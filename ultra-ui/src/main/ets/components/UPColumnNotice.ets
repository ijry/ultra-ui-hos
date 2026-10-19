import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle, UPStyleResult } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPSlotRegion } from '../internal/UPSlotRegion';

/** 上游 `.u-notice__swiper` 的固定高度。/ Upstream swiper height. */
export const UP_COLUMN_NOTICE_SWIPER_HEIGHT: number = 16;

/**
 * 上游 text 为数组时逐项转字符串；传入字符串时按单条兜底。
 * Normalizes the upstream text prop, whose declared type is Array but whose default is an empty string.
 */
export function upColumnNoticeItems(text: UPRawValue | Array<UPRawValue>): Array<string> {
  if (Array.isArray(text)) {
    const result: Array<string> = [];
    for (let index: number = 0; index < text.length; index += 1) {
      const item: UPRawValue = text[index];
      result.push(item === null || item === undefined ? '' : String(item));
    }
    return result;
  }
  if (text === null || text === undefined) {
    return [];
  }
  const single: string = String(text);
  return single.length === 0 ? [] : [single];
}

export interface UPColumnNoticeOptions {
  text?: UPRawValue | Array<UPRawValue>;
  icon?: UPRawValue;
  mode?: UPRawValue;
  color?: UPRawValue;
  bgColor?: UPRawValue;
  fontSize?: UPRawValue;
  speed?: UPRawValue;
  step?: UPRawValue;
  duration?: UPRawValue;
  disableTouch?: UPRawValue;
  justifyContent?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (index: number) => void;
  onClose?: () => void;
  iconBuilder?: UPBuilder;
}

export class UPColumnNoticeProps {
  text: UPRawValue | Array<UPRawValue> = '';
  icon: UPRawValue = 'volume';
  mode: UPRawValue = '';
  color: UPRawValue = '#f9ae3d';
  bgColor: UPRawValue = '#fdf6ec';
  fontSize: UPRawValue = 14;
  speed: UPRawValue = 80;
  step: UPRawValue = false;
  duration: UPRawValue = 1500;
  disableTouch: UPRawValue = true;
  justifyContent: UPRawValue = 'flex-start';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onClick?: (index: number) => void;
  onClose?: () => void;
  iconBuilder?: UPBuilder;

  constructor(options?: UPColumnNoticeOptions) {
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
    this.step = options.step ?? this.step;
    this.duration = options.duration ?? this.duration;
    this.disableTouch = options.disableTouch ?? this.disableTouch;
    this.justifyContent = options.justifyContent ?? this.justifyContent;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
    this.onClose = options.onClose;
    this.iconBuilder = options.iconBuilder;
  }
}

@Component
export struct UPColumnNotice {
  @Prop @Watch('applyProps') props: UPColumnNoticeProps = new UPColumnNoticeProps();
  /** 上游 data.index：swiper change 后回传给 click 事件。/ Upstream data.index. */
  @State private current: number = 0;
  private applied: string = '';

  aboutToAppear(): void {
    this.applied = this.signature();
    this.report();
  }

  /** 上游 text 的 immediate watch。/ Upstream immediate text watcher. */
  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    const items: Array<string> = this.items();
    if (this.current >= items.length) {
      this.current = 0;
    }
    this.report();
  }

  private signature(): string {
    return this.items().join('\u0001');
  }

  private report(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (!Array.isArray(this.props.text)) {
      diagnostics.report('UPColumnNotice', 'text', this.props.text as UPRawValue,
        'noticebar 组件 direction 为 column 时要求 text 为数组，非数组入参按单条兜底');
    }
    if (upString(this.props.mode, '').length > 0 && this.modeName() !== 'link' && this.modeName() !== 'closable') {
      diagnostics.report('UPColumnNotice', 'mode', this.props.mode, 'only link and closable render a right-hand icon upstream');
    }
    diagnostics.report('UPColumnNotice', 'speed', this.props.speed,
      'upstream declares speed for the column mode but never reads it, so it stays a no-op here as well');
    diagnostics.report('UPColumnNotice', 'bgColor', this.props.bgColor,
      'upstream declares bgColor but never paints it inside u-column-notice, so it stays a no-op unless customStyle sets a background');
  }

  private items(): Array<string> {
    return upColumnNoticeItems(this.props.text);
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

  /** 上游 `:interval="duration"`。/ Upstream interval. */
  private interval(): number {
    const value: number = upNumber(this.props.duration, Number.NaN);
    const parsed: number = Number.isFinite(value) ? value : UPUnit.parse(this.props.duration, 375, 1500);
    return Math.max(100, Math.floor(parsed > 0 ? parsed : 1500));
  }

  /** 上游 `:vertical="step ? false : true"`：step 为真时改成横向步进。/ Upstream vertical flag. */
  private verticalScroll(): boolean {
    return !upBoolean(this.props.step, false);
  }

  private itemAlign(): FlexAlign {
    switch (upString(this.props.justifyContent, 'flex-start').trim().toLowerCase()) {
      case 'center': return FlexAlign.Center;
      case 'flex-end':
      case 'end': return FlexAlign.End;
      case 'space-between': return FlexAlign.SpaceBetween;
      case 'space-around': return FlexAlign.SpaceAround;
      case 'space-evenly': return FlexAlign.SpaceEvenly;
      default: return FlexAlign.Start;
    }
  }

  /** 上游 noticeChange()。/ Upstream noticeChange(). */
  private noticeChange(index: number): void {
    this.current = index;
  }

  /** 上游 clickHandler()：回传当前索引。/ Upstream clickHandler(). */
  private click(): void {
    this.props.onClick?.(this.current);
  }

  /** 上游 close()。/ Upstream close(). */
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
  private notice(item: string) {
    Row() {
      Text(item)
        .fontSize(this.textSize())
        .fontColor(this.textColor())
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(UP_COLUMN_NOTICE_SWIPER_HEIGHT)
    .alignItems(VerticalAlign.Center)
    .justifyContent(this.itemAlign())
    .clip(true)
  }

  @Builder
  private carousel() {
    if (this.items().length === 0) {
      Row()
        .layoutWeight(1)
        .height(UP_COLUMN_NOTICE_SWIPER_HEIGHT)
    } else {
      Swiper() {
        ForEach(this.items(), (item: string, index: number) => {
          this.notice(item)
        }, (item: string, index: number): string => `${String(index)}-${item}`)
      }
      .index(this.current)
      .autoPlay(true)
      .interval(this.interval())
      .indicator(false)
      .loop(true)
      .vertical(this.verticalScroll())
      .disableSwipe(upBoolean(this.props.disableTouch, true))
      .layoutWeight(1)
      .height(UP_COLUMN_NOTICE_SWIPER_HEIGHT)
      .onChange((index: number): void => this.noticeChange(index))
    }
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
      this.carousel()
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
