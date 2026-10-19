import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPColor } from '../core/UPColor';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';

/** 上游默认字号，measureText 兜底估算时使用。/ Upstream default font size used by the fallback measurement. */
export const UP_CANVAS_DEFAULT_FONT_SIZE: number = 12;

/** 上游默认字体族。/ Upstream default font family. */
export const UP_CANVAS_DEFAULT_FONT_FAMILY: string = 'sans-serif';

/** measureText 的具名返回值，替代上游的匿名对象。/ Named metrics instead of an anonymous object. */
export interface UPCanvasTextMetrics {
  width: number;
}

/** 触摸事件载荷，坐标相对画布左上角。/ Touch payload relative to the canvas origin. */
export interface UPCanvasTouchEvent {
  x: number;
  y: number;
  type: string;
}

/** getImageData 的具名入参。/ Named options for getImageData. */
export interface UPCanvasImageDataOptions {
  x?: number;
  y?: number;
  width?: number;
  height?: number;
}

/** putImageData 的具名入参。/ Named options for putImageData. */
export interface UPCanvasPutImageDataOptions {
  data: ImageData;
  x?: number;
  y?: number;
}

/** 上游随机 canvasId 的等价实现，宿主需要唯一标识时可用。/ Mirrors the upstream random canvasId. */
export function upCanvasId(): string {
  return `u-canvas${Math.floor(Math.random() * 1000000)}`;
}

/**
 * 上游 parseSize + `actualWidth + unit` 的合并换算：先解析尺寸字面量，再按组件 unit 落到 px。
 * Mirrors upstream parseSize() followed by the CSS unit suffix, resolving to device-independent pixels.
 */
export function upCanvasParseSize(value: UPRawValue, unit: string = 'px', viewportWidth: number = 375): number {
  let base: number = 0;
  if (typeof value === 'number') {
    base = Number.isFinite(value) ? value : 0;
  } else {
    const source: string = upString(value, '').trim();
    const magnitude: number = parseFloat(source);
    const numeric: number = Number.isFinite(magnitude) ? magnitude : 0;
    base = source.endsWith('rpx') || source.endsWith('upx')
      ? UPUnit.parse(`${numeric}rpx`, viewportWidth, numeric / 2)
      : numeric;
  }
  const suffix: string = unit.trim().toLowerCase();
  if (suffix === 'rpx' || suffix === 'upx') {
    return UPUnit.parse(`${base}rpx`, viewportWidth, base / 2);
  }
  return base;
}

/** unit 白名单，ArkUI 只能落到 px 语义。/ Whitelist of units ArkUI can honour. */
export function upCanvasUnitSupported(unit: string): boolean {
  const suffix: string = unit.trim().toLowerCase();
  return suffix.length === 0 || suffix === 'px' || suffix === 'rpx' || suffix === 'upx';
}

/** lineCap 字符串到 CanvasLineCap 的映射。/ Maps the upstream string to CanvasLineCap. */
export function upCanvasLineCap(value: string): CanvasLineCap {
  if (value === 'butt') {
    return 'butt';
  }
  if (value === 'square') {
    return 'square';
  }
  return 'round';
}

/** lineJoin 字符串到 CanvasLineJoin 的映射。/ Maps the upstream string to CanvasLineJoin. */
export function upCanvasLineJoin(value: string): CanvasLineJoin {
  if (value === 'bevel') {
    return 'bevel';
  }
  if (value === 'miter') {
    return 'miter';
  }
  return 'round';
}

/** textAlign 字符串到 CanvasTextAlign 的映射。/ Maps the upstream string to CanvasTextAlign. */
export function upCanvasTextAlign(value: string): CanvasTextAlign {
  if (value === 'center') {
    return 'center';
  }
  if (value === 'right') {
    return 'right';
  }
  if (value === 'start') {
    return 'start';
  }
  if (value === 'end') {
    return 'end';
  }
  return 'left';
}

