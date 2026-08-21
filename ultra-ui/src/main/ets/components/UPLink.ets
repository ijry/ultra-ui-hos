import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPLinkClickEvent {
  href: UPRawValue;
  text: string;
}

export interface UPLinkOptions {
  color?: UPRawValue;
  fontSize?: UPRawValue;
  underLine?: UPRawValue;
  href?: UPRawValue;
  mpTips?: UPRawValue;
  lineColor?: UPRawValue;
  text?: UPRawValue;
  customClass?: UPRawValue;
  customStyle?: UPStyleInput;
  onTap?: (event: UPLinkClickEvent) => void;
  onClick?: (event: UPLinkClickEvent) => void;
}

export class UPLinkProps {
  color: UPRawValue = 'primary';
  fontSize: UPRawValue = 15;
  underLine: UPRawValue = true;
  href: UPRawValue = '';
  mpTips: UPRawValue = '';
  lineColor: UPRawValue = '';
  text: UPRawValue = '';
  customClass: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  onTap?: (event: UPLinkClickEvent) => void;
  onClick?: (event: UPLinkClickEvent) => void;

  constructor(options?: UPLinkOptions) {
    if (options === undefined) {
      return;
    }
    this.color = options.color ?? this.color;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.underLine = options.underLine ?? this.underLine;
    this.href = options.href ?? this.href;
    this.mpTips = options.mpTips ?? this.mpTips;
    this.lineColor = options.lineColor ?? this.lineColor;
    this.text = options.text ?? this.text;
    this.customClass = options.customClass ?? this.customClass;
    this.customStyle = options.customStyle;
    this.onTap = options.onTap;
    this.onClick = options.onClick;
  }
}

@Component
export struct UPLink {
  @Prop props: UPLinkProps = new UPLinkProps();

  private label(): string {
    if (this.props.text === null || this.props.text === undefined) {
      return '';
    }
    return String(this.props.text);
  }

  private textColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, UP_DEFAULT_THEME.primary);
  }

  private fontSizeValue(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.fontSize ?? UPUnit.parse(this.props.fontSize, 375, 15);
  }

  private click(): void {
    const event: UPLinkClickEvent = { href: this.props.href, text: this.label() };
    this.props.onTap?.(event);
    this.props.onClick?.(event);
  }

  build() {
    Column({ space: 2 }) {
      Text(this.label())
        .fontSize(this.fontSizeValue())
        .fontColor(this.textColor())
      if (upBoolean(this.props.underLine, true)) {
        Column()
          .height(1)
          .width('100%')
          .backgroundColor(UPColor.parse(this.props.lineColor, UP_DEFAULT_THEME, this.textColor()))
      }
    }
    .alignItems(HorizontalAlign.Start)
    .onClick(() => this.click())
  }
}
