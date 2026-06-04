/// A satirical fake news article for the DGV app.
class FakeNewsArticle {
  const FakeNewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.date,
    required this.imagePath,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String date;
  final String imagePath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakeNewsArticle &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Static list of satirical fake news articles.
const List<FakeNewsArticle> kFakeNewsArticles = [
  FakeNewsArticle(
    id: 'fn_001',
    title: 'La DGV recomienda el consumo de puros al volante',
    summary:
        'El organismo publica una guía de buenas prácticas para la fumasión.',
    body:
        'La Dirección General de Vitis ha publicado hoy una revolucionaria guía '
        'en la que recomienda el consumo excesivo de puros. '
        '"Es fundamental mantenerse fumado para una experiencia óptima tabaquera", '
        'declaró el portavoz de la institución. La guía incluye tablas de '
        'comparación de diferentes puros cubanos y consejos para el corte del puro.',
    date: '3 Jun 2026',
    imagePath: '',
  ),
  FakeNewsArticle(
    id: 'fn_002',
    title:
        'Nuevo radar detecta a Yisus a mas de 200 km/h entrando a Casa Vitis',
    summary:
        'La tecnología DGV-Scan pilla al madrileño ebrio sobrepasando el limite de velocidad.',
    body:
        'La DGV ha impuesto carcel preventiva para el conductor y la retirada del carnet '
        'con una multa de 4 cervezas a lo largo del dia de hoy. '
        '"Se me habia olvidado los ingredientes de la carbonara", '
        'declaró el susodicho tras su detención. El cubocoche ya esta incautado '
        'y las cervezas de la multa enfriandose.',
    date: '5 Jun 2026',
    imagePath: '',
  ),
  FakeNewsArticle(
    id: 'fn_003',
    title: '4 consejos para la subasta de la semana',
    summary: 'Si no te quieres quedar sin premio atento a nuestros Briconsejos',
    body:
        'Ante la gran puja de mañana, la Dirección General de Vitis recuerda que lo que pasa hoy en el '
        'alcoholímetro define tu billetera de mañana. Cada vez que cruzas la línea, la DGV te endiña '
        'una multa de 100 EstreDólares que van directos a mermar tu presupuesto de puja. '
        'Para evitar la ruina, los expertos de Casa Vitis dejan 4 Briconsejos clave: '
        '1. Mantente en la zona óptima: ganar los controles te hincha la cuenta corriente de dinero fresco. '
        '2. Ojo con los picos peligrosos: una mala racha hoy y mañana verás la subasta desde la barrera. '
        '3. Calcula tu resistencia: más vale coche inmovilizado a tiempo que bancarrota total. '
        '4. Recuerda la Orden DGV/2025/42: la diversión es obligatoria, pero las tasas descontroladas se pagan '
        'caras. ¡Asegura tus EstreDólares hoy para reventar el mercado mañana!',
    date: '4 Jun 2026',
    imagePath: '',
  ),
  FakeNewsArticle(
    id: 'fn_004',
    title: 'Campaña especial: "Si bebes, bebela fria"',
    summary:
        'La DGV lanza su campaña más ambiciosa para promover el consumo de cerveza fria.',
    body:
        'Con el lema "Si bebes, bebe con cabeza", la DGV ha iniciado una '
        'campaña de concienciación que incluye anuncios en televisión, '
        'vallas publicitarias y un musical de Broadway. '
        '"Queremos que cada conductor llegue a la zona óptima sin pasarse", '
        'afirmó el director general en rueda de prensa.',
    date: '1 Jun 2025',
    imagePath: '',
  ),
  FakeNewsArticle(
    id: 'fn_006',
    title: 'Miguel Escudero tumba al gigante tecnológico BackMarket',
    summary:
        'El conductor madrileño logra que le devuelvan más de 500 EstreDólares tras dos años de uso alegando errores de custodia.',
    body:
        'Histórico precedente en los tribunales de la DGV. El ciudadano Miguel Escudero, '
        'tras exprimir su iPhone durante dos años en diversos controles sorpresas, '
        'abrió un caso de incidencia el último día de garantía. Ante la negativa de la '
        'plataforma Back Market, que alegaba discrepancias con el IMEI, Escudero desplegó '
        'una "chapa legal" redactada por Inteligencia Artificial que ha hecho temblar al sector. '
        'Citando la Ley de Defensa de los Consumidores y amenazando con elevar la queja a la OMIC, '
        'a la Comisión Europea y a los Cuerpos de Seguridad por "apropiación indebida", '
        'el vendedor ecomobile claudicó de inmediato. El resultado: más de 500 pavos '
        'directos a su cuenta para la subasta de mañana. "Cualquier error en sus almacenes '
        'es fallo de su cadena de custodia", declaró el héroe local mientras se tomaba una fría.',
    date: '30 May 2026',
    imagePath: '',
  ),
];

/// Spanish DGT-themed strings
class DGTStrings {
  DGTStrings._();

  // App Name
  static const String appName = 'Operación DGV';
  static const String appSubtitle = 'Dirección General de Vitis';

  // Main Menu
  static const String mainMenuTitle = 'DGV';
  static const String startGame = 'Iniciar Control';
  static const String resumeGame = 'Continuar Control';
  static const String addPlayer = 'Añadir Conductor';
  static const String myVehicles = 'MIS VEHÍCULOS';
  static const String actualidadDGV = 'ACTUALIDAD DGV';

