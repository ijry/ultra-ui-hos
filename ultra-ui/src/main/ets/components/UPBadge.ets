import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPBadgeOptions {
  isDot?: UPRawValue;
  value?: UPRawValue;
  modelValue?: UPRawValue;
  show?: UPRawValue;
  max?: UPRawValue;
  type?: UPRawValue;
  showZero?: UPRawValue;
  bgColor?: UPRawValue;
  color?: UPRawValue;
  shape?: UPRawValue;
  numberType?: UPRawValue;
  offset?: Array<number>;
  inverted?: UPRawValue;
  absolute?: UPRawValue;
  customClass?: UPRawValue;
  customStyle?: UPStyleInput;
}

export class UPBadgeProps {
  isDot: UPRawValue = false;
  value: UPRawValue = '';
  modelValue: UPRawValue = undefined;
  show: UPRawValue = true;
  max: UPRawValue = 99;
  type: UPRawValue = 'error';
  showZero: UPRawValue = false;
  bgColor: UPRawValue = '';
  color: UPRawValue = '';
  shape: UPRawValue = 'circle';
  numberType: UPRawValue = 'overflow';
  offset: Array<number> = [0, 0];
  inverted: UPRawValue = false;
  absolute: UPRawValue = false;
  customClass: UPRawValue = '';
  customStyle: UPStyleInput = undefined;

  constructor(options?: UPBadgeOptions) {
    if (options === undefined) {
      return;
    }
    this.isDot = options.isDot ?? this.isDot;
    this.value = options.value ?? this.value;
    this.modelValue = options.modelValue ?? this.modelValue;
    this.show = options.show ?? this.show;
    this.max = options.max ?? this.max;
    this.type = options.type ?? this.type;
    this.showZero = options.showZero ?? this.showZero;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.color = options.color ?? this.color;
    this.shape = options.shape ?? this.shape;
    this.numberType = options.numberType ?? this.numberType;
    this.offset = options.offset ?? this.offset;
    this.inverted = options.inverted ?? this.inverted;
    this.absolute = options.absolute ?? this.absolute;
    this.customClass = options.customClass ?? this.customClass;
    this.customStyle = options.customStyle;
  }
}

function badgeTypeColor(type: string): string {
  switch (type) {
    case 'primary': return UP_DEFAULT_THEME.primary;
    case 'success': return UP_DEFAULT_THEME.success;
    case 'warning': return UP_DEFAULT_THEME.warning;
    case 'info': return UP_DEFAULT_THEME.info;
    default: return UP_DEFAULT_THEME.error;
  }
}

@Component
export struct UPBadge {
  @Prop props: UPBadgeProps = new UPBadgeProps();

  private rawValue(): UPRawValue {
    return this.props.modelValue === undefined ? this.props.value : this.props.modelValue;
  }

  private displayValue(): string {
    const value: UPRawValue = this.rawValue();
    if (value === null || value === undefined) {
      return '';
    }
    const text: string = String(value);
    const numeric: number = Number(text);
    if (Number.isFinite(numeric)) {
      const max: number = upNumber(this.props.max, 99);
      if (numeric === 0 && !upBoolean(this.props.showZero, false)) {
        return '';
      }
      if (upString(this.props.numberType, 'overflow') === 'overflow' && numeric > max) {
        return String(max) + '+';
      }
    }
    return text;
  }

  private visible(): boolean {
    if (!upBoolean(this.props.show, true)) {
      return false;
    }
    return upBoolean(this.props.isDot, false) || this.displayValue().length > 0;
  }

  private bg(): string {
    const style = UPStyle.parse(this.props.customStyle);
    const typeColor: string = badgeTypeColor(upString(this.props.type, 'error').toLowerCase());
    if (upBoolean(this.props.inverted, false)) {
      return style.backgroundColor ?? style.background ?? '#ffffff';
    }
    return style.backgroundColor ?? style.background ?? UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, typeColor);
  }

  private fg(): string {
    const style = UPStyle.parse(this.props.customStyle);
    const typeColor: string = badgeTypeColor(upString(this.props.type, 'error').toLowerCase());
    if (upBoolean(this.props.inverted, false)) {
      return style.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, typeColor);
    }
    return style.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color'));
  }

  private radius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderRadius !== undefined) {
      return style.borderRadius;
    }
    return upString(this.props.shape, 'circle').toLowerCase() === 'horn' ? 4 : 100;
  }

  private offsetX(): number {
    return this.props.offset.length > 0 ? this.props.offset[0] : 0;
  }

  private offsetY(): number {
    return this.props.offset.length > 1 ? this.props.offset[1] : 0;
  }

  @Builder
  private content() {
    if (!this.visible()) {
      Row().width(0).height(0)
    } else if (upBoolean(this.props.isDot, false)) {
      Column()
        .width(8)
        .height(8)
        .backgroundColor(this.bg())
        .borderRadius(4)
        .offset({ x: this.offsetX(), y: this.offsetY() })
    } else {
      Text(this.displayValue())
        .fontSize(11)
        .fontColor(this.fg())
        .height(18)
        .padding({ left: 6, right: 6 })
        .backgroundColor(this.bg())
        .borderWidth(upBoolean(this.props.inverted, false) ? 1 : 0)
        .borderColor(this.fg())
        .borderRadius(this.radius())
        .offset({ x: this.offsetX(), y: this.offsetY() })
    }
  }

  build() {
    this.content()
  }
}
