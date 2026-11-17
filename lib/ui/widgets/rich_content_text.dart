import 'package:flutter/material.dart';

/// Renders the light Markdown used in the education content (from the PA
/// MHAD booklet) and quiz copy, so readers see real emphasis instead of raw
/// `**` markers:
///
/// - `**bold**` → bold (or [emphasisStyle] when given, e.g. the quiz's
///   primary-colored keywords), `*italic*` → italic;
/// - blank-line-separated paragraphs get paragraph spacing;
/// - lines starting with `•` or `1.` … get a hanging indent, so wrapped list
///   text lines up under the text instead of under the bullet.
///
/// This is the ONE place that interprets these markers; card previews use
/// [plainExcerpt], which strips them.
class RichContentText extends StatelessWidget {
  final String content;
  final TextStyle? style;

  /// Style merged onto `**…**` spans. Defaults to bold.
  final TextStyle? emphasisStyle;
  final TextAlign textAlign;

  const RichContentText(
    this.content, {
    this.style,
    this.emphasisStyle,
    this.textAlign = TextAlign.start,
    super.key,
  });

  static final RegExp _listMarker = RegExp(r'^(•|\d{1,2}[.)])\s+');

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final paragraphs = content
        .replaceAll('\r\n', '\n')
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final gap = (base.fontSize ?? 16) * 0.75;

    final children = <Widget>[];
    for (var i = 0; i < paragraphs.length; i++) {
      if (i > 0) children.add(SizedBox(height: gap));
      final lines = paragraphs[i].split('\n');
      for (var j = 0; j < lines.length; j++) {
        final line = lines[j].trim();
        if (line.isEmpty) continue;
        if (j > 0) children.add(SizedBox(height: gap / 3));
        final marker = _listMarker.firstMatch(line);
        if (marker == null) {
          children.add(Text.rich(_spans(line, base), textAlign: textAlign));
        } else {
          children.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: (base.fontSize ?? 16) * 1.6,
                child: Text(marker.group(1)!, style: base),
              ),
              Expanded(
                child: Text.rich(
                  _spans(line.substring(marker.end), base),
                  textAlign: textAlign,
                ),
              ),
            ],
          ));
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  TextSpan _spans(String text, TextStyle base) =>
      inlineMarkdownSpan(text, base: base, emphasisStyle: emphasisStyle);
}

/// Inline `**bold**` / `*italic*` → spans. Shared by [RichContentText] and
/// any single-line headline that carries emphasis markers.
TextSpan inlineMarkdownSpan(String text,
    {TextStyle? base, TextStyle? emphasisStyle}) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|(?<![*\w])\*(?!\s)(.+?)(?<!\s)\*(?![*\w])');
  var index = 0;
  for (final m in pattern.allMatches(text)) {
    if (m.start > index) spans.add(TextSpan(text: text.substring(index, m.start)));
    if (m.group(1) != null) {
      spans.add(TextSpan(
        text: m.group(1),
        style: emphasisStyle ?? const TextStyle(fontWeight: FontWeight.w700),
      ));
    } else {
      spans.add(TextSpan(
        text: m.group(2),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));
    }
    index = m.end;
  }
  if (index < text.length) spans.add(TextSpan(text: text.substring(index)));
  return TextSpan(style: base, children: spans);
}

/// Removes the inline markers (`**`, `*`) and list bullets so text reads
/// cleanly in a one- or two-line preview.
String stripInlineMarkdown(String text) => text
    .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!)
    .replaceAllMapped(
        RegExp(r'(?<![*\w])\*(?!\s)(.+?)(?<!\s)\*(?![*\w])'), (m) => m.group(1)!)
    .replaceAll(RegExp(r'^\s*(•|\d{1,2}[.)])\s+', multiLine: true), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// A clean card preview: the first paragraph with markers stripped, cut at a
/// word boundary (never mid-word) with an ellipsis when longer than
/// [maxChars].
String plainExcerpt(String content, {int maxChars = 140}) {
  final firstPara = content
      .replaceAll('\r\n', '\n')
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .firstWhere((p) => p.isNotEmpty, orElse: () => '');
  final plain = stripInlineMarkdown(firstPara);
  if (plain.length <= maxChars) return plain;
  final cut = plain.substring(0, maxChars);
  final lastSpace = cut.lastIndexOf(' ');
  final trimmed = (lastSpace > maxChars * 0.6 ? cut.substring(0, lastSpace) : cut)
      .replaceAll(RegExp(r'[\s,;:.\-–—]+$'), '');
  return '$trimmed…';
}
