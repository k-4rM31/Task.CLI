import 'package:dart_tui/dart_tui.dart';
import 'package:task_cli/config/app_info.dart';

class HeaderWidget {
  static const _boldStyle = Style(isBold: true);

  static (String text, int lineCount) build(int width) {
    final buffer = StringBuffer();
    final separator = "".padRight(width, "─");
 
    buffer.writeln(separator);
    buffer.writeln("${AppInfo.name} ${_boldStyle.render(' v${AppInfo.version} ')}");
    buffer.writeln(_boldStyle.render(" ${AppInfo.description} "));
    buffer.writeln("${_boldStyle.render(" Dernière mise à jour:")} ${AppInfo.updateDate}");
    buffer.writeln("${_boldStyle.render(" Développé par:")} ${AppInfo.author}");
    buffer.writeln("${_boldStyle.render(" copyright:")} ${AppInfo.copyright}");
    buffer.writeln(separator);

    final text = buffer.toString();
    return (text, text.split('\n').length - 1);
  }
}