import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/services/screenshot_protection_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/utils/platform_utils.dart';

/// Central settings hub — consolidates AI setup, privacy policy,
/// screenshot protection, and app info.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI Setup
          Card(
            child: ListTile(
              leading: Icon(Icons.auto_awesome, color: cs.primary),
              title: const Text('AI Assistant Setup'),
              subtitle: const Text('Configure your free Gemini API key'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.aiSetup),
            ),
          ),
          const SizedBox(height: 8),

          // Privacy Policy
          Card(
            child: ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: cs.primary),
              title: const Text('Privacy Policy'),
              subtitle: const Text('How your data is stored and protected'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.privacyPolicy),
            ),
          ),
          const SizedBox(height: 8),

          // Screenshot Protection (Android only)
          if (platformIsAndroid && !kIsWeb)
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  ScreenshotProtectionService.isEnabled
                      ? Icons.screen_lock_portrait
                      : Icons.screenshot_outlined,
                  color: cs.primary,
                ),
                title: const Text('Screenshot Protection'),
                subtitle: Text(ScreenshotProtectionService.isEnabled
                    ? 'Screenshots are blocked'
                    : 'Screenshots are allowed'),
                value: ScreenshotProtectionService.isEnabled,
                onChanged: (_) async {
                  await ScreenshotProtectionService.toggle();
                  setState(() {});
                },
              ),
            ),
          if (platformIsAndroid && !kIsWeb) const SizedBox(height: 8),

          // Education / Learn More
          Card(
            child: ListTile(
              leading: Icon(Icons.school_outlined, color: cs.primary),
              title: const Text('Education & Resources'),
              subtitle: const Text('FAQ, glossary, and legal information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.education),
            ),
          ),
          const SizedBox(height: 24),

          // About
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    'PA Mental Health Advance Directive\n'
                    'Under Pennsylvania Act 194 of 2004\n\n'
                    'This app helps you document your mental health treatment '
                    'preferences. It is not a substitute for legal advice.\n\n'
                    'Form content based on the official PA MHAD booklet '
                    'published by the Disabilities Law Project (2005).',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
