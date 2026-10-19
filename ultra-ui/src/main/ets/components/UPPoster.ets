import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPStyle } from '../core/UPStyle';
import {
  UPPosterConfig,
  UPPosterGradient,
  UPPosterGradientLine,
  UPPosterLine,
  UPPosterStop,
  UPPosterStyle,
  UPPosterView,
  UP_POSTER_DEFAULT_HEIGHT,
  UP_POSTER_DEFAULT_LINE_HEIGHT,
  UP_POSTER_DEFAULT_WIDTH,
  UP_POSTER_ELLIPSIS,
  UP_POSTER_EXPORT_TIMEOUT,
  UP_POSTER_QRCODE_BACKGROUND,
  UP_POSTER_QRCODE_FOREGROUND,
  UP_POSTER_QRCODE_PLACEHOLDER_BACKGROUND,
  UP_POSTER_QRCODE_PLACEHOLDER_COLOR,
  UP_POSTER_QRCODE_PLACEHOLDER_FONT_SIZE,
  UP_POSTER_QRCODE_PLACEHOLDER_TEXT,
  UP_POSTER_TEXT_COLOR,
  UP_POSTER_VIEW_TYPES,
  upPosterBaseline,
  upPosterGradient,
  upPosterGradientBackground,
  upPosterGradientLine,
  upPosterLength,
  upPosterLineClamp,
  upPosterStrokeWidth,
  upPosterTypeSupported,
  upPosterWrapText
} from '../internal/UPPosterLayout';
import { UPPosterCommand, UPPosterController, UPPosterImage } from '../controllers/UPPosterController';
import { UPQrcodeEncoder, upQrcodeForeground, upQrcodeLevel } from './UPQrcode';
import { isLocalCanvasSource } from './UPCanvas';

/** 导出失败原因。/ Reason an export attempt failed. */
export type UPPosterFailureReason = 'not-ready' | 'export-failed' | 'empty-views';

/** 导出失败事件。/ Export failure payload. */
export interface UPPosterFailureEvent {
  reason: UPPosterFailureReason;
  message: string;
}

export interface UPPosterOptions {
  json?: UPPosterConfig;
  qrcodeLevel?: UPRawValue;
  viewportWidth?: UPRawValue;
  showCanvas?: UPRawValue;
  customStyle?: UPStyleInput;
  controller?: UPPosterController;
  diagnostics?: UPCompatibilityDiagnostics;
  onExport?: (image: UPPosterImage) => void;
  onFailure?: (event: UPPosterFailureEvent) => void;
}

export class UPPosterProps {
  json: UPPosterConfig = {};
  qrcodeLevel: UPRawValue = 3;
  viewportWidth: UPRawValue = 375;
  showCanvas: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  controller?: UPPosterController;
  diagnostics?: UPCompatibilityDiagnostics;
  onExport?: (image: UPPosterImage) => void;
  onFailure?: (event: UPPosterFailureEvent) => void;

  constructor(options?: UPPosterOptions) {
    if (options === undefined) {
      return;
    }
    this.json = options.json ?? this.json;
    this.qrcodeLevel = options.qrcodeLevel ?? this.qrcodeLevel;
    this.viewportWidth = options.viewportWidth ?? this.viewportWidth;
    this.showCanvas = options.showCanvas ?? this.showCanvas;
    this.customStyle = options.customStyle;
    this.controller = options.controller;
    this.diagnostics = options.diagnostics;
    this.onExport = options.onExport;
    this.onFailure = options.onFailure;
  }
}

/**
 * u-poster 的 HarmonyOS 原生实现：按 json 配置在 Canvas 上合成海报，二维码复用内置编码器。
 * Native u-poster: composes the poster on an ArkUI Canvas and reuses the bundled QR encoder.
 */
@Component
export struct UPPoster {
  @Prop @Watch('applyProps') props: UPPosterProps = new UPPosterProps();
  private ready: boolean = false;
  private applied: string = '';
  private exported: UPPosterImage = { path: '', width: 0, height: 0 };
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  aboutToAppear(): void {
    this.props.controller?.mount((command: UPPosterCommand): void => this.execute(command));
    this.applied = this.signature();
    this.reportBoundaries();
  }

