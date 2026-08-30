import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_hex_map/world_hex_map.dart';

void main() {
  testWidgets('renders markers and exposes map semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 720,
            child: WorldHexMap(
              semanticsLabel: 'Locations around the world',
              markers: <WorldHexMarker>[
                WorldHexMarker.fromCoordinates(
                  latitude: 40.7128,
                  longitude: -74.0060,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(WorldHexMap), findsOneWidget);
    expect(find.bySemanticsLabel('Locations around the world'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reports the tapped land cell', (tester) async {
    int? tappedCellId;
    final londonCellId = WorldHexGrid.nearestLandCell(
      latitude: 51.5072,
      longitude: -0.1276,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 720,
            child: WorldHexMap(onCellTap: (cellId) => tappedCellId = cellId),
          ),
        ),
      ),
    );

    final rect = tester.getRect(find.byType(WorldHexMap));
    final center = WorldHexGrid.normalizedCenter(londonCellId);
    await tester.tapAt(
      Offset(
        rect.left + center.x * rect.width,
        rect.top + center.y * rect.height,
      ),
    );
    await tester.pump();

    expect(tappedCellId, londonCellId);
  });
}
