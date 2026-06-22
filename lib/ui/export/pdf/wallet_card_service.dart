import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/ui/export/pdf/wallet_card_generator.dart';
import 'package:mhad/utils/background_runner.dart';
import 'package:mhad/utils/open_pdf.dart';
import 'package:printing/printing.dart';

/// Generates the wallet-card PDF and opens it in the user's PDF viewer (a new
/// browser tab on web) so they can print or save it — never an automatic
/// download. Falls back to the print/save dialog on native or if the browser
/// blocks the tab.
class WalletCardService {
  WalletCardService._();

  static Future<void> generateAndShare(
      Directive directive, List<Agent> agents) async {
    const generator = WalletCardGenerator();
    final bytes = await runInBackground(
      () => generator.generate(directive: directive, agents: agents),
    );
    final fname =
        'PA_MHAD_WalletCard_${directive.fullName.replaceAll(' ', '_')}.pdf';
    final opened = await openPdfInViewer(bytes, filename: fname);
    if (!opened) {
      await Printing.layoutPdf(onLayout: (_) => bytes, name: fname);
    }
  }
}