  aboutToDisappear(): void {
    this.props.controller?.unmount();
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.reportBoundaries();
    this.paint();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    const views: Array<UPPosterView> = this.props.json.views ?? [];
    let text: string = String(this.canvasWidth()) + 'x' + String(this.canvasHeight()) + '|' + String(views.length);
    for (const view of views) {
      text += '|' + (view.type ?? '') + ':' + (view.text ?? '') + ':' + (view.src ?? '');
    }
    return text;
  }

  private execute(command: UPPosterCommand): void {
    if (command.action === 'exportImage') {
      this.exportImage();
      return;
    }
    this.paint();
  }

  private reportBoundaries(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    for (const view of this.props.json.views ?? []) {
      const type: string = view.type ?? '';
      if (!upPosterTypeSupported(type)) {
        diagnostics.report('UPPoster', 'views', type,
          'only the upstream element types are drawn: ' + UP_POSTER_VIEW_TYPES.join(', '));
      }
    }
    diagnostics.report('UPPoster', 'exportImage', '',
      'toTempFilePath is unavailable, so the poster is returned as a base64 data URL');
    diagnostics.report('UPPoster', 'timeout', UP_POSTER_EXPORT_TIMEOUT,
      'drawing is synchronous on ArkUI, so the upstream 20s export race is not needed');
    diagnostics.report('UPPoster', 'blob', '',
      'the upstream H5-only Blob conversion is not applicable on HarmonyOS');
  }

  private viewportWidthValue(): number {
    const width: number = upNumber(this.props.viewportWidth, 375);
    return width > 0 ? width : 375;
  }

  private posterStyle(): UPPosterStyle {
    return this.props.json.css ?? {};
  }

  private canvasWidth(): number {
    const width: number = upPosterLength(this.posterStyle().width ?? UP_POSTER_DEFAULT_WIDTH, this.viewportWidthValue());
    return width > 0 ? width : upPosterLength(UP_POSTER_DEFAULT_WIDTH, this.viewportWidthValue());
  }

  private canvasHeight(): number {
    const height: number = upPosterLength(this.posterStyle().height ?? UP_POSTER_DEFAULT_HEIGHT, this.viewportWidthValue());
    return height > 0 ? height : upPosterLength(UP_POSTER_DEFAULT_HEIGHT, this.viewportWidthValue());
  }

  private length(value: string | undefined): number {
    return upPosterLength(value ?? '0rpx', this.viewportWidthValue());
  }

  private handleReady(): void {
    this.ready = true;
    this.paint();
  }

  /** 上游 exportImage 的绘制主循环。/ The drawing loop of upstream exportImage(). */
  private paint(): void {
    if (!this.ready) {
      return;
    }
    const width: number = this.canvasWidth();
    const height: number = this.canvasHeight();
    this.renderContext.clearRect(0, 0, width, height);
    const style: UPPosterStyle = this.posterStyle();
    const background: string = style.background ?? '';
    if (background.length > 0) {
      if (upPosterGradientBackground(background)) {
        this.paintGradient(style, 0, 0, width, height);
      } else {
        this.renderContext.fillStyle = background;
        this.renderContext.fillRect(0, 0, width, height);
      }
    }
    for (const view of this.props.json.views ?? []) {
      this.paintView(view);
    }
  }

  /** 上游 drawItem()。/ Mirrors upstream drawItem(). */
  private paintView(view: UPPosterView): void {
    const style: UPPosterStyle = view.css ?? {};
    const left: number = this.length(style.left);
    const top: number = this.length(style.top);
    const width: number = this.length(style.width);
    const height: number = this.length(style.height);
    const type: string = view.type ?? '';
    if (type === 'view') {
      this.paintBox(style, left, top, width, height);
      return;
    }
    if (type === 'text') {
      this.paintText(view, style, left, top, width);
      return;
    }
    if (type === 'image') {
      this.paintImage(view, style, left, top, width, height);
      return;
    }
    if (type === 'qrcode') {
      this.paintQrcode(view, left, top, width, height);
    }
  }

