import 'package:flutter/material.dart';
import 'package:world_hex_map/world_hex_map.dart';

/// Runs the World Hex Map example.
void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      ),
      home: const MapExamplePage(),
    );
  }
}

class MapExamplePage extends StatefulWidget {
  const MapExamplePage({super.key});

  @override
  State<MapExamplePage> createState() => _MapExamplePageState();
}

class _MapExamplePageState extends State<MapExamplePage> {
  int? selectedCellId;

  static final List<WorldHexMarker> _cityMarkers = <WorldHexMarker>[
    WorldHexMarker.fromCoordinates(latitude: 40.7128, longitude: -74.0060),
    WorldHexMarker.fromCoordinates(latitude: 51.5072, longitude: -0.1276),
    WorldHexMarker.fromCoordinates(latitude: 35.6762, longitude: 139.6503),
    WorldHexMarker.fromCoordinates(latitude: -33.8688, longitude: 151.2093),
    WorldHexMarker.fromCoordinates(latitude: -33.9249, longitude: 18.4241),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCellId = this.selectedCellId;
    final markers = <WorldHexMarker>[
      ..._cityMarkers,
      if (selectedCellId != null)
        WorldHexMarker(
          cellId: selectedCellId,
          color: const Color(0xFFF97316),
          scale: 1.6,
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('World Hex Map')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WorldHexMap(
                landColor: const Color(0xFFD0D5DD),
                markerColor: Theme.of(context).colorScheme.primary,
                markers: markers,
                onCellTap: (cellId) {
                  setState(() => this.selectedCellId = cellId);
                },
              ),
              const SizedBox(height: 24),
              Text(
                selectedCellId == null
                    ? 'Tap a land cell'
                    : _selectionLabel(selectedCellId),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectionLabel(int cellId) {
    final center = WorldHexGrid.geographicCenter(cellId);
    return 'Cell $cellId · '
        '${center.latitude.toStringAsFixed(1)}°, '
        '${center.longitude.toStringAsFixed(1)}°';
  }
}
