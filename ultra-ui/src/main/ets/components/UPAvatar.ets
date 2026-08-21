import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPUnit } from '../core/UPUnit';
import { UPIcon, UPIconProps } from './UPIcon';

export interface UPAvatarClickEvent {
  name: UPRawValue;
  src: UPRawValue;
  text: string;
}

export interface UPAvatarOptions {
  src?: UPRawValue;
  shape?: UPRawValue;
  size?: UPRawValue;
  mode?: UPRawValue;
  text?: UPRawValue;
  bgColor?: UPRawValue;
  color?: UPRawValue;
  fontSize?: UPRawValue;
  icon?: UPRawValue;
  mpAvatar?: UPRawValue;
  randomBgColor?: UPRawValue;
  defaultUrl?: UPRawValue;
  colorIndex?: UPRawValue;
  name?: UPRawValue;
  customStyle?: UPStyleInput;
  onClick?: (event: UPAvatarClickEvent) => void;
}

export class UPAvatarProps {
  src: UPRawValue = '';
  shape: UPRawValue = 'circle';
  size: UPRawValue = 40;
  mode: UPRawValue = 'scaleToFill';
  text: UPRawValue = '';
  bgColor: UPRawValue = '#c0c4cc';
  color: UPRawValue = '#ffffff';
  fontSize: UPRawValue = 18;
  icon: UPRawValue = 'account';
  mpAvatar: UPRawValue = false;
  randomBgColor: UPRawValue = false;
  defaultUrl: UPRawValue = '';
  colorIndex: UPRawValue = 0;
  name: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  onClick?: (event: UPAvatarClickEvent) => void;

  constructor(options?: UPAvatarOptions) {
    if (options === undefined) {
      return;
    }
    this.src = options.src ?? this.src;
    this.shape = options.shape ?? this.shape;
    this.size = options.size ?? this.size;
    this.mode = options.mode ?? this.mode;
    this.text = options.text ?? this.text;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.color = options.color ?? this.color;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.icon = options.icon ?? this.icon;
    this.mpAvatar = options.mpAvatar ?? this.mpAvatar;
    this.randomBgColor = options.randomBgColor ?? this.randomBgColor;
    this.defaultUrl = options.defaultUrl ?? this.defaultUrl;
    this.colorIndex = options.colorIndex ?? this.colorIndex;
    this.name = options.name ?? this.name;
    this.customStyle = options.customStyle;
    this.onClick = options.onClick;
  }
}

const UP_AVATAR_COLORS: Array<string> = [
  '#ffb34b', '#f2bba9', '#f7a196', '#f18080', '#88a867', '#bfbf39', '#89c152', '#94d554',
  '#f19ec2', '#afaae4', '#e1b0df', '#c38cc1', '#72dcdc', '#9acdcb', '#77b1cc', '#448aca'
];

function rawText(value: UPRawValue): string {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value);
}

function rawNumber(value: UPRawValue, fallback: number): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string' && Number.isFinite(Number(value.trim()))) {
    return Number(value.trim());
  }
  return fallback;
}

function isLocalImageSource(value: string): boolean {
  return value.startsWith('resource://') || value.startsWith('file://') || value.startsWith('/') || value.startsWith('$rawfile:');
}

@Component
export struct UPAvatar {
  @Prop props: UPAvatarProps = new UPAvatarProps();

  private sizeValue(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? style.height ?? UPUnit.parse(this.props.size, 375, 40);
  }

  private radius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderRadius !== undefined) {
      return style.borderRadius;
    }
    return upString(this.props.shape, 'circle').toLowerCase() === 'square' ? 4 : this.sizeValue() / 2;
  }

  private source(): string {
    const source: string = rawText(this.props.src);
    if (source.length > 0) {
      return source;
    }
    return rawText(this.props.defaultUrl);
  }

  private label(): string {
    const text: string = rawText(this.props.text);
    if (text.length > 0) {
      return text.slice(0, 2);
    }
    const name: string = rawText(this.props.name);
    return name.length > 0 ? name.slice(0, 1).toUpperCase() : '';
  }

  private avatarBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.backgroundColor !== undefined || style.background !== undefined) {
      return style.backgroundColor ?? style.background ?? '#c0c4cc';
    }
    if (upBoolean(this.props.randomBgColor, false)) {
      const label: string = this.label() + rawText(this.props.name);
      let index: number = Math.floor(rawNumber(this.props.colorIndex, 0));
      if (label.length > 0 && index === 0) {
        index = label.charCodeAt(0);
      }
      return UP_AVATAR_COLORS[Math.abs(index) % UP_AVATAR_COLORS.length];
    }
    return UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#c0c4cc');
  }

  private foreground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#ffffff');
  }

  private click(): void {
    this.props.onClick?.({ name: this.props.name, src: this.props.src, text: this.label() });
  }

  @Builder
  private content() {
    Stack() {
      if (this.source().length > 0 && isLocalImageSource(this.source())) {
        Image(this.source())
          .width(this.sizeValue())
          .height(this.sizeValue())
          .objectFit(ImageFit.Cover)
      } else if (this.label().length > 0) {
        Text(this.label())
          .fontSize(UPUnit.parse(this.props.fontSize, 375, Math.max(12, this.sizeValue() * 0.42)))
          .fontColor(this.foreground())
          .fontWeight(FontWeight.Medium)
      } else if (upString(this.props.icon, 'account').length > 0) {
        UPIcon({ props: new UPIconProps({ name: upString(this.props.icon, 'account'), size: this.sizeValue() * 0.52, color: this.foreground() }) })
      }
    }
    .width(this.sizeValue())
    .height(this.sizeValue())
    .backgroundColor(this.avatarBackground())
    .borderRadius(this.radius())
    .clip(true)
    .onClick((): void => {
      this.click();
    })
  }

  build() {
    this.content()
  }
}
