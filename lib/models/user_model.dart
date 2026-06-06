class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String password;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.password,
  });

  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Food Rush customer',
      email: json['email'],
      phone: json['phone'],
      password: json['password'] ?? '',
    );
  }

  /// Legacy single-contact format support.
  factory UserModel.fromLegacyJson(Map<String, dynamic> json) {
    final contact = (json['contact'] ?? '').toString().trim();
    final isEmail = contact.contains('@');
    return UserModel(
      id: 'legacy-${contact.hashCode}',
      name: json['name'] ?? 'Food Rush customer',
      email: isEmail ? contact : null,
      phone: isEmail ? null : contact,
      password: '',
    );
  }
}
