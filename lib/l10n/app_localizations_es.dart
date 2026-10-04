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
  String get navHome => 'Inicio';

  @override
  String get navLearn => 'Aprender';

  @override
  String get navAsk => 'Preguntar';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navMore => 'Más';

  @override
  String get navStart => 'Comenzar';

  @override
  String get navAutofill => 'Autocompletar';

  @override
  String get navAiAssistant => 'Asistente de IA';

  @override
  String get navDownloadPrint => 'Descargar e imprimir';

  @override
  String get navResetForm => 'Reiniciar formulario';

  @override
  String get badgeAiReady => 'LISTO';

  @override
  String get badgeAiSetUp => 'ACTIVAR';

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

  @override
  String get procResearchEctLabel => 'Terapia electroconvulsiva (TEC)';

  @override
  String get procResearchExperimentalLabel => 'Estudios experimentales';

  @override
  String get procResearchDrugTrialsLabel => 'Ensayos de medicamentos';

  @override
  String get procResearchWhyTheseThree =>
      '¿Por qué estos tres? La Ley 194 de PA exige específicamente un consentimiento documentado para la TEC, los estudios experimentales y los ensayos de medicamentos. Los demás tratamientos se rigen por sus preferencias generales.';

  @override
  String get procResearchAgentAuthority =>
      'Autoridad del agente sobre estos tres: su agente no puede consentir en su nombre a la TEC, a estudios experimentales ni a ensayos de medicamentos, a menos que usted le otorgue expresamente esa facultad más abajo. Sin una autorización expresa, solo usted puede consentir; de lo contrario, no estarán disponibles mientras usted esté incapacitado.';

  @override
  String get procResearchNeverAuthorizedTitle =>
      'Nunca autorizado según la Ley 194 de PA';

  @override
  String get procResearchNeverAuthorizedBody =>
      'Por ley (20 Pa.C.S. § 5836(b)), esta directiva nunca puede otorgar la facultad de consentir a lo siguiente; ninguna cláusula de este documento ni ninguna decisión de su agente puede autorizarlo:';

  @override
  String get procResearchPsychosurgery =>
      'Psicocirugía (cirugía cerebral destinada a cambiar el estado de ánimo o la conducta)';

  @override
  String get procResearchParentalRights => 'Terminación de la patria potestad';

  @override
  String get signScreenPreparing => 'Preparando el paquete para firmar';

  @override
  String get signScreenBackToReview => 'Volver a revisar';

  @override
  String get executionHelpText =>
      'Según 20 Pa.C.S. § 5822 / § 5832, una Directiva Anticipada de Salud Mental debe firmarse en papel por usted y dos testigos adultos, todos presentes al mismo tiempo. La aplicación no puede actuar como testigo; este paso le explica qué hacer.';

  @override
  String get executionFinalStepLabel => 'Último paso · en papel';

  @override
  String get executionHeading => 'Hágalo legal, con bolígrafo.';

  @override
  String get executionIntro =>
      'La ley de Pensilvania exige una firma real en papel. No podemos ser testigos por usted, pero aquí tiene exactamente lo que debe hacer.';

  @override
  String get executionWhyNotAppLead => '¿Por qué no firmar en la aplicación? ';

  @override
  String get executionWhyNotAppBody =>
      'Según la Ley 194, la directiva solo es válida cuando usted y dos testigos adultos firman el ';

  @override
  String get executionSamePaperDocument => 'mismo documento en papel';

  @override
  String get executionWhyNotAppTail =>
      ', juntos. Una firma con un toque en la pantalla no sería válida.';

  @override
  String get executionAnyFormValid =>
      'No tiene que usar un formulario específico. Los formularios oficiales de Pensilvania se recomiendan, pero no son obligatorios: lo que hace válida su directiva es su contenido y que se firme y atestigüe correctamente. Si un centro le da otro formulario, este sigue siendo válido.';

  @override
  String get executionStep1Title => 'Imprima el paquete';

  @override
  String get executionStep1Body =>
      'Imprima el PDF que acabamos de crear. Ya incluye líneas de firma para usted y dos testigos.';

  @override
  String get executionStep2Title => 'Reúna a dos testigos adultos';

  @override
  String get executionStep2Body =>
      'Ambos deben tener 18 años o más y estar en la misma sala que usted cuando firme. (Más abajo se indica quién no puede ser testigo).';

  @override
  String get executionStep3Title =>
      'Todos firman en el mismo lugar y al mismo tiempo';

  @override
  String get executionStep3Body =>
      'Firme y feche la página de testigos delante de ambos testigos. Ellos firman justo después de usted, mientras usted observa.';

  @override
  String get executionWitnessLead => 'Un testigo ';

  @override
  String get executionWitnessCannot => 'no puede';

  @override
  String get executionWitnessRest =>
      ' ser su agente ni su agente alternativo, su proveedor de atención de salud mental ni un empleado del centro donde recibe tratamiento, a menos que tenga con usted parentesco por consanguinidad, matrimonio o adopción.';

  @override
  String get executionInYourPacket => 'En su paquete';

  @override
  String get executionPacketMhadTitle => 'Su MHAD completada';

  @override
  String get executionPacketMhadSub => 'PDF · formato de la Ley 194 de PA';

  @override
  String get executionPacketSignatureTitle => 'Página de firma y testigos';

  @override
  String get executionPacketSignatureSub =>
      'Con su nombre y las líneas de fecha ya completados';

  @override
  String get executionPacketWitnessTitle => 'Guía de requisitos para testigos';

  @override
  String get executionPacketWitnessSub =>
      'Una página: quién puede y quién no puede firmar';

  @override
  String get executionPacketAfterTitle => 'Qué hacer después de firmar';

  @override
  String get executionPacketAfterSub =>
      'A quién darle copias y cómo distribuirlas';

  @override
  String get executionPreviewPacket => 'Ver y abrir el paquete';

  @override
  String get executionNotYetValid =>
      'AÚN NO ES VÁLIDA · SERÁ LEGAL CUANDO USTED Y 2 TESTIGOS LA FIRMEN EN PAPEL';

  @override
  String get reviewStepNotProvidedYet => 'Aún no se ha indicado';

  @override
  String get reviewStepNoInfoEntered => 'No se ingresó información';

  @override
  String reviewStepA11yNoInfo(String label) {
    return '$label. No se ingresó información.';
  }

  @override
  String get reviewStepPrimaryAgent => 'Agente principal';

  @override
  String get reviewStepWhereIWantCare => 'Dónde quiero recibir atención';

  @override
  String get reviewStepMedicalDiagnoses => 'Diagnósticos médicos';

  @override
  String get reviewStepAllergiesReactions => 'Alergias y reacciones';

  @override
  String get reviewStepProceduresResearch => 'Procedimientos e investigación';

  @override
  String get reviewStepName => 'Nombre';

  @override
  String get reviewStepPhone => 'Teléfono';

  @override
  String get reviewStepCondition => 'Condición';

  @override
  String get reviewStepRelationship => 'Parentesco';

  @override
  String get reviewStepTreatmentFacility => 'Centro de tratamiento';

  @override
  String get reviewStepMedicationConsent => 'Consentimiento sobre medicamentos';

  @override
  String get reviewStepAllergies => 'Alergias';

  @override
  String get reviewStepNeverGive => 'Nunca administrar';

  @override
  String get reviewStepWithLimits => 'Con límites';

  @override
  String get reviewStepPreferred => 'Preferidos';

  @override
  String get reviewStepEctConsent => 'Consentimiento para TEC';

  @override
  String get reviewStepDrugTrials => 'Ensayos de medicamentos';

  @override
  String get reviewStepActivities => 'Actividades';

  @override
  String get reviewStepCrisisIntervention => 'Intervención en crisis';

  @override
  String get reviewStepHealthHistory => 'Antecedentes de salud';

  @override
  String get reviewStepDietary => 'Alimentación';

  @override
  String get reviewStepReligious => 'Religión';

  @override
  String get reviewStepChildren => 'Hijos';

  @override
  String get reviewStepFamilyNotification => 'Aviso a la familia';

  @override
  String get reviewStepRecordsDisclosure => 'Divulgación de registros';

  @override
  String get reviewStepPetCare => 'Cuidado de mascotas';

  @override
  String get reviewStepOther => 'Otro';

  @override
  String reviewStepWhoPhone(String who) {
    return 'Número de teléfono de $who';
  }

  @override
  String reviewStepWhoAddress(String who) {
    return 'Dirección de $who';
  }

  @override
  String get reviewStepYourPrimaryAgent => 'su agente principal';

  @override
  String get reviewStepYourAlternateAgent => 'su agente alternativo';

  @override
  String get reviewStepYourGuardianNominee =>
      'la persona que usted propone como tutor';

  @override
  String get reviewStepLoading => 'Cargando';

  @override
  String get reviewStepOneLastLook =>
      'Una última revisión y luego prepararemos su paquete para firmar.';

  @override
  String get reviewStepOneSectionNeedsAttention =>
      'Todavía hay 1 sección que requiere su atención antes de firmar.';

  @override
  String reviewStepSectionsNeedAttention(int count) {
    return 'Todavía hay $count secciones que requieren su atención antes de firmar.';
  }

  @override
  String get reviewStepAllGood =>
      'Todo se ve bien. Se revisaron todas las secciones.';

  @override
  String reviewStepOptionalGather(String items) {
    return 'Opcional, pero conviene reunirlo antes de firmar: $items. Ayuda a su equipo de atención a comunicarse con las personas que usted nombró; aun así, puede firmar sin estos datos.';
  }

  @override
  String get reviewStepAtAGlance => 'Su directiva de un vistazo';

  @override
  String get reviewStepOptionalCheck => 'Revisión opcional';

  @override
  String get reviewStepRunConsistencyCheck =>
      'Hacer una revisión de coherencia';

  @override
  String get reviewStepConsistencyCheckHelp =>
      'Revisa sus respuestas en busca de contradicciones entre pasos (por ejemplo, un consentimiento del agente que contradice una lista de cosas a evitar) y, si la IA está configurada, añade una revisión opcional de la IA para verificar vacíos. Es opcional; puede firmar sin hacerla.';

  @override
  String get reviewStepReadyToSign => '¿Listo para firmar?';

  @override
  String get reviewStepReadyToSignBody =>
      'Revise todas las secciones anteriores. Cuando esté conforme, toque Vista previa para continuar con la firma y la fecha de la directiva.';

  @override
  String get reviewStepProvidersMustComply => 'Los proveedores deben cumplir ';

  @override
  String get reviewStepProvidersMustComplyBody =>
      'su directiva según la Ley 194 de PA (20 Pa.C.S. §§ 5804, 5842). Un proveedor solo puede negarse a seguir instrucciones específicas si contradicen la práctica médica aceptada o si el proveedor no está físicamente disponible.';

  @override
  String get reviewStepExperimentalStudies => 'Estudios experimentales';

  @override
  String get wizardProgressSaved => 'Progreso guardado';

  @override
  String get wizardLoading => 'Cargando';

  @override
  String get wizardError => 'Error';

  @override
  String get wizardUnableToLoad => 'No se pudo cargar esta directiva.';

  @override
  String get wizardBackToHome => 'Volver al inicio';

  @override
  String get wizardNotFound => 'No encontrado';

  @override
  String get wizardDirectiveNotFound => 'No se encontró la directiva.';

  @override
  String get wizardPreview => 'Vista previa';

  @override
  String get wizardContinue => 'Continuar';

  @override
  String get wizardSaved => 'Guardado';

  @override
  String get wizardIncompletePrivate =>
      'Algunos campos están incompletos; puede volver más tarde para terminarlos.';

  @override
  String get wizardIncompletePublic =>
      'Algunos campos están incompletos; puede completarlos antes de terminar.';

  @override
  String get wizardExitWithoutSaving => '¿Salir sin guardar?';

  @override
  String get wizardExitWebBody =>
      'La aplicación web no guarda su progreso de forma permanente.\n\nSi sale, cierra la pestaña o la aplicación falla, su trabajo se conserva en este dispositivo durante 10 minutos para que pueda volver a abrirlo y recuperarlo; después se borra. Exporte o imprima su documento para conservar una copia.';

  @override
  String get wizardExitPublicBody =>
      'Está en Modo Público: sus datos solo se guardan en la memoria y se perderán cuando se cierre la aplicación.\n\nExporte o imprima su documento antes de salir. Para guardarlo entre sesiones, use el Modo Privado.';

  @override
  String get wizardStay => 'Quedarme';

  @override
  String get wizardExit => 'Salir';

  @override
  String get wizardSaveExitBody =>
      'Se guardará su progreso en este paso. Puede volver más tarde para continuar.';

  @override
  String get wizardYourDirective => 'SU DIRECTIVA';

  @override
  String personalInfoStepReuseDetails(String name) {
    return '¿Usar sus datos de $name?';
  }

  @override
  String get personalInfoStepCopy => 'Copiar';

  @override
  String get personalInfoStepZipFirst =>
      'Primero ingrese un código postal de 5 dígitos.';

  @override
  String get personalInfoStepZipLookupFailed =>
      'No se pudo buscar ese código postal; puede escribirlo usted.';

  @override
  String personalInfoStepCountyName(String county) {
    return 'Condado de $county';
  }

  @override
  String personalInfoStepFilled(String filled) {
    return 'Completado: $filled';
  }

  @override
  String get personalInfoStepDateFormat =>
      'Use el formato MM/DD/AAAA (mes/día/año)';

  @override
  String get personalInfoStepInvalidDate => 'Fecha no válida';

  @override
  String get personalInfoStepDobFuture =>
      'La fecha de nacimiento no puede ser futura';

  @override
  String get personalInfoStepMustBeAdult =>
      'Debe tener 18 años o más (o ser un menor emancipado) para crear una directiva';

  @override
  String get personalInfoStepSelectDob => 'Seleccione su fecha de nacimiento';

  @override
  String get personalInfoStepHelp =>
      'Indique su nombre legal tal como aparece en sus documentos oficiales. Debe tener 18 años o más, o ser un menor emancipado, para crear una Directiva Anticipada de Salud Mental según la Ley 194 de 2004 de PA.';

  @override
  String get personalInfoStepFullLegalName => 'Nombre legal completo *';

  @override
  String get personalInfoStepFullLegalNameHelper =>
      'Use su nombre legal completo tal como aparece en su identificación oficial';

  @override
  String get personalInfoStepDobLabel => 'Fecha de nacimiento (MM/DD/AAAA) *';

  @override
  String get personalInfoStepDobHelper =>
      'Se usa para verificar su identidad en la directiva';

  @override
  String get personalInfoStepPickDate => 'Elegir fecha';

  @override
  String get personalInfoStepStreetAddress => 'Dirección';

  @override
  String get personalInfoStepStreetAddressHelper =>
      'Su dirección residencial actual';

  @override
  String get personalInfoStepAddress2 => 'Apto., suite, unidad, etc.';

  @override
  String get personalInfoStepCounty => 'Condado';

  @override
  String get personalInfoStepZip => 'Código postal';

  @override
  String get personalInfoStepZipHint => '12345 o 12345-6789';

  @override
  String get personalInfoStepZipHelper =>
      'Toque el ícono para completar ciudad, condado y estado';

  @override
  String get personalInfoStepZipTooltip =>
      'Completar ciudad, condado y estado a partir del código postal';

  @override
  String get personalInfoStepZipInvalid =>
      'Ingrese un código postal de 5 o de 5+4 dígitos';

  @override
  String get personalInfoStepPhoneInvalid =>
      'Ingrese un número de teléfono válido de 10 dígitos';

  @override
  String get peopleTrustPrimaryAgent => 'AGENTE PRINCIPAL';

  @override
  String get peopleTrustAlternateAgent => 'AGENTE ALTERNATIVO';

  @override
  String get peopleTrustWhatCanTheyDecide => '¿Qué pueden decidir?';

  @override
  String get peopleTrustAuthorityIntro =>
      'Limite o amplíe la autoridad de su agente. Por defecto, la autoridad es amplia.';

  @override
  String get peopleTrustLegendAgentDecides => '\"Decide el agente\"';

  @override
  String get peopleTrustLegendGrants => ' otorga la facultad; ';

  @override
  String get peopleTrustLegendNo => '\"No\"';

  @override
  String get peopleTrustLegendWithholds => ' la niega por completo; ';

  @override
  String get peopleTrustLegendIf => '\"Si…\"';

  @override
  String get peopleTrustLegendCondition =>
      ' le permite añadir una condición con sus propias palabras.';

  @override
  String get peopleTrustPrimaryBadge => 'Principal';

  @override
  String get peopleTrustAddSomeone => 'Añadir a alguien';

  @override
  String get peopleTrustOptional => 'Opcional';

  @override
  String get peopleTrustContactPicker => 'Selector de contactos';

  @override
  String get peopleTrustPhoneOnFile => 'Teléfono registrado';

  @override
  String get agentDesigHelp =>
      'Su agente debe tener 18 años o más. Según la Ley 194 de PA, no puede ser su proveedor de atención de salud mental ni un empleado de un centro de salud mental o centro residencial donde usted reciba atención, a menos que sea su pariente. Elija a alguien de confianza que respete sus deseos.';

  @override
  String get agentDesigTitle => 'Designación del agente principal';

  @override
  String get agentDesigAgentDefinition =>
      'Un agente (apoderado de atención médica) es la persona que usted elige para tomar decisiones sobre su atención de salud mental en su nombre cuando usted no pueda hacerlo.';

  @override
  String get agentDesigRelationship => 'Parentesco';

  @override
  String get agentDesigSpouseNote =>
      'Nota: Según la Ley 194 de PA §5838, si designa a su cónyuge como agente, esa designación se revoca automáticamente si cualquiera de los cónyuges solicita el divorcio, a menos que usted indique lo contrario en esta directiva.';

  @override
  String get altAgentHelp =>
      'Su agente debe tener 18 años o más. No puede ser su médico tratante, un empleado de su centro de tratamiento (salvo que sea pariente) ni alguien con un interés económico en su patrimonio. Elija a alguien de confianza que respete sus deseos.';

  @override
  String get altAgentTitle => 'Designación del agente alternativo';

  @override
  String get altAgentActsIf =>
      'Su agente alternativo actúa si su agente principal no puede o no quiere hacerlo.';

  @override
  String get altAgentSameAuthority =>
      'El agente alternativo tiene la misma autoridad que el agente principal, pero solo interviene cuando el agente principal no puede actuar.';

  @override
  String get altAgentNotRequired =>
      'No está obligado a designar un agente alternativo.';

  @override
  String get altAgentRelationship => 'Parentesco';

  @override
  String get agentAuthHelp =>
      'Piénselo con cuidado antes de restringir la autoridad de su agente. Una autoridad amplia le da a su agente flexibilidad para responder a situaciones que usted quizá no prevea.';

  @override
  String get agentAuthIntro =>
      'Por defecto, su agente tiene amplia autoridad para tomar decisiones sobre su tratamiento de salud mental. Aquí puede restringir esa autoridad.';

  @override
  String get agentAuthScopeTitle =>
      'Importante: alcance de la autoridad (20 Pa.C.S. § 5836)';

  @override
  String get agentAuthScopeBody =>
      'Las casillas de abajo se aplican SOLO a:\n  • Hospitalización voluntaria (ingreso a un centro de tratamiento)\n  • Medicamentos psiquiátricos en general\n\nNO incluyen:\n  • Terapia electroconvulsiva (TEC)\n  • Estudios o procedimientos experimentales\n  • Ensayos clínicos de medicamentos\n\nSus decisiones de consentimiento sobre la TEC, los estudios experimentales y los ensayos de medicamentos se indican en sus propias páginas, antes en este formulario. Según la Ley 194 de PA, su agente NO PUEDE anular esas decisiones: son obligatorias independientemente de la autoridad del agente.';

  @override
  String get agentAuthStandardLead => 'La norma que su agente debe seguir: ';

  @override
  String get agentAuthStandardBody =>
      'según el § 5836(d), su agente está legalmente obligado a tomar la decisión que usted tomaría si fuera competente, guiándose por lo que escriba en esta directiva y por cualquier instrucción previa clara, después de consultar con los proveedores. Cuanto más complete, más podrán sus decisiones parecerse a las suyas.';

  @override
  String get agentAuthHospitalization =>
      'El agente puede consentir a una hospitalización voluntaria';

  @override
  String get agentAuthHospitalizationSub =>
      'Solo el ingreso a un centro de tratamiento psiquiátrico';

  @override
  String get agentAuthMedication => 'El agente puede consentir a medicamentos';

  @override
  String get agentAuthMedicationSub =>
      'Solo medicamentos psiquiátricos en general; no incluye la TEC';

  @override
  String get agentAuthExamplesField => 'Limitaciones del agente';

  @override
  String get agentAuthExample1 =>
      'Mi agente no puede consentir a la terapia electroconvulsiva (TEC) bajo ninguna circunstancia.';

  @override
  String get agentAuthExample2 =>
      'Mi agente debe consultar con mi terapeuta, el Dr. Smith, antes de aceptar cualquier cambio en mi régimen de medicamentos.';

  @override
  String get agentAuthExample3 =>
      'Mi agente puede consentir a un ingreso hospitalario voluntario de hasta 72 horas, pero no puede consentir a estancias más largas sin consultar a mi familia.';

  @override
  String get agentAuthLimitationsLabel =>
      'Limitaciones o instrucciones adicionales (opcional)';

  @override
  String get guardianNomNoPreference => 'Sin preferencia';

  @override
  String get guardianNomNoPreferenceHint =>
      'Que decida el tribunal. Por lo general, nombrará a un familiar o a la oficina de tutela del condado.';

  @override
  String get guardianNomSameAsPrimary =>
      'La misma persona que mi agente principal';

  @override
  String get guardianNomSameAsPrimaryHint =>
      'La opción más sencilla. El tribunal no está obligado a seguirla, pero es una orientación de peso.';

  @override
  String get guardianNomSameAsAlternate =>
      'La misma persona que mi agente alternativo';

  @override
  String get guardianNomSameAsAlternateHint =>
      'Use esta opción si su agente alternativo sería más adecuado para una tutela de largo plazo.';

  @override
  String get guardianNomDifferent => 'Otra persona';

  @override
  String get guardianNomDifferentHint =>
      'Elija a otra persona; por ejemplo, un abogado, un hermano o un amigo cercano que aún no haya nombrado.';

  @override
  String get guardianNomHelp =>
      'Su propuesta no es obligatoria: el tribunal la tendrá en cuenta, pero toma la decisión final sobre a quién nombrar.';

  @override
  String get guardianNomOptionalIntro =>
      'Esta sección es opcional. Puede proponer un tutor por si algún día un tribunal necesita nombrarle uno.';

  @override
  String get guardianNomGuardianVsAgent =>
      'Un tutor no es lo mismo que su agente. Un tutor lo nombra un tribunal en un proceso formal de incapacidad. Esta propuesta le indica al tribunal a quién prefiere usted.';

  @override
  String get guardianNomPreferredGuardian => 'Tutor preferido';

  @override
  String get guardianNomPickWhatFits =>
      'Elija lo que mejor le convenga: su propuesta es una orientación para el tribunal, no una instrucción obligatoria.';

  @override
  String get guardianNomNomineeFullName =>
      'Nombre completo de la persona propuesta';

  @override
  String get guardianNomRelationshipToYou => 'Parentesco o relación con usted';

  @override
  String get guardianNomConditionsTitle => 'Condiciones de la tutela';

  @override
  String get guardianNomConditionsIntro =>
      'Si un tribunal nombra a un tutor, indique los límites que desea que respete. Son una orientación para el tribunal, no son obligatorios.';

  @override
  String get guardianNomCanChangeAgent => 'Puede cambiar a mi agente';

  @override
  String get guardianNomCanChangeAgentHint =>
      '¿Cuándo o cómo puede el tutor cambiar a mi agente? (opcional)';

  @override
  String get guardianNomCanOverride => 'Puede anular esta directiva';

  @override
  String get guardianNomCanOverrideSub =>
      'Revocarla, suspenderla o darla por terminada.';

  @override
  String get guardianNomCanOverrideHint =>
      '¿Algún límite para anular esta directiva? (opcional)';

  @override
  String get guardianNomMustConsult => 'Debe consultar primero con mi agente';

  @override
  String get guardianNomMustConsultHint =>
      '¿Sobre qué debe el tutor consultar a mi agente? (opcional)';

  @override
  String diagnosesAlreadyAdded(String name) {
    return '$name ya está agregado';
  }

  @override
  String get diagnosesSearchHint =>
      'Busque una condición (p. ej., depresión, TDAH)…';

  @override
  String get diagnosesClearSearch => 'Borrar búsqueda';

  @override
  String get diagnosesHelpText =>
      'Busque sus diagnósticos psiquiátricos y médicos mediante los códigos CIE-10 (ICD-10). Son los códigos oficiales de clasificación médica que usan los proveedores de salud. Añadir sus diagnósticos ayuda a su equipo de atención y a su agente a entender sus condiciones.\n\nLos diagnósticos psiquiátricos (códigos F) y los médicos se muestran en secciones separadas.\n\nEsta búsqueda es gratuita y usa el NIH Clinical Tables Service; no consume tokens de IA.';

  @override
  String get diagnosesPsychiatric => 'Psiquiátricos';

  @override
  String get diagnosesMedical => 'Médicos';

  @override
  String get diagnosesNoResults => 'No se encontraron resultados.';

  @override
  String get diagnosesEmptyTitle => 'Aún no se han añadido diagnósticos';

  @override
  String get diagnosesEmptyBody =>
      'Use la búsqueda de arriba para encontrar y añadir sus diagnósticos.';

  @override
  String diagnosesAddedOne(int count) {
    return 'Añadida · $count condición';
  }

  @override
  String diagnosesAddedMany(int count) {
    return 'Añadidas · $count condiciones';
  }

  @override
  String diagnosesPsychiatricCount(int count) {
    return 'Psiquiátricos ($count)';
  }

  @override
  String diagnosesMedicalCount(int count) {
    return 'Médicos ($count)';
  }

  @override
  String get diagnosesDoctorSection => 'Médico de atención primaria · opcional';

  @override
  String get diagnosesDoctorName => 'Nombre del médico';

  @override
  String get diagnosesDoctorNameHint =>
      'Escriba un nombre para buscar en el registro de proveedores';

  @override
  String get diagnosesNpiNote =>
      'Nombres de proveedores del registro NPI (NIH Clinical Tables). Verifique los datos antes de confiar en ellos.';

  @override
  String get diagnosesSpecialty => 'Especialidad';

  @override
  String get diagnosesPhone => 'Teléfono';

  @override
  String get diagnosesDescribeSemantics =>
      'Describa una condición para encontrar su nombre oficial';

  @override
  String get diagnosesDescribeLead => '¿No sabe el nombre oficial? ';

  @override
  String get diagnosesDescribeBold => 'Describa cómo se manifiesta en usted';

  @override
  String get diagnosesDescribeTail =>
      ' y le sugeriré el código CIE-10 más cercano para que usted lo confirme.';

  @override
  String get diagnosesTry => 'Probar →';

  @override
  String get diagnosesFooter =>
      'No está obligado a indicar nada. Lo que indique solo se comparte con las personas que nombra en su directiva.';

  @override
  String diagnosesAddedName(String name) {
    return 'Se añadió “$name”';
  }

  @override
  String diagnosesAlreadyAddedQuoted(String name) {
    return '“$name” ya está añadido';
  }

  @override
  String get diagnosesDescribeTitle => 'Describa lo que le pasa';

  @override
  String get diagnosesDescribeIntro =>
      'Con sus propias palabras: los síntomas, cómo le afectan y cuándo ocurren. Le sugeriremos posibles condiciones y confirmaremos cada una con el registro CIE-10. Son sugerencias para revisar, no un diagnóstico.';

  @override
  String get diagnosesDescribeHint =>
      'p. ej., largos periodos en los que me siento sin esperanza y no puedo levantarme de la cama';

  @override
  String get diagnosesFinding => 'Buscando…';

  @override
  String get diagnosesFindMatches => 'Buscar coincidencias';

  @override
  String get diagnosesNoMatches =>
      'No hay coincidencias cercanas. Añada más detalles o use el cuadro de búsqueda de la página si conoce parte del nombre.';

  @override
  String get diagnosesSuggestionsNote =>
      'Solo son sugerencias: confírmelas con sus registros o con su médico. Códigos de NIH Clinical Tables (ICD-10-CM).';

  @override
  String get diagnosesDone => 'Listo';

  @override
  String get allergiesKindDrug => 'Medicamento';

  @override
  String get allergiesKindFood => 'Alimento';

  @override
  String get allergiesKindMaterial => 'Material';

  @override
  String get allergiesKindOther => 'Otro';

  @override
  String get allergiesSearchDrugHint => 'Busque un medicamento o una clase…';

  @override
  String get allergiesSearchFoodHint => 'Busque alérgenos alimentarios…';

  @override
  String get allergiesSearchMaterialHint => 'Busque alérgenos de materiales…';

  @override
  String get allergiesSearchOtherHint => 'Busque otros alérgenos…';

  @override
  String allergiesAddedToNeverWant(String name) {
    return 'Se añadió $name a “Medicamentos que nunca quiero”.';
  }

  @override
  String get allergiesCodeSevere => 'GRAVE';

  @override
  String get allergiesCodeModerate => 'MOD';

  @override
  String get allergiesCodeMild => 'LEVE';

  @override
  String get allergiesHelpText =>
      'Indique sus alergias a medicamentos, sensibilidades y reacciones adversas previas. El personal de urgencias revisa esta sección primero. Gravedad = Leve / Moderada / Grave. Las alergias y la lista \"Medicamentos que nunca quiero\" son secciones separadas: añada allí usted mismo cualquier medicamento que rechace.';

  @override
  String get allergiesAddSection => 'Añadir una alergia';

  @override
  String get allergiesSourceRxTerms => 'RxTerms · tablas clínicas de la NLM';

  @override
  String get allergiesSourceIcd => 'ICD-10-CM · tablas clínicas de la NLM';

  @override
  String get allergiesNoResults => 'No se encontraron resultados.';

  @override
  String get allergiesSourceNote =>
      'Las alergias a medicamentos se buscan en RxTerms. Las alergias a alimentos, materiales y otras se buscan en CIE-10 (p. ej., Z91.01 alergia alimentaria, T78.4 alergia no especificada).';

  @override
  String get allergiesSeveritySection => 'Gravedad y reacción';

  @override
  String get allergiesHowSerious => '¿Qué tan grave es?';

  @override
  String get allergiesWhatHappens => 'Qué ocurre';

  @override
  String get allergiesReactionsHint =>
      'p. ej., urticaria, hinchazón, cierre de garganta';

  @override
  String get allergiesAddButton => 'Añadir alergia';

  @override
  String allergiesAddedOne(int count) {
    return 'Añadida · $count alergia';
  }

  @override
  String allergiesAddedMany(int count) {
    return 'Añadidas · $count alergias';
  }

  @override
  String get allergiesFooter =>
      'No está obligado a indicar nada. Lo que indique solo se comparte con las personas que nombra en su directiva.';

  @override
  String get allergiesClearSearch => 'Borrar búsqueda';

  @override
  String allergiesMatches(int count) {
    return '$count coincidencias';
  }

  @override
  String get allergiesSeverityMild => 'Leve';

  @override
  String get allergiesSeverityMildDesc =>
      'sarpullido, molestias digestivas leves';

  @override
  String get allergiesSeverityModerate => 'Moderada';

  @override
  String get allergiesSeverityModerateDesc => 'urticaria, hinchazón';

  @override
  String get allergiesSeveritySevere => 'Grave';

  @override
  String get allergiesSeveritySevereDesc => 'anafilaxia · urgencias';

  @override
  String allergiesSeveritySemantics(String label) {
    return 'Gravedad: $label';
  }

  @override
  String medsStepMaxPerCategory(int max) {
    return 'Máximo $max medicamentos por categoría';
  }

  @override
  String get medsStepHelpText =>
      'Indique los medicamentos por su nombre. Sus preferencias se aplican a los equivalentes genéricos, de marca y comerciales, salvo que indique lo contrario en las notas; para pedir solo la versión de marca, anótelo en el campo de motivo.\n\nLos medicamentos de índice terapéutico estrecho (NTI), que tienen un margen de seguridad pequeño entre una dosis útil y una dañina, como el litio, la carbamazepina y el ácido valproico, no pueden sustituirse por genéricos según la ley de PA (35 P.S. §960.3). Aparecen con la etiqueta \"NTI\" al buscarlos.';

  @override
  String get medsStepHeadsUpLead => 'Atención: ';

  @override
  String get medsStepHeadsUpBody =>
      'su rechazo de un medicamento y los límites que ponga a su uso son obligatorios según la Ley 194 de PA, pero ';

  @override
  String get medsStepHeadsUpBold =>
      'las instrucciones de dosis específicas no son obligatorias';

  @override
  String get medsStepHeadsUpTail =>
      ' para el médico: es él quien elige la dosis.';

  @override
  String get medsStepAgentDecides =>
      'He designado a un agente para que tome decisiones sobre mis medicamentos';

  @override
  String get medsStepCurrentTitle => 'Medicamentos que tomo actualmente';

  @override
  String get medsStepCurrentSubtitle =>
      'Como referencia para su equipo de atención, no es una preferencia';

  @override
  String get medsStepNeverTitle => 'Medicamentos que NUNCA quiero';

  @override
  String get medsStepNeverSubtitle =>
      'Estos medicamentos no deben administrarse';

  @override
  String get medsStepLimitTitle => 'Medicamentos con limitaciones';

  @override
  String get medsStepLimitSubtitle =>
      'Pueden administrarse, pero con restricciones';

  @override
  String get medsStepPreferredTitle => 'Medicamentos preferidos';

  @override
  String get medsStepPreferredSubtitle =>
      'Medicamentos que le han funcionado bien';

  @override
  String get medsStepSideEffectsTitle =>
      'Efectos secundarios que podría estar teniendo';

  @override
  String get medsStepSideEffectsBody =>
      'Para los medicamentos que toma ahora, lea los efectos secundarios e interacciones oficiales de la FDA; no necesita IA. Con el asistente de IA opcional también obtiene una lista breve para marcar, para que su equipo de atención sepa qué afecta sus actividades diarias. No es consejo médico.';

  @override
  String medsStepNtiNote(String note) {
    return 'Medicamento de índice terapéutico estrecho: $note. La ley de Pensilvania prohíbe sustituirlo por un genérico; indique abajo cualquier necesidad de control. (Informativo, no es consejo médico).';
  }

  @override
  String get medsStepDosageLabel => 'Dosis (p. ej., 20 mg dos veces al día)';

  @override
  String get medsStepReasonLabel => 'Motivo / notas (opcional)';

  @override
  String medsStepLearnAbout(String name) {
    return 'Información sobre $name';
  }

  @override
  String get medsStepMedlineInfo =>
      'Información en lenguaje sencillo (MedlinePlus)';

  @override
  String get medsStepFdaInfo =>
      'Etiqueta oficial de la FDA (efectos secundarios e interacciones)';

  @override
  String get medsStepRemoveDefault => 'Quitar medicamento';

  @override
  String medsStepRemoveNamed(String name) {
    return 'Quitar $name';
  }

  @override
  String medsStepAddToList(String title) {
    return 'Añadir un medicamento a la lista $title';
  }

  @override
  String get medsStepAddButton => 'Añadir medicamento';

  @override
  String get facilityRoommateWomen => 'Mujeres';

  @override
  String get facilityRoommateMen => 'Hombres';

  @override
  String get facilityRoommateSameAsIdentity =>
      'Del mismo género con el que me identifico';

  @override
  String get facilityRoommateSpecify => 'Quiero especificarlo';

  @override
  String get facilityHelpText =>
      'Puede indicar los centros de tratamiento que prefiere o que quiere evitar. Estas preferencias orientan a su agente y a sus proveedores de tratamiento, pero no siempre será posible respetarlas. Ambas secciones son opcionales.';

  @override
  String get facilityNoPreferenceBanner =>
      'Deje ambas secciones vacías si no tiene preferencia. Su directiva indicará \"Sin preferencia\" en cuanto a centros de tratamiento.';

  @override
  String get facilityPreferredTitle => 'Centros preferidos';

  @override
  String get facilityPreferredSubtitle =>
      'Centros donde preferiría recibir tratamiento';

  @override
  String get facilityAvoidTitle => 'Centros que prefiero evitar';

  @override
  String get facilityAvoidSubtitle =>
      'Centros donde no quiere recibir tratamiento';

  @override
  String get facilityOtherRoomPrefsLabel => 'Otras preferencias de habitación';

  @override
  String get facilityOtherRoomPrefsHint =>
      'Cualquier otra cosa sobre su habitación o entorno; p. ej., poca luz, cerca de una ventana, lejos de zonas ruidosas…';

  @override
  String get facilityRoomSingle => 'Habitación individual';

  @override
  String get facilityRoomWindow => 'Con ventana si es posible';

  @override
  String get facilityRoomQuietFloor => 'Piso tranquilo';

  @override
  String get facilityRoomSameGender =>
      'Compañero de habitación del mismo género';

  @override
  String get facilityRoomNoRoommate => 'Sin compañero de habitación';

  @override
  String get facilityRoomTransAffirming =>
      'Personal que respete a las personas trans';

  @override
  String get facilityRoomLowStimulation => 'Unidad de baja estimulación';

  @override
  String get facilityRoomPrefsTitle => 'Preferencias de habitación';

  @override
  String get facilityRoomPrefsSubtitle =>
      'Opcional: orienta al personal si hay opciones disponibles.';

  @override
  String get facilityRoommateMatchPrompt =>
      'Para \"compañero de habitación del mismo género\", asígnenme con:';

  @override
  String get facilityMatchMeWithLabel => 'Asígnenme con';

  @override
  String get facilityMatchMeWithHint =>
      'Describa su preferencia sobre el compañero de habitación';

  @override
  String get facilityNameLabel => 'Nombre del centro';

  @override
  String get facilityNameHint => 'Escriba para buscar centros';

  @override
  String get facilityLocationLabel => 'Ubicación (opcional)';

  @override
  String get facilityLocationHint => 'p. ej., 123 Main St, Philadelphia, PA';

  @override
  String get facilityRemoveTooltip => 'Quitar centro';

  @override
  String facilityAddToSemantics(String title) {
    return 'Añadir un centro a $title';
  }

  @override
  String get facilityAddButton => 'Añadir centro';

  @override
  String get facilityNpiAttribution =>
      'Nombres de centros del registro NPI (NIH Clinical Tables). Verifique los datos antes de confiar en ellos.';

  @override
  String get addlInstrHelpText =>
      'Todas estas secciones son opcionales. Úselas para orientar a su agente y a su equipo de tratamiento más allá de las preferencias básicas anteriores.';

  @override
  String get addlInstrExampleFieldName => 'Instrucciones adicionales';

  @override
  String get addlInstrExample1 =>
      'Escuchar música tranquila y salir a caminar me ayuda en momentos de angustia. Por favor, permítanme usar mi reproductor de música personal.';

  @override
  String get addlInstrExample2 =>
      'Soy vegetariano por motivos religiosos. Por favor, asegúrense de respetar mis necesidades alimentarias durante cualquier hospitalización. También me gustaría tener acceso a un capellán o consejero espiritual.';

  @override
  String get addlInstrExample3 =>
      'Por favor, avisen a mi hermana, Jane Doe, si me ingresan. No contacten a mi excónyuge bajo ninguna circunstancia. Mi terapeuta, el Dr. Smith, debe ser informado de cualquier cambio en el tratamiento.';

  @override
  String get addlInstrActivitiesTitle => 'Actividades y entorno';

  @override
  String get addlInstrActivitiesHint =>
      'Preferencias sobre actividades diarias, entorno, sujeción y aislamiento';

  @override
  String get addlInstrActivitiesDescription =>
      'Describa las actividades que le ayudan a sentirse mejor (p. ej., caminar, leer, música) y sus preferencias sobre el entorno físico durante el tratamiento. También puede indicar si consiente o rechaza el uso de sujeción (ser inmovilizado físicamente o atado, o recibir medicamentos para restringir su movimiento o conducta, lo que se llama \"sujeción química\") o de aislamiento (ser confinado solo en una habitación).';

  @override
  String get addlInstrCrisisTitle => 'Intervención en crisis';

  @override
  String get addlInstrCrisisHint =>
      'Qué ayuda y qué no ayuda durante una crisis';

  @override
  String get addlInstrCrisisDescription =>
      'Según su experiencia, describa qué le ayuda durante una crisis de salud mental y qué empeora las cosas. Esto ayuda a su equipo de tratamiento a responder de la manera que mejor funcione para usted.';

  @override
  String get addlInstrDeescTitle => 'Técnicas para calmarse';

  @override
  String get addlInstrDeescHint =>
      'p. ej., música, respiración profunda, habitación tranquila, manta con peso';

  @override
  String get addlInstrDeescDescription =>
      'Indique técnicas o estrategias específicas que le ayudan a calmarse cuando está angustiado. Por ejemplo: escuchar música, respirar profundamente, estar en una habitación tranquila, usar una manta con peso, hablar con una persona en particular o salir a caminar.';

  @override
  String get addlInstrTriggersTitle => 'Posibles desencadenantes de crisis';

  @override
  String get addlInstrTriggersHint =>
      'p. ej., lugares ruidosos, ciertos temas, estar solo';

  @override
  String get addlInstrTriggersDescription =>
      'Identifique situaciones, entornos o temas que puedan desencadenar o empeorar una crisis. Esto ayuda a su equipo de tratamiento a evitarlos. Por ejemplo: lugares ruidosos, que lo toquen sin permiso, ciertos temas de conversación, quedarse solo o personas específicas.';

  @override
  String get addlInstrHealthHistoryTitle => 'Antecedentes de salud';

  @override
  String get addlInstrHealthHistoryHint =>
      'Antecedentes de salud mental relevantes, diagnósticos, hospitalizaciones';

  @override
  String get addlInstrHealthHistoryDescription =>
      'Resuma sus antecedentes de salud mental relevantes, incluidos diagnósticos previos, hospitalizaciones y tratamientos que funcionaron bien o que no funcionaron. Esto le da contexto a su equipo de tratamiento sobre su historial de atención.';

  @override
  String get addlInstrDietaryTitle => 'Preferencias alimentarias';

  @override
  String get addlInstrDietaryHint =>
      'Restricciones y preferencias alimentarias, normas religiosas sobre la alimentación';

  @override
  String get addlInstrDietaryDescription =>
      'Indique cualquier alergia alimentaria, restricción o preferencia que su equipo de tratamiento deba conocer. Esto incluye normas religiosas sobre la alimentación (p. ej., kosher, halal, vegetariana), intolerancias alimentarias y alimentos que deba evitar por interacciones con medicamentos.';

  @override
  String get addlInstrReligiousTitle => 'Religión y espiritualidad';

  @override
  String get addlInstrReligiousHint =>
      'Prácticas religiosas, necesidades espirituales, contacto con un religioso';

  @override
  String get addlInstrReligiousDescription =>
      'Describa las prácticas religiosas o espirituales que son importantes para usted durante el tratamiento. Puede incluir horarios de oración, visitas de un religioso o capellán, textos u objetos religiosos a los que quiera tener acceso, ayunos o prácticas de afrontamiento basadas en la fe.';

  @override
  String get addlInstrChildrenTitle => 'Hijos y custodia';

  @override
  String get addlInstrChildrenHint =>
      'Instrucciones sobre el cuidado de sus hijos menores';

  @override
  String get addlInstrChildrenDescription =>
      'Si tiene hijos menores o dependientes, describa quién debe cuidarlos si usted es hospitalizado. Incluya los datos de contacto de los cuidadores, información de la escuela y cualquier acuerdo de custodia que su equipo de tratamiento deba conocer.';

  @override
  String get addlInstrFamilyNotifyTitle => 'Aviso a la familia';

  @override
  String get addlInstrFamilyNotifyHint => 'A quién se debe avisar y cómo';

  @override
  String get addlInstrFamilyNotifyDescription =>
      'Indique a quién se debe avisar si usted es hospitalizado o si cambia su tratamiento. Incluya cómo comunicarse con esas personas y qué información se puede compartir. También puede indicar a quién NO se debe contactar.';

  @override
  String get addlInstrPetCareTitle => 'Cuidado de mascotas';

  @override
  String get addlInstrPetCareHint =>
      'Instrucciones para el cuidado de sus mascotas';

  @override
  String get addlInstrPetCareDescription =>
      'Si tiene mascotas, describa quién debe cuidarlas si usted es hospitalizado. Incluya los datos de contacto del cuidador, los horarios de alimentación y medicamentos, los contactos del veterinario y cualquier instrucción especial.';

  @override
  String get addlInstrReproTitle => 'Atención de salud reproductiva';

  @override
  String get addlInstrReproHint => 'Pruebas de embarazo, anticoncepción, etc.';

  @override
  String get addlInstrReproDescription =>
      'Describa cualquier preferencia de atención de salud reproductiva que su equipo de tratamiento deba conocer. Puede incluir si desea una prueba de embarazo antes de cambios en los medicamentos, preferencias de anticoncepción o condiciones de salud reproductiva que podrían afectar su tratamiento.';

  @override
  String get addlInstrOtherTitle => 'Otras instrucciones';

  @override
  String get addlInstrOtherHint =>
      'Cualquier otra instrucción no incluida arriba';

  @override
  String get addlInstrOtherDescription =>
      'Use esta sección para cualquier instrucción para su equipo de tratamiento o su agente que no esté incluida en las secciones anteriores. Sirve para todo lo demás que quiera comunicar sobre sus preferencias de atención.';

  @override
  String get addlInstrRecordsTitle => 'Divulgación de registros y limitaciones';

  @override
  String get addlInstrRecordsDescription =>
      'Elija quién puede recibir copias de sus registros de salud mental y quién no. Según 20 Pa.C.S. § 5836(e), la autorización de divulgación que otorgue aquí puede prevalecer sobre ciertas protecciones de confidencialidad (incluidas las leyes de confidencialidad sobre drogas y alcohol, procedimientos de salud mental y VIH), así que sea específico.';

  @override
  String get addlInstrRecordsReleaseLabel =>
      'Quién puede recibir mis registros';

  @override
  String get addlInstrRecordsReleaseHint =>
      'p. ej., mi agente Jane Doe; mi equipo de tratamiento; el Dr. Smith';

  @override
  String get addlInstrRecordsWithholdLabel =>
      'Quién NO debe recibir mis registros';

  @override
  String get addlInstrRecordsWithholdHint =>
      'p. ej., mi excónyuge; ciertos familiares';

  @override
  String get addlInstrRecordsOtherLabel =>
      'Otras limitaciones a la divulgación';

  @override
  String get addlInstrRecordsOtherHint =>
      'p. ej., divulgar solo los registros de los últimos 12 meses';

  @override
  String get addlInstrOptionalAddOns => 'Complementos opcionales';

  @override
  String get addlInstrCrisisPlanTitle => 'Plan de crisis';

  @override
  String get addlInstrCrisisPlanSubtitle =>
      'Sus señales de alerta temprana, desencadenantes, lo que realmente ayuda y lo que no se debe hacer. La Ley 194 no lo exige, pero es lo primero que leen los agentes y el personal de urgencias.';

  @override
  String get addlInstrUlyssesTitle =>
      'Cláusula de autovinculación (cláusula Ulises)';

  @override
  String get addlInstrUlyssesSubtitle =>
      'Reconozca que, una vez que dos profesionales determinen que usted no tiene capacidad, lo que escribió se mantiene incluso si usted protesta en ese momento, hasta que recupere la capacidad (20 Pa.C.S. §§ 5824, 5834).';

  @override
  String get effCondHelpText =>
      'Describa las circunstancias en las que quiere que esta directiva entre en vigor; por ejemplo, \"cuando dos profesionales calificados certifiquen que no tengo capacidad para tomar decisiones sobre mi tratamiento\". Según la Ley 194 de PA, la declaración entra en vigor cuando un psiquiatra y uno de los siguientes certifican que usted no tiene capacidad: otro psiquiatra, un psicólogo con licencia, su médico de familia, su médico tratante u otro profesional de tratamiento de salud mental.';

  @override
  String get effCondTakeEffectWhen =>
      'Esta directiva debe entrar en vigor cuando…';

  @override
  String get effCondTriggerTwoTitle =>
      'Un psiquiatra y otro profesional determinen que no tengo capacidad';

  @override
  String get effCondTriggerTwoSubtitle =>
      'El criterio habitual de la Ley 194 de PA: dos profesionales calificados certifican que usted no puede tomar decisiones sobre su tratamiento de salud mental.';

  @override
  String get effCondTriggerCourtTitle =>
      'Un tribunal determine que no tengo capacidad';

  @override
  String get effCondTriggerCommitTitle => 'Me internen de forma involuntaria';

  @override
  String get effCondAnythingElseTitle =>
      'Algo más sobre cuándo entra en vigor (opcional)';

  @override
  String get effCondAnythingElseSubtitle =>
      'Escriba con sus propias palabras o elija un ejemplo para empezar.';

  @override
  String get effCondExampleFieldName => 'Condición de vigencia';

  @override
  String get effCondExample1 =>
      'Esta directiva entra en vigor cuando yo no pueda tomar por mí mismo decisiones sobre mi tratamiento de salud mental, según lo determinen dos profesionales calificados.';

  @override
  String get effCondExample2 =>
      'Esta directiva entra en vigor siempre que me ingresen en un centro psiquiátrico o una unidad de crisis, ya sea de forma voluntaria o involuntaria, y yo no pueda comunicar claramente mis deseos.';

  @override
  String get effCondExample3 =>
      'Esta directiva entra en vigor cuando esté atravesando un episodio grave de psicosis, manía o disociación que me impida entender mis opciones de tratamiento o comunicar mis preferencias.';

  @override
  String get effCondExample4 =>
      'Esta directiva entra en vigor cuando le diga a mi agente o a mi proveedor de tratamiento que quiero activarla, o cuando no pueda tomar decisiones coherentes e informadas sobre mi atención de salud mental.';

  @override
  String get effCondExample5 =>
      'Esta directiva entra en vigor cuando mi agente designado, en consulta con cualquier profesional tratante, determine que me beneficiaría que se sigan las preferencias de tratamiento que dejé indicadas.';

  @override
  String get effCondOwnWordsLabel => 'Con sus propias palabras (opcional)';

  @override
  String get effCondDoctorTitle =>
      'Médico preferido para la evaluación (opcional)';

  @override
  String get effCondDoctorSubtitle =>
      'Si tiene un médico preferido para evaluar su capacidad, ingrese sus datos abajo.';

  @override
  String get effCondDoctorNameLabel => 'Nombre del médico';

  @override
  String get effCondDoctorContactLabel => 'Dirección / número de teléfono';

  @override
  String get consentChoiceEctSectionLabel => 'CONSENTIMIENTO PARA TRATAMIENTO';

  @override
  String get consentChoiceEctTitle => 'Terapia electroconvulsiva (TEC)';

  @override
  String get consentChoiceEctSubtitle =>
      'La TEC es un tratamiento psiquiátrico en el que se inducen convulsiones mediante electricidad. Indique sus preferencias abajo.';

  @override
  String get consentChoiceEctHelpText =>
      'La TEC puede ser un tratamiento eficaz para la depresión grave y otras condiciones. Según la ley de PA, usted puede consentir por adelantado, rechazarla por adelantado o establecer condiciones.';

  @override
  String get consentChoiceEctInfoBannerText =>
      'Según la Ley 194 de PA, su agente no puede consentir a la TEC a menos que usted lo autorice expresamente aquí.';

  @override
  String get consentChoiceEctNoTitle => 'No consiento a la TEC';

  @override
  String get consentChoiceEctNoDescription => 'No se me debe aplicar la TEC.';

  @override
  String get consentChoiceEctYesTitle => 'Consiento a la TEC';

  @override
  String get consentChoiceEctYesDescription =>
      'Mi proveedor puede aplicar la TEC si está indicada.';

  @override
  String get consentChoiceEctAgentTitle => 'Mi agente decidirá sobre la TEC';

  @override
  String get consentChoiceEctAgentDescription =>
      'Autorice a su agente a consentir o rechazar la TEC en su nombre.';

  @override
  String get consentChoiceEctConditionalHint =>
      'p. ej., solo si otros tratamientos no han funcionado y mi agente está de acuerdo';

  @override
  String get consentChoiceExperimentalSectionLabel =>
      'CONSENTIMIENTO PARA INVESTIGACIÓN';

  @override
  String get consentChoiceExperimentalTitle => 'Estudios experimentales';

  @override
  String get consentChoiceExperimentalSubtitle =>
      'Indique sus preferencias sobre participar en investigaciones experimentales durante el tratamiento de salud mental.';

  @override
  String get consentChoiceExperimentalHelpText =>
      'Usted tiene derecho a consentir o a negarse a participar en investigaciones experimentales. Sus preferencias aquí orientarán a su equipo de atención y a su agente.';

  @override
  String get consentChoiceExperimentalInfoBannerText =>
      'Según la Ley 194 de PA, su agente no puede consentir a investigaciones experimentales a menos que usted lo autorice expresamente aquí.';

  @override
  String get consentChoiceExperimentalNoDescription =>
      'Me niego a participar en estudios experimentales.';

  @override
  String get consentChoiceExperimentalYesTitle =>
      'Consiento a participar en estudios experimentales';

  @override
  String get consentChoiceExperimentalYesDescription =>
      'Estoy dispuesto a participar en estudios de investigación durante el tratamiento.';

  @override
  String get consentChoiceExperimentalConditionalHint =>
      'p. ej., solo estudios no invasivos aprobados por mi agente';

  @override
  String get consentChoiceDrugTrialsSectionLabel => 'ENSAYOS CLÍNICOS';

  @override
  String get consentChoiceDrugTrialsTitle => 'Ensayos de medicamentos';

  @override
  String get consentChoiceDrugTrialsSubtitle =>
      'Indique sus preferencias sobre participar en ensayos clínicos de medicamentos durante el tratamiento de salud mental.';

  @override
  String get consentChoiceDrugTrialsHelpText =>
      'Los ensayos clínicos de medicamentos prueban medicamentos nuevos. Puede consentir, negarse o establecer condiciones para su participación.';

  @override
  String get consentChoiceDrugTrialsInfoBannerText =>
      'Según la Ley 194 de PA, su agente no puede consentir a ensayos de medicamentos a menos que usted lo autorice expresamente aquí.';

  @override
  String get consentChoiceDrugTrialsNoDescription =>
      'Me niego a participar en ensayos de medicamentos.';

  @override
  String get consentChoiceDrugTrialsYesTitle =>
      'Consiento a participar en ensayos de medicamentos';

  @override
  String get consentChoiceDrugTrialsYesDescription =>
      'Estoy dispuesto a participar en ensayos clínicos de medicamentos.';

  @override
  String get consentChoiceDrugTrialsConditionalHint =>
      'p. ej., solo ensayos con un supervisor de seguridad independiente';

  @override
  String get consentChoiceConditionalTitle =>
      'Consiento bajo condiciones específicas';

  @override
  String get consentChoiceConditionalDescription =>
      'Describa las condiciones en el cuadro de abajo.';

  @override
  String get consentChoiceConditionsLabel => 'Condiciones';

  @override
  String get consentChoiceNoConsentTitle => 'No consiento';

  @override
  String get consentChoiceAgentDecidesTitle => 'Mi agente decidirá';

  @override
  String get consentChoiceAgentDecidesDescription =>
      'Autorice a su agente a consentir o rechazar en su nombre.';

  @override
  String get voiceInputOpenDictation => 'Abrir dictado por voz';

  @override
  String get voiceInputDictateText => 'Dictar texto';

  @override
  String get savedImportCouldNotRead => 'No se pudo leer ese archivo.';

  @override
  String get savedImportImportedAsDraft =>
      'Se importó como borrador editable. Después de revisarlo, vuelva a firmarlo y a reunir testigos para que sea válido de nuevo; la firma anterior no se conserva.';

  @override
  String get contactPickerBtnMissingName => 'nombre';

  @override
  String get contactPickerBtnMissingAddress => 'dirección';

  @override
  String get contactPickerBtnMissingPhone => 'número de teléfono';

  @override
  String contactPickerBtnMissingFields(String fields) {
    return 'Al contacto le falta: $fields. Complete manualmente los campos que faltan.';
  }

  @override
  String get contactPickerBtnImportA11y => 'Importar de contactos';

  @override
  String get contactPickerBtnImport => 'Importar de Contactos';

  @override
  String medAutoSelectA11y(String name) {
    return 'Seleccionar el medicamento $name';
  }

  @override
  String medAutoSelectNtiA11y(String name) {
    return 'Seleccionar el medicamento $name, medicamento de índice terapéutico estrecho';
  }

  @override
  String get medAutoNtiTooltip =>
      'Medicamento de índice terapéutico estrecho (NTI): no se permite sustituirlo por un genérico en PA';

  @override
  String get medAutoNtiBadge => 'NTI';

  @override
  String medAutoSelectStrengthA11y(String medication) {
    return 'Seleccionar $medication';
  }

  @override
  String get medAutoFieldLabel => 'Nombre del medicamento';

  @override
  String get medAutoSearchingA11y => 'Buscando medicamentos';

  @override
  String get wizardHelpA11y => 'Ayuda para este paso. Abre la hoja de ayuda.';

  @override
  String get wizardHelpButton => 'Ayuda';

  @override
  String get wizardHelpLearnMore => 'Más información';

  @override
  String wizardHelpQuestionsContact(String phone) {
    return '¿Preguntas? Comuníquese con PA Protection & Advocacy: $phone';
  }

  @override
  String get neverWantCrossAddTitle =>
      '¿Añadir a “Medicamentos que nunca quiero”?';

  @override
  String get neverWantCrossAddBodySingle =>
      'Indicó una alergia a un medicamento. ¿También quiere rechazarlo como medicamento y añadirlo a su lista “Medicamentos que nunca quiero”?';

  @override
  String get neverWantCrossAddBodyMulti =>
      'Indicó estas alergias a medicamentos. Elija las que también quiera rechazar como medicamentos; se añadirán a su lista “Medicamentos que nunca quiero”.';

  @override
  String get neverWantCrossAddNotNow => 'Ahora no';

  @override
  String get neverWantCrossAddConfirmSingle => 'Añadir a la lista';

  @override
  String get neverWantCrossAddConfirmMulti => 'Añadir los seleccionados';

  @override
  String get exampleTextSeeExamples => 'Ver ejemplos';

  @override
  String exampleTextTitle(String fieldName) {
    return 'Ejemplo: $fieldName';
  }

  @override
  String get exampleTextIntro =>
      'Estos son algunos ejemplos de lo que otras personas han escrito. Use sus propias palabras para describir sus preferencias.';

  @override
  String exampleTextNumbered(int number) {
    return 'Ejemplo $number';
  }

  @override
  String get exampleTextDisclaimer =>
      'Son solo ejemplos. Su directiva debe reflejar sus propios deseos y circunstancias.';

  @override
  String get exampleTextGotIt => 'Entendido';

  @override
  String get quizQ1Headline =>
      '¿Tiene a alguien en mente que **hable por usted**?';

  @override
  String get quizQ1Sub =>
      'Un familiar, pareja o amigo cercano que pueda tomar decisiones sobre su tratamiento si usted no puede.';

  @override
  String get quizQ1O1Label => 'Sí, y confío plenamente en esa persona';

  @override
  String get quizQ1O1Hint =>
      'Probablemente le convenga un formulario Combinado o solo de Poder Notarial.';

  @override
  String get quizQ1O2Label => 'Sí, pero quiero poner límites firmes';

  @override
  String get quizQ1O2Hint =>
      'El Combinado le da tanto un agente como una declaración obligatoria.';

  @override
  String get quizQ1O3Label =>
      'No, quiero que los proveedores sigan mis deseos por escrito';

  @override
  String get quizQ1O3Hint => 'Solo Declaración es para usted.';

  @override
  String get quizQ1O4Label => 'Todavía no estoy seguro';

  @override
  String get quizQ1O4Hint => 'No hay problema; podemos volver a esto.';

  @override
  String get quizQ2Headline =>
      '¿Quiere **dejar por escrito** preferencias de tratamiento específicas?';

  @override
  String get quizQ2Sub =>
      'Medicamentos, centros, TEC, estudios experimentales, ensayos de medicamentos.';

  @override
  String get quizQ2O1Label =>
      'Sí, hay cosas concretas que quiero o que rechazo';

  @override
  String get quizQ2O1Hint =>
      'Probablemente le convenga un formulario Combinado o de Declaración.';

  @override
  String get quizQ2O2Label =>
      'Algunas preferencias, pero prefiero que decida mi agente';

  @override
  String get quizQ2O2Hint =>
      'El Combinado también sirve: el agente decide en lo que usted no escribió.';

  @override
  String get quizQ2O3Label => 'No, que mi agente o los médicos decidan todo';

  @override
  String get quizQ2O3Hint => 'Solo Poder Notarial es la opción más sencilla.';

  @override
  String get quizQ2O4Label => 'Todavía no estoy seguro';

  @override
  String get quizQ2O4Hint =>
      'No hay problema; el Combinado deja ambas opciones abiertas.';

  @override
  String get quizQ3Headline =>
      'Si usted no puede decidir, ¿**qué voz** debe llegar primero a los médicos?';

  @override
  String get quizQ3Sub =>
      '¿La directiva que escribe hoy o la persona en quien confía?';

  @override
  String get quizQ3O1Label =>
      'Lo que escribí, incluso por encima de lo que alguien diga en ese momento';

  @override
  String get quizQ3O1Hint =>
      'Solo Declaración, o Combinado con preferencias escritas sólidas.';

  @override
  String get quizQ3O2Label =>
      'Mi agente, que puede evaluar la situación en el momento';

  @override
  String get quizQ3O2Hint =>
      'Solo Poder Notarial, o Combinado con amplia autoridad para el agente.';

  @override
  String get quizQ3O3Label =>
      'Ambos: lo que escribí, y mi agente completa lo que falte';

  @override
  String get quizQ3O3Hint => 'El Combinado es la opción que mejor encaja.';

  @override
  String get quizQ3O4Label => 'Todavía no estoy seguro';

  @override
  String get quizQ3O4Hint =>
      'No hay problema; el Combinado admite ambos caminos.';

  @override
  String get quizQ4Headline =>
      '¿Qué es lo **más importante** que este documento hace por usted?';

  @override
  String get quizQ4Sub =>
      'No hay respuestas incorrectas; esto solo confirma lo que vemos.';

  @override
  String get quizQ4O1Label =>
      'Nombra a las personas en quienes confío para hablar por mí';

  @override
  String get quizQ4O1Hint => 'Combinado o solo Poder Notarial.';

  @override
  String get quizQ4O2Label =>
      'Deja fijados los tratamientos concretos que quiero o que rechazo';

  @override
  String get quizQ4O2Hint => 'Combinado o solo Declaración.';

  @override
  String get quizQ4O3Label => 'Ambas cosas, por igual';

  @override
  String get quizQ4O3Hint => 'Combinado.';

  @override
  String get quizQ4O4Label => 'Simplemente tener algo registrado';

  @override
  String get quizQ4O4Hint =>
      'Cualquier formulario sirve. El Combinado ofrece la cobertura más amplia.';

  @override
  String quizQuestionEyebrow(int current, int total) {
    return 'Ayúdeme a elegir · pregunta $current de $total';
  }

  @override
  String get quizInYourWords => 'Con sus palabras';

  @override
  String get quizResultEyebrow => 'Ayúdeme a elegir · resultado';

  @override
  String get quizRecommendedForYou => 'Recomendado para usted';

  @override
  String get quizYouProbablyWant => 'Probablemente le convenga\n';

  @override
  String get quizLegendCombined => 'Combinado';

  @override
  String get quizLegendDeclaration => 'Solo Declaración';

  @override
  String get quizLegendPoa => 'Solo Poder Notarial';

  @override
  String get quizRetake => 'Repetir';

  @override
  String quizUseForm(String formName) {
    return 'Usar $formName';
  }

  @override
  String get quizFormNameCombined => 'Combinado';

  @override
  String get quizFormNameDeclaration => 'Declaración';

  @override
  String get quizFormNamePoa => 'Poder Notarial';

  @override
  String get quizExplainCombined =>
      'Incluye sus preferencias de tratamiento Y la designación de un agente. Es la opción más completa y la que elige la mayoría de las personas.';

  @override
  String get quizExplainPoa =>
      'Designa a un agente para que tome decisiones por usted, sin fijar preferencias de tratamiento específicas. Es mejor cuando confía plenamente en alguien y quiere que esa persona decida en el momento.';

  @override
  String get quizExplainDeclaration =>
      'Documenta sus preferencias de tratamiento sin nombrar a un agente. Su equipo de tratamiento seguirá directamente sus deseos por escrito.';

  @override
  String get aiSuggestDraftTitle => 'Borrador de la IA';

  @override
  String get aiSuggestSuggestionTitle => 'Sugerencia de la IA';

  @override
  String get aiSuggestYourText => 'Su texto:';

  @override
  String get aiSuggestDraftLabel => 'Borrador de la IA:';

  @override
  String get aiSuggestSuggestionLabel => 'Sugerencia de la IA:';

  @override
  String aiSuggestReviewCarefully(String notAdvice) {
    return '$notAdvice Revíselo con cuidado.';
  }

  @override
  String get aiSuggestDismiss => 'Descartar';

  @override
  String get aiSuggestAddToMine => 'Añadir a lo mío';

  @override
  String get aiSuggestUseDraft => 'Usar este borrador';

  @override
  String get aiSuggestUseInstead => 'Usar en su lugar';

  @override
  String get aiSuggestAppliedA11y =>
      'Se aplicó la sugerencia de la IA. Puede deshacerla.';

  @override
  String get aiSuggestApplied => 'Se aplicó la sugerencia de la IA.';

  @override
  String get aiSuggestUndo => 'Deshacer';

  @override
  String aiSuggestLoadingA11y(String fieldName) {
    return 'Sugerencia de IA, cargando una sugerencia para $fieldName';
  }

  @override
  String aiSuggestForFieldA11y(String fieldName) {
    return 'Sugerencia de IA para $fieldName';
  }

  @override
  String get aiSuggestSetupA11y =>
      'Configure el Asistente de IA para usar sugerencias';

  @override
  String get aiSuggestTooltip =>
      'Obtener una sugerencia de la IA para este campo';

  @override
  String get aiSuggestSetupTooltip =>
      'Configure el Asistente de IA para usar esta función';

  @override
  String get aiSuggestIconTooltip => 'Sugerencia de la IA';

  @override
  String get contactSheetPermissionRequired =>
      'Se necesita permiso para acceder a los contactos para importar.';

  @override
  String get contactSheetRolePrimaryAgent => 'agente principal';

  @override
  String get contactSheetPickYour => 'Elija a su ';

  @override
  String get contactSheetLocalOnly =>
      'De los contactos de su teléfono. Nunca los subimos; la búsqueda se hace en su dispositivo.';

  @override
  String get contactSheetSearchHint => 'Buscar por nombre o número';

  @override
  String get contactSheetClearSearch => 'Borrar búsqueda';

  @override
  String contactSheetContactsCount(int count) {
    return 'Contactos · $count';
  }

  @override
  String get contactSheetPickAContact => 'Elija un contacto';

  @override
  String contactSheetUseName(String name) {
    return 'Usar a $name';
  }

  @override
  String get contactSheetThisContact => 'este contacto';

  @override
  String get contactSheetLooksLikeProvider => 'Parece un proveedor';

  @override
  String get contactSheetUnder18 => 'Menor de 18';

  @override
  String contactSheetWarnConfirm(String note) {
    return '⚠ $note: confirme que no le está dando tratamiento';
  }

  @override
  String get contactSheetEligible => '✓ Cumple los requisitos · 18+';

  @override
  String get contactSheetEnterManually => 'Ingresar a alguien manualmente';

  @override
  String get contactSheetHardBlock => 'bloqueo';

  @override
  String get contactSheetSoftWarn => 'advertencia';

  @override
  String get contactSheetRuleProvider =>
      'Su proveedor tratante actual o un empleado suyo';

  @override
  String get contactSheetRuleFacilityOwner =>
      'El propietario u operador de un centro donde usted recibe atención';

  @override
  String get contactSheetWhoCantBeAgent => 'Quién no puede ser su agente';

  @override
  String get contactSheetRulesFootnote =>
      'Los menores de 18 se bloquean automáticamente según la fecha de nacimiento del contacto. No podemos saber quiénes son sus proveedores, así que todo lo que parezca un proveedor es una advertencia que puede ignorar; confírmelo solo si realmente no le está dando tratamiento.';

  @override
  String get voiceMicPermission =>
      'Se necesita permiso para usar el micrófono.';

  @override
  String get voiceTranscribeFailed =>
      'No se pudo transcribir. Inténtelo de nuevo o escríbalo.';

  @override
  String get voiceSpeechError => 'Error del reconocimiento de voz.';

  @override
  String get voiceNeedsBrowser => 'La voz requiere Chrome, Edge o Safari.';

  @override
  String get voiceNotAvailable =>
      'El reconocimiento de voz no está disponible en este dispositivo.';

  @override
  String get voiceStatusTranscribing => '● Transcribiendo';

  @override
  String get voiceStatusRecording => '● Grabando';

  @override
  String get voiceStatusPaused => '● En pausa';

  @override
  String get voiceSayItYourWay => 'Dígalo a su manera.';

  @override
  String get voiceExplainAi =>
      'Para mayor precisión con nombres de medicamentos y condiciones, su grabación se envía a la IA de Google para transcribirla. Revise el texto antes de guardarlo.';

  @override
  String get voiceExplainBrowser =>
      'Para transcribir, su navegador envía el audio a su servicio de voz (a menudo, Google). No guardamos el audio ni el texto; edítelo antes de guardarlo.';

  @override
  String get voiceExplainDevice =>
      'Su dispositivo convierte la voz en texto. Nunca guardamos el audio; puede editar el texto antes de guardarlo.';

  @override
  String get voiceEmptyHintAi =>
      'Toque el botón rojo, hable y luego toque detener para transcribir…';

  @override
  String get voiceEmptyHintLive =>
      'Toque el botón rojo de grabar y empiece a hablar…';

  @override
  String get voiceCancelA11y => 'Cancelar la grabación de voz';

  @override
  String get voiceConfirmA11y => 'Confirmar y usar la transcripción';

  @override
  String get voiceFooterAi =>
      'NO GUARDAMOS NADA · LA IA DE GOOGLE TRANSCRIBE LA GRABACIÓN';

  @override
  String get voiceFooterBrowser =>
      'NO GUARDAMOS NADA · EL SERVICIO DE VOZ DE SU NAVEGADOR TRANSCRIBE EL AUDIO';

  @override
  String get voiceFooterDevice =>
      'EL AUDIO NO SE GUARDA · LA TRANSCRIPCIÓN SE QUEDA EN ESTA SESIÓN';

  @override
  String get voiceTranscribingCard => 'Transcribiendo su grabación…';

  @override
  String get voiceStopRecording => 'Detener la grabación';

  @override
  String get voiceStartRecording => 'Empezar a grabar';

  @override
  String get pipelineGeneratingSuggestions =>
      'La IA está generando sugerencias personalizadas...';

  @override
  String get pipelineNoAdditionalSuggestions =>
      'La IA no pudo generar sugerencias adicionales.';

  @override
  String pipelineAutofillProblem(String error) {
    return 'El autocompletado tuvo un problema. $error';
  }

  @override
  String pipelineAppliedA11y(int count) {
    return 'El autocompletado aplicó $count campos a su directiva';
  }

  @override
  String get pipelineAppliedNoneA11y =>
      'El autocompletado terminó; no se añadieron campos nuevos';

  @override
  String get pipelinePastedImage => 'Imagen pegada';

  @override
  String get pipelineDocument => 'Documento';

  @override
  String get pipelineKindPdf => 'PDF';

  @override
  String get pipelineKindPhoto => 'Foto';

  @override
  String get pipelineKindText => 'Texto';

  @override
  String get pipelineKindAudio => 'Audio';

  @override
  String get pipelineKindFile => 'Archivo';

  @override
  String get pipelineCancelled =>
      'Se canceló el procesamiento; no se aplicó nada.';

  @override
  String get pipelineSetupAiTitle => 'Configure la IA para leer documentos';

  @override
  String get pipelineSetupAiBody =>
      'Autocompletar con una foto usa la IA para leer el documento que usted sube (foto, PDF o texto) y extraer datos para completar su formulario: medicamentos, condiciones, preferencias de atención y sus datos de contacto. Necesita una clave de IA; configurar el nivel gratuito de Gemini toma unos 30 segundos. Usted revisa cada campo antes de que se añada a su formulario.';

  @override
  String get pipelineSetupAi => 'Configurar la IA';

  @override
  String get pipelineDroppedFile => 'Archivo soltado';

  @override
  String get pipelineUnsupportedType =>
      'Ese tipo de archivo no es compatible. Use un archivo JPG, PNG, HEIC, PDF o de texto.';

  @override
  String pipelineRpmLimit(int pages, int remaining, int seconds) {
    return 'Procesar $pages páginas requiere $pages solicitudes, pero solo quedan $remaining solicitudes disponibles en este minuto. Espere $seconds segundos o seleccione menos páginas.';
  }

  @override
  String pipelineRpdLimit(int pages, int remaining, int limit) {
    return 'Procesar $pages páginas requiere $pages solicitudes, pero solo quedan $remaining solicitudes hoy (límite diario: $limit).';
  }

  @override
  String pipelineFileTooLarge(String name, String sizeMb) {
    return 'El archivo \"$name\" es demasiado grande ($sizeMb MB). El tamaño máximo es de 10 MB por documento.';
  }

  @override
  String pipelineExtractingPage(int current, int total) {
    return 'Extrayendo la página $current de $total...';
  }

  @override
  String get pipelineExtractingSingle =>
      'Extrayendo datos médicos del documento...';

  @override
  String pipelineLooksLikeKind(String kind) {
    return ' (parece ser: $kind)';
  }

  @override
  String pipelineNotMedicalSingle(String kind) {
    return 'Esto no parece un documento de salud o médico$kind, así que no se usó nada. Suba un registro médico, una lista de medicamentos o de alergias, o una directiva anticipada existente.';
  }

  @override
  String pipelineNotMedicalMulti(String kind) {
    return 'Estos no parecen documentos de salud o médicos$kind, así que no se usó nada.';
  }

  @override
  String get pipelineNoMedicalInfoSingle =>
      'No se encontró información médica en este documento.';

  @override
  String pipelineNoMedicalInfoMulti(int count) {
    return 'No se encontró información médica en estas $count páginas.';
  }

  @override
  String get pipelineValidating => 'Validando medicamentos y condiciones...';

  @override
  String get pipelinePleaseWait => 'Espere mientras se procesa...';

  @override
  String get pipelineBackWizard => 'Asistente';

  @override
  String get pipelineBackReview => 'Revisión';

  @override
  String get pipelineTitleSnapToFill => 'Autocompletar con una foto';

  @override
  String get pipelineTitleProcessing => 'Procesando';

  @override
  String get pipelineTitleReview => 'Revisar los datos extraídos';

  @override
  String get pipelineTitleGenerating => 'Generando sugerencias';

  @override
  String get pipelineTitleResults => 'Sugerencias de la IA';

  @override
  String pipelinePickerFailed(String error) {
    return 'No se pudo abrir el selector de archivos ($error). Pruebe a arrastrar el archivo al cuadro de arriba.';
  }

  @override
  String get pipelineCouldNotRead =>
      'No pudimos leer ese archivo. Use un archivo PDF, JPG, PNG, WEBP, HEIC o de texto sin formato de menos de 10 MB.';

  @override
  String get pipelineFormCombined => 'Combinado';

  @override
  String get pipelineFormDeclaration => 'Solo Declaración';

  @override
  String get pipelineFormPoa => 'Solo Poder Notarial';

  @override
  String get pipelineFormCombinedSub =>
      'Preferencias de tratamiento Y una persona que decida (lo más amplio).';

  @override
  String get pipelineFormDeclarationSub =>
      'Preferencias de tratamiento, sin nombrar a un agente.';

  @override
  String get pipelineFormPoaSub =>
      'Nombrar a una persona que decida, sin indicar preferencias.';

  @override
  String get pipelineWhichForm => '¿Qué formulario quiere completar?';

  @override
  String get pipelineWhichFormBody =>
      'Elija primero su formulario; la IA leerá solo las partes que ese formulario necesita. El Combinado es el más amplio; puede cambiarlo después.';

  @override
  String get pickSnapOptional => 'Autocompletar con una foto · opcional';

  @override
  String get pickHeadlineLead => '¿Tiene una foto a mano? ';

  @override
  String get pickHeadlineAccent => 'La leeremos.';

  @override
  String get pickIntro =>
      'Suelte una foto, un PDF o una grabación de audio (identificación, lista de medicamentos, etiqueta de una receta, una directiva anterior o simplemente sus deseos dichos en voz alta) y la IA extraerá lo que pueda. Usted revisa cada campo antes de que se añada al formulario. O sáltese este paso y escríbalo todo usted.';

  @override
  String get pickPrivacyNote =>
      'Su privacidad: tache cualquier dato sensible antes de subir el archivo. Nunca tiene que subir datos personales: cualquier campo se puede escribir a mano para mantenerlo confidencial.';

  @override
  String get pickVoiceGuideLink =>
      '¿Va a grabar un archivo de voz? Vea el cuestionario y las instrucciones';

  @override
  String get pickSkipTypeAll => 'Omitir: lo escribiré todo';

  @override
  String get pickContinueStep2 => 'Continuar al paso 2';

  @override
  String get pickYourDocuments => 'Sus documentos';

  @override
  String pickFilesKeptInMemory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ARCHIVOS · GUARDADOS EN MEMORIA',
      one: '1 ARCHIVO · GUARDADO EN MEMORIA',
    );
    return '$_temp0';
  }

  @override
  String get pickClearAll => 'Borrar todo';

  @override
  String get pickHeldWithKey =>
      'Se guarda en este dispositivo. No se envía nada hasta que toque Leer; entonces se envía a su proveedor de IA para leerlo.';

  @override
  String get pickHeldNoKey =>
      'Se guarda en este dispositivo. Para leerlo, primero hay que configurar la IA (gratis, unos 30 segundos); hasta entonces no se envía nada.';

  @override
  String pickReadWithAi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Leer $count documentos con IA',
      one: 'Leer este documento con IA',
    );
    return '$_temp0';
  }

  @override
  String get pickRemove => 'Quitar';

  @override
  String get pickNoKeyTitle => 'La IA aún no está configurada';

  @override
  String get pickNoKeyBody =>
      'Abajo puede ver cómo funciona el autocompletado con una foto, pero leer una foto o un PDF real requiere una clave de IA (configurar el nivel gratuito de Gemini toma unos 30 segundos). Usted revisa cada campo antes de que se añada a su formulario.';

  @override
  String get pickTryAgain => 'Intentar de nuevo';

  @override
  String get pickDropTitleCamera => 'Añada una foto de su documento';

  @override
  String get pickDropTitle =>
      'Suelte una foto, un PDF o una captura de pantalla';

  @override
  String pickFormatsPaste(String shortcut) {
    return 'JPG · PNG · HEIC · PDF · hasta 10 MB, o pegue con $shortcut';
  }

  @override
  String get pickFormats => 'JPG · PNG · HEIC · PDF · hasta 10 MB';

  @override
  String get pickBrowseFiles => 'Buscar archivos';

  @override
  String get pickTakePhoto => 'Tomar una foto';

  @override
  String get pickSentToProvider =>
      'Para autocompletar, su archivo, incluidos los datos personales que contenga, se envía a su proveedor de IA para leerlo. La aplicación no guarda nada (se borra al cerrar esta pestaña), pero el proveedor podría conservarlo (el nivel gratuito de Gemini lo hace). Usted revisa todo antes de que se añada a su directiva.';

  @override
  String get pickTargetId => 'Foto de identificación';

  @override
  String get pickTargetIdSub => 'Nombre · fecha de nacimiento · dirección';

  @override
  String get pickTargetRx => 'Frasco o etiqueta de receta';

  @override
  String get pickTargetRxSub => 'Medicamento · dosis · horario';

  @override
  String get pickTargetConditions => 'Lista de condiciones';

  @override
  String get pickTargetConditionsSub => 'Diagnósticos · alergias';

  @override
  String get pickTargetOther => 'Cualquier otra cosa';

  @override
  String get pickTargetOtherSub => 'Notas, directiva anterior…';

  @override
  String get pickTargetOtherSubMobile => 'Directiva anterior, notas…';

  @override
  String get pickWhatYouCanAdd => 'Qué puede añadir';

  @override
  String get pickWhatYouCanDrop => 'Qué puede soltar aquí';

  @override
  String get pickOnAPhone => '¿Prefiere usar un teléfono?';

  @override
  String get pickOnAPhoneBody =>
      'Abra esta página en su teléfono para fotografiar una página directamente con la cámara.';

  @override
  String get pickTakePhotoSub =>
      'Abre su cámara. Fotografíe su identificación, la etiqueta de una receta o lo que sea.';

  @override
  String get pickPickFile => 'Elegir un archivo';

  @override
  String get pickPickFileSub => 'De sus fotos o archivos. JPG, PNG, HEIC, PDF.';

  @override
  String get pickWhatHelpsMost => 'Lo que más ayuda';

  @override
  String get pickFastest => 'LO MÁS RÁPIDO';

  @override
  String get pickSentToProviderShort =>
      'Su archivo (incluidos los datos personales) se envía a su proveedor de IA para leerlo. La aplicación no guarda nada; el proveedor podría conservarlo (el nivel gratuito de Gemini lo hace). Usted lo revisa antes de que se añada nada.';

  @override
  String pickReadingDocs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Leyendo $count documentos:',
      one: 'Leyendo 1 documento:',
    );
    return '$_temp0';
  }

  @override
  String pickReadByAi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos leídos por la IA de Google para autocompletar.',
      one: 'Leído por la IA de Google para autocompletar.',
    );
    return '$_temp0';
  }

  @override
  String get reviewLabelMedPrefer => 'Medicamento preferido';

  @override
  String get reviewLabelMedAvoid => 'Medicamento que se debe evitar';

  @override
  String get reviewLabelMedCurrent => 'Lo toma actualmente';

  @override
  String get reviewLabelMedLimit => 'Medicamento de uso restringido';

  @override
  String get reviewLabelCond => 'Condición';

  @override
  String get reviewLabelDiag => 'Diagnóstico';

  @override
  String get reviewLabelAllergy => 'Alergia';

  @override
  String get reviewLabelHh => 'Antecedentes de salud';

  @override
  String get reviewLabelEffectiveCondition =>
      'Cuándo entra en vigor (con sus palabras)';

  @override
  String get reviewLabelFacilityPrefer => 'Centro preferido';

  @override
  String get reviewLabelFacilityAvoid => 'Centro que se debe evitar';

  @override
  String get reviewLabelDietary => 'Alimentación';

  @override
  String get reviewLabelReligious => 'Religión / cultura';

  @override
  String get reviewLabelActivities => 'Actividades';

  @override
  String get reviewLabelCrisis => 'Intervención en crisis';

  @override
  String get reviewLabelCrisisPlan => 'Plan de crisis';

  @override
  String get reviewLabelAgentAuthorityLimitations =>
      'Límites a la autoridad del agente';

  @override
  String get reviewLabelEctConsent => 'Consentimiento para TEC';

  @override
  String get reviewLabelExperimentalConsent =>
      'Consentimiento para tratamiento experimental';

  @override
  String get reviewLabelDrugTrialConsent =>
      'Consentimiento para ensayos de medicamentos';

  @override
  String get reviewLabelMedicationConsent =>
      'Consentimiento sobre medicamentos';

  @override
  String get reviewLabelTriggerTwoProfessionals => 'Activación: profesionales';

  @override
  String get reviewLabelTriggerCourtOrder => 'Activación: orden judicial';

  @override
  String get reviewLabelTriggerInvoluntaryCommitment =>
      'Activación: internamiento involuntario';

  @override
  String get reviewLabelRoomPrefsNote => 'Preferencias de habitación';

  @override
  String get reviewLabelRoomPrefChips => 'Opciones de habitación';

  @override
  String get reviewLabelRoommateSameGender =>
      'Compañero de habitación del mismo género';

  @override
  String get reviewLabelGuardianCanRevoke => 'Tutor: anular';

  @override
  String get reviewLabelGuardianCanChangeAgent => 'Tutor: reemplazar al agente';

  @override
  String get reviewLabelGuardianMustConsultAgent =>
      'Tutor: consultar al agente';

  @override
  String get reviewLabelAuthorityHospitalization => 'Agente: hospitalización';

  @override
  String get reviewLabelAuthorityMedication => 'Agente: medicamentos';

  @override
  String get reviewLabelUlyssesOptin => 'Autovinculación (Ulises)';

  @override
  String get reviewLabelPetCustody => 'Cuidado de mascotas';

  @override
  String get reviewLabelChildrenCustody => 'Hijos / dependientes';

  @override
  String get reviewLabelFamilyNotification => 'A quién avisar';

  @override
  String get reviewLabelRecordsDisclosure => 'Divulgación de registros';

  @override
  String get reviewLabelOther => 'Otro';

  @override
  String get reviewLabelPersonName => 'Su nombre completo';

  @override
  String get reviewLabelPersonDob => 'Fecha de nacimiento';

  @override
  String get reviewLabelPersonAddress1 => 'Dirección';

  @override
  String get reviewLabelPersonAddress2 => 'Apto. / suite / unidad';

  @override
  String get reviewLabelPersonCity => 'Ciudad';

  @override
  String get reviewLabelPersonCounty => 'Condado';

  @override
  String get reviewLabelPersonState => 'Estado';

  @override
  String get reviewLabelPersonZip => 'Código postal';

  @override
  String get reviewLabelPersonPhone => 'Su teléfono';

  @override
  String get reviewLabelPersonDoctorName => 'Médico principal';

  @override
  String get reviewLabelPersonDoctorSpecialty => 'Especialidad del médico';

  @override
  String get reviewLabelPersonDoctorPhone => 'Teléfono del médico';

  @override
  String get reviewLabelPersonEvalDoctorName =>
      'Médico preferido para la evaluación';

  @override
  String get reviewLabelPersonEvalDoctorContact =>
      'Contacto del médico evaluador';

  @override
  String get reviewLabelAgentName => 'Nombre del agente';

  @override
  String get reviewLabelAgentRelationship => 'Parentesco del agente';

  @override
  String get reviewLabelAgentAddress1 => 'Dirección del agente';

  @override
  String get reviewLabelAgentAddress2 => 'Apto. / suite del agente';

  @override
  String get reviewLabelAgentCity => 'Ciudad del agente';

  @override
  String get reviewLabelAgentState => 'Estado del agente';

  @override
  String get reviewLabelAgentZip => 'Código postal del agente';

  @override
  String get reviewLabelAgentPhone => 'Teléfono del agente';

  @override
  String get reviewLabelAltAgentName => 'Nombre del agente alternativo';

  @override
  String get reviewLabelAltAgentRelationship =>
      'Parentesco del agente alternativo';

  @override
  String get reviewLabelAltAgentAddress1 => 'Dirección del agente alternativo';

  @override
  String get reviewLabelAltAgentAddress2 =>
      'Apto. / suite del agente alternativo';

  @override
  String get reviewLabelAltAgentCity => 'Ciudad del agente alternativo';

  @override
  String get reviewLabelAltAgentState => 'Estado del agente alternativo';

  @override
  String get reviewLabelAltAgentZip => 'Código postal del agente alternativo';

  @override
  String get reviewLabelAltAgentPhone => 'Teléfono del agente alternativo';

  @override
  String get reviewLabelGuardianName => 'Tutor propuesto';

  @override
  String get reviewLabelGuardianRelationship => 'Parentesco del tutor';

  @override
  String get reviewLabelGuardianAddress1 => 'Dirección del tutor';

  @override
  String get reviewLabelGuardianAddress2 => 'Apto. / suite del tutor';

  @override
  String get reviewLabelGuardianCity => 'Ciudad del tutor';

  @override
  String get reviewLabelGuardianState => 'Estado del tutor';

  @override
  String get reviewLabelGuardianZip => 'Código postal del tutor';

  @override
  String get reviewLabelGuardianPhone => 'Teléfono del tutor';

  @override
  String get reviewSectionMedPrefer => 'Medicamentos preferidos';

  @override
  String get reviewSectionMedAvoid => 'Medicamentos que se deben evitar';

  @override
  String get reviewSectionMedCurrent => 'Los toma actualmente';

  @override
  String get reviewSectionMedLimit => 'Medicamentos de uso restringido';

  @override
  String get reviewSectionCond => 'Condiciones';

  @override
  String get reviewSectionDiag => 'Diagnósticos';

  @override
  String get reviewSectionAllergy => 'Alergias';

  @override
  String get reviewSectionHh => 'Antecedentes de salud';

  @override
  String get reviewSectionEffectiveCondition => 'Cuándo entra en vigor';

  @override
  String get reviewSectionPerson => 'Sus datos';

  @override
  String get reviewSectionAgent => 'Su agente';

  @override
  String get reviewSectionAgentAuthority => 'Autoridad del agente';

  @override
  String get reviewSectionUlyssesOptin => 'Autovinculación';

  @override
  String get reviewSectionCrisisPlan => 'Plan de crisis';

  @override
  String get reviewSectionConsent => 'Consentimiento';

  @override
  String get reviewSectionRoomPreferences => 'Preferencias de habitación';

  @override
  String get reviewSectionAltAgent => 'Agente alternativo';

  @override
  String get reviewSectionGuardian => 'Tutor';

  @override
  String get reviewSectionOther => 'Otro';

  @override
  String get reviewStepGroupWhenKicksIn => 'Cuándo entra en vigor';

  @override
  String get reviewStepGroupDiagnoses => 'Diagnósticos';

  @override
  String get reviewStepGroupAboutYou => 'Sobre usted';

  @override
  String get reviewStepGroupPeopleITrust => 'Personas de confianza';

  @override
  String get reviewStepGroupGuardian => 'Si un tribunal nombra a un tutor';

  @override
  String get reviewStepGroupWhereIWantCare => 'Dónde quiero recibir atención';

  @override
  String get reviewStepGroupMedications => 'Medicamentos';

  @override
  String get reviewStepGroupAllergies => 'Alergias y reacciones';

  @override
  String get reviewStepGroupProceduresResearch =>
      'Procedimientos e investigación';

  @override
  String get reviewStepGroupAnythingElse => 'Algo más';

  @override
  String get reviewAiReadThisPhoto => 'LA IA LEYÓ ESTA FOTO';

  @override
  String get reviewHeresWhatWeRead => 'Esto es lo que leímos.';

  @override
  String get reviewHowToIntro =>
      'Estos son los datos que la IA extrajo de su documento. Así se usa esta página:';

  @override
  String get reviewHowToChecked =>
      'Una casilla marcada significa que se añadirá a su formulario. Desmarque lo que no quiera.';

  @override
  String get reviewHowToEdit =>
      'Toque cualquier campo para cambiar su redacción antes de añadirlo.';

  @override
  String get reviewHowToGrouped =>
      'Los resultados se agrupan por sección del formulario (los mismos pasos que verá después). Una nota \"Reemplaza lo que tiene\" significa que sobrescribiría algo que ya ingresó; esos empiezan desmarcados.';

  @override
  String reviewHowToFinish(String buttonLabel) {
    return 'Cuando esté listo, toque \"$buttonLabel\" abajo para completar su formulario con estos datos y continuar; llegará al formulario para revisarlo todo.';
  }

  @override
  String reviewPiiRemoved(String items) {
    return 'Se detectaron y eliminaron datos personales antes del análisis: $items';
  }

  @override
  String get reviewAddToDirective => 'Añadir a su directiva';

  @override
  String get reviewPhotoDiscarded =>
      'Su foto se envió a la IA para leerla y luego se descartó. No se guarda nada después de confirmar o descartar.';

  @override
  String reviewFieldsReady(int checked, int total) {
    return '$checked de $total campos listos para añadir';
  }

  @override
  String get reviewYouEntered => 'Usted ingresó';

  @override
  String get reviewAutofillFound => 'El autocompletado encontró';

  @override
  String get reviewKeepMine => 'Conservar lo mío';

  @override
  String get reviewUseNew => 'Usar lo nuevo';

  @override
  String get reviewAddBoth => 'Añadir ambos';

  @override
  String get reviewConsolidateAi => 'Unificar (IA)';

  @override
  String get reviewIdentityNotMerged =>
      'La IA no unifica los campos de identidad; revise este usted mismo.';

  @override
  String get reviewWillSave => 'Se guardará:';

  @override
  String get reviewSetupAiToConsolidate =>
      'Primero configure el asistente de IA para poder unificar.';

  @override
  String get reviewAgentInitialsNote =>
      'Esto permite que su agente decida. Según la ley de PA (§5836(c)), solo tiene efecto si usted pone sus iniciales a mano en esta autorización en el formulario impreso; confirme que esto es lo que quiere.';

  @override
  String get reviewSmartIntro =>
      'La IA generó estas sugerencias adicionales a partir de sus condiciones y medicamentos validados. Toque para editar y desmarque para omitir. No es consejo médico ni legal.';

  @override
  String get reviewGuidanceOnly =>
      'Orientación para leer; no se guarda en su formulario. Indique su decisión en Procedimientos e investigación.';

  @override
  String get reviewAutofillInformation => 'Información de autocompletado';

  @override
  String get reviewApplyAll => 'Aplicar todo';

  @override
  String get reviewDiscardAll => 'Descartar todo';

  @override
  String get reviewGenerateMore => 'Generar más';

  @override
  String get reviewIncludeField => 'Incluir este campo';

  @override
  String get reviewNotAdded => 'No añadido';

  @override
  String get reviewEdit => 'Editar';

  @override
  String get homeMakeItFindableInA => 'Que la encuentren en una crisis';

  @override
  String get homeShareCopiesCarryTheWallet =>
      'Comparta copias, lleve la tarjeta de billetera y diga a sus personas dónde está';

  @override
  String get homeSessionRestoredPersonalInfoMust =>
      'Sesión restaurada. Debe volver a ingresar su información personal.';

  @override
  String get homeDeleteDirective => '¿Eliminar la directiva?';

  @override
  String get homeAllDataForThisDirective =>
      'Todos los datos de esta directiva se eliminarán de forma permanente.';

  @override
  String get homeDirectiveDeleted => 'Directiva eliminada.';

  @override
  String get homeRenameDirective => 'Cambiar el nombre de la directiva';

  @override
  String get homeRenewDirective => '¿Renovar la directiva?';

  @override
  String get homeThisWillCreateANew =>
      'Esto creará una nueva directiva con las mismas preferencias de tratamiento y designaciones de agente. Tendrá que volver a ingresar la información personal, los testigos y las firmas.\n\nLa directiva original no cambiará.';

  @override
  String get homeRenew => 'Renovar';

  @override
  String get homeAmendThisDirective => '¿Modificar esta directiva?';

  @override
  String get homeAmendingOpensThisDirectiveSo =>
      'Modificarla abre esta directiva para que pueda cambiarla; sus respuestas actuales se mantienen.\n\nImportante: una modificación solo es válida cuando usted la vuelve a firmar en papel con dos testigos adultos, igual que la original (Ley 194 de PA). Hasta que la vuelva a firmar, esta directiva aparecerá como un borrador sin firmar, y las copias impresas de la versión anterior seguirán vigentes hasta que las reemplace.\n\n¿Prefiere no tocar el original firmado? Use “Renovar (copiar a una nueva)”.';

  @override
  String get homeAmend => 'Modificar';

  @override
  String get homePrivateByDesign => 'Privada por diseño';

  @override
  String get homeLetSGetStarted => 'Empecemos.';

  @override
  String get homeRename => 'Cambiar nombre';

  @override
  String get homeLabelShownInThisList =>
      'Etiqueta que solo se muestra en esta lista; nunca se imprime';

  @override
  String get homeRenewCopyToNew => 'Renovar (copiar a una nueva)';

  @override
  String get homeAmendEditThisOne => 'Modificar (editar esta)';

  @override
  String get homeRequiresReSigningReWitnessing =>
      'Requiere volver a firmar y a reunir testigos';

  @override
  String get homeRevoke => 'Revocar';

  @override
  String get homeTools => 'Herramientas';

  @override
  String get homePastDirectives => 'Directivas anteriores';

  @override
  String get homeStartANewDirective => 'Empezar una nueva directiva';

  @override
  String get homeLoadingYourDirectives => 'Cargando sus directivas';

  @override
  String get homeDisplayLabel => 'Etiqueta visible';

  @override
  String get homeShownOnlyInThisList =>
      'Solo se muestra en esta lista; nunca se imprime en el formulario. Déjela vacía para usar el nombre que figura en la directiva.';

  @override
  String get homeCouldnTLoadYourDirectives =>
      'No se pudieron cargar sus directivas.';

  @override
  String get homeNothingWasLostThisIs =>
      'No se perdió nada: es un problema de visualización, no de datos.';

  @override
  String get homeYourVoice => 'Su voz,\n';

  @override
  String get homeInYourWords => 'con sus palabras.';

  @override
  String get homeLetSKeepYourVoice =>
      'Hagamos que su voz se escuche con claridad.';

  @override
  String get homeStartYourDirective => 'Empezar su directiva';

  @override
  String get homePrivateBodyWeb =>
      'Su directiva nunca sale de este navegador: sin servidor, sin cuenta y sin rastreo. Solo existe en esta sesión, y solo usted decide con quién compartirla.';

  @override
  String get homePrivateBodyDevice =>
      'Su directiva se queda en su dispositivo. Sin anuncios, sin rastreo y sin vender sus datos; solo usted decide con quién compartirla.';

  @override
  String homeHiName(String name) {
    return 'Hola, $name.\n';
  }

  @override
  String homeProfileA11y(String name) {
    return 'Perfil de $name';
  }

  @override
  String homeCardDraft(int step, int total, String date) {
    return 'Borrador · paso $step de $total · $date';
  }

  @override
  String homeCardPrepared(String date) {
    return 'Preparada · $date';
  }

  @override
  String get homeCardExpired => 'Vencida · revóquela o cópiela a una nueva';

  @override
  String homeCardRevoked(String date) {
    return 'Revocada · $date';
  }

  @override
  String homeCardDirectiveYear(int year) {
    return 'Directiva · $year';
  }

  @override
  String homeCardA11y(String name, String status) {
    return '$name. $status. Toque para abrir.';
  }

  @override
  String get crisisPlanHelpThePeopleAroundYou =>
      'Ayude a las personas cercanas a detectar problemas a tiempo y a saber qué le ayuda de verdad cuando ocurren.';

  @override
  String get crisisPlanAdd => 'Añadir';

  @override
  String get crisisPlanAdd2 => '+ Añadir';

  @override
  String get crisisPlanOptionalAddOnCrisisPlan =>
      'Complemento opcional · Plan de crisis';

  @override
  String get crisisPlanEarlyWarningSigns => 'Señales de alerta temprana';

  @override
  String get crisisPlanTriggersToWatchFor =>
      'Desencadenantes a tener en cuenta';

  @override
  String get crisisPlanThingsThatGenuinelyHelp => 'Cosas que realmente ayudan';

  @override
  String get crisisPlanThingsToSayToMe => 'Cosas que me pueden decir';

  @override
  String get crisisPlanDonTDoThese => 'No hagan esto';

  @override
  String get crisisPlanTypeAShortNote => 'Escriba una nota breve';

  @override
  String get permissionsOverviewPaMhadRequestsSystemPermissions =>
      'PA MHAD solicita permisos del sistema solo para las funciones que usted usa activamente. No se recopila nada en segundo plano. Cada sección de abajo explica exactamente qué permite cada permiso, qué hace la aplicación con el resultado y qué nunca hace.';

  @override
  String get permissionsOverviewWhatThisAppMayAsk =>
      'Qué puede solicitar esta aplicación';

  @override
  String get permissionsOverviewBiometricsPasscode =>
      'Biometría / código de acceso';

  @override
  String get permissionsOverviewNotifications => 'Notificaciones';

  @override
  String get permissionsOverviewCamera => 'Cámara';

  @override
  String get permissionsOverviewMicrophone => 'Micrófono';

  @override
  String get permissionsOverviewContacts => 'Contactos';

  @override
  String get makeItFindableADirectiveOnlyHelpsIf =>
      'Una directiva solo ayuda si las personas que le atienden pueden encontrarla cuando usted no puede hablar por sí mismo. Tómese unos minutos ahora para dejar copias donde las buscarán.';

  @override
  String get makeItFindableThisIsGeneralInformationAbout =>
      'Esta es información general sobre cómo mantener su directiva accesible, no es asesoría legal.';

  @override
  String get makeItFindableCrisisReadiness => 'Preparación para una crisis';

  @override
  String get makeItFindableDoTheseNow => 'Haga esto ahora';

  @override
  String get makeItFindableShareItWithYourAgent =>
      'Compártala con su agente y con una persona de confianza';

  @override
  String get makeItFindableTheyShouldEachHaveA =>
      'Cada uno debe tener una copia antes de cualquier crisis, no solo usted.';

  @override
  String get makeItFindableGiveACopyToYour =>
      'Dé una copia a su equipo de atención';

  @override
  String get makeItFindableAskYourPsychiatristTherapistPrimary =>
      'Pida a su psiquiatra, terapeuta, médico de atención primaria y a cualquier centro que la añadan a su expediente médico.';

  @override
  String get makeItFindablePrintAndCarryTheWallet =>
      'Imprima y lleve la tarjeta de billetera';

  @override
  String get makeItFindableAPocketCardThatTells =>
      'Una tarjeta de bolsillo que les indica a quienes le atiendan que usted tiene una directiva y cómo comunicarse con su agente.';

  @override
  String get adminUpdateFederalRegisterRelevantFederalRules =>
      'Federal Register: normas federales pertinentes';

  @override
  String get adminUpdateFederalRulesTheAppReferences =>
      'Normas federales que la aplicación cita. Use un enlace como FUENTE para un cambio legal o con fecha que requiera verificación. La ley estatal (Ley 194 de PA) no se incluye aquí.';

  @override
  String get adminUpdateOpen => 'Abrir';

  @override
  String get adminUpdateSourceLinkCopied => 'Enlace de la fuente copiado';

  @override
  String get adminUpdateCopyLink => 'Copiar enlace';

  @override
  String get adminUpdateRestoreFromWhichBackup =>
      '¿Restaurar desde qué copia de seguridad?';

  @override
  String get adminUpdateAdminDataUpdate =>
      'Administración · actualización de datos';

  @override
  String get adminUpdateEnterTheAdminPassphrase =>
      'Ingrese la frase de acceso de administración.';

  @override
  String get adminUpdateUnlock => 'Desbloquear';

  @override
  String get adminUpdateDescribeTheUpdateTheAi =>
      'Describa la actualización. La IA redacta cambios al archivo seleccionado con sus fuentes; usted los revisa y aprueba antes de que se genere nada. Los cambios legales, normativos y educativos siempre requieren su aprobación explícita.';

  @override
  String get adminUpdateRevert => 'Revertir';

  @override
  String get adminUpdateCheckBestGeminiModel =>
      'Buscar el mejor modelo de Gemini';

  @override
  String get adminUpdateCheckFederalRegister => 'Consultar el Federal Register';

  @override
  String get adminUpdateCopiedUpdatedJson => 'JSON actualizado copiado';

  @override
  String get adminUpdateCopyJson => 'Copiar JSON';

  @override
  String get adminUpdateAnotherUpdate => 'Otra actualización';

  @override
  String get adminUpdatePassphrase => 'Frase de acceso';

  @override
  String get adminUpdateWhatToUpdate => 'Qué actualizar';

  @override
  String get adminUpdateAiProvider => 'Proveedor de IA';

  @override
  String get adminUpdateModel => 'Modelo';

  @override
  String get adminUpdateDescribeTheUpdate => 'Describa la actualización *';

  @override
  String get adminUpdateEGTheTrevorProject =>
      'p. ej., \"El número de The Trevor Project cambió a ...\" o \"Revisa los límites actuales del nivel gratuito de Gemini\"';

  @override
  String get adminUpdateRequiredWhatShouldTheAi =>
      'Obligatorio: ¿sobre qué debe redactar la IA un cambio?';

  @override
  String get adminUpdateFocusAreaPathOptional =>
      'Área de enfoque / ruta (opcional)';

  @override
  String get adminUpdateRestrictTheAiToOne =>
      'Limite la IA a un solo lugar; p. ej., \"config.timeoutsSeconds\" o \"sections.faq_valid\".';

  @override
  String get reminderSheetsQuickRenew5Min => 'Renovación rápida · ~5 min';

  @override
  String get reminderSheetsMostPeopleKeepTheSame =>
      'La mayoría de las personas mantiene las mismas respuestas. Completaremos las 11 secciones con los datos de su directiva actual; toque cualquier tarjeta para cambiarla y luego imprima y firme la nueva copia con bolígrafo ante dos testigos.';

  @override
  String get reminderSheetsStartQuickRenew => 'Empezar la renovación rápida';

  @override
  String get reminderSheetsRemindMeNextWeek => 'Recordármelo la próxima semana';

  @override
  String get reminderSheetsWeLlRemindYouAgain =>
      'Se lo recordaremos de nuevo 7 días antes del vencimiento.';

  @override
  String get reminderSheetsAnythingChanged => '¿Cambió algo?';

  @override
  String get reminderSheetsStillAccurateAllGood =>
      'Sigue siendo correcta; todo bien';

  @override
  String get reminderSheetsEditMyDirective => 'Editar mi directiva';

  @override
  String get reminderSheetsIfYouEditAnythingYou =>
      'Si edita algo, tendrá que volver a imprimir y firmar con bolígrafo la copia actualizada. Los cambios pequeños pueden esperar a la renovación de los 2 años.';

  @override
  String get reminderSheets3MonthCheckIn => '● Revisión de los 3 meses';

  @override
  String get reminderSheetsCommonThingsThatChange => 'Cosas que suelen cambiar';

  @override
  String get reminderSheetsStillTheRightPeople =>
      '¿Siguen siendo las personas adecuadas?';

  @override
  String get reminderSheetsMedicationsUpToDate =>
      '¿Están al día los medicamentos?';

  @override
  String get reminderSheetsCarePreferencesStillRight =>
      '¿Siguen siendo correctas sus preferencias de atención?';

  @override
  String get reminderSheetsPaDirectivesExpireAfter2 =>
      'Las directivas de PA vencen a los 2 años. La suya vence el ';

  @override
  String get reminderSheetsIfYouAreIncapableOf =>
      '. (Si en la fecha de vencimiento usted no tiene capacidad para tomar decisiones de salud mental, sigue vigente hasta que recupere la capacidad).';

  @override
  String get reminderSheetsYourDirectiveIsStillValid =>
      'Su directiva sigue siendo válida hasta el ';

  @override
  String get reminderSheetsNoSigningNeededJustA =>
      '; no hace falta firmar nada. Solo una revisión rápida para confirmar que sigue ajustándose a su vida.';

  @override
  String get revocationMarkedRevokedOnThisDevice =>
      'Marcada como revocada en este dispositivo';

  @override
  String get revocationPer20PaCS =>
      'Según 20 Pa.C.S. §§ 5825 y 5839, la revocación solo tiene efecto cuando se comunica a su médico o proveedor tratante. Marcar aquí esta directiva como revocada no la comunica; todavía tiene que avisar a cada destinatario.';

  @override
  String get revocationYouPickedTheseRecipientsTo =>
      'Eligió avisar a estos destinatarios:';

  @override
  String get revocationContactEachRecipientYourselfCall =>
      'Comuníquese usted mismo con cada destinatario, por teléfono o correo electrónico, y pida al proveedor que registre la revocación en su expediente. La revocación tiene efecto una vez que su proveedor ha sido informado.';

  @override
  String get revocationYourDirectiveWillNoLonger =>
      'Su directiva dejará de ser legalmente obligatoria cuando usted comunique la revocación a su médico o proveedor tratante (20 Pa.C.S. §§ 5825, 5839). Esta aplicación marca la directiva como revocada en el dispositivo y le ayuda a generar una carta de revocación.';

  @override
  String get revocationThisDeclarationMayBeRevoked =>
      'Esta declaración puede revocarse total o parcialmente en cualquier momento, de forma oral o por escrito, siempre que no se haya determinado que no tengo capacidad para tomar decisiones de salud mental. Mi revocación tendrá efecto cuando yo, o un testigo de mi revocación, comunique la intención de revocar a mi médico tratante u otro proveedor de atención de salud mental.';

  @override
  String get revocationNoBatchSendsPickEach =>
      'No se hacen envíos masivos: elija a cada destinatario. La aplicación mantiene sus elecciones a la vista como una lista de verificación; usted se comunica con cada destinatario (por teléfono, correo electrónico o en persona).';

  @override
  String get revocationTypeRevokeToConfirm => 'Escriba REVOCAR para confirmar';

  @override
  String get revocationHowRevocationWorksInPa =>
      'Cómo funciona la revocación en PA';

  @override
  String get revocationStatutoryRevocationStatement =>
      'Declaración legal de revocación';

  @override
  String get revocationWhoToNotifyOptIn =>
      'A quién avisar (elija cada destinatario)';

  @override
  String get revocationPermanentAction => 'Acción permanente';

  @override
  String get revocationRevoke => 'REVOCAR';

  @override
  String get pastDirectiveDetailDeleteFromThisDevice =>
      '¿Eliminar de este dispositivo?';

  @override
  String get pastDirectiveDetailThisRemovesTheSavedDirective =>
      'Esto elimina la directiva guardada de este dispositivo. El efecto legal de cualquier copia en papel firmada anteriormente no cambia. No se puede deshacer.';

  @override
  String get pastDirectiveDetailDirectiveDeletedFromThisDevice =>
      'Directiva eliminada de este dispositivo.';

  @override
  String get pastDirectiveDetailNoShareLogEntriesYet =>
      'Aún no hay entradas en el registro de copias compartidas.';

  @override
  String get pastDirectiveDetailWeDonTTrackDelivery =>
      'No registramos la entrega ni la confirmación de recepción (eso requeriría un servidor). Añada entradas manualmente a medida que distribuya copias.';

  @override
  String get pastDirectiveDetailGeneratedOnDemand6Pages =>
      'Se genera cuando la pide · ~6 páginas';

  @override
  String get pastDirectiveDetailWhoHadACopy => 'Quién tenía una copia';

  @override
  String get pastDirectiveDetailActions => 'Acciones';

  @override
  String get pastDirectiveDetailLoadingThisDirective =>
      'Cargando esta directiva';

  @override
  String get pastDirectiveDetailCopyToANewDirective =>
      'Copiar a una nueva directiva';

  @override
  String get pastDirectiveDetailStartWithTheseAnswersComing =>
      'Empezar con estas respuestas; llegará con el flujo de renovación';

  @override
  String get pastDirectiveDetailOpenThePdf => 'Abrir el PDF';

  @override
  String get pastDirectiveDetailPrintOrSaveForYour =>
      'Imprimir o guardar para sus registros';

  @override
  String get pastDirectiveDetailDeleteFromThisDevice2 =>
      'Eliminar de este dispositivo';

  @override
  String get pastDirectiveDetailSignedBy => 'FIRMADA POR';

  @override
  String get pastDirectiveDetailWitness1 => 'TESTIGO 1';

  @override
  String get pastDirectiveDetailWitness2 => 'TESTIGO 2';

  @override
  String get pastDirectiveDetailDirective => 'Directiva · ';

  @override
  String get pinDialogCreatePasscode => 'Crear código de acceso';

  @override
  String get pinDialogBiometricAuthenticationIsNotAvailable =>
      'La autenticación biométrica no está disponible en este dispositivo. Cree un código de acceso para proteger sus datos privados.';

  @override
  String get pinDialogCreate => 'Crear';

  @override
  String get pinDialogPaMhad => 'PA MHAD';

  @override
  String get pinDialogPrivateModeLocked => 'MODO PRIVADO · BLOQUEADO';

  @override
  String get pinDialogEnterYourPasscodeToUnlock =>
      'Ingrese su código de acceso para desbloquear el modo privado.';

  @override
  String get pinDialogSwitchToPublicMode => 'Cambiar al modo público';

  @override
  String get pinDialogPasscode => 'Código de acceso';

  @override
  String get pinDialogAtLeast4Characters => 'Al menos 4 caracteres';

  @override
  String get pinDialogConfirmPasscode => 'Confirmar código de acceso';

  @override
  String get pinDialogUseYour => 'Use su ';

  @override
  String get pinDialogPasscode2 => 'código de acceso.';

  @override
  String get modeSelectionAuthenticationFailedOrWasCancelled =>
      'La autenticación falló o se canceló. Inténtelo de nuevo.';

  @override
  String get modeSelectionHowShouldWeHandleYour =>
      '¿Cómo debemos manejar sus datos?';

  @override
  String get modeSelectionYouCanChangeThisAnytime =>
      'Puede cambiarlo en cualquier momento en Ajustes.';

  @override
  String get modeSelectionRecommended => 'RECOMENDADO';

  @override
  String get modeSelectionPrivacySetup => 'Privacidad · configuración';

  @override
  String get modeSelectionPrivateMode => 'Modo privado';

  @override
  String get modeSelectionYourDataStaysOnThis =>
      'Sus datos se quedan en este dispositivo, cifrados. Desbloquee con biometría o un código de acceso. Puede volver a su borrador cuando quiera.';

  @override
  String get modeSelectionPublicMode => 'Modo público';

  @override
  String get modeSelectionNoDataIsSavedAfter =>
      'No se guarda ningún dato después de cerrar la aplicación. Ideal para dispositivos compartidos o para un solo uso sin dejar rastro.';

  @override
  String get sideEffectsForTheMedicationsYouRe =>
      'Para los medicamentos que toma actualmente, estos son los efectos secundarios comunes; marque los que realmente tenga. Anotarlos (sobre todo los que afectan sus actividades diarias) ayuda a su equipo de atención. Es información sobre efectos secundarios comunes, no es consejo médico.';

  @override
  String get sideEffectsWorthDiscussingWithYourDoctor =>
      'Vale la pena hablarlo con su médico';

  @override
  String get sideEffectsOptionalAddOn => 'Complemento opcional';

  @override
  String get sideEffectsAskYourDoctorOrPharmacist =>
      'Pregunte a su médico o farmacéutico';

  @override
  String get educationCategoryBrowserNoSectionsInThisCategory =>
      'Todavía no hay secciones en esta categoría.';

  @override
  String get educationMostOfThisComesStraight =>
      'La mayor parte proviene directamente del folleto oficial de la MHAD de PA, más algunas explicaciones en lenguaje sencillo. Sin publicidad ni opiniones: solo las normas y lo que significan.';

  @override
  String get educationSearchArticlesGlossaryFaqs =>
      'Buscar artículos, glosario, preguntas frecuentes…';

  @override
  String get educationYourDirectiveIsYourVoice =>
      '\"Su directiva es su voz: escrita por adelantado, guardada en un lugar seguro y respetada cuando usted no pueda hablar por sí mismo.\"';

  @override
  String get educationPaOfficeOfMentalHealth =>
      '— PA OFFICE OF MENTAL HEALTH & SUBSTANCE ABUSE SERVICES · FOLLETO, P. 3';

  @override
  String get educationTypeToSearchEducationalContent =>
      'Escriba para buscar contenido educativo...';

  @override
  String get educationBrowseAllTopics => 'Ver todos los temas';

  @override
  String get educationUnderstand => 'Entienda ';

  @override
  String get educationYouSign => ' de firmar.';

  @override
  String get learnAiPanelAskTheAi => 'Preguntar a la IA';

  @override
  String get learnAiPanelSetUpAiAssistant => 'Configurar el asistente de IA';

  @override
  String get learnAiPanelNotLegalOrMedicalAdvice =>
      'No es asesoría legal ni médica.';

  @override
  String get learnAiPanelAskAQuestion => 'Haga una pregunta…';

  @override
  String get educationArticleDetailTryIt => 'PRUÉBELO';

  @override
  String get educationArticleDetailReadyToWriteYours =>
      '¿Listo para escribir la suya?';

  @override
  String get educationArticleDetailTheGuidedWizardTakesAbout =>
      'El asistente guiado toma unos 20 minutos y funciona de forma anónima.';

  @override
  String get educationArticleDetailStartMyDirective => 'Empezar mi directiva';

  @override
  String get audioGuideCouldnTOpenTheQuestionnaire =>
      'No se pudo abrir el cuestionario para imprimirlo. Inténtelo de nuevo.';

  @override
  String get audioGuideRecordYourWishesByVoice => 'Grabe sus deseos con su voz';

  @override
  String get audioGuideDescribeYourWishesOutLoud =>
      'Describa sus deseos en voz alta, suba la grabación en la pantalla Autocompletar con una foto y la IA completará su directiva; usted revisa cada campo antes de que se guarde nada.';

  @override
  String get audioGuidePrintTheQuestionnaire => 'Imprimir el cuestionario';

  @override
  String get audioGuidePrintItToReadAloud =>
      'Imprímalo para leerlo en voz alta mientras graba, o para completarlo a mano primero.';

  @override
  String get audioGuidePrint => 'Imprimir';

  @override
  String get audioGuideSetTheseInTheApp => 'Indique esto en la aplicación:';

  @override
  String get audioGuideWorthSayingOutLoudAutofill =>
      'Vale la pena decirlo en voz alta; el autocompletado ahora recoge esto:';

  @override
  String get audioGuideHowToRecord => 'Cómo grabar';

  @override
  String get audioGuideWhatTheRecordingCanT =>
      'Lo que la grabación no puede completar';

  @override
  String get ulyssesClauseBeforeYouAcknowledge => 'Antes de aceptarlo';

  @override
  String get ulyssesClauseThisIsASignificantDecision =>
      'Esta es una decisión importante. Una vez que se determine que usted no tiene capacidad, no podrá revocar la directiva hasta que la recupere. Le recomendamos encarecidamente hablarlo con un especialista de apoyo entre pares o con su médico antes de guardarlo.';

  @override
  String get ulyssesClauseIUnderstand => 'Entiendo';

  @override
  String get ulyssesClauseSometimesDuringACrisisPeople =>
      'A veces, durante una crisis, las personas rechazan tratamientos que querrían recibir cuando están bien. La ley de PA respeta lo que usted escribió hoy, aunque proteste en ese momento.';

  @override
  String get ulyssesClauseSelfBindingUlysses => 'AUTOVINCULACIÓN (\"Ulises\")';

  @override
  String get ulyssesClauseTieMyselfToTheMast => 'Atarme al mástil.';

  @override
  String get ulyssesClausePerPaAct19420 =>
      'Según la Ley 194 de PA (20 Pa.C.S. §§ 5825, 5839), esta directiva solo puede revocarse mientras yo tenga capacidad. Una vez que se determine que no tengo capacidad, lo que escribí aquí se mantiene, incluso por encima de mi protesta en ese momento, hasta que recupere la capacidad.';

  @override
  String get ulyssesClauseIAcknowledgeThis => 'Lo acepto';

  @override
  String get ulyssesClauseRecordedInYourDirectivePdf =>
      'Queda registrado en el PDF de su directiva.';

  @override
  String get ulyssesClauseBoundariesOnThisClause => 'Límites de esta cláusula';

  @override
  String get exportCardsBeforeSharingEnsureThisDirective =>
      'Antes de compartirla: asegúrese de que esta directiva esté firmada, fechada y atestiguada por dos adultos (18+), como exige la Ley 194 de PA. Dé copias a su agente, a su médico y a sus personas de apoyo.';

  @override
  String get exportCardsPrincipal => 'Declarante';

  @override
  String get exportCardsTheExportedPdfIsNot =>
      'El PDF exportado no está cifrado. Compártalo solo por medios de confianza.';

  @override
  String get exportCardsImportantBeforeSharingEnsureThis =>
      'Importante: antes de compartirla, asegúrese de que esta directiva esté firmada, fechada y atestiguada por dos adultos, como exige la Ley 194 de PA. Dé copias a su agente, a su médico y a sus personas de apoyo.';

  @override
  String get pdfPreviewUsLetter8511 => 'CARTA EE. UU. · 8.5×11\"';

  @override
  String get pdfPreviewShare => 'Compartir';

  @override
  String get pdfPreviewSizedForUsLetter8 =>
      'Tamaño carta de EE. UU. (8.5 × 11″) con márgenes de 1 pulgada. La vista previa ocupa todo el ancho; use − / + para acercar o alejar.';

  @override
  String get pdfPreviewPages => 'PÁGINAS';

  @override
  String get pdfPreviewExportShare => 'Exportar y compartir';

  @override
  String get pdfPreviewClosePreview => 'Cerrar la vista previa';

  @override
  String get pdfPreviewRenderingPdfPreview =>
      'Generando la vista previa del PDF';

  @override
  String get pdfPreviewFitPageToWindow => 'Ajustar la página a la ventana';

  @override
  String get pdfPreviewYourDirective => 'Su directiva, ';

  @override
  String get pdfPreviewOnPaper => 'en papel.';

  @override
  String get exportSelectAtLeastOneSection =>
      'Seleccione al menos una sección para incluir.';

  @override
  String get exportIncompleteDirective => 'Directiva incompleta';

  @override
  String get exportGoBack => 'Volver';

  @override
  String get exportEditDirective => 'Editar la directiva';

  @override
  String get exportExportAnyway => 'Exportar de todos modos';

  @override
  String get exportExportedFileIsNotEncrypted =>
      'El archivo exportado no está cifrado';

  @override
  String get exportThePdfYouAreAbout =>
      'El PDF que va a compartir contiene su directiva de salud mental completa (nombres, agentes, medicamentos, firmas). Se genera sin cifrar porque la biblioteca de PDF que usamos no admite protección con contraseña.\n\nCompártalo solo por medios de confianza (p. ej., entregándolo en mano o por un correo seguro a un proveedor específico). Evite subirlo a sitios públicos, enlaces en la nube o aplicaciones de mensajería no confiables.';

  @override
  String get exportIUnderstandContinue => 'Entiendo, continuar';

  @override
  String get exportCouldnTGenerateThePdf => 'No se pudo generar el PDF.';

  @override
  String get exportSelectAtLeastOneSection2 =>
      'Seleccione al menos una sección para la vista previa.';

  @override
  String get exportNothingToDownloadYet => 'Todavía no hay nada para descargar';

  @override
  String get exportStartADirectiveFirstThen =>
      'Primero empiece una directiva; luego vuelva aquí para verla, descargarla e imprimirla.';

  @override
  String get exportSelectFormsToInclude =>
      'Seleccione los formularios que desea incluir:';

  @override
  String get exportAdditionalPages => 'Páginas adicionales:';

  @override
  String get exportPrintABlankFormFill =>
      'Imprimir un formulario en blanco (para completar a mano)';

  @override
  String get exportPlainSignable => 'Sencillo (para firmar)';

  @override
  String get exportLegalInfoOnly => 'Legal (solo informativo)';

  @override
  String get exportHeadsUpTheLegalLanguage =>
      'Atención: la versión en lenguaje legal es solo de referencia. Firme y use el formulario oficial en lenguaje sencillo.';

  @override
  String get exportOpenPdf => 'Abrir el PDF';

  @override
  String get exportOpenWalletCardPdf => 'Abrir la tarjeta de billetera (PDF)';

  @override
  String get exportEncryptTheFile => 'Cifrar el archivo';

  @override
  String get exportDownload => 'Descargar';

  @override
  String get exportFhirJson => 'FHIR JSON';

  @override
  String get exportFhirXml => 'FHIR XML';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportZipBundle => 'paquete .zip';

  @override
  String get exportDoneBackToHome => 'Listo, volver al inicio';

  @override
  String get exportCopiedToClipboard => 'Copiado al portapapeles.';

  @override
  String get exportCouldnTSaveTheFile =>
      'No se pudo guardar el archivo. Inténtelo de nuevo.';

  @override
  String get exportExportedYourDirectiveBundlePdf =>
      'Se exportó el paquete de su directiva: PDF, JSON, XML y CSV.';

  @override
  String get exportCouldNotBuildTheZip => 'No se pudo crear el paquete .zip.';

  @override
  String get exportCouldnTGenerateTheWallet =>
      'No se pudo generar la tarjeta de billetera. Inténtelo de nuevo.';

  @override
  String get exportYourOfficialDirective => 'Su directiva oficial';

  @override
  String get exportKeepACopy => 'Guardar una copia';

  @override
  String get exportAdvancedDataExports => 'Avanzado · exportación de datos';

  @override
  String get exportDeclarationPowerOfAttorneyMost =>
      'Declaración + Poder Notarial (lo más completo)';

  @override
  String get exportTreatmentPreferencesOnlyNoAgent =>
      'Solo preferencias de tratamiento (sin agente)';

  @override
  String get exportAgentAuthorityOnlyNoPersonal =>
      'Solo la autoridad del agente (sin preferencias personales)';

  @override
  String get exportSupplementaryLegalInformation =>
      'Información legal complementaria';

  @override
  String get exportAdditionalLegalReferenceInformation =>
      'Información legal adicional de referencia';

  @override
  String get exportDistributionChecklistNotes =>
      'Lista de distribución y notas';

  @override
  String get exportBlankPagesForHandwrittenNotes =>
      'Páginas en blanco para notas escritas a mano';

  @override
  String get exportOpenThePdfDirectiveIn =>
      'Abra la directiva en PDF en su visor para imprimirla o guardarla';

  @override
  String get exportDownloadAnEditableCopyOf =>
      'Descargue una copia editable de su directiva';

  @override
  String get exportExportAsFhirJsonFor =>
      'Exportar como FHIR JSON para expedientes médicos electrónicos';

  @override
  String get exportExportAsFhirXmlFor =>
      'Exportar como FHIR XML para expedientes médicos electrónicos';

  @override
  String get exportExportAsCsvSpreadsheet =>
      'Exportar como hoja de cálculo CSV';

  @override
  String get exportDownloadEverythingPdfJsonXml =>
      'Descargar todo (PDF, JSON, XML, CSV) en un paquete zip';

  @override
  String get exportYourDirective => 'Su directiva,\n';

  @override
  String get appThemeWarmTeal => 'Verde azulado cálido';

  @override
  String get appThemeBalancedCalmProfessional =>
      'Equilibrado, tranquilo, profesional.';

  @override
  String get appThemeDeepNavy => 'Azul marino';

  @override
  String get appThemeFormalSteadyHighContrast =>
      'Formal, estable, de alto contraste.';

  @override
  String get appThemeSageGreen => 'Verde salvia';

  @override
  String get appThemeSoftNaturalApproachable => 'Suave, natural, cercano.';

  @override
  String get aiSetupReplyWithTheSingleWord => 'Reply with the single word: ok';

  @override
  String get aiSetupRemoveApiKey => '¿Quitar la clave de API?';

  @override
  String get aiSetupAiFeaturesWillBeDisabled =>
      'Las funciones de IA se desactivarán hasta que añada una clave nueva.';

  @override
  String get aiSetupApiKeyRemoved => 'Clave de API eliminada';

  @override
  String get aiSetupAiAssistantSetup => 'Configuración del asistente de IA';

  @override
  String get aiSetupYourApiKeyWillNot =>
      'Su clave de API no se guardará de forma permanente. Se mantiene en memoria durante esta sesión, con una copia temporal de hasta 10 minutos para que pueda recuperarla si la aplicación se recarga; luego se descarta al cerrar la aplicación o borrar sus datos.';

  @override
  String get aiSetupStep1OpenAPrivate =>
      'Paso 1: abra una ventana privada o de incógnito';

  @override
  String get aiSetupYouLlNeedToSign =>
      'Tendrá que iniciar sesión en su cuenta de Google para obtener una clave de API. Para proteger su sesión en dispositivos compartidos o públicos, primero abra una ventana de navegación privada:';

  @override
  String get aiSetupOnAPhoneTapThe =>
      'En un teléfono: toque el menú (⋮ o ⋯) y seleccione \"Nueva pestaña de incógnito\" o \"Nueva pestaña privada\".';

  @override
  String get aiSetupYourGoogleLoginWillBe =>
      'Su sesión de Google se olvidará automáticamente al cerrar la ventana privada.';

  @override
  String get aiSetupPrivacyNotice => 'Aviso de privacidad';

  @override
  String get aiSetupHowYourDataIsHandled => 'Cómo se manejan sus datos';

  @override
  String get aiSetupYourDirectiveDataIsHeld =>
      '- Los datos de su directiva solo se guardan en memoria; si la aplicación se cierra o falla, se conservan unos 10 minutos para recuperarlos y luego se borran; nunca se escriben en el disco ni en un servidor\n- Las funciones de IA son opcionales y la aplicación funciona sin ellas\n- Solo sale de su dispositivo el texto que usted envía expresamente por el chat de IA o Sugerencia de IA\n- Esta aplicación no es un servicio médico ni legal\n- Esta aplicación no cumple con HIPAA';

  @override
  String get aiSetupCommonQuestions => 'Preguntas frecuentes';

  @override
  String get aiSetupRemoveApiKey2 => 'Quitar la clave de API';

  @override
  String get aiSetupCreateAnApiKey => 'Crear una clave de API';

  @override
  String get aiSetupCreateANewApiKey =>
      'Cree una clave de API nueva en la página de claves de API; los valores predeterminados sirven.';

  @override
  String get aiSetupCopyAndPasteBelow => 'Cópiela y péguela abajo';

  @override
  String get aiSetupPasteFromClipboard => 'Pegar desde el portapapeles';

  @override
  String get aiSetupTestingConnection => 'Probando la conexión';

  @override
  String get accessibilitySettingsAdjustHowTheAppFeels =>
      'Ajuste la aplicación a su gusto. Los cambios se aplican en todas partes al instante.';

  @override
  String get accessibilitySettingsHowToUseReadAloud =>
      'Cómo usar la lectura en voz alta';

  @override
  String get accessibilitySettingsResetAccessibilitySettings =>
      'Restablecer los ajustes de accesibilidad';

  @override
  String get accessibilitySettingsReadThisPageAloud =>
      'Leer esta página en voz alta';

  @override
  String get accessibilitySettingsYourBrowserAndDeviceAlready =>
      'Su navegador y su dispositivo ya incluyen lectura en voz alta y funcionan mejor que un lector dentro de la aplicación; use una de estas opciones:';

  @override
  String get accessibilitySettingsPeopleWhoITrustWill =>
      'Las personas en quienes confío tomarán mis decisiones si yo no puedo.';

  @override
  String get accessibilitySettingsEnglish => 'English';

  @override
  String get accessibilitySettingsEspaOl => 'Español';

  @override
  String get accessibilitySettingsAccessibility => 'Accesibilidad';

  @override
  String get accessibilitySettingsTextSize => 'Tamaño del texto';

  @override
  String get accessibilitySettingsDyslexiaFriendlyFont =>
      'Fuente adaptada para dislexia';

  @override
  String get accessibilitySettingsBoldText => 'Texto en negrita';

  @override
  String get accessibilitySettingsReduceMotion => 'Reducir el movimiento';

  @override
  String get accessibilitySettingsHighContrast => 'Alto contraste';

  @override
  String get accessibilitySettingsReadAloud => 'Lectura en voz alta';

  @override
  String get accessibilitySettingsRightClickThePageRead =>
      'Haga clic derecho en la página → “Leer en voz alta” (Edge), o use el Modo de lectura o una extensión en Chrome. Edge: Ctrl+Shift+U.';

  @override
  String get accessibilitySettingsSelectTextTapListenOr =>
      'Seleccione el texto → toque “Escuchar”, o active Ajustes → Accesibilidad → Seleccionar para pronunciar / TalkBack.';

  @override
  String get accessibilitySettingsSettingsAccessibilitySpokenContentTurn =>
      'Ajustes → Accesibilidad → Contenido leído → active “Leer pantalla” y luego deslice hacia abajo con dos dedos.';

  @override
  String get accessibilitySettingsNarratorCtrlWinEnterOr =>
      'Narrador: Ctrl+Win+Enter. O use “Leer en voz alta” de Edge, descrito arriba.';

  @override
  String get accessibilitySettingsSystemSettingsAccessibilitySpokenContent =>
      'Ajustes del Sistema → Accesibilidad → Contenido leído → “Leer selección” y luego pulse Opción+Esc.';

  @override
  String get privacyPolicyPrivacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicyPaMhadAppPrivacyPolicy =>
      'Política de privacidad de la aplicación PA MHAD';

  @override
  String get privacyPolicyReviewLegalDisclaimer => 'Revisar el aviso legal';

  @override
  String get privacyPolicyDataWeCollect => 'Datos que recopilamos';

  @override
  String get privacyPolicyThisAppCollectsOnlyThe =>
      'Esta aplicación solo recopila la información que usted ingresa en los formularios de su Directiva Anticipada de Salud Mental, que incluye:\n  - Información personal (nombre, dirección, teléfono, fecha de nacimiento)\n  - Información del agente y de los testigos\n  - Preferencias de tratamiento y listas de medicamentos\n  - Firmas digitales\n  - Instrucciones adicionales\n\nNo recopilamos datos de análisis, informes de fallos, identificadores del dispositivo ni datos de ubicación.';

  @override
  String get privacyPolicyHowDataIsStoredProtected =>
      'Cómo se guardan y protegen los datos';

  @override
  String get privacyPolicyYourDirectiveDataIsNot =>
      'Los datos de su directiva NO se transmiten al desarrollador de la aplicación ni a ningún tercero para su almacenamiento.\n\nEsta es una aplicación web: sus datos se guardan en una base de datos en memoria dentro de la pestaña de su navegador. Si cierra la pestaña o la aplicación falla, su trabajo se conserva en este dispositivo durante unos 10 minutos para que pueda volver a abrirlo y recuperarlo; luego se borra. No se escribe nada en un servidor. Exporte o imprima su directiva para conservar una copia permanente.';

  @override
  String get privacyPolicyAiFeaturesThirdPartyData =>
      'Funciones de IA y datos compartidos con terceros';

  @override
  String get privacyPolicyIfYouChooseToUse =>
      'Si decide usar las funciones opcionales de IA (el chat del Asistente de IA o Sugerencia de IA), el texto que envíe se manda para su procesamiento al proveedor de IA que usted elija: Google Gemini de forma predeterminada, o Anthropic Claude, OpenAI o xAI Grok si elige uno de ellos y añade su propia clave.\n\nEn el nivel gratuito de Gemini de Google, Google puede:\n  - Usar sus datos de entrada y salida para mejorar sus productos\n  - Permitir que revisores humanos lean sus entradas y salidas\n  - Conservar los datos indefinidamente (sin vencimiento automático)\nLos demás proveedores tratan sus datos según sus propias políticas de datos de API; revise la política del proveedor que use.\n\nLa aplicación elimina la información de identificación personal más común (números de seguro social, números de teléfono, correos electrónicos, fechas de nacimiento, direcciones, nombres y nombres de centros) antes de enviar su texto a cualquier proveedor, pero es un filtro de mejor esfuerzo y no puede garantizar una eliminación completa.\n\nLas funciones de IA son totalmente opcionales. La aplicación funciona por completo sin ellas.';

  @override
  String get privacyPolicyGeminiFreeTierDataPractices =>
      'Prácticas de datos del nivel gratuito de Gemini';

  @override
  String get privacyPolicyIfYouUseTheAi =>
      'Si usa las funciones de IA con el nivel gratuito de Gemini de Google, tenga en cuenta lo siguiente:\n\n1. Google conserva indefinidamente los datos de las conversaciones con la IA en el nivel gratuito. No hay vencimiento automático.\n\n2. Revisores humanos de Google pueden leer sus entradas y salidas como parte de sus procesos de calidad y seguridad.\n\n3. Ni usted ni esta aplicación pueden recuperar ni borrar los datos enviados a Gemini. Una vez enviados, quedan bajo el control de Google.\n\n4. Si le preocupa la privacidad de sus datos, considere pasar al nivel de pago de Gemini, que ofrece políticas de protección de datos más sólidas y no usa sus datos para entrenar modelos.\n\nSi elige otro proveedor (Anthropic, OpenAI o xAI) en lugar de Gemini, se aplica la política de datos y de conservación de ese proveedor; revísela antes de enviar contenido sensible.\n\nPuede evitar compartir cualquier dato con terceros si no usa las funciones de IA.';

  @override
  String get privacyPolicyInternationalUsersGdpr =>
      'Usuarios internacionales (RGPD)';

  @override
  String get privacyPolicyIfYouAreLocatedIn =>
      'Si se encuentra en el Espacio Económico Europeo (EEE), el Reino Unido o Suiza, el Reglamento General de Protección de Datos (RGPD) se aplica a su uso de esta aplicación.\n\nBase legal del tratamiento: su consentimiento explícito, otorgado mediante el aviso legal de la aplicación y los diálogos de consentimiento de IA.\n\nSus derechos según el RGPD:\n  - Derecho de acceso: todos sus datos se guardan localmente en su dispositivo; usted tiene acceso directo en todo momento.\n  - Derecho de supresión: use \"Eliminar todos los datos\" en el menú de la aplicación para borrar de forma permanente todos los datos locales.\n  - Derecho a la portabilidad de los datos: exporte sus directivas como PDF o FHIR JSON (un formato estándar de expedientes médicos) en cualquier momento.\n  - Derecho a retirar el consentimiento: deje de usar las funciones de IA cuando quiera; quite su clave de API para evitar más transmisiones de datos.\n  - Derecho a la limitación: puede usar la aplicación en Modo Público sin que se conserven datos.\n\nLos datos enviados al proveedor de IA que elija se procesan según la política de privacidad y las condiciones de tratamiento de datos de ese proveedor. No podemos controlar ni borrar los datos una vez enviados.';

  @override
  String get privacyPolicyUsStateConsumerHealthData =>
      'Leyes estatales de EE. UU. sobre datos de salud del consumidor (CA, WA, CT, NV, NY)';

  @override
  String get privacyPolicyThisAppMayBeSubject =>
      'Esta aplicación puede estar sujeta a leyes estatales de privacidad de datos de salud del consumidor, como las de California (CCPA/CPRA), Washington (My Health My Data Act / MHMDA), Connecticut (disposiciones de salud de la CTDPA), Nevada (SB 370) y Nueva York (Health Information Privacy Act).\n\nEl contenido de una directiva de salud mental se considera \"datos de salud del consumidor\" según cada una de estas leyes. Según todas ellas: (1) Recopilamos datos sobre preferencias de tratamiento de salud mental **únicamente** para ayudarle a crear su directiva anticipada. (2) **No vendemos** sus datos de salud; no hay ningún destinatario comercial. (3) El único tercero que puede recibir parte de su texto es el proveedor de IA que usted elija (Google Gemini de forma predeterminada, o Anthropic, OpenAI o xAI), y **solo** si usted acepta expresamente las funciones de IA en cada sesión. (4) No usamos SDK de terceros, herramientas de análisis, plataformas de publicidad, píxeles de seguimiento ni cookies. (5) Puede eliminar todos los datos guardados localmente en cualquier momento con \"Eliminar todos los datos\" en el menú de la aplicación.\n\nLa MHMDA de Washington incluye un **derecho privado de acción**; hemos diseñado la aplicación para exigir un consentimiento explícito en cada sesión antes de cualquier transferencia de datos de salud del consumidor a terceros, y consideramos que el consentimiento por escrito está condicionado a los términos específicos que se muestran en el diálogo de consentimiento de IA.\n\nSi tiene preguntas sobre sus derechos de privacidad, comuníquese con el desarrollador por los medios indicados en la sección Contacto más abajo (se ofrecen varios medios, según la Norma de Notificación de Violaciones de Datos de Salud de la FTC).';

  @override
  String get privacyPolicyMedicalReferenceLookupsUS =>
      'Consultas de referencia médica (datos del gobierno de EE. UU.)';

  @override
  String get privacyPolicyToHelpYouFillIn =>
      'Para ayudarle a completar y entender su directiva, la aplicación consulta bases de datos públicas y gratuitas del gobierno de EE. UU. Estas consultas usan ÚNICAMENTE el término o código necesario para cada búsqueda. Nunca reciben su identidad (su nombre, fecha de nacimiento, dirección o teléfono), las personas que usted nombra (agentes, testigos, tutor) ni su directiva guardada.\n\nQué se envía y a quién:\n  - El nombre del medicamento que escribe → NLM RxTerms (autocompletado).\n  - El nombre de la condición que escribe → NLM ICD-10-CM (búsqueda de diagnósticos).\n  - El nombre de un médico o proveedor que escribe en la búsqueda opcional de médicos → registro NPI de la NLM, que se usa solo para buscar a ese proveedor en el registro público de proveedores de salud.\n  - Una condición (por su código CIE-10) o un medicamento (por su nombre, convertido en un código mediante NLM RxNav) → NLM MedlinePlus Connect, para obtener una explicación en lenguaje sencillo.\n  - El nombre de un medicamento → openFDA (Administración de Alimentos y Medicamentos de EE. UU.), para obtener la etiqueta oficial de la FDA de ese medicamento, que se usa como base para la lista de efectos secundarios.\n\nNinguna de estas solicitudes incluye información personal ni que permita identificarle; solo el término médico, el código o el nombre del proveedor que se busca.\n\nLa NLM, los NIH y la FDA no son responsables de este producto ni lo respaldan o recomiendan. Estos servicios son solo informativos y no constituyen consejo médico; consulte a un profesional calificado. Los servicios Clinical Table de la NLM tienen un límite de 20 solicitudes por segundo.\n\nFuentes: Biblioteca Nacional de Medicina de EE. UU. (RxTerms, ICD-10-CM, registro NPI, RxNav, MedlinePlus Connect); Administración de Alimentos y Medicamentos de EE. UU. (openFDA).';

  @override
  String get privacyPolicyPdfExportSharing => 'Exportación y envío del PDF';

  @override
  String get privacyPolicyWhenYouExportAPdf =>
      'Cuando exporta un PDF de su directiva, se genera localmente en su dispositivo. Compartir el PDF (por correo electrónico, mensajería, etc.) lo envía a través del mecanismo habitual para compartir de su dispositivo. La aplicación no puede controlar dónde se guarda el PDF una vez compartido.';

  @override
  String get privacyPolicyYourRights => 'Sus derechos';

  @override
  String get privacyPolicyYouCanDeleteAnyDirective =>
      'Puede eliminar cualquier directiva en cualquier momento desde la pantalla de inicio. Al eliminar una directiva se borran de la base de datos local todos los datos asociados (información personal, agentes, medicamentos, testigos, firmas).\n\nPuede quitar las claves de API de sus proveedores de IA en cualquier momento desde la pantalla de configuración de la IA.\n\nDesinstalar la aplicación elimina todos los datos guardados localmente.';

  @override
  String get privacyPolicyNoThirdPartyTracking => 'Sin rastreo de terceros';

  @override
  String get privacyPolicyThisAppDoesNotInclude =>
      'Esta aplicación no incluye SDK de análisis de terceros, plataformas de publicidad, servicios de informes de fallos (como Firebase, Crashlytics o Sentry) ni píxeles de seguimiento.\n\nLas únicas conexiones de red externas que realiza esta aplicación son:\n  - El proveedor de IA que elija (Google Gemini de forma predeterminada, Anthropic, OpenAI o xAI), solo cuando usa funciones de IA\n  - NIH/NLM Clinical Table Search Service: búsquedas de medicamentos, condiciones y proveedores (médicos)\n  - NLM MedlinePlus Connect y RxNav: explicaciones en lenguaje sencillo sobre condiciones y medicamentos (solo envía un código CIE-10 o el nombre de un medicamento)\n  - openFDA / FDA de EE. UU.: etiquetas oficiales de medicamentos que sirven de base para la lista de efectos secundarios (solo envía el nombre de un medicamento)\n\nCada uno recibe solo el término o código que se busca, nunca su identidad ni su directiva. En ningún momento se envían datos al desarrollador de la aplicación.';

  @override
  String get privacyPolicyHipaaCompliance => 'HIPAA y cumplimiento normativo';

  @override
  String get privacyPolicyThisAppIsNotHipaa =>
      'Esta aplicación NO cumple con HIPAA. No es una entidad cubierta ni un socio comercial según HIPAA. La aplicación está pensada para el uso personal de quienes preparan su propia directiva anticipada de salud mental.\n\nAunque esta aplicación aplica medidas de privacidad alineadas con los principios del RGPD, la CCPA y la MHMDA (como se describe arriba), no ha sido auditada ni certificada de forma independiente en cuanto al cumplimiento de estas normas. Si necesita un cumplimiento normativo verificado, consulte con un profesional de privacidad antes de usarla.';

  @override
  String get privacyPolicyBreachNotification =>
      'Notificación de violaciones de datos';

  @override
  String get privacyPolicyInAccordanceWithTheFtc =>
      'De acuerdo con la Norma de Notificación de Violaciones de Datos de Salud de la FTC, si se produce una divulgación no autorizada de su información de salud debido a una violación de seguridad, avisaremos a los usuarios afectados dentro de los 60 días calendario siguientes a su descubrimiento.\n\nComo esta aplicación guarda los datos localmente en su dispositivo y no mantiene una base de datos en un servidor, el riesgo de violación se limita a las funciones opcionales de IA. Si el proveedor de IA que usted eligió nos avisa de una violación que afecte a datos enviados a través de la aplicación, transmitiremos ese aviso mediante una notificación dentro de la aplicación y una publicación en la página de la política de privacidad.';

  @override
  String get privacyPolicyContact => 'Contacto';

  @override
  String get settingsBrightness => 'Brillo';

  @override
  String get settingsScreenshotProtection =>
      'Protección contra capturas de pantalla';

  @override
  String get settingsAdminToolTitle =>
      'Admin: herramienta de actualización de datos';

  @override
  String get settingsAdminToolSubtitle =>
      'Solo para mantenimiento — requiere contraseña. Se ocultará al lanzar.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsPaMentalHealthAdvanceDirective =>
      'Directiva Anticipada de Salud Mental de PA\nSegún la Ley 194 de 2004 de Pensilvania (vigente desde el 29 de enero de 2005)\n\nEsta aplicación le ayuda a documentar sus preferencias de tratamiento de salud mental. No es asesoría legal ni médica, y no sustituye a un abogado o profesional clínico con licencia. Consulte el aviso legal completo más arriba para ver los detalles.\n\nSu directiva es válida durante dos años a partir de la fecha en que la firma, salvo que en la fecha de vencimiento se determine que usted no tiene capacidad para tomar decisiones de salud mental; en ese caso, sigue vigente hasta que recupere la capacidad.\n\nEl contenido del formulario se basa en el folleto oficial de la MHAD de PA publicado por el Disabilities Law Project (2005).';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsLegalPrivacy => 'Legal y privacidad';

  @override
  String get settingsChooseAProviderAndAdd =>
      'Elija un proveedor y añada su clave de API';

  @override
  String get settingsTextSizeDyslexiaFontBold =>
      'Tamaño del texto, fuente para dislexia, negrita, contraste, idioma';

  @override
  String get settingsHowYourDataIsStored =>
      'Cómo se guardan y protegen sus datos';

  @override
  String get settingsPrivacyPermissions => 'Privacidad y permisos';

  @override
  String get settingsWhatPermissionsTheAppUses =>
      'Qué permisos usa la aplicación y qué prometemos sobre cada uno';

  @override
  String get settingsLegalDisclaimer => 'Aviso legal';

  @override
  String get settingsTermsLimitationsAndYourLegal =>
      'Condiciones, limitaciones y sus derechos legales';

  @override
  String get assistantMessageWidgetsVerifiedWithWebSearch =>
      'Verificado con búsqueda web';

  @override
  String get assistantMessageWidgetsSources => 'Fuentes';

  @override
  String get assistantMessageWidgetsVerifyOnTheWeb => 'Verificar en la web';

  @override
  String get assistantMessageWidgetsAiIsTyping => 'La IA está escribiendo';

  @override
  String get assistantContextPanelAskAboutFormTypesAgents =>
      'Pregunte sobre los tipos de formulario, los agentes, las preferencias de tratamiento o cualquier tema del folleto de la MHAD de PA. Pruebe con una de estas:';

  @override
  String get assistantContextPanelPiiRedactionOn =>
      'OCULTACIÓN DE DATOS PERSONALES ACTIVADA';

  @override
  String get assistantContextPanelNamesAddressesPhoneNumbersAnd =>
      'Los nombres, direcciones, números de teléfono y fechas se reemplazan por marcadores antes de enviarlos a Gemini. Las sugerencias vuelven con los marcadores completados en su dispositivo.';

  @override
  String get assistantContextPanelContextTheAiSees => 'Contexto que ve la IA';

  @override
  String get assistantContextPanelSuggestedPrompts => 'Preguntas sugeridas';

  @override
  String get assistantContextPanelWhatICanHelpWith => 'En qué puedo ayudar';

  @override
  String get assistantContextPanelPrivacy => 'Privacidad';

  @override
  String get assistantContextPanelFormType => 'Tipo de formulario';

  @override
  String get assistantContextPanelCurrentStep => 'Paso actual';

  @override
  String get assistantContextPanelFilledFields => 'Campos completados';

  @override
  String get assistantContextPanelPii => 'Datos personales';

  @override
  String get assistantTheReplyFailed => 'No se pudo obtener la respuesta.';

  @override
  String get assistantStillFailingCheckYourConnection =>
      'Sigue fallando: revise su conexión o su clave.';

  @override
  String get assistantClearConversation => '¿Borrar la conversación?';

  @override
  String get assistantThisWillEraseAllMessages =>
      'Esto borrará todos los mensajes. No se puede deshacer.';

  @override
  String get assistantClear => 'Borrar';

  @override
  String get assistantToUseTheAiAssistant =>
      'Para usar el asistente de IA, configure una clave de IA; el nivel gratuito de Gemini funciona.';

  @override
  String get assistantSetUpFree => 'Configurar (gratis)';

  @override
  String get assistantPersonalInfoRemoved => 'Información personal eliminada';

  @override
  String get assistantAskMeAnythingAboutYour =>
      'Pregúnteme lo que quiera sobre su\nDirectiva Anticipada de Salud Mental de PA';

  @override
  String get assistantSuggestedQuestions => 'Preguntas sugeridas:';

  @override
  String get assistantClearConversation2 => 'Borrar conversación';

  @override
  String get assistantApiKeySettings => 'Configuración de la clave de API';

  @override
  String assistantDisclaimerNotLegalOrMedical(String phone) {
    return 'Aviso: no es asesoramiento legal ni médico. Para preguntas legales, comuníquese con PA Protection and Advocacy: $phone ';
  }

  @override
  String get assistantAskAQuestionAboutYour =>
      'Haga una pregunta sobre su directiva...';

  @override
  String get assistantSend => 'Enviar';

  @override
  String get directiveFormChoiceWithAPoaOnlyForm =>
      'Con un formulario de solo Poder Notarial, su agente tendrá autoridad para tomar decisiones de atención de salud mental en su nombre, pero el documento no incluirá sus preferencias personales de tratamiento.\n\nConsidere usar el formulario Combinado para documentar sus preferencias Y nombrar a un agente. Así su equipo de atención tendrá la mayor orientación posible.';

  @override
  String get directiveFormChoiceContinueWithPoa =>
      'Continuar con Poder Notarial';

  @override
  String get directiveFormChoiceYouCanSwitchFormTypes =>
      'Puede cambiar de tipo de formulario más adelante si cambia de opinión; el Combinado es el más completo.';

  @override
  String get directiveFormChoiceCombinedDirective => 'Directiva combinada';

  @override
  String get directiveFormChoiceTreatmentPreferencesAndATrusted =>
      'Preferencias de tratamiento y una persona de confianza que decida, en un solo documento. 11 pasos cortos · unos 20 minutos.';

  @override
  String get directiveFormChoiceStartNow => 'Empezar ahora';

  @override
  String get directiveFormChoiceNotSureWhichFormFits =>
      '¿No sabe qué formulario le conviene? Responda el cuestionario de 4 preguntas.';

  @override
  String get directiveFormChoiceHelpMeChoose => 'Ayúdeme a elegir →';

  @override
  String get directiveFormChoicePowerOfAttorneyOnly => 'Solo Poder Notarial';

  @override
  String get directiveFormChoiceTakeThe4QuestionQuiz =>
      'Responda el cuestionario de 4 preguntas para elegir un formulario';

  @override
  String get webLandingALegalDocumentThatTells =>
      'Un documento legal que indica a los médicos, a su familia y a una persona de confianza cómo cuidarle si usted no puede hablar por sí mismo. Gratis, anónimo y toma unos 20 minutos.';

  @override
  String get webLandingYouReWorkingAnonymouslyNothing =>
      'Está trabajando de forma anónima. No se guarda nada.';

  @override
  String get webLandingNoAccountNoCloudIf =>
      'Sin cuenta ni nube. Si cierra la pestaña o la aplicación falla, su trabajo se conserva en este dispositivo durante 10 minutos para que pueda volver a abrirlo y recuperarlo; después se borra para siempre. Abra su PDF y guárdelo para conservar una copia.';

  @override
  String get webLandingHowThisWorks => 'CÓMO FUNCIONA →';

  @override
  String get webLandingAnMhadIsYourVoice =>
      '“Una DASM es su voz cuando usted no puede hablar por sí mismo.”';

  @override
  String get webLandingPaMhadBookletOfficeOf =>
      '— Folleto de la DASM de PA · Oficina de Salud Mental';

  @override
  String get webLandingReadTheBasics => 'Lea lo básico →';

  @override
  String get webLandingPennsylvaniaAct194Of2004 =>
      'Pensilvania · Ley 194 de 2004';

  @override
  String get webLandingOurPrivacyPromise => 'Nuestro compromiso de privacidad';

  @override
  String get webLandingFromTheBooklet => 'Del folleto';

  @override
  String get webLandingPrintABlankForm => 'Imprimir un formulario en blanco';

  @override
  String get webLandingPrintBlankForm => 'Imprimir formulario en blanco';

  @override
  String get webLandingTheBasics => 'Lo básico';

  @override
  String get webLandingMakeAMentalHealth => 'Cree su ';

  @override
  String get webLandingAdvanceDirective =>
      'directiva anticipada de salud mental.';

  @override
  String get homeToolsGridMakeItFindable => 'Hágala fácil de encontrar';

  @override
  String get homeToolsGridCrisisHelp => 'Ayuda en crisis';

  @override
  String get homeDirectiveHeroDraft => '● Borrador';

  @override
  String get homeDirectiveHeroContinueWhereYouLeftOff =>
      'Continúe donde lo dejó';

  @override
  String get facilitatorGetHelpEvidenceBased =>
      'Obtenga ayuda · basada en evidencia';

  @override
  String get facilitatorTalkToSomeoneTrained => 'Hable con alguien capacitado';

  @override
  String get facilitatorPennsylvaniaPeerSpecialistsAndRights =>
      'Los especialistas de apoyo entre pares y los defensores de derechos de Pensilvania le ayudan a completar el formulario. Es gratis; esta aplicación no tiene sistema de citas: llame o visite a una de las organizaciones a continuación.';

  @override
  String get facilitatorPrintReviewItTogether => 'Imprímala y revísenla juntos';

  @override
  String get facilitatorPrintOrScreenShareYour =>
      'Imprima o comparta en pantalla su borrador y revíselo con un amigo, un familiar o un par. No pueden cambiar nada en su aplicación; eso queda en sus manos.';

  @override
  String get facilitatorEmailADraftToMy => 'Enviar un borrador a mi médico';

  @override
  String get facilitatorGenerateThePdfInExport =>
      'Genere el PDF en Exportar y luego envíelo con la aplicación de correo de su teléfono. Pida comentarios a su terapeuta o psiquiatra. Usted mismo pasará sus sugerencias al formulario; esta aplicación no se conecta con su historia clínica electrónica.';

  @override
  String get facilitatorCall => 'Llamar';

  @override
  String get facilitatorOpenWebsite => 'Abrir sitio web';

  @override
  String get legalSheetFullLegalDisclosure => 'Aviso legal completo';

  @override
  String get legalSheetTheEightSectionsBelowWere =>
      'Las ocho secciones siguientes se aceptaron al abrir la aplicación por primera vez. Toque para ampliar.';

  @override
  String get legalSheetFullLegalSections => 'Secciones legales completas';

  @override
  String get legalSheetNotLegalOrMedicalAdvice =>
      'No es asesoramiento legal ni médico';

  @override
  String get legalSheetNoProfessionalRelationship =>
      'Ninguna relación profesional';

  @override
  String get legalSheetUseAtYourOwnRisk => 'Uso bajo su propio riesgo';

  @override
  String get legalSheetRequirementsForAValidDirective =>
      'Requisitos para una directiva válida';

  @override
  String get legalSheetTwoYearValidity => 'Validez de dos años';

  @override
  String get legalSheetRevocation => 'Revocación';

  @override
  String get legalSheetPrivacyAiFeatures => 'Privacidad y funciones de IA';

  @override
  String get legalSheetResourcesAssistance => 'Recursos y asistencia';

  @override
  String get legalSheetPaProtectionAdvocacy => 'PA Protection & Advocacy';

  @override
  String get legalSheetPaMentalHealthConsumersAssociation =>
      'PA Mental Health Consumers\' Association';

  @override
  String get legalSheetMentalHealthAssociationInPennsylvania =>
      'Mental Health Association in Pennsylvania';

  @override
  String get legalSheet988SuicideCrisisLifeline =>
      '988 Línea de Prevención del Suicidio y Crisis';

  @override
  String get legalSheetThisAppHelpsPennsylvaniaResidents =>
      'Esta aplicación ayuda a los residentes de Pensilvania a documentar sus preferencias de tratamiento conforme a la ';

  @override
  String get legalSheetPaAct194Of2004 => 'Ley 194 de PA de 2004';

  @override
  String get legalSheetTheInformationIsForInformational =>
      '. La información tiene fines exclusivamente informativos y ';

  @override
  String get legalSheetConstituteLegalOrMedicalAdvice =>
      ' constituye asesoramiento legal ni médico.';

  @override
  String get legalSheetItIsNotAMedical =>
      'No es un dispositivo médico. No diagnostica, trata, cura ni previene ninguna afección. Para decisiones de tratamiento, consulte a un profesional de salud mental calificado. Para preguntas legales, consulte a un abogado autorizado en PA.';

  @override
  String get legalSheetUseOfThisAppDoes => 'El uso de esta aplicación ';

  @override
  String get legalSheetCreateAnAttorneyClientRelationship =>
      ' crea una relación abogado–cliente, proveedor–paciente ni ninguna otra relación profesional entre usted y el desarrollador.';

  @override
  String get legalSheetYouAreSolelyResponsibleFor =>
      'Usted es el único responsable de asegurarse de que su directiva cumpla todos los requisitos legales de la ley de PA, incluida la firma correcta ante testigos.';

  @override
  String get legalSheetInPlainTermsThisApp =>
      'En palabras sencillas: esta aplicación le ayuda a plasmar sus propios deseos en una directiva, y usted la usa bajo su propio riesgo. Revise el documento final para verificar que sea correcto; pueden ocurrir errores y los datos que ingresó pueden estar desactualizados o incompletos. Si alguna vez no está seguro de si algo es legalmente adecuado para su situación, no dude en consultar a un abogado. La versión formal:';

  @override
  String get legalSheetThisAppIsProvided => 'Esta aplicación se proporciona ';

  @override
  String get legalSheetAsIs => '\"tal cual\"';

  @override
  String get legalSheetWithoutWarrantiesOfAnyKind =>
      ', sin garantías de ningún tipo, y usted la usa bajo su propio riesgo. En la máxima medida permitida por la ley, el desarrollador no es responsable de ningún daño derivado del uso de la aplicación o de cualquier documento creado con ella. Usted es responsable de revisar que su directiva sea correcta y completa; para preguntas legales específicas de su situación, consulte a un abogado autorizado en Pensilvania.';

  @override
  String get legalSheetAPaMentalHealthAdvance =>
      'Una Directiva Anticipada de Salud Mental de PA es legalmente válida ';

  @override
  String get legalSheetWhen => ' cuando:';

  @override
  String get legalSheetYouThePrincipalHaveLegal =>
      'Usted (el declarante) tiene capacidad legal en el momento de firmar';

  @override
  String get legalSheetItIsSignedInThe => 'Se firma en presencia de ';

  @override
  String get legalSheetBothWitnessesMeetEligibilityRequirements =>
      'Ambos testigos cumplen los requisitos de elegibilidad de la Ley 194';

  @override
  String get legalSheetYourDesignatedAgentOrAlternate =>
      'su agente designado o agente alternativo, su proveedor de atención de salud mental ni un empleado del centro donde recibe tratamiento, a menos que sean parientes suyos por consanguinidad, matrimonio o adopción.';

  @override
  String get legalSheetThisAppCapturesTouchDrawn =>
      'Esta aplicación captura firmas dibujadas en la pantalla para su comodidad durante la preparación. La directiva ';

  @override
  String get legalSheetDirectiveMustBeSignedIn =>
      ' debe firmarse con tinta original, en presencia de sus dos testigos, para ser legalmente válida.';

  @override
  String get legalSheetOnceSignedProvidersAndYour =>
      'Una vez firmada, los proveedores y su agente ';

  @override
  String get legalSheetWithYourDirective20Pa =>
      ' con su directiva (20 Pa.C.S. §§ 5804, 5842). Sin embargo, un proveedor puede negarse a seguir instrucciones específicas que vayan en contra de la práctica médica aceptada, o cuando el proveedor no esté físicamente disponible.';

  @override
  String get legalSheetUnderPaAct194An =>
      'Según la Ley 194 de PA, una DASM es válida durante ';

  @override
  String get legalSheetFromTheDateOfExecution =>
      ' a partir de la fecha de firma, salvo que se revoque antes, ';

  @override
  String get legalSheetOfMakingMentalHealthDecisions =>
      ' de tomar decisiones de salud mental en el momento en que vencería, en cuyo caso sigue vigente hasta que recupere la capacidad. Esta aplicación le avisará cuando su directiva se acerque a su vencimiento.';

  @override
  String get legalSheetYouMayRevokeThisDirective =>
      'Puede revocar esta directiva en cualquier momento mientras tenga capacidad legal:';

  @override
  String get legalSheetNotifyingYourHealthcareProviderOr =>
      'Notificando por escrito a su proveedor de atención médica o a su agente';

  @override
  String get legalSheetDestroyingTheDirective => 'Destruyendo la directiva';

  @override
  String get legalSheetExecutingANewDirective => 'Firmando una nueva directiva';

  @override
  String get legalSheetNotifyEveryoneWhoHasCopies =>
      'Avise de la revocación a todas las personas que tengan copias.';

  @override
  String get legalSheetThisIsAWebApp =>
      'Esta es una aplicación web: su directiva se mantiene solo en la memoria de su navegador y ';

  @override
  String get legalSheetIfYouCloseTheTab =>
      '; si cierra la pestaña o esta falla, su trabajo se conserva en este dispositivo durante unos 10 minutos para poder recuperarlo y luego se borra; nunca se envía a un servidor. Exporte o imprima para conservar una copia. Esta aplicación ';

  @override
  String get legalSheetHipaaCompliant => ' cumple con HIPAA.';

  @override
  String get legalSheetIfYouUseTheOptional =>
      'Si usa el Asistente de IA opcional, el texto que envíe se transmite al proveedor de IA que elija (Google Gemini de forma predeterminada; o Anthropic, OpenAI o xAI). En el nivel gratuito de Gemini, Google puede usar estos datos para mejorar sus productos y revisores humanos pueden leer lo que se envía; los demás proveedores tratan sus datos según sus propias políticas de API.';

  @override
  String get legalSheetToProtectYouTheApp => 'Para protegerle, la aplicación ';

  @override
  String get legalSheetYourNameDateOfBirth =>
      ': nunca se incluyen su nombre, fecha de nacimiento, dirección ni los nombres y datos de contacto de sus agentes y tutor. Solo se comparte contexto que no le identifica (como afecciones, medicamentos y preferencias de atención), y solo si decide usar el asistente. (Subir un documento para autocompletar es la única excepción, descrita a continuación.)';

  @override
  String get legalSheetDocumentsYouUploadForAutofill =>
      'Los documentos que sube para autocompletar son distintos: el archivo completo se envía tal cual al proveedor de IA que haya elegido, y para completar su directiva la IA lee los datos personales que contiene (su nombre, fecha de nacimiento, dirección y los datos de su agente o tutor). Usted revisa todo antes de que se guarde. ';

  @override
  String get legalSheetBlackOutAnythingYouDon =>
      ': tache lo que no quiera enviar, o simplemente escriba cualquier campo a mano para mantenerlo privado. Evite también escribir identificadores personales (nombre completo, número de Seguro Social, fecha de nacimiento, dirección) directamente en los mensajes del chat.';

  @override
  String get legalSheetSeparatelyToHelpYouFill =>
      'Por otra parte, para ayudarle a completar y entender su directiva, la aplicación consulta medicamentos, afecciones y (opcionalmente) a su médico en bases de datos públicas y gratuitas del gobierno de EE. UU.: NIH/NLM Clinical Tables, MedlinePlus y openFDA de la FDA. ';

  @override
  String get legalSheetNeverYourIdentityThePeople =>
      ', nunca su identidad, las personas que nombra ni su directiva guardada. Es información de referencia, no asesoramiento médico.';

  @override
  String get legalSheetAiSuggestionsAreNotLegal =>
      'Las sugerencias de la IA no son asesoramiento legal ni médico; revíselas con atención antes de aceptarlas.';

  @override
  String get disclaimerAFewThingsToUnderstand =>
      'Algunas cosas que debe saber.';

  @override
  String get disclaimerThisToolHelpsYouWrite =>
      'Esta herramienta le ayuda a redactar una Directiva Anticipada de Salud Mental de Pensilvania conforme a la Ley 194. Lea lo siguiente antes de continuar.';

  @override
  String get disclaimerReadFullDisclaimer => 'Leer el aviso completo';

  @override
  String get disclaimerGetStarted => 'Comenzar';

  @override
  String get disclaimerIM18OrOlder =>
      'Tengo 18 años o más, lo entiendo y quiero continuar.';

  @override
  String get disclaimerBeforeYouBegin => 'Antes de empezar';

  @override
  String get disclaimerThisIsNotLegalAdvice => 'Esto no es asesoramiento legal';

  @override
  String get disclaimerWeGivePlainLanguageHelp =>
      'Ofrecemos ayuda en lenguaje sencillo, no asesoría legal. Para situaciones complejas, hable con un abogado o un defensor.';

  @override
  String get disclaimerItBecomesValidOnlyWhen =>
      'Solo es válida cuando se firma en papel';

  @override
  String get disclaimerPaLawRequiresYourSignature =>
      'La ley de PA exige su firma y la de dos testigos adultos, con tinta y en persona. La aplicación no puede firmar por usted.';

  @override
  String get disclaimerNothingIsSavedOrSent =>
      'No se guarda ni se nos envía nada';

  @override
  String get disclaimerYouCanStopOrChange =>
      'Puede detenerse o cambiar cualquier cosa en cualquier momento';

  @override
  String get disclaimerSkipQuestionsGoBackOr =>
      'Omita preguntas, vuelva atrás o revoque más adelante. Es su voz: usted mantiene el control.';

  @override
  String get onboardingWeLlWalkYouThrough =>
      'Le guiaremos paso a paso y en lenguaje sencillo: cómo quiere que le traten durante una crisis de salud mental, para que se respeten sus deseos incluso cuando no pueda hablar por sí mismo.';

  @override
  String get onboardingValidTwoYearsFromSigning =>
      'Válida por dos años desde la firma, a menos que usted esté incapacitado cuando vencería; en ese caso sigue vigente hasta que recupere la capacidad. (Ley 194 de PA, vigente desde 2005.)';

  @override
  String get onboardingUploadADocumentToAutofill =>
      'Subir un documento para autocompletar';

  @override
  String get onboardingContinueFromASavedFile =>
      'Continuar desde un archivo guardado';

  @override
  String get onboardingFreeNoAccountNoTracking =>
      'Gratis · sin cuenta · sin rastreo · código abierto';

  @override
  String get onboardingPaMhadAct194 => 'DASM de PA · Ley 194';

  @override
  String get onboardingInYour => 'Con sus\n';

  @override
  String get onboardingWords => 'propias palabras.';

  @override
  String get onboardingMakingThisChangesNothingToday =>
      'Hacer esto no cambia nada hoy. ';

  @override
  String get onboardingYouKeepEveryDecision =>
      'Usted conserva todas sus decisiones';

  @override
  String get onboardingUntilTwoProfessionalsFindYou =>
      ' hasta que dos profesionales determinen que usted no puede decidir por sí mismo.';

  @override
  String get aiConsistencyTheAiIsReviewingYour =>
      'La IA está revisando su directiva…';

  @override
  String get aiConsistencyAiReviewSkippedYouCan =>
      'Se omitió la revisión de la IA; puede volver a ejecutarla en cualquier momento.';

  @override
  String get aiConsistencyRunAiReview => 'Ejecutar revisión de la IA';

  @override
  String get aiConsistencyIgnoreContinue => 'Ignorar y continuar';

  @override
  String get aiConsistencyResolveInWizard => 'Resolver en el asistente';

  @override
  String get aiConsistencyLooksGoodContinue => 'Todo bien: continuar';

  @override
  String get aiConsistencyKeepBoth => 'Conservar ambos';

  @override
  String get aiConsistencyAiReview => 'Revisión de la IA';

  @override
  String get aiConsistencyConsistencyCheckCheckedAtReview =>
      'Verificación de coherencia · revisada en Revisión';

  @override
  String get aiConsistencyCheckingYourDirective => 'Revisando su directiva';

  @override
  String get aiConsistencyYouSaidYourAgentDecides =>
      'Usted indicó que su agente decide sobre sus medicamentos, pero el formulario dice que su agente NO está autorizado para dar consentimiento a medicamentos.';

  @override
  String get aiConsistencyTheseCancelEachOtherOut =>
      'Estas opciones se anulan entre sí. El formulario oficial le permite establecer por separado sus propias preferencias de medicamentos y la autoridad de su agente (ambas son válidas), pero tal como están ingresadas se contradicen. Autorice a su agente a dar consentimiento a medicamentos, o cambie la opción de medicamentos para que coincidan.';

  @override
  String get aiConsistencyYouDonTConsentTo =>
      'Usted no da su consentimiento a ningún medicamento, pero su agente está autorizado para dar consentimiento a ellos.';

  @override
  String get aiConsistencyTheOfficialFormLetsYou =>
      'El formulario oficial le permite establecer por separado su propia preferencia y la autoridad de su agente (ambas son válidas), pero tal como están ingresadas se contradicen: su rechazo a todos los medicamentos frente a la facultad de su agente de dar consentimiento a cualquiera. Decida cuál debe prevalecer y ajuste la otra.';

  @override
  String get aiConsistencyINoticed => 'Noté ';

  @override
  String get draftRecoveryDialogRecoverUnsavedWork =>
      '¿Recuperar el trabajo sin guardar?';

  @override
  String get draftRecoveryDialogDiscard => 'Descartar';

  @override
  String get draftRecoveryDialogRestore => 'Restaurar';

  @override
  String get draftRecoveryDialogDraftRestoredPersonalInformationWill =>
      'Borrador restaurado. Tendrá que volver a ingresar la información personal.';

  @override
  String get draftRecoveryDialogCouldnTRestoreTheDraft =>
      'No se pudo restaurar el borrador.';

  @override
  String get moreSheetResetAndStartFresh => '¿Restablecer y empezar de nuevo?';

  @override
  String get moreSheetThisPermanentlyErasesEverythingIn =>
      'Esto borra de forma permanente todo lo de esta sesión (todas las directivas, su clave de IA y el historial del chat) y le devuelve a un inicio en blanco.\n\nExporte o imprima primero lo que quiera conservar. No se puede deshacer.';

  @override
  String get moreSheetResetEverything => 'Restablecer todo';

  @override
  String get moreSheetEverythingElseYouCanDo =>
      'Todo lo demás que puede hacer aquí.';

  @override
  String get moreSheetGetHelp => 'Obtener ayuda';

  @override
  String get moreSheetReset => 'Restablecer';

  @override
  String get crisisSheet247FreeConfidential => '24/7 GRATIS Y CONFIDENCIAL';

  @override
  String get crisisSheetRealPeopleAreStandingBy =>
      'Hay personas reales listas para ayudarle: por teléfono, mensaje de texto o chat.';

  @override
  String get crisisSheetCalling988ConnectsYouTo =>
      'Llamar al 988 le conecta con un consejero capacitado de su zona. Es gratis, confidencial y está disponible las 24 horas del día. En la mayoría de los casos, llamar no hace que se envíe a la policía.';

  @override
  String get crisisSheetWhyTheseNumbers => '¿Por qué estos números?';

  @override
  String get crisisSheetIfYouOrSomeoneElse =>
      'Si usted u otra persona está en peligro inmediato, llame al ';

  @override
  String get walletCardMh => 'SM';

  @override
  String get walletCardPaMhadAct194 => 'DASM DE PA · LEY 194';

  @override
  String get walletCardHasAnActiveDirectiveOn =>
      'Tiene una directiva vigente registrada';

  @override
  String get walletCardAgent => 'AGENTE';

  @override
  String get walletCardExp => 'VENCE';

  @override
  String get webSidebarAct1942004 => 'LEY 194 · 2004';

  @override
  String get webSidebar247Lifeline => 'LÍNEA 24/7';

  @override
  String get webSidebar988CrisisHelp => '988 · Ayuda en crisis';

  @override
  String get webSidebarClickForMoreInformation =>
      'Haga clic para más información';

  @override
  String get webSidebarPeerSupportAdvocatesReferrals =>
      'Apoyo entre pares · defensores · derivaciones';

  @override
  String get medlinePlusDialogNoPlainLanguageSummaryIs =>
      'En este momento no hay un resumen en lenguaje sencillo disponible. Puede buscarlo en MedlinePlus.';

  @override
  String get medlinePlusDialogPlainLanguageInformationFromThe =>
      'Información en lenguaje sencillo de la Biblioteca Nacional de Medicina de EE. UU. (MedlinePlus). Solo con fines educativos; no es asesoramiento médico.';

  @override
  String get medlinePlusDialogReadMoreOnMedlineplus =>
      'Leer más en MedlinePlus';

  @override
  String get fdaLabelDialogNoFdaLabelInformationIs =>
      'En este momento no hay información de la etiqueta de la FDA para este medicamento. Los nombres de marca y genéricos pueden escribirse de forma distinta: pruebe con el otro o pregunte a su farmacéutico.';

  @override
  String get fdaLabelDialogOfficialUSFdaDrug =>
      'Texto oficial de la etiqueta del medicamento de la FDA de EE. UU. (openFDA). Solo como referencia; no es asesoramiento médico ni está personalizado para usted. Hable de cualquier cosa de aquí con su médico o farmacéutico.';

  @override
  String get aiConsentDialogBeforeYouUpload => 'Antes de subir';

  @override
  String get aiConsentDialogNothingIsSavedToYour =>
      'Nada se guarda en su directiva automáticamente: usted revisa cada campo que completa la IA antes de aplicarlo.';

  @override
  String get aiConsentDialogUploadingIsOnlyAShortcut =>
      'Subir un documento es solo un atajo, nunca es obligatorio:\n• Tache lo que no quiera enviar (números de identificación o de tarjetas, datos de otras personas) antes de subirlo.\n• O no suba nada y escriba cualquier campo a mano: los campos escritos se quedan en su dispositivo y nunca se envían a la IA.';

  @override
  String get aiConsentDialogSendToTheAi => 'Enviar a la IA';

  @override
  String get aiConsentDialogTranscribeWithAi => 'Transcribir con IA';

  @override
  String get aiConsentDialogYouReviewTheTextBefore =>
      'Usted revisa el texto antes de que pase a su formulario. ¿Prefiere no hacerlo? Toque Cancelar para usar el dictado integrado de su dispositivo, o simplemente escriba; ninguna de las dos opciones envía audio a la IA.';

  @override
  String get aiConsentDialogUseAi => 'Usar IA';

  @override
  String get aiConsentDialogAiDataNotice => 'Aviso sobre datos e IA';

  @override
  String get aiConsentDialogImportantPleaseReadBeforeContinuing =>
      'Importante: lea esto antes de continuar.\n';

  @override
  String get aiConsentDialogThisAiAssistantIsNot =>
      '• Este asistente de IA NO es un terapeuta, médico ni abogado. Solo ofrece información general sobre las Directivas Anticipadas de Salud Mental de PA.\n';

  @override
  String get aiConsentDialogNeverEnterPersonalInformationFull =>
      'NUNCA ingrese información personal (nombre completo, fecha de nacimiento, número de Seguro Social, dirección, teléfono, correo electrónico) en el chat de IA ni en las funciones con IA.\n\nLa aplicación elimina automáticamente los datos personales comunes, pero esto no está garantizado. Los campos de información personal deben completarse a mano: se guardan solo en su dispositivo y nunca se envían a la IA.';

  @override
  String get aiConsentDialogNotNow => 'Ahora no';

  @override
  String get aiConsentDialogIAuthorize => 'Autorizo';

  @override
  String get addressFieldsTapTheIconToFill =>
      'Toque el ícono para completar ciudad y estado';

  @override
  String get addressFieldsFillCityStateFromZip =>
      'Completar ciudad y estado a partir del código postal';

  @override
  String get mainTheAppCouldnTStart => 'La aplicación no pudo iniciarse';

  @override
  String get mainPaMentalHealthAdvanceDirective =>
      'Directiva Anticipada de Salud Mental de PA';

  @override
  String get mainAppTitle => 'Directiva Anticipada de Salud Mental de PA';

  @override
  String get aiConsistencyStepsProcedures =>
      'Procedimientos + autoridad del agente';

  @override
  String get aiConsistencyStepsMeds => 'Medicamentos + autoridad del agente';

  @override
  String aiConsistencyProcTitle(String name) {
    return 'Usted dio su propio consentimiento para $name; el formulario impreso también indicará que su agente NO está autorizado para dar consentimiento para $name.';
  }

  @override
  String aiConsistencyProcBody(String name) {
    return 'El formulario de Pensilvania le permite hacer ambas cosas: dar su propio consentimiento Y autorizar a su agente a dar consentimiento en su nombre (esa autorización al agente requiere sus iniciales a mano, §5836(c)). Tal como está ingresado, solo se registra su propio consentimiento, por lo que el documento indica que su agente no puede dar consentimiento para $name. Eso está permitido y puede ser exactamente lo que desea; si es así, conserve ambos. Si también quiere que su agente pueda dar consentimiento (por ejemplo, si más adelante usted no puede decidir), elija “Mi agente decidirá” para $name.';
  }

  @override
  String aiConsistencyProcA(String name) {
    return 'Usted da su consentimiento para $name';
  }

  @override
  String aiConsistencyProcB(String name) {
    return 'Agente no autorizado: $name';
  }

  @override
  String aiConsistencyProcAction(String name) {
    return 'Revisar la opción de $name';
  }

  @override
  String get aiConsistencyProcEct => 'TEC';

  @override
  String get aiConsistencyProcExperimental => 'estudios experimentales';

  @override
  String get aiConsistencyProcDrugTrials => 'ensayos de medicamentos';

  @override
  String get aiConsistencyAgentDecidesMeds =>
      'El agente decide los medicamentos';

  @override
  String get aiConsistencyAgentNotAuthorizedMeds =>
      'Agente no autorizado: medicamentos';

  @override
  String get aiConsistencyEditMedications => 'Editar medicamentos';

  @override
  String get aiConsistencyEditAgentAuthority =>
      'Editar la autoridad del agente';

  @override
  String get aiConsistencyNoMedsYou => 'Ningún medicamento (usted)';

  @override
  String get aiConsistencyAgentMayConsentMeds =>
      'El agente puede dar consentimiento: medicamentos';

  @override
  String get aiConsistencySetupAiInvite =>
      'Configure el asistente de IA gratuito para obtener una revisión adicional con IA que sugiere vacíos y cosas por verificar. Es opcional: la verificación basada en reglas de arriba siempre se ejecuta sin ella.';

  @override
  String get aiConsistencyNoSuggestions =>
      'La IA no devolvió ninguna sugerencia.';

  @override
  String aiConsistencyNotAdviceOptional(String notAdvice) {
    return '$notAdvice Sugerencias opcionales basadas solo en lo que usted ingresó.';
  }

  @override
  String aiConsistencyCheckFailed(String error) {
    return 'No se pudo ejecutar la verificación de coherencia.\n$error';
  }

  @override
  String aiConsistencyThingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cosas',
      one: '1 cosa',
    );
    return '$_temp0';
  }

  @override
  String get aiConsistencyAllConsistent => 'Todo parece coherente.';

  @override
  String get aiConsistencyWarningsOnly =>
      'Esto no le impedirá generar el PDF: son advertencias que puede corregir o ignorar.';

  @override
  String get aiConsistencyNoContradictions =>
      'No se detectaron contradicciones entre pasos.';

  @override
  String get aiConsistencyRulesExplainer =>
      'La verificación de contradicciones de arriba usa reglas integradas. Cuando el asistente de IA está configurado, una revisión adicional con IA agrega sugerencias opcionales. Revise todo antes de aceptar; esta pantalla advierte, pero no bloquea la generación del PDF.';

  @override
  String aiConsistencyConflictHeader(int number, String steps) {
    return 'CONFLICTO · $number · $steps';
  }

  @override
  String get aiConsistencyVs => 'frente a';

  @override
  String get crisisPlanHowIKnowIM => 'Cómo sé que no estoy bien';

  @override
  String get crisisPlanHeadsUpThisSectionIs =>
      'Aviso: esta sección es solo suya; la Ley 194 de PA no la exige, pero en la práctica es lo primero que leen los agentes y el personal de urgencias.';

  @override
  String get permissionsOverviewOnlyWhatWeNeed => 'Solo lo que necesitamos.';

  @override
  String get permissionsOverviewPermissionsAreManagedByYour =>
      'Los permisos los administra su dispositivo, no esta aplicación. Abra Configuración de su dispositivo → PA MHAD para conceder, revocar o revisar cualquiera de los anteriores en cualquier momento.';

  @override
  String get permissionsOverviewNoAnalyticsNoTrackingPixels =>
      'Sin analíticas. Sin píxeles de rastreo. Sin cookies. Sin SDK de terceros para publicidad o medición. Los únicos datos que salen son los de las funciones de IA opcionales (el proveedor de IA que usted elija) y las consultas de referencia médica de la NLM, ambos con eliminación de datos personales en un único punto de control.';

  @override
  String get makeItFindableMakeItFindableInA =>
      'Haga que la encuentren en una crisis.';

  @override
  String get makeItFindablePennsylvaniaHasNoStatewideDirective =>
      'Pensilvania no tiene un registro estatal de directivas, así que las personas de su vida son el registro: asegúrese de que su agente, una persona de confianza y sus proveedores sepan que tiene una directiva y dónde encontrarla.';

  @override
  String get makeItFindableUnderPaAct194A =>
      'Según la Ley 194 de PA, una directiva válida que su equipo de atención pueda encontrar debe seguirse. Que se pueda encontrar es lo que hace que funcione.';

  @override
  String get revocationAreYouSure => '¿Está seguro?';

  @override
  String get revocationPutItInWritingSign =>
      'Póngalo por escrito: firme y feche una breve declaración de que revoca esta directiva.';

  @override
  String get revocationTellYourAgentYourProviders =>
      'Avise a su agente, a sus proveedores y a cualquier persona que tenga una copia.';

  @override
  String get revocationDestroyOldCopiesOrClearly =>
      'Destruya las copias antiguas o márquelas claramente como “REVOCADA”.';

  @override
  String get revocationIfYouHaveAnyFurther =>
      'Si tiene más preguntas sobre cómo se le aplica la revocación, es prudente consultar a un abogado.';

  @override
  String get pastDirectiveDetailNoShareHistoryIsKept =>
      'No se guarda historial de envíos: nada se conserva al cerrar la aplicación, así que esta lista está vacía a propósito.';

  @override
  String get wizardAiRailFullView => 'Vista completa';

  @override
  String get wizardAiRailYourApiKeyStaysOn =>
      'Su clave de API se queda en este dispositivo y solo se usa para responder sus preguntas. Puede completar todo el asistente sin ella.';

  @override
  String get wizardAiRailReadingThisStep => 'Leyendo este paso…';

  @override
  String get wizardAiRailSuggestedForThisStep => 'SUGERIDO PARA ESTE PASO';

  @override
  String get wizardAiRailAskAnythingAboutThisStep =>
      'Pregunte lo que quiera sobre este paso; las respuestas aparecen aquí y en el asistente completo.';

  @override
  String get wizardAiRailNeedHelpWithThisStep =>
      '¿Necesita ayuda con este paso? Pregunte a la IA';

  @override
  String get wizardAiRailAiHelpIsOffThe =>
      'La ayuda de IA está desactivada. El aviso del paso, las preguntas sugeridas, el autocompletado con fotos y el chat de abajo no estarán disponibles hasta que configure la IA.';

  @override
  String get wizardAiRailCheckingThisStep => 'Revisando este paso';

  @override
  String get wizardAiRailFindAPaFacilityBy =>
      'Busque un centro de PA por nombre o condado…';

  @override
  String get wizardAiRailThinking => 'Pensando…';

  @override
  String get wizardAiRailAskAboutThisStep => 'Pregunte sobre este paso…';

  @override
  String get wizardAiRailSending => 'Enviando';

  @override
  String get sideEffectsBringAnythingYouCheckAnd =>
      'Lleve todo lo que marque, y especialmente lo marcado como \"hablar con su médico\", a su médico o farmacéutico. Esta lista nunca le indica que empiece, suspenda o cambie un medicamento.';

  @override
  String get sideEffectsTheseArePossibleInteractionsDrawn =>
      'Estas son posibles interacciones tomadas de las etiquetas de la FDA de los medicamentos, redactadas como preguntas para hacer. No son un aviso para que usted suspenda o cambie nada por su cuenta; solo su médico o farmacéutico puede aconsejarle sobre su caso.';

  @override
  String get sideEffectsAddTheMedicationsYouRe =>
      'Primero agregue los medicamentos que toma actualmente en el paso Medicamentos y luego vuelva aquí para revisar sus efectos secundarios comunes.';

  @override
  String get audioGuideToTranscribeYourRecordingIncluding =>
      'Para transcribirla, su grabación (incluidos los datos personales que diga) se envía a la IA de Google. En el nivel gratuito puede conservarse y revisarse, y no se puede recuperar. No diga nada que no quiera enviar; siempre puede escribir a mano los campos sensibles.';

  @override
  String get ulyssesClauseIfFutureMeRefuses => 'Si mi yo futuro se niega…';

  @override
  String get ulyssesClauseStronglyRecommendedTalkWithA =>
      'Muy recomendable: hable con un especialista de apoyo entre pares o un profesional clínico antes de guardar. Vea \"Obtener ayuda\" en Configuración.';

  @override
  String get aiSetupIsTheApiKeyReally =>
      '¿La clave de API es realmente gratis?';

  @override
  String get aiSetupYesGoogleOffersAGenerous =>
      'Sí. El nivel gratuito de Gemini de Google no requiere tarjeta de crédito. Tiene límites diarios: el modelo predeterminado de la aplicación (Gemini Flash-Lite) permite unos cientos de solicitudes al día, suficiente para un uso normal; los modelos Flash más potentes permiten muchas menos (unas 20 al día).';

  @override
  String get aiSetupWhatGoogleAccountShouldI =>
      '¿Qué cuenta de Google debo usar?';

  @override
  String get aiSetupAnyGoogleAccountWorksA =>
      'Cualquier cuenta de Google sirve; una cuenta personal de Gmail está bien. No necesita una cuenta de facturación de Google Cloud.';

  @override
  String get aiSetupCanIRevokeTheKey => '¿Puedo revocar la clave más adelante?';

  @override
  String get aiSetupYesVisitAistudioGoogleCom =>
      'Sí. Visite aistudio.google.com/apikey en cualquier momento para eliminar o regenerar su clave. También puede quitarla de esta aplicación con el ícono de papelera en la esquina superior derecha.';

  @override
  String get aiSetupWhatIfIDonT => '¿Y si no agrego una clave?';

  @override
  String get aiSetupTheAppWorksFullyWithout =>
      'La aplicación funciona por completo sin IA. El asistente del formulario, la generación del PDF, el contenido educativo y todas las demás funciones no requieren una clave de API. La IA es totalmente opcional.';

  @override
  String get accessibilitySettingsMakeItReadable => 'Hágalo legible.';

  @override
  String get accessibilitySettingsLegalTextIsAlwaysRendered =>
      'El texto legal siempre se muestra en inglés para conservar la redacción de la Ley 194 de PA.';

  @override
  String get facilitatorYouDonTHaveTo => 'No tiene que hacerlo solo.';

  @override
  String get facilitatorPeerSpecialistAdvocateReferral =>
      '♥ Derivación a especialista de apoyo entre pares / defensor';

  @override
  String get facilitatorSomeoneIAlreadyTrust => '👥 Alguien en quien ya confío';

  @override
  String get facilitatorMyCareTeam => '🧠 Mi equipo de atención';

  @override
  String get facilitatorPreferToDoItYourself =>
      '¿Prefiere hacerlo por su cuenta? Está bien: siga desde donde lo dejó.';

  @override
  String get moreSheetCallOrText98824 =>
      'Llame o envíe un mensaje al 988 · apoyo 24/7';

  @override
  String get moreSheetUploadADocumentPhotoOr =>
      'Subir un documento, una foto o una grabación';

  @override
  String get moreSheetPreviewAndExportYourDirective =>
      'Ver y exportar el paquete de su directiva';

  @override
  String get moreSheetEraseThisSessionAndStart =>
      'Borrar esta sesión y empezar de nuevo';

  @override
  String get crisisSheetYouAreNotAlone => 'No está solo.';

  @override
  String get crisisSheetCallOrText988 => 'Llame o envíe un mensaje al 988';

  @override
  String get crisisSheetCall988Press1 => 'Llame al 988 y marque 1';

  @override
  String get crisisSheetCallTextChat => 'Llamada · texto · chat';

  @override
  String get assistantSenderYou => 'Usted';

  @override
  String get assistantSenderAi => 'Asistente de IA';

  @override
  String get aiSetupApiKeySetForThis =>
      'Clave de API configurada para esta sesión';

  @override
  String get aiSetupApiKeySaved => 'Clave de API guardada';

  @override
  String get aiSetupGetYourFreeGeminiApi =>
      'Obtenga su clave de API gratuita de Gemini';

  @override
  String aiSetupAddYourApiKey(Object label) {
    return 'Agregue su clave de API de $label';
  }

  @override
  String get aiSetupTheAssistantUsesGoogleS =>
      'El asistente usa el modelo Gemini de Google. Necesita una clave de API gratuita de Google AI Studio; toma unos 30 segundos.';

  @override
  String aiSetupYouBringYourOwnApi(Object label) {
    return 'Usted usa su propia clave de API de $label. Se aplican los límites de uso y la facturación de su proveedor; esta aplicación nunca ve ni cobra su uso. Gemini sigue siendo la opción gratuita predeterminada si prefiere no pagar.';
  }

  @override
  String get aiSetupOpenGoogleAiStudioIn =>
      'Abrir Google AI Studio (en su ventana privada)';

  @override
  String aiSetupOpenInYourPrivateWindow(Object label) {
    return 'Abrir $label (en su ventana privada)';
  }

  @override
  String get aiSetupUseAnyGoogleAccountPersonal =>
      'Use cualquier cuenta de Google (una cuenta personal de Gmail sirve)';

  @override
  String get aiSetupSignInThenOpenThe =>
      'Inicie sesión y luego abra la página de claves de API';

  @override
  String get aiSetupOpenAiStudio => 'Abrir AI Studio';

  @override
  String aiSetupOpen(Object label) {
    return 'Abrir $label';
  }

  @override
  String get aiSetupSignInWithGoogle => 'Iniciar sesión con Google';

  @override
  String aiSetupSignInTo(Object label) {
    return 'Iniciar sesión en $label';
  }

  @override
  String get aiSetupNoCreditCardOrPayment =>
      'No se necesita tarjeta de crédito ni pago. El nivel gratuito tiene límites diarios; el modelo predeterminado de la aplicación (Flash-Lite) se eligió para que alcance en un uso normal.';

  @override
  String get aiSetupMostProvidersRequireAPaid =>
      'La mayoría de los proveedores exigen una cuenta de pago con créditos para usar la API. Su proveedor le factura directamente.';

  @override
  String get aiSetupKeySetForThisSession =>
      'Clave configurada para esta sesión';

  @override
  String get aiSetupKeySaved => 'Clave guardada';

  @override
  String get aiSetupShowApiKey => 'Mostrar clave de API';

  @override
  String get aiSetupHideApiKey => 'Ocultar clave de API';

  @override
  String get aiSetupUseKeyForThisSession => 'Usar la clave en esta sesión';

  @override
  String get aiSetupSaveApiKey => 'Guardar clave de API';

  @override
  String get aiSetupTesting => 'Probando…';

  @override
  String get aiSetupTestConnection => 'Probar conexión';

  @override
  String aiSetupThatDoesnTLookLike(Object label, Object keyHint) {
    return 'No parece una clave válida de $label ($keyHint).';
  }

  @override
  String aiSetupCouldNotPasteTryPasting(Object pasteShortcutLabel) {
    return 'No se pudo pegar. Intente pegarla manualmente ($pasteShortcutLabel).';
  }

  @override
  String aiSetupMayBeBlockedByYour(Object label) {
    return 'Es posible que la seguridad de su navegador (CORS) bloquee $label en la web. Si no responde, elija Gemini o Claude; ambos funcionan en el navegador.';
  }

  @override
  String aiSetupTheKeyLooksLikeCopy(Object keyHint) {
    return 'La clave se parece a \"$keyHint\": cópiela y luego use el botón de pegar o péguela manualmente.';
  }

  @override
  String aiSetupApiKey(Object label) {
    return 'Clave de API de $label';
  }

  @override
  String get adminUpdateBlankUseTheAppS =>
      'En blanco = usar la clave guardada en la aplicación para este proveedor. No se almacena.';

  @override
  String get adminUpdateDrafting => 'Redactando…';

  @override
  String get adminUpdateStartUpdateWithAi => 'Iniciar actualización con IA';

  @override
  String adminUpdateRestoreFromBackupFieldS(
    Object changesLength,
    Object assetPath,
  ) {
    return 'Restaurar desde copia de seguridad: $changesLength campo(s) difieren de la versión anterior de $assetPath. Marque la(s) parte(s) que desea revertir (todo marcado = reversión completa).';
  }

  @override
  String adminUpdateProposedChangeSReviewEach(Object changesLength) {
    return '$changesLength cambio(s) propuesto(s). Revise cada uno; marque los elementos VERIFICAR solo si los ha confirmado.';
  }

  @override
  String adminUpdateVerifyTierChangeSNot(Object verifyCount) {
    return '$verifyCount cambio(s) de nivel verificar aún sin aprobar';
  }

  @override
  String get adminUpdateReady => 'Listo';

  @override
  String get adminUpdateBuildRestoredJson => 'Generar JSON restaurado';

  @override
  String get adminUpdateBuildUpdatedJson => 'Generar JSON actualizado';

  @override
  String adminUpdateContextInOut(
    Object displayName,
    Object note,
    Object inputTokenLimit,
    Object outputTokenLimit,
  ) {
    return '$displayName\n$note\ncontexto $inputTokenLimit entrada / $outputTokenLimit salida';
  }

  @override
  String adminUpdateBestGeminiModelNow(Object currentModel) {
    return 'Mejor modelo de Gemini (actual: $currentModel)';
  }

  @override
  String adminUpdateCheckTheNewestModelsLive(Object label) {
    return 'Consultar los modelos más recientes de $label (API en vivo)';
  }

  @override
  String adminUpdateApiKey(Object label) {
    return 'Clave de API de $label';
  }

  @override
  String adminUpdateSource(Object source) {
    return 'Fuente: $source';
  }

  @override
  String adminUpdateRestoredTheSelectedFieldS(Object assetPath) {
    return 'RESTAURADO: los campos seleccionados se revirtieron a la copia de seguridad. Confirme esto sobre $assetPath para aplicar la reversión.';
  }

  @override
  String adminUpdateUpdatedReplaceThatFileWith(Object assetPath) {
    return '$assetPath actualizado. Reemplace ese archivo con este y confírmelo; la versión lo publica para todos.';
  }

  @override
  String get reminderSheetsTimeToRenew => 'Es hora de renovar.';

  @override
  String reminderSheetsTimeToRenew2(Object firstName) {
    return 'Es hora de renovar, $firstName.';
  }

  @override
  String reminderSheetsExpires(Object dayLabel) {
    return '● Vence $dayLabel';
  }

  @override
  String get revocationWillBeReferencedInYour =>
      'Se mencionará en su carta de revocación';

  @override
  String get revocationTapToInclude => 'Toque para incluir';

  @override
  String get revocationRevoking => 'Revocando…';

  @override
  String get revocationRevokeNow => 'Revocar ahora';

  @override
  String pastDirectiveDetailUnableToLoad(Object error) {
    return 'No se pudo cargar: $error';
  }

  @override
  String pastDirectiveDetailTheDirectiveRemainsRegardless(Object status) {
    return 'La directiva sigue $status de todos modos';
  }

  @override
  String get pinDialogShowPasscode => 'Mostrar código';

  @override
  String get pinDialogHidePasscode => 'Ocultar código';

  @override
  String get modeSelectionOnTheWebYourData =>
      'En la web, sus datos se mantienen solo en la memoria y nunca se envían a un servidor, por lo que el almacenamiento cifrado en el dispositivo (modo Privado) no está disponible aquí.';

  @override
  String get modeSelectionThisAppIsNotHipaa =>
      'Esta aplicación no cumple con HIPAA. No se envía nada a un servidor para almacenarlo.';

  @override
  String modeSelectionSelect(Object title, Object recommended) {
    return 'Seleccionar $title$recommended';
  }

  @override
  String sideEffectsCheckingCovers(Object currentMedsJoin) {
    return 'La revisión incluye: $currentMedsJoin';
  }

  @override
  String sideEffectsReCheckFor(Object currentMedsJoin) {
    return 'Volver a revisar: $currentMedsJoin';
  }

  @override
  String get sideEffectsCheckSideEffects => 'Revisar efectos secundarios';

  @override
  String get sideEffectsReCheck => 'Volver a revisar';

  @override
  String sideEffectsMayAffect(Object adlImpact) {
    return 'Puede afectar: $adlImpact';
  }

  @override
  String educationCategoryBrowserSections(
    Object title,
    Object count,
    Object sub,
  ) {
    return '$title, $count secciones. $sub';
  }

  @override
  String get learnAiPanelAskAQuestionToGet =>
      'Haga una pregunta para empezar; por ejemplo: \"¿Cuál es la diferencia entre una declaración y un poder notarial?\"';

  @override
  String get learnAiPanelSetUpTheFreeAi =>
      'Configure el asistente de IA gratuito para hacer preguntas mientras lee.';

  @override
  String learnAiPanelPiiStripped(Object nameToUpperCase) {
    return '● $nameToUpperCase · SIN DATOS PERSONALES';
  }

  @override
  String educationArticleDetailQuestionsContactPaProtectionAdvocacy(
    Object paProtectionAdvocacy,
  ) {
    return '¿Preguntas? Comuníquese con PA Protection & Advocacy: $paProtectionAdvocacy';
  }

  @override
  String audioGuideExample(Object example) {
    return 'Ejemplo: $example';
  }

  @override
  String exportCardsExecuted(Object executionDate) {
    return 'Firmada: $executionDate';
  }

  @override
  String exportCardsExpires(Object expirationDate) {
    return 'Vence: $expirationDate';
  }

  @override
  String get pdfPreviewFit => 'AJUSTAR';

  @override
  String pdfPreviewPageOf(Object current, Object pageCount) {
    return 'Página $current de $pageCount';
  }

  @override
  String pdfPreviewGoToPage(Object i) {
    return 'Ir a la página $i';
  }

  @override
  String pdfPreviewPage(Object i) {
    return 'Página $i';
  }

  @override
  String get exportGeneratingPdfPreview => 'Generando la vista previa del PDF';

  @override
  String get exportPreviewPdfBeforeSharing => 'Ver el PDF antes de compartirlo';

  @override
  String exportTheFollowingFieldsAreEmpty(Object n) {
    return 'Los siguientes campos están vacíos o faltan:\n\n$n\n\nUna directiva incompleta podría no ser legalmente válida según la Ley 194 de PA. ¿Exportar de todos modos?';
  }

  @override
  String privacyPolicyLastUpdated(
    Object privacyPolicyUpdated,
    Object privacyPolicyVersion,
  ) {
    return 'Última actualización: $privacyPolicyUpdated ($privacyPolicyVersion)';
  }

  @override
  String privacyPolicyYouCanReachTheDeveloper(Object privacyPolicyUrl) {
    return 'La Norma de Notificación de Violaciones de Datos de Salud de la FTC exige al menos dos medios de contacto. Ofrecemos:\n\n  - En la aplicación: si una violación de datos le afecta, se mostrará un aviso la próxima vez que abra la aplicación.\n  - En línea: $privacyPolicyUrl (también se usa para publicar avisos de violaciones si la información de contacto directo no es suficiente).';
  }

  @override
  String get settingsScreenshotsAreBlocked =>
      'Las capturas de pantalla están bloqueadas';

  @override
  String get settingsScreenshotsAreAllowed =>
      'Las capturas de pantalla están permitidas';

  @override
  String assistantMessageWidgetsAt(
    Object sender,
    Object timeStr,
    Object content,
  ) {
    return '$sender a las $timeStr: $content';
  }

  @override
  String assistantActiveTextPiiStrippedBefore(Object model) {
    return '● ACTIVO · $model · SE QUITAN LOS DATOS PERSONALES DEL TEXTO ANTES DE ENVIAR';
  }

  @override
  String get assistantNotSetUpAddA =>
      '○ NO CONFIGURADO · AGREGUE UNA CLAVE PARA USAR LA IA';

  @override
  String assistantOlderMessagesWereTrimmedTo(Object trimmedCount) {
    return 'Se recortaron $trimmedCount mensajes antiguos para ajustarse al límite de contexto de la IA. Los mensajes recientes se conservan.';
  }

  @override
  String assistantNotLegalOrMedicalAdvice(Object paProtectionAdvocacy) {
    return 'No es asesoramiento legal ni médico. Para preguntas legales, comuníquese con PA Protection & Advocacy: $paProtectionAdvocacy';
  }

  @override
  String assistantFreeTierRequestsMinRequests(
    Object model,
    Object maxRpm,
    Object maxRpd,
    Object tpmK,
    Object contextK,
  ) {
    return 'Nivel gratuito de $model:\n$maxRpm solicitudes/min\n$maxRpd solicitudes/día\n${tpmK}K tokens/min\n${contextK}K de contexto máximo';
  }

  @override
  String get homeToolsGridSuggestsChecks => 'Sugiere + verifica';

  @override
  String get homeToolsGridShareCarry => 'Compartir + llevar';

  @override
  String get homeToolsGridNoDirectiveYet => 'Aún no hay directiva';

  @override
  String homeDirectiveHeroContinueYourLastEdited(
    Object formLabel,
    Object pctLabel,
    Object lastEdited,
  ) {
    return 'Continúe su $formLabel: $pctLabel, última edición $lastEdited';
  }

  @override
  String homeDirectiveHeroStepOf(Object currentStep, Object totalSteps) {
    return 'Paso $currentStep de $totalSteps';
  }

  @override
  String homeDirectiveHeroLastEdited(Object formLabel, Object lastEdited) {
    return '$formLabel · última edición $lastEdited';
  }

  @override
  String facilitatorPickTheKindOfSupport(Object facilitatorCompletionStat) {
    return '$facilitatorCompletionStat Elija el tipo de apoyo que le convenga hoy.';
  }

  @override
  String get disclaimerYouWorkAnonymouslyInThis =>
      'Trabaja de forma anónima en esta pestaña del navegador: sin cuenta, sin nube, sin rastreo. Si cierra la pestaña, su trabajo se conserva en este dispositivo durante unos 10 minutos para poder recuperarlo y luego se borra; abra y guarde su PDF para conservarlo.';

  @override
  String get disclaimerNoAccountNoCloudNo =>
      'Sin cuenta, sin nube, sin rastreo: nada llega a nuestros servidores. Todo lo que guarde se queda cifrado en este dispositivo, donde solo usted puede abrirlo.';

  @override
  String draftRecoveryDialogItLooksLikeTheApp(Object ageDescription) {
    return 'Parece que la aplicación se cerró de forma inesperada. Se encontró un borrador guardado automáticamente de $ageDescription.\n\nEste borrador contiene sus preferencias de tratamiento y datos médicos (no se guardó información personal).\n\n¿Desea restaurarlo?';
  }

  @override
  String stepDotsStepOf(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String stepDotsGoToStepOf(Object i, Object total) {
    return 'Ir al paso $i de $total';
  }

  @override
  String healthChipLearnAbout(Object label) {
    return 'Más información sobre $label';
  }

  @override
  String healthChipRemove(Object label) {
    return 'Quitar $label';
  }

  @override
  String crisisSheetTextHomeTo(Object crisisTextLine) {
    return 'Envíe HOME al $crisisTextLine';
  }

  @override
  String crisisSheetTreatmentReferrals(Object samhsa) {
    return '$samhsa · derivaciones a tratamiento';
  }

  @override
  String crisisSheetKnowYourRights(Object paProtectionAdvocacy) {
    return '$paProtectionAdvocacy · conozca sus derechos';
  }

  @override
  String fdaLabelDialogFdaLabel(Object medName) {
    return '$medName: etiqueta de la FDA';
  }

  @override
  String nlmAttributionSourceUSNationalLibrary(Object medicalDisclaimer) {
    return 'Fuente: Biblioteca Nacional de Medicina de EE. UU. $medicalDisclaimer';
  }

  @override
  String aiConsentDialogToAutofillYourDirectiveThe(Object label) {
    return 'Para autocompletar su directiva, el documento completo, incluidos los datos personales que contenga (nombres, fechas de nacimiento, direcciones, números de teléfono), se envía a $label para que pueda leerlo y completar sus campos.';
  }

  @override
  String aiConsentDialogForMoreAccurateTranscriptionEspecially(Object label) {
    return 'Para una transcripción más precisa (especialmente de nombres de medicamentos y afecciones), su grabación de voz, incluidos los datos personales que diga, se envía a $label para convertirla en texto.';
  }

  @override
  String aiConsentDialogTextYouEnterWillBe(Object label, Object provider) {
    return '• El texto que ingrese se enviará a $label para procesarlo con IA. $provider\n';
  }

  @override
  String aiConsentDialogByTappingIAuthorizeYou(Object label) {
    return '\nAl tocar \"Autorizo\", usted acepta enviar su texto a $label para procesarlo con IA según estos términos.\n\nEste aviso aparece una vez por sesión.';
  }

  @override
  String get exportDraftModeFinal => 'Copia final';

  @override
  String get exportDraftModeDraft => 'Borrador';

  @override
  String get exportDraftModeSignedExists =>
      'Borrador · existe una copia firmada';

  @override
  String exportOpenedManyPdfs(int count) {
    return 'Se abrieron $count PDF en pestañas nuevas; imprima o guarde cada uno desde su visor de PDF.';
  }

  @override
  String get exportOpenedOnePdf =>
      'Se abrió en una pestaña nueva; use Imprimir o Descargar en su visor de PDF.';

  @override
  String get exportNoAgentDesignated =>
      'No hay agente designado; las secciones del agente quedarán en blanco';

  @override
  String get exportWalletYourName => 'Su nombre';

  @override
  String get exportWalletSignToActivate => 'firme para activar';

  @override
  String get exportEffectiveCondition => 'Condición de entrada en vigor';

  @override
  String get exportWitnessSignatures => 'Firmas de los testigos';

  @override
  String get exportPrintedCopyType => 'Tipo de copia impresa';

  @override
  String get exportADraftPrintsALight =>
      'Un borrador imprime una marca de agua clara de “BORRADOR” en cada página, para enviar una copia mientras usted conserva el original firmado en papel. Marque todos los que quiera; Descargar le da un PDF de cada uno.';

  @override
  String get exportDocumentLanguage => 'Idioma del documento';

  @override
  String get exportThePlainLanguageOfficialForm =>
      'El formulario oficial en lenguaje sencillo es el que usted firma y usa: es la directiva legalmente válida. La versión en lenguaje jurídico lo reformula con la redacción formal de la ley solo como referencia y no es el documento que usted firma.';

  @override
  String get exportThisOpensYourDirectiveIn =>
      'Esto abre su directiva en su visor de PDF (una nueva pestaña del navegador), donde puede imprimirla o guardarla/descargarla; NO se descargará automáticamente.';

  @override
  String get exportWalletCard => 'Tarjeta de bolsillo';

  @override
  String get exportACreditCardSizedSummary =>
      'Un resumen del tamaño de una tarjeta de crédito que puede imprimir y llevar consigo.';

  @override
  String get exportSaveAnEditableCopy => 'Guardar una copia editable';

  @override
  String get exportNotAFinishedDocumentThis =>
      'No es un documento terminado: así es como guarda su progreso. La aplicación web no puede almacenar su trabajo en este dispositivo, así que descargue este archivo para conservarlo y luego vuelva a subirlo (aquí o en otro dispositivo) para seguir editando. No se almacena nada en línea.';

  @override
  String get exportEncryptingHindersOthersFromReading =>
      'El cifrado dificulta que otros lo lean; la aplicación lo sigue abriendo sin frase de contraseña.';

  @override
  String get exportMachineReadableFormats => 'Formatos legibles por máquina';

  @override
  String get exportYourPdfAboveIsThe =>
      'El PDF de arriba es el documento que usted firma; estas son exportaciones de datos para sus registros, una hoja de cálculo o un sistema de salud. FHIR es el formato estándar que usan los hospitales para intercambiar historias clínicas; CSV es un archivo de hoja de cálculo (se abre en Excel o Google Sheets).';

  @override
  String aiSetupTestOk(String provider) {
    return '$provider respondió. Esta clave y este modelo funcionan.';
  }

  @override
  String get aiSetupPrivacyLeadGemini =>
      'En el nivel gratuito de Gemini, Google puede usar los datos que envíe para mejorar sus productos de IA, y revisores humanos pueden leer lo que envía.';

  @override
  String aiSetupPrivacyLeadOther(String provider) {
    return 'Su clave de $provider envía datos a $provider; se aplica su política de uso y conservación de datos.';
  }

  @override
  String get aiSetupPrivacyKeyEphemeral =>
      'Su clave de API se mantiene en memoria durante esta sesión, con una copia temporal de hasta 10 minutos (para recuperarse de fallos); se descarta cuando termina la sesión.';

  @override
  String get aiSetupPrivacyKeyStored =>
      'Su clave de API se guarda de forma segura solo en este dispositivo y nunca se comparte con nadie más que su proveedor de IA.';

  @override
  String aiSetupPrivacyNoticeBody(String lead, String keyLine) {
    return '$lead\n\nLas funciones de IA de esta aplicación envían a los servidores de su proveedor de IA el texto que usted ingresa en los campos del formulario y en los mensajes del chat. No incluya datos de identificación personal (nombre legal completo, número de Seguro Social, fecha de nacimiento, etc.) en el chat de IA ni al usar Sugerencias de IA.\n\n$keyLine';
  }

  @override
  String get aiSetupDuckDuckGoNote =>
      'Toda la navegación es privada (el botón Fire la borra)';

  @override
  String aiSetupProviderFree(String provider) {
    return '$provider (gratis)';
  }

  @override
  String aiSetupShortcutWithMac(
    String browser,
    String shortcut,
    String macShortcut,
  ) {
    return '$browser:  $shortcut  (Mac: $macShortcut)';
  }

  @override
  String aiSetupShortcutMacOnly(String browser, String macShortcut) {
    return '$browser:  $macShortcut  (solo Mac)';
  }

  @override
  String get feAiUnreachable =>
      'No se pudo conectar con el servicio de IA. Revise su conexión a internet. Si usa la aplicación web, es posible que la política de seguridad de su navegador también bloquee a este proveedor; Gemini y Claude funcionan en el navegador.';

  @override
  String get feNoInternet =>
      'No hay conexión a internet. Revise su red e intente de nuevo.';

  @override
  String get feTimeout =>
      'Se agotó el tiempo de espera de la solicitud. Revise su conexión e intente de nuevo.';

  @override
  String get feBlocked =>
      'No se pudo conectar con el servicio de IA: la solicitud se bloqueó o la conexión falló. Revise su conexión a internet y, si usa la aplicación web, pruebe Gemini o Claude, que funcionan en el navegador.';

  @override
  String get feRateLimited =>
      'Demasiadas solicitudes. Espere un momento e intente de nuevo.';

  @override
  String get feKeyRejected =>
      'Su clave de API fue rechazada. Abra la configuración de IA y verifique que la clave sea correcta, siga activa y pertenezca al proveedor seleccionado.';

  @override
  String get feModelUnavailable =>
      'El modelo de IA seleccionado no está disponible; es posible que se haya retirado. Elija otro modelo en la configuración de IA.';

  @override
  String get feEmptyResponse =>
      'La IA no devolvió resultados. Intente de nuevo o ingrese la información manualmente.';

  @override
  String get feBadFormat =>
      'La respuesta de la IA no tenía el formato esperado. Intente de nuevo.';

  @override
  String get feServiceError =>
      'El servicio de IA tuvo un error. Intente de nuevo más tarde.';

  @override
  String get fePermission =>
      'No se concedió el permiso. Revise la configuración de su dispositivo.';

  @override
  String get feGeneric => 'Algo salió mal. Intente de nuevo.';

  @override
  String assistantSendError(String error) {
    return 'Lo siento, ocurrió un error: $error';
  }

  @override
  String assistantVerifyError(String error) {
    return 'Lo siento, no pude verificarlo en la web: $error';
  }

  @override
  String get permissionsOverviewUnlockingEncryptedOnDeviceStorage =>
      'Desbloquear el almacenamiento cifrado en el dispositivo (solo en la aplicación nativa; la aplicación web no lo usa).';

  @override
  String get permissionsOverviewUsedOnlyToVerifyYour =>
      'Se usa solo para verificar su identidad al desbloquear';

  @override
  String get permissionsOverviewBiometricDataNeverLeavesThe =>
      'Los datos biométricos nunca salen del almacén de claves del sistema operativo';

  @override
  String get permissionsOverviewNoBiometricDataIsSent =>
      'No se envían datos biométricos a ningún servidor';

  @override
  String get permissionsOverviewFallsBackToAPasscode =>
      'Si la biometría falla, se usa un código que usted elige';

  @override
  String get permissionsOverviewNotApplicableOnThisPlatform =>
      'No aplica en esta plataforma';

  @override
  String get permissionsOverviewRemindingYouAboutWitnessSigning =>
      'Recordatorios sobre la firma de testigos, renovaciones y revisiones periódicas.';

  @override
  String get permissionsOverviewYouChooseWhichRemindersTo =>
      'Usted elige qué recordatorios activar';

  @override
  String get permissionsOverviewNotificationsAreScheduledLocallyOn =>
      'Las notificaciones se programan localmente en este dispositivo';

  @override
  String get permissionsOverviewNoContentPiiDirectiveText =>
      'Ninguna notificación incluye contenido (datos personales ni texto de la directiva)';

  @override
  String get permissionsOverviewDisablePerCategoryInDevice =>
      'Desactívelas por categoría en Configuración del dispositivo → Notificaciones';

  @override
  String get permissionsOverviewSnappingAPhotoOfYour =>
      'Tomar una foto de su identificación, etiquetas de medicamentos o listas de afecciones para extraer campos con ayuda de la IA. Disponible en una versión futura.';

  @override
  String get permissionsOverviewPhotoIsSentToAi =>
      'La foto se envía a la IA solo para leerla';

  @override
  String get permissionsOverviewPhotoIsDiscardedRightAfter =>
      'La foto se descarta justo después de la extracción';

  @override
  String get permissionsOverviewNothingIsSavedToYour =>
      'De forma predeterminada, no se guarda nada en la galería de fotos de su dispositivo';

  @override
  String get permissionsOverviewYouReviewEveryFieldBefore =>
      'Usted revisa cada campo antes de que se use';

  @override
  String get permissionsOverviewNotYetWiredFeatureIn =>
      'Aún no conectado: función de una versión futura';

  @override
  String get permissionsOverviewSpeakingLongFormAnswersE =>
      'Dictar respuestas largas (por ejemplo, \"algo más\") en lugar de escribirlas. Disponible en una versión futura.';

  @override
  String get permissionsOverviewAudioIsProcessedOnDevice =>
      'El audio se procesa en el dispositivo cuando es posible';

  @override
  String get permissionsOverviewIfSentToAiFor =>
      'Si se envía a la IA para transcribirlo, no se almacena';

  @override
  String get permissionsOverviewTranscriptStaysInYourSession =>
      'La transcripción se queda en su sesión; nunca se sube';

  @override
  String get permissionsOverviewToggleOffAtAnyTime =>
      'Desactívelo en cualquier momento en Configuración';

  @override
  String get permissionsOverviewPickingAnAgentOrWitness =>
      'Elegir un agente o testigo de su libreta de direcciones en lugar de escribir sus datos. Disponible en una versión futura.';

  @override
  String get permissionsOverviewWeNeverUploadYourContacts =>
      'Nunca subimos sus contactos';

  @override
  String get permissionsOverviewSearchRunsLocallyOnThis =>
      'La búsqueda se hace localmente en este dispositivo';

  @override
  String get permissionsOverviewOnlyTheContactYouPick =>
      'Solo el contacto que elija se agrega a la directiva';

  @override
  String get permissionsOverviewYouCanRevokeAccessIn =>
      'Puede revocar el acceso en Configuración en cualquier momento';

  @override
  String get permissionsOverviewAvailableOsManaged =>
      'Disponible · administrado por el sistema';

  @override
  String get eduBrowseIntroduction => 'Introducción';

  @override
  String get eduBrowseWhatAnMhadIsAnd =>
      'Qué es una DASM y quién debería firmarla';

  @override
  String get eduBrowseCombinedForm => 'Formulario combinado';

  @override
  String get eduBrowseBothAnAgentAndTreatment =>
      'Un agente y preferencias de tratamiento';

  @override
  String get eduBrowseTreatmentPreferencesWithoutAnAgent =>
      'Preferencias de tratamiento sin agente';

  @override
  String get eduBrowsePowerOfAttorney => 'Poder Notarial';

  @override
  String get eduBrowseAgentDesignationWithoutPreferences =>
      'Designación de agente sin preferencias';

  @override
  String get eduBrowseFrequentlyAsked => 'Preguntas frecuentes';

  @override
  String get eduBrowseCommonQuestionsAboutMhads =>
      'Preguntas comunes sobre las DASM';

  @override
  String get eduBrowseGlossary => 'Glosario';

  @override
  String get eduBrowseEveryLegalTermDefined =>
      'Todos los términos legales, definidos';

  @override
  String get eduBrowseBeyondTheBooklet => 'Más allá del folleto';

  @override
  String get eduBrowseTopicsNotCoveredInThe =>
      'Temas que no trata el folleto oficial de PA';

  @override
  String get eduBrowseYourChecklist => 'Su lista de verificación';

  @override
  String get eduBrowseStepByStepDistributionRevocation =>
      'Guías paso a paso de distribución y revocación';

  @override
  String get webLandingPreferPaperOpenAnyOf =>
      '¿Prefiere papel? Abra cualquiera de los tres formularios oficiales en blanco para imprimirlo y completarlo a mano; no necesita cuenta ni asistente.';

  @override
  String get webLandingNoAccountRequired => 'No necesita cuenta';

  @override
  String get webLandingNoEmailNoPasswordNo =>
      'Sin correo, sin contraseña, sin registro.';

  @override
  String get webLandingNothingLeavesYourBrowser => 'Nada sale de su navegador';

  @override
  String get webLandingYourAnswersLiveInThis =>
      'Sus respuestas viven en esta pestaña. Nunca las vemos.';

  @override
  String get webLandingNoCookiesNoTracking => 'Sin cookies, sin rastreo';

  @override
  String get webLandingNoAnalyticsNoThirdParty =>
      'Sin analíticas ni scripts de terceros.';

  @override
  String get webLandingYouKeepTheFile => 'Usted conserva el archivo';

  @override
  String get webLandingSaveThePdfFromYour =>
      'Guarde el PDF desde su visor: es la única copia.';

  @override
  String get pinDialogPasscodeTooShort =>
      'El código debe tener al menos 4 caracteres.';

  @override
  String get pinDialogPasscodesDontMatch => 'Los códigos no coinciden.';

  @override
  String get pinDialogUnlockPrivateMode => 'Desbloquear el modo privado';

  @override
  String get pinDialogEnterPasscode => 'Ingrese su código.';

  @override
  String get pinDialogTooManyAttempts =>
      'Demasiados intentos. Espere 30 segundos.';

  @override
  String get pinDialogIncorrectPasscode =>
      'Código incorrecto. Intente de nuevo.';

  @override
  String get deviceSecurityWarningTitle =>
      'Advertencia de seguridad del dispositivo';

  @override
  String get deviceSecurityWarningBody =>
      'Parece que su dispositivo tiene acceso root o jailbreak. Esto puede poner en riesgo sus datos de salud sensibles. Considere usar un dispositivo sin modificar para guardar directivas anticipadas.';

  @override
  String get deviceSecurityIUnderstand => 'Entiendo';

  @override
  String get blankFormPrintTitle => 'Imprimir un formulario en blanco';

  @override
  String blankFormPrintError(String error) {
    return 'No se pudo abrir el formulario en blanco para imprimir: $error';
  }

  @override
  String launchCopiedToClipboard(String value) {
    return '$value copiado al portapapeles';
  }

  @override
  String get reminderRenewMetricSections => 'secciones';

  @override
  String get reminderRenewMetricWetInk => 'con tinta';

  @override
  String get reminderRenewMetricSigning => 'firma';

  @override
  String get reminderRenewMetricMin => 'min';

  @override
  String get educationBefore => 'antes';

  @override
  String get assistantGeneralQuestion => 'Pregunta general';

  @override
  String get assistantContextPanelStrippedBeforeSend =>
      'Se quita antes de enviar';

  @override
  String get assistantSuggestWalkMeThroughFillingOut =>
      'Guíeme paso a paso para completar mi directiva';

  @override
  String get assistantSuggestWhatIsAMentalHealth =>
      '¿Qué es una Directiva Anticipada de Salud Mental?';

  @override
  String get assistantSuggestWhatSTheDifferenceBetween =>
      '¿Cuál es la diferencia entre Combinado, Declaración y Poder Notarial?';

  @override
  String get assistantSuggestWhoCanBeMyAgent => '¿Quién puede ser mi agente?';

  @override
  String get assistantSuggestWhatMedicationsShouldIList =>
      '¿Qué medicamentos debo anotar?';

  @override
  String get assistantSuggestWhatDoesEctMean => '¿Qué significa TEC?';

  @override
  String get assistantSuggestHowLongIsTheDirective =>
      '¿Por cuánto tiempo es válida la directiva?';

  @override
  String get assistantSuggestCanIChangeMyDirective =>
      '¿Puedo cambiar mi directiva más adelante?';

  @override
  String get ulyssesOnlyAppliesOnceIHave =>
      'Solo se aplica una vez que se haya determinado formalmente que no tengo capacidad';

  @override
  String get ulyssesOnlyForTreatmentsIExplicitly =>
      'Solo para los tratamientos que nombré explícitamente (medicamentos, TEC, centro)';

  @override
  String get ulyssesDoesNotAuthorizePhysicalRestraint =>
      'No autoriza la sujeción física';

  @override
  String get ulyssesACourtAppointedGuardianNot =>
      'Un tutor designado por un tribunal (no el agente) puede revocarla, suspenderla o darla por terminada';

  @override
  String get ulyssesMyDirectiveStillTerminatesAt =>
      'Mi directiva sigue terminando a los 2 años, a menos que yo esté incapacitado cuando vencería; en ese caso sigue vigente (§§ 5824(e), 5834(c))';

  @override
  String homeHeroPercentComplete(int percent) {
    return '$percent% completado';
  }

  @override
  String get homeHeroReadyToReviewSign => 'Lista para revisar y firmar';

  @override
  String homeHeroMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~ $count pasos más',
      one: '~ 1 paso más',
    );
    return '$_temp0';
  }

  @override
  String get homeHeroCombinedForm => 'Formulario combinado';

  @override
  String get homeHeroDeclarationOnly => 'Solo Declaración';

  @override
  String homeHeroNamedMhad(String name) {
    return 'DASM de $name';
  }

  @override
  String get homeHeroYourMhad => 'Su DASM';

  @override
  String get educationNoResultsFound => 'No se encontraron resultados.';

  @override
  String educationNoResultsFor(String query) {
    return 'No hay resultados para \"$query\"';
  }

  @override
  String get relativeJustNow => 'justo ahora';

  @override
  String relativeMinsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count min',
      one: 'hace 1 min',
    );
    return '$_temp0';
  }

  @override
  String relativeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get revocationNotifyPrimaryCareDoctor => 'Médico de atención primaria';

  @override
  String get revocationNotifyPsychiatristTherapist => 'Psiquiatra / terapeuta';

  @override
  String get revocationNotifyNearestHospitalEr =>
      'Sala de urgencias del hospital más cercano';

  @override
  String get revocationNotifyPharmacy => 'Farmacia';

  @override
  String get revocationNotifyLocalRightsAdvocate =>
      'Defensor de derechos local';

  @override
  String get legalSheetBoldNot => 'no';

  @override
  String get legalSheetBoldOnly => 'solo';

  @override
  String get legalSheetBoldTwoAdultWitnesses => 'dos testigos adultos';

  @override
  String get legalSheetBoldWitnessesCannotBe => 'Los testigos no pueden ser: ';

  @override
  String get legalSheetBoldPrinted => 'impresa';

  @override
  String get legalSheetBoldMustComply => 'deben cumplir';

  @override
  String get legalSheetBoldTwoYears => 'dos años';

  @override
  String get legalSheetBoldUnlessYouAreFoundIncapable =>
      'a menos que se determine que usted es incapaz';

  @override
  String get legalSheetBoldNotSavedPermanently =>
      'no se guarda de forma permanente';

  @override
  String get legalSheetBoldAutomaticallyKeepsIdentifyingDetailsOut =>
      'excluye automáticamente los datos identificativos de lo que envía al asistente de IA y de sus sugerencias';

  @override
  String get legalSheetBoldUploadingIsNeverRequired =>
      'Subir documentos nunca es obligatorio';

  @override
  String get legalSheetBoldTheseLookupsSendOnlyThe =>
      'Estas consultas solo envían el término médico, el código o el nombre del proveedor que se busca';

  @override
  String get legalSheetYourRightsUnderAct194 => 'Sus derechos según la Ley 194';

  @override
  String get legalSheet247FreeConfidential => '24/7, gratis y confidencial';

  @override
  String get legalSheetCallOrText988 => 'Llame o envíe un mensaje al 988';

  @override
  String get crisisPlanTheFirstThingsINotice =>
      'Lo primero que noto cuando cambia mi estado de ánimo.';

  @override
  String get crisisPlanExternalThingsThatHaveSet =>
      'Cosas externas que antes han desencadenado episodios.';

  @override
  String get crisisPlanSpecificConcreteNotSelfCare =>
      'Específico y concreto. No \'autocuidado\': lo que de verdad funciona.';

  @override
  String get crisisPlanWordsThatGroundMeUseful =>
      'Palabras que me ayudan a centrarme. Útiles para el personal, los paramédicos y la familia.';

  @override
  String get crisisPlanApproachesThatEscalateMeBe =>
      'Formas de trato que me alteran más. Sea específico.';

  @override
  String get reminderSheetsAgentsPrimaryAndAlternate =>
      'Agentes: principal y alternativo';

  @override
  String get reminderSheetsCurrentMedsOnesYouDon =>
      'Medicamentos actuales, los que no quiere, alergias';

  @override
  String get reminderSheetsPreferredFacilityRoomEnvironment =>
      'Centro preferido, ambiente de la habitación';

  @override
  String get accessibilitySettingsAtkinsonHyperlegibleClearerEasierLetter =>
      'Atkinson Hyperlegible: letras más claras y fáciles de leer';

  @override
  String get accessibilitySettingsHeavierTextWeightEverywhere =>
      'Texto más grueso en todas partes';

  @override
  String get accessibilitySettingsRemovesScreenTransitionsAndAnimations =>
      'Quita las transiciones y animaciones de pantalla';

  @override
  String get accessibilitySettingsMaximizesSeparationBetweenTextAnd =>
      'Maximiza el contraste entre el texto y el fondo';

  @override
  String get accessibilitySettingsUseYourBrowserOrDevice =>
      'Use la lectura en voz alta de su navegador o dispositivo; vea la guía de abajo';

  @override
  String get accessibilitySettingsChromeEdgeDesktop =>
      'Chrome / Edge (computadora)';

  @override
  String get directiveFormChoiceTreatmentPreferencesWithoutNamingAn =>
      'Preferencias de tratamiento sin nombrar a un agente.';

  @override
  String get directiveFormChoiceNameADecisionMakerWithout =>
      'Nombre a una persona que decida sin anotar preferencias.';

  @override
  String get homeToolsGridFaqGlossary => 'Preguntas frecuentes, glosario';

  @override
  String get homeToolsGrid988More => '988 y más';

  @override
  String get facilitator45Min => '~45 min';

  @override
  String get facilitatorFree => 'Gratis';

  @override
  String get facilitatorPaBased => 'En PA';

  @override
  String get facilitatorInPerson => 'En persona';

  @override
  String get facilitatorYouStayInControl => 'Usted mantiene el control';

  @override
  String get facilitatorEmailComposer => 'Redactor de correo';

  @override
  String get facilitatorManualTranscribeBack =>
      'Transcripción manual de vuelta';

  @override
  String get modeSelectionBiometrics => 'Biometría';

  @override
  String get modeSelectionAes256 => 'AES-256';

  @override
  String get modeSelectionSaveDrafts => 'Guarda borradores';

  @override
  String get modeSelectionAcrossSessions => 'Entre sesiones';

  @override
  String get modeSelectionNothingSaved => 'No guarda nada';

  @override
  String get modeSelectionInMemoryOnly => 'Solo en memoria';

  @override
  String get modeSelectionSingleSession => 'Una sola sesión';

  @override
  String get pdfPreviewLoading => 'Cargando…';

  @override
  String get pdfPreviewSelectASectionToPreview =>
      'Seleccione una sección para ver la vista previa.';

  @override
  String get pdfPreviewCouldNotRenderThePreview =>
      'No se pudo mostrar la vista previa.';

  @override
  String reminderSheetsStepN(int n) {
    return 'Paso $n';
  }

  @override
  String get sideEffectsNoneFound =>
      'En este momento no encontramos efectos secundarios comunes para mostrar. Puede agregar lo que esté experimentando en el paso Algo más y consulte siempre sus inquietudes sobre efectos secundarios con su médico.';

  @override
  String get sideEffectsGenerateError =>
      'Algo salió mal al generar la lista. Intente de nuevo o anote usted mismo los efectos secundarios.';

  @override
  String get inputPhoneInvalid =>
      'Ingrese un número de teléfono válido de 10 dígitos';

  @override
  String get inputZipInvalid =>
      'Ingrese un código postal de 5 dígitos o de 5+4 dígitos';

  @override
  String get audioGuideTipQualityDoesnTMatterAny =>
      'La calidad no importa. Cualquier nota de voz del teléfono sirve: la IA reduce la calidad del audio de todos modos, así que un archivo pequeño de baja calidad se transcribe igual de bien que uno grande.';

  @override
  String get audioGuideTipKeepEachClipShortUnder =>
      'Haga cada grabación corta, de menos de unos 2 minutos. Grabe una por cada sección de abajo y súbalas juntas; la aplicación las combina. Las grabaciones largas pueden agotar el tiempo de espera.';

  @override
  String get audioGuideTipSayMedicationAndDoctorNames =>
      'Diga los nombres de medicamentos y médicos despacio y deletréelos. La IA no adivinará un medicamento o afección que no haya oído con claridad.';

  @override
  String get stepSubtitleAboutYou =>
      'Solo lo básico para que este documento sea exclusivamente suyo. Suba una foto de su identificación y los leeremos por usted.';

  @override
  String get stepSubtitleWhenItKicksIn =>
      'Las condiciones en las que su directiva entra en vigor. Puede elegir más de una.';

  @override
  String get stepSubtitlePeopleITrust =>
      'Hablan por usted si usted no puede. Puede nombrar a un agente principal y a uno alternativo, y poner límites a lo que deciden.';

  @override
  String get stepSubtitleGuardianNomination =>
      'Es poco común, pero conviene planificarlo. Un tutor lo nombra un tribunal, no usted, y tiene una autoridad más amplia que un agente.';

  @override
  String get stepSubtitleWhereIWantCare =>
      'Los centros que prefiere, y los que quiere evitar específicamente, además de sus preferencias de habitación y ambiente.';

  @override
  String get stepSubtitleDiagnoses =>
      'Ayude a su equipo de atención a ver el panorama completo en una crisis. Busque por nombre: adjuntamos el código CIE-10 que usan sus médicos.';

  @override
  String get stepSubtitleMedications =>
      'Lo que toma ahora (para su equipo de atención) y los medicamentos que rechaza, limita o prefiere. Sus rechazos y límites son vinculantes según la Ley 194.';

  @override
  String get stepSubtitleAllergies =>
      'Alergias a medicamentos, sensibilidades y reacciones adversas anteriores. Es la sección que más revisa el personal de urgencias.';

  @override
  String get stepSubtitleProceduresResearch =>
      'Según la ley de PA, tres tratamientos requieren su consentimiento explícito. Defina cada uno; su agente completa lo que falte.';

  @override
  String get stepSubtitleAnythingElse =>
      'Preferencias libres que no se trataron arriba. Es su voz: escríbalo como lo diría.';

  @override
  String get stepSubtitleReviewAndSign =>
      'Un último vistazo y luego prepararemos su paquete para firmar. Toque cualquier sección para editarla.';

  @override
  String get formTypeNameCombined => 'Declaración y Poder Notarial combinados';

  @override
  String get formTypeNameDeclaration => 'Solo Declaración';

  @override
  String get formTypeNamePoa => 'Solo Poder Notarial';

  @override
  String get formTypeShortCombined => 'Combinado';

  @override
  String get formTypeShortDeclaration => 'Declaración';

  @override
  String get formTypeShortPoa => 'Poder Notarial';

  @override
  String get stepTitleAboutYou => 'Sobre usted';

  @override
  String get stepTitleWhenItKicksIn => 'Cuándo entra en vigor';

  @override
  String get stepTitlePeopleITrust => 'Personas de confianza';

  @override
  String get stepTitleGuardianNomination => 'Si un tribunal nombra un tutor';

  @override
  String get stepTitleWhereIWantCare => 'Dónde quiero recibir atención';

  @override
  String get stepTitleDiagnoses => 'Diagnósticos';

  @override
  String get stepTitleMedications => 'Medicamentos';

  @override
  String get stepTitleAllergies => 'Alergias y reacciones';

  @override
  String get stepTitleProceduresResearch => 'Procedimientos e investigación';

  @override
  String get stepTitleAnythingElse => 'Algo más';

  @override
  String get stepTitleReviewAndSign => 'Revisión';

  @override
  String get directiveStatusRevoked => 'Revocada';

  @override
  String get directiveStatusExpired => 'Vencida';

  @override
  String get directiveStatusActive => 'Vigente';

  @override
  String get directiveStatusDraft => 'Borrador';

  @override
  String pastDirectiveSignedOn(String date) {
    return 'firmada el $date';
  }

  @override
  String pastDirectiveExpiredOn(String date) {
    return 'venció el $date';
  }

  @override
  String pastDirectiveExpiresOn(String date) {
    return 'vence el $date';
  }

  @override
  String get settingsDefaultUserName => 'Usuario de DASM de PA';

  @override
  String rateDailyLimitUsed(int max) {
    return 'Ha usado las $max solicitudes gratuitas de hoy. El límite se restablece a medianoche. Considere pasar a una clave de API de pago para tener límites más altos.';
  }

  @override
  String rateTooManyThisMinute(int max, int seconds) {
    return 'Demasiadas solicitudes en este minuto (límite: $max/min). Espere $seconds segundos.';
  }

  @override
  String rateTokenLimitThisMinute(int thousands) {
    return 'Se alcanzó el límite de tokens de este minuto (${thousands}K/min). Espere un momento antes de enviar otra solicitud.';
  }

  @override
  String get rateDailyLimitReached => 'Se alcanzó el límite diario';

  @override
  String rateWaitStatus(int seconds, int remaining) {
    return 'Espere $seconds s • quedan $remaining solicitudes hoy';
  }

  @override
  String rateRemainingStatus(int remainingToday, int remainingMinute) {
    return 'Quedan $remainingToday solicitudes hoy • $remainingMinute en este minuto';
  }

  @override
  String llmHeicUnsupported(String provider) {
    return '$provider no puede leer fotos HEIC/HEIF (el formato predeterminado del iPhone). Cambie a Gemini o vuelva a guardar la foto como JPEG o PNG.';
  }

  @override
  String llmPdfUnsupported(String provider) {
    return '$provider no puede leer PDF aquí; cambie a Gemini o Claude, o pegue el texto del documento.';
  }

  @override
  String llmFileTypeUnsupported(String provider, String mimeType) {
    return '$provider no puede leer archivos $mimeType aquí; cambie a Gemini o pegue el texto.';
  }

  @override
  String llmRateLimited(String provider) {
    return 'Demasiadas solicitudes a $provider. Espere un minuto e intente de nuevo.';
  }

  @override
  String llmGeminiKeyRejected(String provider) {
    return '$provider rechazó su clave de API. Abra la configuración de IA y verifique que la clave sea correcta, siga activa y tenga habilitada la Generative Language API.';
  }

  @override
  String llmGeminiModelNotFound(String provider, String model) {
    return '$provider no reconoce el modelo \"$model\"; es posible que se haya retirado. Elija otro modelo en la configuración de IA.';
  }

  @override
  String llmNetworkError(String provider, String detail) {
    return 'No se pudo conectar con $provider ($detail). Revise su conexión a internet. Si usa la aplicación web, es posible que la política CORS de su navegador también bloquee a este proveedor; Gemini y Claude funcionan en el navegador.';
  }

  @override
  String llmKeyRejected(String provider) {
    return '$provider rechazó su clave de API. Abra la configuración de IA y verifique que la clave sea correcta, siga activa y pertenezca a $provider.';
  }

  @override
  String llmModelNotFound(String provider, String model) {
    return '$provider no reconoce el modelo \"$model\". Elija otro modelo en la configuración de IA.';
  }

  @override
  String get importFileUnreadable =>
      'No se pudo leer el archivo: está dañado o no es un archivo de directiva de DASM.';

  @override
  String get importFileUnrecognized =>
      'Este archivo no es un archivo de directiva reconocido.';

  @override
  String get importFileCorrupted => 'El archivo está dañado.';

  @override
  String get importNotDirectiveFile => 'Este no es un archivo de directiva.';

  @override
  String get importNotMhadFile => 'Este no es un archivo de directiva de DASM.';

  @override
  String get importNewerVersion =>
      'Este archivo se creó con una versión más reciente de la aplicación. Actualícela para abrirlo.';

  @override
  String get importNoDirectiveData =>
      'El archivo no contiene datos de directiva.';

  @override
  String get breachNoticeDefaultTitle =>
      'Aviso de un incidente de seguridad de datos';

  @override
  String get breachNoticeWhatHappened => 'Qué pasó';

  @override
  String get breachNoticeInformationInvolved =>
      'Qué información estuvo involucrada';

  @override
  String get breachNoticeThirdParties => 'Quién obtuvo la información';

  @override
  String get breachNoticeWhatWeAreDoing => 'Qué estamos haciendo';

  @override
  String get breachNoticeWhatYouCanDo => 'Qué puede hacer usted';

  @override
  String get breachNoticeContactUs => 'Cómo comunicarse con nosotros';

  @override
  String get breachNoticeAcknowledge => 'He leído este aviso';

  @override
  String get dateInputHint => 'MM/DD/AAAA';

  @override
  String get facilitatorGuidedTag => 'SESIÓN GUIADA · EN LA APLICACIÓN';

  @override
  String get facilitatorGuidedTitle => 'Háblelo, una pregunta a la vez';

  @override
  String get facilitatorGuidedBody =>
      'El asistente de IA hace las preguntas que haría un facilitador capacitado, en el mismo orden: cómo es una crisis para usted, qué le ha ayudado o empeorado las cosas, en quién confía y luego sus decisiones. Usted mismo completa el formulario; el asistente explica, no decide.';

  @override
  String get facilitatorGuidedMetaPace => 'Deténgase cuando quiera';

  @override
  String get facilitatorGuidedMetaAi => 'Usa su clave de IA';

  @override
  String get facilitatorGuidedStart => 'Iniciar una sesión guiada';

  @override
  String get facilitatorHelperStart => 'Estoy ayudando a alguien';

  @override
  String get facilitatorGuidedOpeningPrompt =>
      'Quisiera una sesión guiada. Por favor, guíeme por mi directiva anticipada una pregunta a la vez, empezando por cómo es una crisis para mí.';

  @override
  String get facilitatorHelperOpeningPrompt =>
      'Estoy ayudando a alguien a completar su directiva anticipada. Por favor, guíenos una pregunta a la vez, empezando por cómo es una crisis para esa persona.';

  @override
  String get assistantContextGuidedSession => 'Sesión guiada';

  @override
  String get assistantContextHelperSession =>
      'Sesión guiada · ayudando a alguien';

  @override
  String get accessibilitySettingsSectionReading => 'Lectura';

  @override
  String get accessibilitySettingsSectionLanguage => 'Idioma';

  @override
  String get accessibilitySettingsTextSizeSmall => 'Pequeño';

  @override
  String get accessibilitySettingsTextSizeDefault => 'Predeterminado';

  @override
  String get accessibilitySettingsTextSizeLarge => 'Grande';

  @override
  String get accessibilitySettingsTextSizeHuge => 'Muy grande';

  @override
  String get accessibilitySettingsSpanishReviewNotice =>
      'La traducción al español se hizo con ayuda de herramientas automáticas y todavía no la ha revisado un hablante nativo. Si alguna redacción no está clara, cambie a inglés para verificarla. El PDF de su directiva siempre se genera en inglés.';

  @override
  String get settingsThemeAuto => 'Automático';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsStatusWebInMemory => '● APLICACIÓN WEB · SOLO EN MEMORIA';

  @override
  String settingsStatusNative(String mode, String auth) {
    return '● MODO $mode · $auth';
  }

  @override
  String get settingsStatusPrivate => 'PRIVADO';

  @override
  String get settingsStatusPublic => 'PÚBLICO';

  @override
  String get settingsStatusNoSession => 'SIN SESIÓN';

  @override
  String get settingsStatusBiometrics => 'BIOMETRÍA';

  @override
  String get settingsStatusEphemeral => 'EFÍMERO';

  @override
  String get pinDialogAuthenticating => 'AUTENTICANDO…';

  @override
  String get pinDialogLockedWait => 'BLOQUEADO · ESPERE 30 S';

  @override
  String pinDialogAttempt(int count, int max) {
    return 'INTENTO $count / $max';
  }

  @override
  String get modeSelectionRecommendedSuffix => ' (recomendado)';

  @override
  String get onboardingPillValidTwoYears => 'Válida 2 años';

  @override
  String get onboardingPillTwoWitnesses => '2 testigos';

  @override
  String get onboardingPillAct194 => 'Ley 194 de PA';

  @override
  String get onboardingPillNothingSaved => 'No se guarda nada';

  @override
  String get onboardingPillStaysOnDevice => 'Se queda en su dispositivo';

  @override
  String get educationHelpTitle => 'Ayuda';

  @override
  String get educationTabAll => 'Todo';

  @override
  String get educationTabArticles => 'Artículos';

  @override
  String get educationTabGlossary => 'Glosario';

  @override
  String get educationTabFaq => 'Preguntas';

  @override
  String get educationTabChecklists => 'Listas';

  @override
  String get educationCategoryFaq => 'Preguntas frecuentes';

  @override
  String get educationSourceBeyondBooklet => 'MÁS ALLÁ DEL FOLLETO';

  @override
  String get educationSourceOfficialBooklet => 'DEL FOLLETO OFICIAL';

  @override
  String get commonLoading => 'Cargando';

  @override
  String get wizardHeaderSaveAndExit => 'Guardar y salir';

  @override
  String get fdaLabelDialogAdverseReactions =>
      'Reacciones adversas (efectos secundarios)';

  @override
  String get fdaLabelDialogDrugInteractions =>
      'Interacciones con otros medicamentos';

  @override
  String get addressFieldsEnterZipFirst =>
      'Primero ingrese un código postal de 5 dígitos.';

  @override
  String get addressFieldsZipLookupFailed =>
      'No se pudo buscar ese código postal; puede escribirlo usted.';

  @override
  String addressFieldsFilled(String place) {
    return 'Completado: $place';
  }

  @override
  String get aiConsentDialogGeminiCaveat =>
      'En el nivel gratuito de Gemini, Google puede conservar sus datos y usarlos para mejorar su IA, revisores humanos pueden verlos y lo que se envía no se puede recuperar ni borrar después.';

  @override
  String aiConsentDialogProviderCaveat(String provider) {
    return 'Sus datos se envían a $provider y se tratan según su política de datos de API; ni usted ni esta aplicación pueden recuperar ni borrar lo que se envía.';
  }

  @override
  String get reminderSheetsExpiresSoon => 'pronto';

  @override
  String get reminderSheetsExpiresToday => 'hoy';

  @override
  String reminderSheetsExpiresInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count días',
      one: 'en 1 día',
    );
    return '$_temp0';
  }

  @override
  String get reminderSheetsYourRenewalDate => 'su fecha de renovación';

  @override
  String get pastDirectiveDetailPrincipalYou => 'Usted';

  @override
  String get exportShareSubjectEditable =>
      'Copia editable de la directiva DASM';

  @override
  String get exportShareSubjectFhirJson => 'Recurso FHIR Consent de la DASM';

  @override
  String get exportShareSubjectFhirXml =>
      'Recurso FHIR Consent de la DASM (XML)';

  @override
  String get exportShareSubjectCsv => 'Directiva DASM (CSV)';

  @override
  String get exportShareSubjectBundle => 'Paquete de la directiva DASM de PA';

  @override
  String get assistantContextLearning => 'Aprendizaje';

  @override
  String get educationArticlesInEnglishNotice =>
      'Los artículos a continuación reproducen el folleto oficial de Pensilvania y por ahora solo están disponibles en inglés.';

  @override
  String get sideEffectsOfficialLabelsHeading =>
      'Etiquetas oficiales de la FDA';

  @override
  String get sideEffectsOfficialLabelsIntro =>
      'Directamente de la etiqueta de la FDA de cada medicamento (openFDA). No necesita IA. Toque un medicamento para leer sus efectos secundarios e interacciones.';

  @override
  String get sideEffectsChecklistOptionalTitle =>
      '¿Quiere una lista breve? (opcional)';

  @override
  String get sideEffectsChecklistOptionalBody =>
      'Las etiquetas de la FDA de abajo funcionan sin IA. Si configura el asistente de IA gratuito, también puede convertirlas en una lista breve que puede marcar, con las posibles interacciones redactadas como preguntas para su médico.';

  @override
  String llmRefusal(String provider) {
    return '$provider no quiso responder a esto. Si está en crisis o piensa en hacerse daño, llame o envíe un mensaje al 988 ahora. Si no, intente reformular la pregunta o elija otro modelo en la configuración de IA.';
  }

  @override
  String llmTruncated(String provider) {
    return '$provider se quedó sin espacio antes de poder responder. Intente de nuevo; si sigue pasando, elija otro modelo en la configuración de IA.';
  }

  @override
  String get crisisBannerTitle => 'No tiene que esperar a la IA';

  @override
  String get crisisBannerBody =>
      'Si está pensando en el suicidio o en hacerse daño, o está en crisis, llame o envíe un mensaje al 988 ahora: es gratis, confidencial y está disponible las 24 horas. Si está en peligro inmediato, llame al 911.';

  @override
  String get crisisBannerCall => 'Llamar al 988';

  @override
  String get crisisBannerText => 'Mensaje al 988';

  @override
  String get crisisBannerMore => 'Más ayuda';
}
