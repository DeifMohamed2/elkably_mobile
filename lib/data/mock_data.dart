import '../models/models.dart';

// Mock Students Data
const List<Student> mockStudents = [
  Student(
    id: '1',
    name: 'Ahmed Hassan',
    grade: 'Grade 10',
    studentClass: 'Class A',
  ),
  Student(
    id: '2',
    name: 'Sara Hassan',
    grade: 'Grade 8',
    studentClass: 'Class B',
  ),
  Student(
    id: '3',
    name: 'Omar Hassan',
    grade: 'Grade 6',
    studentClass: 'Class C',
  ),
];

// Mock Student Data (for backwards compatibility)
const Student mockStudent = Student(
  id: '1',
  name: 'Ahmed Hassan',
  grade: 'Grade 10',
  studentClass: 'Class A',
);

// Mock Attendance Data
const List<AttendanceRecord> mockAttendance = [
  AttendanceRecord(
    date: '2025-12-22',
    status: AttendanceStatus.present,
    homeworkStatus: HomeworkStatus.done,
  ),
  AttendanceRecord(
    date: '2025-12-21',
    status: AttendanceStatus.present,
    homeworkStatus: HomeworkStatus.done,
  ),
  AttendanceRecord(
    date: '2025-12-20',
    status: AttendanceStatus.absent,
    homeworkStatus: HomeworkStatus.notDone,
  ),
  AttendanceRecord(
    date: '2025-12-19',
    status: AttendanceStatus.present,
    homeworkStatus: HomeworkStatus.done,
  ),
  AttendanceRecord(
    date: '2025-12-18',
    status: AttendanceStatus.present,
    homeworkStatus: HomeworkStatus.notDone,
  ),
  AttendanceRecord(
    date: '2025-12-17',
    status: AttendanceStatus.present,
    homeworkStatus: HomeworkStatus.done,
  ),
  AttendanceRecord(
    date: '2025-12-16',
    status: AttendanceStatus.present,
    homeworkStatus: HomeworkStatus.done,
  ),
  AttendanceRecord(
    date: '2025-12-15',
    status: AttendanceStatus.present,
    homeworkStatus: HomeworkStatus.done,
  ),
  AttendanceRecord(
    date: '2025-12-14',
    status: AttendanceStatus.present,
    homeworkStatus: HomeworkStatus.done,
  ),
  AttendanceRecord(
    date: '2025-12-13',
    status: AttendanceStatus.absent,
    homeworkStatus: HomeworkStatus.notDone,
  ),
];

// Mock Assignments Data
const List<Assignment> mockAssignments = [
  Assignment(
    id: '1',
    subject: 'Mathematics',
    title: 'Chapter 5 Exercises',
    dueDate: '2025-12-25',
    status: AssignmentStatus.pending,
  ),
  Assignment(
    id: '2',
    subject: 'Physics',
    title: 'Lab Report - Motion',
    dueDate: '2025-12-23',
    status: AssignmentStatus.late,
  ),
  Assignment(
    id: '3',
    subject: 'English',
    title: 'Essay: Climate Change',
    dueDate: '2025-12-28',
    status: AssignmentStatus.pending,
  ),
  Assignment(
    id: '4',
    subject: 'Chemistry',
    title: 'Periodic Table Quiz',
    dueDate: '2025-12-20',
    status: AssignmentStatus.done,
  ),
  Assignment(
    id: '5',
    subject: 'History',
    title: 'World War II Research',
    dueDate: '2025-12-30',
    status: AssignmentStatus.pending,
  ),
];

// Mock Fees Data
const List<Fee> mockFees = [
  Fee(
    id: '1',
    type: 'Tuition Fee - December',
    amount: 5000,
    dueDate: '2025-12-31',
    status: FeeStatus.unpaid,
  ),
  Fee(
    id: '2',
    type: 'Bus Fee - December',
    amount: 500,
    dueDate: '2025-12-31',
    status: FeeStatus.unpaid,
  ),
  Fee(
    id: '3',
    type: 'Tuition Fee - November',
    amount: 5000,
    dueDate: '2025-11-30',
    status: FeeStatus.paid,
  ),
  Fee(
    id: '4',
    type: 'Bus Fee - November',
    amount: 500,
    dueDate: '2025-11-30',
    status: FeeStatus.paid,
  ),
  Fee(
    id: '5',
    type: 'Activity Fee',
    amount: 300,
    dueDate: '2025-12-15',
    status: FeeStatus.paid,
  ),
];

