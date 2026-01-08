import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../core/services/auth_api_service.dart';
import '../core/services/notifications_api_service.dart';
import '../core/services/attendance_api_service.dart';
import '../core/services/dashboard_api_service.dart';
import '../core/utils/fcm_helper.dart';

// Theme Provider with Persistence
final isDarkModeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('is_dark_mode') ?? false; // Default to light mode
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }
}

// Auth State
class AuthState {
  final bool isLoggedIn;
  final UserRole? selectedRole;
  final String? token;

  const AuthState({this.isLoggedIn = false, this.selectedRole, this.token});

  AuthState copyWith({
    bool? isLoggedIn,
    UserRole? selectedRole,
    String? token,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      selectedRole: selectedRole ?? this.selectedRole,
      token: token ?? this.token,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState());

  // Load saved session on app startup
  Future<void> loadSession() async {
    debugPrint('========== LOADING SESSION ==========');
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final roleStr = prefs.getString('selected_role');
      final token = prefs.getString('jwt_token');
      final studentsJson = prefs.getString('students_data');

      debugPrint('[SESSION] isLoggedIn: $isLoggedIn');
      debugPrint('[SESSION] role: $roleStr');
      debugPrint('[SESSION] token exists: ${token != null}');
      debugPrint('[SESSION] students data exists: ${studentsJson != null}');

      if (isLoggedIn && token != null) {
        UserRole? role;
        if (roleStr == 'parent') {
          role = UserRole.parent;
        } else if (roleStr == 'student') {
          role = UserRole.student;
        }

        // Restore students list if available
        if (studentsJson != null) {
          try {
            final List<dynamic> studentsList = jsonDecode(studentsJson);
            final students =
                studentsList.map((s) {
                  final m = s as Map<String, dynamic>;
                  return Student(
                    id: m['id'] ?? '',
                    name: m['name'] ?? '',
                    grade: m['grade'] ?? '',
                    studentClass: m['studentClass'] ?? '',
                  );
                }).toList();
            _ref.read(studentsProvider.notifier).state = students;
            debugPrint('[SESSION] ✅ Restored ${students.length} students');
          } catch (e) {
            debugPrint('[SESSION] ❌ Failed to parse students: $e');
          }
        }

        state = AuthState(isLoggedIn: true, selectedRole: role, token: token);
        debugPrint('[SESSION] ✅ Session restored');
      } else {
        debugPrint('[SESSION] No valid session found');
      }
    } catch (e) {
      debugPrint('[SESSION] ❌ Error loading session: $e');
    }
  }

