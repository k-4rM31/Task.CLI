import 'package:task_cli/config/shortcut_config.dart';
import 'package:task_cli/presentation/utils/text_style.dart';

class ShortcutsWidget {
  static final List<(String, List<String>)> items = ShortcutConfig.shortcutLinesList;

  static List<String> buildLines(int width, {double sideMarginRatio = 0.3}) {
    final sideMargin = (width * sideMarginRatio).round();
    final containerWidth = width - (sideMargin * 2);

    final lines = <String>[];
    for (int i = 0; i < items.length; i++) {
      final (label, keys) = items[i];
      final row = shortcutInstructionJustified(label, keys, containerWidth);
      lines.add("${' ' * sideMargin} $row ${' ' * sideMargin}");
      if (i < items.length - 1) lines.add('');
    }
    return lines;
  }
}