/** textBaseline 字符串到 CanvasTextBaseline 的映射。/ Maps the upstream string to CanvasTextBaseline. */
export function upCanvasTextBaseline(value: string): CanvasTextBaseline {
  if (value === 'top') {
    return 'top';
  }
  if (value === 'bottom') {
    return 'bottom';
  }
  if (value === 'middle') {
    return 'middle';
  }
  if (value === 'hanging') {
    return 'hanging';
  }
  if (value === 'ideographic') {
    return 'ideographic';
  }
  return 'alphabetic';
}

/** direction 字符串到 CanvasDirection 的映射。/ Maps the upstream string to CanvasDirection. */
export function upCanvasDirection(value: string): CanvasDirection {
  if (value === 'ltr') {
    return 'ltr';
  }
  if (value === 'rtl') {
    return 'rtl';
  }
  return 'inherit';
}

/** fillRule 字符串到 CanvasFillRule 的映射。/ Maps the upstream string to CanvasFillRule. */
export function upCanvasFillRule(value: string): CanvasFillRule {
  return value === 'evenodd' ? 'evenodd' : 'nonzero';
}

/** 只允许本地图片进入 drawImage。/ Only local sources may enter drawImage. */
export function isLocalCanvasSource(value: string): boolean {
  return value.startsWith('resource://') || value.startsWith('file://')
    || value.startsWith('/') || value.startsWith('$rawfile:');
}

/**
 * 上游 estimateTextWidth：全角按一个字号、空白按 0.28、其余按 0.56 估算。
 * Mirrors upstream estimateTextWidth so Chinese text never measures 40% short.
 */
export function upCanvasEstimateTextWidth(text: string, fontSize: number = UP_CANVAS_DEFAULT_FONT_SIZE): number {
  const size: number = Number.isFinite(fontSize) && fontSize > 0 ? fontSize : UP_CANVAS_DEFAULT_FONT_SIZE;
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
    const char: string = text.charAt(index);
    if (fullWidth.test(char)) {
      width += size;
    } else if (blank.test(char)) {
      width += size * 0.28;
    } else {
      width += size * 0.56;
    }
    index += 1;
  }
  return width;
}

/**
 * 绘制面板：把上游 u-canvas 的实例方法搬到独立对象上，宿主 new 出来传进 props 即可复用上游绘制代码。
 * Drawing surface exposing the upstream u-canvas instance methods on a standalone object.
 */
export class UPCanvasSurface {
  /** 是否已经绑定到画布。/ Whether a renderer is attached. */
  ready: boolean = false;
  /** clearCanvas 铺底色，由组件按 props 同步。/ Background used by clearCanvas. */
  bgColor: string = '#ffffff';
  /** 兼容性诊断收集器，由组件按 props 同步。/ Diagnostics sink synced by the component. */
  diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  private renderer?: CanvasRenderingContext2D = undefined;
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private fontSize: number = UP_CANVAS_DEFAULT_FONT_SIZE;
  private fontFamily: string = UP_CANVAS_DEFAULT_FONT_FAMILY;
  private fontWeight: string = 'normal';

  /** 绑定 ArkUI 渲染上下文。/ Attaches the ArkUI rendering context. */
  attach(renderer: CanvasRenderingContext2D, width: number, height: number): void {
    this.renderer = renderer;
    this.canvasWidth = width;
    this.canvasHeight = height;
    this.ready = true;
  }

  /** 解绑，组件销毁时调用。/ Detaches on component teardown. */
  detach(): void {
    this.renderer = undefined;
    this.ready = false;
  }

  getWidth(): number {
    return this.canvasWidth;
  }

  getHeight(): number {
    return this.canvasHeight;
  }

  /** 上游 refresh()：ArkUI 上等价于重铺底色。/ Upstream refresh(), equivalent to repainting the background. */
  refresh(): void {
    this.clearCanvas();
  }

