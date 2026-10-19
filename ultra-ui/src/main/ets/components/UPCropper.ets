import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import {
  UPCropperConstraint,
  UPCropperHandle,
  UPCropperPlacement,
  UPCropperPreview,
  UPCropperRect,
  UPCropperTouch,
  UP_CROPPER_BORDER_COLOR,
  UP_CROPPER_BORDER_WIDTH,
  UP_CROPPER_CLOSE_TEXT,
  UP_CROPPER_CONFIRM_TEXT,
  UP_CROPPER_CORNER_COLOR,
  UP_CROPPER_CORNER_LENGTH,
  UP_CROPPER_DRAW_INTERVAL,
  UP_CROPPER_EMPTY_AREA_TEXT,
  UP_CROPPER_HANDLE_COLOR,
  UP_CROPPER_HANDLE_SIZE,
  UP_CROPPER_MASK_ALPHA,
  UP_CROPPER_MASK_COLOR,
  UP_CROPPER_MAX_SCALE,
  UP_CROPPER_MIN_SCALE,
  UP_CROPPER_PINCH_FACTOR,
  UP_CROPPER_PREVIEW_TEXT,
  UP_CROPPER_RESELECT_TEXT,
  UP_CROPPER_ROTATE_TEXT,
  UP_CROPPER_TAB_HEIGHT,
  UP_CROPPER_TRANSPARENT,
  upCropperConstraint,
  upCropperDistance,
  upCropperHandleAt,
  upCropperImageBounds,
  upCropperLength,
  upCropperPlacement,
  upCropperPreviewPlacement,
  upCropperQuality,
  upCropperResize,
  upCropperRotate,
  upCropperSaturate,
  upCropperSaturation,
  upCropperScale,
  upCropperSelection,
  upCropperStretchSupported,
  upCropperTranslate
} from '../internal/UPCropperGeometry';
import { isLocalCanvasSource } from './UPCanvas';
import { UPSlider, UPSliderChangeEvent, UPSliderProps } from './UPSlider';

/** 上游 chooseImage(index, params, data) 的具名入参。/ Named payload of upstream chooseImage(). */
export interface UPCropperOpenOptions {
  imageSrc?: string;
  areaWidth?: string;
  areaHeight?: string;
  exportWidth?: string;
  exportHeight?: string;
  quality?: string;
  canRotate?: boolean;
  canScale?: boolean;
  canChangeSize?: boolean;
  minScale?: number;
  maxScale?: number;
  stretch?: string;
  lock?: string;
  inner?: boolean;
  index?: number;
}

/** 上游 confirm 事件。/ Upstream confirm payload. */
export interface UPCropperConfirmEvent {
  path: string;
  source: string;
  index: number;
  width: number;
  height: number;
}

/** 上游 avtinit 事件。/ Upstream avtinit payload. */
export interface UPCropperInitEvent {
  width: number;
  height: number;
  selectionWidth: number;
  selectionHeight: number;
}

/** 导出失败原因。/ Reason an export attempt failed. */
export type UPCropperFailureReason = 'no-source' | 'remote-source' | 'empty-area' | 'export-failed';

/** 导出失败事件。/ Export failure payload. */
export interface UPCropperFailureEvent {
  reason: UPCropperFailureReason;
  message: string;
}

export interface UPCropperOptions {
  imageSrc?: UPRawValue;
  areaWidth?: UPRawValue;
  areaHeight?: UPRawValue;
  exportWidth?: UPRawValue;
  exportHeight?: UPRawValue;
  imageWidth?: UPRawValue;
  imageHeight?: UPRawValue;
  canScale?: UPRawValue;
  canRotate?: UPRawValue;
  canChangeSize?: UPRawValue;
  minScale?: UPRawValue;
  maxScale?: UPRawValue;
  stretch?: UPRawValue;
  lock?: UPRawValue;
  lockWidth?: UPRawValue;
  lockHeight?: UPRawValue;
  inner?: UPRawValue;
  noTab?: UPRawValue;
  quality?: UPRawValue;
  index?: UPRawValue;
  fillColor?: UPRawValue;
  show?: UPRawValue;
  viewportWidth?: UPRawValue;
  viewportHeight?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  chooseImage?: () => string;
  onInit?: (event: UPCropperInitEvent) => void;
  onAvtinit?: (event: UPCropperInitEvent) => void;
  onConfirm?: (event: UPCropperConfirmEvent) => void;
  onCancel?: () => void;
  onFailure?: (event: UPCropperFailureEvent) => void;
  contentBuilder?: () => void;
}

