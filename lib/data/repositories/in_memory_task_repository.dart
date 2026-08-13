import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAll() async {
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> add(Task task) async {
    if (_tasks.any((item) => item.id == task.id)) {
      throw InvalidTaskException('Une tache existe deja avec id: ${task.id}');
    }
    _tasks.add(task);
  }

  @override
  Future<void> update(Task task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) throw TaskNotFoundException(task.id);

    _tasks[index] = task;
  }

  @override
  Future<void> delete(String id) async {
    final initialLength = _tasks.length;
    _tasks.removeWhere((item) => item.id == id);
    if (_tasks.length == initialLength) throw TaskNotFoundException(id);
  }
}
