/// Mix into every wizard step State to give the WizardScreen a uniform
/// interface for validation + saving before navigating forward.
mixin WizardStepMixin {
  /// Validate the current step's form and persist data to the database.
  /// Returns [true] if valid and saved successfully, [false] otherwise.
  Future<bool> validateAndSave();
}
