import 'package:mhad/data/database/app_database.dart';

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
  /// Unifies the 3-4 separate "best phone" pickers (one of which trimmed,
  /// the others didn't — trimming is now consistent).
  String get bestPhone {
    for (final p in [cellPhone, homePhone, workPhone]) {
      final t = p.trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }
}
