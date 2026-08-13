import 'package:task_cli/data/repositories/in_memory_task_repository.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/usecases/delete_task.dart';
import 'package:task_cli/domaine/usecases/toggle_task_done.dart';
import 'package:test/test.dart';

import '../../helpers/task_factory.dart';

void main() {
  group('Task state use cases', () {
    test('ToggleTaskDone marks an existing task as completed', () async {
      final repository = InMemoryTaskRepository();
      await repository.add(buildTestTask('1', 'Ship feature'));

      await ToggleTaskDone(repository)('1');

      final tasks = await repository.getAll();
      expect(tasks.single.done, isTrue);
    });

    test('DeleteTask removes a task', () async {
      final repository = InMemoryTaskRepository();
      await repository.add(buildTestTask('1', 'Remove me'));

      await DeleteTask(repository)('1');

      expect(await repository.getAll(), isEmpty);
    });

    test('DeleteTask reports missing tasks with a custom exception', () async {
      final repository = InMemoryTaskRepository();

      expect(
        () => DeleteTask(repository)('missing'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });
}
