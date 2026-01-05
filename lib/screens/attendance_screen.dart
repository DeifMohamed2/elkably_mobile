import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(attendanceProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    final presentCount = attendance.where((a) => a.status == AttendanceStatus.present).length;
    final absentCount = attendance.where((a) => a.status == AttendanceStatus.absent).length;
    final attendanceRate = attendance.isNotEmpty
        ? ((presentCount / attendance.length) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.headerGradient,
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Month Selector
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedMonth,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Attendance Records
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ...attendance.map((record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AttendanceRecordCard(record: record),
                    )),

                    const SizedBox(height: 12),

                    // Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.elkablyRed.withValues(alpha: 0.1),
                            AppColors.elkablyDarkRed.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.elkablyRed.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryItem(
                                  label: 'Present',
                                  value: '$presentCount',
                                  valueColor: AppColors.success,
                                ),
                              ),
                              Expanded(
                                child: _SummaryItem(
                                  label: 'Absent',
                                  value: '$absentCount',
                                  valueColor: AppColors.elkablyRed,
                                ),
                              ),
                              Expanded(
                                child: _SummaryItem(
                                  label: 'Rate',
                                  value: '$attendanceRate%',
                                  valueColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  final AttendanceRecord record;

  const _AttendanceRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(record.date);
    final dayName = DateFormat('EEE').format(date);
    final dayNumber = date.day;
    final monthName = DateFormat('MMM').format(date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Info
          Column(
            children: [
              Text(
                dayName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '$dayNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                monthName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Divider
          Container(
            width: 1,
            height: 48,
            color: AppColors.borderLight,
          ),
          const SizedBox(width: 16),

          // Status Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attendance Status
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: record.status == AttendanceStatus.present
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.elkablyRed.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        record.status == AttendanceStatus.present
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 16,
                        color: record.status == AttendanceStatus.present
                            ? AppColors.success
                            : AppColors.elkablyRed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.status == AttendanceStatus.present ? 'Present' : 'Absent',
                      style: TextStyle(
                        color: record.status == AttendanceStatus.present
                            ? AppColors.success
                            : AppColors.elkablyRed,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Homework Status
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: record.homeworkStatus == HomeworkStatus.done
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.warning.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        record.homeworkStatus == HomeworkStatus.done
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 16,
                        color: record.homeworkStatus == HomeworkStatus.done
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.homeworkStatus == HomeworkStatus.done
                          ? 'Homework Done'
                          : 'Homework Pending',
                      style: TextStyle(
                        color: record.homeworkStatus == HomeworkStatus.done
                            ? AppColors.textSecondary
                            : AppColors.warning,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

