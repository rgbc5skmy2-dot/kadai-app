import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks;
  final List<String> subjects;
  final Function(String) onToggleDone;
  final Function(String) onDelete;
  final Function(Task) onEdit;

  const CalendarScreen({
    super.key,
    required this.tasks,
    required this.subjects,
    required this.onToggleDone,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Task> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      return task.dueDate.year == day.year &&
          task.dueDate.month == day.month &&
          task.dueDate.day == day.day;
    }).toList();
  }

  List<Task> get _selectedTasks {
    if (_selectedDay == null) return _getTasksForDay(DateTime.now());
    return _getTasksForDay(_selectedDay!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // カレンダー（コンパクト版）
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getTasksForDay,
              // コンパクトサイズに設定
              rowHeight: 36,
              daysOfWeekHeight: 24,
              calendarStyle: CalendarStyle(
                // セルのサイズを小さく
                cellMargin: const EdgeInsets.all(2),
                defaultTextStyle: const TextStyle(fontSize: 12),
                weekendTextStyle: const TextStyle(fontSize: 12),
                outsideTextStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF3D5AFE).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF3D5AFE),
                  fontWeight: FontWeight.w700,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF3D5AFE),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
                markerSize: 5,
                markersMaxCount: 3,
                markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                ),
                weekendStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                headerPadding: EdgeInsets.symmetric(vertical: 8),
                titleTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
                leftChevronIcon: Icon(Icons.chevron_left, size: 18),
                rightChevronIcon: Icon(Icons.chevron_right, size: 18),
              ),
              locale: 'ja_JP',
            ),
          ),

          // 選択した日の課題ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  _selectedDay == null
                      ? '今日の課題'
                      : '${DateFormat('M月d日').format(_selectedDay!)}の課題',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0x269E9E9E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_selectedTasks.length}件',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 課題リスト
          Expanded(
            child: _selectedTasks.isEmpty
                ? Center(
                    child: Text(
                      'この日の課題はありません',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[400]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = _selectedTasks[index];
                      final color =
                          getSubjectColor(task.subject, widget.subjects);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(color: color, width: 4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ListTile(
                          dense: true,
                          leading: GestureDetector(
                            onTap: () => widget.onToggleDone(task.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: task.isDone
                                    ? color
                                    : Colors.transparent,
                                border: Border.all(
                                  color: task.isDone
                                      ? color
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: task.isDone
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: task.isDone
                                  ? Colors.grey
                                  : const Color(0xFF1A1A2E),
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '${task.subject}  ${task.dueTime}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18),
                                color: Colors.grey[400],
                                onPressed: () => widget.onEdit(task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18),
                                color: Colors.grey[400],
                                onPressed: () =>
                                    widget.onDelete(task.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}