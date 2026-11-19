// On the web the draft recovery keeps nothing (2026-11-18): the progress
// autosave (lib/services/locked_progress/) keeps the work the way the person
// chose — a passphrase-locked copy, or nothing outside the tab — instead of
// this readable copy in localStorage. The old copy is erased at startup
// (LockedProgressStore.legacyKeys).

/// Nothing is written on the web.
Future<void> saveDraftPlatform(String jsonString) async {}

/// Nothing to read on the web.
Future<String?> readDraftPlatform() async => null;

/// Nothing to delete on the web.
Future<void> clearDraftPlatform() async {}