  /** 上游 view 分支：纯色或渐变背景，支持圆角。/ The upstream view branch. */
  private paintBox(style: UPPosterStyle, left: number, top: number, width: number, height: number): void {
    const background: string = style.background ?? '';
    if (background.length === 0) {
      return;
    }
    if (upPosterGradientBackground(background)) {
      this.paintGradient(style, left, top, width, height);
      return;
    }
    this.renderContext.fillStyle = background;
    const radius: number = this.length(style.radius);
    if (radius > 0) {
      this.paintRoundRect(left, top, width, height, radius);
      this.renderContext.fill();
      return;
    }
    this.renderContext.fillRect(left, top, width, height);
  }

  /** 上游 text 分支：可选行数限制，基线按半个字号下移。/ The upstream text branch. */
  private paintText(view: UPPosterView, style: UPPosterStyle, left: number, top: number, width: number): void {
    const fontSize: number = this.length(style.fontSize);
    this.renderContext.fillStyle = style.color ?? UP_POSTER_TEXT_COLOR;
    if (fontSize > 0) {
      this.renderContext.font = String(fontSize) + 'px sans-serif';
    }
    const fontWeight: string = style.fontWeight ?? '';
    if (fontWeight.length > 0) {
      this.renderContext.lineWidth = upPosterStrokeWidth(fontWeight);
    }
    const baseline: number = upPosterBaseline(fontSize);
    const text: string = view.text ?? '';
    const clampValue: string = style.lineClamp ?? '';
    if (clampValue.length === 0) {
      this.renderContext.fillText(text, left, top + baseline);
      return;
    }
    const lineHeight: number = this.length(style.lineHeight) > 0
      ? this.length(style.lineHeight)
      : UP_POSTER_DEFAULT_LINE_HEIGHT;
    const lines: Array<UPPosterLine> = upPosterWrapText(text, width, fontSize, upPosterLineClamp(clampValue));
    for (let index: number = 0; index < lines.length; index++) {
      this.renderContext.fillText(lines[index].text, left, top + index * lineHeight + baseline);
    }
  }

  /** 上游 image 分支：圆角时先裁剪再绘制。/ The upstream image branch. */
  private paintImage(view: UPPosterView, style: UPPosterStyle, left: number, top: number,
    width: number, height: number): void {
    const source: string = view.src ?? '';
    if (!isLocalCanvasSource(source)) {
      this.diagnostics().report('UPPoster', 'src', source,
        'only local sources are drawn; remote images are skipped');
      return;
    }
    const radius: number = this.length(style.radius);
    if (radius > 0) {
      this.renderContext.save();
      this.paintRoundRect(left, top, width, height, radius);
      this.renderContext.clip();
      this.renderContext.drawImage(new ImageBitmap(source), left, top, width, height);
      this.renderContext.restore();
      return;
    }
    this.renderContext.drawImage(new ImageBitmap(source), left, top, width, height);
  }

  /** 上游 qrcode 分支：内容为空时画占位方块。/ The upstream qrcode branch. */
  private paintQrcode(view: UPPosterView, left: number, top: number, width: number, height: number): void {
    const text: string = view.text ?? '';
    if (text.length === 0) {
      this.renderContext.fillStyle = UP_POSTER_QRCODE_PLACEHOLDER_BACKGROUND;
      this.renderContext.fillRect(left, top, width, height);
      this.renderContext.fillStyle = UP_POSTER_QRCODE_PLACEHOLDER_COLOR;
      this.renderContext.font = String(UP_POSTER_QRCODE_PLACEHOLDER_FONT_SIZE) + 'px sans-serif';
      this.renderContext.textAlign = 'center';
      this.renderContext.fillText(UP_POSTER_QRCODE_PLACEHOLDER_TEXT, left + width / 2, top + height / 2);
      this.renderContext.textAlign = 'left';
      return;
    }
    const edge: number = Math.max(width, height);
    if (edge <= 0) {
      return;
    }
    const encoder: UPQrcodeEncoder = new UPQrcodeEncoder(text, upQrcodeLevel(this.props.qrcodeLevel));
    const count: number = encoder.getModuleCount();
    const tile: number = edge / count;
    for (let row: number = 0; row < count; row++) {
      for (let col: number = 0; col < count; col++) {
        const cellWidth: number = Math.ceil((col + 1) * tile) - Math.floor(col * tile);
        const cellHeight: number = Math.ceil((row + 1) * tile) - Math.floor(row * tile);
        this.renderContext.fillStyle = encoder.isDark(row, col)
          ? upQrcodeForeground(row, col, count, UP_POSTER_QRCODE_FOREGROUND, UP_POSTER_QRCODE_FOREGROUND)
          : UP_POSTER_QRCODE_BACKGROUND;
        this.renderContext.fillRect(left + Math.round(col * tile), top + Math.round(row * tile),
          cellWidth, cellHeight);
      }
    }
  }

