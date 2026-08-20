import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPNotifyOptions {
  show?: UPRawValue; top?: UPRawValue; message?: UPRawValue; type?: UPRawValue; color?: UPRawValue;
  bgColor?: UPRawValue; duration?: UPRawValue; fontSize?: UPRawValue; safeAreaInsetTop?: UPRawValue;
  onShowChange?: (show: boolean) => void; onClick?: () => void; onClose?: () => void; customStyle?: UPStyleInput;
}
export class UPNotifyProps {
  show: UPRawValue = false; top: UPRawValue = 0; message: UPRawValue = ''; type: UPRawValue = 'primary';
  color: UPRawValue = ''; bgColor: UPRawValue = ''; duration: UPRawValue = 3000; fontSize: UPRawValue = 14;
  safeAreaInsetTop: UPRawValue = false; onShowChange?: (show: boolean) => void; onClick?: () => void;
  onClose?: () => void; customStyle: UPStyleInput = undefined;
  constructor(options?: UPNotifyOptions) {
    if (options === undefined) return;
    this.show = options.show ?? this.show; this.top = options.top ?? this.top; this.message = options.message ?? this.message;
    this.type = options.type ?? this.type; this.color = options.color ?? this.color; this.bgColor = options.bgColor ?? this.bgColor;
    this.duration = options.duration ?? this.duration; this.fontSize = options.fontSize ?? this.fontSize;
    this.safeAreaInsetTop = options.safeAreaInsetTop ?? this.safeAreaInsetTop; this.onShowChange = options.onShowChange;
    this.onClick = options.onClick; this.onClose = options.onClose; this.customStyle = options.customStyle;
  }
}
function notifyColor(value: UPRawValue): string {
  const type: string = upString(value, 'primary').toLowerCase();
  if (type === 'success') return UP_DEFAULT_THEME.success;
  if (type === 'warning') return UP_DEFAULT_THEME.warning;
  if (type === 'error') return UP_DEFAULT_THEME.error;
  if (type === 'info') return UP_DEFAULT_THEME.info;
  return UP_DEFAULT_THEME.primary;
}
@Component
export struct UPNotify {
  @Prop props: UPNotifyProps = new UPNotifyProps();
  private close(): void { this.props.onShowChange?.(false); this.props.onClose?.(); }
  private color(): string { return UPColor.parse(this.props.color, UP_DEFAULT_THEME, notifyColor(this.props.type)); }
  private message(): string { return this.props.message === null || this.props.message === undefined ? '' : String(this.props.message); }
  @Builder
  private content() {
    if (!upBoolean(this.props.show, false)) {
      Row().width(0).height(0)
    } else {
      Row() {
        Text(this.message()).fontSize(UPUnit.parse(this.props.fontSize, 375, 14)).fontColor(this.color()).maxLines(2).layoutWeight(1)
        Text('×').fontSize(18).fontColor(this.color()).onClick(() => this.close())
      }
      .width('100%').margin({ top: Math.max(0, upNumber(this.props.top, 0)) }).padding({ top: 10, right: 14, bottom: 10, left: 14 })
      .backgroundColor(UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, this.color() + '18')).borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 4).opacity(UPStyle.parse(this.props.customStyle).opacity ?? 1)
      .onClick(() => this.props.onClick?.())
    }
  }

  build() {
    this.content()
  }
}
