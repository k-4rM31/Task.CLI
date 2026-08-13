import 'dart:io';

import 'package:task_cli/data/repositories/in_memory_task_repository.dart';
import 'package:task_cli/data/repositories/json_file_task_repository.dart';
import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/usecases/add_task.dart';
import 'package:task_cli/domaine/usecases/delete_task.dart';
import 'package:task_cli/domaine/usecases/list_tasks.dart';
import 'package:task_cli/domaine/usecases/toggle_task_done.dart';
import 'package:task_cli/presentation/commands/command.dart';
import 'package:task_cli/presentation/commands/command_parser.dart';
import 'package:test/test.dart';

void main() {
  final baseDate = DateTime(2026, 1, 1);

  Task task(
    String id,
    String title, {
    Priority priority = Priority.medium,
    DateTime? dueDate,
    int createdOffset = 0,
  }) {
    final createdAt = baseDate.add(Duration(minutes: createdOffset));
    return Task.build(
      id: id,
      title: title,
      priority: priority,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  test('add task stores title, priority and optional due date', () async {
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

  test('add task rejects an empty title with a custom exception', () async {
    final repository = InMemoryTaskRepository();
    final addTask = AddTask(repository);

    expect(() => addTask('   '), throwsA(isA<InvalidTaskException>()));
  });

  test('list tasks can sort by priority', () async {
    final repository = InMemoryTaskRepository();
    await repository.add(
      task('1', 'Low task', priority: Priority.low, createdOffset: 1),
    );
    await repository.add(
      task('2', 'High task', priority: Priority.high, createdOffset: 2),
    );
    await repository.add(
      task('3', 'Medium task', priority: Priority.medium, createdOffset: 3),
    );

    final tasks = await ListTasks(repository)(sort: TaskSort.priority);

    expect(tasks.map((item) => item.title), [
      'High task',
      'Medium task',
      'Low task',
    ]);
  });

  test('list tasks can sort by due date with missing dates last', () async {
    final repository = InMemoryTaskRepository();
    await repository.add(task('1', 'No date', createdOffset: 1));
    await repository.add(
      task('2', 'Later', dueDate: DateTime(2026, 9, 10), createdOffset: 2),
    );
    await repository.add(
      task('3', 'Sooner', dueDate: DateTime(2026, 8, 15), createdOffset: 3),
    );

    final tasks = await ListTasks(repository)(sort: TaskSort.dueDate);

    expect(tasks.map((item) => item.title), ['Sooner', 'Later', 'No date']);
  });

  test('toggle task done marks an existing task as completed', () async {
    final repository = InMemoryTaskRepository();
    await repository.add(task('1', 'Ship feature'));

    await ToggleTaskDone(repository)('1');

    final tasks = await repository.getAll();
    expect(tasks.single.done, isTrue);
  });

  test('delete task removes it and reports missing tasks', () async {
    final repository = InMemoryTaskRepository();
    await repository.add(task('1', 'Remove me'));

    await DeleteTask(repository)('1');

    expect(await repository.getAll(), isEmpty);
    expect(
      () => DeleteTask(repository)('missing'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('json repository persists tasks locally', () async {
    final directory = await Directory.systemTemp.createTemp('task_cli_test_');
    final path = '${directory.path}${Platform.pathSeparator}tasks.json';

    try {
      final repository = JsonFileTaskRepository(path);
      await repository.add(
        task(
          '1',
          'Persisted urgent task',
          priority: Priority.high,
          dueDate: DateTime(2026, 8, 30),
        ),
      );

      final reloadedRepository = JsonFileTaskRepository(path);
      final tasks = await reloadedRepository.getAll();

      expect(tasks, hasLength(1));
      expect(tasks.single, isA<UrgentTask>());
      expect(tasks.single.title, 'Persisted urgent task');
      expect(tasks.single.dueDate, DateTime(2026, 8, 30));
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('command parser supports due dates and list sorting', () {
    final add = CommandParser.parse('add "Write README" high 2026-08-20');
    final list = CommandParser.parse('list date');

    expect(add, isA<AddCommand>());
    final addCommand = add as AddCommand;
    expect(addCommand.title, 'Write README');
    expect(addCommand.priority, Priority.high);
    expect(addCommand.dueDate, DateTime(2026, 8, 20));

    expect(list, isA<ListCommand>());
    expect((list as ListCommand).sort, TaskSort.dueDate);
  });
}
