import 'dart:io';

import 'package:task_cli/data/repositories/json_file_task_repository.dart';
import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:test/test.dart';

import '../../helpers/task_factory.dart';

void main() {
  group('JsonFileTaskRepository', () {
    test('persists tasks locally', () async {
      final directory = await Directory.systemTemp.createTemp('task_cli_test_');
      final path = '${directory.path}${Platform.pathSeparator}tasks.json';

      try {
        final repository = JsonFileTaskRepository(path);
        await repository.add(
          buildTestTask(
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

    test('throws StorageException for invalid JSON content', () async {
      final directory = await Directory.systemTemp.createTemp(
        'task_cli_bad_json_',
      );
      final file = File('${directory.path}${Platform.pathSeparator}tasks.json');

      try {
        await file.writeAsString('{not-json');
        final repository = JsonFileTaskRepository(file.path);

        expect(repository.getAll, throwsA(isA<StorageException>()));
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });
}
