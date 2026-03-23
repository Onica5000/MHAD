import 'dart:convert';

import 'package:mhad/data/database/app_database.dart';

/// Generates a FHIR R4 Consent resource JSON from a completed directive.
/// This enables future EHR integration. The output conforms to the FHIR
/// Consent resource structure (http://hl7.org/fhir/consent.html).
class FhirExportService {
  FhirExportService._();

  static String exportAsJson({
    required Directive directive,
    required List<Agent> agents,
    required List<MedicationEntry> medications,
    required DirectivePref? prefs,
    required AdditionalInstructionsTableData? additional,
    List<WitnessesData>? witnesses,
    GuardianNomination? guardian,
  }) {
    final resource = <String, dynamic>{
      'resourceType': 'Consent',
      'status': directive.status == 'complete' ? 'active' : 'draft',
      'scope': {
        'coding': [
          {
            'system': 'http://terminology.hl7.org/CodeSystem/consentscope',
            'code': 'adr',
            'display': 'Advance Directive',
          }
        ],
      },
      'category': [
        {
          'coding': [
            {
              'system': 'http://loinc.org',
              'code': '83334-6',
              'display': 'Psychiatric advance directive',
            }
          ],
        }
      ],
      'dateTime': DateTime.fromMillisecondsSinceEpoch(directive.updatedAt)
          .toIso8601String(),
    };

    // Patient reference (no actual PII — just a local reference)
    if (directive.fullName.isNotEmpty) {
      resource['patient'] = {
        'display': directive.fullName,
      };
    }

    // Policy — PA Act 194
    resource['policy'] = [
      {
        'authority': 'https://www.legis.state.pa.us',
        'uri': 'https://www.legis.state.pa.us/cfdocs/legis/li/uconsCheck.cfm?yr=2004&sessInd=0&act=194',
      }
    ];
    resource['policyRule'] = {
      'text': 'Pennsylvania Mental Health Advance Directive (Act 194 of 2004)',
    };

    // Provisions — treatment preferences
    final provisions = <Map<String, dynamic>>[];

    // Medications
    for (final med in medications) {
      provisions.add({
        'type': med.entryType == 'exception' ? 'deny' : 'permit',
        'code': [
          {
            'text': med.medicationName,
          }
        ],
        if (med.reason.isNotEmpty) 'data': [{'meaning': 'related', 'reference': {'display': med.reason}}],
      });
    }

    // ECT preference
    if (prefs != null) {
      provisions.add({
        'type': prefs.ectConsent == 'yes' ? 'permit' : 'deny',
        'code': [
          {
            'coding': [
              {
                'system': 'http://snomed.info/sct',
                'code': '35631009',
                'display': 'Electroconvulsive therapy',
              }
            ],
          }
        ],
      });
    }

    if (provisions.isNotEmpty) {
      resource['provision'] = {
        'provision': provisions,
      };
    }

    // Agents as actors
    final actors = <Map<String, dynamic>>[];
    for (final agent in agents) {
      if (agent.fullName.isEmpty) continue;
      actors.add({
        'role': {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/extra-security-role-type',
              'code': 'HPOWATT',
              'display': 'Healthcare Power of Attorney',
            }
          ],
        },
        'reference': {
          'display': '${agent.fullName} (${agent.agentType})',
        },
      });
    }
    // Witnesses as actors
    if (witnesses != null) {
      for (final w in witnesses) {
        if (w.fullName.isEmpty) continue;
        actors.add({
          'role': {
            'coding': [
              {
                'system':
                    'http://terminology.hl7.org/CodeSystem/v3-RoleCode',
                'code': 'WIT',
                'display': 'Witness',
              }
            ],
          },
          'reference': {
            'display': '${w.fullName} (Witness ${w.witnessNumber})',
          },
        });
      }
    }

    // Guardian nominee as actor
    if (guardian != null && guardian.nomineeFullName.isNotEmpty) {
      actors.add({
        'role': {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/v3-RoleCode',
              'code': 'GUARD',
              'display': 'Guardian',
            }
          ],
        },
        'reference': {
          'display':
              '${guardian.nomineeFullName} (${guardian.nomineeRelationship})',
        },
      });
    }

    if (actors.isNotEmpty) {
      resource['provision'] ??= {};
      (resource['provision'] as Map)['actor'] = actors;
    }

    // Source reference — the directive text
    if (directive.effectiveCondition.isNotEmpty) {
      resource['sourceAttachment'] = {
        'contentType': 'text/plain',
        'title': 'Effective condition',
        'data': base64Encode(
            utf8.encode(directive.effectiveCondition)),
      };
    }

    return const JsonEncoder.withIndent('  ').convert(resource);
  }
}
