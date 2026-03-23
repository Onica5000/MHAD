import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Tracks Gemini API usage against the free tier limits.
///
/// Gemini 2.5 Flash free tier (as of Dec 2025):
///   - 10 requests per minute (RPM)
///   - 250 requests per day (RPD)
///   - 250,000 tokens per minute (TPM)
///   - 1,048,576 token context window
///   - 65,536 max output tokens
///
/// This tracker is in-memory and resets on app restart. It provides:
///   - Pre-flight checks before sending requests
///   - Usage info for the UI (remaining requests, estimated tokens)
///   - Estimated wait time when rate-limited
class GeminiRateTracker extends ChangeNotifier {
  // ── Free tier limits ─────────────────────────────────────────────────
  static const int maxRpm = 10;
  static const int maxRpd = 250;
  static const int maxTpm = 250000;
  static const int maxContextTokens = 1048576;

  /// Rough estimate: 1 token ≈ 4 characters in English.
  static const double charsPerToken = 4.0;

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

  int get remainingRpm => (maxRpm - requestsThisMinute).clamp(0, maxRpm);

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

  int get remainingRpd => (maxRpd - requestsToday).clamp(0, maxRpd);

  bool get dailyLimitReached => remainingRpd <= 0;

  // ── Token estimation ─────────────────────────────────────────────────

  int get tokensThisMinute {
    _prune(DateTime.now());
    return _tokenMinuteLog.fold(0, (sum, e) => sum + e.tokens);
  }

  int get remainingTpm => (maxTpm - tokensThisMinute).clamp(0, maxTpm);

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

  bool get canSend => remainingRpm > 0 && remainingRpd > 0;

  /// Returns a user-facing reason if the request should be blocked,
  /// or null if it's safe to send.
  String? get blockReason {
    if (dailyLimitReached) {
      return 'You\'ve used all $maxRpd free requests for today. '
          'The limit resets at midnight. Consider upgrading to a paid '
          'API key for higher limits.';
    }
    if (remainingRpm <= 0) {
      return 'Too many requests this minute (limit: $maxRpm/min). '
          'Please wait ${secondsUntilRpmSlot} seconds.';
    }
    return null;
  }

  // ── UI display ───────────────────────────────────────────────────────

  /// Short status for the app bar or info chip.
  String get statusText {
    _prune(DateTime.now());
    if (dailyLimitReached) {
      return 'Daily limit reached ($maxRpd/$maxRpd)';
    }
    if (remainingRpm <= 0) {
      return 'Wait ${secondsUntilRpmSlot}s \u2022 $remainingRpd/$maxRpd today';
    }
    if (requestsToday == 0) return '';
    return '$remainingRpd/$maxRpd today \u2022 $remainingRpm/$maxRpm this min';
  }

  /// Whether to show a warning indicator (approaching limits).
  bool get showWarning =>
      remainingRpd <= 25 || remainingRpm <= 2 || dailyLimitReached;

  /// Whether to show the status at all (hide when no requests made).
  bool get showStatus => requestsToday > 0;

  /// Last request's estimated token count (for display).
  int get lastRequestTokens => _lastRequestTokens;
}

class _TokenEntry {
  final DateTime time;
  final int tokens;
  const _TokenEntry(this.time, this.tokens);
}