export class UPCropperProps {
  imageSrc: UPRawValue = '';
  areaWidth: UPRawValue = '300rpx';
  areaHeight: UPRawValue = '300rpx';
  exportWidth: UPRawValue = '260rpx';
  exportHeight: UPRawValue = '260rpx';
  imageWidth: UPRawValue = 0;
  imageHeight: UPRawValue = 0;
  canScale: UPRawValue = true;
  canRotate: UPRawValue = true;
  canChangeSize: UPRawValue = false;
  minScale: UPRawValue = '';
  maxScale: UPRawValue = '';
  stretch: UPRawValue = '';
  lock: UPRawValue = '';
  lockWidth: UPRawValue = '';
  lockHeight: UPRawValue = '';
  inner: UPRawValue = false;
  noTab: UPRawValue = true;
  quality: UPRawValue = '';
  index: UPRawValue = '';
  fillColor: UPRawValue = UP_CROPPER_TRANSPARENT;
  show: UPRawValue = false;
  viewportWidth: UPRawValue = 375;
  viewportHeight: UPRawValue = 667;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  chooseImage?: () => string;
  onInit?: (event: UPCropperInitEvent) => void;
  onAvtinit?: (event: UPCropperInitEvent) => void;
  onConfirm?: (event: UPCropperConfirmEvent) => void;
  onCancel?: () => void;
  onFailure?: (event: UPCropperFailureEvent) => void;
  contentBuilder?: () => void;

  constructor(options?: UPCropperOptions) {
    if (options === undefined) {
      return;
    }
    this.imageSrc = options.imageSrc ?? this.imageSrc;
    this.areaWidth = options.areaWidth ?? this.areaWidth;
    this.areaHeight = options.areaHeight ?? this.areaHeight;
    this.exportWidth = options.exportWidth ?? this.exportWidth;
    this.exportHeight = options.exportHeight ?? this.exportHeight;
    this.imageWidth = options.imageWidth ?? this.imageWidth;
    this.imageHeight = options.imageHeight ?? this.imageHeight;
    this.canScale = options.canScale ?? this.canScale;
    this.canRotate = options.canRotate ?? this.canRotate;
    this.canChangeSize = options.canChangeSize ?? this.canChangeSize;
    this.minScale = options.minScale ?? this.minScale;
    this.maxScale = options.maxScale ?? this.maxScale;
    this.stretch = options.stretch ?? this.stretch;
    this.lock = options.lock ?? this.lock;
    this.lockWidth = options.lockWidth ?? this.lockWidth;
    this.lockHeight = options.lockHeight ?? this.lockHeight;
    this.inner = options.inner ?? this.inner;
    this.noTab = options.noTab ?? this.noTab;
    this.quality = options.quality ?? this.quality;
    this.index = options.index ?? this.index;
    this.fillColor = options.fillColor ?? this.fillColor;
    this.show = options.show ?? this.show;
    this.viewportWidth = options.viewportWidth ?? this.viewportWidth;
    this.viewportHeight = options.viewportHeight ?? this.viewportHeight;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.chooseImage = options.chooseImage;
    this.onInit = options.onInit;
    this.onAvtinit = options.onAvtinit;
    this.onConfirm = options.onConfirm;
    this.onCancel = options.onCancel;
    this.onFailure = options.onFailure;
    this.contentBuilder = options.contentBuilder;
  }
}

/** 底部操作按钮模型。/ One toolbar button. */
class UPCropperButton {
  action: string = '';
  label: string = '';

  constructor(action: string, label: string) {
    this.action = action;
    this.label = label;
  }
}

/**
 * u-cropper 的 HarmonyOS 原生实现：三层 Canvas 换成一张画布加遮罩层，图片选择与落盘由宿主承担。
 * Native u-cropper: the three upstream canvases collapse into one canvas plus a mask, and file IO stays with the host.
 */
