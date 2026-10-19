import { UPBuilder, UPRawValue, UPStyleInput, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle, UPStyleResult } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPIcon, UPIconProps } from './UPIcon';
import { upCanvasEstimateTextWidth } from './UPCanvas';
import { UPSlotRegion } from '../internal/UPSlotRegion';

/** 上游 innerText 的分片长度，低端安卓抖动的规避手段。/ Upstream innerText slice length. */
export const UP_ROW_NOTICE_SLICE_LENGTH: number = 20;

/** Marquee 的步进按 60fps 折算，用于把上游“每秒像素”映射为“每帧步长”。/ Frames per second used to map px/s to vp/frame. */
export const UP_ROW_NOTICE_FRAMES_PER_SECOND: number = 60;

/**
 * 上游 innerText：把长文本按 20 字符切片，避免单个文本节点滚动抖动。
 * Mirrors upstream innerText(), slicing long text into 20-character chunks.
 */
export function upRowNoticeSlices(text: string): Array<string> {
  const result: Array<string> = [];
  const characters: Array<string> = text.split('');
  for (let index: number = 0; index < characters.length; index += UP_ROW_NOTICE_SLICE_LENGTH) {
    result.push(characters.slice(index, index + UP_ROW_NOTICE_SLICE_LENGTH).join(''));
  }
  return result;
}

/** 上游 getPx(speed)：数字按 px，`rpx`/`upx` 折算成 px。/ Mirrors upstream getPx() for the speed prop. */
export function upRowNoticeSpeedPx(speed: UPRawValue, viewportWidth: number = 375): number {
  if (typeof speed === 'number') {
    return Number.isFinite(speed) && speed > 0 ? speed : 80;
  }
  const source: string = upString(speed, '').trim().toLowerCase();
  if (source.length === 0) {
    return 80;
  }
  const magnitude: number = parseFloat(source);
  if (!Number.isFinite(magnitude) || magnitude <= 0) {
    return 80;
  }
  if (source.endsWith('rpx') || source.endsWith('upx')) {
    return UPUnit.parse(`${magnitude}rpx`, viewportWidth, magnitude / 2);
  }
  return magnitude;
}

/**
 * 上游 `animationDuration = ${textWidth / getPx(speed)}s`：文本宽度由字号估算替代 DOM 测量。
 * Mirrors upstream animationDuration; the DOM measurement is replaced by a font-size estimate.
 */
export function upRowNoticeDuration(text: string, fontSize: number, speed: UPRawValue): string {
  const width: number = upCanvasEstimateTextWidth(text, fontSize);
  const velocity: number = upRowNoticeSpeedPx(speed);
  const seconds: number = velocity > 0 ? width / velocity : 0;
  return `${Number(seconds.toPrecision(4))}s`;
}

/** 把上游“每秒像素”换成 Marquee 的“每帧 vp”。/ Converts px/s into the native Marquee step. */
export function upRowNoticeStep(speed: UPRawValue): number {
  const velocity: number = upRowNoticeSpeedPx(speed);
  const step: number = velocity / UP_ROW_NOTICE_FRAMES_PER_SECOND;
  return step > 0 ? Number(step.toPrecision(4)) : 1;
}

export interface UPRowNoticeOptions {
  text?: UPRawValue;
  icon?: UPRawValue;
  mode?: UPRawValue;
  color?: UPRawValue;
  bgColor?: UPRawValue;
  fontSize?: UPRawValue;
  speed?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: () => void;
  onClose?: () => void;
  iconBuilder?: UPBuilder;
}

export class UPRowNoticeProps {
  text: UPRawValue = '';
  icon: UPRawValue = 'volume';
  mode: UPRawValue = '';
  color: UPRawValue = '#f9ae3d';
  bgColor: UPRawValue = '#fdf6ec';
  fontSize: UPRawValue = 14;
  speed: UPRawValue = 80;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onClick?: () => void;
  onClose?: () => void;
  iconBuilder?: UPBuilder;

  constructor(options?: UPRowNoticeOptions) {
    if (options === undefined) {
      return;
    }
    this.text = options.text ?? this.text;
    this.icon = options.icon ?? this.icon;
    this.mode = options.mode ?? this.mode;
    this.color = options.color ?? this.color;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.speed = options.speed ?? this.speed;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
    this.onClose = options.onClose;
    this.iconBuilder = options.iconBuilder;
  }
}

@Component
export struct UPRowNotice {
  @Prop @Watch('applyProps') props: UPRowNoticeProps = new UPRowNoticeProps();
  /** 上游 animationPlayState：先 paused，10ms 后 running。/ Upstream animationPlayState. */
  @State private playing: boolean = false;
  private applied: string = '';
  private startTimerId: number = -1;

