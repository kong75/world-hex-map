# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-08-29

### Added

- Typed ES module with the same grid and coordinate APIs as Dart.
- Dependency-free SVG renderer for TypeScript, including accessible labels and
  coordinate-based markers.
- Node build, tests, package metadata, and CI coverage.
- Deterministic Flutter preview and visual regression coverage.
- Runnable TypeScript SVG example, architecture notes, and release checklist.

### Changed

- Natural Earth generation now emits matching Dart and TypeScript data files.
- Minimum supported versions are now Dart 3.0 and Flutter 3.10.

## [0.1.0] - 2026-08-29

### Added

- Generated 72 × 47 world land grid with island preservation.
- Coordinate-to-land-cell snapping utilities.
- Customizable Flutter map widget, markers, semantics, and cell taps.
- Reproducible Natural Earth generator, tests, example, and project docs.

[Unreleased]: https://github.com/kong75/world-hex-map/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/kong75/world-hex-map/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/kong75/world-hex-map/releases/tag/v0.1.0
