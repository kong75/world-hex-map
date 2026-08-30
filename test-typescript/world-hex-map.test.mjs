import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import test from 'node:test';

import {renderWorldHexMap, WorldHexGrid} from '../dist/index.js';

test('renders accessible standalone SVG with coordinate markers', () => {
  const londonCellId = WorldHexGrid.nearestLandCell({
    latitude: 51.5072,
    longitude: -0.1276,
  });
  const svg = renderWorldHexMap({
    ariaLabel: 'Locations & offices',
    className: 'office-map',
    markers: [{latitude: 51.5072, longitude: -0.1276}],
  });

  assert.match(svg, /^<svg /);
  assert.match(svg, /class="office-map"/);
  assert.match(svg, /aria-label="Locations &amp; offices"/);
  assert.match(svg, /data-cell-count="1141"/);
  assert.match(svg, new RegExp(`data-cell-id="${londonCellId}"`));
  assert.match(svg, /<\/svg>$/);
});

test('ignores markers for non-land cells and validates layout options', () => {
  const svg = renderWorldHexMap({markers: [{cellId: 0}]});
  assert.doesNotMatch(svg, /data-layer="marker"/);
  assert.throws(() => renderWorldHexMap({cellScale: 1.1}), RangeError);
  assert.throws(
    () => renderWorldHexMap({width: 100, height: 100, padding: 50}),
    RangeError,
  );
});

test('rendered SVG matches the approved visual fixture', () => {
  const svg = renderWorldHexMap({
    width: 1200,
    ariaLabel: 'Five highlighted cities on the world hex map',
    backgroundColor: '#f8fafc',
    landColor: '#cbd5e1',
    markerColor: '#2563eb',
    markers: [
      {latitude: 40.7128, longitude: -74.006},
      {latitude: 51.5072, longitude: -0.1276},
      {latitude: 35.6762, longitude: 139.6503, color: '#e11d48'},
      {latitude: -33.8688, longitude: 151.2093},
      {latitude: -33.9249, longitude: 18.4241},
    ],
    padding: 24,
  });
  const digest = createHash('sha256').update(svg).digest('hex');

  assert.equal(
    digest,
    'c4be9b960fc198f63cbb60c21d91cedb0e9ba10685b81d75661637546f34714d',
  );
});
