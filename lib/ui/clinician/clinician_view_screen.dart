import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Clinician / paramedic 30-second summary view (v2 prototype `m-clinician` +
/// `m-verify`, unified per v3 #29).
///
/// Read-only. Renders three color-coded blocks the user can hand to a
/// clinician on their unlocked phone:
/// - **DO NOT** (crisis-red): refusal items derived from medication entries
///   marked `exception` + allergies marked `severe` + explicit ECT/research
///   refusals
/// - **PREFERS** (ok-green): preferred medications, preferred facilities,
///   conditional consents
/// - **WHO TO CALL · IN ORDER** (primary border): agent → alternate →
///   preferred doctor
///
/// No audit-trail footer per v3 (impossible without a server).
class ClinicianViewScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const ClinicianViewScreen({required this.directiveId, super.key});

  @override
  ConsumerState<ClinicianViewScreen> createState() =>
      _ClinicianViewScreenState();
}

class _ClinicianViewScreenState extends ConsumerState<ClinicianViewScreen> {
  Directive? _directive;
  List<Agent> _agents = const [];
  DirectivePref? _prefs;
  List<MedicationEntry> _meds = const [];
  List<DirectiveAllergy> _allergies = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(directiveRepositoryProvider);
    final d = await repo.getDirectiveById(widget.directiveId);
    final a = await repo.getAgents(widget.directiveId);
    final pr = await repo.getPreferences(widget.directiveId);
    final m = await repo.watchMedications(widget.directiveId).first;
    final al = await repo.getAllergies(widget.directiveId);
    if (!mounted) return;
    setState(() {
      _directive = d;
      _agents = a;
      _prefs = pr;
      _meds = m;
      _allergies = al;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final d = _directive;
    if (d == null) {
      return Scaffold(
        backgroundColor: p.scaffoldBackground,
        appBar: AppBar(title: const Text('Clinician view')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final primaryAgent =
        _agents.where((a) => a.agentType == 'primary').firstOrNull;
    final altAgent =
        _agents.where((a) => a.agentType == 'alternate').firstOrNull;

    final exceptions =
        _meds.where((m) => m.entryType == 'exception').toList();
    final preferred =
        _meds.where((m) => m.entryType == 'preferred').toList();
    final severeAllergies =
        _allergies.where((a) => a.severity == 'severe').toList();

    final dateFmt = DateFormat('MMM d, y');
    final signedStr = d.expirationDate != null
        ? dateFmt.format(DateTime.fromMillisecondsSinceEpoch(d.expirationDate!)
            .subtract(const Duration(days: 365 * 2)))
        : '—';
    final validThrough = d.expirationDate != null
        ? dateFmt.format(DateTime.fromMillisecondsSinceEpoch(d.expirationDate!))
        : '—';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: p.primaryDark,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Clinician view · read-only'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Header — dark band identifying directive holder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.primaryDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('30-SECOND SUMMARY',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace'
                      ],
                      fontSize: 10.5,
                      letterSpacing: 1,
                      color: Theme.of(context).colorScheme.onPrimary
                          .withValues(alpha: 0.75),
                    )),
                const SizedBox(height: 4),
                Text(
                  d.fullName.isEmpty ? '(holder name)' : d.fullName,
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontFamilyFallback: const [
                      'Georgia',
                      'Times New Roman',
                      'serif'
                    ],
                    fontStyle: FontStyle.italic,
                    fontSize: 28,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                if (d.dateOfBirth.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('DOB ${d.dateOfBirth}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.onPrimary
                            .withValues(alpha: 0.85),
                      )),
                ],
                const SizedBox(height: 6),
                Text(
                  'PA MHAD · signed $signedStr · valid through $validThrough',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.onPrimary
                        .withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // DO NOT
          _SeverityBlock(
            title: 'DO NOT',
            icon: Icons.cancel_outlined,
            tint: _SeverityTint.crisis,
            items: [
              for (final m in exceptions)
                _Line('${m.medicationName}${m.reason.isEmpty ? "" : " — ${m.reason}"}'),
              for (final a in severeAllergies)
                _Line('${a.substance}${a.reactions.isEmpty ? "" : " — ${a.reactions}"} '
                    '[SEVERE allergy]'),
              if (_prefs?.ectConsent == 'no')
                const _Line('Electroconvulsive therapy (ECT) — refused'),
              if (_prefs?.experimentalConsent == 'no')
                const _Line('Experimental studies — refused'),
              if (_prefs?.drugTrialConsent == 'no')
                const _Line('Drug trials — refused'),
              const _Line('Psychosurgery — never authorized (20 Pa.C.S. § 5804)'),
              const _Line('Termination of parental rights — never authorized'),
            ],
          ),

          const SizedBox(height: 10),

          // PREFERS
          _SeverityBlock(
            title: 'PREFERS',
            icon: Icons.check_circle_outline,
            tint: _SeverityTint.ok,
            items: [
              for (final m in preferred)
                _Line('${m.medicationName}${m.reason.isEmpty ? "" : " — ${m.reason}"}'),
              if (_prefs != null && _prefs!.preferredFacilityName.isNotEmpty)
                _Line('Facility: ${_prefs!.preferredFacilityName.split('\n').first}'),
            ],
          ),

          const SizedBox(height: 10),

          // WHO TO CALL · IN ORDER
          _SeverityBlock(
            title: 'WHO TO CALL · IN ORDER',
            icon: Icons.people_alt_outlined,
            tint: _SeverityTint.primary,
            items: [
              if (primaryAgent != null)
                _Line('1. ${primaryAgent.fullName} '
                    '(${primaryAgent.relationship.isEmpty ? "primary agent" : "${primaryAgent.relationship}, primary agent"})'
                    '${primaryAgent.cellPhone.isEmpty ? "" : " · ${primaryAgent.cellPhone}"}'),
              if (altAgent != null)
                _Line('2. ${altAgent.fullName} '
                    '(${altAgent.relationship.isEmpty ? "alternate" : "${altAgent.relationship}, alternate"})'
                    '${altAgent.cellPhone.isEmpty ? "" : " · ${altAgent.cellPhone}"}'),
              if (d.preferredDoctorName.isNotEmpty)
                _Line('3. ${d.preferredDoctorName} '
                    '(treating clinician)'
                    '${d.preferredDoctorContact.isEmpty ? "" : " · ${d.preferredDoctorContact}"}'),
              if (primaryAgent == null && altAgent == null &&
                  d.preferredDoctorName.isEmpty)
                const _Line('No contacts on file. Defer to next of kin or '
                    'standard hospital protocol.'),
            ],
          ),

          const SizedBox(height: 14),
          const SectionLabel('Source'),
          const SizedBox(height: 4),
          Text(
            'Generated from the principal\'s on-device directive under '
            'PA Act 194 (20 Pa.C.S. Ch. 58). Full text available via '
            'Export → PDF.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

enum _SeverityTint { crisis, ok, primary }

class _Line {
  final String text;
  const _Line(this.text);
}

class _SeverityBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final _SeverityTint tint;
  final List<_Line> items;
  const _SeverityBlock({
    required this.title,
    required this.icon,
    required this.tint,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final (bg, border, fg) = switch (tint) {
      _SeverityTint.crisis => (
          dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight,
          dark
              ? SemanticColors.errorBorderDark
              : SemanticColors.errorBorderLight,
          dark
              ? SemanticColors.errorAccentDark
              : SemanticColors.errorAccentLight,
        ),
      _SeverityTint.ok => (
          dark ? SemanticColors.successBgDark : SemanticColors.successBgLight,
          dark
              ? SemanticColors.successBorderDark
              : SemanticColors.successBorderLight,
          dark
              ? SemanticColors.successTextDark
              : SemanticColors.successTextLight,
        ),
      _SeverityTint.primary => (cs.surface, cs.primary, cs.primary),
    };

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace'
                    ],
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: fg,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text('(none on file)',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: cs.onSurfaceVariant,
                ))
          else
            for (final line in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration:
                            BoxDecoration(color: fg, shape: BoxShape.circle),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line.text,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
