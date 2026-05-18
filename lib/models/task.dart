import 'package:flutter/material.dart';

const List<Color> subjectColors = [
  Color(0xFF3D5AFE),
  Color(0xFFE53935),
  Color(0xFF43A047),
  Color(0xFFFF9800),
  Color(0xFF8E24AA),
  Color(0xFF00ACC1),
  Color(0xFFD81B60),
  Color(0xFF6D4C41),
];

class Task {
  String id;
  String subject;
  String title;
  DateTime dueDate;
  String dueTime;
  bool isDone;
  String memo; // メモフィールドを追加

  Task({
    required this.id,
    required this.subject,
    required this.title,
    required this.dueDate,
    this.dueTime = '23:59',
    this.isDone = false,
    this.memo = '', // デフォルトは空
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime,
      'isDone': isDone,
      'memo': memo,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      subject: map['subject'],
      title: map['title'],
      dueDate: DateTime.parse(map['dueDate']),
      dueTime: map['dueTime'] ?? '23:59',
      isDone: map['isDone'],
      memo: map['memo'] ?? '',
    );
  }
}

Color getSubjectColor(String subject, List<String> subjects) {
  if (subject.isEmpty) return const Color(0xFF3D5AFE);
  final index = subjects.indexOf(subject);
  if (index == -1) return const Color(0xFF3D5AFE);
  return subjectColors[index % subjectColors.length];
}