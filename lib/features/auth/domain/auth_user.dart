class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, String> toStorageMap() => {'id': id, 'name': name, 'email': email};

  factory AuthUser.fromStorageMap(Map<String, String> map) {
    return AuthUser(id: map['id'] ?? '', name: map['name'] ?? '', email: map['email'] ?? '');
  }
}
