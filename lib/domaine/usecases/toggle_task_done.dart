import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

class ToggleTaskDone {
  final TaskRepository repository;
  const ToggleTaskDone(this.repository);

  Future<void> call(String taskId) async {
    final tasks = await repository.getAll();
    final task = tasks.where((item) => item.id == taskId).firstOrNull;

    if (task == null) throw TaskNotFoundException(taskId);

    await repository.update(task.copyWith(done: !task.done));
  }
}
