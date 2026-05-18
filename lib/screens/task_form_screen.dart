import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final List<String> subjects;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.subjects,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _subjectController = TextEditingController();
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = const TimeOfDay(hour: 23, minute: 59);

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _subjectController.text = widget.task!.subject;
      _titleController.text = widget.task!.title;
      _memoController.text = widget.task!.memo;
      _dueDate = widget.task!.dueDate;
      final parts = widget.task!.dueTime.split(':');
      _dueTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  String get _formattedTime {
    final h = _dueTime.hour.toString().padLeft(2, '0');
    final m = _dueTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _save() {
    if (_subjectController.text.isEmpty || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('科目名と課題名を入力してください')),
      );
      return;
    }

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _subjectController.text,
      title: _titleController.text,
      dueDate: _dueDate,
      dueTime: _formattedTime,
      isDone: widget.task?.isDone ?? false,
      memo: _memoController.text,
    );
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? '課題を追加' : '課題を編集'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 科目名入力（候補付き）
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return widget.subjects;
                }
                return widget.subjects.where((s) => s
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (value) {
                _subjectController.text = value;
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                if (widget.task != null && controller.text.isEmpty) {
                  controller.text = widget.task!.subject;
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: '科目名',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                    hintText: '科目名を入力または選択',
                  ),
                  onChanged: (value) {
                    _subjectController.text = value;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            // 課題名入力
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '課題名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
              ),
            ),
            const SizedBox(height: 16),
            // 締切日選択
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '締切日：${DateFormat('yyyy年M月d日').format(_dueDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('日付を選ぶ'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 締切時間選択
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '締切時間：$_formattedTime',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickTime,
                  child: const Text('時間を選ぶ'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // メモ入力
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'メモ（任意）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                hintText: '例：教科書p.30参照、グループワーク など',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            // 保存ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '保存する',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}