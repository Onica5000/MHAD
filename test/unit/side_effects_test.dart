import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/side_effect_item.dart';
import 'package:mhad/ui/export/pdf/pdf_helpers.dart';

/// Guards the side-effects data path: the checklist UI persists confirmed
/// effects as `{items: [...]}` JSON in `directive_prefs.side_effects_json`, and
/// the PDF renderer reads that same JSON back. The two sides must agree on the
/// key names and envelope shape — drift there silently drops the block from the
/// printed directive while every build stays green.
void main() {
  group('SideEffectItem JSON round-trip', () {
    test('survives toJson -> fromJson with all fields', () {
      final item = SideEffectItem(
        med: 'Lithium',
        effect: 'Hand tremor',
        adlImpact: 'Handwriting, fine motor tasks',
        serious: true,
        experiencing: true,
      );

      final back = SideEffectItem.fromJson(item.toJson());

      expect(back.med, 'Lithium');
      expect(back.effect, 'Hand tremor');
      expect(back.adlImpact, 'Handwriting, fine motor tasks');
      expect(back.serious, isTrue);
      expect(back.experiencing, isTrue);
    });

    test('toJson uses the short "adl" key the PDF reader expects', () {
      final json = SideEffectItem(med: 'X', effect: 'Y', adlImpact: 'Z').toJson();
      // The PDF helper reads raw['adl'] — not 'adlImpact'. Lock the key name.
      expect(json.containsKey('adl'), isTrue);
      expect(json['adl'], 'Z');
    });

    test('fromJson defaults missing fields and coerces non-bool flags', () {
      final back = SideEffectItem.fromJson({'effect': 'Drowsiness'});
      expect(back.med, '');
      expect(back.effect, 'Drowsiness');
      expect(back.adlImpact, '');
      // serious/experiencing must be strictly `true` — anything else is false.
      expect(back.serious, isFalse);
      expect(back.experiencing, isFalse);

      final coerced = SideEffectItem.fromJson(
          {'effect': 'E', 'serious': 'true', 'experiencing': 1});
      expect(coerced.serious, isFalse, reason: 'string "true" is not bool true');
      expect(coerced.experiencing, isFalse, reason: '1 is not bool true');
    });
  });

  group('experiencedSideEffectsBlocks (PDF reader contract)', () {
    String encodeItems(List<SideEffectItem> items) =>
        jsonEncode({'items': items.map((i) => i.toJson()).toList()});

    test('returns nothing for null / empty / malformed JSON', () {
      expect(experiencedSideEffectsBlocks(null), isEmpty);
      expect(experiencedSideEffectsBlocks(''), isEmpty);
      expect(experiencedSideEffectsBlocks('not json'), isEmpty);
      expect(experiencedSideEffectsBlocks('[]'), isEmpty,
          reason: 'top level must be a {items: [...]} map');
    });

    test('omits items the user did NOT confirm experiencing', () {
      final json = encodeItems([
        SideEffectItem(med: 'A', effect: 'Nausea', experiencing: false),
        SideEffectItem(med: 'B', effect: 'Dry mouth', experiencing: false),
      ]);
      expect(experiencedSideEffectsBlocks(json), isEmpty);
    });

    test('omits confirmed items that have no effect text', () {
      final json = encodeItems([
        SideEffectItem(med: 'A', effect: '', experiencing: true),
      ]);
      expect(experiencedSideEffectsBlocks(json), isEmpty);
    });

    test('renders a single block when at least one effect is confirmed', () {
      final json = encodeItems([
        SideEffectItem(med: 'A', effect: 'Nausea', experiencing: false),
        SideEffectItem(
            med: 'Lithium',
            effect: 'Hand tremor',
            adlImpact: 'Writing',
            serious: true,
            experiencing: true),
      ]);
      // One dataBlock summarising the confirmed effects.
      expect(experiencedSideEffectsBlocks(json).length, 1);
    });

    test('full screen->PDF round-trip agrees on shape', () {
      // Exactly how side_effects_screen persists the checklist.
      final persisted = encodeItems([
        SideEffectItem(
            med: 'Sertraline',
            effect: 'Insomnia',
            adlImpact: 'Sleep, next-day alertness',
            experiencing: true),
      ]);
      expect(experiencedSideEffectsBlocks(persisted).length, 1,
          reason: 'screen JSON envelope must be readable by the PDF helper');
    });
  });
}