@Component
export struct UPCropper {
  @Prop @Watch('applyProps') props: UPCropperProps = new UPCropperProps();
  @State private opened: boolean = false;
  @State private previewing: boolean = false;
  @State private source: string = '';
  @State private saturation: number = 0;
  @State private selection: UPCropperRect = new UPCropperRect();
  private placement: UPCropperPlacement = new UPCropperPlacement();
  private constraint: UPCropperConstraint = new UPCropperConstraint();
  private previewBox: UPCropperPreview = new UPCropperPreview();
  private handle: UPCropperHandle = 'none';
  private touchOne: UPCropperTouch = new UPCropperTouch();
  private touchTwo?: UPCropperTouch = undefined;
  private pinchDistance: number = 0;
  private applied: string = '';
  private lastDrawAt: number = 0;
  private previewBuffer?: Uint8ClampedArray = undefined;
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  @Builder
  private defaultTrigger() {
    Text('选择图片')
      .fontSize(14)
      .fontColor(UP_DEFAULT_THEME.primary)
  }

  @BuilderParam contentBuilder: () => void = this.defaultTrigger;

  aboutToAppear(): void {
    this.applied = this.signature();
    this.source = upString(this.props.imageSrc);
    this.reportBoundaries();
    if (upBoolean(this.props.show, false)) {
      this.open();
    }
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    const incoming: string = upString(this.props.imageSrc);
    if (incoming !== this.source) {
      this.source = incoming;
      if (this.opened) {
        this.layout();
      }
    }
    this.reportBoundaries();
    if (upBoolean(this.props.show, false) && !this.opened) {
      this.open();
    }
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    return upString(this.props.imageSrc) + '|' + String(upBoolean(this.props.show, false))
      + '|' + this.areaText() + '|' + this.stretchName() + '|' + this.lockName()
      + '|' + String(this.imageWidthValue()) + 'x' + String(this.imageHeightValue());
  }

  private areaText(): string {
    return upString(this.props.areaWidth, '300rpx') + 'x' + upString(this.props.areaHeight, '300rpx');
  }

  private stretchName(): string {
    return upString(this.props.stretch, '');
  }

  private lockName(): string {
    return upString(this.props.lock, '');
  }

  private reportBoundaries(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    if (!upCropperStretchSupported(this.stretchName())) {
      diagnostics.report('UPCropper', 'stretch', this.props.stretch,
        'stretch falls back to the default fitting because only x, y, long, short, longSel and shortSel are modelled');
    }
    if (!upCropperStretchSupported(this.lockName())) {
      diagnostics.report('UPCropper', 'lock', this.props.lock,
        'lock falls back to free dragging because only x, y, long, short, longSel and shortSel are modelled');
    }
    if (upBoolean(this.props.lockWidth, false) || upBoolean(this.props.lockHeight, false)) {
      diagnostics.report('UPCropper', 'lockWidth', this.props.lockWidth,
        'upstream declares lockWidth and lockHeight without reading them; here they force the matching axis lock');
    }
    diagnostics.report('UPCropper', 'chooseImage', '',
      'the system image picker is delegated to the host through the chooseImage callback');
    if (this.imageWidthValue() <= 0 || this.imageHeightValue() <= 0) {
      diagnostics.report('UPCropper', 'imageWidth', this.props.imageWidth,
        'uni.getImageInfo is unavailable, so the natural image size must be supplied through imageWidth and imageHeight');
    }
    diagnostics.report('UPCropper', 'quality', this.props.quality,
      'the export quality only applies to the data URL because a temp file path is not produced');
    if (upBoolean(this.props.noTab, true)) {
      diagnostics.report('UPCropper', 'noTab', this.props.noTab,
        'tab bar visibility is owned by the host page, so showTabBar and hideTabBar are no-ops');
    }
  }

  private viewportWidthValue(): number {
    const width: number = upNumber(this.props.viewportWidth, 375);
    return width > 0 ? width : 375;
  }

  private viewportHeightValue(): number {
    const height: number = upNumber(this.props.viewportHeight, 667);
    return height > 0 ? height : 667;
  }

  private canvasHeightValue(): number {
    return Math.max(1, this.viewportHeightValue() - UP_CROPPER_TAB_HEIGHT);
  }

  private areaWidthValue(): number {
    return upCropperLength(upString(this.props.areaWidth, '300rpx'), this.viewportWidthValue());
  }

