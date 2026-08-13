import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/usecases/list_tasks.dart';
import 'package:task_cli/presentation/commands/command.dart';
import 'package:task_cli/presentation/commands/command_parser.dart';
import 'package:test/test.dart';

void main() {
  group('CommandParser', () {
    test('parses add commands with priority and due date', () {
      final command = CommandParser.parse('add "Write README" high 2026-08-20');

      expect(command, isA<AddCommand>());
      final addCommand = command as AddCommand;
      expect(addCommand.title, 'Write README');
      expect(addCommand.priority, Priority.high);
      expect(addCommand.dueDate, DateTime(2026, 8, 20));
    });

    test('parses list commands with date sorting', () {
      final command = CommandParser.parse('list date');

      expect(command, isA<ListCommand>());
      expect((command as ListCommand).sort, TaskSort.dueDate);
    });

    test('returns InvalidCommand for unknown sort options', () {
      final command = CommandParser.parse('list title');

      expect(command, isA<InvalidCommand>());
    });
  });
}
