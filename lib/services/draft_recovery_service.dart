import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'draft_recovery_stub.dart'
    if (dart.library.io) 'draft_recovery_native.dart'
    if (dart.library.js_interop) 'draft_recovery_web.dart' as platform;

/// Manages crash-recovery drafts for wizard form data.
///
/// In public mode, the in-memory database is lost on crash. This service
/// writes a temporary JSON draft with a TTL so that if the app crashes,
/// the user can recover their non-PII work.
///
/// Privacy rules:
/// - NEVER stores PII (name, DOB, address, phone, SSN, email)
/// - Only stores medical/treatment preference data
/// - Draft files auto-delete after [ttl] (default 30 minutes)
/// - Draft files are deleted on successful wizard completion
class DraftRecoveryService {
  DraftRecoveryService._();

  static const ttl = Duration(minutes: 30);

  /// Fields that are safe to auto-save (non-PII).
  static const safeFields = {
    'effectiveCondition',
    'medications',
    'treatmentFacilityPref',
    'preferredFacilityName',
    'avoidFacilityName',
    'medicationConsent',
    'ectConsent',
    'experimentalConsent',
    'drugTrialConsent',
    'agentCanConsentHospitalization',
    'agentCanConsentMedication',
    'agentAuthorityLimitations',
    'activities',
    'crisisIntervention',
    'healthHistory',
    'dietary',
    'religious',
    'childrenCustody',
    'familyNotification',
    'recordsDisclosure',
    'petCustody',
    'other',
    'lastStepIndex',
    'formType',
  };

  /// PII fields that are NEVER saved to the draft.
  static const piiFields = {
    'fullName',
    'dateOfBirth',
    'address',
    'address2',
    'city',
    'state',
    'zip',
    'phone',
    'agentFullName',
    'agentAddress',
    'agentHomePhone',
    'agentWorkPhone',
    'agentCellPhone',
    'witnessFullName',
    'witnessAddress',
    'guardianFullName',
    'guardianAddress',
    'guardianPhone',
  };

  /// Save a draft of non-PII form data.
  static Future<void> saveDraft({
    required int directiveId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Filter out any PII that might have snuck in
      final safeData = <String, dynamic>{};
      for (final entry in data.entries) {
        if (!piiFields.contains(entry.key)) {
          safeData[entry.key] = entry.value;
        }
      }

      final draft = {
        'directiveId': directiveId,
        'timestamp': DateTime.now().toIso8601String(),
        'data': safeData,
      };

      await platform.saveDraftPlatform(jsonEncode(draft));
    } catch (e) {
      debugPrint('Draft save failed: $e');
    }
  }

  /// Check for a recoverable draft. Returns null if no valid draft exists
  /// or if the draft has expired.
  static Future<RecoverableDraft?> checkForDraft() async {
    try {
      final content = await platform.readDraftPlatform();
      if (content == null) return null;

      final json = jsonDecode(content) as Map<String, dynamic>;

      final timestamp = DateTime.parse(json['timestamp'] as String);
      final age = DateTime.now().difference(timestamp);

      // TTL check — delete expired drafts
      if (age > ttl) {
        await platform.clearDraftPlatform();
        return null;
      }

      return RecoverableDraft(
        directiveId: json['directiveId'] as int,
        timestamp: timestamp,
        data: (json['data'] as Map<String, dynamic>?) ?? {},
      );
    } catch (e) {
      debugPrint('Draft recovery check failed: $e');
      return null;
    }
  }

  /// Delete the draft (call after successful save or wizard completion).
  static Future<void> clearDraft() async {
    try {
      await platform.clearDraftPlatform();
    } catch (e) {
      debugPrint('Draft clear failed: $e');
    }
  }
}

/// A recovered draft with its metadata.
class RecoverableDraft {
  final int directiveId;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const RecoverableDraft({
    required this.directiveId,
    required this.timestamp,
    required this.data,
  });

  /// Human-readable age like "5 minutes ago"
  String get ageDescription {
    final age = DateTime.now().difference(timestamp);
    if (age.inMinutes < 1) return 'just now';
    if (age.inMinutes < 60) return '${age.inMinutes} minutes ago';
    return '${age.inHours} hours ago';
  }
}