  /** 上游 drawGradientBackground()。/ Mirrors upstream drawGradientBackground(). */
  private paintGradient(style: UPPosterStyle, left: number, top: number, width: number, height: number): void {
    const gradient: UPPosterGradient = upPosterGradient(style.background ?? '');
    if (gradient.stops.length === 0) {
      return;
    }
    let painter: CanvasGradient;
    if (gradient.radial) {
      const centerX: number = left + width / 2;
      const centerY: number = top + height / 2;
      painter = this.renderContext.createRadialGradient(centerX, centerY, 0, centerX, centerY,
        Math.min(width, height) / 2);
    } else {
      const line: UPPosterGradientLine = upPosterGradientLine(gradient.angle, left, top, width, height);
      painter = this.renderContext.createLinearGradient(line.startX, line.startY, line.endX, line.endY);
    }
    for (const stop of gradient.stops) {
      painter.addColorStop(stop.offset, stop.color);
    }
    this.renderContext.fillStyle = painter;
    const radius: number = this.length(style.radius);
    if (radius > 0) {
      this.paintRoundRect(left, top, width, height, radius);
      this.renderContext.fill();
      return;
    }
    this.renderContext.fillRect(left, top, width, height);
  }

  /** 上游 drawRoundRect()/clipRoundRect() 的共用路径。/ Shared path of the upstream round-rect helpers. */
  private paintRoundRect(left: number, top: number, width: number, height: number, radius: number): void {
    this.renderContext.beginPath();
    this.renderContext.moveTo(left + radius, top);
    this.renderContext.lineTo(left + width - radius, top);
    this.renderContext.quadraticCurveTo(left + width, top, left + width, top + radius);
    this.renderContext.lineTo(left + width, top + height - radius);
    this.renderContext.quadraticCurveTo(left + width, top + height, left + width - radius, top + height);
    this.renderContext.lineTo(left + radius, top + height);
    this.renderContext.quadraticCurveTo(left, top + height, left, top + height - radius);
    this.renderContext.lineTo(left, top + radius);
    this.renderContext.quadraticCurveTo(left, top, left + radius, top);
    this.renderContext.closePath();
  }

  /** 上游 exportImage()：导出 data URL 并回传。/ Mirrors upstream exportImage(). */
  exportImage(): void {
    if (!this.ready) {
      this.diagnostics().report('UPPoster', 'exportImage', '',
        'the canvas is not ready yet, so the export request is dropped');
      this.props.onFailure?.({ reason: 'not-ready', message: '画布尚未就绪' });
      return;
    }
    const views: Array<UPPosterView> = this.props.json.views ?? [];
    if (views.length === 0) {
      this.props.onFailure?.({ reason: 'empty-views', message: '海报配置没有任何元素' });
      return;
    }
    this.paint();
    let dataUrl: string = '';
    try {
      dataUrl = this.renderContext.toDataURL('image/png', 1);
    } catch (_error) {
      dataUrl = '';
    }
    if (dataUrl.length === 0) {
      this.props.onFailure?.({ reason: 'export-failed', message: '海报导出失败' });
      return;
    }
    this.exported = { path: dataUrl, width: this.canvasWidth(), height: this.canvasHeight() };
    this.props.controller?.updateSnapshot(this.exported);
    this.props.onExport?.(this.exported);
  }

  /** 最近一次导出结果。/ The latest export result. */
  lastImage(): UPPosterImage {
    return { path: this.exported.path, width: this.exported.width, height: this.exported.height };
  }

  build() {
    Column() {
      if (upBoolean(this.props.showCanvas, true)) {
        Canvas(this.renderContext)
          .width(this.canvasWidth())
          .height(this.canvasHeight())
          .backgroundColor('#00000000')
          .onReady((): void => this.handleReady())
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? this.canvasWidth())
    .height(UPStyle.parse(this.props.customStyle).height ?? this.canvasHeight())
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#00000000')
    .clip(true)
  }
}
