import 'package:task_cli/domaine/repositories/task_repository.dart';

class UpdateTaskTitle {
  final TaskRepository repository;
  const UpdateTaskTitle(this.repository);

  Future<void> call(String taskId, String newTitle) async {
    final tasks = await repository.getAll();
    final task = tasks.where((t) => t.id == taskId).firstOrNull;

    if (task == null) {
      throw ArgumentError('Aucune tâche trouvée avec id: $taskId');
    }

    await repository.update(task.copyWith(title: newTitle));
  }
}