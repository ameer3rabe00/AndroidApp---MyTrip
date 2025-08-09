import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Expense {
  int id;
  int categoryId;
  double amount;
  String description;
  DateTime date;

  Expense({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);

}