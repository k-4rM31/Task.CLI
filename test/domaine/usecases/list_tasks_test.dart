import 'package:task_cli/data/repositories/in_memory_task_repository.dart';
import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/usecases/list_tasks.dart';
import 'package:test/test.dart';

import '../../helpers/task_factory.dart';

void main() {
  group('ListTasks', () {
    test('sorts tasks by priority', () async {
      final repository = InMemoryTaskRepository();
      await repository.add(
        buildTestTask(
          '1',
          'Low task',
          priority: Priority.low,
          createdOffset: 1,
        ),
      );
      await repository.add(
        buildTestTask(
          '2',
          'High task',
          priority: Priority.high,
          createdOffset: 2,
        ),
      );
      await repository.add(
        buildTestTask(
          '3',
          'Medium task',
          priority: Priority.medium,
          createdOffset: 3,
        ),
      );

      final tasks = await ListTasks(repository)(sort: TaskSort.priority);

      expect(tasks.map((item) => item.title), [
        'High task',
        'Medium task',
        'Low task',
      ]);
    });

    test('sorts tasks by due date with missing dates last', () async {
      final repository = InMemoryTaskRepository();
      await repository.add(buildTestTask('1', 'No date', createdOffset: 1));
      await repository.add(
        buildTestTask(
          '2',
          'Later',
          dueDate: DateTime(2026, 9, 10),
          createdOffset: 2,
        ),
      );
      await repository.add(
        buildTestTask(
          '3',
          'Sooner',
          dueDate: DateTime(2026, 8, 15),
          createdOffset: 3,
        ),
      );

      final tasks = await ListTasks(repository)(sort: TaskSort.dueDate);

      expect(tasks.map((item) => item.title), ['Sooner', 'Later', 'No date']);
    });
  });
}
