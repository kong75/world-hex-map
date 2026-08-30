import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'world_hex_grid.dart';

/// A highlighted hex on a [WorldHexMap].
@immutable
final class WorldHexMarker {
  /// Creates a marker for an existing grid cell.
  const WorldHexMarker({
    required this.cellId,
    this.color,
    this.borderColor,
    this.scale = 1.35,
  }) : assert(scale > 0);

  /// Creates a marker snapped to the nearest land cell.
  factory WorldHexMarker.fromCoordinates({
    required double latitude,
    required double longitude,
    Color? color,
    Color? borderColor,
    double scale = 1.35,
  }) {
    return WorldHexMarker(
      cellId: WorldHexGrid.nearestLandCell(
        latitude: latitude,
        longitude: longitude,
      ),
      color: color,
      borderColor: borderColor,
      scale: scale,
    );
  }

  /// Grid cell drawn by this marker.
  final int cellId;

  /// Marker fill, or the map's default marker color when null.
  final Color? color;

  /// Marker outline, or the map's default marker border when null.
  final Color? borderColor;

  /// Marker size relative to a regular land cell.
  final double scale;
}

/// A lightweight world silhouette rendered from hexagonal land cells.
///
/// The widget has no map SDK or network requirement. Supply [markers] to
/// highlight grid cells, or use [WorldHexMarker.fromCoordinates] to snap
/// latitude and longitude values to the map.
class WorldHexMap extends StatelessWidget {
  /// Creates a world hex map.
  const WorldHexMap({
    super.key,
    this.landColor = const Color(0xFFD0D5DD),
    this.backgroundColor = Colors.transparent,
    this.markerColor = const Color(0xFF2563EB),
    this.markerBorderColor = Colors.white,
    this.markers = const <WorldHexMarker>[],
    this.cellScale = 0.78,
    this.padding = EdgeInsets.zero,
    this.onCellTap,
    this.semanticsLabel = 'World hex map',
  }) : assert(cellScale > 0 && cellScale <= 1);

  /// Color used for unmarked land cells.
  final Color landColor;

  /// Color painted behind the map.
  final Color backgroundColor;

  /// Default fill used by markers without their own color.
  final Color markerColor;

  /// Default outline used by markers without their own border color.
  final Color markerBorderColor;

  /// Cells highlighted above the land silhouette.
  final List<WorldHexMarker> markers;

  /// Size of each land hex relative to the available grid spacing.
  final double cellScale;

  /// Space between the widget boundary and the map silhouette.
  final EdgeInsets padding;

  /// Called with the tapped land-cell ID.
  final ValueChanged<int>? onCellTap;

  /// Accessibility label for the map.
  final String semanticsLabel;

  /// Width-to-height ratio of the generated map grid.
  static const double aspectRatio = 1.78;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticsLabel,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final layout = _WorldHexLayout(size, padding);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: onCellTap == null
                  ? null
                  : (details) {
                      final cellId = layout.cellAt(details.localPosition);
                      if (cellId != null) onCellTap!(cellId);
                    },
              child: ColoredBox(
                color: backgroundColor,
                child: CustomPaint(
                  painter: _WorldHexMapPainter(
                    cellScale: cellScale,
                    landColor: landColor,
                    layout: layout,
                    markerBorderColor: markerBorderColor,
                    markerColor: markerColor,
                    markers: markers,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _WorldHexMapPainter extends CustomPainter {
  const _WorldHexMapPainter({
    required this.cellScale,
    required this.landColor,
    required this.layout,
    required this.markerBorderColor,
    required this.markerColor,
    required this.markers,
  });

  final double cellScale;
  final Color landColor;
  final _WorldHexLayout layout;
  final Color markerBorderColor;
  final Color markerColor;
  final List<WorldHexMarker> markers;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = layout.cellRadius * cellScale;
    final landPath = Path();
    for (final cellId in WorldHexGrid.landCellIds) {
      _addHex(landPath, layout.cellCenter(cellId), radius);
    }
    canvas.drawPath(
      landPath,
      Paint()
        ..color = landColor
        ..style = PaintingStyle.fill,
    );

    for (final marker in markers) {
      if (!WorldHexGrid.isLandCell(marker.cellId)) continue;
      final path = Path();
      _addHex(path, layout.cellCenter(marker.cellId), radius * marker.scale);
      canvas
        ..drawPath(
          path,
          Paint()
            ..color = marker.color ?? markerColor
            ..style = PaintingStyle.fill,
        )
        ..drawPath(
          path,
          Paint()
            ..color = marker.borderColor ?? markerBorderColor
            ..strokeWidth = math.max(1, radius * 0.28)
            ..style = PaintingStyle.stroke,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _WorldHexMapPainter oldDelegate) {
    return oldDelegate.cellScale != cellScale ||
        oldDelegate.landColor != landColor ||
        oldDelegate.layout != layout ||
        oldDelegate.markerBorderColor != markerBorderColor ||
        oldDelegate.markerColor != markerColor ||
        !listEquals(oldDelegate.markers, markers);
  }
}

@immutable
final class _WorldHexLayout {
  const _WorldHexLayout(this.size, this.padding);

  final EdgeInsets padding;
  final Size size;

  Rect get mapRect {
    final available = padding.deflateRect(Offset.zero & size);
    if (available.isEmpty) return Rect.zero;

    final availableAspectRatio = available.width / available.height;
    if (availableAspectRatio > WorldHexMap.aspectRatio) {
      final width = available.height * WorldHexMap.aspectRatio;
      return Rect.fromLTWH(
        available.left + (available.width - width) / 2,
        available.top,
        width,
        available.height,
      );
    }

    final height = available.width / WorldHexMap.aspectRatio;
    return Rect.fromLTWH(
      available.left,
      available.top + (available.height - height) / 2,
      available.width,
      height,
    );
  }

  double get cellRadius {
    final rect = mapRect;
    if (rect.isEmpty) return 0;
    final horizontalStep = rect.width / (WorldHexGrid.columns - 0.5);
    final verticalStep = rect.height / (WorldHexGrid.rows - 1);
    return math.min(horizontalStep / 1.9, verticalStep / 1.66);
  }

  Offset cellCenter(int cellId) {
    final rect = mapRect;
    final normalized = WorldHexGrid.normalizedCenter(cellId);
    return Offset(
      rect.left + normalized.x * rect.width,
      rect.top + normalized.y * rect.height,
    );
  }

  int? cellAt(Offset point) {
    final radius = cellRadius;
    if (radius <= 0) return null;

    int? closestCell;
    var closestDistanceSquared = double.infinity;
    for (final cellId in WorldHexGrid.landCellIds) {
      final center = cellCenter(cellId);
      final distanceSquared = (point - center).distanceSquared;
      if (distanceSquared < closestDistanceSquared) {
        closestCell = cellId;
        closestDistanceSquared = distanceSquared;
      }
    }
    if (closestDistanceSquared > radius * radius) return null;
    return closestCell;
  }

  @override
  bool operator ==(Object other) {
    return other is _WorldHexLayout &&
        other.size == size &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(size, padding);
}

void _addHex(Path path, Offset center, double radius) {
  for (var index = 0; index < 6; index++) {
    final angle = math.pi / 3 * index;
    final point = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    if (index == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  path.close();
}
