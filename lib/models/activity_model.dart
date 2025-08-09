import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Activity {
  String title;
  String? description;
  DateTime date;
  TimeOfDay time;
  bool isDone;

  Activity({
      required this.title,
      this.description,
      required this.date,
      required this.time,
      this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
    'title' : title,
    'description' : description,
    'date' : date.toIso8601String(),
    'time': {
      'hour' : time.hour,
      'minute': time.minute,
    },
    'isDone' : isDone,
  };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
        title: json['title'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        time: TimeOfDay(
            hour: json['time']['hour'],
            minute: json['time']['minute'],
        ),
      isDone: json['isDone'] ?? false,
    );
  }

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);

  String get formattedTime =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  bool get isPast {
    final activityDateTime =
    DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateTime.now().isAfter(activityDateTime);
  }

}