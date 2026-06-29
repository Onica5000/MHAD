import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';

/// Home tools grid — a 2×2 of icon tiles linking to the destinations users hit
/// most often (AI assistant, Learn, "Make it findable" crisis-readiness for the
/// most-recent directive, and the crisis sheet).
class ToolsGrid extends ConsumerWidget {
  const ToolsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final aiReady =
        ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;
    final directivesAsync = ref.watch(allDirectivesProvider);
    final mostRecentDirective = directivesAsync.maybeWhen(
      data: (ds) {
        if (ds.isEmpty) return null;
        final sorted = [...ds]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return sorted.first;
      },
      orElse: () => null,
    );

    final tiles = <_ToolTile>[
      _ToolTile(
        icon: Icons.auto_awesome,
        label: 'AI assistant',
        sub: aiReady ? 'Suggests + checks' : 'Set up AI',
        onTap: () => context.go(
          aiReady ? AppRoutes.assistant : AppRoutes.aiSetup,
        ),
      ),
      _ToolTile(
        icon: Icons.menu_book_outlined,
        label: 'Learn',
        sub: 'FAQ, glossary',
        onTap: () => context.go(AppRoutes.education),
      ),
      _ToolTile(
        icon: Icons.health_and_safety_outlined,
        label: 'Make it findable',
        sub: mostRecentDirective != null
            ? 'Share + carry'
            : 'No directive yet',
        onTap: mostRecentDirective != null
            ? () => context.push(
                AppRoutes.findableRoute(mostRecentDirective.id))
            : null,
      ),
      _ToolTile(
        icon: Icons.favorite_outline,
        label: 'Crisis help',
        sub: '988 + more',
        onTap: () => showCrisisSheet(context),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tiles
              .map((t) => SizedBox(
                    width: colWidth,
                    child: _ToolTileCard(tile: t, palette: p),
                  ))
              .toList(growable: false),
        );
      },
    );
  }
}

class _ToolTile {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback? onTap;
  const _ToolTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });
}

class _ToolTileCard extends StatelessWidget {
  final _ToolTile tile;
  final MhadPalette palette;
  const _ToolTileCard({required this.tile, required this.palette});

  @override
  Widget build(BuildContext context) {
    final disabled = tile.onTap == null;
    return Semantics(
      button: true,
      enabled: !disabled,
      label: '${tile.label} — ${tile.sub}',
      child: HoverLift(
        enabled: !disabled,
        radius: 12,
        child: Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: tile.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: palette.primaryTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(tile.icon,
                      size: 18,
                      color: disabled
                          ? palette.textMuted
                          : palette.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  tile.label,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: palette.text,
                  ),
                ),
                Text(
                  tile.sub,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 11.5,
                    color: palette.textMuted,
                  ),
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
