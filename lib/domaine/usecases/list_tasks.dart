import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

class ListTasks {
  final TaskRepository repository;
  const ListTasks(this.repository);

  Future<List<Task>> call() => repository.getAll();
}