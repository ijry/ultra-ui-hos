import { UPRawValue } from './UPTypes';
import { UPTheme, UP_DEFAULT_THEME } from './UPTheme';

/** Color parser accepting #RGB, #RGBA, #RRGGBB and #RRGGBBAA plus rgb()/rgba(). */
export class UPColor {
  static parse(value: UPRawValue, theme: UPTheme = UP_DEFAULT_THEME, fallback: string = theme.main): string {
    if (typeof value !== 'string') {
      return fallback;
    }
    const source: string = value.trim();
    if (source.length === 0) {
      return fallback;
    }
    const themed: string = theme.color(source, '');
    if (themed.length > 0) {
      return themed;
    }
    if (UPColor.isHex(source) || UPColor.isRgb(source)) {
      return UPColor.normalize(source);
    }
    return fallback;
  }

  static isValid(value: UPRawValue): boolean {
    if (typeof value !== 'string') {
      return false;
    }
    const source: string = value.trim();
    return UPColor.isHex(source) || UPColor.isRgb(source);
  }

  private static isHex(value: string): boolean {
    return /^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(value);
  }

  private static isRgb(value: string): boolean {
    return /^rgba?\(\s*[-+]?\d+(?:\.\d+)?\s*,\s*[-+]?\d+(?:\.\d+)?\s*,\s*[-+]?\d+(?:\.\d+)?(?:\s*,\s*(?:0|1|0?\.\d+))?\s*\)$/i.test(value);
  }

  private static normalize(value: string): string {
    if (value.length === 4) {
      return '#' + value.slice(1).split('').map((part: string): string => part + part).join('');
    }
    if (value.length === 5) {
      const rgb: string = value.slice(1, 4).split('').map((part: string): string => part + part).join('');
      const alpha: string = value.slice(4) + value.slice(4);
      return '#' + rgb + alpha;
    }
    return value;
  }
}
