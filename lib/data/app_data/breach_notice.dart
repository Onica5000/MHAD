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
class BreachNotice {
  /// Stable identifier, e.g. `2026-10-01-ai-provider`. Keys the acknowledgement.
  final String id;

  /// Date the notice was issued (free text, shown as-is).
  final String date;

  final String title;

  /// What happened, when, and when it was discovered.
  final String whatHappened;

  /// Types of PHR-identifiable information involved.
  final String informationInvolved;

  /// Full identity of any third party that acquired the information (required
  /// content under the amended rule). Empty when none.
  final String thirdParties;

  /// What we are doing to protect affected people / mitigate harm.
  final String whatWeAreDoing;

  /// Steps affected people should take.
  final String whatYouCanDo;

  /// Contact methods — the amended rule requires **at least two** (toll-free
  /// phone, email, website, in-app, postal). This in-app notice counts as one.
  final List<String> contactMethods;

  const BreachNotice({
    required this.id,
    this.date = '',
    this.title = '',
    this.whatHappened = '',
    this.informationInvolved = '',
    this.thirdParties = '',
    this.whatWeAreDoing = '',
    this.whatYouCanDo = '',
    this.contactMethods = const [],
  });

  /// Parses the `breachNotice` block. Returns null for a missing block or an
  /// empty `id`, so a half-filled template can never surface by accident.
  static BreachNotice? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    final id = (m['id'] ?? '').toString().trim();
    if (id.isEmpty) return null;
    String s(String k) => (m[k] ?? '').toString().trim();
    return BreachNotice(
      id: id,
      date: s('date'),
      title: s('title'),
      whatHappened: s('whatHappened'),
      informationInvolved: s('informationInvolved'),
      thirdParties: s('thirdParties'),
      whatWeAreDoing: s('whatWeAreDoing'),
      whatYouCanDo: s('whatYouCanDo'),
      contactMethods: [
        for (final c in (m['contactMethods'] as List?) ?? const [])
          if (c.toString().trim().isNotEmpty) c.toString().trim(),
      ],
    );
  }
}
