import 'package:dart_tui/dart_tui.dart';
import 'package:task_cli/domaine/entities/task.dart';

class TasksLoadedMsg extends Msg {
  final List<Task> tasks;
  TasksLoadedMsg(this.tasks);
}

/// Commande qui modifie l'état : porte le feedback ET la liste rafraîchie.
class CommandExecutedMsg extends Msg {
  final bool success;
  final String message;
  final List<Task> tasks;
  CommandExecutedMsg({
    required this.success,
    required this.message,
    required this.tasks,
  });
}

/// Commande qui ne modifie rien (erreur, help) : juste un message.
class CommandFeedbackMsg extends Msg {
  final bool success;
  final String message;
  CommandFeedbackMsg({required this.success, required this.message});
}