  /** 上游 clearCanvas()：清屏后按 bgColor 铺底。/ Mirrors upstream clearCanvas(). */
  clearCanvas(): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    if (this.bgColor.length > 0 && this.bgColor !== 'transparent') {
      renderer.beginPath();
      renderer.rect(0, 0, this.canvasWidth, this.canvasHeight);
      renderer.fillStyle = this.bgColor;
      renderer.fill();
    }
  }

  rect(x: number, y: number, width: number, height: number): void {
    this.renderer?.rect(x, y, width, height);
  }

  clearRect(x: number, y: number, width: number, height: number): void {
    this.renderer?.clearRect(x, y, width, height);
  }

  fillRect(x: number, y: number, width: number, height: number): void {
    this.renderer?.fillRect(x, y, width, height);
  }

  strokeRect(x: number, y: number, width: number, height: number): void {
    this.renderer?.strokeRect(x, y, width, height);
  }

  fill(fillRule: string = 'nonzero'): void {
    this.renderer?.fill(upCanvasFillRule(fillRule));
  }

  stroke(): void {
    this.renderer?.stroke();
  }

  beginPath(): void {
    this.renderer?.beginPath();
  }

  closePath(): void {
    this.renderer?.closePath();
  }

  moveTo(x: number, y: number): void {
    this.renderer?.moveTo(x, y);
  }

  lineTo(x: number, y: number): void {
    this.renderer?.lineTo(x, y);
  }

  arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, anticlockwise: boolean = false): void {
    this.renderer?.arc(x, y, radius, startAngle, endAngle, anticlockwise);
  }

  arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): void {
    this.renderer?.arcTo(x1, y1, x2, y2, radius);
  }

  bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): void {
    this.renderer?.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
  }

  quadraticCurveTo(cpx: number, cpy: number, x: number, y: number): void {
    this.renderer?.quadraticCurveTo(cpx, cpy, x, y);
  }

  ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number,
    startAngle: number, endAngle: number, anticlockwise: boolean = false): void {
    this.renderer?.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise);
  }

  clip(fillRule: string = 'nonzero'): void {
    this.renderer?.clip(upCanvasFillRule(fillRule));
  }

  save(): void {
    this.renderer?.save();
  }

  restore(): void {
    this.renderer?.restore();
  }

  translate(x: number, y: number): void {
    this.renderer?.translate(x, y);
  }

  rotate(angle: number): void {
    this.renderer?.rotate(angle);
  }

  scale(x: number, y: number): void {
    this.renderer?.scale(x, y);
  }

  setTransform(a: number, b: number, c: number, d: number, e: number, f: number): void {
    this.renderer?.setTransform(a, b, c, d, e, f);
  }

  transform(a: number, b: number, c: number, d: number, e: number, f: number): void {
    this.renderer?.transform(a, b, c, d, e, f);
  }

  resetTransform(): void {
    this.renderer?.resetTransform();
  }

  setFillStyle(color: string): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.fillStyle = color;
  }

  setStrokeStyle(color: string): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.strokeStyle = color;
  }

  /** ArkTS 补充：渐变只能通过对象赋值。/ ArkTS addition: gradients cannot be passed as strings. */
  setFillGradient(gradient: CanvasGradient): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.fillStyle = gradient;
  }

  /** ArkTS 补充：渐变只能通过对象赋值。/ ArkTS addition: gradients cannot be passed as strings. */
  setStrokeGradient(gradient: CanvasGradient): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.strokeStyle = gradient;
  }

  setLineWidth(lineWidth: number): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.lineWidth = lineWidth;
  }

  setLineCap(lineCap: string = 'round'): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.lineCap = upCanvasLineCap(lineCap);
  }

  setLineJoin(lineJoin: string = 'round'): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.lineJoin = upCanvasLineJoin(lineJoin);
  }

  setMiterLimit(miterLimit: number): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.miterLimit = miterLimit;
  }

  setLineDash(segments: Array<number> = []): void {
    this.renderer?.setLineDash(segments);
  }

  getLineDash(): Array<number> {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return [];
    }
    return renderer.getLineDash();
  }

  setTextAlign(align: string = 'left'): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.textAlign = upCanvasTextAlign(align);
  }

  setTextBaseline(baseline: string = 'alphabetic'): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.textBaseline = upCanvasTextBaseline(baseline);
  }

  /** ArkTS 补充：直接落到 CanvasRenderer.direction。/ ArkTS addition mapping CanvasRenderer.direction. */
  setDirection(direction: string = 'inherit'): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.direction = upCanvasDirection(direction);
  }

  setFontSize(fontSize: number): void {
    this.fontSize = Number.isFinite(fontSize) && fontSize > 0 ? fontSize : this.fontSize;
    this.applyFont();
  }

  setFont(font: string): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    const matched: RegExpMatchArray | null = font.match(/(\d+(?:\.\d+)?)px/);
    if (matched !== null && matched.length > 1) {
      const parsed: number = parseFloat(matched[1]);
      this.fontSize = Number.isFinite(parsed) && parsed > 0 ? parsed : this.fontSize;
    }
    if (renderer === undefined) {
      return;
    }
    renderer.font = font;
  }

  setGlobalAlpha(alpha: number): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.globalAlpha = alpha;
  }

  setGlobalCompositeOperation(operation: string): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.globalCompositeOperation = operation;
  }

  setShadow(offsetX: number = 0, offsetY: number = 0, blur: number = 0, color: string = 'rgba(0,0,0,0)'): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    renderer.shadowOffsetX = offsetX;
    renderer.shadowOffsetY = offsetY;
    renderer.shadowBlur = blur;
    renderer.shadowColor = color;
  }

  /** 上游 setLineStyle()：圆头圆角 + 颜色 + 线宽一次设置。/ Mirrors upstream setLineStyle(). */
  setLineStyle(lineColor: string, lineWidth: number): void {
    this.setLineCap('round');
    this.setLineJoin('round');
    this.setStrokeStyle(lineColor);
    this.setLineWidth(lineWidth);
  }

  /** 上游 applyFont()：按当前字重/字号/字体族回写 font。/ Mirrors upstream applyFont(). */
  applyFont(): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    const weight: string = this.fontWeight === 'normal' ? '' : `${this.fontWeight} `;
    renderer.font = `${weight}${this.fontSize}px ${this.fontFamily}`.trim();
  }

  fillText(text: string, x: number, y: number): void {
    this.renderer?.fillText(text, x, y);
  }

  strokeText(text: string, x: number, y: number, maxWidth?: number): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    if (maxWidth === undefined) {
      renderer.strokeText(text, x, y);
      return;
    }
    renderer.strokeText(text, x, y, maxWidth);
  }

  /** 上游 estimateTextWidth()，字号缺省时取当前字号。/ Mirrors upstream estimateTextWidth(). */
  estimateTextWidth(text: string, fontSize?: number): number {
    return upCanvasEstimateTextWidth(text, fontSize ?? this.fontSize);
  }

  /** 上游 measureText()：真实测量为 0 时回落估算，绝不把 0 交给调用方。/ Mirrors upstream measureText(). */
  measureText(text: string): UPCanvasTextMetrics {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer !== undefined) {
      const metrics: TextMetrics = renderer.measureText(text);
      if (Number.isFinite(metrics.width) && metrics.width > 0) {
        return { width: metrics.width };
      }
    }
    return { width: this.estimateTextWidth(text) };
  }

  createLinearGradient(x0: number, y0: number, x1: number, y1: number): CanvasGradient | undefined {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return undefined;
    }
    return renderer.createLinearGradient(x0, y0, x1, y1);
  }

  createRadialGradient(x0: number, y0: number, r0: number, x1: number, y1: number, r1: number): CanvasGradient | undefined {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return undefined;
    }
    return renderer.createRadialGradient(x0, y0, r0, x1, y1, r1);
  }

  /** 只画本地图片，远端地址报诊断后跳过。/ Draws local sources only; remote ones are reported and skipped. */
  drawImage(src: string, dx: number, dy: number, dw?: number, dh?: number): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    if (!isLocalCanvasSource(src)) {
      this.diagnostics.report('UPCanvas', 'drawImage', src, 'only local sources are drawn; remote images are skipped');
      return;
    }
    const bitmap: ImageBitmap = new ImageBitmap(src);
    if (dw === undefined || dh === undefined) {
      renderer.drawImage(bitmap, dx, dy);
      return;
    }
    renderer.drawImage(bitmap, dx, dy, dw, dh);
  }

  /** 上游 drawImage 的九参裁剪形态。/ The nine-argument cropping form of upstream drawImage. */
  drawImageRegion(src: string, sx: number, sy: number, sw: number, sh: number,
    dx: number, dy: number, dw: number, dh: number): void {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return;
    }
    if (!isLocalCanvasSource(src)) {
      this.diagnostics.report('UPCanvas', 'drawImage', src, 'only local sources are drawn; remote images are skipped');
      return;
    }
    renderer.drawImage(new ImageBitmap(src), sx, sy, sw, sh, dx, dy, dw, dh);
  }

  /** 上游返回 Promise，这里同步返回 ImageData。/ Upstream resolves a Promise; ArkUI reads synchronously. */
  getImageData(options?: UPCanvasImageDataOptions): ImageData | undefined {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return undefined;
    }
    const request: UPCanvasImageDataOptions = options ?? {};
    return renderer.getImageData(request.x ?? 0, request.y ?? 0,
      request.width ?? this.canvasWidth, request.height ?? this.canvasHeight);
  }

  /** 上游返回 Promise，这里同步写回。/ Upstream resolves a Promise; ArkUI writes synchronously. */
  putImageData(options: UPCanvasPutImageDataOptions): void {
    this.renderer?.putImageData(options.data, options.x ?? 0, options.y ?? 0);
  }

  /** ArkUI 即时绘制，draw() 只负责回调时序。/ ArkUI paints immediately, so draw() only keeps the callback contract. */
  draw(isLastDraw: boolean = false, callback?: () => void): void {
    if (callback === undefined) {
      return;
    }
    callback();
  }

  /** 导出 data URL；上游返回临时文件路径。/ Exports a data URL where upstream returns a temp file path. */
  exportImage(fileType: string = 'png', quality: number = 1): string {
    const renderer: CanvasRenderingContext2D | undefined = this.renderer;
    if (renderer === undefined) {
      return '';
    }
    return renderer.toDataURL(`image/${fileType}`, quality);
  }
}

