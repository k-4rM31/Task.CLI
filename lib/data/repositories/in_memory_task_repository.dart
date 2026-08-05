import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAll() async {
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> add(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> update(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}