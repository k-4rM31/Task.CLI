import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

class UpdateTaskTitle {
  final TaskRepository repository;
  const UpdateTaskTitle(this.repository);

  Future<void> call(
    String taskId,
    String newTitle, {
    Priority? priority,
    DateTime? dueDate,
  }) async {
    final normalizedTitle = newTitle.trim();
    if (normalizedTitle.isEmpty) {
      throw const InvalidTaskException('Le titre ne peut pas etre vide.');
    }

    final tasks = await repository.getAll();
    final task = tasks.where((item) => item.id == taskId).firstOrNull;

    if (task == null) throw TaskNotFoundException(taskId);

    await repository.update(
      task.copyWith(
        title: normalizedTitle,
        priority: priority,
        dueDate: dueDate,
      ),
    );
  }
}
