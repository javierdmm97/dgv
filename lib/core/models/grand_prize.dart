import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/dgt_strings.dart';

/// Grand Prize types (end-of-game awards)
enum GrandPrizeType {
  @JsonValue('conductor_perfecto')
  conductorPerfecto, // 🏆 Highest points + never crossed line

  @JsonValue('precision_absoluta')
  precisionAbsoluta, // 🎯 Closest average to optimal zone

  @JsonValue('coleccionista_titulos')
  coleccionistaTitulos, // 👑 Most DGT titles accumulated
}

/// Extension methods for GrandPrizeType
extension GrandPrizeTypeX on GrandPrizeType {
  /// Get prize display name
  String get displayName {
    switch (this) {
      case GrandPrizeType.conductorPerfecto:
        return DGTStrings.conductorPerfecto;
      case GrandPrizeType.precisionAbsoluta:
        return DGTStrings.precisionAbsoluta;
      case GrandPrizeType.coleccionistaTitulos:
        return DGTStrings.coleccionistaTitulos;
    }
  }

  /// Get prize description
  String get description {
    switch (this) {
      case GrandPrizeType.conductorPerfecto:
        return DGTStrings.descConductorPerfecto;
      case GrandPrizeType.precisionAbsoluta:
        return DGTStrings.descPrecisionAbsoluta;
      case GrandPrizeType.coleccionistaTitulos:
        return DGTStrings.descColeccionistaTitulos;
    }
  }

  /// Get prize emoji
  String get emoji {
    switch (this) {
      case GrandPrizeType.conductorPerfecto:
        return '🏆';
      case GrandPrizeType.precisionAbsoluta:
        return '🎯';
      case GrandPrizeType.coleccionistaTitulos:
        return '👑';
    }
  }
}
