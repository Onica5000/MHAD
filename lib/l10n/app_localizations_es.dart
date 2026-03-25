// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Directiva Anticipada de\nSalud Mental de PA';

  @override
  String get newDirective => 'Nueva Directiva';

  @override
  String get home => 'Inicio';

  @override
  String get education => 'Educación';

  @override
  String get assistant => 'Asistente';

  @override
  String get exportDirective => 'Exportar Directiva';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get done => 'Listo';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'Aceptar';

  @override
  String get retry => 'Reintentar';

  @override
  String get required => 'Obligatorio';

  @override
  String get combinedForm => 'Declaración Combinada y Poder de Salud Mental';

  @override
  String get declarationOnly => 'Solo Declaración';

  @override
  String get poaOnly => 'Solo Poder Notarial';

  @override
  String get personalInfo => 'Información Personal';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get dateOfBirth => 'Fecha de nacimiento';

  @override
  String get address => 'Dirección';

  @override
  String get city => 'Ciudad';

  @override
  String get state => 'Estado';

  @override
  String get zipCode => 'Código postal';

  @override
  String get phone => 'Teléfono';

  @override
  String get effectiveCondition => 'Condición de Vigencia';

  @override
  String get treatmentFacility => 'Centro de Tratamiento';

  @override
  String get medications => 'Medicamentos';

  @override
  String get ectPreferences => 'Preferencias de TEC';

  @override
  String get experimentalStudies => 'Estudios Experimentales';

  @override
  String get drugTrials => 'Ensayos Clínicos';

  @override
  String get additionalInstructions => 'Instrucciones Adicionales';

  @override
  String get agentDesignation => 'Designación de Agente';

  @override
  String get alternateAgent => 'Agente Alternativo';

  @override
  String get agentAuthority => 'Autoridad y Límites del Agente';

  @override
  String get guardianNomination => 'Nominación de Tutor';

  @override
  String get review => 'Revisar';

  @override
  String get execution => 'Ejecución';

  @override
  String get draft => 'Borrador';

  @override
  String get complete => 'Completa';

  @override
  String get expired => 'Vencida';

  @override
  String get revoked => 'Revocada';

  @override
  String get saveAndExit => 'Guardar y Salir';

  @override
  String get saveAndExitMessage =>
      'Su progreso en este paso se guardará. Puede regresar para continuar más tarde (solo en Modo Privado).';

  @override
  String get legalDisclaimer =>
      'Esta aplicación no proporciona asesoramiento legal. La información es solo para fines educativos y no sustituye el consejo de un abogado con licencia. Consulte a un profesional legal antes de ejecutar cualquier documento legal.';

  @override
  String get aiDisclaimer =>
      'El asistente de IA proporciona información general únicamente. No es un sustituto de asesoramiento legal, médico o profesional.';

  @override
  String get previewPdf => 'Vista Previa del PDF';

  @override
  String get sharePrint => 'Compartir / Imprimir';

  @override
  String get generateWalletCard => 'Generar Tarjeta de Billetera';

  @override
  String get importFromDocument => 'Importar de Documento';

  @override
  String get importFromContacts => 'Importar de Contactos';

  @override
  String get seeExamples => 'Ver ejemplos';

  @override
  String get aiSuggest => 'Sugerencia IA';

  @override
  String stepNOfTotal(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String percentComplete(int percent) {
    return '$percent% completado';
  }

  @override
  String lastEdited(String date) {
    return 'Última edición $date';
  }

  @override
  String nSections(int filled, int total) {
    return '$filled de $total secciones';
  }
}
