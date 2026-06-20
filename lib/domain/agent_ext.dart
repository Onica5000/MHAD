import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/utils/address_format.dart';

/// "City, State ZIP" helper — mirrors the private function in address_format.dart
/// but exposed here for PDF rendering sites that need city/state/zip separately.
String composeCityStateZip(String city, String state, String zip) {
  final stateZip = [state.trim(), zip.trim()].where((s) => s.isNotEmpty).join(' ');
  return [
    if (city.trim().isNotEmpty) city.trim(),
    if (stateZip.isNotEmpty) stateZip,
  ].join(', ');
}

/// Shared agent lookups — previously reimplemented at ~11 sites as
/// `agents.where((a) => a.agentType == '…').firstOrNull`.
extension AgentListX on List<Agent> {
  Agent? get primaryAgent => agentByType('primary');
  Agent? get alternateAgent => agentByType('alternate');

  Agent? agentByType(String type) {
    for (final a in this) {
      if (a.agentType == type) return a;
    }
    return null;
  }
}

extension AgentX on Agent {
  /// First non-empty phone, preferring cell → home → work (trimmed).
  String get bestPhone {
    for (final p in [cellPhone, homePhone, workPhone]) {
      final t = p.trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }

  /// Full composed address (line 1/2 · city · state · ZIP) as one line.
  String get fullAddress => composeAddressInline(
      line1: address, line2: address2, city: city, state: state, zip: zip);

  /// Street part only (line 1 + optional line 2, no city/state/zip).
  String get streetAddress =>
      [address.trim(), address2.trim()].where((p) => p.isNotEmpty).join(', ');

  /// "City, State ZIP" — for displaying below the street address line.
  String get cityStateZip => composeCityStateZip(city, state, zip);
}

extension GuardianAddressX on GuardianNomination {
  /// Full composed nominee address (line 1/2 · city · state · ZIP) as one line.
  String get fullNomineeAddress => composeAddressInline(
      line1: nomineeAddress,
      line2: nomineeAddress2,
      city: nomineeCity,
      state: nomineeState,
      zip: nomineeZip);

  /// Street part only (line 1 + optional line 2).
  String get nomineeStreetAddress =>
      [nomineeAddress.trim(), nomineeAddress2.trim()]
          .where((p) => p.isNotEmpty)
          .join(', ');

  /// "City, State ZIP" for the nominee.
  String get nomineeCityStateZip =>
      composeCityStateZip(nomineeCity, nomineeState, nomineeZip);
}

extension WitnessAddressX on WitnessesData {
  /// Full composed address (line 1/2 · city · state · ZIP) as one line.
  String get fullAddress => composeAddressInline(
      line1: address, line2: address2, city: city, state: state, zip: zip);

  /// Street part only (line 1 + optional line 2).
  String get streetAddress =>
      [address.trim(), address2.trim()].where((p) => p.isNotEmpty).join(', ');

  /// "City, State ZIP".
  String get cityStateZip => composeCityStateZip(city, state, zip);
}
