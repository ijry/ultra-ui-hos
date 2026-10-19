import { UPRawValue, UPStyleInput, upBoolean } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPUnit } from '../core/UPUnit';
import { UPLoadingIcon, UPLoadingIconProps } from './UPLoadingIcon';

export interface UPSwitchChangeEvent {
  value: UPRawValue;
  checked: boolean;
}

export interface UPSwitchOptions {
  loading?: UPRawValue;
  disabled?: UPRawValue;
  size?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
  dotActiveColor?: UPRawValue;
  dotInactiveColor?: UPRawValue;
  modelValue?: UPRawValue;
  value?: UPRawValue;
  activeValue?: UPRawValue;
  inactiveValue?: UPRawValue;
  asyncChange?: UPRawValue;
  space?: UPRawValue;
  customStyle?: UPStyleInput;
  onChange?: (event: UPSwitchChangeEvent) => void;
}

export class UPSwitchProps {
  loading: UPRawValue = false;
  disabled: UPRawValue = false;
  size: UPRawValue = 25;
  activeColor: UPRawValue = '#2979ff';
  inactiveColor: UPRawValue = '#ffffff';
  dotActiveColor: UPRawValue = '#ffffff';
  dotInactiveColor: UPRawValue = '#ffffff';
  modelValue: UPRawValue = undefined;
  value: UPRawValue = false;
  activeValue: UPRawValue = true;
  inactiveValue: UPRawValue = false;
  asyncChange: UPRawValue = false;
  space: UPRawValue = 0;
  customStyle: UPStyleInput = undefined;
  onChange?: (event: UPSwitchChangeEvent) => void;

  constructor(options?: UPSwitchOptions) {
    if (options === undefined) {
      return;
    }
    this.loading = options.loading ?? this.loading;
    this.disabled = options.disabled ?? this.disabled;
    this.size = options.size ?? this.size;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.dotActiveColor = options.dotActiveColor ?? this.dotActiveColor;
    this.dotInactiveColor = options.dotInactiveColor ?? this.dotInactiveColor;
    this.modelValue = options.modelValue ?? this.modelValue;
    this.value = options.value ?? this.value;
    this.activeValue = options.activeValue ?? this.activeValue;
    this.inactiveValue = options.inactiveValue ?? this.inactiveValue;
    this.asyncChange = options.asyncChange ?? this.asyncChange;
    this.space = options.space ?? this.space;
    this.customStyle = options.customStyle;
    this.onChange = options.onChange;
  }
}

function sameRaw(left: UPRawValue, right: UPRawValue): boolean {
  return String(left) === String(right);
}

@Component
export struct UPSwitch {
  @Prop props: UPSwitchProps = new UPSwitchProps();

  private checked(): boolean {
    const value: UPRawValue = this.props.modelValue === null || this.props.modelValue === undefined ? this.props.value : this.props.modelValue;
    return sameRaw(value, this.props.activeValue) || value === true;
  }

  private sizeValue(): number {
    return UPUnit.parse(this.props.size, 375, 25);
  }

  private emit(): void {
    if (upBoolean(this.props.disabled, false) || upBoolean(this.props.loading, false)) {
      return;
    }
    const next: boolean = !this.checked();
    this.props.onChange?.({ value: next ? this.props.activeValue : this.props.inactiveValue, checked: next });
  }

  private trackWidth(): number {
    return this.sizeValue() * 1.8;
  }

  private knobSize(): number {
    return this.sizeValue() - 4;
  }

  private switchWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? this.trackWidth();
  }

  private switchHeight(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? this.sizeValue();
  }

  build() {
    Stack({ alignContent: this.checked() ? Alignment.End : Alignment.Start }) {
      Column()
        .width(this.trackWidth())
        .height(this.sizeValue())
        .backgroundColor(this.checked() ? UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#2979ff') : UPColor.parse(this.props.inactiveColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')))
        .borderRadius(this.sizeValue() / 2)
        .borderWidth(1)
        .borderColor(this.checked() ? UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#2979ff') : '#dadbde')
      if (upBoolean(this.props.loading, false)) {
        UPLoadingIcon({ props: new UPLoadingIconProps({ show: true, size: this.sizeValue() * 0.55, color: '#909399' }) })
      } else {
        Column()
          .width(this.knobSize())
          .height(this.knobSize())
          .backgroundColor(this.checked() ? UPColor.parse(this.props.dotActiveColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')) : UPColor.parse(this.props.dotInactiveColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')))
          .borderRadius(this.knobSize() / 2)
          .margin({ left: 2, right: 2 })
      }
    }
    .width(this.switchWidth())
    .height(this.switchHeight())
    .opacity(upBoolean(this.props.disabled, false) ? 0.5 : 1)
    .onClick((): void => {
      this.emit();
    })
  }
}
