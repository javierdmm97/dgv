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
    title: 'La DGV recomienda beber agua entre copas',
    summary:
        'El organismo publica una guía de buenas prácticas para conductores responsables.',
    body:
        'La Dirección General de Vitis ha publicado hoy una revolucionaria guía '
        'en la que recomienda alternar bebidas alcohólicas con agua. '
        '"Es fundamental mantenerse hidratado para una experiencia óptima", '
        'declaró el portavoz de la institución. La guía incluye tablas de '
        'referencia y consejos prácticos para cada complexión corporal.',
    date: '15 Jun 2025',
    imagePath: '',
  ),
  FakeNewsArticle(
    id: 'fn_002',
    title: 'Nuevo radar detecta niveles de diversión',
    summary:
        'La tecnología DGV-Scan mide en tiempo real el índice de buen rollo de los conductores.',
    body:
        'La DGV ha presentado el DGV-Scan, un dispositivo capaz de medir el '
        'nivel de diversión de cualquier conductor en menos de dos segundos. '
        '"Si el índice baja de 7, el sistema emite una alerta automática", '
        'explicó la directora de innovación. El aparato ya está operativo '
        'en varios controles piloto de la capital.',
    date: '10 Jun 2025',
    imagePath: '',
  ),
  FakeNewsArticle(
    id: 'fn_003',
    title: 'Multa de 200€ por no disfrutar lo suficiente',
    summary:
        'La nueva normativa obliga a los conductores a mantener un mínimo de alegría.',
    body:
        'El Boletín Oficial del Estado ha publicado hoy la Orden DGV/2025/42, '
        'que establece una sanción de 200 euros para aquellos conductores cuyo '
        'índice de diversión sea inferior al mínimo reglamentario. '
        'Las asociaciones de consumidores han mostrado su apoyo unánime '
        'a la medida, calificándola de "necesaria y justa".',
    date: '5 Jun 2025',
    imagePath: '',
  ),
  FakeNewsArticle(
    id: 'fn_004',
    title: 'Campaña especial: "Si bebes, bebe con cabeza"',
    summary:
        'La DGV lanza su campaña más ambiciosa para promover el consumo responsable.',
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
    id: 'fn_005',
    title: 'Récord histórico de conductores responsables',
    summary:
        'El último control DGV registra el mayor porcentaje de tasas óptimas de la historia.',
    body:
        'El pasado fin de semana se registró un hito histórico: el 94% de los '
        'conductores sometidos a control DGV presentaron tasas dentro de la '
        'zona óptima. "Nunca habíamos visto cifras así", declaró emocionado '
        'el inspector jefe. Los expertos atribuyen el éxito a la popularidad '
        'creciente de la aplicación Operación DGV.',
    date: '28 May 2025',
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
  static const String titleMultaPorExceso = 'Multa por Exceso';
  static const String titleLDePracticas = 'L de Prácticas';
  static const String titleVehiculoHibrido = 'Vehículo Híbrido';
  static const String titleITVPassed = 'ITV Pasada';

  // Title Descriptions
  static const String descVelocidadDeCrucero = 'Más cerca de la zona óptima';
  static const String descMultaPorExceso = 'Mayor subida de tasa';
  static const String descLDePracticas = 'Tasa más baja de la ronda';
  static const String descVehiculoHibrido = 'Bajo la tasa (agua enjoyer)';
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
