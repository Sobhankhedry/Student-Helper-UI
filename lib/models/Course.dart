class Course {
  final String id;
  final String group;
  final String courseCode;
  final String courseName;
  final String professorId;
  final String professorName;
  final String universityId;
  final String universityName;
  final String day;
  final String date;
  final String hour;
  final String majorId;
  final String majorName;
  final String status;
  final String finalExam;
  final String classroom;
  final String examHour;

  Course({
    required this.id,
    required this.group,
    required this.courseCode,
    required this.courseName,
    required this.professorId,
    required this.professorName,
    required this.universityId,
    required this.universityName,
    required this.day,
    required this.date,
    required this.hour,
    required this.majorId,
    required this.majorName,
    required this.status,
    required this.finalExam,
    required this.classroom,
    required this.examHour,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      group: json['group'] ?? '',
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      professorId: json['professorId'] ?? '',
      professorName: json['professorName'] ?? '',
      universityId: json['universityId'] ?? '',
      universityName: json['universityName'] ?? '',
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      hour: json['hour'] ?? '',
      majorId: json['majorId'] ?? '',
      majorName: json['majorName'] ?? '',
      status: json['status'] ?? '',
      finalExam: json['finalExam'] ?? '',
      classroom: json['classroom'] ?? '',
      examHour: json['examHour'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': group,
      'courseCode': courseCode,
      'courseName': courseName,
      'professorId': professorId,
      'professorName': professorName,
      'universityId': universityId,
      'universityName': universityName,
      'day': day,
      'date': date,
      'hour': hour,
      'majorId': majorId,
      'majorName': majorName,
      'status': status,
      'finalExam': finalExam,
      'classroom': classroom,
      'examHour': examHour,
    };
  }
}
