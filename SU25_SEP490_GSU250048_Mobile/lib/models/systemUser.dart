
class SystemUser {
  final int id;
  final String email;
  final String fullName;
  final String phone;
  final String systemId;
  final int companyId;
  final String password;
  final int roleId;

  // Bạn có thể thêm các thuộc tính này nếu API trả về cùng với SystemUser
  // final Company company;
  // final Role role;

  SystemUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.systemId,
    required this.companyId,
    required this.password,
    required this.roleId,
    // this.company,
    // this.role,
  });

  // Factory constructor để tạo SystemUser từ JSON (Map)
  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      systemId: json['systemId'] as String,
      companyId: json['companyId'] as int,
      password: json['password'] as String,
      roleId: json['roleId'] as int,
      // company: json['company'] != null
      //     ? Company.fromJson(json['company'] as Map<String, dynamic>)
      //     : null,
      // role: json['role'] != null
      //     ? Role.fromJson(json['role'] as Map<String, dynamic>)
      //     : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'systemId': systemId,
      'companyId': companyId,
      'password': password,
      'roleId': roleId,
      // 'company': company?.toJson(),
      // 'role': role?.toJson(),
    };
  }
}