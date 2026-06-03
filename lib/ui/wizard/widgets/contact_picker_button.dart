import 'package:flutter/material.dart';
import 'package:mhad/ui/wizard/widgets/contact_picker_sheet.dart';
import 'package:mhad/utils/platform_utils.dart';

/// Data extracted from a picked phone contact.
class PickedContactData {
  final String fullName;
  final String address;
  final String homePhone;
  final String workPhone;
  final String cellPhone;

  const PickedContactData({
    this.fullName = '',
    this.address = '',
    this.homePhone = '',
    this.workPhone = '',
    this.cellPhone = '',
  });
}

/// A button that opens the editorial in-app contact picker sheet and
/// returns structured contact data for agent / witness / guardian fields.
///
/// Inner behavior changed (2026-06-03): the button now opens the
/// `showContactPickerSheet` editorial bottom sheet (see prototype
/// `ScrContactPicker`, mobile-extra.jsx L2327-2470) instead of the
/// OS-native `FlutterContacts.native.showPicker()`. The sheet adds the
/// prototype's eligibility heuristics (PA Act 194 § 5822 disqualifiers —
/// under 18 is a hard block, provider-looking names get a soft warn).
/// Function preserved: the button still says "Import from Contacts",
/// still produces a `PickedContactData` on success, still surfaces a
/// snackbar when fields are missing, and still no-ops on non-mobile.
class ContactPickerButton extends StatelessWidget {
  final void Function(PickedContactData data) onContactPicked;

  const ContactPickerButton({required this.onContactPicked, super.key});

  Future<void> _pick(BuildContext context) async {
    final data = await showContactPickerSheet(context);
    if (data == null) return;

    // Warn if key fields are missing — same heuristic the old native-picker
    // path used. The editorial sheet's "Enter someone manually" tile pops
    // an empty PickedContactData; in that case all fields are empty and
    // we don't warn (the user explicitly chose manual entry).
    final missing = <String>[];
    if (data.fullName.isEmpty) missing.add('name');
    if (data.address.isEmpty) missing.add('address');
    if (data.homePhone.isEmpty &&
        data.workPhone.isEmpty &&
        data.cellPhone.isEmpty) {
      missing.add('phone number');
    }
    final isManualEntry = data.fullName.isEmpty &&
        data.address.isEmpty &&
        data.homePhone.isEmpty &&
        data.workPhone.isEmpty &&
        data.cellPhone.isEmpty;
    if (missing.isNotEmpty && !isManualEntry && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Contact is missing: ${missing.join(", ")}. '
              'Please fill in the missing fields manually.'),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    onContactPicked(data);
  }

  @override
  Widget build(BuildContext context) {
    // Contact picker is only available on mobile (Android/iOS)
    if (!platformIsMobile) return const SizedBox.shrink();

    return Semantics(
      button: true,
      label: 'Import from contacts',
      child: OutlinedButton.icon(
        onPressed: () => _pick(context),
        icon: const Icon(Icons.contacts, size: 18),
        label: const Text('Import from Contacts'),
      ),
    );
  }
}
