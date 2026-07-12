import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/utils/date_format.dart';
import 'package:mhad/ui/wizard/widgets/contact_picker_button.dart'
    show PickedContactData;

/// Eligibility verdict for a candidate contact.
enum _Eligibility {
  /// Under 18 — hard block; the user can't select this contact for the
  /// agent role (agents must be adults, 20 Pa.C.S. § 5835).
  blocked,

  /// Name pattern suggests a provider — soft warning; the user can
  /// override but should confirm the contact isn't currently treating
  /// them.
  warn,

  /// No flagged disqualifiers detected.
  eligible,
}

class _Candidate {
  final Contact contact;
  final _Eligibility eligibility;
  final String? eligibilityNote;
  const _Candidate({
    required this.contact,
    required this.eligibility,
    this.eligibilityNote,
  });

  String get displayName => contact.displayName ?? '';
}

/// Editorial contact-picker bottom sheet — matches prototype
/// `ScrContactPicker` (mobile-extra.jsx L2327-2470).
///
/// Layout:
///   - Drag handle
///   - Italic-serif "Pick your **[role].**" headline
///   - Subtitle "From your phone's contacts. We never upload them —
///     search runs locally."
///   - Local search pill with X-clear
///   - Suggested group (starred contacts) + Other matches group
///   - Person tiles with 42pt initials avatar, MONO relation/eligibility
///     label, selection radio; tiles dim for hard-blocked candidates
///   - "+ Enter someone manually" dashed-border tile (returns an empty
///     PickedContactData for the caller's free-form fields)
///   - "WHO CAN'T BE YOUR AGENT" eligibility rules card
///   - Footer: ghost Cancel + primary "Use [Name] →" (disabled until a
///     non-blocked contact is selected)
///
/// Returns the picked contact's data via [Navigator.pop], or `null` when
/// the user cancels.
Future<PickedContactData?> showContactPickerSheet(
  BuildContext context, {
  String role = 'primary agent',
}) async {
  // Request read permission first — without it the sheet has nothing
  // to show. The caller surfaces the "permission denied" snackbar.
  final status =
      await FlutterContacts.permissions.request(PermissionType.read);
  if (!context.mounted) return null;
  if (status != PermissionStatus.granted &&
      status != PermissionStatus.limited) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact permission is required to import.'),
      ),
    );
    return null;
  }

  // Pull every contact (with phones + addresses + birthdays for the
  // eligibility heuristics). Sort alphabetically.
  final contacts = await FlutterContacts.getAll(
    properties: {
      ContactProperty.phone,
      ContactProperty.address,
      ContactProperty.event,
    },
  );
  contacts.sort((a, b) =>
      (a.displayName ?? '').toLowerCase().compareTo(
          (b.displayName ?? '').toLowerCase()));

  if (!context.mounted) return null;
  return showModalBottomSheet<PickedContactData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _ContactPickerSheet(role: role, contacts: contacts),
  );
}

class _ContactPickerSheet extends StatefulWidget {
  final String role;
  final List<Contact> contacts;

  const _ContactPickerSheet({
    required this.role,
    required this.contacts,
  });

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  final _searchCtrl = TextEditingController();
  Contact? _selected;
  late final List<_Candidate> _all;

