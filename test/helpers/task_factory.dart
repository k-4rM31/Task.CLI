import 'package:task_cli/domaine/entities/task.dart';

final baseTaskDate = DateTime(2026, 1, 1);

Task buildTestTask(
  String id,
  String title, {
  Priority priority = Priority.medium,
  DateTime? dueDate,
  bool done = false,
  int createdOffset = 0,
}) {
  final createdAt = baseTaskDate.add(Duration(minutes: createdOffset));
  return Task.restore(
    id: id,
    title: title,
    done: done,
    priority: priority,
    dueDate: dueDate,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
