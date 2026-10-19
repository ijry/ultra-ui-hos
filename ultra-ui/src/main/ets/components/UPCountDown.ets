import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPCountDownFinishEvent { remainTime: number; }
/** 上游 change 事件：逐秒回传拆分后的时间。/ Upstream change payload with the split time parts. */
export interface UPCountDownChangeEvent {
  remainTime: number; days: number; hours: number; minutes: number; seconds: number;
}
export interface UPCountDownOptions {
  remainTime?: UPRawValue; autoStart?: UPRawValue; showDays?: UPRawValue; separator?: string;
  fontSize?: UPRawValue; color?: string; customStyle?: UPStyleInput;
  onFinish?: (event: UPCountDownFinishEvent) => void;
  onChange?: (event: UPCountDownChangeEvent) => void;
  contentBuilder?: UPBuilder;
}
export class UPCountDownProps {
  remainTime: UPRawValue = 0; autoStart: UPRawValue = true; showDays: UPRawValue = false; separator: string = ':';
  fontSize: UPRawValue = 16; color: string = '#303133'; customStyle: UPStyleInput = undefined;
  onFinish?: (event: UPCountDownFinishEvent) => void;
  onChange?: (event: UPCountDownChangeEvent) => void;
  contentBuilder?: UPBuilder;
  constructor(options?: UPCountDownOptions) {
    if (options === undefined) return;
    this.remainTime = options.remainTime ?? this.remainTime; this.autoStart = options.autoStart ?? this.autoStart;
    this.showDays = options.showDays ?? this.showDays; this.separator = options.separator ?? this.separator;
    this.fontSize = options.fontSize ?? this.fontSize; this.color = options.color ?? this.color;
    this.customStyle = options.customStyle; this.onFinish = options.onFinish; this.onChange = options.onChange;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPCountDown {
  @Prop props: UPCountDownProps = new UPCountDownProps();
  @State private remaining: number = 0;
  private timer: number = -1;

  aboutToAppear(): void {
    this.remaining = Math.max(0, Math.floor(upNumber(this.props.remainTime, 0)));
    if (upBoolean(this.props.autoStart, true)) this.start();
  }

  aboutToDisappear(): void {
    if (this.timer >= 0) clearInterval(this.timer);
    this.timer = -1;
  }

  start(): void {
    this.aboutToDisappear();
    if (this.remaining <= 0) return;
    this.timer = setInterval((): void => {
      this.remaining = Math.max(0, this.remaining - 1);
      this.emitChange();
      if (this.remaining === 0) {
        this.aboutToDisappear();
        this.props.onFinish?.({ remainTime: 0 });
      }
    }, 1000);
  }

  pause(): void { this.aboutToDisappear(); }
  reset(seconds?: UPRawValue): void {
    this.aboutToDisappear();
    const source: UPRawValue = seconds !== undefined ? seconds : this.props.remainTime;
    this.remaining = Math.max(0, Math.floor(upNumber(source, 0)));
  }

  /** 上游 change：逐秒回传拆分后的时间。/ Upstream change with the split time parts. */
  private emitChange(): void {
    const total: number = Math.max(0, this.remaining);
    this.props.onChange?.({
      remainTime: total, days: Math.floor(total / 86400), hours: Math.floor(total / 3600) % 24,
      minutes: Math.floor(total / 60) % 60, seconds: total % 60
    });
  }
  private part(value: number): string { return String(value).padStart(2, '0'); }
  private text(): string {
    const separator: string = this.props.separator.length > 0 ? this.props.separator : ':';
    const total: number = Math.max(0, this.remaining);
    const seconds: number = total % 60; const minutes: number = Math.floor(total / 60) % 60;
    const hours: number = Math.floor(total / 3600) % 24; const days: number = Math.floor(total / 86400);
    if (upBoolean(this.props.showDays, false)) return `${days}天 ${this.part(hours)}${separator}${this.part(minutes)}${separator}${this.part(seconds)}`;
    const allHours: number = Math.floor(total / 3600);
    return `${this.part(allHours)}${separator}${this.part(minutes)}${separator}${this.part(seconds)}`;
  }

  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  build() {
    Column() {
      if (this.props.contentBuilder === undefined) {
        Text(this.text()).fontSize(Math.max(10, upNumber(this.props.fontSize, 16))).fontColor(this.props.color)
          .fontWeight(FontWeight.Medium)
      } else {
        this.slotRegion()
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? undefined)
  }
}