  @override
  void initState() {
    super.initState();
    _all = widget.contacts
        .map((c) => _Candidate(
              contact: c,
              eligibility: _eligibilityFor(c),
              eligibilityNote: _eligibilityNote(c),
            ))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static _Eligibility _eligibilityFor(Contact c) {
    // Under-18 check: any of the contact's stored birthdays whose age is
    // under 18 hard-blocks. Empty/null birthdays don't block.
    for (final ev in c.events) {
      if (ev.label.label != EventLabel.birthday) continue;
      if (ev.year == null) continue; // year-less birthdays are useless here
      final dob = DateTime(ev.year!, ev.month, ev.day);
      if (!isAdult(dob)) return _Eligibility.blocked;
    }
    // Provider heuristic — name starts with "Dr." or contains a
    // common credential suffix delimited by whitespace.
    final n = (c.displayName ?? '').toLowerCase();
    if (n.startsWith('dr.') || n.startsWith('dr ')) return _Eligibility.warn;
    final credentials = <String>[
      'md',
      'do',
      'phd',
      'np',
      'pa-c',
      'rn',
      'lcsw',
      'psyd',
      'crnp',
      'arnp',
    ];
    for (final cred in credentials) {
      if (RegExp('\\b$cred\\b').hasMatch(n)) return _Eligibility.warn;
    }
    return _Eligibility.eligible;
  }

  static String? _eligibilityNote(Contact c) {
    final n = (c.displayName ?? '').toLowerCase();
    if (n.startsWith('dr.') || n.startsWith('dr ')) {
      return 'Looks like a provider';
    }
    if (RegExp(r'\b(md|do|phd|np|pa-c|rn|lcsw|psyd|crnp|arnp)\b')
        .hasMatch(n)) {
      return 'Looks like a provider';
    }
    for (final ev in c.events) {
      if (ev.label.label != EventLabel.birthday) continue;
      if (ev.year == null) continue;
      final dob = DateTime(ev.year!, ev.month, ev.day);
      if (!isAdult(dob)) return 'Under 18';
    }
    return null;
  }

  String _initialsFor(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  List<_Candidate> _filtered() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((c) {
      final name = c.displayName.toLowerCase();
      if (name.contains(q)) return true;
      for (final phone in c.contact.phones) {
        if (phone.number.toLowerCase().contains(q)) return true;
      }
      return false;
    }).toList();
  }

  Future<void> _confirmSelection() async {
    final sel = _selected;
    if (sel == null) return;
    // Re-fetch with phone + address properties when an id is available.
    // `getAll(properties: {phone, address, event})` already pulled the
    // primary surface, so this is a belt-and-suspenders refresh; we fall
    // back to the in-memory selection if id is null.
    Contact full = sel;
    final id = sel.id;
    if (id != null && id.isNotEmpty) {
      final fetched = await FlutterContacts.get(id,
          properties: {ContactProperty.phone, ContactProperty.address});
      if (fetched != null) full = fetched;
    }
    if (!mounted) return;
    final data = _toPicked(full);
    Navigator.of(context).pop(data);
  }

  PickedContactData _toPicked(Contact full) {
    String address = '';
    if (full.addresses.isNotEmpty) {
      final a = full.addresses.first;
      address = [a.street, a.city, a.state, a.postalCode]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(', ');
    }
    String home = '', work = '', cell = '';
    for (final p in full.phones) {
      final num = p.number;
      switch (p.label.label) {
        case PhoneLabel.home:
          if (home.isEmpty) home = num;
        case PhoneLabel.work:
          if (work.isEmpty) work = num;
        case PhoneLabel.mobile:
          if (cell.isEmpty) cell = num;
        default:
          if (cell.isEmpty) {
            cell = num;
          } else if (home.isEmpty) {
            home = num;
          } else if (work.isEmpty) {
            work = num;
          }
      }
    }
    return PickedContactData(
      fullName: full.displayName ?? '',
      address: address,
      homePhone: home,
      workPhone: work,
      cellPhone: cell,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final filtered = _filtered();
    // The flutter_contacts API doesn't expose a "starred"/"favorited"
    // attribute on Contact, so we render a single sorted list instead of
    // the prototype's Suggested/Other split. The visual chrome
    // (SectionLabel "Contacts · N") still matches the prototype's
    // grouping style.
    final others = filtered;
    final selCand = _selected == null
        ? null
        : _all.firstWhere((c) => c.contact.id == _selected!.id,
            orElse: () =>
                _Candidate(contact: _selected!, eligibility: _Eligibility.eligible));
    final canUse = selCand != null && selCand.eligibility != _Eligibility.blocked;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.sheetRadius)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: p.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Pick your '),
                        TextSpan(
                          text: '${widget.role}.',
                          style: TextStyle(color: p.primary),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontFamilyFallback: ['Georgia', 'serif'],
                      fontStyle: FontStyle.italic,
                      fontSize: 28,
                      height: 1.05,
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "From your phone's contacts. We never upload them — "
                    'search runs locally.',
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 12.5,
                      height: 1.45,
                      color: p.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: p.surface,
                      border: Border.all(color: p.border),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            size: 16, color: p.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            // Initial focus when the sheet opens (A3) —
                            // searching is the primary action here.
                            autofocus: true,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Search by name or number',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                            style: TextStyle(
                              fontFamily: kSansFamily,
                              fontSize: 13,
                              color: p.text,
                            ),
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _searchCtrl.clear()),
                            child: Icon(Icons.close,
                                size: 14, color: p.textMuted),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 12),
                children: [
                  SectionLabel('Contacts · ${others.length}'),
                  for (final c in others)
                    _PersonTile(
                      cand: c,
                      selected: _selected?.id == c.contact.id,
                      initials: _initialsFor(c.displayName),
                      onTap: c.eligibility == _Eligibility.blocked
                          ? null
                          : () => setState(() => _selected = c.contact),
                    ),
                  const SizedBox(height: 8),
                  _ManualEntryTile(
                    onTap: () => Navigator.of(context).pop(
                      const PickedContactData(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _EligibilityRulesCard(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.fromLTRB(18, 12, 18, 24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: p.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: canUse ? _confirmSelection : null,
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: Text(_selected == null
                          ? 'Pick a contact'
                          : 'Use ${_firstName(_selected!.displayName ?? '')}'),
                      style: FilledButton.styleFrom(
                        iconAlignment: IconAlignment.end,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _firstName(String name) {
    final t = name.trim();
    if (t.isEmpty) return 'this contact';
    return t.split(RegExp(r'\s+')).first;
  }
}

class _PersonTile extends StatelessWidget {
  final _Candidate cand;
  final bool selected;
  final String initials;
  final VoidCallback? onTap;

  const _PersonTile({
    required this.cand,
    required this.selected,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final blocked = cand.eligibility == _Eligibility.blocked;
    final warn = cand.eligibility == _Eligibility.warn;

    final warnColor =
        dark ? SemanticColors.warningTextDark : SemanticColors.warningTextLight;
    final warnBorder = dark
        ? SemanticColors.warningBorderDark
        : SemanticColors.warningBorderLight;
    final dangerColor =
        dark ? SemanticColors.errorAccentDark : SemanticColors.errorAccentLight;

    final borderColor = selected
        ? p.primary
        : (warn ? warnBorder : p.border);

    // Relation/eligibility label — uppercase MONO. The flutter_contacts
    // API doesn't expose favorited/starred, so we render the first
    // available phone label (HOME / WORK / MOBILE) instead. Empty if no
    // phones.
    String? relLabel;
    if (cand.contact.phones.isNotEmpty) {
      relLabel = cand.contact.phones.first.label.label.name.toUpperCase();
    }

    return Opacity(
      opacity: blocked ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: p.card,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected ? p.primary : p.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: selected ? p.onPrimary : p.onPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cand.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: p.text,
                          ),
                        ),
                        if (relLabel != null)
                          Text(
                            relLabel,
                            style: TextStyle(
                              fontFamily: kMonoFamily,
                              fontFamilyFallback: const [
                                'Consolas',
                                'Menlo',
                                'Courier New',
                                'monospace',
                              ],
                              fontSize: 11,
                              letterSpacing: 0.3,
                              color: p.textMuted,
                            ),
                          ),
                        if (cand.eligibilityNote != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              blocked
                                  ? '⚠ ${cand.eligibilityNote!}'
                                  : '⚠ ${cand.eligibilityNote!} — confirm they\'re not treating you',
                              style: TextStyle(
                                fontFamily: kSansFamily,
                                fontSize: 11,
                                color: blocked ? dangerColor : warnColor,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '✓ Eligible · 18+',
                              style: TextStyle(
                                fontFamily: kSansFamily,
                                fontSize: 11,
                                color: p.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: selected ? p.primary : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? p.primary
                            : (warn ? warnColor : p.border),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: selected
                        ? Icon(Icons.check,
                            size: 14, color: p.onPrimary)
                        : (warn
                            ? Center(
                                child: Text(
                                  '!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: warnColor,
                                  ),
                                ),
                              )
                            : null),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualEntryTile extends StatelessWidget {
  final VoidCallback onTap;
  const _ManualEntryTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: p.border,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, size: 16, color: p.primary),
              const SizedBox(width: 8),
              Text(
                'Enter someone manually',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: p.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EligibilityRulesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final dangerColor =
        dark ? SemanticColors.errorAccentDark : SemanticColors.errorAccentLight;
    final warnColor =
        dark ? SemanticColors.warningTextDark : SemanticColors.warningTextLight;

    final rules = <(String, _Eligibility, String)>[
      ('Under 18', _Eligibility.blocked, 'hard block'),
      ('Your current treating provider or their employee',
          _Eligibility.warn, 'soft warn'),
      ('An owner/operator of a facility where you receive care',
          _Eligibility.warn, 'soft warn'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel("Who can't be your agent"),
          const SizedBox(height: 6),
          for (final (rule, kind, label) in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color:
                          kind == _Eligibility.blocked ? dangerColor : warnColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 12,
                        color: p.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: kMonoFamily,
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color:
                          kind == _Eligibility.blocked ? dangerColor : warnColor,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            "Under-18 is blocked automatically from the contact's "
            "birthday. We can't tell who your providers are, so anything "
            "that looks like a provider is a soft warning you can "
            'override — confirm only if they truly aren\'t treating you.',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 10.5,
              color: p.textMuted,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
