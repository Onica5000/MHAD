import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Card linking to PA mental health provider resources.
class ProviderResourcesCard extends StatelessWidget {
  const ProviderResourcesCard({super.key});

  static const _resources = [
    _Resource(
      title: 'PA Protection & Advocacy',
      subtitle: 'Free help with advance directives',
      url: 'https://www.disabilityrightspa.org',
      phone: '1-800-692-7443',
    ),
    _Resource(
      title: 'SAMHSA Treatment Locator',
      subtitle: 'Find mental health providers near you',
      url: 'https://findtreatment.samhsa.gov',
    ),
    _Resource(
      title: 'National Resource Center on PADs',
      subtitle: 'Information and state-specific PAD resources',
      url: 'https://nrc-pad.org',
    ),
    _Resource(
      title: '988 Suicide & Crisis Lifeline',
      subtitle: '24/7 crisis support',
      phone: '988',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: cs.primary),
                const SizedBox(width: 8),
                Text('Provider & Support Resources',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            ..._resources.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _launch(r, context),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: cs.primary)),
                                Text(r.subtitle,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          if (r.phone != null)
                            Icon(Icons.phone, size: 16, color: cs.primary),
                          if (r.url != null) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.open_in_new,
                                size: 16, color: cs.primary),
                          ],
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(_Resource r, BuildContext context) async {
    // On mobile, prefer phone dialer. On desktop/web, prefer URL or copy.
    if (r.phone != null && platformIsMobile) {
      final uri = Uri(scheme: 'tel', path: r.phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (r.url != null) {
      final uri = Uri.parse(r.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Fallback: copy phone number to clipboard on desktop/web
    if (r.phone != null && !platformIsMobile) {
      await Clipboard.setData(ClipboardData(text: r.phone!));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${r.phone} copied to clipboard')),
        );
      }
    }
  }
}

class _Resource {
  final String title;
  final String subtitle;
  final String? url;
  final String? phone;
  const _Resource({
    required this.title,
    required this.subtitle,
    this.url,
    this.phone,
  });
}
