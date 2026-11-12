import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Renders a word prefixed with "ez", where the "ez" appears in brand red
/// and the remainder appears in the standard text style.
class EzWord extends StatelessWidget {
  const EzWord({super.key, required this.rest, this.style, this.ezColor});

  /// The text following the "ez" prefix (e.g., 'Stays', 'Money', 'Shop', 'Chat').
  final String rest;

  /// The base text style.
  final TextStyle? style;

  /// Custom override color for the "ez" prefix (defaults to brand red).
  final Color? ezColor;

  @override
  Widget build(BuildContext context) {
    final brandRed = ezColor ?? context.colors.brandPrimary;
    final baseStyle = style ?? context.text.bodyMedium;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'ez',
            style: baseStyle?.copyWith(color: brandRed),
          ),
          TextSpan(text: rest, style: baseStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Helper that inspects any sentence text and colors all instances of
/// `ez` that are immediately followed by an uppercase letter.
class EzText extends StatelessWidget {
  const EzText({
    super.key,
    required this.text,
    this.style,
    this.ezColor,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Color? ezColor;
  final TextAlign? textAlign;

  static final _mark = RegExp(r'ez(?=[A-Z])');

  @override
  Widget build(BuildContext context) {
    final brandRed = ezColor ?? context.colors.brandPrimary;
    final baseStyle = style ?? context.text.bodyMedium;
    final spans = <TextSpan>[];
    var at = 0;

    for (final m in _mark.allMatches(text)) {
      if (m.start > at) {
        spans.add(TextSpan(text: text.substring(at, m.start)));
      }
      spans.add(
        TextSpan(
          text: 'ez',
          style: baseStyle?.copyWith(color: brandRed),
        ),
      );
      at = m.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
