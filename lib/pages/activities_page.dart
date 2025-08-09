import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('activities');
    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);
      setState(() {
        activities = decoded.map((item) => Activity.fromJson(item)).toList();
      });
    }
}

Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(
      activities.map((activity) => activity.toJson()).toList(),
    );
    await prefs.setString('activities', encoded);
}



  void _addActivity() {
    String newTitle = "";
    String newDescription = "";
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    bool titleError = false;
    bool dateError = false;
    bool timeError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("הוסף פעילות"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // שם פעילות
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: "שם הפעילות *",
                        errorText: titleError ? "שדה חובה" : null,
                      ),
                      onChanged: (value) {
                        newTitle = value;
                        setDialogState(() {
                          titleError = false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // תיאור (אופציונלי) עם מגבלת תווים
                    TextField(
                      
                      decoration: const InputDecoration(
                        labelText: "תיאור הפעילות (אופציונלי)",
                        counterText: "", // מסתיר את המונה אם לא רוצים להציג
                      ),
                      onChanged: (value) {
                        newDescription = value;
                      },
                    ),
                    const SizedBox(height: 16),

                    // בחירת תאריך
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "תאריך *",
                        errorText: dateError ? "חובה לבחור תאריך" : null,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: selectedDate == null
                            ? ""
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      ),
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                            dateError = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // בחירת שעה
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "שעה *",
                        errorText: timeError ? "חובה לבחור שעה" : null,
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                      controller: TextEditingController(
                        text: selectedTime == null
                            ? ""
                            : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                      ),
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setDialogState(() {
                            selectedTime = time;
                            timeError = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("ביטול"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setDialogState(() {
                      titleError = newTitle.trim().isEmpty;
                      dateError = selectedDate == null;
                      timeError = selectedTime == null;
                    });

                    if (!titleError && !dateError && !timeError) {
                      setState(() {
                        activities.add(
                          Activity(
                            title: newTitle.trim(),
                            description: newDescription.trim(),
                            date: selectedDate!,
                            time: selectedTime!,
                            isDone: false,
                          ),
                        );
                        _sortActivities();
                      });
                      _saveActivities();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("שמור"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleDone(int index, bool? value) {
    setState(() {
      activities[index].isDone = value ?? false;
      _sortActivities();
    });
    _saveActivities();
  }

  void _deleteActivity(int index) {
    setState(() {
      activities.removeAt(index);
    });
    _saveActivities();
  }

  void _sortActivities() {
    activities.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      int dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      TimeOfDay timeA = a.time;
      TimeOfDay timeB = b.time;
      int hourCompare = timeA.hour.compareTo(timeB.hour);
      if (hourCompare != 0) return hourCompare;
      return timeA.minute.compareTo(timeB.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: activities.isEmpty
          ? const Center(child: Text('אין פעילויות עדיין'))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowColor:
              WidgetStateProperty.all(Colors.teal.shade700),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
             
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              columnSpacing: 17,
              columns: const [
                DataColumn(label: FittedBox(child: Text("בוצע"))),
                DataColumn(label: FittedBox(child: Text("שם פעילות"))),
                DataColumn(label: FittedBox(child: Text("תיאור"))),
                DataColumn(label: FittedBox(child: Text("תאריך"))),
                DataColumn(label: FittedBox(child: Text("שעה"))),
                DataColumn(label: FittedBox(child: Text("מחיקה"))),
              ],
              rows: activities.asMap().entries.map((entry) {
                int index = entry.key;
                var activity = entry.value;

                return DataRow(
                  color: WidgetStateProperty.all(
                    activity.isDone
                        ? Colors.green.shade50
                        : activity.isPast
                        ? Colors.red.shade50
                        : (index % 2 == 0
                        ? Colors.grey.shade100
                        : Colors.white),
                  ),
                  cells: [
                    // בוצע
                    DataCell(
                      Checkbox(
                        value: activity.isDone,
                        onChanged: (value) => _toggleDone(index, value),
                      ),
                    ),
                    // שם פעילות
                    DataCell(
                      SizedBox(
                        
                        child: Row(
                          children: [
                            if (activity.isPast && !activity.isDone) ...[
                              Tooltip(
                                message: "הפעילות כבר עברה",
                                child: const Icon(Icons.access_time, size: 16, color: Colors.red),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                activity.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // תיאור
                    DataCell(
                      SizedBox(
                        
                        child: Text(
                          activity.description ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ),
                    ),
                    // תאריך
                    DataCell(Text(activity.formattedDate)),
                    // שעה
                    DataCell(Text(activity.formattedTime)),
                    // מחיקה
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteActivity(index),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
