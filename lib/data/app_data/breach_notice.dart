import 'package:mhad/data/app_data/localized_text.dart';

/// An FTC Health Breach Notification Rule notice (16 CFR Part 318, as amended
/// eff. 2024-07-29), published through `app_data.json` → `breachNotice`.
///
/// The app is local-first and holds no user contact list, so the in-app notice
/// is the primary channel (see `docs/BREACH_PLAN.md` → Notification Methods).
/// On web a deploy is all it takes to publish one: the next page load shows it.
///
/// Absent / empty `id` → no notice (the normal state). Each notice is shown
/// until acknowledged; acknowledgement is remembered per [id], so a *new*
/// notice (new id) is shown even to users who acknowledged an older one.
///
/// Every text field may be a plain string or `{"en": "...", "es": "..."}`
/// ([LocalizedText]); publish a notice in both languages.
class BreachNotice {
  /// Stable identifier, e.g. `2026-10-01-ai-provider`. Keys the acknowledgement.
  final String id;

  /// Date the notice was issued (free text, shown as-is).
  final String date;

  final LocalizedText title;

  /// What happened, when, and when it was discovered.
  final LocalizedText whatHappened;

  /// Types of PHR-identifiable information involved.
  final LocalizedText informationInvolved;

  /// Full identity of any third party that acquired the information (required
  /// content under the amended rule). Empty when none.
  final LocalizedText thirdParties;

  /// What we are doing to protect affected people / mitigate harm.
  final LocalizedText whatWeAreDoing;

  /// Steps affected people should take.
  final LocalizedText whatYouCanDo;

  /// Contact methods — the amended rule requires **at least two** (toll-free
  /// phone, email, website, in-app, postal). This in-app notice counts as one.
  final List<LocalizedText> contactMethods;

  const BreachNotice({
    required this.id,
    this.date = '',
    this.title = LocalizedText.empty,
    this.whatHappened = LocalizedText.empty,
    this.informationInvolved = LocalizedText.empty,
    this.thirdParties = LocalizedText.empty,
    this.whatWeAreDoing = LocalizedText.empty,
    this.whatYouCanDo = LocalizedText.empty,
    this.contactMethods = const [],
  });

  /// Parses the `breachNotice` block. Returns null for a missing block or an
  /// empty `id`, so a half-filled template can never surface by accident.
  static BreachNotice? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    final id = (m['id'] ?? '').toString().trim();
    if (id.isEmpty) return null;
    LocalizedText t(String k) => LocalizedText.fromJson(m[k]);
    return BreachNotice(
      id: id,
      date: (m['date'] ?? '').toString().trim(),
      title: t('title'),
      whatHappened: t('whatHappened'),
      informationInvolved: t('informationInvolved'),
      thirdParties: t('thirdParties'),
      whatWeAreDoing: t('whatWeAreDoing'),
      whatYouCanDo: t('whatYouCanDo'),
      contactMethods: [
        for (final c in (m['contactMethods'] as List?) ?? const [])
          if (LocalizedText.fromJson(c).isNotEmpty) LocalizedText.fromJson(c),
      ],
    );
  }
}
