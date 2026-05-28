//Model for a single entry of UserProfile
// ignore_for_file: non_constant_identifier_names

class UserProfile {
  final String firebase_uid;
  final String emailAddress;
  final String password;
  final String firstName;
  final String? lastName;

  const UserProfile({
    required this.firebase_uid,
    required this.emailAddress,
    required this.password,
    required this.firstName,
    this.lastName
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firebase_uid: json['firebase_uid']?.toString() ?? '',
      emailAddress: json['emailAddress']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? ''
    );
  }
}