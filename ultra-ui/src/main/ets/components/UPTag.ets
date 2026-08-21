import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPTagCloseEvent {
  name: UPRawValue;
}

export interface UPTagOptions {
  type?: UPRawValue;
  disabled?: UPRawValue;
  size?: UPRawValue;
  shape?: UPRawValue;
  text?: UPRawValue;
  bgColor?: UPRawValue;
  color?: UPRawValue;
  borderColor?: UPRawValue;
  closeColor?: UPRawValue;
  name?: UPRawValue;
  plainFill?: UPRawValue;
  plain?: UPRawValue;
  closable?: UPRawValue;
  show?: UPRawValue;
  icon?: UPRawValue;
  iconColor?: UPRawValue;
  textSize?: UPRawValue;
  height?: UPRawValue;
  padding?: UPRawValue;
  borderRadius?: UPRawValue;
  autoBgColor?: UPRawValue;
  customStyle?: UPStyleInput;
  onClick?: (name: UPRawValue) => void;
  onClose?: (event: UPTagCloseEvent) => void;
}

export class UPTagProps {
  type: UPRawValue = 'primary';
  disabled: UPRawValue = false;
  size: UPRawValue = 'medium';
  shape: UPRawValue = 'square';
  text: UPRawValue = '';
  bgColor: UPRawValue = '';
  color: UPRawValue = '';
  borderColor: UPRawValue = '';
  closeColor: UPRawValue = '#C6C7CB';
  name: UPRawValue = '';
  plainFill: UPRawValue = false;
  plain: UPRawValue = false;
  closable: UPRawValue = false;
  show: UPRawValue = true;
  icon: UPRawValue = '';
  iconColor: UPRawValue = '';
  textSize: UPRawValue = '';
  height: UPRawValue = '';
  padding: UPRawValue = '';
  borderRadius: UPRawValue = '';
  autoBgColor: UPRawValue = 0;
  customStyle: UPStyleInput = undefined;
  onClick?: (name: UPRawValue) => void;
  onClose?: (event: UPTagCloseEvent) => void;

  constructor(options?: UPTagOptions) {
    if (options === undefined) {
      return;
    }
    this.type = options.type ?? this.type;
    this.disabled = options.disabled ?? this.disabled;
    this.size = options.size ?? this.size;
    this.shape = options.shape ?? this.shape;
    this.text = options.text ?? this.text;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.color = options.color ?? this.color;
    this.borderColor = options.borderColor ?? this.borderColor;
    this.closeColor = options.closeColor ?? this.closeColor;
    this.name = options.name ?? this.name;
    this.plainFill = options.plainFill ?? this.plainFill;
    this.plain = options.plain ?? this.plain;
    this.closable = options.closable ?? this.closable;
    this.show = options.show ?? this.show;
    this.icon = options.icon ?? this.icon;
    this.iconColor = options.iconColor ?? this.iconColor;
    this.textSize = options.textSize ?? this.textSize;
    this.height = options.height ?? this.height;
    this.padding = options.padding ?? this.padding;
    this.borderRadius = options.borderRadius ?? this.borderRadius;
    this.autoBgColor = options.autoBgColor ?? this.autoBgColor;
    this.customStyle = options.customStyle;
    this.onClick = options.onClick;
    this.onClose = options.onClose;
  }
}

function tagColor(type: string): string {
  switch (type) {
    case 'primary': return UP_DEFAULT_THEME.primary;
    case 'success': return UP_DEFAULT_THEME.success;
    case 'warning': return UP_DEFAULT_THEME.warning;
    case 'error': return UP_DEFAULT_THEME.error;
    case 'info': return UP_DEFAULT_THEME.info;
    default: return UP_DEFAULT_THEME.primary;
  }
}

@Component
export struct UPTag {
  @Prop props: UPTagProps = new UPTagProps();

  private close(): void {
    if (upBoolean(this.props.disabled, false)) {
      return;
    }
    this.props.onClose?.({ name: this.props.name });
  }

  private iconName(): string {
    return upString(this.props.icon, '');
  }

  private typeColor(): string {
    return tagColor(upString(this.props.type, 'primary').toLowerCase());
  }

  private textColor(): string {
    return UPColor.parse(this.props.color, UP_DEFAULT_THEME,
      upBoolean(this.props.plain, false) ? this.typeColor() : '#ffffff');
  }

  private tagBackground(): string {
    const fill: string = upBoolean(this.props.plainFill, false) ? this.typeColor() + '22' : '#ffffff';
    return UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME,
      upBoolean(this.props.plain, false) ? fill : this.typeColor());
  }

  private sizeName(): string {
    return upString(this.props.size, 'medium').toLowerCase();
  }

  private defaultHeight(): number {
    return this.sizeName() === 'large' ? 30 : (this.sizeName() === 'mini' ? 20 : 24);
  }

  private label(): string {
    return this.props.text === null || this.props.text === undefined ? '' : String(this.props.text);
  }

  private styleHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? UPUnit.parse(this.props.height, 375, this.defaultHeight());
  }

  private stylePadding(): object {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? UPUnit.parseEdges(this.props.padding, 375, 6);
  }

  private styleRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderRadius ?? UPUnit.parse(this.props.borderRadius, 375,
      upString(this.props.shape, 'square').toLowerCase() === 'circle' ? this.defaultHeight() / 2 : 4);
  }

  @Builder
  private content() {
    Row({ space: 4 }) {
      if (this.iconName().length > 0) {
        Text('•')
          .fontSize(this.sizeName() === 'large' ? 16 : 13)
          .fontColor(upString(this.props.iconColor, this.textColor()))
      }
      if (upBoolean(this.props.show, true)) {
        Text(this.label())
          .fontSize(UPUnit.parse(this.props.textSize, 375, this.sizeName() === 'large' ? 15 : 12))
          .fontColor(this.textColor())
        if (upBoolean(this.props.closable, false)) {
          Text('×')
            .fontSize(13)
            .fontColor(upString(this.props.closeColor, '#C6C7CB'))
            .onClick(() => this.close())
        }
      }
    }
    .height(this.styleHeight())
    .padding(this.stylePadding())
    .backgroundColor(this.tagBackground())
    .borderWidth(1)
    .borderColor(UPColor.parse(this.props.borderColor, UP_DEFAULT_THEME, this.typeColor()))
    .borderRadius(this.styleRadius())
    .opacity(!upBoolean(this.props.show, true) ? 0 : (upBoolean(this.props.disabled, false) ? 0.5 : 1))
    .onClick(() => this.props.onClick?.(this.props.name))
  }

  build() {
    this.content()
  }
}
