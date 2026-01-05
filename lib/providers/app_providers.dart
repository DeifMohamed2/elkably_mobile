import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

// Auth State
class AuthState {
  final bool isLoggedIn;
  final UserRole? selectedRole;

  const AuthState({
    this.isLoggedIn = false,
    this.selectedRole,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    UserRole? selectedRole,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  void login() {
    state = state.copyWith(isLoggedIn: true);
  }

  void logout() {
    state = const AuthState();
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Current Screen Provider
final currentScreenProvider = StateProvider<AppScreen>((ref) => AppScreen.home);

// Student Provider
final studentProvider = Provider<Student>((ref) => mockStudent);

// Attendance Provider
final attendanceProvider = Provider<List<AttendanceRecord>>((ref) => mockAttendance);

// Assignments Provider
final assignmentsProvider = Provider<List<Assignment>>((ref) => mockAssignments);

// Fees Provider
final feesProvider = Provider<List<Fee>>((ref) => mockFees);

// Grades Provider
final gradesProvider = Provider<List<Grade>>((ref) => mockGrades);

// Notifications Provider
final notificationsProvider = Provider<List<AppNotification>>((ref) => mockNotifications);

// Computed Providers
final totalAbsencesProvider = Provider<int>((ref) {
  final attendance = ref.watch(attendanceProvider);
  return attendance.where((a) => a.status == AttendanceStatus.absent).length;
});

final pendingAssignmentsProvider = Provider<int>((ref) {
  final assignments = ref.watch(assignmentsProvider);
  return assignments.where((a) => a.status == AssignmentStatus.pending || a.status == AssignmentStatus.late).length;
});

final newNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => n.isNew).length;
});

final totalUnpaidFeesProvider = Provider<double>((ref) {
  final fees = ref.watch(feesProvider);
  return fees.where((f) => f.status == FeeStatus.unpaid).fold(0, (sum, fee) => sum + fee.amount);
});

final averageGradeProvider = Provider<int>((ref) {
  final grades = ref.watch(gradesProvider);
  if (grades.isEmpty) return 0;
  return (grades.fold(0, (sum, g) => sum + g.score) / grades.length).round();
});

// Announcement Tab Filter Provider
final announcementTabProvider = StateProvider<NotificationType?>((ref) => null);

final filteredNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  final filter = ref.watch(announcementTabProvider);
  
  if (filter == null) return notifications;
  return notifications.where((n) => n.type == filter).toList();
});

// Selected Month Provider for Attendance
final selectedMonthProvider = StateProvider<String>((ref) => 'December 2025');

