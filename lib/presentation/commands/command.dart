import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/usecases/list_tasks.dart';

sealed class Command {
  const Command();
}

class AddCommand extends Command {
  final String title;
  final Priority priority;
  final DateTime? dueDate;
  const AddCommand(this.title, this.priority, {this.dueDate});
}

class ListCommand extends Command {
  final TaskSort sort;
  const ListCommand({this.sort = TaskSort.none});
}

class DoneCommand extends Command {
  final int index;
  const DoneCommand(this.index);
}

class DeleteCommand extends Command {
  final int index;
  const DeleteCommand(this.index);
}

class UpdateCommand extends Command {
  final int index;
  final String newTitle;
  final Priority? newPriority;
  final DateTime? newDueDate;
  const UpdateCommand(
    this.index,
    this.newTitle,
    this.newPriority, {
    this.newDueDate,
  });
}

class PriorityCommand extends Command {
  final int index;
  final Priority priority;
  const PriorityCommand(this.index, this.priority);
}

class HelpCommand extends Command {
  const HelpCommand();
}

class QuitCommand extends Command {
  const QuitCommand();
}

class InvalidCommand extends Command {
  final String reason;
  const InvalidCommand(this.reason);
}
