import 'package:flutter_test/flutter_test.dart';
import 'package:world_hex_map/world_hex_map.dart';

void main() {
  test('generated world grid contains valid unique land cells', () {
    expect(WorldHexGrid.landCellIds, hasLength(1141));
    expect(
      WorldHexGrid.landCellIds.toSet().length,
      WorldHexGrid.landCellIds.length,
    );

    const maximumCellId = WorldHexGrid.columns * WorldHexGrid.rows;
    for (final cellId in WorldHexGrid.landCellIds) {
      expect(cellId, inInclusiveRange(0, maximumCellId - 1));
      final center = WorldHexGrid.normalizedCenter(cellId);
      expect(center.x, inInclusiveRange(0.0, 1.0));
      expect(center.y, inInclusiveRange(0.0, 1.0));
    }
  });

  test('narrow islands retain nearby cells at compact resolution', () {
    const islandAnchors = <GeographicPoint>[
      (latitude: 43.0618, longitude: 141.3545),
      (latitude: 35.6762, longitude: 139.6503),
      (latitude: 64.1466, longitude: -21.9426),
      (latitude: 21.3069, longitude: -157.8583),
      (latitude: -41.2866, longitude: 174.7756),
      (latitude: 14.5995, longitude: 120.9842),
    ];

    for (final anchor in islandAnchors) {
      final cellId = WorldHexGrid.nearestLandCell(
        latitude: anchor.latitude,
        longitude: anchor.longitude,
      );
      final center = WorldHexGrid.geographicCenter(cellId);
      expect(
        (center.longitude - anchor.longitude).abs(),
        lessThan(3.8),
        reason: 'No nearby land cell for $anchor',
      );
      expect(
        (center.latitude - anchor.latitude).abs(),
        lessThan(2.3),
        reason: 'No nearby land cell for $anchor',
      );
    }
  });

  test('Japan remains visually separated from the Asian mainland', () {
    expect(
      WorldHexGrid.isLandCell(WorldHexGrid.cellId(row: 13, column: 62)),
      isTrue,
    );
    expect(
      WorldHexGrid.isLandCell(WorldHexGrid.cellId(row: 13, column: 63)),
      isFalse,
    );
    expect(
      WorldHexGrid.isLandCell(WorldHexGrid.cellId(row: 13, column: 64)),
      isTrue,
    );
  });

  test('major-city coordinates snap to nearby land cells', () {
    const places = <GeographicPoint>[
      (latitude: 40.7128, longitude: -74.0060),
      (latitude: 51.5072, longitude: -0.1276),
      (latitude: 35.6762, longitude: 139.6503),
      (latitude: -33.8688, longitude: 151.2093),
      (latitude: -33.9249, longitude: 18.4241),
    ];

    for (final place in places) {
      final cellId = WorldHexGrid.nearestLandCell(
        latitude: place.latitude,
        longitude: place.longitude,
      );
      expect(WorldHexGrid.isLandCell(cellId), isTrue);
    }
  });

  test('invalid coordinates and cell indexes are rejected', () {
    expect(
      () => WorldHexGrid.nearestLandCell(latitude: 91, longitude: 0),
      throwsRangeError,
    );
    expect(
      () => WorldHexGrid.nearestLandCell(latitude: 0, longitude: 181),
      throwsRangeError,
    );
    expect(() => WorldHexGrid.normalizedCenter(-1), throwsRangeError);
  });
}
