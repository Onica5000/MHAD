import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mhad/ai/llm_client.dart';
import 'package:mhad/l10n/l10n.dart';

/// Converts raw exceptions into user-friendly messages.
///
/// The guiding rule: **never tell the user to wait unless waiting can actually
/// fix it.** A rejected API key, a retired model id, and a CORS block are all
/// permanent until the user changes something, so each says what to change.
/// Previously they all collapsed into "The AI service encountered an error.
/// Please try again later." or "Something went wrong", which sent people off to
/// retry a request that could never succeed.
class FriendlyError {
  FriendlyError._();

  /// [l10n] localizes the message; without it (tests, non-UI callers) the
  /// English copy is used.
  static String from(Object error, [AppLocalizations? l10n]) {
    final l = l10n ?? lookupAppLocalizations(const Locale('en'));
    // Typed transport errors first — their messages are already user-facing and
    // already name the corrective action.
    if (error is LlmRateLimitError) return error.messageIn(l10n);
    if (error is UnsupportedInputError) return error.messageIn(l10n);
    if (error is LlmAuthError) return error.messageIn(l10n);
    if (error is LlmModelNotFoundError) return error.messageIn(l10n);
    if (error is LlmNetworkError) return error.messageIn(l10n);
    if (error is LlmRefusalError) return error.messageIn(l10n);
    if (error is LlmTruncatedError) return error.messageIn(l10n);

    // Anything that reached the network layer but not a provider. On web this
    // is the ONLY network failure type — browsers never raise SocketException —
    // so without this branch the web build had no connectivity error path.
    if (error is http.ClientException) {
      return l.feAiUnreachable;
    }

    final msg = error.toString();

    // Network errors (native).
    if (msg.contains('SocketException') || msg.contains('No internet')) {
      return l.feNoInternet;
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return l.feTimeout;
    }
    // Web CORS/network failures that arrive as plain text rather than a typed
    // ClientException (e.g. re-thrown through a layer that stringified them).
    if (msg.contains('Failed to fetch') ||
        msg.contains('XMLHttpRequest') ||
        msg.contains('ClientException')) {
      return l.feBlocked;
    }

    // Rate limiting.
    if (msg.contains('429') || msg.contains('rate limit') || msg.contains('quota')) {
      return l.feRateLimited;
    }

    // Key / permission rejections that bypassed the typed errors above.
    if (msg.contains('API key') ||
        msg.contains('API_KEY') ||
        msg.contains('UNAUTHENTICATED') ||
        msg.contains('401') ||
        msg.contains('403')) {
      return l.feKeyRejected;
    }

    // Retired / mistyped model id.
    if (msg.contains('not found for API version') ||
        msg.contains('is not supported for') ||
        msg.contains('model not found') ||
        msg.contains('404')) {
      return l.feModelUnavailable;
    }

    // Empty model output (any provider).
    if (msg.contains('Empty response from the AI')) {
      return l.feEmptyResponse;
    }
    if (msg.contains('Could not parse AI response')) {
      return l.feBadFormat;
    }

    // Generic API errors — genuinely unknown, so this is the one place a
    // "try again" is honest.
    if (msg.contains('API error') || msg.contains('GenerativeAI')) {
      return l.feServiceError;
    }

    // Permission errors (device permissions, not API auth).
    if (msg.contains('permission') || msg.contains('Permission')) {
      return l.fePermission;
    }

    // Document import
    if (msg.contains('No relevant medical information')) {
      return msg; // Already user-friendly
    }

    // Fallback — strip "Exception: " prefix
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }

    return l.feGeneric;
  }
}
