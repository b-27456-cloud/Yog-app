class UserModel {
  final String? id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final int? age;
  final String? accessibilityProfile;

  UserModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.age,
    this.accessibilityProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      phone: json['phone'],
      age: json['age'] is String ? int.tryParse(json['age']) : json['age'],
      accessibilityProfile: json['accessibility_profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'age': age,
      'accessibility_profile': accessibilityProfile,
    };
  }
}
