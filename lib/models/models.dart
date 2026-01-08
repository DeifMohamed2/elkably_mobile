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
enum AttendanceStatus { present, absent, late, presentFromOtherGroup }

enum HomeworkStatus { 
  done, // HomeWork submitted with steps
  doneWithoutSteps, // HomeWork submitted without steps
  notDone, // HomeWork not submitted
  notAvailable // N/A
}

class AttendanceRecord {
  final String date;
  final AttendanceStatus status;
  final String? time;
  final HomeworkStatus homeworkStatus;
  final double? amountPaid;
  final double? amountRemaining;

  const AttendanceRecord({
    required this.date,
    required this.status,
    this.time,
    required this.homeworkStatus,
    this.amountPaid,
    this.amountRemaining,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Parse status
    AttendanceStatus status;
    final statusStr = json['status'] as String?;
    switch (statusStr?.toLowerCase()) {
      case 'present':
        status = AttendanceStatus.present;
        break;
      case 'late':
        status = AttendanceStatus.late;
        break;
      case 'present from other group':
        status = AttendanceStatus.presentFromOtherGroup;
        break;
      case 'absent':
      default:
        status = AttendanceStatus.absent;
    }

    // Parse homework status
    HomeworkStatus hwStatus;
    final hwStr = json['homeworkStatus'] as String?;
    if (hwStr == null || hwStr == 'N/A') {
      hwStatus = HomeworkStatus.notAvailable;
    } else if (hwStr.contains('with steps')) {
      hwStatus = HomeworkStatus.done;
    } else if (hwStr.contains('without steps')) {
      hwStatus = HomeworkStatus.doneWithoutSteps;
    } else {
      hwStatus = HomeworkStatus.notDone;
    }

    return AttendanceRecord(
      date: json['date'] as String,
      status: status,
      time: json['time'] as String?,
      homeworkStatus: hwStatus,
      amountPaid: (json['amountPaid'] as num?)?.toDouble(),
      amountRemaining: (json['amountRemaining'] as num?)?.toDouble(),
    );
  }
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
enum NotificationType {
  attendance,
  homework,
  payment,
  block,
  unblock,
  custom,
  assignment,
  fee,
  grade,
  message,
  general,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final String? studentId;
  final String? studentName;
  final String? studentCode;
  final Map<String, dynamic>? data;
  final bool isNew;
  final String date;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.studentId,
    this.studentName,
    this.studentCode,
    this.data,
    required this.isNew,
    required this.date,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Parse type
    NotificationType parseType(String? typeStr) {
      switch (typeStr?.toLowerCase()) {
        case 'attendance':
          return NotificationType.attendance;
        case 'homework':
          return NotificationType.homework;
        case 'payment':
          return NotificationType.payment;
        case 'block':
          return NotificationType.block;
        case 'unblock':
          return NotificationType.unblock;
        case 'custom':
          return NotificationType.custom;
        default:
          return NotificationType.general;
      }
    }

    // Handle studentId - can be either a string or an object
    String? studentIdStr;
    String? studentNameStr;
    String? studentCodeStr;
    
    final studentIdField = json['studentId'];
    if (studentIdField is Map<String, dynamic>) {
      // studentId is an object
      studentIdStr = studentIdField['_id']?.toString();
      studentNameStr = studentIdField['Username']?.toString() ?? 
                      studentIdField['name']?.toString();
      studentCodeStr = studentIdField['Code']?.toString();
    } else if (studentIdField is String) {
      // studentId is just a string
      studentIdStr = studentIdField;
      // Try to get student info from data field if available
      final dataField = json['data'];
      if (dataField is Map<String, dynamic>) {
        studentNameStr = dataField['studentName']?.toString();
      }
    }

    return AppNotification(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      type: parseType(json['type']?.toString()),
      title: (json['title'] ?? '').toString(),
      description: (json['body'] ?? json['description'] ?? '').toString(),
      studentId: studentIdStr,
      studentName: studentNameStr,
      studentCode: studentCodeStr,
      data: json['data'] as Map<String, dynamic>?,
      isNew: json['isRead'] == false,
      date: (json['createdAt'] ?? json['date'] ?? '').toString(),
    );
  }
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

// Dashboard Models
class DashboardLastSession {
  final String date;
  final AttendanceStatus status;
  final String? time;
  final String homeworkStatus;

  const DashboardLastSession({
    required this.date,
    required this.status,
    this.time,
    required this.homeworkStatus,
  });

  factory DashboardLastSession.fromJson(Map<String, dynamic> json) {
    AttendanceStatus status;
    final statusStr = json['status'] as String?;
    switch (statusStr?.toLowerCase()) {
      case 'present':
        status = AttendanceStatus.present;
        break;
      case 'late':
        status = AttendanceStatus.late;
        break;
      case 'present from other group':
        status = AttendanceStatus.presentFromOtherGroup;
        break;
      case 'absent':
      default:
        status = AttendanceStatus.absent;
    }

    return DashboardLastSession(
      date: json['date'] as String,
      status: status,
      time: json['time'] as String?,
      homeworkStatus: json['homeworkStatus'] as String? ?? 'N/A',
    );
  }
}

class DashboardPayment {
  final double balance;
  final double amountRemaining;

  const DashboardPayment({
    required this.balance,
    required this.amountRemaining,
  });

  factory DashboardPayment.fromJson(Map<String, dynamic> json) {
    return DashboardPayment(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      amountRemaining: (json['amountRemaining'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardTotals {
  final int present;
  final int late;
  final int absent;

  const DashboardTotals({
    required this.present,
    required this.late,
    required this.absent,
  });

  factory DashboardTotals.fromJson(Map<String, dynamic> json) {
    return DashboardTotals(
      present: json['present'] as int? ?? 0,
      late: json['late'] as int? ?? 0,
      absent: json['absent'] as int? ?? 0,
    );
  }

  int get total => present + late + absent;
}

class DashboardData {
  final Map<String, dynamic> student;
  final DashboardLastSession? lastSession;
  final DashboardPayment payment;
  final DashboardTotals totals;
  final List<AppNotification> recentNotifications;

  const DashboardData({
    required this.student,
    this.lastSession,
    required this.payment,
    required this.totals,
    required this.recentNotifications,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      student: json['student'] as Map<String, dynamic>? ?? {},
      lastSession: json['lastSession'] != null
          ? DashboardLastSession.fromJson(json['lastSession'] as Map<String, dynamic>)
          : null,
      payment: DashboardPayment.fromJson(json['payment'] as Map<String, dynamic>? ?? {}),
      totals: DashboardTotals.fromJson(json['totals'] as Map<String, dynamic>? ?? {}),
      recentNotifications: (json['recentNotifications'] as List<dynamic>?)
              ?.map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