  // Save session data
  Future<void> _saveSession() async {
    debugPrint('========== SAVING SESSION ==========');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', state.isLoggedIn);

      if (state.selectedRole != null) {
        await prefs.setString('selected_role', state.selectedRole!.name);
      }

      // Save students data
      final students = _ref.read(studentsProvider);
      final studentsJson = jsonEncode(
        students
            .map(
              (s) => {
                'id': s.id,
                'name': s.name,
                'grade': s.grade,
                'studentClass': s.studentClass,
              },
            )
            .toList(),
      );
      await prefs.setString('students_data', studentsJson);

      debugPrint('[SESSION] ✅ Session saved');
      debugPrint('[SESSION] isLoggedIn: ${state.isLoggedIn}');
      debugPrint('[SESSION] role: ${state.selectedRole?.name}');
      debugPrint('[SESSION] students count: ${students.length}');
    } catch (e) {
      debugPrint('[SESSION] ❌ Error saving session: $e');
    }
  }

  // Clear session data
  Future<void> _clearSession() async {
    debugPrint('========== CLEARING SESSION ==========');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('selected_role');
      await prefs.remove('jwt_token');
      await prefs.remove('students_data');
      debugPrint('[SESSION] ✅ Session cleared');
    } catch (e) {
      debugPrint('[SESSION] ❌ Error clearing session: $e');
    }
  }

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
    _saveSession();
  }

  Future<bool> loginParent(String phone, String studentCode) async {
    debugPrint('========== AUTH PROVIDER LOGIN ==========');
    debugPrint('[PROVIDER] Login attempt - Phone: $phone, Code: $studentCode');

    final fcmToken = await FcmHelper.getFcmToken();
    debugPrint('[PROVIDER] FCM Token retrieved: ${fcmToken ?? "null"}');

    final result = await AuthApiService.loginParent(
      parentPhone: phone,
      studentCode: studentCode,
      fcmToken: fcmToken,
    );

    debugPrint('[PROVIDER] Login result - Success: ${result.success}');
    if (result.success) {
      debugPrint('[PROVIDER] ✅ Login successful!');
      debugPrint('[PROVIDER] Students count: ${result.students.length}');
      debugPrint('[PROVIDER] Token: ${result.token?.substring(0, 20)}...');

      // Update students list provider
      _ref.read(studentsProvider.notifier).state = result.students;
      state = state.copyWith(isLoggedIn: true, token: result.token);

      // Save session
      await _saveSession();

      debugPrint('[PROVIDER] ✅ State updated - isLoggedIn: true');
      return true;
    } else {
      debugPrint('[PROVIDER] ❌ Login failed: ${result.message}');
      return false;
    }
  }

  Future<void> logout() async {
    await _clearSession();
    state = const AuthState();
    _ref.read(studentsProvider.notifier).state = mockStudents;
    debugPrint('[PROVIDER] ✅ Logged out and session cleared');
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Current Screen Provider
final currentScreenProvider = StateProvider<AppScreen>((ref) => AppScreen.home);

// Students List Provider (mutable, defaults to mock data)
final studentsProvider = StateProvider<List<Student>>((ref) => mockStudents);

// Selected Student Index Provider
final selectedStudentIndexProvider = StateProvider<int>((ref) => 0);

// Current Student Provider (based on selection)
final studentProvider = Provider<Student>((ref) {
  final students = ref.watch(studentsProvider);
  final selectedIndex = ref.watch(selectedStudentIndexProvider);
  return students[selectedIndex];
});

// Attendance State
class AttendanceState {
  final List<AttendanceRecord> attendance;
  final bool isLoading;
  final String? error;
  final int totalRecords;
  final Map<String, dynamic>? studentInfo;

  const AttendanceState({
    this.attendance = const [],
    this.isLoading = false,
    this.error,
    this.totalRecords = 0,
    this.studentInfo,
  });

  AttendanceState copyWith({
    List<AttendanceRecord>? attendance,
    bool? isLoading,
    String? error,
    int? totalRecords,
    Map<String, dynamic>? studentInfo,
  }) {
    return AttendanceState(
      attendance: attendance ?? this.attendance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalRecords: totalRecords ?? this.totalRecords,
      studentInfo: studentInfo ?? this.studentInfo,
    );
  }
}

// Attendance Notifier
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final Ref _ref;

  AttendanceNotifier(this._ref) : super(const AttendanceState());

  Future<void> fetchAttendance({String? startDate, String? endDate}) async {
    debugPrint('========== ATTENDANCE PROVIDER ==========');

    // Get current student and auth token
    final student = _ref.read(studentProvider);
    final authState = _ref.read(authProvider);

    if (authState.token == null) {
      debugPrint('[ATTENDANCE_PROVIDER] ❌ No auth token available');
      state = state.copyWith(
        isLoading: false,
        error: 'Please login to view attendance',
      );
      return;
    }

    debugPrint(
      '[ATTENDANCE_PROVIDER] Fetching for student: ${student.name} (${student.id})',
    );
    if (startDate != null)
      debugPrint('[ATTENDANCE_PROVIDER] Start date: $startDate');
    if (endDate != null) debugPrint('[ATTENDANCE_PROVIDER] End date: $endDate');

    state = state.copyWith(isLoading: true, error: null);

    final result = await AttendanceApiService.getAttendance(
      studentId: student.id,
      token: authState.token!,
      startDate: startDate,
      endDate: endDate,
    );

    debugPrint('[ATTENDANCE_PROVIDER] Result - Success: ${result.success}');

    if (result.success) {
      debugPrint(
        '[ATTENDANCE_PROVIDER] ✅ Loaded ${result.attendance!.length} records',
      );
      state = AttendanceState(
        attendance: result.attendance!,
        isLoading: false,
        totalRecords: result.totalRecords ?? 0,
        studentInfo: result.studentInfo,
      );
    } else {
      debugPrint('[ATTENDANCE_PROVIDER] ❌ Failed: ${result.errorMessage}');
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage ?? 'Failed to load attendance',
      );
    }
  }

  Future<void> refresh() async {
    await fetchAttendance();
  }
}

