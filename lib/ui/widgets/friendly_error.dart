import 'package:http/http.dart' as http;
import 'package:mhad/ai/llm_client.dart';

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

  static String from(Object error) {
    // Typed transport errors first — their messages are already user-facing and
    // already name the corrective action.
    if (error is LlmRateLimitError) return error.message;
    if (error is UnsupportedInputError) return error.message;
    if (error is LlmAuthError) return error.message;
    if (error is LlmModelNotFoundError) return error.message;
    if (error is LlmNetworkError) return error.message;

    // Anything that reached the network layer but not a provider. On web this
    // is the ONLY network failure type — browsers never raise SocketException —
    // so without this branch the web build had no connectivity error path.
    if (error is http.ClientException) {
      return "Couldn't reach the AI service. Check your internet connection. "
          'If you are using the web app, this provider may also be blocked by '
          "your browser's security policy — Gemini and Claude both work in "
          'the browser.';
    }

    final msg = error.toString();

    // Network errors (native).
    if (msg.contains('SocketException') || msg.contains('No internet')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return 'The request timed out. Please check your connection and try again.';
    }
    // Web CORS/network failures that arrive as plain text rather than a typed
    // ClientException (e.g. re-thrown through a layer that stringified them).
    if (msg.contains('Failed to fetch') ||
        msg.contains('XMLHttpRequest') ||
        msg.contains('ClientException')) {
      return "Couldn't reach the AI service — the request was blocked or the "
          'connection failed. Check your internet connection, and if you are '
          'on the web app try Gemini or Claude, which work in the browser.';
    }

    // Rate limiting.
    if (msg.contains('429') || msg.contains('rate limit') || msg.contains('quota')) {
      return 'Too many requests. Please wait a moment and try again.';
    }

    // Key / permission rejections that bypassed the typed errors above.
    if (msg.contains('API key') ||
        msg.contains('API_KEY') ||
        msg.contains('UNAUTHENTICATED') ||
        msg.contains('401') ||
        msg.contains('403')) {
      return 'Your API key was rejected. Open AI setup and check the key is '
          'correct, still active, and belongs to the selected provider.';
    }

    // Retired / mistyped model id.
    if (msg.contains('not found for API version') ||
        msg.contains('is not supported for') ||
        msg.contains('model not found') ||
        msg.contains('404')) {
      return "The selected AI model isn't available — it may have been "
          'retired. Pick a different model in AI setup.';
    }

    // Empty model output (any provider).
    if (msg.contains('Empty response from the AI')) {
      return 'The AI returned no results. Try again or enter the information manually.';
    }
    if (msg.contains('Could not parse AI response')) {
      return 'The AI response was not in the expected format. Please try again.';
    }

    // Generic API errors — genuinely unknown, so this is the one place a
    // "try again" is honest.
    if (msg.contains('API error') || msg.contains('GenerativeAI')) {
      return 'The AI service encountered an error. Please try again later.';
    }

    // Permission errors (device permissions, not API auth).
    if (msg.contains('permission') || msg.contains('Permission')) {
      return 'Permission was not granted. Please check your device settings.';
    }

    // Document import
    if (msg.contains('No relevant medical information')) {
      return msg; // Already user-friendly
    }

    // Fallback — strip "Exception: " prefix
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }

    return 'Something went wrong. Please try again.';
  }
}
