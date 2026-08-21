import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPLoadingIcon, UPLoadingIconProps } from './UPLoadingIcon';
import { UPIcon, UPIconProps } from './UPIcon';

export interface UPButtonOptions {
  hairline?: UPRawValue;
  type?: UPRawValue;
  size?: UPRawValue;
  shape?: UPRawValue;
  plain?: UPRawValue;
  disabled?: UPRawValue;
  loading?: UPRawValue;
  loadingText?: UPRawValue;
  loadingMode?: UPRawValue;
  loadingSize?: UPRawValue;
  openType?: UPRawValue;
  formType?: UPRawValue;
  appParameter?: UPRawValue;
  hoverStopPropagation?: UPRawValue;
  lang?: UPRawValue;
  sessionFrom?: UPRawValue;
  sendMessageTitle?: UPRawValue;
  sendMessagePath?: UPRawValue;
  sendMessageImg?: UPRawValue;
  showMessageCard?: UPRawValue;
  dataName?: UPRawValue;
  throttleTime?: UPRawValue;
  hoverStartTime?: UPRawValue;
  hoverStayTime?: UPRawValue;
  text?: UPRawValue;
  icon?: UPRawValue;
  iconColor?: UPRawValue;
  color?: UPRawValue;
  stop?: UPRawValue;
  customStyle?: UPStyleInput;
  onClick?: () => void;
}

export class UPButtonProps {
  hairline: UPRawValue = false;
  type: UPRawValue = 'info';
  size: UPRawValue = 'normal';
  shape: UPRawValue = 'square';
  plain: UPRawValue = false;
  disabled: UPRawValue = false;
  loading: UPRawValue = false;
  loadingText: UPRawValue = '';
  loadingMode: UPRawValue = 'spinner';
  loadingSize: UPRawValue = 15;
  openType: UPRawValue = '';
  formType: UPRawValue = '';
  appParameter: UPRawValue = '';
  hoverStopPropagation: UPRawValue = true;
  lang: UPRawValue = 'en';
  sessionFrom: UPRawValue = '';
  sendMessageTitle: UPRawValue = '';
  sendMessagePath: UPRawValue = '';
  sendMessageImg: UPRawValue = '';
  showMessageCard: UPRawValue = false;
  dataName: UPRawValue = '';
  throttleTime: UPRawValue = 0;
  hoverStartTime: UPRawValue = 0;
  hoverStayTime: UPRawValue = 200;
  text: UPRawValue = '';
  icon: UPRawValue = '';
  iconColor: UPRawValue = '';
  color: UPRawValue = '';
  stop: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  onClick?: () => void;

  constructor(options?: UPButtonOptions) {
    if (options === undefined) {
      return;
    }
    this.hairline = options.hairline ?? this.hairline;
    this.type = options.type ?? this.type;
    this.size = options.size ?? this.size;
    this.shape = options.shape ?? this.shape;
    this.plain = options.plain ?? this.plain;
    this.disabled = options.disabled ?? this.disabled;
    this.loading = options.loading ?? this.loading;
    this.loadingText = options.loadingText ?? this.loadingText;
    this.loadingMode = options.loadingMode ?? this.loadingMode;
    this.loadingSize = options.loadingSize ?? this.loadingSize;
    this.openType = options.openType ?? this.openType;
    this.formType = options.formType ?? this.formType;
    this.appParameter = options.appParameter ?? this.appParameter;
    this.hoverStopPropagation = options.hoverStopPropagation ?? this.hoverStopPropagation;
    this.lang = options.lang ?? this.lang;
    this.sessionFrom = options.sessionFrom ?? this.sessionFrom;
    this.sendMessageTitle = options.sendMessageTitle ?? this.sendMessageTitle;
    this.sendMessagePath = options.sendMessagePath ?? this.sendMessagePath;
    this.sendMessageImg = options.sendMessageImg ?? this.sendMessageImg;
    this.showMessageCard = options.showMessageCard ?? this.showMessageCard;
    this.dataName = options.dataName ?? this.dataName;
    this.throttleTime = options.throttleTime ?? this.throttleTime;
    this.hoverStartTime = options.hoverStartTime ?? this.hoverStartTime;
    this.hoverStayTime = options.hoverStayTime ?? this.hoverStayTime;
    this.text = options.text ?? this.text;
    this.icon = options.icon ?? this.icon;
    this.iconColor = options.iconColor ?? this.iconColor;
    this.color = options.color ?? this.color;
    this.stop = options.stop ?? this.stop;
    this.customStyle = options.customStyle;
    this.onClick = options.onClick;
  }
}

