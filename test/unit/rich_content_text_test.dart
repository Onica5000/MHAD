import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/widgets/rich_content_text.dart';

void main() {
  group('stripInlineMarkdown', () {
    test('removes bold and italic markers, keeps the words', () {
      expect(stripInlineMarkdown('**In simple terms:** a *written* plan'),
          'In simple terms: a written plan');
    });

    test('drops list bullets and numbers at line starts', () {
      expect(stripInlineMarkdown('• one\n• two\n1. three'), 'one two three');
    });

    test('leaves a lone asterisk (e.g. a footnote star) alone', () {
      expect(stripInlineMarkdown('Required * field'), 'Required * field');
    });
  });

  group('plainExcerpt', () {
    test('uses the first paragraph only, without markers', () {
      expect(plainExcerpt('**Short answer: yes.**\n\nMore detail here.'),
          'Short answer: yes.');
    });

    test('cuts at a word boundary with an ellipsis, never mid-word', () {
      final long = List.filled(40, 'word').join(' ');
      final out = plainExcerpt(long, maxChars: 50);
      expect(out.endsWith('…'), isTrue);
      expect(out.length, lessThanOrEqualTo(51));
      expect(out.replaceAll('…', '').split(' ').every((w) => w == 'word'),
          isTrue);
    });
  });

  group('inlineMarkdownSpan', () {
    test('bold spans default to w700; custom emphasis style is used', () {
      final plain = inlineMarkdownSpan('a **b** c');
      final bold = plain.children![1] as TextSpan;
      expect(bold.text, 'b');
      expect(bold.style!.fontWeight, FontWeight.w700);

      final colored = inlineMarkdownSpan('a **b** c',
          emphasisStyle: const TextStyle(color: Color(0xFF123456)));
      expect((colored.children![1] as TextSpan).style!.color,
          const Color(0xFF123456));
    });
  });

  testWidgets('RichContentText renders bold text without raw markers',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: RichContentText('**Bold lead.** Then text.\n\n• item one'),
      ),
    ));
    expect(find.textContaining('**'), findsNothing);
    expect(find.textContaining('Bold lead.', findRichText: true), findsOneWidget);
    expect(find.textContaining('item one', findRichText: true), findsOneWidget);
  });
}
