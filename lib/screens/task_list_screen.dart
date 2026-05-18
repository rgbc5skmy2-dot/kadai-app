import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'task_form_screen.dart';
import '../widgets/task_card.dart';
import 'calendar_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  List<String> get _subjects {
    final seen = <String>{};
    return _tasks
        .map((t) => t.subject)
        .where((s) => seen.add(s))
        .toList();
  }

  // 締切順に並び替え
  List<Task> get _sortedTasks {
    final sorted = List<Task>.from(_tasks);
    sorted.sort((a, b) {
      final aIsToday = _isToday(a.dueDate);
      final bIsToday = _isToday(b.dueDate);
      if (aIsToday && !bIsToday) return -1;
      if (!aIsToday && bIsToday) return 1;
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3D5AFE),
          labelColor: const Color(0xFF3D5AFE),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'すべて'),
            Tab(text: '科目別'),
            Tab(text: 'カレンダー'),
          ],
        ),
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
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(),
                _buildSubjectTab(),
                CalendarScreen(
                  tasks: _tasks,
                  subjects: _subjects,
                  onToggleDone: _toggleDone,
                  onDelete: _deleteTask,
                  onEdit: (task) => _openForm(task: task),
              ),
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

  // すべてタブ：締切順に表示
  Widget _buildAllTab() {
    final incomplete = _sortedTasks.where((t) => !t.isDone).toList();
    final completed = _sortedTasks.where((t) => t.isDone).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        if (incomplete.isNotEmpty) ...[
          _SectionHeader(label: '未完了', count: incomplete.length),
          ...incomplete.map((task) => TaskCard(
                task: task,
                subjects: _subjects,
                onEdit: () => _openForm(task: task),
                onDelete: () => _deleteTask(task.id),
                onToggleDone: () => _toggleDone(task.id),
              )),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(label: '完了済み', count: completed.length),
          ...completed.map((task) => TaskCard(
                task: task,
                subjects: _subjects,
                onEdit: () => _openForm(task: task),
                onDelete: () => _deleteTask(task.id),
                onToggleDone: () => _toggleDone(task.id),
              )),
        ],
      ],
    );
  }

  // 科目別タブ：科目ごとにまとめて表示
  Widget _buildSubjectTab() {
    if (_subjects.isEmpty) {
      return Center(
        child: Text(
          '課題がありません',
          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: _subjects.map((subject) {
        final subjectTasks = _sortedTasks
            .where((t) => t.subject == subject)
            .toList();
        final incomplete = subjectTasks.where((t) => !t.isDone).toList();
        final completed = subjectTasks.where((t) => t.isDone).toList();
        final color = getSubjectColor(subject, _subjects);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 科目ヘッダー
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${incomplete.length}件未完了',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // 科目の課題一覧
            ...incomplete.map((task) => TaskCard(
                  task: task,
                  subjects: _subjects,
                  onEdit: () => _openForm(task: task),
                  onDelete: () => _deleteTask(task.id),
                  onToggleDone: () => _toggleDone(task.id),
                )),
            ...completed.map((task) => TaskCard(
                  task: task,
                  subjects: _subjects,
                  onEdit: () => _openForm(task: task),
                  onDelete: () => _deleteTask(task.id),
                  onToggleDone: () => _toggleDone(task.id),
                )),
            const Divider(height: 24),
          ],
        );
      }).toList(),
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