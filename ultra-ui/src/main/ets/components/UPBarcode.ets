import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { upCanvasTextAlign } from './UPCanvas';

/** 上游 CODE128_START_CODE_B。/ Upstream CODE128 Code B start symbol. */
const UP_BARCODE_CODE128_START_B: number = 104;

/** 上游 CODE128_STOP。/ Upstream CODE128 stop symbol. */
const UP_BARCODE_CODE128_STOP: number = 106;

/** 上游 CODE128_CODE_B_CHARS：Code B 字符集，下标即码值。/ Upstream CODE128 Code B charset. */
const UP_BARCODE_CODE128_CHARS: string =
  ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

/** 上游 getCode128Pattern() 的 107 项模式表，下标即码值。/ Upstream CODE128 pattern table. */
const UP_BARCODE_CODE128_PATTERNS: Array<string> = [
  '11011001100', '11001101100', '11001100110', '10010011000',
  '10010001100', '10001001100', '10011001000', '10011000100',
  '10001100100', '11001001000', '11001000100', '11000100100',
  '10110011100', '10011011100', '10011001110', '10111001100',
  '10011101100', '10011100110', '11001110010', '11001011100',
  '11001001110', '11011100100', '11001110100', '11101101110',
  '11101001100', '11100101100', '11100100110', '11101100100',
  '11100110100', '11100110010', '11011011000', '11011000110',
  '11000110110', '10100011000', '10001011000', '10001000110',
  '10110001000', '10001101000', '10001100010', '11010001000',
  '11000101000', '11000100010', '10110111000', '10110001110',
  '10001101110', '10111011000', '10111000110', '10001110110',
  '11101110110', '11010001110', '11000101110', '11011101000',
  '11011100010', '11011101110', '11101011000', '11101000110',
  '11100010110', '11101101000', '11101100010', '11100011010',
  '11101111010', '11001000010', '11110001010', '10100110000',
  '10100001100', '10010110000', '10010000110', '10000101100',
  '10000100110', '10110010000', '10110000100', '10011010000',
  '10011000010', '10000110100', '10000110010', '11000010010',
  '11001010000', '11110111010', '11000010100', '10001111010',
  '10100111100', '10010111100', '10010011110', '10111100100',
  '10011110100', '10011110010', '11110100100', '11110010100',
  '11110010010', '11011011110', '11011110110', '11110110110',
  '10101111000', '10100011110', '10001011110', '10111101000',
  '10111100010', '11110101000', '11110100010', '10111011110',
  '10111101110', '11101011110', '11110101110', '11010000100',
  '11010010000', '11010011100', '11000111010'
];

/** CODE39 字符表，与 UP_BARCODE_CODE39_PATTERNS 一一对应。/ CODE39 charset paired with the pattern table. */
const UP_BARCODE_CODE39_CHARS: string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. *$/+%';

/** 上游 encodeCode39() 的字符模式表，每项 15 位。/ Upstream CODE39 pattern table. */
const UP_BARCODE_CODE39_PATTERNS: Array<string> = [
  '101000111011101', '111010001010111', '101110001010111', '111011100010101',
  '101000111010111', '111010001110101', '101110001110101', '101000101110111',
  '111010001011101', '101110001011101', '111010100010111', '101110100010111',
  '111011101000101', '101011100010111', '111010111000101', '101110111000101',
  '101010001110111', '111010100011101', '101110100011101', '101011100011101',
  '111010101000111', '101110101000111', '111011101010001', '101011101000111',
  '111010111010001', '101110111010001', '101010111000111', '111010101110001',
  '101110101110001', '101011101110001', '111000101010111', '100011101010111',
  '111000111010101', '100010111010111', '111000101110101', '100011101110101',
  '100010101110111', '111000101011101', '100011101011101', '100010111011101',
  '100010001000101', '100010001010001', '100010100010001', '101000100010001'
];

/** 上游 leftOdd：EAN/UPC 左侧奇校验编码。/ Upstream leftOdd table. */
const UP_BARCODE_LEFT_ODD: Array<string> = [
  '0001101', '0011001', '0010011', '0111101', '0100011',
  '0110001', '0101111', '0111011', '0110111', '0001011'
];

