import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/art_image.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';

/// Layout for the welcome screens (disclaimer, onboarding):
///
/// - **Desktop** (TOTAL window width >= [kWideLayoutBreakpoint] — the shell
///   signal, not this widget's box; review R15): a tall photo panel beside the
///   content, so the first screens fill the window instead of floating as a
///   narrow strip.
/// - **Phone**: a wide photo banner at the top of the content — placed by the
///   screen with [SplitHeroBanner] as the first item of its OWN scroll view,
///   so it scrolls away with the text instead of staying pinned (visual
///   review 2026-11-22). Skipped on very short windows.
///
/// [child] keeps its own layout, including any pinned footer. On desktop it
/// gets a TIGHT width of at most [contentMaxWidth] (the loose
/// Align+ConstrainedBox pattern collapsed `Row > Expanded` in release builds).
class SplitHero extends StatelessWidget {
  /// Desktop panel photo (2:3).
  final AppArt tallArt;

  /// Phone banner photo (16:9).
  final AppArt wideArt;
  final Widget child;
  final double contentMaxWidth;

  const SplitHero({
    required this.tallArt,
    required this.wideArt,
    required this.child,
    this.contentMaxWidth = 640,
    super.key,
  });

  /// Below this window height the phone banner is left out.
  static const double _bannerMinWindowHeight = 640;
  static const double _bannerHeight = 140;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width >= kWideLayoutBreakpoint) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space20),
              child: ArtImage(tallArt, expand: true, radius: DesignTokens.radiusLg),
            ),
          ),
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth < contentMaxWidth
                    ? box.maxWidth
                    : contentMaxWidth;
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(width: w, height: box.maxHeight, child: child),
                );
              },
            ),
          ),
        ],
      );
    }
    if (size.height < _bannerMinWindowHeight) return child;
    return _SplitHeroBannerScope(art: wideArt, child: child);
  }
}

class _SplitHeroBannerScope extends InheritedWidget {
  const _SplitHeroBannerScope({required this.art, required super.child});

  final AppArt art;

  @override
  bool updateShouldNotify(_SplitHeroBannerScope old) => old.art != art;
}

/// The phone photo banner of the enclosing [SplitHero] — put it first in the
/// screen's scrolling content. Nothing on desktop (the photo is the side
/// panel there) or on very short windows.
class SplitHeroBanner extends StatelessWidget {
  const SplitHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SplitHeroBannerScope>();
    if (scope == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.space16),
      child: ArtImage(
        scope.art,
        height: SplitHero._bannerHeight,
        expand: true,
        radius: DesignTokens.radiusLg,
      ),
    );
  }
}
