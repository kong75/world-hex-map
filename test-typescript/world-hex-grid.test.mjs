import assert from 'node:assert/strict';
import test from 'node:test';

import {WorldHexGrid} from '../dist/index.js';

test('generated world grid contains valid unique land cells', () => {
  assert.equal(WorldHexGrid.landCellIds.length, 1141);
  assert.equal(
    new Set(WorldHexGrid.landCellIds).size,
    WorldHexGrid.landCellIds.length,
  );

  const maximumCellId = WorldHexGrid.columns * WorldHexGrid.rows;
  for (const cellId of WorldHexGrid.landCellIds) {
    assert.ok(cellId >= 0 && cellId < maximumCellId);
    const center = WorldHexGrid.normalizedCenter(cellId);
    assert.ok(center.x >= 0 && center.x <= 1);
    assert.ok(center.y >= 0 && center.y <= 1);
  }
});

test('major-city coordinates snap to land cells', () => {
  const places = [
    {latitude: 40.7128, longitude: -74.006},
    {latitude: 51.5072, longitude: -0.1276},
    {latitude: 35.6762, longitude: 139.6503},
    {latitude: -33.8688, longitude: 151.2093},
    {latitude: -33.9249, longitude: 18.4241},
  ];

  for (const place of places) {
    assert.equal(
      WorldHexGrid.isLandCell(WorldHexGrid.nearestLandCell(place)),
      true,
    );
  }
});

test('cell indexes and coordinates are validated', () => {
  assert.throws(() => WorldHexGrid.normalizedCenter(-1), RangeError);
  assert.throws(() => WorldHexGrid.normalizedCenter(1.5), RangeError);
  assert.throws(
    () => WorldHexGrid.nearestLandCell({latitude: 91, longitude: 0}),
    RangeError,
  );
  assert.throws(
    () => WorldHexGrid.nearestLandCell({latitude: 0, longitude: 181}),
    RangeError,
  );
});
