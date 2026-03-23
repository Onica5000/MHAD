import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DisclaimerNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with provided value', () {
      final notifier = DisclaimerNotifier(initialValue: false);
      expect(notifier.accepted, isFalse);
    });

    test('initializes as accepted when true', () {
      final notifier = DisclaimerNotifier(initialValue: true);
      expect(notifier.accepted, isTrue);
    });

    test('load returns false when no stored value', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = await DisclaimerNotifier.load();
      expect(notifier.accepted, isFalse);
    });

    test('load returns true when previously accepted', () async {
      SharedPreferences.setMockInitialValues({'disclaimer_accepted': true});
      final notifier = await DisclaimerNotifier.load();
      expect(notifier.accepted, isTrue);
    });

    test('accept sets accepted to true', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = DisclaimerNotifier(initialValue: false);
      expect(notifier.accepted, isFalse);
      await notifier.accept();
      expect(notifier.accepted, isTrue);
    });

    test('accept notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = DisclaimerNotifier(initialValue: false);
      var notified = false;
      notifier.addListener(() => notified = true);
      await notifier.accept();
      expect(notified, isTrue);
    });

    test('accept persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = DisclaimerNotifier(initialValue: false);
      await notifier.accept();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('disclaimer_accepted'), isTrue);
    });
  });
}
