class Customer {
  Customer({
    required this.id,
    required this.customerId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.token,
  });

  final int id;
  final String? customerId; // Đã thêm lại trường này
  final String? fullName;
  final String? email;
  final String? phone;
  final String? token;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      customerId: json['customerId'] as String, // Thêm trường này vào đây
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId, // Thêm trường này vào đây
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'token': token,
    };
  }

  @override
  String toString() {
    return 'Customer(\n'
        '  id: $id,\n'
        '  customerId: $customerId,\n'
        '  fullName: $fullName,\n'
        '  email: $email,\n'
        '  phone: $phone,\n'
        '  token: [HIDDEN]\n'
        ')';
  }
}