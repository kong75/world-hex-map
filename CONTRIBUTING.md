# Contributing

Thanks for helping improve World Hex Map.

## Before opening a change

- Search existing issues before opening a new one.
- Keep changes focused on the compact world grid, coordinate mapping, Flutter
  widget, generator, documentation, or tests.
- Open an issue first for changes that alter the grid dimensions, geographic
  bounds, source dataset, or cell-selection thresholds.

## Development setup

1. Install the current stable Flutter SDK and Node.js 18 or newer.
2. Run `flutter pub get`.
3. Run `dart format .`.
4. Run `flutter analyze`.
5. Run `flutter test`.

To update the generated land grid, run:

```sh
node tool/generate_world_hex_grid.mjs
```

Include the resulting generated-data change in the same pull request as any
generator change.

## Pull requests

- Add or update tests for behavior changes.
- Update the README and changelog when public behavior changes.
- Keep generated code out of manual edits.
- Confirm formatting, analysis, and tests pass before requesting review.

By contributing, you agree that your contributions will be licensed under the
project's MIT License.
