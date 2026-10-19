import { UPRawValue, UPStyleInput, upBoolean, upNumber } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';

export interface UPCountToFinishEvent { value: number; }
export interface UPCountToOptions {
  startValue?: UPRawValue; endValue?: UPRawValue; duration?: UPRawValue; decimals?: UPRawValue;
  separator?: string; fontSize?: UPRawValue; color?: string; autoplay?: UPRawValue; customStyle?: UPStyleInput;
  onFinish?: (event: UPCountToFinishEvent) => void;
  onEnd?: (event: UPCountToFinishEvent) => void;
}
export class UPCountToProps {
  startValue: UPRawValue = 0; endValue: UPRawValue = 0; duration: UPRawValue = 2000; decimals: UPRawValue = 0;
  separator: string = ','; fontSize: UPRawValue = 22; color: string = '#303133'; autoplay: UPRawValue = true;
  customStyle: UPStyleInput = undefined; onFinish?: (event: UPCountToFinishEvent) => void;
  onEnd?: (event: UPCountToFinishEvent) => void;
  constructor(options?: UPCountToOptions) {
    if (options === undefined) return;
    this.startValue = options.startValue ?? this.startValue; this.endValue = options.endValue ?? this.endValue;
    this.duration = options.duration ?? this.duration; this.decimals = options.decimals ?? this.decimals;
    this.separator = options.separator ?? this.separator; this.fontSize = options.fontSize ?? this.fontSize;
    this.color = options.color ?? this.color; this.autoplay = options.autoplay ?? this.autoplay;
    this.customStyle = options.customStyle; this.onFinish = options.onFinish; this.onEnd = options.onEnd;
  }
}

@Component
export struct UPCountTo {
  @Prop props: UPCountToProps = new UPCountToProps();
  @State private display: number = 0;
  private timer: number = -1;
  private elapsed: number = 0;

  aboutToAppear(): void {
    this.display = upNumber(this.props.startValue, 0);
    if (upBoolean(this.props.autoplay, true)) this.start();
  }
  aboutToDisappear(): void { this.stop(); }
  stop(): void {
    if (this.timer >= 0) clearInterval(this.timer);
    this.timer = -1;
  }
  start(): void {
    this.stop();
    const from: number = upNumber(this.props.startValue, 0);
    const to: number = upNumber(this.props.endValue, 0);
    const duration: number = Math.max(100, upNumber(this.props.duration, 2000));
    const stepTime: number = 30;
    this.elapsed = 0;
    this.display = from;
    this.timer = setInterval((): void => {
      this.elapsed = Math.min(duration, this.elapsed + stepTime);
      const progress: number = Math.min(1, Math.max(0, this.elapsed / duration));
      this.display = from + (to - from) * progress;
      if (this.elapsed >= duration) {
        this.stop();
        this.display = to;
        /** 上游只有 `end`；`onFinish` 是本端别名。/ Upstream emits `end`; onFinish is the local alias. */
        this.props.onFinish?.({ value: to });
        this.props.onEnd?.({ value: to });
      }
    }, stepTime);
  }
  restart(): void { this.start(); }
  private text(): string {
    const decimals: number = Math.max(0, Math.min(6, Math.floor(upNumber(this.props.decimals, 0))));
    return this.display.toFixed(decimals);
  }
  build() {
    Text(this.text()).fontSize(Math.max(10, upNumber(this.props.fontSize, 22))).fontColor(this.props.color)
      .fontWeight(FontWeight.Bold).width(UPStyle.parse(this.props.customStyle).width ?? undefined)
  }
}