/** 上游 leftEven：EAN/UPC 左侧偶校验编码。/ Upstream leftEven table. */
const UP_BARCODE_LEFT_EVEN: Array<string> = [
  '0100111', '0110011', '0011011', '0100001', '0011101',
  '0111001', '0000101', '0010001', '0001001', '0010111'
];

/** 上游 rightCodes：EAN/UPC 右侧编码。/ Upstream rightCodes table. */
const UP_BARCODE_RIGHT: Array<string> = [
  '1110010', '1100110', '1101100', '1000010', '1011100',
  '1001110', '1010000', '1000100', '1001000', '1110100'
];

/** 上游 leftPatterns[0]：EAN13 首位决定的左侧奇偶排布。/ Upstream leftPatterns[0]. */
const UP_BARCODE_EAN13_PATTERNS: Array<string> = [
  'LLLLLL', 'LLGLGG', 'LLGGLG', 'LLGGGL', 'LGLLGG',
  'LGGLLG', 'LGGGLL', 'LGLGLG', 'LGLGGL', 'LGGLGL'
];

/** 上游 format 校验器允许的取值。/ The formats accepted by the upstream validator. */
const UP_BARCODE_FORMATS: Array<string> = [
  'auto',
  'CODE128', 'CODE128A', 'CODE128B', 'CODE128C',
  'EAN13', 'EAN8', 'EAN5', 'EAN2',
  'UPC', 'UPCA', 'UPCE',
  'CODE39',
  'ITF', 'ITF14',
  'MSI', 'MSI10', 'MSI11', 'MSI1010', 'MSI1110',
  'pharmacode',
  'codabar'
];

/** 编码结果：pattern 为 0/1 串，error 非空表示上游会 throw 的场景。/ Encoding result replacing upstream throw. */
export interface UPBarcodeEncodeResult {
  pattern: string;
  error: string;
}

/** rendered 事件载荷，合并上游 canvas 与 image 两种形态。/ Payload of the upstream rendered event. */
export interface UPBarcodeRenderedEvent {
  type: string;
  id: string;
  value: string;
  path: string;
}

/** 上游 format 校验器。/ Mirrors the upstream format validator. */
export function upBarcodeFormatSupported(format: string): boolean {
  return UP_BARCODE_FORMATS.includes(format);
}

/** 上游 getCode128Pattern()：越界返回空串。/ Upstream getCode128Pattern(). */
export function upBarcodeCode128Pattern(code: number): string {
  if (code < 0 || code >= UP_BARCODE_CODE128_PATTERNS.length) {
    return '';
  }
  return UP_BARCODE_CODE128_PATTERNS[code];
}

/** 全数字校验，替代上游的 `^\d{n}$` 正则。/ Digit-only check replacing the upstream regexp. */
function upBarcodeDigits(value: string, length: number): boolean {
  if (value.length !== length) {
    return false;
  }
  for (let index: number = 0; index < value.length; index += 1) {
    const code: number = value.charCodeAt(index);
    if (code < 48 || code > 57) {
      return false;
    }
  }
  return true;
}

/** 单个数字字符转数值。/ Parses one digit character. */
function upBarcodeDigitAt(value: string, index: number): number {
  return value.charCodeAt(index) - 48;
}

/** 上游 encodeCode128()：Code B 全字符集，尾部补 5 个模块的安静区。/ Upstream encodeCode128(). */
export function upBarcodeCode128(data: string): UPBarcodeEncodeResult {
  const codes: Array<number> = [];
  let checksum: number = UP_BARCODE_CODE128_START_B;
  codes.push(UP_BARCODE_CODE128_START_B);
  for (let index: number = 0; index < data.length; index += 1) {
    const char: string = data.charAt(index);
    const code: number = UP_BARCODE_CODE128_CHARS.indexOf(char);
    if (code === -1) {
      return { pattern: '', error: `Invalid character in CODE128: ${char}` };
    }
    codes.push(code);
    checksum += code * (index + 1);
  }
  codes.push(checksum % 103);
  codes.push(UP_BARCODE_CODE128_STOP);
  let barcode: string = '';
  for (let index: number = 0; index < codes.length; index += 1) {
    barcode += upBarcodeCode128Pattern(codes[index]);
  }
  barcode += '00000';
  return { pattern: barcode, error: '' };
}

