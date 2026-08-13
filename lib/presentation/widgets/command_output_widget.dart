import 'package:dart_tui/dart_tui.dart';

class CommandOutputWidget {
  static const _successStyle = Style(foregroundRgb: RgbColor(166, 227, 161));
  static const _errorStyle = Style(foregroundRgb: RgbColor(243, 139, 168));
  static const _promptStyle = Style(isBold: true);

  static List<String> build(
    int width, {
    String? feedbackMessage,
    bool feedbackSuccess = true,
    String? wizardPrompt,
  }) {
    if (wizardPrompt != null) {
      return [
        _promptStyle.render(wizardPrompt).padRight(width),
        ''.padRight(width),
      ];
    }
    if (feedbackMessage != null) {
      final style = feedbackSuccess ? _successStyle : _errorStyle;
      return [
        style.render(feedbackMessage).padRight(width),
        ''.padRight(width),
      ];
    }
    return [''.padRight(width), ''.padRight(width)];
  }
}
