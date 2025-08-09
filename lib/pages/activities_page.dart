import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import 'activity_details_page.dart';

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

                    TextField(
                      decoration: const InputDecoration(
                        labelText: "תיאור הפעילות (אופציונלי)",
                        counterText: "", 
                      ),
                      onChanged: (value) {
                        newDescription = value;
                      },
                    ),
                    const SizedBox(height: 16),

                
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("מחיקת פעילות"),
        content: const Text("האם אתה בטוח שברצונך למחוק את הפעילות?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ביטול"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                activities.removeAt(index);
              });
              _saveActivities();
              Navigator.pop(context);
            },
            child: const Text("מחק", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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

  void _viewActivityDetails(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailsPage(activity: activity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea( 
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0), 
          child: activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'אין פעילויות עדיין',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'לחץ על + להוספת פעילות חדשה',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      // App Title
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'הפעילויות שלי',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8), 
                      
                    
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade700,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 3,
                              child: Text(
                                "שם פעילות",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "תיאור",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "תאריך",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "שעה",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "פעולות",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                  
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: activities.length,
                            itemBuilder: (context, index) {
                              var activity = activities[index];
                              return InkWell(
                                onTap: () => _viewActivityDetails(activity),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: activity.isDone
                                        ? Colors.green.shade50
                                        : activity.isPast
                                            ? Colors.red.shade50
                                            : (index % 2 == 0
                                                ? Colors.grey.shade50
                                                : Colors.white),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // שם פעילות
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            if (activity.isPast && !activity.isDone) ...[
                                              Tooltip(
                                                message: "הפעילות כבר עברה",
                                                child: Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: Colors.red.shade600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Expanded(
                                              child: Text(
                                                activity.title,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  decoration: activity.isDone
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                  color: activity.isDone
                                                      ? Colors.grey
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // תיאור
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          activity.description?.isEmpty ?? true
                                              ? "-"
                                              : activity.description!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      // תאריך
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          activity.formattedDate,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      // שעה
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          activity.formattedTime,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                     
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                value: activity.isDone,
                                                onChanged: (value) => _toggleDone(index, value),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red.shade600,
                                                  size: 18,
                                                ),
                                                onPressed: () => _deleteActivity(index),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}