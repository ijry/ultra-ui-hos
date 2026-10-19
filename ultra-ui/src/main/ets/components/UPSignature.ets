import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPSlider, UPSliderProps } from './UPSlider';
import { UPColor } from '../core/UPColor';

/** 上游 presetColors：黑红绿蓝黄青紫白八色。/ Upstream presetColors palette. */
export const UP_SIGNATURE_PRESET_COLORS: Array<string> = [
  '#000000',
  '#ff0000',
  '#00ff00',
  '#0000ff',
  '#ffff00',
  '#00ffff',
  '#ff00ff',
  '#ffffff'
];

/** 上游轨迹点的起笔类型。/ Upstream start point type. */
export const UP_SIGNATURE_POINT_START: string = 'start';

/** 上游轨迹点的移动类型。/ Upstream move point type. */
export const UP_SIGNATURE_POINT_MOVE: string = 'move';

/** 工具栏常态图标色，对应上游 --up-content-color。/ Default toolbar icon color. */
export const UP_SIGNATURE_ICON_COLOR: string = '#999999';

/** 工具栏禁用图标色，对应上游 --up-disabled-color。/ Disabled toolbar icon color. */
export const UP_SIGNATURE_ICON_DISABLED_COLOR: string = '#c8c9cc';

/** 单个轨迹点，对应上游 currentPath 元素。/ One recorded stroke point. */
export interface UPSignaturePoint {
  x: number;
  y: number;
  type: string;
  color: string;
  lineWidth: number;
}

/**
 * 上游 resolveStrokeColor()：暗色主题把纯黑换成浅色，本包固定浅色主题因此只做空值回落。
 * Mirrors upstream resolveStrokeColor(); this package ships a light theme so only the empty case falls back.
 */
export function upSignatureStrokeColor(color: UPRawValue): string {
  const value: string = upString(color, '#000000').trim();
  return value.length === 0 ? '#000000' : value;
}

/** thickness → lineWidth，钳制到上游滑块的 1..20 区间。/ Clamps thickness into the upstream 1..20 range. */
export function upSignatureLineWidth(value: UPRawValue): number {
  const amount: number = upNumber(value, 3);
  const numeric: number = Number.isFinite(amount) ? amount : 3;
  if (numeric < 1) {
    return 1;
  }
  if (numeric > 20) {
    return 20;
  }
  return numeric;
}

/** 工具栏按钮描述，对应上游五个 toolbar-icon。/ One toolbar button descriptor. */
interface UPSignatureToolButton {
  action: string;
  name: string;
  size: number;
  color: string;
}

export interface UPSignatureOptions {
  width?: UPRawValue;
  height?: UPRawValue;
  bgColor?: UPRawValue;
  color?: UPRawValue;
  thickness?: UPRawValue;
  showToolbar?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClear?: () => void;
  onConfirm?: (imagePath: string) => void;
  onError?: (message: string) => void;
}

export class UPSignatureProps {
  width: UPRawValue = 300;
  height: UPRawValue = 200;
  bgColor: UPRawValue = '#ffffff';
  color: UPRawValue = '#000000';
  thickness: UPRawValue = 3;
  showToolbar: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onClear?: () => void;
  onConfirm?: (imagePath: string) => void;
  onError?: (message: string) => void;

  constructor(options?: UPSignatureOptions) {
    if (options === undefined) {
      return;
    }
    this.width = options.width ?? this.width;
    this.height = options.height ?? this.height;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.color = options.color ?? this.color;
    this.thickness = options.thickness ?? this.thickness;
    this.showToolbar = options.showToolbar ?? this.showToolbar;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClear = options.onClear;
    this.onConfirm = options.onConfirm;
    this.onError = options.onError;
  }
}

