import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import test from 'node:test';

import {WorldHexGrid} from '../dist/index.js';

test('Dart and TypeScript use identical generated grid data', async () => {
  const dartSource = await readFile(
    new URL('../lib/src/world_hex_grid_data.dart', import.meta.url),
    'utf8',
  );
  const listMatch = dartSource.match(
    /static const List<int> landCellIds = <int>\[([\s\S]*?)\];/,
  );
  assert.ok(listMatch, 'Dart landCellIds declaration was not found');

  const dartCellIds = [...listMatch[1].matchAll(/\d+/g)].map((match) =>
    Number(match[0]),
  );
  assert.deepEqual(dartCellIds, WorldHexGrid.landCellIds);

  assert.equal(readDartNumber(dartSource, 'columns'), WorldHexGrid.columns);
  assert.equal(readDartNumber(dartSource, 'rows'), WorldHexGrid.rows);
  assert.equal(readDartNumber(dartSource, 'north'), WorldHexGrid.north);
  assert.equal(readDartNumber(dartSource, 'south'), WorldHexGrid.south);
});

function readDartNumber(source, name) {
  const match = source.match(
    new RegExp(`static const (?:int|double) ${name} = (-?\\d+(?:\\.\\d+)?);`),
  );
  assert.ok(match, `Dart ${name} declaration was not found`);
  return Number(match[1]);
}
