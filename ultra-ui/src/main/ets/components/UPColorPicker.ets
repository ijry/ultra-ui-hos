import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPSubsection, UPSubsectionItem, UPSubsectionProps } from './UPSubsection';
import { UPButton, UPButtonProps } from './UPButton';
import { UPSlotRegion } from '../internal/UPSlotRegion';

/** 渐变控制条宽度，对应上游 getGradientPointerPosition() 里硬编码的 280。/ Upstream hard-coded gradient track width. */
export const UP_COLOR_PICKER_TRACK_WIDTH: number = 280;

/** 渐变节点上限，对应上游 addGradientColor() 的 5。/ Upstream gradient stop ceiling. */
export const UP_COLOR_PICKER_GRADIENT_MAX: number = 5;

/** 渐变节点下限，对应上游 removeGradientColor() 的 2。/ Upstream gradient stop floor. */
export const UP_COLOR_PICKER_GRADIENT_MIN: number = 2;

/** 单个渐变节点，对应上游 gradientColors 元素。/ One gradient stop. */
export interface UPColorPickerStop {
  color: string;
  percent: number;
}

/** 渐变方向，对应上游 gradientDirections 元素。/ One gradient direction descriptor. */
export interface UPColorPickerDirection {
  label: string;
  value: string;
}

/** 上游 gradientDirections 的四个预设方向。/ Upstream preset gradient directions. */
export const UP_COLOR_PICKER_DIRECTIONS: Array<UPColorPickerDirection> = [
  { label: '从左到右', value: 'to right' },
  { label: '从上到下', value: 'to bottom' },
  { label: '从左上到右下', value: 'to bottom right' },
  { label: '从右上到左下', value: 'to bottom left' }
];

/** 上游 hslToRgb() 内部的 hue2rgb 闭包。/ Upstream hue2rgb helper. */
function upColorPickerHueToRgb(start: number, end: number, ratio: number): number {
  let value: number = ratio;
  if (value < 0) {
    value += 1;
  }
  if (value > 1) {
    value -= 1;
  }
  if (value < 1 / 6) {
    return start + (end - start) * 6 * value;
  }
  if (value < 1 / 2) {
    return end;
  }
  if (value < 2 / 3) {
    return start + (end - start) * (2 / 3 - value) * 6;
  }
  return start;
}

/**
 * 上游 hslToRgb()：HSL 转 rgba() 字符串，UPColor 不认 hsl() 所以必须自实现。
 * Mirrors upstream hslToRgb(); UPColor cannot parse hsl() so the conversion is done here.
 */
export function upColorPickerHslToRgb(hue: number, saturation: number, lightness: number, alpha: number = 1): string {
  const normalizedHue: number = hue / 360;
  const normalizedSaturation: number = saturation / 100;
  const normalizedLightness: number = lightness / 100;
  let red: number = normalizedLightness;
  let green: number = normalizedLightness;
  let blue: number = normalizedLightness;
  if (normalizedSaturation !== 0) {
    const end: number = normalizedLightness < 0.5 ?
      normalizedLightness * (1 + normalizedSaturation) :
      normalizedLightness + normalizedSaturation - normalizedLightness * normalizedSaturation;
    const start: number = 2 * normalizedLightness - end;
    red = upColorPickerHueToRgb(start, end, normalizedHue + 1 / 3);
    green = upColorPickerHueToRgb(start, end, normalizedHue);
    blue = upColorPickerHueToRgb(start, end, normalizedHue - 1 / 3);
  }
  const redValue: number = Math.round(red * 255);
  const greenValue: number = Math.round(green * 255);
  const blueValue: number = Math.round(blue * 255);
  return `rgba(${redValue}, ${greenValue}, ${blueValue}, ${alpha.toFixed(2)})`;
}

/** 上游 getDirectionAngle()：CSS 方向关键字转角度。/ Mirrors upstream getDirectionAngle(). */
export function upColorPickerDirectionAngle(value: UPRawValue): number {
  switch (upString(value, 'to right')) {
    case 'to right': return 0;
    case 'to bottom': return 90;
    case 'to left': return 180;
    case 'to top': return 270;
    case 'to bottom right': return 45;
    case 'to bottom left': return 135;
    case 'to top left': return 225;
    case 'to top right': return 315;
    default: return 0;
  }
}

