import 'package:task_cli/domaine/repositories/task_repository.dart';

class DeleteTask {
  final TaskRepository repository;
  const DeleteTask(this.repository);

  Future<void> call(String taskId) => repository.delete(taskId);
}
