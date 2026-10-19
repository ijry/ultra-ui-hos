/**
 * 上游 u-poster 的绘制几何：单位换算、渐变解析与行数受限的文本折行。
 * Drawing geometry of the upstream u-poster: unit conversion, gradient parsing and clamped text wrapping.
 */

/** 上游 exportImage 的默认海报尺寸。/ Default poster size in upstream exportImage. */
export const UP_POSTER_DEFAULT_WIDTH: string = '750rpx';
export const UP_POSTER_DEFAULT_HEIGHT: string = '1114rpx';
/** 上游 drawTextWithLineClamp 的默认行高与省略号。/ Default line height and ellipsis. */
export const UP_POSTER_DEFAULT_LINE_HEIGHT: number = 20;
export const UP_POSTER_ELLIPSIS: string = '...';
/** 上游 drawItem 的默认文本色。/ Default text color in upstream drawItem. */
export const UP_POSTER_TEXT_COLOR: string = '#000000';
/** 上游 drawGradientBackground 的默认角度。/ Default linear gradient angle. */
export const UP_POSTER_GRADIENT_ANGLE: number = 135;
/** 上游二维码占位的取色与文案。/ Placeholder colors and label of the qrcode branch. */
export const UP_POSTER_QRCODE_PLACEHOLDER_BACKGROUND: string = '#f5f5f5';
export const UP_POSTER_QRCODE_PLACEHOLDER_COLOR: string = '#999';
export const UP_POSTER_QRCODE_PLACEHOLDER_TEXT: string = 'QR';
export const UP_POSTER_QRCODE_PLACEHOLDER_FONT_SIZE: number = 12;
/** 上游隐藏二维码的取色。/ Colors of the hidden upstream qrcode. */
export const UP_POSTER_QRCODE_BACKGROUND: string = '#ffffff';
export const UP_POSTER_QRCODE_FOREGROUND: string = '#000000';
/** 上游 exportImage 的超时时长。/ Export timeout in upstream exportImage. */
export const UP_POSTER_EXPORT_TIMEOUT: number = 20000;
/** 上游支持的元素类型。/ Element types accepted upstream. */
export const UP_POSTER_VIEW_TYPES: Array<string> = ['view', 'text', 'image', 'qrcode'];

/** 元素样式的具名模型，替代上游任意 css 对象。/ Named style model instead of an arbitrary css object. */
export interface UPPosterStyle {
  left?: string;
  top?: string;
  width?: string;
  height?: string;
  background?: string;
  radius?: string;
  color?: string;
  fontSize?: string;
  fontWeight?: string;
  lineHeight?: string;
  textAlign?: string;
  lineClamp?: string;
}

/** 单个海报元素。/ One poster element. */
export interface UPPosterView {
  type?: string;
  text?: string;
  src?: string;
  css?: UPPosterStyle;
}

/** 海报配置，对应上游 json。/ Poster configuration mirroring the upstream json prop. */
export interface UPPosterConfig {
  css?: UPPosterStyle;
  views?: Array<UPPosterView>;
}

/** 一段折行结果。/ One wrapped line. */
export class UPPosterLine {
  text: string = '';
  width: number = 0;

  constructor(text: string, width: number) {
    this.text = text;
    this.width = width;
  }
}

/** 渐变色标。/ One gradient color stop. */
export class UPPosterStop {
  offset: number = 0;
  color: string = '';

  constructor(offset: number, color: string) {
    this.offset = offset;
    this.color = color;
  }
}

/** 渐变解析结果。/ Parsed gradient descriptor. */
export class UPPosterGradient {
  radial: boolean = false;
  angle: number = UP_POSTER_GRADIENT_ANGLE;
  stops: Array<UPPosterStop> = [];
}

/** 线性渐变的起止点。/ Start and end point of a linear gradient. */
export class UPPosterGradientLine {
  startX: number = 0;
  startY: number = 0;
  endX: number = 0;
  endY: number = 0;
}

/**
 * 上游 getRpxRatio()：每 1rpx 对应的 px 数，按 750 设计稿折算。
 * Mirrors upstream getRpxRatio() against the 750rpx design width.
 */
export function upPosterRatio(viewportWidth: number): number {
  const width: number = viewportWidth > 0 ? viewportWidth : 375;
  return width / 750;
}

