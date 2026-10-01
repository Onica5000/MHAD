/// Deterministic crisis-language check for messages typed to the AI
/// assistant (English + Spanish).
///
/// The assistant's system prompt already tells the model to point people in
/// crisis to 988, but a model can refuse, time out, be rate-limited, or not be
/// set up at all. This check runs in the app, before and independent of any
/// AI call, so the 988 banner appears regardless. It deliberately errs toward
/// showing help: a false positive costs one banner; a miss could cost more.
library;

final _patterns = <RegExp>[
  // English
  RegExp(r"\bsuicid", caseSensitive: false),
  RegExp(r"\bkill(ing)?\s+my\s*self\b", caseSensitive: false),
  RegExp(
    r"\bend(ing)?\s+(my|it\s+all)\b.*\blife\b|\bend\s+it\s+all\b",
    caseSensitive: false,
  ),
  RegExp(
    r"\b(want|wanna|going|plan(ning)?)\s+to\s+die\b",
    caseSensitive: false,
  ),
  RegExp(
    r"\b(hurt(ing)?|harm(ing)?|cut(ting)?)\s+my\s*self\b",
    caseSensitive: false,
  ),
  RegExp(r"\bself[\s-]?harm", caseSensitive: false),
  RegExp(
    r"\bno\s+(reason|point)\s+(to|in)\s+(live|living|go(ing)?\s+on)\b",
    caseSensitive: false,
  ),
  RegExp(r"\boverdos(e|ing)\b", caseSensitive: false),
  // Spanish
  RegExp(r"\bmatarme\b|\bquitarme\s+la\s+vida\b", caseSensitive: false),
  RegExp(
    r"\bquiero\s+morir(me)?\b|\bme\s+quiero\s+morir\b",
    caseSensitive: false,
  ),
  RegExp(
    r"\bhacerme\s+da[ñn]o\b|\blastimarme\b|\bautolesi",
    caseSensitive: false,
  ),
  RegExp(r"\bsobredosis\b", caseSensitive: false),
];

/// True when [text] contains language suggesting suicidal thoughts,
/// self-harm, or overdose.
bool looksLikeCrisis(String text) => _patterns.any((p) => p.hasMatch(text));
