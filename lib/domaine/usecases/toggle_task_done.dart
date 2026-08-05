import 'package:task_cli/domaine/repositories/task_repository.dart';

class ToggleTaskDone {
  final TaskRepository repository;
  const ToggleTaskDone(this.repository);

  Future<void> call(String taskId) async {
    final tasks = await repository.getAll();
    final task = tasks.where((t) => t.id == taskId).firstOrNull;

    if (task == null) {
      throw ArgumentError('Aucune tâche trouvée avec id: $taskId');
    }

    await repository.update(task.copyWith(done: !task.done));
  }
}