  private areaHeightValue(): number {
    return upCropperLength(upString(this.props.areaHeight, '300rpx'), this.viewportWidthValue());
  }

  private exportWidthValue(): number {
    return upCropperLength(upString(this.props.exportWidth, ''), this.viewportWidthValue());
  }

  private exportHeightValue(): number {
    return upCropperLength(upString(this.props.exportHeight, ''), this.viewportWidthValue());
  }

  private minScaleValue(): number {
    const value: number = upNumber(this.props.minScale, 0);
    return value > 0 ? value : UP_CROPPER_MIN_SCALE;
  }

  private maxScaleValue(): number {
    const value: number = upNumber(this.props.maxScale, 0);
    return value > 0 ? value : UP_CROPPER_MAX_SCALE;
  }

  private qualityValue(): number {
    return upCropperQuality(upString(this.props.quality, ''));
  }

  private innerMode(): boolean {
    return upBoolean(this.props.inner, false);
  }

  /** 上游 letRotate：inner 模式下禁用旋转。/ Upstream letRotate, disabled in inner mode. */
  private rotateEnabled(): boolean {
    return upBoolean(this.props.canRotate, true) && !this.innerMode();
  }

  private scaleEnabled(): boolean {
    return upBoolean(this.props.canScale, true);
  }

  private resizeEnabled(): boolean {
    return upBoolean(this.props.canChangeSize, false);
  }

  private fillColorValue(): string {
    const value: string = upString(this.props.fillColor, UP_CROPPER_TRANSPARENT).trim();
    return value.length === 0 ? UP_CROPPER_TRANSPARENT : value;
  }

  private fillEnabled(): boolean {
    return this.fillColorValue() !== UP_CROPPER_TRANSPARENT;
  }

  private indexValue(): number {
    return Math.max(0, Math.floor(upNumber(this.props.index, 0)));
  }

  private failure(reason: UPCropperFailureReason, message: string): void {
    this.props.onFailure?.({ reason: reason, message: message });
  }

  /** 上游 chooseImage()：宿主选图后进入裁剪态。/ Mirrors upstream chooseImage() with a host picker. */
  open(options?: UPCropperOpenOptions): void {
    let picked: string = options === undefined ? '' : (options.imageSrc ?? '');
    if (picked.length === 0 && this.props.chooseImage !== undefined) {
      try {
        picked = this.props.chooseImage();
      } catch (_error) {
        picked = '';
      }
    }
    if (picked.length === 0) {
      picked = this.source;
    }
    if (picked.length === 0) {
      this.diagnostics().report('UPCropper', 'imageSrc', '',
        'no image source is available, so the cropper stays closed');
      this.failure('no-source', '没有可裁剪的图片');
      this.props.onCancel?.();
      return;
    }
    this.source = picked;
    this.opened = true;
    this.previewing = false;
    this.saturation = 0;
    this.previewBuffer = undefined;
    this.layout();
  }

  /** 上游 close()。/ Mirrors upstream close(). */
  close(): void {
    this.opened = false;
    this.previewing = false;
    this.previewBuffer = undefined;
    this.props.onCancel?.();
  }

  /** 上游 rotate()。/ Mirrors upstream rotate(). */
  rotateImage(): void {
    if (!this.rotateEnabled()) {
      this.diagnostics().report('UPCropper', 'canRotate', this.props.canRotate,
        'rotation is disabled by canRotate or inner mode');
      return;
    }
    this.placement.rotateDeg = upCropperRotate(this.placement.rotateDeg);
    this.paint();
  }