/** 上游 updateGradientDirection()：角度落到四个方向区间。/ Mirrors upstream updateGradientDirection(). */
export function upColorPickerDirectionFromAngle(angle: number): UPColorPickerDirection {
  let value: number = angle;
  if (value < 0) {
    value += 360;
  }
  if (value >= 315 || value < 45) {
    return { label: '从左到右', value: 'to right' };
  }
  if (value >= 45 && value < 135) {
    return { label: '从上到下', value: 'to bottom' };
  }
  if (value >= 135 && value < 225) {
    return { label: '从右到左', value: 'to left' };
  }
  return { label: '从下到上', value: 'to top' };
}

/** 上游 gradientStyle 计算属性：拼出 linear-gradient() 字符串。/ Mirrors the upstream gradientStyle getter. */
export function upColorPickerGradientCss(stops: Array<UPColorPickerStop>, directionValue: UPRawValue): string {
  const parts: string = stops
    .map((item: UPColorPickerStop): string => `${item.color} ${Math.round(item.percent * 100)}%`)
    .join(', ');
  return `linear-gradient(${upString(directionValue, 'to right')}, ${parts})`;
}

/**
 * CSS 方向关键字转 ArkUI linearGradient 角度（ArkUI 0° 朝上、90° 朝右）。
 * Converts a CSS direction keyword to the ArkUI linearGradient angle.
 */
export function upColorPickerArkAngle(value: UPRawValue): number {
  switch (upString(value, 'to right')) {
    case 'to right': return 90;
    case 'to bottom': return 180;
    case 'to left': return 270;
    case 'to top': return 0;
    case 'to bottom right': return 135;
    case 'to bottom left': return 225;
    case 'to top left': return 315;
    case 'to top right': return 45;
    default: return 90;
  }
}

/** 上游 addGradientColor()：不超过五个节点时追加白色节点。/ Mirrors upstream addGradientColor(). */
export function upColorPickerAddStop(stops: Array<UPColorPickerStop>): Array<UPColorPickerStop> {
  const next: Array<UPColorPickerStop> = stops.slice();
  if (next.length < UP_COLOR_PICKER_GRADIENT_MAX) {
    next.push({ color: '#ffffff', percent: 1 });
  }
  return next;
}

/** 上游 removeGradientColor()：多于两个节点时删除指定节点。/ Mirrors upstream removeGradientColor(). */
export function upColorPickerRemoveStop(stops: Array<UPColorPickerStop>, index: number): Array<UPColorPickerStop> {
  const next: Array<UPColorPickerStop> = stops.slice();
  if (next.length > UP_COLOR_PICKER_GRADIENT_MIN && index >= 0 && index < next.length) {
    next.splice(index, 1);
  }
  return next;
}

export interface UPColorPickerOptions {
  modelValue?: UPRawValue;
  commonColors?: Array<UPRawValue>;
  show?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onModelValueChange?: (color: string) => void;
  onConfirm?: (color: string) => void;
  onClose?: () => void;
  onClosed?: () => void;
  contentBuilder?: UPBuilder;
}

