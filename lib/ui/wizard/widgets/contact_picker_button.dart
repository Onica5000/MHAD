import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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

/// A button that opens the device contact picker and returns
/// structured contact data for agent / witness / guardian fields.
class ContactPickerButton extends StatelessWidget {
  final void Function(PickedContactData data) onContactPicked;

  const ContactPickerButton({required this.onContactPicked, super.key});

  Future<void> _pick(BuildContext context) async {
    // Request read permission
    final status =
        await FlutterContacts.permissions.request(PermissionType.read);
    if (status != PermissionStatus.granted &&
        status != PermissionStatus.limited) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Contact permission is required to import.')),
        );
      }
      return;
    }

    // Open native contact picker — returns the contact ID
    final contactId = await FlutterContacts.native.showPicker();
    if (contactId == null) return;

    // Re-fetch with phone + address properties
    final full = await FlutterContacts.get(contactId,
        properties: {ContactProperty.phone, ContactProperty.address});
    if (full == null) return;

    final name = full.displayName ?? '';

    // Build address from first available
    String address = '';
    if (full.addresses.isNotEmpty) {
      final a = full.addresses.first;
      final parts = [a.street, a.city, a.state, a.postalCode]
          .whereType<String>()
          .where((s) => s.isNotEmpty);
      address = parts.join(', ');
    }

    // Sort phones by label
    String home = '', work = '', cell = '';
    for (final p in full.phones) {
      final num = p.number;
      final lbl = p.label.label;
      switch (lbl) {
        case PhoneLabel.home:
          if (home.isEmpty) home = num;
        case PhoneLabel.work:
          if (work.isEmpty) work = num;
        case PhoneLabel.mobile:
          if (cell.isEmpty) cell = num;
        default:
          if (cell.isEmpty) {
            cell = num;
          } else if (home.isEmpty) {
            home = num;
          } else if (work.isEmpty) {
            work = num;
          }
      }
    }

    final data = PickedContactData(
      fullName: name,
      address: address,
      homePhone: home,
      workPhone: work,
      cellPhone: cell,
    );

    // Warn if key fields are missing
    final missing = <String>[];
    if (data.fullName.isEmpty) missing.add('name');
    if (data.address.isEmpty) missing.add('address');
    if (data.homePhone.isEmpty &&
        data.workPhone.isEmpty &&
        data.cellPhone.isEmpty) {
      missing.add('phone number');
    }
    if (missing.isNotEmpty && context.mounted) {
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
