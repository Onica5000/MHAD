import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/spot_illustration.dart';

/// A screen intro (section label + heading + lead text) with a decorative
/// [SpotIllustration] beside it.
///
/// Placement rules, so art never crowds a form:
/// - Only used in read/overview intros, never next to inputs.
/// - Wide (≥ [wideBreakpoint]): the art sits to the right of the whole intro,
///   vertically centred, at [wideSize].
/// - Narrow (phones): the art sits to the right of the short section label
///   only, at [narrowSize], so the heading and lead text keep the full width.
class IllustratedIntro extends StatelessWidget {
  final SpotArt art;
  final Widget label;

  /// Heading + lead text (and anything else that belongs to the intro).
  final Widget body;
  final double wideSize;
  final double narrowSize;
  final double wideBreakpoint;

  const IllustratedIntro({
    required this.art,
    required this.label,
    required this.body,
    this.wideSize = 112,
    this.narrowSize = 56,
    this.wideBreakpoint = 560,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      if (box.maxWidth >= wideBreakpoint) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [label, const SizedBox(height: 6), body],
              ),
            ),
            const SizedBox(width: 24),
            SpotIllustration(art: art, size: wideSize),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: label),
              const SizedBox(width: 12),
              SpotIllustration(art: art, size: narrowSize),
            ],
          ),
          const SizedBox(height: 6),
          body,
        ],
      );
    });
  }
}
