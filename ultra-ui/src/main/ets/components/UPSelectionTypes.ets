import { UPRawValue, UPStyleInput } from '../core/UPTypes';

export interface UPSelectionOption {
  name: UPRawValue;
  label?: UPRawValue;
  disabled?: UPRawValue;
}

export function upSelectionText(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

export function upSelectionNumber(value: UPRawValue, fallback: number): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string' && Number.isFinite(Number(value.trim()))) {
    return Number(value.trim());
  }
  return fallback;
}

export function upSelectionBoolean(value: UPRawValue, fallback: boolean = false): boolean {
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'string') {
    const source: string = value.trim().toLowerCase();
    if (source === 'true' || source === '1') return true;
    if (source === 'false' || source === '0' || source.length === 0) return false;
  }
  return fallback;
}

export function upSelectionEqual(left: UPRawValue, right: UPRawValue): boolean {
  return String(left) === String(right);
}

export function upSelectionColor(value: UPRawValue, fallback: string): string {
  const source: string = upSelectionText(value).trim();
  if (source === 'primary') return '#2979ff';
  if (source === 'success') return '#19be6b';
  if (source === 'warning') return '#ff9900';
  if (source === 'error') return '#fa3534';
  if (source === 'info') return '#909399';
  if (/^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(source)) return source;
  return source.length > 0 ? source : fallback;
}

export function upSelectionShape(value: UPRawValue, fallback: string): string {
  const source: string = upSelectionText(value).toLowerCase();
  return source === 'circle' || source === 'square' ? source : fallback;
}

export function upSelectionStyle(value: UPStyleInput): UPStyleInput {
  return value;
}
