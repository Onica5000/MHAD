import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// A persistent, collapsible crisis resources banner shown on every screen.
///
/// Collapsed: a thin tappable strip reading "Need help now? Tap for crisis
/// resources". Expanded: shows 988 Suicide & Crisis Lifeline, Crisis Text
/// Line, and SAMHSA Helpline with one-tap call/text buttons.
class CrisisResourcesBanner extends StatefulWidget {
  const CrisisResourcesBanner({super.key});

  @override
  State<CrisisResourcesBanner> createState() => _CrisisResourcesBannerState();
}

class _CrisisResourcesBannerState extends State<CrisisResourcesBanner> {
  bool _expanded = false;

  Future<void> _launch(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Call a phone number on mobile, or copy it to clipboard on desktop/web.
  Future<void> _callOrCopy(String phone) async {
    if (platformIsMobile) {
      _launch('tel:$phone');
    } else {
      await Clipboard.setData(ClipboardData(text: phone));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$phone copied to clipboard')),
        );
      }
    }
  }

  /// Send SMS on mobile, or copy number to clipboard on desktop/web.
  Future<void> _textOrCopy(String phone, String body) async {
    if (platformIsMobile) {
      _launch('sms:$phone?body=$body');
    } else {
      await Clipboard.setData(ClipboardData(text: phone));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$phone copied — text "$body" to this number')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: _expanded ? cs.errorContainer : cs.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Collapsed / toggle bar ---
              Semantics(
                button: true,
                label: _expanded
                    ? 'Collapse crisis resources'
                    : 'Expand crisis resources',
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 48),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            Icons.phone_in_talk,
                            size: 16,
                            color: _expanded
                                ? cs.onErrorContainer
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _expanded
                                ? 'Crisis Resources'
                                : 'Need help now? Tap for crisis resources',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _expanded
                                  ? cs.onErrorContainer
                                  : cs.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        ExcludeSemantics(
                          child: Icon(
                            _expanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            size: 18,
                            color: _expanded
                                ? cs.onErrorContainer
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Expanded content ---
              if (_expanded) ...[
                const Divider(height: 1),
                _CrisisResourceTile(
                  icon: Icons.call,
                  title: '988 Suicide & Crisis Lifeline',
                  subtitle: 'Call or text 988',
                  actionLabel: platformIsMobile ? 'Call' : 'Copy',
                  onAction: () => _callOrCopy(crisis988Phone),
                  secondaryActionLabel: platformIsMobile ? 'Text' : null,
                  onSecondaryAction: platformIsMobile
                      ? () => _textOrCopy(crisis988Phone, 'HELLO')
                      : null,
                  foreground: cs.onErrorContainer,
                ),
                _CrisisResourceTile(
                  icon: Icons.sms,
                  title: 'Crisis Text Line',
                  subtitle: 'Text HOME to $crisisTextLine',
                  actionLabel: platformIsMobile ? 'Text' : 'Copy',
                  onAction: platformIsMobile
                      ? () => _textOrCopy(crisisTextLine, 'HOME')
                      : () => _callOrCopy(crisisTextLine),
                  foreground: cs.onErrorContainer,
                ),
                _CrisisResourceTile(
                  icon: Icons.call,
                  title: 'SAMHSA Helpline',
                  subtitle: '1-800-662-4357',
                  actionLabel: platformIsMobile ? 'Call' : 'Copy',
                  onAction: () => _callOrCopy(samhsaHelpline),
                  foreground: cs.onErrorContainer,
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A single crisis-resource row with an icon, title/subtitle, and one or two
/// action buttons that meet the 48x48 minimum touch-target requirement.
class _CrisisResourceTile extends StatelessWidget {
  const _CrisisResourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.foreground,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final Color foreground;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(icon, color: foreground, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: foreground.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Primary action button (min 48x48 touch target)
          Semantics(
            button: true,
            label: '$actionLabel $title',
            child: SizedBox(
              width: 64,
              height: 48,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: foreground,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          // Optional secondary action button
          if (secondaryActionLabel != null && onSecondaryAction != null)
            Semantics(
              button: true,
              label: '$secondaryActionLabel $title',
              child: SizedBox(
                width: 56,
                height: 48,
                child: TextButton(
                  onPressed: onSecondaryAction,
                  style: TextButton.styleFrom(
                    foregroundColor: foreground,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(secondaryActionLabel!,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
