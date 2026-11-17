import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

typedef McpToolCall = Future<Object?> Function(String name, Map<String, dynamic> arguments);

/// Foreground-only, stateless Streamable HTTP transport. No browser origins.
class LocalMcpServer {
  LocalMcpServer({required this.tools, required this.callTool, required this.authorized});

  final List<Map<String, dynamic>> tools;
  final McpToolCall callTool;
  final bool Function() authorized;
  HttpServer? _server;
  String? token;
  int? get port => _server?.port;

  Future<void> start({bool lan = false, int port = 8765}) async {
    if (_server != null) throw StateError('Already running');
    final random = Random.secure();
    token = base64Url.encode(List.generate(32, (_) => random.nextInt(256)));
    _server = await HttpServer.bind(lan ? InternetAddress.anyIPv4 : InternetAddress.loopbackIPv4, port);
    _server!.idleTimeout = const Duration(seconds: 15);
    _server!.listen((request) { unawaited(_handle(request)); });
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    token = null;
    await server?.close(force: true);
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      if (request.uri.path != '/mcp') { response.statusCode = 404; return; }
      if (request.headers.value('origin') != null) { response.statusCode = 403; return; }
      if (!authorized() || token == null || request.headers.value('authorization') != 'Bearer $token') {
        response.statusCode = 401;
        return;
      }
      if (request.method != 'POST') {
        response.statusCode = 405;
        response.headers.set('Allow', 'POST');
        return;
      }
      if (request.headers.contentType?.mimeType != 'application/json') {
        response.statusCode = 415;
        return;
      }
      final bytes = <int>[];
      await for (final chunk in request.timeout(const Duration(seconds: 10))) {
        bytes.addAll(chunk);
        if (bytes.length > 65536) { response.statusCode = 413; return; }
      }
      dynamic message;
      try { message = jsonDecode(utf8.decode(bytes)); }
      catch (_) { _write(response, _error(null, -32700, 'Parse error')); return; }
      final messages = message is List ? message : [message];
      if (messages.isEmpty || messages.length > 20) {
        _write(response, _error(null, -32600, 'Invalid batch')); return;
      }
      final results = <Object>[];
      for (final item in messages) {
        final result = await _dispatch(item);
        if (result != null) results.add(result);
      }
      if (results.isEmpty) { response.statusCode = 202; return; }
      _write(response, message is List ? results : results.single);
    } catch (_) {
      response.statusCode = 400;
    } finally {
      await response.close();
    }
  }

  Future<Map<String, dynamic>?> _dispatch(dynamic message) async {
    if (message is! Map || message['jsonrpc'] != '2.0' || message['method'] is! String ||
        (message.containsKey('id') && message['id'] is! String && message['id'] is! num) ||
        (message['params'] != null && message['params'] is! Map)) {
      return _error(null, -32600, 'Invalid request');
    }
    final id = message['id'];
    if (!message.containsKey('id')) return null;
    if (!authorized() || token == null) return _error(id, -32001, 'Connector stopped or account changed');
    final params = Map<String, dynamic>.from(message['params'] as Map? ?? {});
    Object result;
    switch (message['method']) {
      case 'initialize':
        result = {'protocolVersion': '2025-03-26', 'capabilities': {'tools': {}},
          'serverInfo': {'name': 'auto-entrepreneur-phone', 'version': '1.0.0'}};
      case 'ping': result = <String, dynamic>{};
      case 'tools/list': result = {'tools': tools};
      case 'tools/call':
        final name = params['name'];
        if (name is! String || !tools.any((t) => t['name'] == name) ||
            (params['arguments'] != null && params['arguments'] is! Map)) {
          return _error(id, -32602, 'Unknown tool or invalid arguments');
        }
        try {
          final value = await callTool(name, Map<String, dynamic>.from(params['arguments'] as Map? ?? {}));
          if (!authorized() || token == null) return _error(id, -32001, 'Connector stopped');
          result = {'content': [{'type': 'text', 'text': jsonEncode(value)}]};
        } on ArgumentError catch (e) {
          result = {'isError': true, 'content': [{'type': 'text', 'text': e.message.toString()}]};
        } catch (_) {
          result = {'isError': true, 'content': [{'type': 'text', 'text': 'Operation failed. Check sign-in and connectivity in the app before retrying.'}]};
        }
      default: return _error(id, -32601, 'Method not found');
    }
    return {'jsonrpc': '2.0', 'id': id, 'result': result};
  }

  static Map<String, dynamic> _error(dynamic id, int code, String message) =>
      {'jsonrpc': '2.0', 'id': id, 'error': {'code': code, 'message': message}};

  void _write(HttpResponse response, Object value) {
    response.headers.contentType = ContentType.json;
    response.headers.set('Cache-Control', 'no-store');
    response.write(jsonEncode(value));
  }
}
