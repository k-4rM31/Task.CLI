import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/presentation/widgets/priority_style.dart';

class TaskListScreen {
  static List<String> render(int width, int bodyHeight, List<Task> tasks, List<String> topLines) {
    final lines = <String>[...topLines];

    if (tasks.isEmpty) {
      lines.add('Aucune tâche pour l\'instant. Tape: add "titre" [priorité]'.padRight(width));
    } else {
      for (int i = 0; i < tasks.length; i++) {
        final t = tasks[i];
        final checkbox = t.done ? '[x]' : '[ ]';
        final row = "  ${i + 1}. $checkbox ${t.title}  ${t.priority.render()}";
        lines.add(row.padRight(width));
      }
    }

    return List.generate(bodyHeight, (i) => i < lines.length ? lines[i] : "".padRight(width));
  }
}