export interface UPCanvasOptions {
  canvasId?: UPRawValue;
  width?: UPRawValue;
  height?: UPRawValue;
  unit?: UPRawValue;
  useRootHeightAndWidth?: UPRawValue;
  bgColor?: UPRawValue;
  disableScroll?: UPRawValue;
  surface?: UPCanvasSurface;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onReady?: (surface: UPCanvasSurface) => void;
  onTouchStart?: (event: UPCanvasTouchEvent) => void;
  onTouchMove?: (event: UPCanvasTouchEvent) => void;
  onTouchEnd?: (event: UPCanvasTouchEvent) => void;
}

export class UPCanvasProps {
  canvasId: UPRawValue = '';
  width: UPRawValue = 300;
  height: UPRawValue = 300;
  unit: UPRawValue = 'px';
  useRootHeightAndWidth: UPRawValue = false;
  bgColor: UPRawValue = '#ffffff';
  disableScroll: UPRawValue = false;
  surface?: UPCanvasSurface;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onReady?: (surface: UPCanvasSurface) => void;
  onTouchStart?: (event: UPCanvasTouchEvent) => void;
  onTouchMove?: (event: UPCanvasTouchEvent) => void;
  onTouchEnd?: (event: UPCanvasTouchEvent) => void;

  constructor(options?: UPCanvasOptions) {
    if (options === undefined) {
      return;
    }
    this.canvasId = options.canvasId ?? this.canvasId;
    this.width = options.width ?? this.width;
    this.height = options.height ?? this.height;
    this.unit = options.unit ?? this.unit;
    this.useRootHeightAndWidth = options.useRootHeightAndWidth ?? this.useRootHeightAndWidth;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.disableScroll = options.disableScroll ?? this.disableScroll;
    this.surface = options.surface;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onReady = options.onReady;
    this.onTouchStart = options.onTouchStart;
    this.onTouchMove = options.onTouchMove;
    this.onTouchEnd = options.onTouchEnd;
  }
}