  aboutToAppear(): void {
    this.applied = this.signature();
    this.report();
    this.restart();
  }

  /** 上游 beforeUnmount 的 stopAnimation。/ Upstream beforeUnmount stopAnimation flag. */
  aboutToDisappear(): void {
    this.clearStartTimer();
    this.playing = false;
  }

  /** 上游 text/fontSize/speed 三个 watch 的合并实现。/ Merges the three upstream watchers. */
  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.report();
    this.restart();
  }

  private signature(): string {
    return `${this.contentText()}|${String(this.textSize())}|${String(upRowNoticeStep(this.props.speed))}`;
  }

  private report(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (this.props.text !== null && this.props.text !== undefined && typeof this.props.text !== 'string') {
      diagnostics.report('UPRowNotice', 'text', this.props.text,
        'noticebar 组件 direction 为 row 时要求 text 为字符串，非字符串入参按 String() 兜底');
    }
    if (upString(this.props.mode, '').length > 0 && this.modeName() !== 'link' && this.modeName() !== 'closable') {
      diagnostics.report('UPRowNotice', 'mode', this.props.mode, 'only link and closable render a right-hand icon upstream');
    }
    diagnostics.report('UPRowNotice', 'bgColor', this.props.bgColor,
      'upstream declares bgColor but never paints it inside u-row-notice, so it stays a no-op unless customStyle sets a background');
    diagnostics.report('UPRowNotice', 'speed', this.props.speed,
      'the CSS keyframe duration is replaced by the native Marquee step, mapped through upRowNoticeStep()');
  }

  /** 重启滚动：先停后开，等价上游 paused → setTimeout(10) → running。/ Restarts the marquee like upstream. */
  private restart(): void {
    this.clearStartTimer();
    this.playing = false;
    this.startTimerId = setTimeout((): void => {
      this.startTimerId = -1;
      this.playing = true;
    }, 10);
  }

  private clearStartTimer(): void {
    if (this.startTimerId >= 0) {
      clearTimeout(this.startTimerId);
      this.startTimerId = -1;
    }
  }

  private contentText(): string {
    const source: UPRawValue = this.props.text;
    if (source === null || source === undefined) {
      return '';
    }
    return upRowNoticeSlices(typeof source === 'string' ? source : String(source)).join('');
  }

  private modeName(): string {
    return upString(this.props.mode, '').trim();
  }

  private iconName(): string {
    return upString(this.props.icon, '').trim();
  }

  private textColor(): string {
    return UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#f9ae3d');
  }

  private textSize(): number {
    return UPUnit.parse(this.props.fontSize, 375, 14);
  }

  /** 上游 click：只抛事件，跳转由 u-notice-bar 负责。/ Upstream click handler. */
  private click(): void {
    this.props.onClick?.();
  }

  /** 上游 close。/ Upstream close handler. */
  private close(): void {
    this.props.onClose?.();
  }

  @Builder
  private leftIcon() {
    Row() {
      if (this.props.iconBuilder !== undefined) {
        this.iconRegion()
      } else {
        UPIcon({ props: new UPIconProps({ name: this.iconName(), color: this.textColor(), size: 19 }) })
      }
    }
    .alignItems(VerticalAlign.Center)
    .margin({ right: 5 })
  }

  @Builder
  private rightIcon() {
    Row() {
      if (this.modeName() === 'link') {
        UPIcon({ props: new UPIconProps({ name: 'arrow-right', color: this.textColor(), size: 17 }) })
      } else {
        UPIcon({ props: new UPIconProps({ name: 'close', color: this.textColor(), size: 16, onClick: (): void => this.close() }) })
      }
    }
    .alignItems(VerticalAlign.Center)
    .margin({ left: 5 })
    .onClick((): void => {
      if (this.modeName() === 'closable') {
        this.close();
      }
    })
  }

  @Builder
  private iconRegion() {
    UPSlotRegion({ contentBuilder: this.props.iconBuilder })
  }

  build() {
    Row() {
      if (this.iconName().length > 0) {
        this.leftIcon()
      }
      Marquee({
        start: this.playing,
        step: upRowNoticeStep(this.props.speed),
        loop: -1,
        fromStart: true,
        src: this.contentText()
      })
        .fontColor(this.textColor())
        .fontSize(this.textSize())
        .allowScale(false)
        .marqueeUpdateStrategy(MarqueeUpdateStrategy.DEFAULT)
        .layoutWeight(1)
      if (this.modeName() === 'link' || this.modeName() === 'closable') {
        this.rightIcon()
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(this.rootBackground())
    .onClick((): void => this.click())
  }

  private rootBackground(): string {
    const style: UPStyleResult = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background
      ?? UPColor.adaptive('#00000000', 'warning-light');
  }
}