function typeColor(type: string): string {
  switch (type) {
    case 'primary': return UP_DEFAULT_THEME.primary;
    case 'success': return UP_DEFAULT_THEME.success;
    case 'warning': return UP_DEFAULT_THEME.warning;
    case 'error': return UP_DEFAULT_THEME.error;
    case 'info': return UP_DEFAULT_THEME.info;
    default: return UP_DEFAULT_THEME.info;
  }
}

@Component
export struct UPButton {
  @Prop props: UPButtonProps = new UPButtonProps();
  @State private lastClickAt: number = 0;

  private click(): void {
    if (upBoolean(this.props.disabled, false) || upBoolean(this.props.loading, false)) {
      return;
    }
    const now: number = Date.now();
    const throttle: number = UPUnit.parse(this.props.throttleTime, 375, 0);
    if (throttle > 0 && now - this.lastClickAt < throttle) {
      return;
    }
    this.lastClickAt = now;
    this.props.onClick?.();
  }

  private buttonHeight(): number {
    switch (upString(this.props.size, 'normal').toLowerCase()) {
      case 'large': return 44;
      case 'small': return 32;
      case 'mini': return 28;
      default: return 40;
    }
  }

  private buttonRadius(): number {
    if (upString(this.props.shape, 'square').toLowerCase() === 'circle') {
      return this.buttonHeight() / 2;
    }
    return 4;
  }

  private loadingText(): string {
    return this.props.loadingText === null || this.props.loadingText === undefined ? '' : String(this.props.loadingText);
  }

  private buttonColor(): string {
    const explicit: string = upString(this.props.color, '');
    return explicit.length > 0 ? explicit : typeColor(upString(this.props.type, 'info').toLowerCase());
  }

  private customWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? '100%';
  }

  private customHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? this.buttonHeight();
  }

  private customRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderRadius ?? this.buttonRadius();
  }

  @Builder
  private content() {
    Button({ type: ButtonType.Normal, stateEffect: !upBoolean(this.props.disabled, false) }) {
      Row({ space: 6 }) {
        if (upBoolean(this.props.loading, false)) {
          UPLoadingIcon({ props: new UPLoadingIconProps({
            mode: this.props.loadingMode,
            size: this.props.loadingSize,
            text: ''
          }) })
        } else if (upString(this.props.icon, '').length > 0) {
          UPIcon({ props: new UPIconProps({ name: upString(this.props.icon, ''), color: this.props.iconColor }) })
        }
        Text(upBoolean(this.props.loading, false) ? this.loadingText() : String(this.props.text ?? ''))
          .fontSize(upString(this.props.size, 'normal').toLowerCase() === 'large' ? 16 : 14)
      }
    }
    .height(this.customHeight())
    .width(this.customWidth())
    .borderRadius(this.customRadius())
    .borderWidth(upBoolean(this.props.hairline, false) ? 0.5 : (upBoolean(this.props.plain, false) ? 1 : 0))
    .borderColor(this.buttonColor())
    .backgroundColor(upBoolean(this.props.plain, false) ? '#ffffff' : this.buttonColor())
    .fontColor(upBoolean(this.props.plain, false) ? this.buttonColor() : '#ffffff')
    .opacity(upBoolean(this.props.disabled, false) ? 0.5 : 1)
    .onClick(() => this.click())
  }

  build() {
    this.content()
  }
}