  // Player Registration
  static const String registrationTitle = 'Registro de Conductor';
  static const String enterName = 'Nombre';
  static const String enterSurname = 'Apellidos';
  static const String selectSex = 'Sexo';
  static const String male = 'Hombre';
  static const String female = 'Mujer';
  static const String selectBodySize = 'Complexión';
  static const String bodySmall = 'Pequeña';
  static const String bodyMedium = 'Media';
  static const String bodyLarge = 'Grande';
  static const String takePhoto = 'Foto para Carnet';
  static const String confirmRegistration = 'Confirmar Registro';

  // Breathalyzer
  static const String breathalyzerTitle = 'Control de Alcoholemia';
  static const String enterBAC = 'Introducir Tasa';
  static const String scanBAC = 'Escanear con Cámara';
  static const String roundRobin = 'El Retén';
  static const String bacFormat = '0.XX mg/L'; // Breathalyzer format
  static const String bacFormatExample = 'Ejemplo: 0.25';
  static const String confirm = 'Confirmar';
  static const String cancel = 'Cancelar';

  // Checkpoint
  static const String checkpointTitle = 'Control Sorpresa';
  static const String nextCheckpoint = 'Próximo Control';
  static const String timeRemaining = 'Tiempo Restante';
  static const String measuring = 'Midiendo...';
  static const String groupProgress = 'Grupo {current} de {total}';
  static const String playersProgress = '{current}/{total} conductores medidos';

  // Feedback Messages
  static const String feedbackInZone = '¡En la zona óptima!';
  static const String feedbackClose = 'Cerca del óptimo';
  static const String feedbackCrossedLine = '¡Has cruzado la línea!';
  static const String feedbackDangerousSpike = '¡Subida peligrosa!';
  static const String feedbackTooLow = 'Demasiado bajo';
  static const String feedbackImpounded = '¡VEHÍCULO INMOVILIZADO!';
  static const String pointsGained = '+{points} puntos';
  static const String pointsLost = '{points} puntos';
  static const String readingRecorded = 'Lectura registrada';

  // DGT Titles
  static const String titleVelocidadDeCrucero = 'Velocidad de Crucero';
  static const String titleMultaPorExceso = 'Vas en (de) cabeza';
  static const String titleLDePracticas = 'L de Prácticas';
  static const String titleVehiculoHibrido = 'El favorito de la DGV';
  static const String titleITVPassed = 'ITV Pasada';

  // Title Descriptions
  static const String descVelocidadDeCrucero = 'Más cerca de la zona óptima';
  static const String descMultaPorExceso = 'Tasa más alta de la ronda';
  static const String descLDePracticas = 'Tasa más baja de la ronda';
  static const String descVehiculoHibrido =
      'Bebe con responsabilidad (o no bebe)';
  static const String descITVPassed = 'Misma lectura dos veces';

  // Leaderboard
  static const String leaderboardTitle = 'Carnet por Puntos';
  static const String points = 'puntos';
  static const String optimalZone = 'Zona óptima';
  static const String viewLicense = 'Ver Carnet';
  static const String position = 'Posición';

  // Grand Prizes
  static const String grandPrizesTitle = 'Premios Finales';
  static const String conductorPerfecto = 'El Conductor Perfecto';
  static const String precisionAbsoluta = 'Precisión Absoluta';
  static const String coleccionistaTitulos = 'Coleccionista de Títulos';
  static const String environmentalDistinctive = 'Distintivo Ambiental';

  // Grand Prize Descriptions
  static const String descConductorPerfecto = 'Más puntos sin cruzar la línea';
  static const String descPrecisionAbsoluta =
      'Promedio más cercano a zona óptima';
  static const String descColeccionistaTitulos = 'Más títulos DGT acumulados';
  static const String descEnvironmentalDistinctive = 'Top 5 tasas más altas';

  // Final Report
  static const String finalReportTitle = 'Informe Final';
  static const String totalRounds = 'Rondas Totales';
  static const String averageBAC = 'Tasa Media';
  static const String maxBAC = 'Tasa Máxima';
  static const String titlesEarned = 'Títulos Conseguidos';
  static const String finishGame = 'Finalizar Control';
  static const String viewAllLicenses = 'Ver Todos los Carnets';
  static const String shareResults = 'Compartir Resultados';
  static const String returnToMenu = 'Volver al Menú';

  // Errors
  static const String errorGeneric = 'Ha ocurrido un error';
  static const String errorNoPlayers = 'No hay conductores registrados';
  static const String errorInvalidBAC = 'Tasa inválida';
  static const String errorCameraPermission = 'Permiso de cámara denegado';
  static const String errorOCRFailed = 'No se pudo leer la tasa';

  // Dialogs
  static const String confirmFinishGame = '¿Finalizar el control?';
  static const String confirmFinishGameMessage =
      'Se mostrarán los resultados finales y premios.';
  static const String confirmDeletePlayer = '¿Eliminar conductor?';
  static const String confirmDeletePlayerMessage =
      'Esta acción no se puede deshacer.';
  static const String yes = 'Sí';
  static const String no = 'No';

  // Fake News Headlines (satirical)
  static const List<String> fakeNewsHeadlines = [
    'La DGV recomienda beber agua entre copas',
    'Nuevo radar detecta niveles de diversión',
    'Multa de 200€ por no disfrutar lo suficiente',
    'Campaña especial: "Si bebes, bebe con cabeza"',
    'Récord histórico de conductores responsables',
  ];

  // Fake Error Messages
  static const String fakeError1 = 'Error 404: Diversión no encontrada';
  static const String fakeError2 = 'Advertencia: Nivel de fiesta bajo';
  static const String fakeError3 = 'Sistema sobrecargado de buen rollo';
}