  /** 上游 loadImage + drawInit：量算裁剪框与图片摆放后首绘。/ Mirrors loadImage() plus drawInit(). */
  private layout(): void {
    const areaWidth: number = this.areaWidthValue();
    const areaHeight: number = this.areaHeightValue();
    if (areaWidth <= 0 || areaHeight <= 0) {
      this.diagnostics().report('UPCropper', 'areaWidth', this.props.areaWidth, UP_CROPPER_EMPTY_AREA_TEXT);
      this.failure('empty-area', UP_CROPPER_EMPTY_AREA_TEXT);
      return;
    }
    if (!isLocalCanvasSource(this.source)) {
      this.diagnostics().report('UPCropper', 'imageSrc', this.source,
        'only local sources are drawn; remote images are skipped');
      this.failure('remote-source', '仅支持本地图片地址');
    }
    const canvasWidth: number = this.viewportWidthValue();
    const canvasHeight: number = this.viewportHeightValue();
    this.selection = upCropperSelection(areaWidth, areaHeight, canvasWidth, canvasHeight);
    const imageWidth: number = this.imageWidthValue();
    const imageHeight: number = this.imageHeightValue();
    const ratio: number = imageHeight === 0 ? 1 : imageWidth / imageHeight;
    this.constraint = upCropperConstraint(this.stretchName(), this.lockName(), ratio, this.selection);
    if (upBoolean(this.props.lockWidth, false)) {
      this.constraint.lockWidth = true;
    }
    if (upBoolean(this.props.lockHeight, false)) {
      this.constraint.lockHeight = true;
    }
    this.placement = upCropperPlacement(canvasWidth, canvasHeight, imageWidth, imageHeight,
      this.selection, this.constraint, this.innerMode());
    this.paint();
    /** 上游事件名为 `avtinit`；`onInit` 是本端别名。/ Upstream emits `avtinit`; onInit is the local alias. */
    const ready: UPCropperInitEvent = {
      width: canvasWidth,
      height: this.canvasHeightValue(),
      selectionWidth: this.selection.width,
      selectionHeight: this.selection.height
    };
    this.props.onInit?.(ready);
    this.props.onAvtinit?.(ready);
  }

  /** 上游 drawImage()：节流后按平移缩放旋转重绘。/ Mirrors upstream drawImage() with the redraw throttle. */
  private paint(): void {
    const now: number = Date.now();
    if (now - this.lastDrawAt < UP_CROPPER_DRAW_INTERVAL) {
      return;
    }
    this.lastDrawAt = now;
    const canvasWidth: number = this.viewportWidthValue();
    const canvasHeight: number = this.canvasHeightValue();
    this.renderContext.clearRect(0, 0, canvasWidth, canvasHeight);
    if (this.fillEnabled()) {
      this.renderContext.fillStyle = this.fillColorValue();
      this.renderContext.fillRect(0, 0, canvasWidth, canvasHeight);
    }
    if (isLocalCanvasSource(this.source)) {
      this.renderContext.save();
      this.renderContext.translate(this.placement.posWidth + this.placement.useWidth / 2,
        this.placement.posHeight + this.placement.useHeight / 2);
      this.renderContext.scale(this.placement.scaleSize, this.placement.scaleSize);
      this.renderContext.rotate(this.placement.rotateDeg * Math.PI / 180);
      this.renderContext.drawImage(new ImageBitmap(this.source),
        -this.placement.useWidth / 2, -this.placement.useHeight / 2,
        this.placement.useWidth, this.placement.useHeight);
      this.renderContext.restore();
    }
    this.paintMask(canvasWidth, canvasHeight);
  }

