import {
  columns,
  landCellIds,
  north,
  rows,
  south,
} from './world-hex-grid-data.js';

/** A point in the map's normalized coordinate space. */
export interface NormalizedMapPoint {
  /** Horizontal position from 0 (left) to 1 (right). */
  readonly x: number;
  /** Vertical position from 0 (top) to 1 (bottom). */
  readonly y: number;
}

/** A geographic point expressed in decimal degrees. */
export interface GeographicPoint {
  readonly latitude: number;
  readonly longitude: number;
}

const landCellIdSet = new Set(landCellIds);

/** Utilities and generated data for the built-in world hex grid. */
export class WorldHexGrid {
  private constructor() {}

  /** Number of columns in the generated grid. */
  static readonly columns = columns;

  /** Number of rows in the generated grid. */
  static readonly rows = rows;

  /** Northern latitude represented by the grid. */
  static readonly north = north;

  /** Southern latitude represented by the grid. */
  static readonly south = south;

  /** IDs of cells selected as land by the generator. */
  static readonly landCellIds = landCellIds;

  /** Returns whether a cell is part of the land silhouette. */
  static isLandCell(cellId: number): boolean {
    return landCellIdSet.has(cellId);
  }

  /** Returns the ID at a row and column. */
  static cellId({row, column}: {row: number; column: number}): number {
    checkIntegerInRange(row, 0, rows - 1, 'row');
    checkIntegerInRange(column, 0, columns - 1, 'column');
    return row * columns + column;
  }

  /** Returns the row containing a cell. */
  static rowOf(cellId: number): number {
    checkCellId(cellId);
    return Math.floor(cellId / columns);
  }

  /** Returns the column containing a cell. */
  static columnOf(cellId: number): number {
    checkCellId(cellId);
    return cellId % columns;
  }

  /** Returns the normalized center of a cell. */
  static normalizedCenter(cellId: number): NormalizedMapPoint {
    checkCellId(cellId);
    const row = Math.floor(cellId / columns);
    const column = cellId % columns;
    return {
      x: (column + (row % 2 === 1 ? 0.5 : 0)) / (columns - 0.5),
      y: row / (rows - 1),
    };
  }

  /** Returns the approximate geographic center of a cell. */
  static geographicCenter(cellId: number): GeographicPoint {
    const center = this.normalizedCenter(cellId);
    return {
      latitude: north - center.y * (north - south),
      longitude: center.x * 360 - 180,
    };
  }

  /** Returns the closest land cell to a WGS84 coordinate. */
  static nearestLandCell({
    latitude,
    longitude,
  }: GeographicPoint): number {
    checkCoordinate(latitude, -90, 90, 'latitude');
    checkCoordinate(longitude, -180, 180, 'longitude');

    const targetX = clamp((longitude + 180) / 360, 0, 1);
    const targetY = clamp((north - latitude) / (north - south), 0, 1);
    const targetRow = targetY * (rows - 1);
    const targetColumn = targetX * (columns - 0.5);
    const estimatedRow = clamp(Math.round(targetRow), 0, rows - 1);

    let bestCellId: number | undefined;
    let bestDistanceSquared = Number.POSITIVE_INFINITY;

    for (let row = estimatedRow - 3; row <= estimatedRow + 3; row += 1) {
      if (row < 0 || row >= rows) continue;
      const offset = row % 2 === 1 ? 0.5 : 0;
      const estimatedColumn = Math.round(targetColumn - offset);
      for (
        let column = estimatedColumn - 3;
        column <= estimatedColumn + 3;
        column += 1
      ) {
        if (column < 0 || column >= columns) continue;
        const candidate = row * columns + column;
        if (!landCellIdSet.has(candidate)) continue;
        const distanceSquared = gridDistanceSquared(
          candidate,
          targetRow,
          targetColumn,
        );
        if (distanceSquared < bestDistanceSquared) {
          bestCellId = candidate;
          bestDistanceSquared = distanceSquared;
        }
      }
    }

    if (bestCellId !== undefined) return bestCellId;

    for (const candidate of landCellIds) {
      const distanceSquared = gridDistanceSquared(
        candidate,
        targetRow,
        targetColumn,
      );
      if (distanceSquared < bestDistanceSquared) {
        bestCellId = candidate;
        bestDistanceSquared = distanceSquared;
      }
    }

    // The generated grid is guaranteed to contain land cells.
    return bestCellId as number;
  }
}

function gridDistanceSquared(
  cellId: number,
  targetRow: number,
  targetColumn: number,
): number {
  const row = Math.floor(cellId / columns);
  const column = cellId % columns;
  const columnCenter = column + (row % 2 === 1 ? 0.5 : 0);
  const dx = columnCenter - targetColumn;
  const dy = row - targetRow;
  return dx * dx + dy * dy;
}

function checkCellId(cellId: number): void {
  checkIntegerInRange(cellId, 0, rows * columns - 1, 'cellId');
}

function checkIntegerInRange(
  value: number,
  minimum: number,
  maximum: number,
  name: string,
): void {
  if (!Number.isInteger(value) || value < minimum || value > maximum) {
    throw new RangeError(
      `${name} must be an integer between ${minimum} and ${maximum}.`,
    );
  }
}

function checkCoordinate(
  value: number,
  minimum: number,
  maximum: number,
  name: string,
): void {
  if (!Number.isFinite(value) || value < minimum || value > maximum) {
    throw new RangeError(
      `${name} must be finite and between ${minimum} and ${maximum}.`,
    );
  }
}

function clamp(value: number, minimum: number, maximum: number): number {
  return Math.min(Math.max(value, minimum), maximum);
}