export class UPColorPickerProps {
  modelValue: UPRawValue = '#ff0000';
  commonColors: Array<UPRawValue> = [];
  show: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onModelValueChange?: (color: string) => void;
  onConfirm?: (color: string) => void;
  onClose?: () => void;
  onClosed?: () => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPColorPickerOptions) {
    if (options === undefined) {
      return;
    }
    this.modelValue = options.modelValue ?? this.modelValue;
    this.commonColors = options.commonColors ?? this.commonColors;
    this.show = options.show ?? this.show;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onModelValueChange = options.onModelValueChange;
    this.onConfirm = options.onConfirm;
    this.onClose = options.onClose;
    this.onClosed = options.onClosed;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPColorPicker {
  @Prop @Watch('applyProps') props: UPColorPickerProps = new UPColorPickerProps();

  @State private colorTypeIndex: number = 0;
  @State private hue: number = 0;
  @State private saturation: number = 100;
  @State private lightness: number = 50;
  @State private alphaValue: number = 1;
  @State private saturationPointerX: number = 150;
  @State private saturationPointerY: number = 0;
  @State private huePosition: number = 0;
  @State private alphaPosition: number = 0;
  @State private gradientStops: Array<UPColorPickerStop> = [
    { color: '#ff0000', percent: 0 },
    { color: '#0000ff', percent: 1 }
  ];
  @State private directionValue: string = 'to right';
  @State private directionLabel: string = '从左到右';
  @State private directionPointerX: number = 40;
  @State private directionPointerY: number = 20;
  @State private currentColor: string = '#ff0000';
  @State private previewType: string = 'solid';
  @State private editingIndex: number = -1;
  @State private saturationWidth: number = 0;
  @State private saturationHeight: number = 0;
  @State private hueWidth: number = 0;
  @State private alphaWidth: number = 0;
  @State private trackWidth: number = UP_COLOR_PICKER_TRACK_WIDTH;
  @State private circleSize: number = 40;

  private draggingIndex: number = -1;
  private appliedShow: boolean = false;
  private alphaReady: boolean = false;
  private trackOriginX: number = 0;
  private savedHue: number = 0;
  private savedSaturation: number = 100;
  private savedLightness: number = 50;
  private savedAlpha: number = 1;
  private savedSaturationX: number = 150;
  private savedSaturationY: number = 0;
  private savedHuePosition: number = 0;
  private savedAlphaPosition: number = 0;
  private savedSolidColor: string = '#ff0000';
  private savedStops: Array<UPColorPickerStop> = [
    { color: '#ff0000', percent: 0 },
    { color: '#0000ff', percent: 1 }
  ];
  private savedDirectionValue: string = 'to right';
  private savedDirectionLabel: string = '从左到右';
  private savedPointerX: number = 100;
  private savedPointerY: number = 0;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    diagnostics.report('UPColorPicker', 'trigger', 'slot',
      'the upstream trigger slot is replaced by the controlled show property');
    diagnostics.report('UPColorPicker', 'onTouch', 'PanGesture',
      'touchstart/touchmove/touchend are replaced by PanGesture(distance: 0) with fingerList localX/localY');
    diagnostics.report('UPColorPicker', 'saturation', 'Math.min(width, height)',
      'upstream normalises saturation with Math.min(width, height) which can exceed 100%; each axis is normalised separately here');
    diagnostics.report('UPColorPicker', 'alphaBackground', 'checkerboard',
      'the 10px checkerboard is approximated with a flat #f2f2f2 base plus a white overlay gradient');
    diagnostics.report('UPColorPicker', 'directionCircle', 'conic-gradient',
      'conic-gradient is approximated with sweepGradient so the 0 degree origin may differ slightly');
    this.appliedShow = upBoolean(this.props.show, false);
    this.initColor();
  }

  private applyProps(): void {
    const next: boolean = upBoolean(this.props.show, false);
    if (next && !this.appliedShow) {
      this.initColor();
    }
    this.appliedShow = next;
  }

  /** 上游 initColor()：按 modelValue 判定纯色/渐变。/ Mirrors upstream initColor(). */
  private initColor(): void {
    const value: string = upString(this.props.modelValue, '').trim();
    if (value.length > 0) {
      this.currentColor = value;
      if (value.indexOf('linear-gradient') >= 0) {
        this.colorTypeIndex = 1;
        this.previewType = 'gradient';
        const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
        diagnostics.report('UPColorPicker', 'modelValue', value,
          'upstream parseGradientColor() does not reverse parse stops either, so the default stops stay in place');
      } else {
        this.colorTypeIndex = 0;
        this.previewType = 'solid';
      }
    }
    this.initDirectionPointer();
  }

  /** 上游 initDirectionPointer()。/ Mirrors upstream initDirectionPointer(). */
  private initDirectionPointer(): void {
    this.setDirectionPointerByAngle(upColorPickerDirectionAngle(this.directionValue));
  }

  /** 上游 setDirectionPointerByAngle()。/ Mirrors upstream setDirectionPointerByAngle(). */
  private setDirectionPointerByAngle(angle: number): void {
    const radian: number = angle * Math.PI / 180;
    const radius: number = this.wheelRadius();
    this.directionPointerX = radius * Math.cos(radian) + radius;
    this.directionPointerY = radius * Math.sin(radian) + radius;
  }

  private wheelRadius(): number {
    return (this.circleSize > 0 ? this.circleSize : 40) / 2;
  }

  private measure(value: Length): number {
    if (typeof value === 'number') {
      return Math.max(0, value);
    }
    if (typeof value === 'string') {
      const numeric: number = Number.parseFloat(value);
      return Number.isFinite(numeric) ? Math.max(0, numeric) : 0;
    }
    return 0;
  }

  private typeList(): Array<UPSubsectionItem> {
    const list: Array<UPSubsectionItem> = [{ name: '纯色' }, { name: '渐变' }];
    return list;
  }

  private stopIndexes(): Array<number> {
    return this.gradientStops.map((_item: UPColorPickerStop, index: number): number => index);
  }

  private commonColorList(): Array<string> {
    return this.props.commonColors
      .map((item: UPRawValue): string => upString(item, '').trim())
      .filter((item: string): boolean => item.length > 0);
  }

  /** 色相与方向盘共用的七段光谱。/ Spectrum shared by the hue bar and the direction wheel. */
  private spectrumColors(): Array<[ResourceColor, number]> {
    const colors: Array<[ResourceColor, number]> = [
      ['#ff0000', 0],
      ['#ffff00', 0.1666],
      ['#00ff00', 0.3333],
      ['#00ffff', 0.5],
      ['#0000ff', 0.6666],
      ['#ff00ff', 0.8333],
      ['#ff0000', 1]
    ];
    return colors;
  }

  private trackColors(): Array<[ResourceColor, number]> {
    const colors: Array<[ResourceColor, number]> = [];
    this.gradientStops.forEach((item: UPColorPickerStop): void => {
      colors.push([UPColor.parse(item.color, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')), item.percent]);
    });
    if (colors.length < 2) {
      colors.push(['#ffffff', 0]);
      colors.push(['#ffffff', 1]);
    }
    return colors;
  }

  private gradientCss(): string {
    return upColorPickerGradientCss(this.gradientStops, this.directionValue);
  }

  /** 上游 displayColor 计算属性。/ Mirrors the upstream displayColor getter. */
  private displayColor(): string {
    if (this.previewType === 'gradient-point' && this.editingIndex >= 0 && this.editingIndex < this.gradientStops.length) {
      return this.gradientStops[this.editingIndex].color;
    }
    return this.currentColor;
  }

  private previewIsGradient(): boolean {
    return this.displayColor().indexOf('linear-gradient') >= 0;
  }

  private setStopColor(index: number, color: string): void {
    if (index < 0 || index >= this.gradientStops.length) {
      const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
      diagnostics.report('UPColorPicker', 'editingGradientIndex', index,
        'upstream writes gradientColors[-1].color and throws; the write is skipped here');
      return;
    }
    const next: Array<UPColorPickerStop> = this.gradientStops.slice();
    next[index] = { color: color, percent: next[index].percent };
    this.gradientStops = next;
  }

  private saveSolidState(): void {
    this.savedHue = this.hue;
    this.savedSaturation = this.saturation;
    this.savedLightness = this.lightness;
    this.savedAlpha = this.alphaValue;
    this.savedSaturationX = this.saturationPointerX;
    this.savedSaturationY = this.saturationPointerY;
    this.savedHuePosition = this.huePosition;
    this.savedAlphaPosition = this.alphaPosition;
    this.savedSolidColor = this.currentColor;
  }

  private restoreSolidState(): void {
    this.hue = this.savedHue;
    this.saturation = this.savedSaturation;
    this.lightness = this.savedLightness;
    this.alphaValue = this.savedAlpha;
    this.saturationPointerX = this.savedSaturationX;
    this.saturationPointerY = this.savedSaturationY;
    this.huePosition = this.savedHuePosition;
    this.alphaPosition = this.savedAlphaPosition;
    this.currentColor = this.savedSolidColor;
  }

  private saveGradientState(): void {
    this.savedStops = this.gradientStops.slice();
    this.savedDirectionValue = this.directionValue;
    this.savedDirectionLabel = this.directionLabel;
    this.savedPointerX = this.directionPointerX;
    this.savedPointerY = this.directionPointerY;
  }

  private restoreGradientState(): void {
    this.gradientStops = this.savedStops.slice();
    this.directionValue = this.savedDirectionValue;
    this.directionLabel = this.savedDirectionLabel;
    this.directionPointerX = this.savedPointerX;
    this.directionPointerY = this.savedPointerY;
  }

  /** 上游 changeColorType()：切换前存档、切换后还原。/ Mirrors upstream changeColorType(). */
  private changeColorType(index: number): void {
    if (this.colorTypeIndex === 0) {
      this.saveSolidState();
    } else {
      this.saveGradientState();
    }
    this.colorTypeIndex = index;
    if (index === 0) {
      this.restoreSolidState();
      this.previewType = 'solid';
      this.editingIndex = -1;
    } else {
      this.restoreGradientState();
      this.previewType = 'gradient';
    }
  }

  /** 上游 parseSolidColor()：编辑渐变节点时会把颜色写回节点并切回渐变模式。/ Mirrors upstream parseSolidColor(). */
  private parseSolidColor(color: string): void {
    this.currentColor = color;
    if (this.editingIndex >= 0) {
      this.setStopColor(this.editingIndex, color);
      this.colorTypeIndex = 1;
      this.restoreSolidState();
      this.previewType = 'gradient-point';
    } else {
      this.previewType = 'solid';
    }
  }

  /** 上游 openColorPickerForGradient()。/ Mirrors upstream openColorPickerForGradient(). */
  private openStopEditor(index: number): void {
    if (index < 0 || index >= this.gradientStops.length) {
      return;
    }
    this.editingIndex = index;
    const color: string = this.gradientStops[index].color;
    this.currentColor = color;
    this.previewType = 'gradient-point';
    if (color.indexOf('linear-gradient') < 0) {
      this.colorTypeIndex = 0;
      this.parseSolidColor(color);
      this.saveGradientState();
    }
  }

  /** 上游 updateSolidColor()：按面板尺寸换算 HSL 并写回当前颜色。/ Mirrors upstream updateSolidColor(). */
  private updateSolidColor(): void {
    const panelWidth: number = this.saturationWidth > 0 ? this.saturationWidth : 150;
    const panelHeight: number = this.saturationHeight > 0 ? this.saturationHeight : 150;
    this.saturation = Math.max(0, Math.min(100, this.saturationPointerX / panelWidth * 100));
    this.lightness = Math.max(0, Math.min(100, 100 - this.saturationPointerY / panelHeight * 100));
    const color: string = upColorPickerHslToRgb(this.hue, this.saturation, this.lightness, this.alphaValue);
    if (this.colorTypeIndex === 0) {
      this.currentColor = color;
    } else {
      this.setStopColor(this.editingIndex, color);
    }
  }

  private finger(event: GestureEvent): FingerInfo | undefined {
    const fingers: Array<FingerInfo> = event.fingerList;
    return fingers.length === 0 ? undefined : fingers[0];
  }

  /** 上游 updateSaturationPosition()。/ Mirrors upstream updateSaturationPosition(). */
  private updateSaturationPosition(event: GestureEvent): void {
    const point: FingerInfo | undefined = this.finger(event);
    if (point === undefined) {
      return;
    }
    const panelWidth: number = this.saturationWidth > 0 ? this.saturationWidth : 150;
    const panelHeight: number = this.saturationHeight > 0 ? this.saturationHeight : 150;
    this.saturationPointerX = Math.max(0, Math.min(point.localX, panelWidth));
    this.saturationPointerY = Math.max(0, Math.min(point.localY, panelHeight));
    this.updateSolidColor();
  }

  /** 上游 updateHuePosition()。/ Mirrors upstream updateHuePosition(). */
  private updateHuePosition(event: GestureEvent): void {
    const point: FingerInfo | undefined = this.finger(event);
    if (point === undefined) {
      return;
    }
    const barWidth: number = this.hueWidth > 0 ? this.hueWidth : 150;
    const offsetX: number = Math.max(0, Math.min(point.localX, barWidth));
    this.huePosition = offsetX;
    this.hue = Math.round(offsetX / barWidth * 360);
    this.updateSolidColor();
  }

  /** 上游 updateAlphaPosition()。/ Mirrors upstream updateAlphaPosition(). */
  private updateAlphaPosition(event: GestureEvent): void {
    const point: FingerInfo | undefined = this.finger(event);
    if (point === undefined) {
      return;
    }
    const barWidth: number = this.alphaWidth > 0 ? this.alphaWidth : 150;
    const offsetX: number = Math.max(0, Math.min(point.localX, barWidth));
    this.alphaPosition = offsetX;
    this.alphaValue = offsetX / barWidth;
    this.updateSolidColor();
  }

  /** 上游 onPointerTouchStart() 与节点 @click 合并到一次手势起点。/ Merges the upstream pointer touchstart and click. */
  private startStopDrag(index: number): void {
    this.draggingIndex = index;
    this.openStopEditor(index);
  }

  /** 上游 onPointerTouchMove()：按轨道宽度换算百分比并重排节点。/ Mirrors upstream onPointerTouchMove(). */
  private updateStopDrag(event: GestureEvent): void {
    if (this.draggingIndex < 0) {
      return;
    }
    const point: FingerInfo | undefined = this.finger(event);
    if (point === undefined) {
      return;
    }
    const barWidth: number = this.trackWidth > 0 ? this.trackWidth : UP_COLOR_PICKER_TRACK_WIDTH;
    const offsetX: number = Math.max(0, Math.min(point.globalX - this.trackOriginX, barWidth));
    const percent: number = offsetX / barWidth;
    const next: Array<UPColorPickerStop> = this.gradientStops.slice();
    next[this.draggingIndex] = { color: next[this.draggingIndex].color, percent: percent };
    next.sort((left: UPColorPickerStop, right: UPColorPickerStop): number => left.percent - right.percent);
    this.gradientStops = next;
    this.draggingIndex = next.findIndex((item: UPColorPickerStop): boolean => Math.abs(item.percent - percent) < 0.0001);
    this.editingIndex = this.draggingIndex;
  }

  private endStopDrag(): void {
    this.draggingIndex = -1;
  }

  /** 上游 updateDirection()：限制在圆内并按 atan2 求角度。/ Mirrors upstream updateDirection(). */
  private updateDirection(event: GestureEvent): void {
    const point: FingerInfo | undefined = this.finger(event);
    if (point === undefined) {
      return;
    }
    const radius: number = this.wheelRadius();
    const offsetX: number = point.localX - radius;
    const offsetY: number = point.localY - radius;
    const distance: number = Math.sqrt(offsetX * offsetX + offsetY * offsetY);
    if (distance <= radius || distance === 0) {
      this.directionPointerX = offsetX + radius;
      this.directionPointerY = offsetY + radius;
    } else {
      const ratio: number = radius / distance;
      this.directionPointerX = offsetX * ratio + radius;
      this.directionPointerY = offsetY * ratio + radius;
    }
    const angle: number = Math.atan2(offsetY, offsetX) * 180 / Math.PI;
    const next: UPColorPickerDirection = upColorPickerDirectionFromAngle(angle);
    this.directionValue = next.value;
    this.directionLabel = next.label;
  }

  /** 上游 addGradientColor()。/ Mirrors upstream addGradientColor(). */
  private addStop(): void {
    this.gradientStops = upColorPickerAddStop(this.gradientStops);
  }

  /** 上游 selectCommonColor()。/ Mirrors upstream selectCommonColor(). */
  private selectCommonColor(color: string): void {
    this.currentColor = color;
    if (this.colorTypeIndex === 0) {
      this.parseSolidColor(color);
    } else {
      this.setStopColor(this.editingIndex, color);
    }
  }

  /** 上游 confirm()。/ Mirrors upstream confirm(). */
  private confirm(): void {
    const color: string = this.colorTypeIndex === 1 ? this.gradientCss() : this.currentColor;
    this.props.onModelValueChange?.(color);
    this.props.onConfirm?.(color);
    this.editingIndex = -1;
    this.previewType = this.colorTypeIndex === 0 ? 'solid' : 'gradient';
    this.close();
  }

  /** 上游 close()：本包由调用方把 show 置为 false。/ Mirrors upstream close(); the caller owns show. */
  private close(): void {
    this.props.onClose?.();
    this.props.onClosed?.();
  }

  private captureSaturation(area: Area): void {
    this.saturationWidth = this.measure(area.width);
    this.saturationHeight = this.measure(area.height);
  }

  private captureHue(area: Area): void {
    this.hueWidth = this.measure(area.width);
  }

  /**
   * 上游 initAlphaPosition() 会顺带调用 updateSolidColor() 把预览刷成白色，本包只对齐位置。
   * Upstream initAlphaPosition() also calls updateSolidColor() and wipes the preview; only the position is aligned here.
   */
  private captureAlpha(area: Area): void {
    const barWidth: number = this.measure(area.width);
    this.alphaWidth = barWidth;
    if (!this.alphaReady && barWidth > 0) {
      this.alphaReady = true;
      this.alphaPosition = barWidth;
      this.savedAlphaPosition = barWidth;
    }
  }

  private captureTrack(area: Area): void {
    this.trackWidth = this.measure(area.width);
    this.trackOriginX = this.measure(area.globalPosition.x ?? 0);
  }

  private captureWheel(area: Area): void {
    const size: number = this.measure(area.width);
    if (size > 0) {
      this.circleSize = size;
    }
  }

  @Builder
  private saturationPanel() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({ angle: 90, colors: [['#ffffff', 0], ['rgba(255, 255, 255, 0)', 1]] })
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({ angle: 0, colors: [['#000000', 0], ['rgba(0, 0, 0, 0)', 1]] })
      Column()
        .width(12)
        .height(12)
        .borderRadius(6)
        .border({ width: 2, color: '#ffffff' })
        .position({ x: this.saturationPointerX - 6, y: this.saturationPointerY - 6 })
    }
    .width('100%')
    .height(150)
    .borderRadius(4)
    .backgroundColor(upColorPickerHslToRgb(this.hue, 100, 50, 1))
    .onAreaChange((_oldValue: Area, newValue: Area): void => this.captureSaturation(newValue))
    .gesture(PanGesture({ fingers: 1, direction: PanDirection.All, distance: 0 })
      .onActionStart((event: GestureEvent): void => this.updateSaturationPosition(event))
      .onActionUpdate((event: GestureEvent): void => this.updateSaturationPosition(event))
      .onActionEnd((event: GestureEvent): void => this.updateSaturationPosition(event)))
  }

  @Builder
  private hueBar() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(12)
        .borderRadius(6)
        .linearGradient({ angle: 90, colors: this.spectrumColors() })
      Column()
        .width(4)
        .height(16)
        .borderRadius(2)
        .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
        .border({ width: 1, color: '#cccccc' })
        .position({ x: this.huePosition - 2, y: -2 })
    }
    .width('100%')
    .height(12)
    .onAreaChange((_oldValue: Area, newValue: Area): void => this.captureHue(newValue))
    .gesture(PanGesture({ fingers: 1, direction: PanDirection.All, distance: 0 })
      .onActionStart((event: GestureEvent): void => this.updateHuePosition(event))
      .onActionUpdate((event: GestureEvent): void => this.updateHuePosition(event))
      .onActionEnd((event: GestureEvent): void => this.updateHuePosition(event)))
  }

  @Builder
  private alphaBar() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(12)
        .borderRadius(6)
        .backgroundColor('#f2f2f2')
      Column()
        .width('100%')
        .height(12)
        .borderRadius(6)
        .linearGradient({ angle: 90, colors: [['rgba(255, 255, 255, 0)', 0], ['rgba(255, 255, 255, 1)', 1]] })
      Column()
        .width(4)
        .height(16)
        .borderRadius(2)
        .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
        .border({ width: 1, color: '#cccccc' })
        .position({ x: this.alphaPosition - 2, y: -2 })
    }
    .width('100%')
    .height(12)
    .onAreaChange((_oldValue: Area, newValue: Area): void => this.captureAlpha(newValue))
    .gesture(PanGesture({ fingers: 1, direction: PanDirection.All, distance: 0 })
      .onActionStart((event: GestureEvent): void => this.updateAlphaPosition(event))
      .onActionUpdate((event: GestureEvent): void => this.updateAlphaPosition(event))
      .onActionEnd((event: GestureEvent): void => this.updateAlphaPosition(event)))
  }

  @Builder
  private stopPointer(index: number) {
    Column()
      .width(20)
      .height(20)
      .borderRadius(10)
      .backgroundColor(UPColor.parse(this.gradientStops[index].color, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')))
      .border({ width: 2, color: this.editingIndex === index ? '#333333' : '#ffffff' })
      .position({ x: this.gradientStops[index].percent * (this.trackWidth > 0 ? this.trackWidth : UP_COLOR_PICKER_TRACK_WIDTH) - 10, y: 6 })
      .gesture(PanGesture({ fingers: 1, direction: PanDirection.All, distance: 0 })
        .onActionStart((): void => this.startStopDrag(index))
        .onActionUpdate((event: GestureEvent): void => this.updateStopDrag(event))
        .onActionEnd((): void => this.endStopDrag())
        .onActionCancel((): void => this.endStopDrag()))
  }

  @Builder
  private gradientTrack() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(32)
        .borderRadius(4)
        .linearGradient({ angle: upColorPickerArkAngle(this.directionValue), colors: this.trackColors() })
      ForEach(this.stopIndexes(), (index: number) => {
        this.stopPointer(index)
      }, (index: number): string => `${index}:${this.gradientStops[index].color}:${this.gradientStops[index].percent}`)
    }
    .width('100%')
    .height(32)
    .onAreaChange((_oldValue: Area, newValue: Area): void => this.captureTrack(newValue))
  }

  @Builder
  private directionWheel() {
    Row({ space: 10 }) {
      Text('方向:').fontSize(14).fontColor('#333333')
      Stack({ alignContent: Alignment.TopStart }) {
        Column()
          .width('100%')
          .height('100%')
          .borderRadius(20)
          .sweepGradient({ center: [20, 20], start: 0, end: 360, colors: this.spectrumColors() })
        Column()
          .width(6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
          .border({ width: 2, color: '#333333' })
          .position({ x: this.directionPointerX - 3, y: this.directionPointerY - 3 })
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .border({ width: 2, color: '#eeeeee' })
      .onAreaChange((_oldValue: Area, newValue: Area): void => this.captureWheel(newValue))
      .gesture(PanGesture({ fingers: 1, direction: PanDirection.All, distance: 0 })
        .onActionStart((event: GestureEvent): void => this.updateDirection(event))
        .onActionUpdate((event: GestureEvent): void => this.updateDirection(event))
        .onActionEnd((event: GestureEvent): void => this.updateDirection(event)))
      Text(this.directionLabel).fontSize(13).fontColor('#666666')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private gradientSection() {
    Column({ space: 15 }) {
      this.gradientTrack()
      Row() {
        UPButton({ props: new UPButtonProps({
          type: 'primary',
          size: 'mini',
          plain: true,
          text: '添加颜色',
          disabled: this.gradientStops.length >= UP_COLOR_PICKER_GRADIENT_MAX,
          customStyle: 'width: 96px',
          onClick: (): void => this.addStop()
        }) })
      }.width('100%')
      this.directionWheel()
    }
    .width('100%')
    .margin({ top: 8 })
  }

  @Builder
  private commonColorItem(color: string) {
    Column()
      .width(24)
      .height(24)
      .borderRadius(12)
      .margin({ right: 10, bottom: 10 })
      .border({ width: 1, color: '#eeeeee' })
      .backgroundColor(UPColor.parse(color, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')))
      .onClick((): void => this.selectCommonColor(color))
  }

  @Builder
  private commonSection() {
    Column() {
      Text('常用颜色').fontSize(14).fontColor('#666666').width('100%').margin({ bottom: 10 })
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
        ForEach(this.commonColorList(), (color: string) => {
          this.commonColorItem(color)
        }, (color: string, index: number): string => `${index}:${color}`)
      }.width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private previewBlock() {
    if (this.previewIsGradient()) {
      Column()
        .width(40)
        .height(40)
        .borderRadius(4)
        .border({ width: 1, color: '#eeeeee' })
        .linearGradient({ angle: upColorPickerArkAngle(this.directionValue), colors: this.trackColors() })
    } else {
      Column()
        .width(40)
        .height(40)
        .borderRadius(4)
        .border({ width: 1, color: '#eeeeee' })
        .backgroundColor(UPColor.parse(this.displayColor(), UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')))
    }
  }

  @Builder
  private footer() {
    Column({ space: 15 }) {
      Row({ space: 10 }) {
        this.previewBlock()
        Text(this.displayColor())
          .fontSize(14)
          .fontColor('#333333')
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Row({ space: 10 }) {
        UPButton({ props: new UPButtonProps({
          type: 'primary',
          size: 'small',
          text: '确定',
          customStyle: 'width: 88px',
          onClick: (): void => this.confirm()
        }) })
        UPButton({ props: new UPButtonProps({
          type: 'info',
          size: 'small',
          text: '取消',
          customStyle: 'width: 88px',
          onClick: (): void => this.close()
        }) })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .margin({ top: 8 })
  }

  @Builder
  private panel() {
    Column({ space: 15 }) {
      Text('选择颜色')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Center)
      UPSubsection({ props: new UPSubsectionProps({
        list: this.typeList(),
        current: this.colorTypeIndex,
        fontSize: 14,
        onChange: (index: number): void => this.changeColorType(index)
      }) })
      if (this.colorTypeIndex === 1) {
        this.gradientSection()
      }
      this.saturationPanel()
      this.hueBar()
      if (this.colorTypeIndex === 0) {
        this.alphaBar()
      }
      if (this.commonColorList().length > 0) {
        this.commonSection()
      }
      this.footer()
    }
    .width('100%')
    .padding(20)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
    .borderRadius({ topLeft: 10, topRight: 10 })
  }

  @Builder
  private content() {
    if (!upBoolean(this.props.show, false)) {
      this.slotRegion()
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.5)
          .onClick((): void => this.close())
        this.panel()
      }
      .width('100%')
      .height('100%')
      .zIndex(1002)
    }
  }

  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  build() {
    this.content()
  }
}
