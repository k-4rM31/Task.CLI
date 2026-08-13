import 'package:task_cli/data/repositories/in_memory_task_repository.dart';
import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/usecases/add_task.dart';
import 'package:test/test.dart';

void main() {
  group('AddTask', () {
    test('stores title, priority and optional due date', () async {
      final repository = InMemoryTaskRepository();
      final addTask = AddTask(repository);
      final dueDate = DateTime(2026, 8, 20);

      final created = await addTask(
        'Prepare demo',
        priority: Priority.high,
        dueDate: dueDate,
      );
      final tasks = await repository.getAll();

      expect(tasks, hasLength(1));
      expect(created, isA<UrgentTask>());
      expect(tasks.single.title, 'Prepare demo');
      expect(tasks.single.priority, Priority.high);
      expect(tasks.single.dueDate, dueDate);
    });

    test('rejects an empty title with a custom exception', () async {
      final repository = InMemoryTaskRepository();
      final addTask = AddTask(repository);

      expect(() => addTask('   '), throwsA(isA<InvalidTaskException>()));
    });
  });
}
