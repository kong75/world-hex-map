# Contributing

Thanks for helping improve World Hex Map.

Read [`ARCHITECTURE.md`](ARCHITECTURE.md) before changing shared grid behavior.

## Before opening a change

- Search existing issues before opening a new one.
- Keep changes focused on the compact world grid, coordinate mapping, Flutter
  widget, TypeScript API and renderer, generator, documentation, or tests.
- Open an issue first for changes that alter the grid dimensions, geographic
  bounds, source dataset, or cell-selection thresholds.

## Development setup

1. Install the current stable Flutter SDK and Node.js 18 or newer.
2. Run `flutter pub get`.
3. Run `npm ci`.
4. Run `dart format .`.
5. Run `flutter analyze`.
6. Run `flutter test`.
7. Run `npm run check`.

To verify the checked-in visual preview, run:

```sh
flutter test tool/world_hex_map_preview_test.dart
```

When an intentional visual change is approved, regenerate it once with
`flutter test --update-goldens tool/world_hex_map_preview_test.dart`, inspect
the PNG, and rerun the test without `--update-goldens`.

To update the generated land grid, run:

```sh
node tool/generate_world_hex_grid.mjs
```

Include both resulting generated-data changes in the same pull request as any
generator change. Do not edit either generated data file manually.

## Pull requests

- Add or update tests for behavior changes.
- Keep the Dart and TypeScript grid APIs behaviorally aligned.
- Include visual regression updates for intentional rendering changes.
- Update the README and changelog when public behavior changes.
- Keep generated code out of manual edits.
- Confirm formatting, analysis, and tests pass before requesting review.

By contributing, you agree that your contributions will be licensed under the
project's MIT License.
