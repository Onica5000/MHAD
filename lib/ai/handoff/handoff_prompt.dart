import 'package:mhad/ai/handoff/ai_handoff_data.dart';
import 'package:mhad/ai/handoff/handoff_task.dart';

/// The first line of every handoff prompt. It names the task and what it is
/// for; the parser also uses it to recognise the prompt itself being pasted
/// back by mistake (Trueseed's lesson: the clipboard often still holds it).
const kHandoffMarker = '[PA MHAD ·';

String handoffHeader(HandoffTask task, int version) =>
    '$kHandoffMarker ${task.kind.tag} · v$version · ref ${task.ref}]';

/// Builds the full text the person copies into their AI chat: a header, the
/// envelope (who they are helping, reply language, verified PA legal facts),
/// the task's own instructions (shared with the API path), and — when an
/// answer comes back — the strict JSON rules and the no-attachment guard.
///
/// [paPhone] fills `{paPhone}` in the legal facts from the app's contact data
/// (one definition of the number).
String buildHandoffPrompt(
  HandoffTask task, {
  required String languageCode,
  required String paPhone,
  AiHandoffData? data,
}) {
  final d = data ?? AiHandoffData.instance;
  String fill(String s) => s
      .replaceAll('{task}', task.kind.tag)
      .replaceAll('{ref}', task.ref)
      .replaceAll('{paPhone}', paPhone)
      .replaceAll('{attachment}',
          d.attachmentName(languageCode, task.attachment.name));

  final out = StringBuffer()
    ..writeln(handoffHeader(task, d.version))
    ..writeln(fill(d.text(languageCode, 'intro')))
    ..writeln(fill(d.text(languageCode, 'replyLanguage')))
    ..writeln();
  for (final line in d.legalFacts) {
    out.writeln(fill(line));
  }
  out
    ..writeln()
    ..writeln(task.instructions.trim());

  switch (task.kind) {
    case HandoffTaskKind.ask:
      out
        ..writeln()
        ..writeln(fill(d.text(languageCode, 'askLead')))
        ..writeln(fill(d.text(languageCode, 'questionLabel')))
        ..writeln((task.question ?? '').trim());
    case HandoffTaskKind.fieldWording:
      out
        ..writeln()
        ..writeln(fill(d.text(languageCode, 'wordingLead')));
    default:
      break;
  }
  if (task.attachment != HandoffAttachment.none) {
    out
      ..writeln()
      ..writeln(fill(d.text(languageCode, 'attachmentGuard')));
  }
  if (task.returnsJson) {
    out
      ..writeln()
      ..writeln(fill(d.text(languageCode, 'jsonOnly')));
  }
  return out.toString().trimRight();
}
