import { UPRawValue, UPEdgeInput } from './UPTypes';

export interface UPEdgeValues {
  top: number;
  right: number;
  bottom: number;
  left: number;
}

/** Safe dimension conversion for uview-plus' rpx/vp/px values. */
export class UPUnit {
  static readonly DESIGN_WIDTH: number = 750;

  static parse(value: UPRawValue, viewportWidth: number = 375, fallback: number = 0, allowNegative: boolean = false): number {
    if (typeof value === 'number') {
      if (!Number.isFinite(value) || (!allowNegative && value < 0)) {
        return fallback;
      }
      return value;
    }
    if (typeof value !== 'string') {
      return fallback;
    }
    const source: string = value.trim().toLowerCase();
    if (source.length === 0) {
      return fallback;
    }
    const match: RegExpMatchArray | null = source.match(/^(-?(?:\d+\.?\d*|\.\d+))\s*(rpx|px|vp)?$/);
    if (match === null) {
      return fallback;
    }
    const amount: number = Number(match[1]);
    if (!Number.isFinite(amount) || (!allowNegative && amount < 0)) {
      return fallback;
    }
    const unit: string = match[2] ?? 'vp';
    if (unit === 'rpx') {
      const width: number = Number.isFinite(viewportWidth) && viewportWidth > 0 ? viewportWidth : 375;
      return amount * width / UPUnit.DESIGN_WIDTH;
    }
    return amount;
  }

  static parseOptional(value: UPRawValue, viewportWidth: number = 375, allowNegative: boolean = false): number | undefined {
    if (value === null || value === undefined) {
      return undefined;
    }
    const parsed: number = UPUnit.parse(value, viewportWidth, Number.NaN, allowNegative);
    return Number.isFinite(parsed) ? parsed : undefined;
  }

  static parseEdges(value: UPRawValue | UPEdgeInput | undefined, viewportWidth: number = 375, fallback: number = 0): UPEdgeValues {
    if (value !== null && value !== undefined && typeof value === 'object') {
      const edge: UPEdgeInput = value as UPEdgeInput;
      const horizontal: number = UPUnit.parse(edge.start ?? edge.left, viewportWidth, fallback, true);
      const right: number = UPUnit.parse(edge.end ?? edge.right, viewportWidth, horizontal, true);
      const top: number = UPUnit.parse(edge.top, viewportWidth, fallback, true);
      const bottom: number = UPUnit.parse(edge.bottom, viewportWidth, top, true);
      return { top, right, bottom, left: horizontal };
    }
    const source: string = typeof value === 'string' ? value.trim() : '';
    if (source.length > 0) {
      const parts: Array<string> = source.split(/\s+/);
      const values: Array<number> = parts.map((part: string): number => UPUnit.parse(part, viewportWidth, fallback, true));
      if (values.length === 1) {
        return { top: values[0], right: values[0], bottom: values[0], left: values[0] };
      }
      if (values.length === 2) {
        return { top: values[0], right: values[1], bottom: values[0], left: values[1] };
      }
      if (values.length === 3) {
        return { top: values[0], right: values[1], bottom: values[2], left: values[1] };
      }
      if (values.length >= 4) {
        return { top: values[0], right: values[1], bottom: values[2], left: values[3] };
      }
    }
    const scalar: number = UPUnit.parse(value as UPRawValue, viewportWidth, fallback, true);
    return { top: scalar, right: scalar, bottom: scalar, left: scalar };
  }
}
