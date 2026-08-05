import 'package:dart_tui/dart_tui.dart';

/// Style "badge" pour une touche (fond clair, texte inversé).
/// isReverse inverse fg/bg : en ne précisant qu'un foregroundRgb clair,
/// le résultat visuel est un badge clair avec texte sombre, sans avoir
/// besoin d'un backgroundRgb explicite.
const _keyBadgeStyle = Style(
  foregroundRgb: RgbColor(220, 220, 220),
  isReverse: true,
);

const _separatorStyle = Style(isDim: true);
const _labelStyle = Style(isDim: true);

String keyBadge(String key) => _keyBadgeStyle.render(' $key ');

String shortcutKey(List<String> keys) {
  final sep = _separatorStyle.render(' + ');
  return keys.map(keyBadge).join(sep);
}

String shortcutInstructionJustified(
  String label,
  List<String> keys,
  int shortcutContainerWidth,
) {
  final shortcut = shortcutKey(keys);
  final shortcutWidth = getWidth(shortcut);
  final labelStyled = _labelStyle.render(label);

  final gap = shortcutContainerWidth - label.length - shortcutWidth;
  final safeGap = gap > 1 ? gap : 1;

  return labelStyled + (' ' * safeGap) + shortcut;
}