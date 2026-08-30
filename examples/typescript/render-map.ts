import {mkdir, writeFile} from 'node:fs/promises';
import path from 'node:path';

import {renderWorldHexMap} from 'world-hex-map';

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

const outputDirectory = path.resolve('build/typescript-example');
const outputPath = path.join(outputDirectory, 'world-hex-map.svg');
await mkdir(outputDirectory, {recursive: true});
await writeFile(outputPath, svg, 'utf8');

process.stdout.write(`Rendered ${outputPath}\n`);