/** 上游 encodeCode39()：大写化后以 `*` 包裹，字符间插入一个窄空。/ Upstream encodeCode39(). */
export function upBarcodeCode39(data: string): UPBarcodeEncodeResult {
  const source: string = data.toUpperCase();
  const stopIndex: number = UP_BARCODE_CODE39_CHARS.indexOf('*');
  let barcode: string = UP_BARCODE_CODE39_PATTERNS[stopIndex];
  for (let index: number = 0; index < source.length; index += 1) {
    const char: string = source.charAt(index);
    const position: number = UP_BARCODE_CODE39_CHARS.indexOf(char);
    if (position === -1) {
      return { pattern: '', error: `Invalid character in CODE39: ${char}` };
    }
    barcode += '0';
    barcode += UP_BARCODE_CODE39_PATTERNS[position];
  }
  barcode += '0';
  barcode += UP_BARCODE_CODE39_PATTERNS[stopIndex];
  return { pattern: barcode, error: '' };
}

/** 上游 encodeEAN13()：校验位必须自洽，左侧按首位查表决定奇偶。/ Upstream encodeEAN13(). */
export function upBarcodeEan13(data: string): UPBarcodeEncodeResult {
  if (!upBarcodeDigits(data, 13)) {
    return { pattern: '', error: 'EAN13 must be 13 digits' };
  }
  let sum: number = 0;
  for (let index: number = 0; index < 12; index += 1) {
    const digit: number = upBarcodeDigitAt(data, index);
    sum += index % 2 === 0 ? digit : digit * 3;
  }
  const checkDigit: number = (10 - (sum % 10)) % 10;
  if (upBarcodeDigitAt(data, 12) !== checkDigit) {
    return { pattern: '', error: 'Invalid EAN13 check digit' };
  }
  const pattern: string = UP_BARCODE_EAN13_PATTERNS[upBarcodeDigitAt(data, 0)];
  let barcode: string = '101';
  for (let index: number = 0; index < 6; index += 1) {
    const digit: number = upBarcodeDigitAt(data, index + 1);
    barcode += pattern.charAt(index) === 'L' ? UP_BARCODE_LEFT_ODD[digit] : UP_BARCODE_LEFT_EVEN[digit];
  }
  barcode += '01010';
  for (let index: number = 0; index < 6; index += 1) {
    barcode += UP_BARCODE_RIGHT[upBarcodeDigitAt(data, index + 7)];
  }
  barcode += '101';
  return { pattern: barcode, error: '' };
}

/** 上游 encodeEAN8()：左侧四位全部使用奇校验表。/ Upstream encodeEAN8(). */
export function upBarcodeEan8(data: string): UPBarcodeEncodeResult {
  if (!upBarcodeDigits(data, 8)) {
    return { pattern: '', error: 'EAN8 must be 8 digits' };
  }
  let sum: number = 0;
  for (let index: number = 0; index < 7; index += 1) {
    sum += upBarcodeDigitAt(data, index) * (index % 2 === 0 ? 3 : 1);
  }
  const checkDigit: number = (10 - (sum % 10)) % 10;
  if (upBarcodeDigitAt(data, 7) !== checkDigit) {
    return { pattern: '', error: 'Invalid EAN8 check digit' };
  }
  let barcode: string = '101';
  for (let index: number = 0; index < 4; index += 1) {
    barcode += UP_BARCODE_LEFT_ODD[upBarcodeDigitAt(data, index)];
  }
  barcode += '01010';
  for (let index: number = 0; index < 4; index += 1) {
    barcode += UP_BARCODE_RIGHT[upBarcodeDigitAt(data, index + 4)];
  }
  barcode += '101';
  return { pattern: barcode, error: '' };
}

/**
 * 上游 encodeEAN52()：算出 pattern 后并未参与编码，附加码始终按奇校验表拼接，本端照实复刻该缺陷。
 * Mirrors upstream encodeEAN52(), including the computed-but-unused parity pattern.
 */
export function upBarcodeEan52(data: string, format: string): UPBarcodeEncodeResult {
  const length: number = format === 'EAN5' ? 5 : 2;
  if (!upBarcodeDigits(data, length)) {
    return { pattern: '', error: `${format} must be ${length} digits` };
  }
  let barcode: string = '1011';
  for (let index: number = 0; index < data.length; index += 1) {
    if (index > 0) {
      barcode += '01';
    }
    barcode += UP_BARCODE_LEFT_ODD[upBarcodeDigitAt(data, index)];
  }
  return { pattern: barcode, error: '' };
}

