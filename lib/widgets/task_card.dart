import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final List<String> subjects;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;

  const TaskCard({
    super.key,
    required this.task,
    required this.subjects,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  bool get _isToday {
    final now = DateTime.now();
    return task.dueDate.year == now.year &&
        task.dueDate.month == now.month &&
        task.dueDate.day == now.day;
  }

  bool get _isOverdue {
    final now = DateTime.now();
    return task.dueDate.isBefore(DateTime(now.year, now.month, now.day)) &&
        !task.isDone;
  }

  // 締切状態による色（完了・締切切れ・今日・通常）
  Color get _statusColor {
    if (task.isDone) return Colors.grey;
    if (_isOverdue) return const Color(0xFFE53935);
    if (_isToday) return const Color(0xFFFF9800);
    return const Color(0xFF3D5AFE);
  }

  // 科目名による色
  Color get _subjectColor {
    return getSubjectColor(task.subject, subjects);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // 左側のラインは科目カラー
        border: Border(
          left: BorderSide(color: _subjectColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 完了チェックボックス
            GestureDetector(
              onTap: onToggleDone,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? _subjectColor : Colors.transparent,
                  border: Border.all(
                    color: task.isDone ? _subjectColor : _statusColor,
                    width: 2,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 科目名バッジ（科目カラーで表示）
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color((_subjectColor.value & 0x00FFFFFF) | 0x1A000000),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.subject,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _subjectColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 課題名
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: task.isDone
                          ? Colors.grey
                          : const Color(0xFF1A1A2E),
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 締切日時と状態バッジ
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 13, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('M月d日').format(task.dueDate)} ${task.dueTime}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isToday && !task.isDone)
                        _Badge(
                            label: '今日締切',
                            color: const Color(0xFFFF9800)),
                      if (_isOverdue)
                        _Badge(
                            label: '締切切れ',
                            color: const Color(0xFFE53935)),
                      if (task.isDone)
                        _Badge(label: '完了', color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            // 編集・削除ボタン
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.grey[400],
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.grey[400],
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Color((color.value & 0x00FFFFFF) | 0x26000000),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}