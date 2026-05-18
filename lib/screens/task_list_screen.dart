import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'task_form_screen.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> taskList = jsonDecode(tasksJson);
      setState(() {
        _tasks = taskList.map((t) => Task.fromMap(t)).toList();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson =
        jsonEncode(_tasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  // 登録済みの科目リストを取得（重複なし・登録順）
  List<String> get _subjects {
    final seen = <String>{};
    return _tasks
        .map((t) => t.subject)
        .where((s) => seen.add(s))
        .toList();
  }

  List<Task> get _sortedTasks {
    final sorted = List<Task>.from(_tasks);
    sorted.sort((a, b) {
      final aIsToday = _isToday(a.dueDate);
      final bIsToday = _isToday(b.dueDate);
      if (aIsToday && !bIsToday) return -1;
      if (!aIsToday && bIsToday) return 1;
      // 日付が同じ場合は時間で並び替え
      if (a.dueDate == b.dueDate) {
        return a.dueTime.compareTo(b.dueTime);
      }
      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _openForm({Task? task}) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task, subjects: _subjects),
      ),
    );
    if (result != null) {
      setState(() {
        if (task == null) {
          _tasks.add(result);
        } else {
          final index = _tasks.indexWhere((t) => t.id == result.id);
          if (index != -1) _tasks[index] = result;
        }
      });
      await _saveTasks();
    }
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
    _saveTasks();
  }

  void _toggleDone(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index].isDone = !_tasks[index].isDone;
      }
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final incompleteTasks = _sortedTasks.where((t) => !t.isDone).toList();
    final completedTasks = _sortedTasks.where((t) => t.isDone).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text(
          '課題管理',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x1A3D5AFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '未完了 ${incompleteTasks.length}件',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D5AFE),
              ),
            ),
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    '課題がありません',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右下の＋ボタンで追加しましょう！',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              children: [
                if (incompleteTasks.isNotEmpty) ...[
                  _SectionHeader(
                      label: '未完了', count: incompleteTasks.length),
                  ...incompleteTasks.map((task) => TaskCard(
                        task: task,
                        subjects: _subjects,
                        onEdit: () => _openForm(task: task),
                        onDelete: () => _deleteTask(task.id),
                        onToggleDone: () => _toggleDone(task.id),
                      )),
                ],
                if (completedTasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionHeader(
                      label: '完了済み', count: completedTasks.length),
                  ...completedTasks.map((task) => TaskCard(
                        task: task,
                        subjects: _subjects,
                        onEdit: () => _openForm(task: task),
                        onDelete: () => _deleteTask(task.id),
                        onToggleDone: () => _toggleDone(task.id),
                      )),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF3D5AFE),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '課題を追加',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;

  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9E9E9E),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x269E9E9E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}