/** 上游 encodeUPCA()：11 位自动补校验位，随后按 EAN13 编码。/ Upstream encodeUPCA(). */
export function upBarcodeUpca(data: string): UPBarcodeEncodeResult {
  let source: string = data;
  if (upBarcodeDigits(source, 11)) {
    let sum: number = 0;
    for (let index: number = 0; index < 11; index += 1) {
      const digit: number = upBarcodeDigitAt(source, index);
      sum += index % 2 === 0 ? digit * 3 : digit;
    }
    source += String((10 - (sum % 10)) % 10);
  }
  if (!upBarcodeDigits(source, 12)) {
    return { pattern: '', error: 'UPC-A must be 11 or 12 digits' };
  }
  return upBarcodeEan13(`0${source}`);
}

/**
 * 上游 encodeUPCE()：只绘制中间 6 位与两侧定位符，系统位与右侧数据都没有落到码图上。
 * Mirrors upstream encodeUPCE(), which never renders the system digit nor the right half.
 */
export function upBarcodeUpce(data: string): UPBarcodeEncodeResult {
  let source: string = data;
  if (upBarcodeDigits(source, 7)) {
    let sum: number = 0;
    for (let index: number = 0; index < 7; index += 1) {
      const digit: number = upBarcodeDigitAt(source, index);
      sum += index % 2 === 0 ? digit * 3 : digit;
    }
    source += String((10 - (sum % 10)) % 10);
  }
  if (!upBarcodeDigits(source, 8)) {
    return { pattern: '', error: 'UPC-E must be 7 or 8 digits' };
  }
  const system: string = source.charAt(0);
  if (system !== '0' && system !== '1') {
    return { pattern: '', error: 'UPC-E must start with 0 or 1' };
  }
  const checkDigit: string = source.charAt(7);
  let pattern: string = 'EEOOOO';
  if (checkDigit === '0' || checkDigit === '1' || checkDigit === '2' || checkDigit === '3') {
    pattern = 'EEEEOO';
  } else if (checkDigit === '4') {
    pattern = 'EEEOOO';
  }
  let barcode: string = '101';
  for (let index: number = 0; index < 6; index += 1) {
    const digit: number = upBarcodeDigitAt(source, index + 1);
    barcode += pattern.charAt(index) === 'E' ? UP_BARCODE_LEFT_EVEN[digit] : UP_BARCODE_LEFT_ODD[digit];
  }
  barcode += '010101';
  barcode += '101';
  return { pattern: barcode, error: '' };
}

/**
 * 上游 encodeBarcode()：switch 只实现 CODE128/CODE39/EAN13/EAN8/EAN5/EAN2/UPC/UPCA/UPCE，
 * 其余通过校验器的格式（ITF、MSI、pharmacode、codabar）全部回落 CODE128。
 * Mirrors upstream encodeBarcode(); unimplemented formats fall back to CODE128.
 */
export function upBarcodeEncode(value: string, format: string): UPBarcodeEncodeResult {
  if (format === 'CODE39') {
    return upBarcodeCode39(value);
  }
  if (format === 'EAN13') {
    return upBarcodeEan13(value);
  }
  if (format === 'EAN8') {
    return upBarcodeEan8(value);
  }
  if (format === 'EAN5' || format === 'EAN2') {
    return upBarcodeEan52(value, format);
  }
  if (format === 'UPC' || format === 'UPCA') {
    return upBarcodeUpca(value);
  }
  if (format === 'UPCE') {
    return upBarcodeUpce(value);
  }
  return upBarcodeCode128(value);
}

export interface UPBarcodeOptions {
  value?: UPRawValue;
  format?: UPRawValue;
  width?: UPRawValue;
  height?: UPRawValue;
  displayValue?: UPRawValue;
  text?: UPRawValue;
  fontOptions?: UPRawValue;
  font?: UPRawValue;
  textAlign?: UPRawValue;
  textPosition?: UPRawValue;
  textMargin?: UPRawValue;
  fontSize?: UPRawValue;
  background?: UPRawValue;
  lineColor?: UPRawValue;
  margin?: UPRawValue;
  marginTop?: UPRawValue;
  marginBottom?: UPRawValue;
  marginLeft?: UPRawValue;
  marginRight?: UPRawValue;
  useCanvas?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onRendered?: (event: UPBarcodeRenderedEvent) => void;
  onError?: (message: string) => void;
}

