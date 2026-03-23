/// Converts raw exceptions into user-friendly messages.
class FriendlyError {
  FriendlyError._();

  static String from(Object error) {
    final msg = error.toString();

    // Network errors
    if (msg.contains('SocketException') || msg.contains('No internet')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return 'The request timed out. Please check your connection and try again.';
    }

    // Rate limiting
    if (msg.contains('429') || msg.contains('rate limit') || msg.contains('quota')) {
      return 'Too many requests. Please wait a moment and try again.';
    }

    // Gemini-specific
    if (msg.contains('Empty response from Gemini')) {
      return 'The AI returned no results. Try again or enter the information manually.';
    }
    if (msg.contains('Could not parse AI response')) {
      return 'The AI response was not in the expected format. Please try again.';
    }

    // Generic API errors
    if (msg.contains('API error') || msg.contains('GenerativeAI')) {
      return 'The AI service encountered an error. Please try again later.';
    }

    // Permission errors
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
