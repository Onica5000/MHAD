import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:ndef_record/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

/// Button that writes a directive summary to an NFC tag.
/// Uses platform-specific NDEF write APIs for Android and iOS.
class NfcWriteButton extends StatefulWidget {
  final String principalName;
  final String formType;
  final String? executionDate;
  final String? agentName;
  final String? agentPhone;

  const NfcWriteButton({
    required this.principalName,
    required this.formType,
    this.executionDate,
    this.agentName,
    this.agentPhone,
    super.key,
  });

  @override
  State<NfcWriteButton> createState() => _NfcWriteButtonState();
}

class _NfcWriteButtonState extends State<NfcWriteButton> {
  bool _writing = false;
  bool _dialogOpen = false;

  NdefMessage get _message {
    final payload = jsonEncode({
      'type': 'PA_MHAD',
      'principal': widget.principalName,
      'formType': widget.formType,
      if (widget.executionDate != null) 'executed': widget.executionDate,
      if (widget.agentName != null) 'agent': widget.agentName,
      if (widget.agentPhone != null) 'agentPhone': widget.agentPhone,
      'note':
          'This person has a PA Mental Health Advance Directive on file.',
    });

    // Create a well-known text record
    final languageCode = 'en';
    final textBytes = utf8.encode(payload);
    final langBytes = ascii.encode(languageCode);
    // TNF=1 (well-known), type="T" (text), payload = status byte + lang + text
    final recordPayload = Uint8List.fromList([
      langBytes.length, // status byte: UTF-8, language code length
      ...langBytes,
      ...textBytes,
    ]);

    return NdefMessage(records: [
      NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList(utf8.encode('T')),
        identifier: Uint8List(0),
        payload: recordPayload,
      ),
    ]);
  }

  Future<void> _write() async {
    if (!platformIsAndroid && !platformIsIOS) {
      _showSnack('NFC writing is only available on Android and iOS.');
      return;
    }

    final availability = await NfcManager.instance.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      _showSnack(availability == NfcAvailability.disabled
          ? 'NFC is disabled. Enable it in device settings.'
          : 'NFC is not supported on this device.');
      return;
    }

    setState(() => _writing = true);
    _showScanDialog();

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        onDiscovered: (tag) async {
          try {
            if (platformIsAndroid) {
              await _writeAndroid(tag);
            } else if (platformIsIOS) {
              await _writeIos(tag);
            }
            await NfcManager.instance.stopSession();
            _closeScanDialog();
            _showSnack('NFC tag written. Attach it to your wallet card or ID badge.');
          } catch (e) {
            await NfcManager.instance.stopSession();
            _closeScanDialog();
            _showSnack('Write failed: $e');
          }
          if (mounted) setState(() => _writing = false);
        },
      );
    } catch (e) {
      _closeScanDialog();
      if (mounted) setState(() => _writing = false);
      _showSnack('NFC error: $e');
    }
  }

  Future<void> _writeAndroid(NfcTag tag) async {
    final ndef = NdefAndroid.from(tag);
    if (ndef == null) throw Exception('Tag does not support NDEF.');
    if (!ndef.isWritable) throw Exception('Tag is not writable.');
    await ndef.writeNdefMessage(_message);
  }

  Future<void> _writeIos(NfcTag tag) async {
    final ndef = NdefIos.from(tag);
    if (ndef == null) throw Exception('Tag does not support NDEF.');
    if (ndef.status != NdefStatusIos.readWrite) {
      throw Exception('Tag is read-only.');
    }
    await ndef.writeNdef(_message);
  }

  void _showScanDialog() {
    _dialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Tap NFC Tag'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Hold your phone near a blank NFC tag or sticker...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              NfcManager.instance.stopSession();
              Navigator.pop(ctx);
              _dialogOpen = false;
              if (mounted) setState(() => _writing = false);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _closeScanDialog() {
    if (_dialogOpen && mounted) {
      Navigator.of(context).pop();
      _dialogOpen = false;
    }
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Write directive summary to NFC tag',
      child: OutlinedButton.icon(
        onPressed: _writing ? null : _write,
        icon: const Icon(Icons.nfc),
        label: const Text('Write to NFC Tag'),
      ),
    );
  }
}
