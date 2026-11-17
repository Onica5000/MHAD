/// The prefix of every file MHAD hands the person.
const kFileNamePrefix = 'PA_MHAD';

/// ONE definition of the names of files MHAD hands the person (PDFs, the
/// export archive's contents): [parts] joined with `_`, each made safe for a
/// file name (letters, digits and hyphens; anything else becomes `_`), and
/// empty parts dropped — so a blank name never leaves `PA_MHAD_.pdf` or
/// `Directive_2026_.pdf`.
String mhadFileName(Iterable<Object?> parts, {String extension = 'pdf'}) {
  final safe = [
    for (final p in parts)
      if (p != null) _safePart('$p'),
  ].where((s) => s.isNotEmpty);
  return '${safe.join('_')}.$extension';
}

String _safePart(String s) => s
    .trim()
    .replaceAll(RegExp(r'[^\p{L}\p{N}-]+', unicode: true), '_')
    .replaceAll(RegExp(r'_+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');
