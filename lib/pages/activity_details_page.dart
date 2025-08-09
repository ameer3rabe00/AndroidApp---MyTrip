import 'package:flutter/material.dart';
import '../models/activity_model.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsPage({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('פרטי פעילות'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: activity.isDone
                        ? Colors.green.shade50
                        : activity.isPast
                            ? Colors.red.shade50
                            : Colors.blue.shade50,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: activity.isDone
                              ? Colors.green
                              : activity.isPast
                                  ? Colors.red
                                  : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          activity.isDone
                              ? Icons.check_circle
                              : activity.isPast
                                  ? Icons.access_time
                                  : Icons.schedule,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.isDone
                                  ? 'פעילות הושלמה'
                                  : activity.isPast
                                      ? 'פעילות שעברה'
                                      : 'פעילות מתוכננת',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: activity.isDone
                                    ? Colors.green.shade700
                                    : activity.isPast
                                        ? Colors.red.shade700
                                        : Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.isDone
                                  ? 'המשימה בוצעה בהצלחה'
                                  : activity.isPast
                                      ? 'המשימה לא בוצעה בזמן'
                                      : 'המשימה מתוכננת לביצוע',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Activity Details Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_note,
                            color: Colors.teal.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'פרטי הפעילות',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // שם הפעילות
                      _buildDetailRow(
                        icon: Icons.title,
                        label: 'שם הפעילות',
                        value: activity.title,
                        isTitle: true,
                      ),

                      const SizedBox(height: 16),

                      // תיאור
                      _buildDetailRow(
                        icon: Icons.description,
                        label: 'תיאור',
                        value: activity.description?.isNotEmpty == true
                            ? activity.description!
                            : 'לא הוגדר תיאור',
                        isEmpty: activity.description?.isEmpty ?? true,
                      ),

                      const SizedBox(height: 16),

                      // תאריך ושעה
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              icon: Icons.calendar_today,
                              label: 'תאריך',
                              value: activity.formattedDate,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              icon: Icons.access_time,
                              label: 'שעה',
                              value: activity.formattedTime,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Additional Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.teal.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'מידע נוסף',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // זמן עד לפעילות או זמן שעבר
                      _buildTimeInfo(),

                      const SizedBox(height: 16),

                      // סטטוס הביצוע
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: activity.isDone
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: activity.isDone
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              activity.isDone
                                  ? Icons.check_circle_outline
                                  : Icons.radio_button_unchecked,
                              color: activity.isDone
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              activity.isDone ? 'הפעילות הושלמה' : 'הפעילות טרם הושלמה',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: activity.isDone
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isTitle = false,
    bool isEmpty = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTitle ? 16 : 14,
              fontWeight: isTitle ? FontWeight.w600 : FontWeight.normal,
              color: isEmpty ? Colors.grey.shade500 : Colors.black87,
              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    final activityDateTime = DateTime(
      activity.date.year,
      activity.date.month,
      activity.date.day,
      activity.time.hour,
      activity.time.minute,
    );
    final now = DateTime.now();
    final difference = activityDateTime.difference(now);

    String timeText;
    Color timeColor;
    IconData timeIcon;

    if (activity.isDone) {
      timeText = 'הפעילות הושלמה';
      timeColor = Colors.green.shade700;
      timeIcon = Icons.check_circle;
    } else if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 0) {
        timeText = 'עברו ${absDifference.inDays} ימים מהתאריך המתוכנן';
      } else if (absDifference.inHours > 0) {
        timeText = 'עברו ${absDifference.inHours} שעות מהתאריך המתוכנן';
      } else {
        timeText = 'עברו ${absDifference.inMinutes} דקות מהתאריך המתוכנן';
      }
      timeColor = Colors.red.shade700;
      timeIcon = Icons.schedule;
    } else {
      if (difference.inDays > 0) {
        timeText = 'נותרו ${difference.inDays} ימים עד לפעילות';
      } else if (difference.inHours > 0) {
        timeText = 'נותרו ${difference.inHours} שעות עד לפעילות';
      } else {
        timeText = 'נותרו ${difference.inMinutes} דקות עד לפעילות';
      }
      timeColor = Colors.blue.shade700;
      timeIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: timeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: timeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(timeIcon, color: timeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              timeText,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: timeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}