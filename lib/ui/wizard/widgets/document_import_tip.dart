import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'document_import_tip_dismissed';

/// A one-time dismissible tip card that tells users they can import
/// data from medical documents. Shows only on the first wizard step
/// and disappears permanently once dismissed.
class DocumentImportTip extends StatefulWidget {
  const DocumentImportTip({super.key});

  @override
  State<DocumentImportTip> createState() => _DocumentImportTipState();
}

class _DocumentImportTipState extends State<DocumentImportTip>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _checkIfShouldShow();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkIfShouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(_prefKey) ?? false;
    if (!dismissed && mounted) {
      setState(() => _visible = true);
      _animCtrl.forward();
    }
  }

  Future<void> _dismiss() async {
    await _animCtrl.reverse();
    if (mounted) setState(() => _visible = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SizeTransition(
        sizeFactor: _fadeAnim,
        axisAlignment: -1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Card(
            color: cs.primaryContainer,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 22, color: cs.onPrimaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save time filling out your directive',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: cs.onPrimaryContainer,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap the sparkle icon to use Smart Fill — select your '
                          'conditions and medications, and AI fills the rest. '
                          'Or tap the scan icon to import from a document.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onPrimaryContainer,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: cs.onPrimaryContainer),
                    tooltip: 'Dismiss',
                    onPressed: _dismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
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
