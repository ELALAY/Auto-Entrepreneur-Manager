class Client {
  const Client({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.ice,
    required this.ifNumber,
    required this.email,
    required this.phone,
  });

  final String id;
  final String userId;
  final String name;
  final String address;
  final String ice;
  final String ifNumber;
  final String email;
  final String phone;

  Client copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    String? ice,
    String? ifNumber,
    String? email,
    String? phone,
  }) {
    return Client(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      ice: ice ?? this.ice,
      ifNumber: ifNumber ?? this.ifNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
