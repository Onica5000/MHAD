import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Primary-filled "Snap to fill" launcher placed at the top of relevant
/// wizard steps. Mirrors prototype `SmartFillCard` (mobile.jsx::480-583).
///
/// Replaces the previous wizard-overflow-menu entries for Smart Fill and
/// Document Import — the prototype has no overflow menu, so those two
/// destinations move onto this card per the prototype's `ScrWizardAbout`
/// L599 layout (SmartFillCard, then "OR BY HAND" divider, then fields).
///
/// Four tiles in a 2×2 grid, each calling the same `onPickTarget` callback
/// with a [SmartFillTarget] enum so the caller can route to the right
/// document-pipeline flow. The card itself stays UI-only.
class SmartFillCard extends StatelessWidget {
  /// Fires when the user taps a tile. The caller routes to the relevant
  /// snap-to-fill / document-pipeline screen using the picked target.
  final ValueChanged<SmartFillTarget> onPickTarget;

  /// Set of targets the user has already filled. These render in the
  /// prototype's "done" visual (lighter fill + check icon + "Filled · tap
  /// to review" caption). Pass an empty set to render every tile in the
  /// default unfilled state.
  final Set<SmartFillTarget> doneTargets;

  const SmartFillCard({
    required this.onPickTarget,
    this.doneTargets = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      decoration: BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(DesignTokens.cardRadius - 0.5),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative italic-serif "AI" numeral (130pt at 10% opacity)
            // pinned top-right, matches the prototype's watermark trick
            // used on the active-directive hero and the empty-state card.
            Positioned(
              right: -8,
              top: -28,
              child: ExcludeSemantics(
                child: Text(
                  'AI',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontFamilyFallback: const ['Georgia', 'serif'],
                    fontStyle: FontStyle.italic,
                    fontSize: 130,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    color: p.onPrimary.withValues(alpha: 0.10),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 14, color: p.onPrimary),
                    const SizedBox(width: 6),
                    Text(
                      'SNAP TO FILL · AI-ASSISTED',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontFamilyFallback: const [
                          'Consolas',
                          'Menlo',
                          'Courier New',
                          'monospace',
                        ],
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: p.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Snap a photo. We'll read it and fill the wizard.",
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontFamilyFallback: const ['Georgia', 'serif'],
                    fontStyle: FontStyle.italic,
                    fontSize: 25,
                    height: 1.05,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.5,
                    color: p.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pick what you have on hand. AI extracts the details — '
                  'you review and edit before anything is locked in.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    height: 1.45,
                    color: p.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 14),
                // 2×2 grid of capture targets.
                Row(
                  children: [
                    Expanded(
                      child: _SmartFillTile(
                        icon: Icons.badge_outlined,
                        label: 'Photo of ID',
                        fills: 'Name · DOB · address',
                        recommended: true,
                        done: doneTargets.contains(SmartFillTarget.id),
                        onTap: () => onPickTarget(SmartFillTarget.id),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SmartFillTile(
                        icon: Icons.medication_outlined,
                        label: 'Rx bottle / label',
                        fills: 'Drug · dose · frequency',
                        done: doneTargets.contains(SmartFillTarget.rx),
                        onTap: () => onPickTarget(SmartFillTarget.rx),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SmartFillTile(
                        icon: Icons.health_and_safety_outlined,
                        label: 'Conditions list',
                        fills: 'Diagnoses · allergies',
                        done: doneTargets
                            .contains(SmartFillTarget.conditions),
                        onTap: () =>
                            onPickTarget(SmartFillTarget.conditions),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SmartFillTile(
                        icon: Icons.description_outlined,
                        label: 'Anything else',
                        fills: 'Old directive, notes…',
                        done:
                            doneTargets.contains(SmartFillTarget.other),
                        onTap: () => onPickTarget(SmartFillTarget.other),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 11, color: p.onPrimary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your photo is sent to our AI to read it, then '
                        'discarded · nothing is saved.',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10.5,
                          height: 1.4,
                          color: p.onPrimary.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The four capture targets the prototype's SmartFillCard offers. Each
/// maps to a distinct AI extraction prompt; the caller decides whether to
/// dispatch them to different pipelines or share one with a target hint.
enum SmartFillTarget { id, rx, conditions, other }

class _SmartFillTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String fills;
  final bool recommended;
  final bool done;
  final VoidCallback onTap;

  const _SmartFillTile({
    required this.icon,
    required this.label,
    required this.fills,
    required this.onTap,
    this.recommended = false,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final onPrimary = p.onPrimary;
    final bg = onPrimary.withValues(alpha: done ? 0.16 : 0.08);
    final border = onPrimary.withValues(alpha: done ? 0.4 : 0.18);
    final iconBg = done
        ? Colors.white
        : onPrimary.withValues(alpha: 0.18);
    final iconFg = done ? p.primaryDark : onPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(9, 10, 9, 11),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      done ? Icons.check : icon,
                      size: 15,
                      color: iconFg,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    done ? 'Filled · tap to review' : fills,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 10,
                      letterSpacing: 0.3,
                      height: 1.3,
                      color: onPrimary.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            if (recommended && !done)
              Positioned(
                right: 6,
                top: -7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'START HERE',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: p.primaryDark,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
