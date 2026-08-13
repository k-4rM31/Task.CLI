import 'dart:math';

import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

class AddTask {
  final TaskRepository repository;
  const AddTask(this.repository);

  Future<Task> call(
    String title, {
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw const InvalidTaskException('Le titre ne peut pas etre vide.');
    }

    final task = Task.create(
      id: _generateId(),
      title: normalizedTitle,
      priority: priority,
      dueDate: dueDate,
    );
    await repository.add(task);
    return task;
  }

  String _generateId() {
    final random = Random();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final salt = random.nextInt(999999);
    return '$timestamp-$salt';
  }
}
