class User {
  final String userName;
  final String password;
  final String university;
  final String fullName;
  final String major;

  User({
    required this.userName,
    required this.password,
    required this.university,
    required this.fullName,
    required this.major,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['userName'],
      password: json['password'],
      university: json['university'],
      fullName: json['fullName'],
      major: json['major'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
      'university': university,
      'fullName': fullName,
      'major': major,
    };
  }
}
