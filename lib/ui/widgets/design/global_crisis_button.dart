import 'package:flutter/material.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';

/// The app's single, always-visible crisis affordance. Floats at the
/// bottom-right over EVERY screen (rendered once in MhadApp's builder, above the
/// router). Tapping opens the full crisis-resources sheet. This replaces the
/// many scattered CrisisTopBar / Crisis988Pill instances — one central,
/// prominent, always-reachable button.
///
/// Returns a [Positioned], so it must be placed directly inside a [Stack].
class GlobalCrisisButton extends StatelessWidget {
  const GlobalCrisisButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark
        ? SemanticColors.errorAccentDark
        : SemanticColors.errorAccentLight;
    final wide = MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Positioned(
      right: 16,
      // On narrow screens lift it clear of the floating mobile bottom nav.
      bottom: (wide ? 20.0 : 84.0) + bottomInset,
      child: Semantics(
        button: true,
        label: 'Crisis help — call or text 988',
        child: Material(
          color: bg,
          elevation: 6,
          borderRadius: BorderRadius.circular(26),
          shadowColor: Colors.black.withValues(alpha: 0.30),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: () {
              final ctx = rootNavigatorKey.currentContext;
              if (ctx != null) showCrisisSheet(ctx);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.health_and_safety, size: 22, color: Colors.white),
                  SizedBox(width: 9),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crisis help',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        'Call or text 988',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'DM Sans',
                          fontSize: 10.5,
                          height: 1.15,
                        ),
                      ),
                    ],
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