// Attendance Provider (using StateNotifier)
final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      return AttendanceNotifier(ref);
    });

// Helper provider for the attendance list (for backward compatibility)
final attendanceProvider = Provider<List<AttendanceRecord>>((ref) {
  return ref.watch(attendanceNotifierProvider).attendance;
});

// Dashboard State
class DashboardState {
  final DashboardData? data;
  final bool isLoading;
  final String? error;

  const DashboardState({this.data, this.isLoading = false, this.error});

  DashboardState copyWith({
    DashboardData? data,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Dashboard Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;

  DashboardNotifier(this._ref) : super(const DashboardState());

  Future<void> fetchDashboard() async {
    debugPrint('========== DASHBOARD PROVIDER ==========');

    // Get current student and auth token
    final student = _ref.read(studentProvider);
    final authState = _ref.read(authProvider);

    if (authState.token == null) {
      debugPrint('[DASHBOARD_PROVIDER] ❌ No auth token available');
      state = state.copyWith(
        isLoading: false,
        error: 'Please login to view dashboard',
      );
      return;
    }

    debugPrint(
      '[DASHBOARD_PROVIDER] Fetching for student: ${student.name} (${student.id})',
    );

    state = state.copyWith(isLoading: true, error: null);

    final result = await DashboardApiService.getDashboard(
      studentId: student.id,
      token: authState.token!,
    );

    debugPrint('[DASHBOARD_PROVIDER] Result - Success: ${result.success}');

    if (result.success) {
      debugPrint('[DASHBOARD_PROVIDER] ✅ Dashboard data loaded');
      state = DashboardState(data: result.dashboardData, isLoading: false);
    } else {
      debugPrint('[DASHBOARD_PROVIDER] ❌ Failed: ${result.errorMessage}');
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage ?? 'Failed to load dashboard',
      );
    }
  }

  Future<void> refresh() async {
    await fetchDashboard();
  }
}

// Dashboard Provider
final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier(ref);
    });

// Assignments Provider
final assignmentsProvider = Provider<List<Assignment>>(
  (ref) => mockAssignments,
);

// Fees Provider
final feesProvider = Provider<List<Fee>>((ref) => mockFees);

// Grades Provider
final gradesProvider = Provider<List<Grade>>((ref) => mockGrades);

