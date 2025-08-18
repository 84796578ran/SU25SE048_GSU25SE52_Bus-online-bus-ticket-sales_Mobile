

class SystemUser {
  final int id;
  final String systemId;
  final String email;
  final String fullName;
  final String phone;
  final String address;
  final int companyId;
  final String password;
  final String avartar;
  final bool isActive;
  final bool isDeleted;
  final int roleId;

  SystemUser({
    required this.id,
    required this.systemId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.companyId,
    required this.password,
    required this.avartar,
    required this.isActive,
    required this.isDeleted,
    required this.roleId,
  });

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      id: json['id'] as int,
      systemId: json['systemId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      companyId: json['companyId'] as int,
      password: json['password'] as String,
      avartar: json['avartar'] as String,
      isActive: json['isActive'] as bool,
      isDeleted: json['isDeleted'] as bool,
      roleId: json['roleId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systemId': systemId,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'companyId': companyId,
      'password': password,
      'avartar': avartar,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'roleId': roleId,
    };
  }
}