  /** 上游 drawInit 的操作层：四周遮罩、边框、红角与四个控制点。/ Mirrors the mask layer of drawInit(). */
  private paintMask(canvasWidth: number, canvasHeight: number): void {
    const left: number = this.selection.left;
    const top: number = this.selection.top;
    const width: number = this.selection.width;
    const height: number = this.selection.height;
    this.renderContext.save();
    this.renderContext.globalAlpha = UP_CROPPER_MASK_ALPHA;
    this.renderContext.fillStyle = UP_CROPPER_MASK_COLOR;
    this.renderContext.fillRect(0, 0, canvasWidth, top);
    this.renderContext.fillRect(0, top, left, height);
    this.renderContext.fillRect(0, top + height, canvasWidth, canvasHeight - height - top);
    this.renderContext.fillRect(left + width, top, canvasWidth - width - left, height);
    this.renderContext.globalAlpha = 1;
    this.renderContext.lineWidth = UP_CROPPER_BORDER_WIDTH;
    this.renderContext.strokeStyle = UP_CROPPER_BORDER_COLOR;
    this.renderContext.strokeRect(left, top, width, height);
    this.renderContext.strokeStyle = UP_CROPPER_CORNER_COLOR;
    this.renderContext.beginPath();
    const corner: number = UP_CROPPER_CORNER_LENGTH;
    this.renderContext.moveTo(left + corner, top);
    this.renderContext.lineTo(left, top);
    this.renderContext.lineTo(left, top + corner);
    this.renderContext.moveTo(left + width - corner, top);
    this.renderContext.lineTo(left + width, top);
    this.renderContext.lineTo(left + width, top + corner);
    this.renderContext.moveTo(left + corner, top + height);
    this.renderContext.lineTo(left, top + height);
    this.renderContext.lineTo(left, top + height - corner);
    this.renderContext.moveTo(left + width - corner, top + height);
    this.renderContext.lineTo(left + width, top + height);
    this.renderContext.lineTo(left + width, top + height - corner);
    this.renderContext.stroke();
    const handle: number = UP_CROPPER_HANDLE_SIZE;
    this.renderContext.fillStyle = UP_CROPPER_HANDLE_COLOR;
    this.renderContext.strokeStyle = UP_CROPPER_BORDER_COLOR;
    this.renderContext.lineWidth = 1;
    this.paintHandle(left - handle / 2, top - handle / 2, handle);
    this.paintHandle(left + width - handle / 2, top - handle / 2, handle);
    this.paintHandle(left - handle / 2, top + height - handle / 2, handle);
    this.paintHandle(left + width - handle / 2, top + height - handle / 2, handle);
    this.renderContext.restore();
  }

  private paintHandle(originX: number, originY: number, size: number): void {
    this.renderContext.fillRect(originX, originY, size, size);
    this.renderContext.strokeRect(originX, originY, size, size);
  }

  /** 上游 start()。/ Mirrors upstream start(). */
  private touchStart(event: GestureEvent): void {
    const fingers: Array<FingerInfo> = event.fingerList;
    if (fingers.length === 0) {
      return;
    }
    this.touchOne = new UPCropperTouch(fingers[0].localX, fingers[0].localY);
    if (fingers.length > 1) {
      this.touchTwo = new UPCropperTouch(fingers[1].localX, fingers[1].localY);
      this.pinchDistance = upCropperDistance(this.touchOne, this.touchTwo);
      this.handle = 'none';
      return;
    }
    this.touchTwo = undefined;
    this.handle = this.resizeEnabled() ? upCropperHandleAt(this.touchOne, this.selection) : 'none';
  }

  /** 上游 move()：双指缩放、控制点改框与单指平移三条分支。/ Mirrors the three branches of upstream move(). */
  private touchMove(event: GestureEvent): void {
    const fingers: Array<FingerInfo> = event.fingerList;
    if (fingers.length === 0) {
      return;
    }
    const first: UPCropperTouch = new UPCropperTouch(fingers[0].localX, fingers[0].localY);
    if (fingers.length > 1) {
      const second: UPCropperTouch = new UPCropperTouch(fingers[1].localX, fingers[1].localY);
      const distance: number = upCropperDistance(first, second);
      if (this.scaleEnabled()) {
        const delta: number = UP_CROPPER_PINCH_FACTOR * (distance - this.pinchDistance);
        this.placement = upCropperScale(this.placement, this.placement.scaleSize + delta,
          this.minScaleValue(), this.maxScaleValue(), this.selection, this.innerMode());
      }
      this.pinchDistance = distance;
      this.touchOne = first;
      this.touchTwo = second;
      this.paint();
      return;
    }
    if (this.handle !== 'none' && this.resizeEnabled()) {
      const bounds: UPCropperRect | undefined = this.innerMode()
        ? upCropperImageBounds(this.placement)
        : undefined;
      const resized: UPCropperRect | undefined = upCropperResize(this.selection, this.handle, first,
        this.viewportWidthValue(), this.viewportHeightValue(), bounds);
      if (resized !== undefined) {
        this.selection = resized;
        this.paint();
      }
      this.touchOne = first;
      return;
    }
    this.placement = upCropperTranslate(this.placement, first.x - this.touchOne.x, first.y - this.touchOne.y,
      this.selection, this.constraint, this.innerMode());
    this.touchOne = first;
    this.paint();
  }

  /** 上游 end()。/ Mirrors upstream end(). */
  private touchEnd(): void {
    this.touchTwo = undefined;
    this.handle = 'none';
  }

