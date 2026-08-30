import {WorldHexGrid} from './world-hex-grid.js';

const aspectRatio = 1.78;

/** A highlighted hex on a rendered world map. */
export type WorldHexMarker =
  | {
      /** An existing land-cell ID. */
      readonly cellId: number;
      readonly latitude?: never;
      readonly longitude?: never;
      /** Marker fill. */
      readonly color?: string;
      /** Marker outline. */
      readonly borderColor?: string;
      /** Marker size relative to a regular land cell. */
      readonly scale?: number;
    }
  | {
      readonly cellId?: never;
      /** Latitude to snap to the closest land cell. */
      readonly latitude: number;
      /** Longitude to snap to the closest land cell. */
      readonly longitude: number;
      /** Marker fill. */
      readonly color?: string;
      /** Marker outline. */
      readonly borderColor?: string;
      /** Marker size relative to a regular land cell. */
      readonly scale?: number;
    };

/** Options for the dependency-free SVG renderer. */
export interface WorldHexMapOptions {
  /** Rendered width in CSS pixels. Defaults to 720. */
  readonly width?: number;
  /** Rendered height in CSS pixels. Defaults to width / 1.78. */
  readonly height?: number;
  /** Color used for unmarked land cells. */
  readonly landColor?: string;
  /** Color painted behind the map. */
  readonly backgroundColor?: string;
  /** Default fill used by markers. */
  readonly markerColor?: string;
  /** Default outline used by markers. */
  readonly markerBorderColor?: string;
  /** Cells or coordinates highlighted above the land silhouette. */
  readonly markers?: readonly WorldHexMarker[];
  /** Size of land hexes relative to the grid spacing. */
  readonly cellScale?: number;
  /** Inset on every edge, in view-box units. */
  readonly padding?: number;
  /** Accessible label placed on the SVG. */
  readonly ariaLabel?: string;
  /** Optional CSS class placed on the SVG element. */
  readonly className?: string;
}

/**
 * Produces standalone SVG markup for the built-in world hex map.
 *
 * The result can be assigned to `innerHTML`, rendered by an SSR framework, or
 * written directly to an `.svg` file. It has no DOM or runtime dependency.
 */
export function renderWorldHexMap(options: WorldHexMapOptions = {}): string {
  const width = options.width ?? 720;
  const height = options.height ?? width / aspectRatio;
  const padding = options.padding ?? 0;
  const cellScale = options.cellScale ?? 0.78;
  checkPositive(width, 'width');
  checkPositive(height, 'height');
  if (!Number.isFinite(padding) || padding < 0) {
    throw new RangeError('padding must be finite and at least zero.');
  }
  if (!Number.isFinite(cellScale) || cellScale <= 0 || cellScale > 1) {
    throw new RangeError('cellScale must be finite, greater than zero, and at most one.');
  }
  if (padding * 2 >= width || padding * 2 >= height) {
    throw new RangeError('padding must leave a non-empty map area.');
  }

  const mapRect = fittedMapRect(width, height, padding);
  const horizontalStep = mapRect.width / (WorldHexGrid.columns - 0.5);
  const verticalStep = mapRect.height / (WorldHexGrid.rows - 1);
  const baseRadius = Math.min(horizontalStep / 1.9, verticalStep / 1.66);
  const radius = baseRadius * cellScale;
  const landPath = WorldHexGrid.landCellIds
    .map((cellId) => hexPath(cellCenter(cellId, mapRect), radius))
    .join('');

  const markerPaths = (options.markers ?? [])
    .map((marker) => renderMarker(marker, mapRect, radius, options))
    .filter((marker): marker is string => marker !== undefined)
    .join('');

  const classAttribute = options.className
    ? ` class="${escapeAttribute(options.className)}"`
    : '';
  const label = escapeAttribute(options.ariaLabel ?? 'World hex map');
  const background = escapeAttribute(options.backgroundColor ?? 'transparent');
  const landColor = escapeAttribute(options.landColor ?? '#d0d5dd');

  return (
    `<svg xmlns="http://www.w3.org/2000/svg"${classAttribute}` +
    ` width="${formatNumber(width)}" height="${formatNumber(height)}"` +
    ` viewBox="0 0 ${formatNumber(width)} ${formatNumber(height)}"` +
    ` role="img" aria-label="${label}" preserveAspectRatio="xMidYMid meet">` +
    `<rect width="100%" height="100%" fill="${background}"/>` +
    `<path data-layer="land" data-cell-count="${WorldHexGrid.landCellIds.length}"` +
    ` d="${landPath}" fill="${landColor}"/>${markerPaths}</svg>`
  );
}

interface Rect {
  readonly left: number;
  readonly top: number;
  readonly width: number;
  readonly height: number;
}

interface Point {
  readonly x: number;
  readonly y: number;
}

function fittedMapRect(width: number, height: number, padding: number): Rect {
  const availableWidth = width - padding * 2;
  const availableHeight = height - padding * 2;
  if (availableWidth / availableHeight > aspectRatio) {
    const mapWidth = availableHeight * aspectRatio;
    return {
      left: padding + (availableWidth - mapWidth) / 2,
      top: padding,
      width: mapWidth,
      height: availableHeight,
    };
  }

  const mapHeight = availableWidth / aspectRatio;
  return {
    left: padding,
    top: padding + (availableHeight - mapHeight) / 2,
    width: availableWidth,
    height: mapHeight,
  };
}

function cellCenter(cellId: number, rect: Rect): Point {
  const normalized = WorldHexGrid.normalizedCenter(cellId);
  return {
    x: rect.left + normalized.x * rect.width,
    y: rect.top + normalized.y * rect.height,
  };
}

function renderMarker(
  marker: WorldHexMarker,
  mapRect: Rect,
  radius: number,
  options: WorldHexMapOptions,
): string | undefined {
  const cellId = marker.cellId ?? WorldHexGrid.nearestLandCell({
    latitude: marker.latitude,
    longitude: marker.longitude,
  });
  if (!WorldHexGrid.isLandCell(cellId)) return undefined;

  const scale = marker.scale ?? 1.35;
  checkPositive(scale, 'marker scale');
  const fill = escapeAttribute(marker.color ?? options.markerColor ?? '#2563eb');
  const stroke = escapeAttribute(
    marker.borderColor ?? options.markerBorderColor ?? '#ffffff',
  );
  const strokeWidth = Math.max(1, radius * 0.28);
  return (
    `<path data-layer="marker" data-cell-id="${cellId}"` +
    ` d="${hexPath(cellCenter(cellId, mapRect), radius * scale)}"` +
    ` fill="${fill}" stroke="${stroke}"` +
    ` stroke-width="${formatNumber(strokeWidth)}"/>`
  );
}

function hexPath(center: Point, radius: number): string {
  let path = '';
  for (let index = 0; index < 6; index += 1) {
    const angle = (Math.PI / 3) * index;
    const x = center.x + Math.cos(angle) * radius;
    const y = center.y + Math.sin(angle) * radius;
    path += `${index === 0 ? 'M' : 'L'}${formatNumber(x)} ${formatNumber(y)}`;
  }
  return `${path}Z`;
}

function checkPositive(value: number, name: string): void {
  if (!Number.isFinite(value) || value <= 0) {
    throw new RangeError(`${name} must be finite and greater than zero.`);
  }
}

function formatNumber(value: number): string {
  return String(Number(value.toFixed(3)));
}

function escapeAttribute(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}
