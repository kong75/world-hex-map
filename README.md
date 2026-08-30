# World Hex Map

A lightweight, offline world hex map for Flutter and Dart. It includes a
generated land grid, latitude/longitude-to-cell snapping, island-aware
coverage, and a customizable Flutter widget without a map SDK or runtime
network dependency.

## Features

- Recognizable 72 × 47 world silhouette with 1,141 land cells
- Offline rendering with no tile server, API key, or map SDK
- Latitude and longitude snapping to the nearest land cell
- Custom colors, markers, spacing, padding, semantics, and tap handling
- Reproducible generator pinned to Natural Earth source data
- Small, dependency-light Flutter package

## Installation

Add the repository as a Git dependency:

```yaml
dependencies:
  world_hex_map:
    git:
      url: https://github.com/kong75/world-hex-map.git
```

Then fetch packages:

```sh
flutter pub get
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:world_hex_map/world_hex_map.dart';

WorldHexMap(
  landColor: const Color(0xFFD0D5DD),
  markerColor: const Color(0xFF2563EB),
  markers: <WorldHexMarker>[
    WorldHexMarker.fromCoordinates(
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    WorldHexMarker.fromCoordinates(
      latitude: 35.6762,
      longitude: 139.6503,
    ),
  ],
  onCellTap: (cellId) {
    final center = WorldHexGrid.geographicCenter(cellId);
    debugPrint('${center.latitude}, ${center.longitude}');
  },
)
```

To use the grid without rendering the widget:

```dart
final cellId = WorldHexGrid.nearestLandCell(
  latitude: 51.5072,
  longitude: -0.1276,
);

final normalizedCenter = WorldHexGrid.normalizedCenter(cellId);
```

See [`example/lib/main.dart`](example/lib/main.dart) for a complete app.

## How the grid is generated

The generator samples pinned Natural Earth 1:10m land polygons against a
staggered hex grid. Area-aware supersampling keeps the coastline recognizable,
while a second pass preserves representative cells for islands that would
otherwise disappear at this resolution.

Regenerate the checked-in Dart data with Node.js and the Dart SDK available:

```sh
node tool/generate_world_hex_grid.mjs
```

The generated file is committed so applications never need network access at
runtime.

## Scope and accuracy

World Hex Map is a compact visualization, not a GIS index, navigation system,
or authoritative boundary dataset. Coordinates are snapped to the nearest
visual land cell. Antarctica is intentionally outside the map's displayed
latitude range.

## Data source

The generator uses [Natural Earth](https://www.naturalearthdata.com/) 1:10m
land polygons. Natural Earth data is public domain. See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for the pinned revision and
source details.

## Contributing

Issues and pull requests are welcome. Read [`CONTRIBUTING.md`](CONTRIBUTING.md)
before submitting a change.

## License

World Hex Map is available under the [MIT License](LICENSE).
