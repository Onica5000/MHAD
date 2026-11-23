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

    test('dash bullets too (the privacy policy uses them)', () {
      expect(stripInlineMarkdown('  - one\n  - two'), 'one two');
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

    test('a lead-in ending with a colon carries on into its list', () {
      // Learn's witnesses card ended on "…who are NOT:" (visual review).
      expect(
          plainExcerpt('You need two adult witnesses who are NOT:\n\n'
              '• your agent\n• the person signing for you'),
          'You need two adult witnesses who are NOT: your agent; '
          'the person signing for you');
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

  testWidgets('dash bullets render as • with the text beside them',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: RichContentText('Your rights:\n  - Right to access\n  - Right '
            'to erasure'),
      ),
    ));
    expect(find.text('•'), findsNWidgets(2));
    expect(find.textContaining('- Right'), findsNothing);
    expect(find.textContaining('Right to access', findRichText: true),
        findsOneWidget);
  });

  test('readingMinutes: words / 200, rounded up, at least 1', () {
    expect(readingMinutes('**Short.**'), 1);
    expect(readingMinutes(List.filled(401, 'word').join(' ')), 3);
    expect(readingMinutes(List.filled(400, 'word').join(' ')), 2);
  });
}