// Notifications State
class NotificationsState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState());

  Future<void> fetchNotifications({int page = 1, int limit = 20}) async {
    debugPrint('========== NOTIFICATIONS PROVIDER ==========');
    debugPrint('[NOTIF_PROVIDER] Fetching page $page');

    state = state.copyWith(isLoading: true, error: null);

    final result = await NotificationsApiService.getNotifications(
      page: page,
      limit: limit,
    );

    debugPrint('[NOTIF_PROVIDER] Result - Success: ${result.success}');

    if (result.success) {
      debugPrint(
        '[NOTIF_PROVIDER] ✅ Loaded ${result.notifications.length} notifications',
      );
      debugPrint('[NOTIF_PROVIDER] Page ${result.page}/${result.pages}');

      state = NotificationsState(
        notifications: result.notifications,
        isLoading: false,
        currentPage: result.page,
        totalPages: result.pages,
        totalCount: result.total,
      );
    } else {
      debugPrint('[NOTIF_PROVIDER] ❌ Failed: ${result.message}');
      state = state.copyWith(
        isLoading: false,
        error: result.message ?? 'Failed to load notifications',
      );
    }
  }

  Future<void> refresh() async {
    await fetchNotifications(page: 1);
  }

  Future<void> markAsRead(String notificationId) async {
    debugPrint('========== MARK NOTIFICATION READ PROVIDER ==========');
    debugPrint(
      '[NOTIF_PROVIDER] Marking notification as read: $notificationId',
    );

    final success = await NotificationsApiService.markAsRead(notificationId);

    if (success) {
      debugPrint('[NOTIF_PROVIDER] ✅ Updating local state');
      // Update local state - mark notification as read
      final updatedNotifications =
          state.notifications.map((n) {
            if (n.id == notificationId) {
              return AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                description: n.description,
                studentId: n.studentId,
                studentName: n.studentName,
                studentCode: n.studentCode,
                data: n.data,
                isNew: false, // Mark as read
                date: n.date,
              );
            }
            return n;
          }).toList();

      state = state.copyWith(notifications: updatedNotifications);
      debugPrint('[NOTIF_PROVIDER] ✅ Local state updated');
    } else {
      debugPrint('[NOTIF_PROVIDER] ❌ Failed to mark as read');
    }
  }

  Future<void> markAllAsRead() async {
    debugPrint('========== MARK ALL NOTIFICATIONS READ PROVIDER ==========');
    debugPrint('[NOTIF_PROVIDER] Marking all notifications as read');

    final success = await NotificationsApiService.markAllAsRead();

    if (success) {
      debugPrint(
        '[NOTIF_PROVIDER] ✅ Updating local state - marking all as read',
      );
      // Update local state - mark all notifications as read
      final updatedNotifications =
          state.notifications.map((n) {
            return AppNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              description: n.description,
              studentId: n.studentId,
              studentName: n.studentName,
              studentCode: n.studentCode,
              data: n.data,
              isNew: false, // Mark as read
              date: n.date,
            );
          }).toList();

      state = state.copyWith(notifications: updatedNotifications);
      debugPrint(
        '[NOTIF_PROVIDER] ✅ All notifications marked as read in local state',
      );
    } else {
      debugPrint('[NOTIF_PROVIDER] ❌ Failed to mark all as read');
    }
  }
}

// Notifications Provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      return NotificationsNotifier();
    });

// Helper provider for the list
final notificationsListProvider = Provider<List<AppNotification>>((ref) {
  return ref.watch(notificationsProvider).notifications;
});

// Computed Providers
final totalAbsencesProvider = Provider<int>((ref) {
  // Try to get from dashboard first
  final dashboard = ref.watch(dashboardNotifierProvider).data;
  if (dashboard != null) {
    return dashboard.totals.absent;
  }

  // Fallback to attendance list
  final attendance = ref.watch(attendanceProvider);
  return attendance.where((a) => a.status == AttendanceStatus.absent).length;
});

final pendingAssignmentsProvider = Provider<int>((ref) {
  final assignments = ref.watch(assignmentsProvider);
  return assignments
      .where(
        (a) =>
            a.status == AssignmentStatus.pending ||
            a.status == AssignmentStatus.late,
      )
      .length;
});

final newNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsListProvider);
  return notifications.where((n) => n.isNew).length;
});

final totalUnpaidFeesProvider = Provider<double>((ref) {
  // Try to get from dashboard first
  final dashboard = ref.watch(dashboardNotifierProvider).data;
  if (dashboard != null) {
    return dashboard.payment.amountRemaining;
  }

  // Fallback to fees list
  final fees = ref.watch(feesProvider);
  return fees
      .where((f) => f.status == FeeStatus.unpaid)
      .fold(0, (sum, fee) => sum + fee.amount);
});

final averageGradeProvider = Provider<int>((ref) {
  final grades = ref.watch(gradesProvider);
  if (grades.isEmpty) return 0;
  return (grades.fold(0, (sum, g) => sum + g.score) / grades.length).round();
});

// Announcement Tab Filter Provider
final announcementTabProvider = StateProvider<NotificationType?>((ref) => null);

final filteredNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationsListProvider);
  final filter = ref.watch(announcementTabProvider);

  if (filter == null) return notifications;
  return notifications.where((n) => n.type == filter).toList();
});

// Selected Month Provider for Attendance
final selectedMonthProvider = StateProvider<String>((ref) => 'December 2025');