export class UPBarcodeProps {
  value: UPRawValue = '';
  format: UPRawValue = 'auto';
  width: UPRawValue = 200;
  height: UPRawValue = 80;
  displayValue: UPRawValue = true;
  text: UPRawValue = undefined;
  fontOptions: UPRawValue = '';
  font: UPRawValue = 'monospace';
  textAlign: UPRawValue = 'center';
  textPosition: UPRawValue = 'bottom';
  textMargin: UPRawValue = 2;
  fontSize: UPRawValue = 14;
  background: UPRawValue = '#ffffff';
  lineColor: UPRawValue = '#000000';
  margin: UPRawValue = 10;
  marginTop: UPRawValue = undefined;
  marginBottom: UPRawValue = undefined;
  marginLeft: UPRawValue = undefined;
  marginRight: UPRawValue = undefined;
  useCanvas: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onRendered?: (event: UPBarcodeRenderedEvent) => void;
  onError?: (message: string) => void;

  constructor(options?: UPBarcodeOptions) {
    if (options === undefined) {
      return;
    }
    this.value = options.value ?? this.value;
    this.format = options.format ?? this.format;
    this.width = options.width ?? this.width;
    this.height = options.height ?? this.height;
    this.displayValue = options.displayValue ?? this.displayValue;
    this.text = options.text;
    this.fontOptions = options.fontOptions ?? this.fontOptions;
    this.font = options.font ?? this.font;
    this.textAlign = options.textAlign ?? this.textAlign;
    this.textPosition = options.textPosition ?? this.textPosition;
    this.textMargin = options.textMargin ?? this.textMargin;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.background = options.background ?? this.background;
    this.lineColor = options.lineColor ?? this.lineColor;
    this.margin = options.margin ?? this.margin;
    this.marginTop = options.marginTop;
    this.marginBottom = options.marginBottom;
    this.marginLeft = options.marginLeft;
    this.marginRight = options.marginRight;
    this.useCanvas = options.useCanvas ?? this.useCanvas;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onRendered = options.onRendered;
    this.onError = options.onError;
  }
}