@Component
export struct UPSignature {
  @Prop @Watch('applyProps') props: UPSignatureProps = new UPSignatureProps();
  @State private pathStack: Array<Array<UPSignaturePoint>> = [];
  @State private isEmpty: boolean = true;
  @State private showBrushSettings: boolean = false;
  @State private showColorSettings: boolean = false;
  @State private lineColor: string = '#000000';
  @State private lineWidth: number = 3;
  private currentPath: Array<UPSignaturePoint> = [];
  private drawing: boolean = false;
  private ready: boolean = false;
  private appliedColor: string = '#000000';
  private appliedThickness: number = 3;
  private appliedSize: string = '';
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    this.appliedColor = upSignatureStrokeColor(this.props.color);
    this.appliedThickness = upSignatureLineWidth(this.props.thickness);
    this.appliedSize = `${this.canvasWidth()}x${this.canvasHeight()}`;
    this.lineColor = this.appliedColor;
    this.lineWidth = this.appliedThickness;
    const thickness: number = upNumber(this.props.thickness, 3);
    if (thickness < 1 || thickness > 20) {
      diagnostics.report('UPSignature', 'thickness', this.props.thickness, 'thickness is clamped into the upstream slider range 1-20');
    }
    diagnostics.report('UPSignature', 'onTouch', 'PanGesture', 'strokes are captured by PanGesture(distance: 0) instead of upstream canvas touch events');
  }

  /** 上游 width/height/color/thickness 四个 immediate watch 的合并实现。/ Mirrors the four upstream watchers. */
  private applyProps(): void {
    const color: string = upSignatureStrokeColor(this.props.color);
    if (color !== this.appliedColor) {
      this.appliedColor = color;
      this.lineColor = color;
    }
    const thickness: number = upSignatureLineWidth(this.props.thickness);
    if (thickness !== this.appliedThickness) {
      this.appliedThickness = thickness;
      this.lineWidth = thickness;
    }
    const size: string = `${this.canvasWidth()}x${this.canvasHeight()}`;
    if (size !== this.appliedSize) {
      this.appliedSize = size;
      this.redraw();
    }
  }

  private canvasWidth(): number {
    const value: number = upNumber(this.props.width, 300);
    return Number.isFinite(value) && value > 0 ? value : 300;
  }

  private canvasHeight(): number {
    const value: number = upNumber(this.props.height, 200);
    return Number.isFinite(value) && value > 0 ? value : 200;
  }

  /** 上游 resolvedBgColor：浅色主题下原样返回 bgColor。/ Mirrors upstream resolvedBgColor. */
  private backdrop(): string {
    const value: string = upString(this.props.bgColor, '#ffffff').trim();
    return value.length === 0 ? '#ffffff' : value;
  }

  private toolButtons(): Array<UPSignatureToolButton> {
    const undoColor: string = this.pathStack.length === 0 ? UP_SIGNATURE_ICON_DISABLED_COLOR : UP_SIGNATURE_ICON_COLOR;
    const exportColor: string = this.isEmpty ? UP_SIGNATURE_ICON_DISABLED_COLOR : UP_SIGNATURE_ICON_COLOR;
    const buttons: Array<UPSignatureToolButton> = [
      { action: 'undo', name: 'arrow-left', size: 22, color: undoColor },
      { action: 'clear', name: 'trash', size: 25, color: UP_SIGNATURE_ICON_COLOR },
      { action: 'brush', name: 'edit-pen', size: 25, color: UP_SIGNATURE_ICON_COLOR },
      { action: 'color', name: 'grid', size: 24, color: UP_SIGNATURE_ICON_COLOR },
      { action: 'export', name: 'checkmark', size: 25, color: exportColor }
    ];
    return buttons;
  }

  private runAction(action: string): void {
    if (action === 'undo') {
      this.undo();
      return;
    }
    if (action === 'clear') {
      this.clear();
      return;
    }
    if (action === 'brush') {
      this.toggleBrushSettings();
      return;
    }
    if (action === 'color') {
      this.toggleColorSettings();
      return;
    }
    this.exportSignature();
  }

  /** 上游 mounted：拿到实例后立刻清屏铺底。/ Mirrors upstream mounted() clearCanvas(). */
  private handleReady(): void {
    this.ready = true;
    this.clearCanvas();
    if (this.pathStack.length > 0) {
      this.redraw();
    }
  }

  private pointOf(event: GestureEvent, type: string): UPSignaturePoint | undefined {
    const fingers: Array<FingerInfo> = event.fingerList;
    if (fingers.length === 0) {
      return undefined;
    }
    const finger: FingerInfo = fingers[0];
    return {
      x: finger.localX,
      y: finger.localY,
      type: type,
      color: this.lineColor,
      lineWidth: this.lineWidth
    };
  }

  /** 上游 touchStart()：起笔时设置线条样式并记录起点。/ Mirrors upstream touchStart(). */
  private handleStart(event: GestureEvent): void {
    if (!this.ready) {
      return;
    }
    const point: UPSignaturePoint | undefined = this.pointOf(event, UP_SIGNATURE_POINT_START);
    if (point === undefined) {
      return;
    }
    this.drawing = true;
    this.isEmpty = false;
    this.currentPath = [point];
    this.applyLineStyle(point.color, point.lineWidth);
    this.renderContext.beginPath();
    this.renderContext.moveTo(point.x, point.y);
  }

  /** 上游 touchMove()：连线并即时描边。/ Mirrors upstream touchMove(). */
  private handleUpdate(event: GestureEvent): void {
    if (!this.drawing || !this.ready) {
      return;
    }
    const point: UPSignaturePoint | undefined = this.pointOf(event, UP_SIGNATURE_POINT_MOVE);
    if (point === undefined) {
      return;
    }
    this.currentPath.push(point);
    this.renderContext.lineTo(point.x, point.y);
    this.renderContext.stroke();
  }

  /** 上游 touchEnd()：收笔并把当前路径压入回退栈。/ Mirrors upstream touchEnd(). */
  private handleEnd(): void {
    if (!this.drawing) {
      return;
    }
    this.drawing = false;
    if (this.ready) {
      this.renderContext.closePath();
    }
    if (this.currentPath.length > 0) {
      this.pathStack.push(this.currentPath);
    }
    this.currentPath = [];
  }

  /** 上游 setLineStyle()：圆头圆角 + 颜色 + 线宽。/ Mirrors upstream setLineStyle(). */
  private applyLineStyle(color: string, lineWidth: number): void {
    this.renderContext.lineCap = 'round';
    this.renderContext.lineJoin = 'round';
    this.renderContext.strokeStyle = color;
    this.renderContext.lineWidth = lineWidth;
  }

  /** 上游 undo()：弹出最后一条路径后整屏重绘。/ Mirrors upstream undo(). */
  private undo(): void {
    if (this.pathStack.length === 0) {
      return;
    }
    this.pathStack.pop();
    this.redraw();
  }

  /** 上游 clear()：清栈清屏并抛出 clear。/ Mirrors upstream clear(). */
  private clear(): void {
    this.pathStack = [];
    this.currentPath = [];
    this.drawing = false;
    this.isEmpty = true;
    this.clearCanvas();
    const callback: (() => void) | undefined = this.props.onClear;
    if (callback !== undefined) {
      callback();
    }
  }

  /** 上游 redraw()：清屏后逐条路径重放。/ Mirrors upstream redraw(). */
  private redraw(): void {
    if (!this.ready) {
      return;
    }
    this.clearCanvas();
    if (this.pathStack.length === 0) {
      this.isEmpty = true;
      return;
    }
    this.isEmpty = false;
    for (let index = 0; index < this.pathStack.length; index++) {
      const path: Array<UPSignaturePoint> = this.pathStack[index];
      if (path.length === 0) {
        continue;
      }
      this.renderContext.beginPath();
      for (let cursor = 0; cursor < path.length; cursor++) {
        const point: UPSignaturePoint = path[cursor];
        if (cursor === 0 && point.type === UP_SIGNATURE_POINT_START) {
          this.applyLineStyle(point.color, point.lineWidth);
          this.renderContext.moveTo(point.x, point.y);
        } else if (point.type === UP_SIGNATURE_POINT_MOVE) {
          this.renderContext.lineTo(point.x, point.y);
        }
      }
      this.renderContext.stroke();
    }
  }

  /** 上游 clearCanvas()：清屏后按 bgColor 铺底。/ Mirrors upstream clearCanvas(). */
  private clearCanvas(): void {
    if (!this.ready) {
      return;
    }
    const boxWidth: number = this.canvasWidth();
    const boxHeight: number = this.canvasHeight();
    this.renderContext.clearRect(0, 0, boxWidth, boxHeight);
    const background: string = this.backdrop();
    if (background !== 'transparent') {
      this.renderContext.beginPath();
      this.renderContext.rect(0, 0, boxWidth, boxHeight);
      this.renderContext.fillStyle = background;
      this.renderContext.fill();
    }
  }

  /** 上游 exportSignature()：重绘后导出图片并抛出 confirm。/ Mirrors upstream exportSignature(). */
  private exportSignature(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (this.isEmpty || this.pathStack.length === 0) {
      diagnostics.report('UPSignature', 'confirm', '', 'the signature is empty so upstream skips the export');
      return;
    }
    if (!this.ready) {
      this.reportError('无法获取画布实例');
      return;
    }
    this.redraw();
    diagnostics.report('UPSignature', 'confirm', 'data-url', 'exportImage() returns a base64 data URL instead of a temp file path');
    let dataUrl: string = '';
    try {
      dataUrl = this.renderContext.toDataURL('image/png', 1);
    } catch (_) {
      dataUrl = '';
    }
    if (dataUrl.length === 0) {
      this.reportError('导出签名图片失败');
      return;
    }
    const callback: ((imagePath: string) => void) | undefined = this.props.onConfirm;
    if (callback !== undefined) {
      callback(dataUrl);
    }
  }

  private reportError(message: string): void {
    const callback: ((message: string) => void) | undefined = this.props.onError;
    if (callback !== undefined) {
      callback(message);
    }
  }

  /** 上游 toggleBrushSettings()：两个面板互斥。/ Mirrors upstream toggleBrushSettings(). */
  private toggleBrushSettings(): void {
    this.showBrushSettings = !this.showBrushSettings;
    if (this.showBrushSettings) {
      this.showColorSettings = false;
    }
  }

  /** 上游 toggleColorSettings()：两个面板互斥。/ Mirrors upstream toggleColorSettings(). */
  private toggleColorSettings(): void {
    this.showColorSettings = !this.showColorSettings;
    if (this.showColorSettings) {
      this.showBrushSettings = false;
    }
  }

  /** 上游 selectColor()：仅切换当前笔色。/ Mirrors upstream selectColor(). */
  private selectColor(color: string): void {
    this.lineColor = color;
  }

  @Builder
  private canvasFrame() {
    Canvas(this.renderContext)
      .width(this.canvasWidth())
      .height(this.canvasHeight())
      .backgroundColor(this.backdrop())
      .border({ width: 1, color: '#e0e0e0', radius: 4 })
      .onReady((): void => this.handleReady())
      .gesture(PanGesture({ fingers: 1, direction: PanDirection.All, distance: 0 })
        .onActionStart((event: GestureEvent): void => this.handleStart(event))
        .onActionUpdate((event: GestureEvent): void => this.handleUpdate(event))
        .onActionEnd((): void => this.handleEnd())
        .onActionCancel((): void => this.handleEnd()))
  }

  @Builder
  private toolButton(item: UPSignatureToolButton) {
    Column() {
      UPIcon({ props: new UPIconProps({ name: item.name, size: item.size, color: item.color }) })
    }
    .padding(6)
    .onClick((): void => {
      this.runAction(item.action);
    })
  }

  @Builder
  private brushSettings() {
    Row({ space: 8 }) {
      Text('笔画粗细:').fontSize(13).fontColor(UPColor.adaptive('#606266', 'content-color'))
      UPSlider({
        props: new UPSliderProps({
          modelValue: this.lineWidth,
          min: 1,
          max: 20,
          step: 1,
          length: 180,
          showValue: true,
          onModelValueChange: (value: number): void => {
            this.lineWidth = value;
          }
        })
      })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private colorSettings() {
    Row({ space: 8 }) {
      Text('笔画颜色:').fontSize(13).fontColor(UPColor.adaptive('#606266', 'content-color'))
      Row({ space: 8 }) {
        ForEach(UP_SIGNATURE_PRESET_COLORS, (color: string): void => {
          Column()
            .width(30)
            .height(30)
            .borderRadius(15)
            .backgroundColor(color)
            .border({
              width: this.lineColor === color ? 2 : 1,
              color: this.lineColor === color ? '#3c9cff' : '#dcdfe6'
            })
            .onClick((): void => {
              this.selectColor(color);
            })
        }, (color: string): string => color)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private toolPanel() {
    Column({ space: 10 }) {
      Row({ space: 20 }) {
        ForEach(this.toolButtons(), (item: UPSignatureToolButton): void => {
          this.toolButton(item);
        }, (item: UPSignatureToolButton): string => item.action)
      }
      .justifyContent(FlexAlign.Center)
      if (this.showBrushSettings) {
        this.brushSettings()
      }
      if (this.showColorSettings) {
        this.colorSettings()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column({ space: 10 }) {
      this.canvasFrame()
      if (upBoolean(this.props.showToolbar, true)) {
        this.toolPanel()
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .alignItems(HorizontalAlign.Start)
  }
}
