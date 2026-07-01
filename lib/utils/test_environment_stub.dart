/// Web fallback — there is no `dart:io` test-process environment to inspect,
/// so a release web build is never "in test".
bool get isRunningInTest => false;
