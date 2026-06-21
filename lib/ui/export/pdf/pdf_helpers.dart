/// Shared building blocks for PA MHAD PDF forms.
///
/// This is a barrel: it re-exports the presentation primitives
/// (`pdf_layout.dart`) and the directive-data section builders
/// (`pdf_section_builders.dart`) so the PDF generators can keep a single
/// `import 'pdf_helpers.dart';`.
library;

export 'pdf_layout.dart';
export 'pdf_section_builders.dart';
