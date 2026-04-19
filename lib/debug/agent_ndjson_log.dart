import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const _agentLogPath =
    r'c:\Users\elala\OneDrive\Bureau\Projects\Auto-Entrepreneur-Manager\.cursor\debug.log';

/// Debug-mode NDJSON log (desktop: file; mobile emulator: POST to host ingest).
Future<void> agentNdjsonLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?> data = const {},
  String runId = 'pre-fix',
}) async {
  // #region agent log
  final payload = <String, Object?>{
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'runId': runId,
  };
  final line = jsonEncode(payload);
  try {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await File(_agentLogPath).writeAsString('$line\n', mode: FileMode.append, flush: true);
      return;
    }
  } catch (_) {}
  try {
    final host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : '127.0.0.1';
    final uri = Uri.parse(
      'http://$host:7245/ingest/736f0e76-bd51-44b5-8948-4681a0944351',
    );
    await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: line)
        .timeout(const Duration(seconds: 3));
  } catch (_) {}
  // #endregion
}
