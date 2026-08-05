import 'dart:math';

import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';


class AddTask {
  final TaskRepository repository;
  const AddTask(this.repository);

  Future<Task> call(String title, {Priority priority = Priority.medium}) async {
    final task = Task.create(
      id: _generateId(),
      title: title,
      priority: priority,
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