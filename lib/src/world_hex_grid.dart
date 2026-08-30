import 'world_hex_grid_data.dart';

/// A point in the map's normalized coordinate space.
///
/// Both `x` and `y` range from 0 to 1, with `(0, 0)` at the top-left.
typedef NormalizedMapPoint = ({double x, double y});

/// A geographic point expressed in decimal degrees.
typedef GeographicPoint = ({double latitude, double longitude});

/// Utilities and generated data for the built-in world hex grid.
///
/// The grid is an intentionally compact visual representation rather than a
/// GIS indexing system. It works well for dashboards, collection maps, and
/// other interfaces that need a recognizable world silhouette at small sizes.
abstract final class WorldHexGrid {
  /// Number of columns in the generated grid.
  static const int columns = WorldHexGridData.columns;

  /// Number of rows in the generated grid.
  static const int rows = WorldHexGridData.rows;

  /// Northern latitude represented by the grid.
  static const double north = WorldHexGridData.north;

  /// Southern latitude represented by the grid.
  static const double south = WorldHexGridData.south;

  /// IDs of cells selected as land by the generator.
  static const List<int> landCellIds = WorldHexGridData.landCellIds;

  static final Set<int> _landCellIdSet = landCellIds.toSet();

  /// Returns whether [cellId] is part of the land silhouette.
  static bool isLandCell(int cellId) => _landCellIdSet.contains(cellId);

  /// Returns the ID at [row] and [column].
  static int cellId({required int row, required int column}) {
    RangeError.checkValueInInterval(row, 0, rows - 1, 'row');
    RangeError.checkValueInInterval(column, 0, columns - 1, 'column');
    return row * columns + column;
  }

  /// Returns the row containing [cellId].
  static int rowOf(int cellId) {
    _checkCellId(cellId);
    return cellId ~/ columns;
  }

  /// Returns the column containing [cellId].
  static int columnOf(int cellId) {
    _checkCellId(cellId);
    return cellId % columns;
  }

  /// Returns the normalized center of [cellId].
  static NormalizedMapPoint normalizedCenter(int cellId) {
    _checkCellId(cellId);
    final row = rowOf(cellId);
    final column = columnOf(cellId);
    return (
      x: (column + (row.isOdd ? 0.5 : 0.0)) / (columns - 0.5),
      y: row / (rows - 1),
    );
  }

  /// Returns the approximate geographic center of [cellId].
  static GeographicPoint geographicCenter(int cellId) {
    final center = normalizedCenter(cellId);
    return (
      latitude: north - center.y * (north - south),
      longitude: center.x * 360 - 180,
    );
  }

  /// Returns the closest land cell to a geographic coordinate.
  ///
  /// Coordinates outside the visible latitude range are clamped to the
  /// nearest row. Inputs must still be valid finite WGS84 coordinates.
  static int nearestLandCell({
    required double latitude,
    required double longitude,
  }) {
    _checkCoordinate(latitude, -90, 90, 'latitude');
    _checkCoordinate(longitude, -180, 180, 'longitude');

    final targetX = ((longitude + 180) / 360).clamp(0.0, 1.0);
    final targetY = ((north - latitude) / (north - south)).clamp(0.0, 1.0);
    final targetRow = targetY * (rows - 1);
    final targetColumn = targetX * (columns - 0.5);
    final estimatedRow = targetRow.round().clamp(0, rows - 1);

    int? bestCellId;
    var bestDistanceSquared = double.infinity;

    for (var row = estimatedRow - 3; row <= estimatedRow + 3; row++) {
      if (row < 0 || row >= rows) continue;
      final estimatedColumn = (targetColumn - (row.isOdd ? 0.5 : 0.0)).round();
      for (var column = estimatedColumn - 3;
          column <= estimatedColumn + 3;
          column++) {
        if (column < 0 || column >= columns) continue;
        final candidate = cellId(row: row, column: column);
        if (!isLandCell(candidate)) continue;
        final distanceSquared = _gridDistanceSquared(
          candidate,
          targetRow,
          targetColumn,
        );
        if (distanceSquared < bestDistanceSquared) {
          bestCellId = candidate;
          bestDistanceSquared = distanceSquared;
        }
      }
    }

    if (bestCellId != null) return bestCellId;

    for (final candidate in landCellIds) {
      final distanceSquared = _gridDistanceSquared(
        candidate,
        targetRow,
        targetColumn,
      );
      if (distanceSquared < bestDistanceSquared) {
        bestCellId = candidate;
        bestDistanceSquared = distanceSquared;
      }
    }
    return bestCellId!;
  }

  static double _gridDistanceSquared(
    int cellId,
    double targetRow,
    double targetColumn,
  ) {
    final row = cellId ~/ columns;
    final column = cellId % columns;
    final columnCenter = column + (row.isOdd ? 0.5 : 0.0);
    final dx = columnCenter - targetColumn;
    final dy = row - targetRow;
    return dx * dx + dy * dy;
  }

  static void _checkCellId(int cellId) {
    RangeError.checkValueInInterval(cellId, 0, rows * columns - 1, 'cellId');
  }

  static void _checkCoordinate(
    double value,
    double minimum,
    double maximum,
    String name,
  ) {
    if (!value.isFinite || value < minimum || value > maximum) {
      throw RangeError.value(
        value,
        name,
        'Must be finite and between $minimum and $maximum.',
      );
    }
  }
}
