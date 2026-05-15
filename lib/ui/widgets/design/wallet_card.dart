import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Wallet-card preview rendered in the primary→primaryDark gradient. Used on
/// the wizard-complete screen and in Export. Carries a decorative serif
/// monogram on the right.
class WalletCard extends StatelessWidget {
  final String principalName;
  final String? agentName;
  final String? agentPhone;
  final String validThrough; // e.g. "05 · 2028"
  final String qrPayload;
  final double radius;

  const WalletCard({
    required this.principalName,
    required this.validThrough,
    required this.qrPayload,
    this.agentName,
    this.agentPhone,
    this.radius = 14,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [p.primary, p.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative serif monogram
            Positioned(
              right: -20,
              top: -30,
              child: IgnorePointer(
                child: Text(
                  'MH',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontFamilyFallback: const [
                      'Georgia',
                      'Times New Roman',
                      'serif'
                    ],
                    fontStyle: FontStyle.italic,
                    fontSize: 140,
                    height: 1,
                    color: p.onPrimary.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PA MHAD · ACT 194',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontFamilyFallback: const [
                                  'Consolas',
                                  'Menlo',
                                  'Courier New',
                                  'monospace'
                                ],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                                color: p.onPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              principalName,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: p.onPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Has an active directive on file',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11.5,
                                color: p.onPrimary.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data: qrPayload,
                          version: QrVersions.auto,
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.white,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: p.primaryDark,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: p.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _walletKeyValue(
                          context,
                          label: 'AGENT',
                          value: agentName == null
                              ? '—'
                              : agentPhone == null
                                  ? agentName!
                                  : '$agentName · $agentPhone',
                          color: p.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _walletKeyValue(
                        context,
                        label: 'EXP',
                        value: validThrough,
                        align: CrossAxisAlignment.end,
                        color: p.onPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletKeyValue(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontFamilyFallback: const [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace'
            ],
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: color.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: align == CrossAxisAlignment.end
              ? TextAlign.end
              : TextAlign.start,
        ),
      ],
    );
  }
}
