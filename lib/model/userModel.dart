class User {
  final int id;
  final String name;
  final String email;
  final String number_phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.number_phone
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    number_phone: json['number_phone']
  );
}

class RoleInfo {
  final int id;
  final String role;

  RoleInfo({
    required this.id,
    required this.role,
  });

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      id: json['id'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
    };
  }
}