@Component
export struct UPBarcode {
  @Prop @Watch('applyProps') props: UPBarcodeProps = new UPBarcodeProps();
  /** 上游 error：非空时以灰底红字替代码图。/ Upstream error state. */
  @State private failure: string = '';
  private canvasId: string = '';
  private ready: boolean = false;
  private applied: string = '';
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    this.canvasId = `barcode-${Math.floor(Math.random() * 1000000000).toString(36)}`;
    this.applied = this.signature();
    const format: string = this.format();
    if (!upBarcodeFormatSupported(format)) {
      diagnostics.report('UPBarcode', 'format', format, 'the value is outside the upstream validator whitelist and is encoded as CODE128');
    } else if (format !== 'auto' && format !== 'CODE128' && format !== 'CODE39' && format !== 'EAN13'
      && format !== 'EAN8' && format !== 'EAN5' && format !== 'EAN2' && format !== 'UPC'
      && format !== 'UPCA' && format !== 'UPCE') {
      diagnostics.report('UPBarcode', 'format', format, 'upstream accepts the format but its switch has no branch, so CODE128 is used');
    }
    if (upString(this.props.font, 'monospace') !== 'monospace' || upString(this.props.fontOptions, '').length > 0) {
      diagnostics.report('UPBarcode', 'font', this.props.font, 'upstream never applies font/fontOptions to the canvas context, so only fontSize takes effect');
    }
    if (!upBoolean(this.props.useCanvas, true)) {
      diagnostics.report('UPBarcode', 'useCanvas', this.props.useCanvas, 'toTempFilePath is unavailable; the image branch reports a base64 data URL instead');
    }
  }

  /** 上游 12 个 watch 的合并实现：任何影响像素的入参变化都重绘。/ Merges the twelve upstream watchers. */
  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.generate();
  }

  private signature(): string {
    const parts: Array<string> = [
      upString(this.props.value, ''),
      this.format(),
      String(this.barWidth()),
      String(this.barHeight()),
      String(upBoolean(this.props.displayValue, true)),
      this.label(),
      upString(this.props.font, 'monospace'),
      String(this.textSize()),
      this.foreground(),
      this.backdrop(),
      String(upNumber(this.props.margin, 10)),
      String(this.marginTop()),
      String(this.marginBottom()),
      String(this.marginLeft()),
      String(this.marginRight()),
      this.textSpot(),
      this.alignment(),
      String(this.textGap()),
      String(upBoolean(this.props.useCanvas, true))
    ];
    return parts.join('|');
  }

  private format(): string {
    const value: string = upString(this.props.format, 'auto').trim();
    return value.length === 0 ? 'auto' : value;
  }

  private barWidth(): number {
    return upNumber(this.props.width, 200);
  }

  private barHeight(): number {
    return upNumber(this.props.height, 80);
  }

  /** 上游 `this.fontSize || 20`：0 与空串都落到 20。/ Mirrors the upstream `fontSize || 20` fallback. */
  private textSize(): number {
    const size: number = upNumber(this.props.fontSize, 14);
    return Number.isFinite(size) && size !== 0 ? size : 20;
  }

  private textGap(): number {
    return upNumber(this.props.textMargin, 2);
  }

  private label(): string {
    const custom: string = upString(this.props.text, '');
    return custom.length > 0 ? custom : upString(this.props.value, '');
  }

  private textSpot(): string {
    const value: string = upString(this.props.textPosition, 'bottom').trim();
    return value.length === 0 ? 'bottom' : value;
  }

  private alignment(): string {
    const value: string = upString(this.props.textAlign, 'center').trim();
    return value.length === 0 ? 'center' : value;
  }

  private backdrop(): string {
    const value: string = upString(this.props.background, '#ffffff').trim();
    return value.length === 0 ? '#ffffff' : value;
  }

  private foreground(): string {
    const value: string = upString(this.props.lineColor, '#000000').trim();
    return value.length === 0 ? '#000000' : value;
  }

  /** 上游 `marginTop !== undefined ? marginTop : margin`。/ Mirrors the upstream per-edge fallback. */
  private marginTop(): number {
    return this.props.marginTop === undefined ? upNumber(this.props.margin, 10) : upNumber(this.props.marginTop, 10);
  }

  private marginBottom(): number {
    return this.props.marginBottom === undefined
      ? upNumber(this.props.margin, 10)
      : upNumber(this.props.marginBottom, 10);
  }

  private marginLeft(): number {
    return this.props.marginLeft === undefined ? upNumber(this.props.margin, 10) : upNumber(this.props.marginLeft, 10);
  }

  private marginRight(): number {
    return this.props.marginRight === undefined
      ? upNumber(this.props.margin, 10)
      : upNumber(this.props.marginRight, 10);
  }

  /** 上游 textHeight：不显示文本时为 0。/ Upstream textHeight. */
  private textBand(): number {
    return upBoolean(this.props.displayValue, true) ? this.textSize() + this.textGap() : 0;
  }

  /** 上游 calculateCanvasSize()：宽度不低于 100，高度不低于 `60 + textHeight`。/ Upstream calculateCanvasSize(). */
  private boxWidth(): number {
    const total: number = this.barWidth() + this.marginLeft() + this.marginRight();
    return Math.max(total, 100);
  }

  private boxHeight(): number {
    const band: number = this.textBand();
    const position: string = this.textSpot();
    const base: number = position === 'top' || position === 'bottom' ? this.barHeight() + band : this.barHeight();
    const total: number = base + this.marginTop() + this.marginBottom();
    return Math.max(total, 60 + band);
  }

  private handleReady(): void {
    this.ready = true;
    this.generate();
  }

  /** 上游 generateBarcode()：铺底后编码并绘制，失败时切到错误态。/ Mirrors upstream generateBarcode(). */
  private generate(): void {
    if (!this.ready) {
      return;
    }
    const canvasWidth: number = this.boxWidth();
    const canvasHeight: number = this.boxHeight();
    this.renderContext.clearRect(0, 0, canvasWidth, canvasHeight);
    this.renderContext.fillStyle = this.backdrop();
    this.renderContext.fillRect(0, 0, canvasWidth, canvasHeight);
    const encoded: UPBarcodeEncodeResult = upBarcodeEncode(upString(this.props.value, ''), this.format());
    if (encoded.error.length > 0) {
      this.failure = encoded.error;
      const callback: ((message: string) => void) | undefined = this.props.onError;
      if (callback !== undefined) {
        callback(encoded.error);
      }
      return;
    }
    this.failure = '';
    if (encoded.pattern.length > 0) {
      this.drawBars(encoded.pattern, canvasWidth, canvasHeight);
    }
    this.emitRendered(canvasWidth, canvasHeight);
  }

  /** 上游 drawBarcode()：按总模块数摊平宽度，随后按 textPosition 落文本。/ Mirrors upstream drawBarcode(). */
  private drawBars(pattern: string, canvasWidth: number, canvasHeight: number): void {
    const left: number = this.marginLeft();
    const right: number = this.marginRight();
    const band: number = this.textBand();
    const barHeight: number = this.barHeight();
    const rightGap: number = right === 0 ? 10 : right;
    const moduleWidth: number = Math.max(1, (canvasWidth - left - rightGap) / pattern.length);
    this.renderContext.fillStyle = this.foreground();
    const position: string = this.textSpot();
    const showText: boolean = upBoolean(this.props.displayValue, true);
    let barTop: number = this.marginTop();
    if (showText && position === 'top') {
      barTop += band;
    }
    let cursor: number = left;
    for (let index: number = 0; index < pattern.length; index += 1) {
      if (pattern.charAt(index) === '1') {
        this.renderContext.fillRect(cursor, barTop, moduleWidth, barHeight);
      }
      cursor += moduleWidth;
    }
    if (!showText) {
      return;
    }
    const fontSize: number = this.textSize();
    const alignment: string = this.alignment();
    this.renderContext.fillStyle = this.foreground();
    this.renderContext.font = `${fontSize}px sans-serif`;
    this.renderContext.textAlign = upCanvasTextAlign(alignment);
    let textX: number = canvasWidth / 2;
    if (alignment === 'left') {
      textX = left;
    } else if (alignment === 'right') {
      textX = canvasWidth - right;
    }
    let textY: number = barTop + barHeight + this.textGap() + fontSize;
    if (position === 'top') {
      textY = this.marginTop() + fontSize - 3;
    } else if (textY > canvasHeight - this.marginBottom()) {
      textY = canvasHeight - this.marginBottom() - 2;
    }
    this.renderContext.fillText(this.label(), textX, textY);
  }

  /** 上游 rendered：canvas 分支回传 canvasId，image 分支回传导出路径。/ Mirrors the upstream rendered event. */
  private emitRendered(canvasWidth: number, canvasHeight: number): void {
    const callback: ((event: UPBarcodeRenderedEvent) => void) | undefined = this.props.onRendered;
    if (callback === undefined) {
      return;
    }
    if (upBoolean(this.props.useCanvas, true)) {
      callback({ type: 'canvas', id: this.canvasId, value: upString(this.props.value, ''), path: '' });
      return;
    }
    let dataUrl: string = '';
    try {
      dataUrl = this.renderContext.toDataURL('image/png', 1);
    } catch (_) {
      dataUrl = '';
    }
    if (dataUrl.length === 0) {
      const failed: ((message: string) => void) | undefined = this.props.onError;
      if (failed !== undefined) {
        failed('生成条码图片失败');
      }
      return;
    }
    callback({ type: 'image', id: this.canvasId, value: upString(this.props.value, ''), path: dataUrl });
  }

  @Builder
  private errorBox() {
    Column() {
      Text(this.failure)
        .fontSize(14)
        .fontColor('#ff0000')
        .textAlign(TextAlign.Center)
    }
    .width(this.boxWidth())
    .height(this.boxHeight())
    .backgroundColor('#f0f0f0')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.renderContext)
        .width(this.boxWidth())
        .height(this.boxHeight())
        .backgroundColor('transparent')
        .onReady((): void => this.handleReady())
      if (this.failure.length > 0) {
        this.errorBox()
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? this.boxWidth())
    .height(UPStyle.parse(this.props.customStyle).height ?? this.boxHeight())
  }
}
