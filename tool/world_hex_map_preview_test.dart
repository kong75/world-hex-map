import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_hex_map/world_hex_map.dart';

const _canvasSize = Size(1440, 810);
const _logicalSize = Size(720, 405);
const _scale = 2.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the deterministic package preview', (tester) async {
    tester.view.physicalSize = _canvasSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
      disableAnimations: true,
      reduceMotion: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final captureKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ColoredBox(
            color: const Color(0xFFF8FAFC),
            child: Align(
              alignment: Alignment.topLeft,
              child: Transform.scale(
                scale: _scale,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: _logicalSize.width,
                  height: _logicalSize.height,
                  child: WorldHexMap(
                    backgroundColor: const Color(0xFFF8FAFC),
                    landColor: const Color(0xFFCBD5E1),
                    markerColor: const Color(0xFF2563EB),
                    markerBorderColor: Colors.white,
                    padding: const EdgeInsets.all(22),
                    markers: <WorldHexMarker>[
                      WorldHexMarker.fromCoordinates(
                        latitude: 40.7128,
                        longitude: -74.0060,
                      ),
                      WorldHexMarker.fromCoordinates(
                        latitude: 51.5072,
                        longitude: -0.1276,
                      ),
                      WorldHexMarker.fromCoordinates(
                        latitude: 35.6762,
                        longitude: 139.6503,
                        color: const Color(0xFFE11D48),
                      ),
                      WorldHexMarker.fromCoordinates(
                        latitude: -33.8688,
                        longitude: 151.2093,
                      ),
                      WorldHexMarker.fromCoordinates(
                        latitude: -33.9249,
                        longitude: 18.4241,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(captureKey),
      matchesGoldenFile('../doc/assets/world_hex_map_preview.png'),
    );
  });
}
