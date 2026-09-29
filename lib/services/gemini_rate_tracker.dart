import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// Tracks Gemini API usage against the free tier limits.
///
/// Gemini 3.5 Flash free tier (as of May 2026; the live numbers come from
/// `assets/data/app_data.json` — these are just illustrative):
///   - 15 requests per minute (RPM)
///   - 1,500 requests per day (RPD)
///   - 1,000,000 tokens per minute (TPM)
///   - 1,048,576 token context window
///   - 65,536 max output tokens
///
/// This tracker is in-memory and resets on app restart. It provides:
///   - Pre-flight checks before sending requests
///   - Usage info for the UI (remaining requests, estimated tokens)
///   - Estimated wait time when rate-limited
class GeminiRateTracker extends ChangeNotifier {
  // ── Free tier limits (from assets/data/app_data.json, updatable) ───────
  static int get maxRpm => appData.ai.rpm;
  static int get maxRpd => appData.ai.rpd;
  static int get maxTpm => appData.ai.tpm;
  static int get maxContextTokens => appData.ai.maxContextTokens;

  /// Rough estimate: 1 token ≈ 4 characters in English.
  static const double charsPerToken = 4.0;

  // ── Enforcement scope ────────────────────────────────────────────────
  /// Whether these caps should actually gate requests.
  ///
  /// The numbers above are **Gemini free-tier** limits, but this tracker was
  /// consulted on every AI path regardless of the active provider — so a user
  /// on a paid Anthropic/OpenAI/xAI key was blocked by Google's free quota and
  /// told they had used their "free requests" for the day. Requests are still
  /// *recorded* for every provider (the usage read-out stays truthful); only
  /// the blocking is scoped to the provider the limits describe.
  ///
  /// Kept as mutable state rather than a constructor arg so switching provider
  /// mid-session updates enforcement without discarding the request log.
  bool _enforced = true;

  bool get enforced => _enforced;

  set enforced(bool value) {
    if (_enforced == value) return;
    _enforced = value;
    notifyListeners();
  }

  // ── Request log ──────────────────────────────────────────────────────
  final _minuteLog = Queue<DateTime>();
  final _dayLog = Queue<DateTime>();

  // ── Token tracking (estimated) ───────────────────────────────────────
  final _tokenMinuteLog = Queue<_TokenEntry>();
  int _lastRequestTokens = 0;

  /// Record a request with estimated token count.
  void recordRequest({int estimatedTokens = 0}) {
    final now = DateTime.now();
    _minuteLog.add(now);
    _dayLog.add(now);
    if (estimatedTokens > 0) {
      _tokenMinuteLog.add(_TokenEntry(now, estimatedTokens));
      _lastRequestTokens = estimatedTokens;
    }
    _prune(now);
    notifyListeners();
  }

  void _prune(DateTime now) {
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    while (_minuteLog.isNotEmpty && _minuteLog.first.isBefore(oneMinuteAgo)) {
      _minuteLog.removeFirst();
    }
    while (_tokenMinuteLog.isNotEmpty &&
        _tokenMinuteLog.first.time.isBefore(oneMinuteAgo)) {
      _tokenMinuteLog.removeFirst();
    }
    final startOfDay = DateTime(now.year, now.month, now.day);
    while (_dayLog.isNotEmpty && _dayLog.first.isBefore(startOfDay)) {
      _dayLog.removeFirst();
    }
  }

  // ── RPM ──────────────────────────────────────────────────────────────

  int get requestsThisMinute {
    _prune(DateTime.now());
    return _minuteLog.length;
  }

  int get remainingRpm => _enforced
      ? (maxRpm - requestsThisMinute).clamp(0, maxRpm)
      : maxRpm;

  int get secondsUntilRpmSlot {
    if (remainingRpm > 0) return 0;
    if (_minuteLog.isEmpty) return 0;
    final oldest = _minuteLog.first;
    final expiresAt = oldest.add(const Duration(minutes: 1));
    final wait = expiresAt.difference(DateTime.now()).inSeconds;
    return wait.clamp(0, 60);
  }

  // ── RPD ──────────────────────────────────────────────────────────────

  int get requestsToday {
    _prune(DateTime.now());
    return _dayLog.length;
  }

  int get remainingRpd => _enforced
      ? (maxRpd - requestsToday).clamp(0, maxRpd)
      : maxRpd;

  bool get dailyLimitReached => _enforced && remainingRpd <= 0;

  // ── Token estimation ─────────────────────────────────────────────────

  int get tokensThisMinute {
    _prune(DateTime.now());
    return _tokenMinuteLog.fold(0, (sum, e) => sum + e.tokens);
  }

  int get remainingTpm => _enforced
      ? (maxTpm - tokensThisMinute).clamp(0, maxTpm)
      : maxTpm;

  /// Estimate tokens from a character count.
  static int estimateTokens(int charCount) =>
      (charCount / charsPerToken).ceil();

  /// Estimate the tokens for a chat request: system prompt + history + user message.
  static int estimateChatTokens({
    required int systemPromptChars,
    required int historyChars,
    required int userMessageChars,
  }) {
    return estimateTokens(systemPromptChars + historyChars + userMessageChars);
  }

  // ── Pre-flight check ─────────────────────────────────────────────────

  bool get canSend => remainingRpm > 0 && remainingRpd > 0 && remainingTpm > 0;

  /// Returns a user-facing reason if the request should be blocked,
  /// or null if it's safe to send.
  String? get blockReason {
    // Another provider's quota is the provider's business, not ours to guess.
    if (!_enforced) return null;
    if (dailyLimitReached) {
      return 'You\'ve used all $maxRpd free requests for today. '
          'The limit resets at midnight. Consider upgrading to a paid '
          'API key for higher limits.';
    }
    if (remainingRpm <= 0) {
      return 'Too many requests this minute (limit: $maxRpm/min). '
          'Please wait $secondsUntilRpmSlot seconds.';
    }
    if (remainingTpm <= 0) {
      return 'Token limit reached this minute (${(maxTpm / 1000).round()}K/min). '
          'Please wait a moment before sending another request.';
    }
    return null;
  }

  // ── UI display ───────────────────────────────────────────────────────

  /// Short status for the app bar or info chip.
  String get statusText {
    _prune(DateTime.now());
    // Don't quote Gemini's free-tier allowance at someone using another
    // provider — we have no visibility into their plan's limits.
    if (!_enforced) return '';
    if (dailyLimitReached) {
      return 'Daily limit reached';
    }
    if (remainingRpm <= 0) {
      return 'Wait ${secondsUntilRpmSlot}s \u2022 $remainingRpd requests left today';
    }
    if (requestsToday == 0) return '';
    return '$remainingRpd requests left today \u2022 $remainingRpm this minute';
  }

  /// Whether to show a warning indicator (approaching limits).
  bool get showWarning =>
      _enforced &&
      (remainingRpd <= 25 || remainingRpm <= 2 || dailyLimitReached);

  /// Whether to show the status at all (hide when no requests made).
  bool get showStatus => _enforced && requestsToday > 0;

  /// Last request's estimated token count (for display).
  int get lastRequestTokens => _lastRequestTokens;
}

class _TokenEntry {
  final DateTime time;
  final int tokens;
  const _TokenEntry(this.time, this.tokens);
}
