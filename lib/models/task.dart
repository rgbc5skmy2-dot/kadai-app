import 'package:flutter/material.dart';

// 科目ごとに使う色のリスト
const List<Color> subjectColors = [
  Color(0xFF3D5AFE), // 青
  Color(0xFFE53935), // 赤
  Color(0xFF43A047), // 緑
  Color(0xFFFF9800), // オレンジ
  Color(0xFF8E24AA), // 紫
  Color(0xFF00ACC1), // シアン
  Color(0xFFD81B60), // ピンク
  Color(0xFF6D4C41), // ブラウン
];

class Task {
  String id;
  String subject;
  String title;
  DateTime dueDate;
  String dueTime;
  bool isDone;

  Task({
    required this.id,
    required this.subject,
    required this.title,
    required this.dueDate,
    this.dueTime = '23:59',
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime,
      'isDone': isDone,
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
    );
  }
}

// 科目名からカラーを取得するヘルパー関数
// 同じ科目名には常に同じ色が返る
Color getSubjectColor(String subject, List<String> subjects) {
  if (subject.isEmpty) return const Color(0xFF3D5AFE);
  final index = subjects.indexOf(subject);
  if (index == -1) return const Color(0xFF3D5AFE);
  return subjectColors[index % subjectColors.length];
}