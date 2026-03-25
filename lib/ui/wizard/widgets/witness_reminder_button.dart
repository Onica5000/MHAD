import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/notification_service.dart';

/// A button that helps the user schedule a reminder to arrange
/// witness signing. PA Act 194 requires two adult witnesses.
/// Only shown in private mode (reminders are useless if data doesn't persist).
class WitnessReminderButton extends ConsumerWidget {
  const WitnessReminderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privacyModeNotifierProvider).isPrivate;
    if (!isPrivate) return const SizedBox.shrink();

    return OutlinedButton.icon(
      onPressed: () => _showScheduleDialog(context),
      icon: const Icon(Icons.event, size: 18),
      label: const Text('Schedule Witness Signing'),
    );
  }

  Future<void> _showScheduleDialog(BuildContext context) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pick a date to sign with your witnesses',
    );
    if (picked == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
      helpText: 'What time?',
    );
    if (time == null || !context.mounted) return;

    final scheduled = DateTime(
      picked.year,
      picked.month,
      picked.day,
      time.hour,
      time.minute,
    );

    try {
      await NotificationService.instance.scheduleWitnessReminder(scheduled);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Reminder set for ${_formatDate(scheduled)}. '
                'You\'ll need two adult witnesses present to sign.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Could not set reminder. Notifications may not be '
              'available on this device.')),
        );
      }
    }
  }

  String _formatDate(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final h = d.hour % 12;
    final hour = h == 0 ? 12 : h;
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '$month/$day/${d.year} at $hour:$min $amPm';
  }
}
