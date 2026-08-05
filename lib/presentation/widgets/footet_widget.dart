import 'package:dart_tui/dart_tui.dart';

class FooterWidget {
  static String build(
    int width,
    String separatorLine,
    TextInputModel textInput,
    CursorModel cursor,
  ) {
    final inputView = textInput.view().content;
    final cursorView = cursor.view().content;
    final row = "$inputView$cursorView".padRight(width).substring(0, width);
    return "$separatorLine\n$row";
  }
}