@Component
export struct UPCanvas {
  @Prop props: UPCanvasProps = new UPCanvasProps();
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private ownSurface: UPCanvasSurface = new UPCanvasSurface();

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    const unit: string = upString(this.props.unit, 'px');
    if (!upCanvasUnitSupported(unit)) {
      diagnostics.report('UPCanvas', 'unit', this.props.unit, 'only px/rpx/upx are supported; other units fall back to px');
    }
    if (upBoolean(this.props.disableScroll, false)) {
      diagnostics.report('UPCanvas', 'disableScroll', this.props.disableScroll, 'ArkUI Canvas never scrolls its own content; the flag is a no-op');
    }
    const canvasId: string = upString(this.props.canvasId, '');
    if (canvasId.length > 0) {
      diagnostics.report('UPCanvas', 'canvasId', this.props.canvasId, 'ArkUI addresses the canvas through its rendering context; canvasId is informational only');
    }
  }

  aboutToDisappear(): void {
    this.surface().detach();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private surface(): UPCanvasSurface {
    return this.props.surface ?? this.ownSurface;
  }

  private backdrop(): string {
    const raw: string = upString(this.props.bgColor, '#ffffff');
    if (raw === 'transparent') {
      return 'transparent';
    }
    return UPColor.parse(raw, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color'));
  }

  private boxWidth(): string | number {
    const custom: number | undefined = UPStyle.parse(this.props.customStyle).width;
    if (custom !== undefined) {
      return custom;
    }
    if (upBoolean(this.props.useRootHeightAndWidth, false)) {
      return '100%';
    }
    return upCanvasParseSize(this.props.width, upString(this.props.unit, 'px'));
  }

  private boxHeight(): string | number {
    const custom: number | undefined = UPStyle.parse(this.props.customStyle).height;
    if (custom !== undefined) {
      return custom;
    }
    if (upBoolean(this.props.useRootHeightAndWidth, false)) {
      return '100%';
    }
    return upCanvasParseSize(this.props.height, upString(this.props.unit, 'px'));
  }

  private measuredWidth(): number {
    return upNumber(this.renderContext.width, upCanvasParseSize(this.props.width, upString(this.props.unit, 'px')));
  }

  private measuredHeight(): number {
    return upNumber(this.renderContext.height, upCanvasParseSize(this.props.height, upString(this.props.unit, 'px')));
  }

  /** onReady 里铺底色并绑定绘制面板。/ Paints the background and attaches the surface. */
  private handleReady(): void {
    const surface: UPCanvasSurface = this.surface();
    surface.bgColor = this.backdrop();
    surface.diagnostics = this.diagnostics();
    surface.attach(this.renderContext, this.measuredWidth(), this.measuredHeight());
    surface.clearCanvas();
    const callback: ((surface: UPCanvasSurface) => void) | undefined = this.props.onReady;
    if (callback !== undefined) {
      callback(surface);
    }
  }

  private handleTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return;
    }
    const touch: TouchObject = event.touches[0];
    if (event.type === TouchType.Down) {
      const start: ((event: UPCanvasTouchEvent) => void) | undefined = this.props.onTouchStart;
      if (start !== undefined) {
        start({ x: touch.x, y: touch.y, type: 'touchstart' });
      }
      return;
    }
    if (event.type === TouchType.Move) {
      const move: ((event: UPCanvasTouchEvent) => void) | undefined = this.props.onTouchMove;
      if (move !== undefined) {
        move({ x: touch.x, y: touch.y, type: 'touchmove' });
      }
      return;
    }
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      const end: ((event: UPCanvasTouchEvent) => void) | undefined = this.props.onTouchEnd;
      if (end !== undefined) {
        end({ x: touch.x, y: touch.y, type: 'touchend' });
      }
    }
  }

  build() {
    Canvas(this.renderContext)
      .width(this.boxWidth())
      .height(this.boxHeight())
      .backgroundColor(this.backdrop())
      .onReady((): void => this.handleReady())
      .onTouch((event: TouchEvent): void => this.handleTouch(event))
  }
}