  /** 上游 preview()。/ Mirrors upstream preview(). */
  showPreview(): void {
    this.previewBox = upCropperPreviewPlacement(this.viewportWidthValue(), this.canvasHeightValue(), this.selection);
    this.previewBuffer = undefined;
    this.saturation = 0;
    this.previewing = true;
    this.paintPreview();
  }

  /** 上游 hideImg()。/ Mirrors upstream hideImg(). */
  private hidePreview(): void {
    this.previewing = false;
    this.previewBuffer = undefined;
    this.paint();
  }

  /** 预览层重绘：把裁剪区放大到预览框。/ Repaints the preview layer with the cropped region. */
  private paintPreview(): void {
    const canvasWidth: number = this.viewportWidthValue();
    const canvasHeight: number = this.canvasHeightValue();
    this.renderContext.clearRect(0, 0, canvasWidth, canvasHeight);
    if (this.fillEnabled()) {
      this.renderContext.fillStyle = this.fillColorValue();
      this.renderContext.fillRect(0, 0, canvasWidth, canvasHeight);
    }
    if (!isLocalCanvasSource(this.source)) {
      return;
    }
    const bounds: UPCropperRect = upCropperImageBounds(this.placement);
    const scaleX: number = bounds.width === 0 ? 1 : this.imageWidthValue() / bounds.width;
    const scaleY: number = bounds.height === 0 ? 1 : this.imageHeightValue() / bounds.height;
    this.renderContext.drawImage(new ImageBitmap(this.source),
      Math.max(0, (this.selection.left - bounds.left) * scaleX),
      Math.max(0, (this.selection.top - bounds.top) * scaleY),
      Math.max(1, this.selection.width * scaleX),
      Math.max(1, this.selection.height * scaleY),
      this.previewBox.x, this.previewBox.y, this.previewBox.width, this.previewBox.height);
  }

  /** 上游 getImageInfo 的替代：宿主传入原图尺寸，缺省时按画布尺寸兜底。/ Host-provided natural size. */
  private imageWidthValue(): number {
    const width: number = upNumber(this.props.imageWidth, 0);
    return width > 0 ? width : this.viewportWidthValue();
  }

  private imageHeightValue(): number {
    const height: number = upNumber(this.props.imageHeight, 0);
    return height > 0 ? height : this.canvasHeightValue();
  }

  /** 上游 colorChange()：读像素调饱和度后写回预览层。/ Mirrors upstream colorChange(). */
  private changeSaturation(value: number): void {
    this.saturation = value;
    const factor: number = upCropperSaturation(value);
    const width: number = Math.max(1, Math.round(this.previewBox.width));
    const height: number = Math.max(1, Math.round(this.previewBox.height));
    const originX: number = Math.max(0, Math.round(this.previewBox.x));
    const originY: number = Math.max(0, Math.round(this.previewBox.y));
    if (this.previewBuffer === undefined) {
      const snapshot: ImageData = this.renderContext.getImageData(originX, originY, width, height);
      this.previewBuffer = snapshot.data;
    }
    const buffer: Uint8ClampedArray | undefined = this.previewBuffer;
    if (buffer === undefined) {
      return;
    }
    const target: Uint8ClampedArray = upCropperSaturate(buffer, factor);
    this.renderContext.putImageData(new ImageData(width, height, target), originX, originY);
  }

  /** 上游 confirm()：导出裁剪结果。/ Mirrors upstream confirm(). */
  confirm(): void {
    const exportWidth: number = this.exportWidthValue() > 0 ? this.exportWidthValue() : this.selection.width;
    const exportHeight: number = this.exportHeightValue() > 0 ? this.exportHeightValue() : this.selection.height;
    let dataUrl: string = '';
    try {
      dataUrl = this.renderContext.toDataURL('image/png', this.qualityValue());
    } catch (_error) {
      dataUrl = '';
    }
    if (dataUrl.length === 0) {
      this.failure('export-failed', '裁剪结果导出失败');
      return;
    }
    this.opened = false;
    this.previewing = false;
    this.previewBuffer = undefined;
    this.props.onConfirm?.({
      path: dataUrl,
      source: this.source,
      index: this.indexValue(),
      width: exportWidth,
      height: exportHeight
    });
  }

