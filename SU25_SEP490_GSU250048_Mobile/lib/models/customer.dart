class Customer {
  Customer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.token,
  });
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? token;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
        '  fullName: $fullName,\n'
        '  email: $email,\n'
        '  phone: $phone,\n'
        '  password: [HIDDEN]\n'
        ')';
  }
}