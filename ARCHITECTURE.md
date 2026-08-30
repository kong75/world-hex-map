# Architecture

World Hex Map is one repository containing two independently consumable
packages. The Flutter package uses the repository root and `lib/`; the npm
package uses `typescript/src/` and compiles to `dist/`. Publication allowlists
keep each package's development files out of the other package artifact.

## Components

```text
Natural Earth GeoJSON (pinned revision)
                    |
                    v
       tool/generate_world_hex_grid.mjs
              /                 \
             v                   v
lib/src/world_hex_grid_data.dart  typescript/src/world-hex-grid-data.ts
             |                   |
             v                   v
      WorldHexGrid            WorldHexGrid
             |                   |
             v                   v
    Flutter WorldHexMap      SVG string renderer
```

The checked-in generated files make both runtime packages offline and
deterministic. The generator is the only place that downloads Natural Earth
data.

## Cross-language contract

The Dart and TypeScript grid APIs intentionally share these concepts:

| Concept | Dart | TypeScript |
| --- | --- | --- |
| Grid dimensions and bounds | Static constants | Static constants |
| Cell lookup | `cellId`, `rowOf`, `columnOf` | Same names |
| Coordinate conversion | `normalizedCenter`, `geographicCenter` | Same names |
| Land lookup | `isLandCell`, `nearestLandCell` | Same names |
| Invalid coordinates/indexes | `RangeError` | `RangeError` |

`test-typescript/generated-data-parity.test.mjs` verifies that both generated
datasets are identical. Behavioral tests use the same representative cities
and edge cases in both languages.

The renderers are platform-specific by design. Flutter exposes a widget with
tap handling. TypeScript returns standalone SVG markup suitable for browsers,
SSR, and files without introducing a framework or DOM dependency.

## Making changes

- Change grid selection in `tool/generate_world_hex_grid.mjs`, then run
  `npm run generate` and commit both generated files.
- Keep coordinate and validation behavior aligned between the two
  `WorldHexGrid` implementations.
- Put Flutter-only behavior under `lib/` and TypeScript-only behavior under
  `typescript/src/`.
- Add public behavior tests in both languages when the shared contract changes.
- Treat generated files as outputs; never edit them directly.
