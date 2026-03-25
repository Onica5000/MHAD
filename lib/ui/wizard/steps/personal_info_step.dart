import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class PersonalInfoStep extends ConsumerStatefulWidget {
  final int directiveId;
  const PersonalInfoStep({required this.directiveId, super.key});

  @override
  ConsumerState<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<PersonalInfoStep>
    with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _address2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _zipCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController();
    _dobCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _address2Ctrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController(text: 'PA');
    _zipCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl, _dobCtrl, _addressCtrl, _address2Ctrl,
      _cityCtrl, _stateCtrl, _zipCtrl, _phoneCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final d = await repo.getDirectiveById(widget.directiveId);
    if (d != null && mounted) {
      setState(() {
        _fullNameCtrl.text = d.fullName;
        _dobCtrl.text = d.dateOfBirth;
        _addressCtrl.text = d.address;
        _address2Ctrl.text = d.address2;
        _cityCtrl.text = d.city;
        _stateCtrl.text = d.state.isEmpty ? 'PA' : d.state;
        _zipCtrl.text = d.zip;
        _phoneCtrl.text = d.phone;
      });

      // Offer to copy personal info from most recent prior directive
      final isEmpty = d.fullName.isEmpty &&
          d.dateOfBirth.isEmpty &&
          d.address.isEmpty &&
          d.phone.isEmpty;
      if (isEmpty && mounted) {
        await _offerAutofill(repo);
      }
    }
  }

  Future<void> _offerAutofill(dynamic repo) async {
    final all = await repo.getAllDirectives();
    final prior = (all as List)
        .where((d) => d.id != widget.directiveId && d.fullName.isNotEmpty)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (prior.isEmpty || !mounted) return;

    final source = prior.first;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy Personal Info?'),
        content: Text(
          'Would you like to copy your personal information from a '
          'previous directive (${source.fullName})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, start fresh'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, copy'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        _fullNameCtrl.text = source.fullName;
        _dobCtrl.text = source.dateOfBirth;
        _addressCtrl.text = source.address;
        _address2Ctrl.text = source.address2;
        _cityCtrl.text = source.city;
        _stateCtrl.text = source.state.isEmpty ? 'PA' : source.state;
        _zipCtrl.text = source.zip;
        _phoneCtrl.text = source.phone;
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate(); // Show warnings but don't block
    await ref.read(directiveRepositoryProvider).updatePersonalInfo(
      widget.directiveId,
      fullName: _fullNameCtrl.text.trim(),
      dateOfBirth: _dobCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      address2: _address2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      zip: _zipCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    return true;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final parts = value.split('/');
    if (parts.length != 3) return 'Use MM/DD/YYYY format';
    final dob = DateTime.tryParse(
        '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}');
    if (dob == null) return 'Invalid date';
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    if (age < 18) return 'Must be 18 or older to create a directive';
    return null;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your date of birth',
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.year}';
      // Trigger validation
      _formKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WizardHelpButton(
              helpText:
                  'Provide your legal name as it appears on official documents. '
                  'You must be 18 years of age or older to create a Mental Health '
                  'Advance Directive under PA Act 194 of 2004.',
              stepId: 'personalInfo',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full legal name *',
                border: OutlineInputBorder(),
                helperText: 'Use your full legal name as it appears on official ID',
              ),
              autofillHints: const [],
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dobCtrl,
              decoration: InputDecoration(
                labelText: 'Date of birth (MM/DD/YYYY) *',
                border: const OutlineInputBorder(),
                hintText: 'MM/DD/YYYY',
                helperText: 'Used to verify your identity on the directive',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  tooltip: 'Pick date',
                  onPressed: _pickDateOfBirth,
                ),
              ),
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.next,
              inputFormatters: [_DateInputFormatter()],
              validator: _validateAge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Street address',
                border: OutlineInputBorder(),
                helperText: 'Your current residential address',
              ),
              autofillHints: const [],
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _address2Ctrl,
              decoration: const InputDecoration(
                labelText: 'Apt, suite, unit, etc.',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [],
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: const [],
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _stateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: const [],
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    maxLength: 2,
                    buildCounter: (_, {required currentLength,
                        required isFocused, maxLength}) => null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _zipCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ZIP',
                      hintText: '12345 or 12345-6789',
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: const [],
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [_ZipInputFormatter()],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 5 && digits.length != 9) {
                        return 'Enter 5-digit or 5+4-digit ZIP';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '(215) 555-1234',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [],
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [_PhoneInputFormatter()],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final digits = v.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 10) {
                  return 'Enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
          ],
        ),
      );
  }
}

/// Auto-formats date input as MM/DD/YYYY while typing.
/// Inserts slashes automatically after month and day digits.
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Auto-formats phone input as (123) 456-7890 while typing.
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 10; i++) {
      if (i == 0) buf.write('(');
      buf.write(digits[i]);
      if (i == 2) buf.write(') ');
      if (i == 5) buf.write('-');
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Auto-formats ZIP input as 12345 or 12345-6789 while typing.
class _ZipInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 9; i++) {
      if (i == 5) buf.write('-');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

