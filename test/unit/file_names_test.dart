import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/utils/file_names.dart';

/// One file-name builder: no dangling separator when a part is blank (the
/// old "Directive_2026_.pdf" / "PA_MHAD_.pdf"), and names stay file-safe.
void main() {
  test('blank parts are dropped, never left as a trailing _', () {
    expect(mhadFileName([kFileNamePrefix, '', 2026]), 'PA_MHAD_2026.pdf');
    expect(mhadFileName([kFileNamePrefix, '   ']), 'PA_MHAD.pdf');
    expect(mhadFileName([kFileNamePrefix, null, 'WalletCard']),
        'PA_MHAD_WalletCard.pdf');
  });

  test('names are made file-safe; letters with accents are kept', () {
    expect(mhadFileName([kFileNamePrefix, "Mary O'Brien"]),
        'PA_MHAD_Mary_O_Brien.pdf');
    expect(mhadFileName([kFileNamePrefix, 'José  Núñez / Jr.']),
        'PA_MHAD_José_Núñez_Jr.pdf');
    expect(mhadFileName([kFileNamePrefix, 'blank-form']),
        'PA_MHAD_blank-form.pdf');
  });

  test('other extensions', () {
    expect(mhadFileName([kFileNamePrefix, 'Ann Lee'], extension: 'zip'),
        'PA_MHAD_Ann_Lee.zip');
  });
}
