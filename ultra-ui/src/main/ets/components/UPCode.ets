import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPI18n } from '../core/UPI18n';

export interface UPCodeStorage {
  get(key: string): number | undefined;
  set(key: string, timestamp: number): void;
  remove(key: string): void;
}

export interface UPCodeChangeEvent {
  text: string;
  seconds: number;
}

export interface UPCodeEndEvent {
  text: string;
}

export interface UPCodeOptions {
  seconds?: UPRawValue;
  startText?: UPRawValue;
  changeText?: UPRawValue;
  endText?: UPRawValue;
  keepRunning?: UPRawValue;
  uniqueKey?: UPRawValue;
  storage?: UPCodeStorage;
  customStyle?: UPStyleInput;
  onStart?: () => void;
  onChange?: (event: UPCodeChangeEvent) => void;
  onEnd?: (event: UPCodeEndEvent) => void;
  contentBuilder?: UPBuilder;
}

export class UPCodeProps {
  seconds: UPRawValue = 60;
  startText: UPRawValue = UPI18n.t('up.code.send');
  changeText: UPRawValue = UPI18n.t('up.code.resendAfter');
  endText: UPRawValue = UPI18n.t('up.code.resend');
  keepRunning: UPRawValue = false;
  uniqueKey: UPRawValue = '';
  storage?: UPCodeStorage;
  customStyle: UPStyleInput = undefined;
  onStart?: () => void;
  onChange?: (event: UPCodeChangeEvent) => void;
  onEnd?: (event: UPCodeEndEvent) => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPCodeOptions) {
    if (options === undefined) return;
    this.seconds = options.seconds ?? this.seconds;
    this.startText = options.startText ?? this.startText;
    this.changeText = options.changeText ?? this.changeText;
    this.endText = options.endText ?? this.endText;
    this.keepRunning = options.keepRunning ?? this.keepRunning;
    this.uniqueKey = options.uniqueKey ?? this.uniqueKey;
    this.storage = options.storage;
    this.customStyle = options.customStyle;
    this.onStart = options.onStart;
    this.onChange = options.onChange;
    this.onEnd = options.onEnd;
    this.contentBuilder = options.contentBuilder;
  }
}

function codeText(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

@Component
export struct UPCode {
  @Prop props: UPCodeProps = new UPCodeProps();
  @State private remaining: number = 0;
  @State private renderedText: string = '';
  @State private canReceive: boolean = true;
  private timer: number = -1;
  private active: boolean = true;

  @Builder
  private defaultContent() {
    Text(this.displayText())
      .fontSize(UPStyle.parse(this.props.customStyle).fontSize ?? 14)
      .fontColor(UPStyle.parse(this.props.customStyle).color ?? UP_DEFAULT_THEME.primary)
  }

  @BuilderParam contentBuilder: () => void = this.defaultContent;

  aboutToAppear(): void {
    this.active = true;
    this.remaining = this.secondsValue();
    this.renderedText = codeText(this.props.startText);
    this.canReceive = true;
    this.restoreIfNeeded();
  }

  aboutToDisappear(): void {
    this.persistIfNeeded();
    this.clearTimer();
    this.active = false;
  }

  private secondsValue(): number {
    return Math.max(0, Math.floor(upNumber(this.props.seconds, 60)));
  }

  private storageKey(): string {
    return codeText(this.props.uniqueKey) + '_$uCountDownTimestamp';
  }

  private clearTimer(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
    }
    this.timer = -1;
  }

  private emitChange(text: string): void {
    this.renderedText = text;
    this.props.onChange?.({ text, seconds: this.remaining });
  }

  private changeText(): string {
    return codeText(this.props.changeText);
  }

  private replacedChangeText(): string {
    return this.changeText().replace(/x|X/, String(this.remaining));
  }

  private persistIfNeeded(): void {
    if (!upBoolean(this.props.keepRunning, false) || this.props.storage === undefined || this.timer < 0) {
      return;
    }
    if (this.remaining > 0 && this.remaining <= this.secondsValue()) {
      const timestamp: number = Math.floor(Date.now() / 1000) + this.remaining;
      this.props.storage.set(this.storageKey(), timestamp);
    }
  }

  private restoreIfNeeded(): void {
    if (!upBoolean(this.props.keepRunning, false) || this.props.storage === undefined) {
      this.emitChange(codeText(this.props.startText));
      return;
    }
    const timestamp: number | undefined = this.props.storage.get(this.storageKey());
    const now: number = Math.floor(Date.now() / 1000);
    if (timestamp !== undefined && timestamp > now) {
      this.remaining = timestamp - now;
      this.beginTimer(true);
      return;
    }
    this.props.storage.remove(this.storageKey());
    this.emitChange(codeText(this.props.startText));
  }

  private finish(): void {
    this.clearTimer();
    this.canReceive = true;
    this.remaining = this.secondsValue();
    if (this.props.storage !== undefined) {
      this.props.storage.remove(this.storageKey());
    }
    const text: string = codeText(this.props.endText);
    this.emitChange(text);
    this.props.onEnd?.({ text });
  }

  private beginTimer(restored: boolean): void {
    this.clearTimer();
    this.canReceive = false;
    if (!restored) {
      this.props.onStart?.();
    } else {
      this.props.onStart?.();
    }
    this.emitChange(this.replacedChangeText());
    if (this.remaining <= 0) {
      this.finish();
      return;
    }
    this.timer = setInterval((): void => {
      if (!this.active) {
        return;
      }
      this.remaining = Math.max(0, this.remaining - 1);
      if (this.remaining <= 0) {
        this.finish();
        return;
      }
      this.emitChange(this.replacedChangeText());
    }, 1000);
    this.persistIfNeeded();
  }

  canGetCode(): boolean {
    return this.canReceive && this.timer < 0;
  }

  start(): void {
    if (!this.canGetCode()) {
      return;
    }
    this.remaining = this.secondsValue();
    this.beginTimer(false);
  }

  reset(): void {
    this.clearTimer();
    this.canReceive = true;
    this.remaining = this.secondsValue();
    if (this.props.storage !== undefined) {
      this.props.storage.remove(this.storageKey());
    }
    this.emitChange(codeText(this.props.endText));
  }

  displayText(): string {
    return this.renderedText.length > 0 ? this.renderedText : codeText(this.props.startText);
  }

  private customWidth(): number | string {
    return UPStyle.parse(this.props.customStyle).width ?? 'auto';
  }

  private customHeight(): number | string {
    return UPStyle.parse(this.props.customStyle).height ?? 'auto';
  }

  build() {
    Row() {
      this.contentBuilder()
    }
    .width(this.customWidth())
    .height(this.customHeight())
    .padding({ left: UPUnit.parse(8, 375, 8), right: UPUnit.parse(8, 375, 8) })
    .onClick(() => {
      this.start();
    })
  }
}
