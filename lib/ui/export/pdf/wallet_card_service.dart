import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/ui/export/pdf/wallet_card_generator.dart';
import 'package:mhad/utils/background_runner.dart';
import 'package:printing/printing.dart';

/// Generates the wallet-card PDF and hands it to the OS share/print sheet.
/// Extracted from the identical block in wizard-complete and export screens;
/// each caller keeps its own in-progress flag and error handling around this.
class WalletCardService {
  WalletCardService._();

  static Future<void> generateAndShare(
      Directive directive, List<Agent> agents) async {
    const generator = WalletCardGenerator();
    final bytes = await runInBackground(
      () => generator.generate(directive: directive, agents: agents),
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'PA_MHAD_WalletCard_${directive.fullName.replaceAll(' ', '_')}.pdf',
    );
  }
}