  private buttons(): Array<UPCropperButton> {
    const list: Array<UPCropperButton> = [
      new UPCropperButton('select', UP_CROPPER_RESELECT_TEXT),
      new UPCropperButton('close', UP_CROPPER_CLOSE_TEXT)
    ];
    if (!this.innerMode()) {
      list.push(new UPCropperButton('rotate', UP_CROPPER_ROTATE_TEXT));
    }
    list.push(new UPCropperButton('preview', UP_CROPPER_PREVIEW_TEXT));
    list.push(new UPCropperButton('confirm', UP_CROPPER_CONFIRM_TEXT));
    return list;
  }

  private runAction(action: string): void {
    if (action === 'select') {
      this.open();
      return;
    }
    if (action === 'close') {
      this.close();
      return;
    }
    if (action === 'rotate') {
      this.rotateImage();
      return;
    }
    if (action === 'preview') {
      this.showPreview();
      return;
    }
    this.confirm();
  }

  @Builder
  private actionBar() {
    Row() {
      ForEach(this.buttons(), (button: UPCropperButton) => {
        Text(button.label)
          .fontSize(14)
          .fontColor('#ffffff')
          .layoutWeight(1)
          .height(UP_CROPPER_TAB_HEIGHT)
          .textAlign(TextAlign.Center)
          .onClick((): void => this.runAction(button.action))
      }, (button: UPCropperButton): string => button.action)
    }
    .width('100%')
    .height(UP_CROPPER_TAB_HEIGHT)
    .backgroundColor('#000000')
  }

  @Builder
  private previewBar() {
    Row({ space: 10 }) {
      UPSlider({
        props: new UPSliderProps({
          value: this.saturation,
          min: -100,
          max: 100,
          step: 1,
          showValue: true,
          activeColor: '#fa3534',
          inactiveColor: '#19be6b',
          blockColor: '#c0c4cc',
          blockSize: 25,
          onChanging: (event: UPSliderChangeEvent): void => this.changeSaturation(event.value),
          onChange: (event: UPSliderChangeEvent): void => this.changeSaturation(event.value)
        })
      })
      Text(UP_CROPPER_CONFIRM_TEXT)
        .fontSize(14)
        .fontColor('#ffffff')
        .width(72)
        .height(UP_CROPPER_TAB_HEIGHT)
        .textAlign(TextAlign.Center)
        .onClick((): void => this.confirm())
    }
    .width('100%')
    .height(UP_CROPPER_TAB_HEIGHT)
    .padding({ left: 12 })
    .backgroundColor('#000000')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private stage() {
    Column() {
      Stack() {
        Canvas(this.renderContext)
          .width(this.viewportWidthValue())
          .height(this.canvasHeightValue())
          .backgroundColor(UP_CROPPER_TRANSPARENT)
          .onReady((): void => this.paint())
          .gesture(GestureGroup(GestureMode.Parallel,
            PanGesture({ fingers: 1, direction: PanDirection.All, distance: 0 })
              .onActionStart((event: GestureEvent): void => this.touchStart(event))
              .onActionUpdate((event: GestureEvent): void => this.touchMove(event))
              .onActionEnd((): void => this.touchEnd()),
            PinchGesture({ fingers: 2, distance: 1 })
              .onActionStart((event: GestureEvent): void => this.touchStart(event))
              .onActionUpdate((event: GestureEvent): void => this.touchMove(event))
              .onActionEnd((): void => this.touchEnd())))
        if (this.previewing) {
          Column()
            .width(this.viewportWidthValue())
            .height(this.canvasHeightValue())
            .backgroundColor(UP_CROPPER_TRANSPARENT)
            .onClick((): void => this.hidePreview())
        }
      }
      .width(this.viewportWidthValue())
      .height(this.canvasHeightValue())
      .alignContent(Alignment.TopStart)
      if (this.previewing) {
        this.previewBar()
      } else {
        this.actionBar()
      }
    }
    .width('100%')
    .backgroundColor('#000000')
  }

  build() {
    Column() {
      if (this.opened) {
        this.stage()
      } else {
        Column() {
          this.contentBuilder()
        }
        .width('100%')
        .onClick((): void => this.open())
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor
      ?? UPColor.parse(UP_CROPPER_TRANSPARENT, UP_DEFAULT_THEME, '#00000000'))
  }
}
