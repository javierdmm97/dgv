import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/constants/asset_paths.dart';
import 'package:dgv/features/fake_id/services/license_export_service.dart';

void main() {
  group('LicenseExportService', () {
    test('maps environmental rank to sticker from most to least polluted', () {
      expect(
        LicenseExportService.environmentalPathForTest(0),
        equals(AssetPaths.sinPegatina),
      );
      expect(
        LicenseExportService.environmentalPathForTest(1),
        equals(AssetPaths.pegatinab),
      );
      expect(
        LicenseExportService.environmentalPathForTest(2),
        equals(AssetPaths.pegatinac),
      );
      expect(
        LicenseExportService.environmentalPathForTest(3),
        equals(AssetPaths.pegatinaEco),
      );
      expect(
        LicenseExportService.environmentalPathForTest(4),
        equals(AssetPaths.pegatina0Emisiones),
      );
      expect(LicenseExportService.environmentalPathForTest(5), isNull);
    });
  });
}
