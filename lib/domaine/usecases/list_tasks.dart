import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

enum TaskSort { none, priority, dueDate }

class ListTasks {
  final TaskRepository repository;
  const ListTasks(this.repository);

  Future<List<Task>> call({TaskSort sort = TaskSort.none}) async {
    final tasks = [...await repository.getAll()];
    switch (sort) {
      case TaskSort.none:
        return tasks;
      case TaskSort.priority:
        tasks.sort(_compareByPriority);
        return tasks;
      case TaskSort.dueDate:
        tasks.sort(_compareByDueDate);
        return tasks;
    }
  }

  int _compareByPriority(Task left, Task right) {
    final priorityComparison = left.priority.sortRank.compareTo(
      right.priority.sortRank,
    );
    if (priorityComparison != 0) return priorityComparison;
    return left.createdAt.compareTo(right.createdAt);
  }

  int _compareByDueDate(Task left, Task right) {
    final leftDueDate = left.dueDate;
    final rightDueDate = right.dueDate;

    if (leftDueDate == null && rightDueDate == null) {
      return left.createdAt.compareTo(right.createdAt);
    }
    if (leftDueDate == null) return 1;
    if (rightDueDate == null) return -1;

    final dueDateComparison = leftDueDate.compareTo(rightDueDate);
    if (dueDateComparison != 0) return dueDateComparison;
    return left.createdAt.compareTo(right.createdAt);
  }
}
