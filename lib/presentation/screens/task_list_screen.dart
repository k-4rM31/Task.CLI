import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/presentation/widgets/priority_style.dart';

class TaskListScreen {
  static List<String> render(
    int width,
    int bodyHeight,
    List<Task> tasks,
    List<String> topLines,
  ) {
    final lines = <String>[...topLines];

    if (tasks.isEmpty) {
      lines.add(
        'Aucune tache pour l\'instant. Tape: add "titre" [priorite] [YYYY-MM-DD]'
            .padRight(width),
      );
    } else {
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        final checkbox = task.done ? '[x]' : '[ ]';
        final dueDate = _formatDueDate(task.dueDate);
        final row =
            '  ${i + 1}. $checkbox ${task.title}  ${task.priority.render()}$dueDate';
        lines.add(row.padRight(width));
      }
    }

    return List.generate(
      bodyHeight,
      (index) => index < lines.length ? lines[index] : ''.padRight(width),
    );
  }

  static String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return '';
    final month = dueDate.month.toString().padLeft(2, '0');
    final day = dueDate.day.toString().padLeft(2, '0');
    return '  due: ${dueDate.year}-$month-$day';
  }
}