// Mock Grades Data
const List<Grade> mockGrades = [
  Grade(
    id: '1',
    subject: 'Mathematics',
    examType: 'Midterm Exam',
    score: 88,
    maxScore: 100,
    grade: 'A',
  ),
  Grade(
    id: '2',
    subject: 'Physics',
    examType: 'Midterm Exam',
    score: 82,
    maxScore: 100,
    grade: 'B+',
  ),
  Grade(
    id: '3',
    subject: 'English',
    examType: 'Midterm Exam',
    score: 91,
    maxScore: 100,
    grade: 'A+',
  ),
  Grade(
    id: '4',
    subject: 'Chemistry',
    examType: 'Midterm Exam',
    score: 85,
    maxScore: 100,
    grade: 'A',
  ),
  Grade(
    id: '5',
    subject: 'History',
    examType: 'Midterm Exam',
    score: 78,
    maxScore: 100,
    grade: 'B',
  ),
  Grade(
    id: '6',
    subject: 'Arabic',
    examType: 'Midterm Exam',
    score: 93,
    maxScore: 100,
    grade: 'A+',
  ),
];

// Mock Notifications Data
const List<AppNotification> mockNotifications = [
  AppNotification(
    id: '1',
    type: NotificationType.attendance,
    title: 'Absence Alert',
    description: 'Your child was absent today. Please contact the school office.',
    studentName: 'Ahmed Hassan',
    studentCode: 'K1234',
    date: '2025-12-20T09:30:00',
    isNew: true,
  ),
  AppNotification(
    id: '2',
    type: NotificationType.assignment,
    title: 'New Assignment Posted',
    description: 'Physics Lab Report has been assigned. Due date: December 23.',
    studentName: 'Ahmed Hassan',
    studentCode: 'K1234',
    date: '2025-12-19T14:20:00',
    isNew: true,
  ),
  AppNotification(
    id: '3',
    type: NotificationType.grade,
    title: 'Midterm Results Published',
    description: 'Mathematics midterm exam results are now available.',
    studentName: 'Ahmed Hassan',
    studentCode: 'K1234',
    date: '2025-12-18T11:00:00',
    isNew: false,
  ),
  AppNotification(
    id: '4',
    type: NotificationType.fee,
    title: 'Payment Reminder',
    description: 'December tuition fee is due by December 31.',
    date: '2025-12-17T08:00:00',
    isNew: false,
  ),
  AppNotification(
    id: '5',
    type: NotificationType.message,
    title: 'Parent-Teacher Meeting',
    description: 'Scheduled for December 28 at 10:00 AM.',
    studentName: 'Sara Hassan',
    studentCode: 'K5678',
    date: '2025-12-16T16:45:00',
    isNew: false,
  ),
  AppNotification(
    id: '6',
    type: NotificationType.general,
    title: 'Winter Break Announcement',
    description: 'School will be closed from December 24 to January 5.',
    date: '2025-12-15T12:00:00',
    isNew: false,
  ),
  AppNotification(
    id: '7',
    type: NotificationType.assignment,
    title: 'English Essay Submitted',
    description: 'Your child submitted the Climate Change essay.',
    studentName: 'Ahmed Hassan',
    studentCode: 'K1234',
    date: '2025-12-14T15:30:00',
    isNew: false,
  ),
  AppNotification(
    id: '8',
    type: NotificationType.attendance,
    title: 'Perfect Attendance Week',
    description: 'Congratulations! Your child had perfect attendance this week.',
    date: '2025-12-13T17:00:00',
    isNew: false,
  ),
];

