import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/asset_paths.dart';
import '../constants/dgt_strings.dart';

/// DGT Title types (per-round awards)
enum DGTTitle {
  @JsonValue('velocidad_de_crucero')
  velocidadDeCrucero, // 🟢 Closest to optimal zone

  @JsonValue('multa_por_exceso')
  multaPorExceso, // 🔴 Highest BAC spike

  @JsonValue('l_de_practicas')
  lDePracticas, // 🔰 Lowest BAC in round

  @JsonValue('vehiculo_hibrido')
  vehiculoHibrido, // 🔋 BAC dropped (water)

  @JsonValue('itv_pasada')
  itvPassed, // 🛠️ Same reading twice
}

/// Extension methods for DGTTitle
extension DGTTitleX on DGTTitle {
  /// Get title display name
  String get displayName {
    switch (this) {
      case DGTTitle.velocidadDeCrucero:
        return DGTStrings.titleVelocidadDeCrucero;
      case DGTTitle.multaPorExceso:
        return DGTStrings.titleMultaPorExceso;
      case DGTTitle.lDePracticas:
        return DGTStrings.titleLDePracticas;
      case DGTTitle.vehiculoHibrido:
        return DGTStrings.titleVehiculoHibrido;
      case DGTTitle.itvPassed:
        return DGTStrings.titleITVPassed;
    }
  }

  /// Get title description
  String get description {
    switch (this) {
      case DGTTitle.velocidadDeCrucero:
        return DGTStrings.descVelocidadDeCrucero;
      case DGTTitle.multaPorExceso:
        return DGTStrings.descMultaPorExceso;
      case DGTTitle.lDePracticas:
        return DGTStrings.descLDePracticas;
      case DGTTitle.vehiculoHibrido:
        return DGTStrings.descVehiculoHibrido;
      case DGTTitle.itvPassed:
        return DGTStrings.descITVPassed;
    }
  }

  /// Get title icon/image path
  String get iconPath {
    switch (this) {
      case DGTTitle.velocidadDeCrucero:
        return AssetPaths.titleVelocidadCrucero;
      case DGTTitle.multaPorExceso:
        return AssetPaths.titleMultaExceso;
      case DGTTitle.lDePracticas:
        return AssetPaths.titlePlacaL;
      case DGTTitle.vehiculoHibrido:
        return AssetPaths.titleCocheHibrido;
      case DGTTitle.itvPassed:
        return AssetPaths.titleItvPasada;
    }
  }

  /// Get title emoji
  String get emoji {
    switch (this) {
      case DGTTitle.velocidadDeCrucero:
        return '🟢';
      case DGTTitle.multaPorExceso:
        return '🔴';
      case DGTTitle.lDePracticas:
        return '🔰';
      case DGTTitle.vehiculoHibrido:
        return '🔋';
      case DGTTitle.itvPassed:
        return '🛠️';
    }
  }
}
