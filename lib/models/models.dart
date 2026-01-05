// Student Model
class Student {
  final String id;
  final String name;
  final String grade;
  final String studentClass;
  final String? avatarUrl;

  const Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.studentClass,
    this.avatarUrl,
  });
}

// Attendance Record Model
enum AttendanceStatus { present, absent }
enum HomeworkStatus { done, notDone }

class AttendanceRecord {
  final String date;
  final AttendanceStatus status;
  final HomeworkStatus homeworkStatus;

  const AttendanceRecord({
    required this.date,
    required this.status,
    required this.homeworkStatus,
  });
}

// Assignment Model
enum AssignmentStatus { done, pending, late }

class Assignment {
  final String id;
  final String subject;
  final String title;
  final String dueDate;
  final AssignmentStatus status;

  const Assignment({
    required this.id,
    required this.subject,
    required this.title,
    required this.dueDate,
    required this.status,
  });
}

// Fee Model
enum FeeStatus { paid, unpaid }

class Fee {
  final String id;
  final String type;
  final double amount;
  final String dueDate;
  final FeeStatus status;

  const Fee({
    required this.id,
    required this.type,
    required this.amount,
    required this.dueDate,
    required this.status,
  });
}

// Grade Model
class Grade {
  final String id;
  final String subject;
  final String examType;
  final int score;
  final int maxScore;
  final String grade;

  const Grade({
    required this.id,
    required this.subject,
    required this.examType,
    required this.score,
    required this.maxScore,
    required this.grade,
  });
}

// Notification Model
enum NotificationType { attendance, assignment, fee, grade, message, general }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final String? teacherName;
  final String date;
  final bool isNew;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.teacherName,
    required this.date,
    required this.isNew,
  });
}

// Screen enum for navigation
enum AppScreen {
  login,
  home,
  attendance,
  announcements,
  assignments,
  fees,
  grades,
  profile,
}

// User Role enum
enum UserRole { parent, student }

