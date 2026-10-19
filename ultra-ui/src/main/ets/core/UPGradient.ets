/**
 * 上游 `libs/function/colorGradient.js` 与 `genLightColor()` 的 ArkTS 复刻。
 * ArkTS port of the upstream colour helpers: hex/rgb conversion, N-step gradients,
 * alpha composition and the HSL-based light background generator.
 */
import { UPRawValue } from './UPTypes';

/** RGB 三通道，取值 0–255。/ An RGB triple in the 0-255 range. */
export interface UPRgbColor {
  red: number;
  green: number;
  blue: number;
}

/** HSL 色域，`hue` 为度、`saturation`/`lightness` 为百分比。/ HSL triple. */
export interface UPHslColor {
  hue: number;
  saturation: number;
  lightness: number;
}

function textOf(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

function clampChannel(value: number): number {
  if (!Number.isFinite(value)) {
    return 0;
  }
  return Math.max(0, Math.min(255, Math.round(value)));
}

function hexPair(value: number): string {
  const channel: string = clampChannel(value).toString(16);
  return channel.length === 1 ? '0' + channel : channel;
}

export class UPGradient {
  /** 把 `#abc` 展开为 `#aabbcc`。/ Expands a three-digit hex colour. */
  static expandHex(value: string): string {
    const source: string = value.trim().toLowerCase();
    if (!/^#([0-9a-f]{3})$/.test(source)) {
      return source;
    }
    let expanded: string = '#';
    for (let index: number = 1; index < 4; index++) {
      const part: string = source.slice(index, index + 1);
      expanded = expanded + part + part;
    }
    return expanded;
  }

  /**
   * 上游 `hexToRgb(color, false)`：把 `#rgb`/`#rrggbb`/`rgb(...)` 解析为通道值。
   * 解析失败返回 undefined，由调用方决定回退策略。
   * Parses a hex or rgb() colour into channels.
   */
  static toRgb(value: UPRawValue): UPRgbColor | undefined {
    const source: string = textOf(value).trim().toLowerCase();
    if (source.length === 0) {
      return undefined;
    }
    if (/^#([0-9a-f]{3}|[0-9a-f]{6})$/.test(source)) {
      const full: string = source.length === 4 ? UPGradient.expandHex(source) : source;
      return {
        red: Number.parseInt(full.slice(1, 3), 16),
        green: Number.parseInt(full.slice(3, 5), 16),
        blue: Number.parseInt(full.slice(5, 7), 16)
      };
    }
    const match: RegExpMatchArray | null = source.match(/^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/);
    if (match !== null) {
      return {
        red: clampChannel(Number(match[1])),
        green: clampChannel(Number(match[2])),
        blue: clampChannel(Number(match[3]))
      };
    }
    return undefined;
  }

  /** 上游 `hexToRgb(color, true)`：返回 `rgb(r,g,b)` 字符串。/ Formats as `rgb(...)`. */
  static toRgbText(value: UPRawValue): string {
    const rgb: UPRgbColor | undefined = UPGradient.toRgb(value);
    if (rgb === undefined) {
      return textOf(value);
    }
    return 'rgb(' + String(rgb.red) + ',' + String(rgb.green) + ',' + String(rgb.blue) + ')';
  }

  /** 上游 `rgbToHex()`：`rgb(...)` 或 `#abc` 统一转成 `#rrggbb`。/ Normalises to six-digit hex. */
  static toHex(value: UPRawValue): string {
    const source: string = textOf(value).trim().toLowerCase();
    if (/^#([0-9a-f]{3})$/.test(source)) {
      return UPGradient.expandHex(source);
    }
    if (/^#([0-9a-f]{6})$/.test(source)) {
      return source;
    }
    const rgb: UPRgbColor | undefined = UPGradient.toRgb(source);
    if (rgb === undefined) {
      return source;
    }
    return '#' + hexPair(rgb.red) + hexPair(rgb.green) + hexPair(rgb.blue);
  }

  /** 上游 `colorToRgba()`：附加透明度后输出 `rgba(...)`。/ Adds an alpha channel. */
  static toRgba(value: UPRawValue, alpha: number): string {
    const rgb: UPRgbColor | undefined = UPGradient.toRgb(value);
    if (rgb === undefined) {
      return textOf(value);
    }
    const safeAlpha: number = Number.isFinite(alpha) ? Math.max(0, Math.min(1, alpha)) : 1;
    return 'rgba(' + String(rgb.red) + ',' + String(rgb.green) + ',' + String(rgb.blue) + ','
      + String(safeAlpha) + ')';
  }

  /**
   * 上游 `colorGradient()`：在首尾颜色之间等分出 `step` 个色值。
   * 首尾两项分别锁定为起点与终点，与上游一致。
   * Builds an N-step gradient between two colours.
   */
  static gradient(startColor: UPRawValue, endColor: UPRawValue, step: number = 10): Array<string> {
    const steps: number = Math.max(1, Math.floor(step));
    const start: UPRgbColor | undefined = UPGradient.toRgb(startColor);
    const end: UPRgbColor | undefined = UPGradient.toRgb(endColor);
    const result: Array<string> = [];
    if (start === undefined || end === undefined) {
      for (let index: number = 0; index < steps; index++) {
        result.push(UPGradient.toHex(index === 0 ? startColor : endColor));
      }
      return result;
    }
    const deltaRed: number = (end.red - start.red) / steps;
    const deltaGreen: number = (end.green - start.green) / steps;
    const deltaBlue: number = (end.blue - start.blue) / steps;
    for (let index: number = 0; index < steps; index++) {
      if (index === 0) {
        result.push(UPGradient.toHex(startColor));
        continue;
      }
      if (index === steps - 1) {
        result.push(UPGradient.toHex(endColor));
        continue;
      }
      result.push('#' + hexPair(deltaRed * index + start.red)
        + hexPair(deltaGreen * index + start.green)
        + hexPair(deltaBlue * index + start.blue));
    }
    return result;
  }

  /** RGB 转 HSL，与上游 `rgbToHsl()` 的取整口径一致。/ RGB to HSL. */
  static toHsl(value: UPRawValue): UPHslColor | undefined {
    const rgb: UPRgbColor | undefined = UPGradient.toRgb(value);
    if (rgb === undefined) {
      return undefined;
    }
    const red: number = rgb.red / 255;
    const green: number = rgb.green / 255;
    const blue: number = rgb.blue / 255;
    const maximum: number = Math.max(red, green, blue);
    const minimum: number = Math.min(red, green, blue);
    const lightness: number = (maximum + minimum) / 2;
    if (maximum === minimum) {
      return { hue: 0, saturation: 0, lightness: Number((lightness * 100).toFixed(1)) };
    }
    const delta: number = maximum - minimum;
    const saturation: number = lightness > 0.5 ? delta / (2 - maximum - minimum) : delta / (maximum + minimum);
    let hue: number = 0;
    if (maximum === red) {
      hue = (green - blue) / delta + (green < blue ? 6 : 0);
    } else if (maximum === green) {
      hue = (blue - red) / delta + 2;
    } else {
      hue = (red - green) / delta + 4;
    }
    return {
      hue: Number((hue * 60).toFixed(1)),
      saturation: Number((saturation * 100).toFixed(1)),
      lightness: Number((lightness * 100).toFixed(1))
    };
  }

  /** HSL 转 `#rrggbb`，与上游 `hslToHex()` 同算法。/ HSL to hex. */
  static fromHsl(hue: number, saturation: number, lightness: number): string {
    const level: number = lightness / 100;
    const amplitude: number = saturation * Math.min(level, 1 - level) / 100;
    return '#' + UPGradient.hslChannel(0, hue, level, amplitude)
      + UPGradient.hslChannel(8, hue, level, amplitude)
      + UPGradient.hslChannel(4, hue, level, amplitude);
  }

  /**
   * 上游 `genLightColor()`：保留色相与饱和度，把亮度提到 `lightness`（上限 95）。
   * 解析失败时返回空串，上游在这种情况下会抛错。
   * Generates a light companion colour; returns an empty string when parsing fails.
   */
  static lightColor(value: UPRawValue, lightness: number = 95): string {
    const hsl: UPHslColor | undefined = UPGradient.toHsl(value);
    if (hsl === undefined) {
      return '';
    }
    return UPGradient.fromHsl(hsl.hue, hsl.saturation, Math.min(lightness, 95));
  }

  private static hslChannel(offset: number, hue: number, level: number, amplitude: number): string {
    const position: number = (offset + hue / 30) % 12;
    const factor: number = level - amplitude * Math.max(Math.min(position - 3, 9 - position, 1), -1);
    const channel: string = Math.round(255 * factor).toString(16);
    return channel.length === 1 ? '0' + channel : channel;
  }
}