/**
 * 上游 convertRpxToPx()：`rpx` 按比例折算，其余按 parseFloat 取值。
 * Mirrors upstream convertRpxToPx().
 */
export function upPosterLength(value: string, viewportWidth: number): number {
  const text: string = value.trim();
  if (text.length === 0) {
    return 0;
  }
  const amount: number = parseFloat(text);
  if (isNaN(amount)) {
    return 0;
  }
  if (text.endsWith('rpx') || text.endsWith('upx')) {
    return amount * upPosterRatio(viewportWidth);
  }
  return amount;
}

/** type 是否落在上游取值内。/ Whether the element type is modelled upstream. */
export function upPosterTypeSupported(type: string): boolean {
  return UP_POSTER_VIEW_TYPES.includes(type);
}

/** 是否渐变背景。/ Whether the background declares a gradient. */
export function upPosterGradientBackground(background: string): boolean {
  return background.includes('linear-gradient') || background.includes('radial-gradient');
}

/**
 * 上游 drawGradientBackground 的颜色抓取：只认 `#hex` 与 `rgb()/rgba()`。
 * Mirrors the upstream color scan that accepts hex and rgb notations.
 */
export function upPosterGradientColors(background: string): Array<string> {
  const colors: Array<string> = [];
  const matched: RegExpMatchArray | null = background.match(/#[0-9a-fA-F]+|rgba?\([^)]+\)/g);
  if (matched === null) {
    return colors;
  }
  for (const color of matched) {
    colors.push(color);
  }
  return colors;
}

/** 上游 `linear-gradient(<deg>` 的角度抓取。/ Angle scan of the upstream linear gradient. */
export function upPosterGradientAngle(background: string): number {
  const matched: RegExpMatchArray | null = background.match(/linear-gradient\((\d+)deg/);
  if (matched === null || matched.length < 2) {
    return UP_POSTER_GRADIENT_ANGLE;
  }
  const angle: number = Number.parseInt(matched[1]);
  return isNaN(angle) ? UP_POSTER_GRADIENT_ANGLE : angle;
}

/** 解析渐变声明。/ Parses a gradient declaration. */
export function upPosterGradient(background: string): UPPosterGradient {
  const gradient: UPPosterGradient = new UPPosterGradient();
  gradient.radial = background.includes('radial-gradient');
  gradient.angle = gradient.radial ? UP_POSTER_GRADIENT_ANGLE : upPosterGradientAngle(background);
  const colors: Array<string> = upPosterGradientColors(background);
  if (colors.length < 2) {
    return gradient;
  }
  for (let index: number = 0; index < colors.length; index++) {
    gradient.stops.push(new UPPosterStop(index / (colors.length - 1), colors[index]));
  }
  return gradient;
}

/**
 * 上游支持的四个角度分支，其余角度落到左上到右下的对角线。
 * Mirrors the four upstream angle branches; other angles fall back to the diagonal.
 */
export function upPosterGradientLine(angle: number, left: number, top: number,
  width: number, height: number): UPPosterGradientLine {
  const line: UPPosterGradientLine = new UPPosterGradientLine();
  line.startX = left;
  line.startY = top;
  line.endX = left + width;
  line.endY = top + height;
  if (angle === 0) {
    line.startY = top + height;
    line.endX = left;
    line.endY = top;
    return line;
  }
  if (angle === 90) {
    line.endY = top;
    return line;
  }
  if (angle === 180) {
    line.endX = left;
    return line;
  }
  if (angle === 270) {
    line.startX = left + width;
    line.endX = left;
    line.endY = top;
    return line;
  }
  return line;
}

/**
 * 上游 estimateWidth()：全角按一个字号、空白按 0.28、其余按 0.56 估算。
 * Mirrors the upstream estimateWidth() fallback.
 */
export function upPosterEstimateWidth(text: string, fontSize: number): number {
  const size: number = fontSize > 0 ? fontSize : UP_POSTER_DEFAULT_LINE_HEIGHT;
  const fullWidth: RegExp = /[\u1100-\u115F\u2E80-\u303E\u3041-\u33FF\u3400-\u4DBF\u4E00-\u9FBF\uA000-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE30-\uFE6F\uFF00-\uFF60\uFFE0-\uFFE6]/;
  const blank: RegExp = /\s/;
  let width: number = 0;
  let index: number = 0;
  while (index < text.length) {
    const code: number = text.charCodeAt(index);
    if (code >= 0xd800 && code <= 0xdbff && index + 1 < text.length) {
      width += size;
      index += 2;
      continue;
    }
    const character: string = text.charAt(index);
    if (fullWidth.test(character)) {
      width += size;
    } else if (blank.test(character)) {
      width += size * 0.28;
    } else {
      width += size * 0.56;
    }
    index += 1;
  }
  return width;
}

/** 按码位切分，保证代理对不被拆开。/ Splits by code point so surrogate pairs stay intact. */
export function upPosterCharacters(text: string): Array<string> {
  const characters: Array<string> = [];
  let index: number = 0;
  while (index < text.length) {
    const code: number = text.charCodeAt(index);
    if (code >= 0xd800 && code <= 0xdbff && index + 1 < text.length) {
      characters.push(text.substring(index, index + 2));
      index += 2;
      continue;
    }
    characters.push(text.charAt(index));
    index += 1;
  }
  return characters;
}

/**
 * 上游 findTextFitLength()：二分查找能放进 maxWidth 的字符数。
 * Mirrors the upstream binary search for the fitting character count.
 */
export function upPosterFitLength(characters: Array<string>, suffix: string, maxWidth: number,
  fontSize: number): number {
  let low: number = 0;
  let high: number = characters.length;
  while (low < high) {
    const middle: number = Math.ceil((low + high) / 2);
    const candidate: string = characters.slice(0, middle).join('') + suffix;
    if (upPosterEstimateWidth(candidate, fontSize) <= maxWidth) {
      low = middle;
    } else {
      high = middle - 1;
    }
  }
  return low;
}

/**
 * 上游 drawTextWithLineClamp 的折行结果：末行超宽时补省略号。
 * Mirrors the wrapping of upstream drawTextWithLineClamp, ellipsising the last line.
 */
export function upPosterWrapText(text: string, maxWidth: number, fontSize: number,
  lineClamp: number): Array<UPPosterLine> {
  const lines: Array<UPPosterLine> = [];
  const characters: Array<string> = upPosterCharacters(text);
  const limit: number = Math.max(1, lineClamp);
  const width: number = maxWidth > 0 ? maxWidth : 1;
  let offset: number = 0;
  while (offset < characters.length && lines.length < limit) {
    const remaining: Array<string> = characters.slice(offset);
    const remainingText: string = remaining.join('');
    if (upPosterEstimateWidth(remainingText, fontSize) <= width) {
      lines.push(new UPPosterLine(remainingText, upPosterEstimateWidth(remainingText, fontSize)));
      break;
    }
    if (lines.length === limit - 1) {
      let suffix: string = UP_POSTER_ELLIPSIS;
      while (suffix.length > 0 && upPosterEstimateWidth(suffix, fontSize) > width) {
        suffix = suffix.substring(0, suffix.length - 1);
      }
      const fitLength: number = upPosterFitLength(remaining, suffix, width, fontSize);
      const clipped: string = remaining.slice(0, fitLength).join('') + suffix;
      lines.push(new UPPosterLine(clipped, upPosterEstimateWidth(clipped, fontSize)));
      break;
    }
    const fitLength: number = Math.max(1, upPosterFitLength(remaining, '', width, fontSize));
    const line: string = remaining.slice(0, fitLength).join('');
    lines.push(new UPPosterLine(line, upPosterEstimateWidth(line, fontSize)));
    offset += fitLength;
  }
  return lines;
}

/** 上游 `lineClamp` 解析。/ Parses the upstream lineClamp value. */
export function upPosterLineClamp(value: string): number {
  const amount: number = Number.parseInt(value);
  return isNaN(amount) || amount < 1 ? 1 : amount;
}

/** 上游 `textBaseLine`：无字号时按 10 兜底。/ Mirrors the upstream text baseline offset. */
export function upPosterBaseline(fontSize: number): number {
  return fontSize > 0 ? fontSize / 2 : 10;
}

/** 上游 `fontWeight === 'bold' ? 2 : 1` 的描边宽度。/ Mirrors the upstream stroke width quirk. */
export function upPosterStrokeWidth(fontWeight: string): number {
  return fontWeight === 'bold' ? 2 : 1;
}
