import 'package:dart_tui/dart_tui.dart';
import 'package:task_cli/domaine/entities/task.dart';

extension PriorityStyle on Priority {
  Style get style => switch (this) {
        Priority.low => const Style(foregroundRgb: RgbColor(166, 227, 161)),   // vert
        Priority.medium => const Style(foregroundRgb: RgbColor(249, 226, 175)), // jaune
        Priority.high => const Style(foregroundRgb: RgbColor(243, 139, 168)),   // rouge
      };

  /// Rend le libellé de la priorité avec sa couleur.
  String render() => style.render(label);
}