import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mhad/ai/llm_client.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';

/// Locks the failure-diagnosis behaviour added after a real report of
/// "I wasn't able to send info to the AI" with no usable explanation.
///
/// The rule these tests defend: an error the user can fix must say what to fix,
/// and must never be reported as a transient problem that retrying will clear.
void main() {
  group('FriendlyError — actionable diagnosis', () {
    test('a rejected API key names the key, and never says "try again later"',
        () {
      const err = LlmAuthError(
          'Gemini rejected your API key. Open AI setup and check the key is '
          'correct, still active, and has the Generative Language API enabled.');
      final msg = FriendlyError.from(err);
      expect(msg, contains('API key'));
      expect(msg, contains('AI setup'));
      // The old behaviour: 401 fell through to the generic "API error" branch
      // and told the user to wait — advice that can never work for a bad key.
      expect(msg.toLowerCase(), isNot(contains('try again later')));
    });

    test('an unknown model points at AI setup rather than the AI service', () {
      const err = LlmModelNotFoundError(
          'Gemini doesn\'t recognise the model "gemini-x" — it may have been '
          'retired. Pick a different model in AI setup.');
      final msg = FriendlyError.from(err);
      expect(msg, contains('AI setup'));
      expect(msg.toLowerCase(), isNot(contains('try again later')));
    });

    test('a network/CORS failure is explained, not swallowed', () {
      const err = LlmNetworkError(
          "Couldn't reach Gemini (Failed to fetch). Check your internet "
          'connection.');
      expect(FriendlyError.from(err), contains('internet connection'));
    });

    test('a raw web ClientException no longer falls through to the catch-all',
        () {
      // Browsers raise ClientException, never SocketException, so before this
      // branch existed the web build had no connectivity error path at all and
      // every CORS/offline failure read "Something went wrong."
      final msg = FriendlyError.from(http.ClientException('Failed to fetch'));
      expect(msg, isNot('Something went wrong. Please try again.'));
      expect(msg, contains('internet connection'));
    });

    test('stringified key/model failures are still caught by the text fallback',
        () {
      expect(
        FriendlyError.from(Exception('API key not valid. Please pass a valid '
            'API key.')),
        contains('API key was rejected'),
      );
      expect(
        FriendlyError.from(
            Exception('models/foo is not found for API version v1beta')),
        contains('AI setup'),
      );
    });

    test('a genuinely unknown provider error may still say try again', () {
      // The one honest use of "try again later" — nothing identifies a fix.
      expect(
        FriendlyError.from(Exception('Gemini API error (500).')),
        contains('try again later'),
      );
    });

    test('rate limits keep their existing typed message', () {
      const err = LlmRateLimitError('Too many requests to Gemini.');
      expect(FriendlyError.from(err), 'Too many requests to Gemini.');
    });
  });

  group('GeminiRateTracker — enforcement is scoped to Gemini', () {
    test('blocks once the per-minute cap is hit while enforced', () {
      final t = GeminiRateTracker()..enforced = true;
      for (var i = 0; i < GeminiRateTracker.maxRpm; i++) {
        t.recordRequest();
      }
      expect(t.remainingRpm, 0);
      expect(t.blockReason, isNotNull);
    });

    test('does not block a non-Gemini provider with Google\'s free quota', () {
      // The bug: a paid Anthropic/OpenAI key was capped by Gemini's free tier
      // and told it had used its "free requests" for the day.
      final t = GeminiRateTracker()..enforced = false;
      for (var i = 0; i < GeminiRateTracker.maxRpm * 2; i++) {
        t.recordRequest();
      }
      expect(t.blockReason, isNull);
      expect(t.remainingRpm, GeminiRateTracker.maxRpm);
      expect(t.dailyLimitReached, isFalse);
      // And it must not quote a Gemini allowance at a non-Gemini user.
      expect(t.statusText, isEmpty);
      expect(t.showStatus, isFalse);
    });

    test('still records usage while unenforced, so switching back is accurate',
        () {
      final t = GeminiRateTracker()..enforced = false;
      t.recordRequest();
      t.recordRequest();
      t.enforced = true;
      expect(t.requestsThisMinute, 2);
    });
  });
}
