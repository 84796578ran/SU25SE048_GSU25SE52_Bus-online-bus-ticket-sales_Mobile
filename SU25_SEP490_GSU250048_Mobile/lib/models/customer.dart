class Customer {
  Customer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.userName,

  });
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? password;
  final String? userName;


  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String, // Assuming 'id' is always present and non-null
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String?, // Again, handle this securely in a real app
      userName: json['userName'] as String?,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'userName': userName,
    };
  }

  @override
  String toString() {
    return 'Customer(\n'
        '  id: $id,\n'
        '  fullName: $fullName,\n'
        '  email: $email,\n'
        '  phone: $phone,\n'
        '  userName: $userName,\n'
        '  password: [HIDDEN]\n'
        ')';
  }
}