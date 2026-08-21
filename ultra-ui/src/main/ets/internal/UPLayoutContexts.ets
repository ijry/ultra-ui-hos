import { UPRawValue } from '../core/UPTypes';

/** Number of grid units in the 12-column layout system shared by Row and Col. */
export const UP_GRID_UNITS: number = 12;

/** Parse an integer and clamp it into [min, max]; invalid values fall back. */
export function upLayoutInt(value: UPRawValue, fallback: number, min: number, max: number): number {
  let parsed: number = fallback;
  if (typeof value === 'number' && Number.isFinite(value)) {
    parsed = Math.trunc(value);
  } else if (typeof value === 'string') {
    const trimmed: string = value.trim();
    if (trimmed.length > 0) {
      const numeric: number = Number(trimmed);
      if (Number.isFinite(numeric)) {
        parsed = Math.trunc(numeric);
      }
    }
  }
  if (parsed < min) {
    return min;
  }
  if (parsed > max) {
    return max;
  }
  return parsed;
}

/** Resolve an enum-like string against an allowed set; invalid values fall back. */
export function upLayoutEnum(value: UPRawValue, allowed: Array<string>, fallback: string): string {
  if (typeof value !== 'string') {
    return fallback;
  }
  const candidate: string = value.trim().toLowerCase();
  if (candidate.length === 0) {
    return fallback;
  }
  for (let i = 0; i < allowed.length; i++) {
    if (allowed[i] === candidate) {
      return candidate;
    }
  }
  return fallback;
}

/** Read-only layout context provided by UPRow to nested UPCol children. */
export class UPRowLayoutContext {
  gutter: number;

  constructor(gutter: number) {
    this.gutter = Math.max(0, gutter);
  }
}

/** Read-only layout context provided by UPGrid to nested UPGridItem children. */
export class UPGridLayoutContext {
  columns: number;
  border: boolean;
  align: string;
  gap: number;
  private nextIndex: number;

  constructor(columns: number, border: boolean, align: string, gap: number) {
    this.columns = Math.max(1, columns);
    this.border = border;
    this.align = align;
    this.gap = Math.max(0, gap);
    this.nextIndex = 0;
  }

  /** Reset the render-local item counter at the start of each Grid build pass. */
  beginComposition(): void {
    this.nextIndex = 0;
  }

  /** Allocate the next visual index for a nested item; never persisted globally. */
  allocateIndex(): number {
    const index: number = this.nextIndex;
    this.nextIndex = this.nextIndex + 1;
    return index;
  }

  /** Number of GridItem children allocated during the current composition. */
  itemCount(): number {
    return this.nextIndex;
  }
}
