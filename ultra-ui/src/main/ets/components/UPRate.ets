import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPUnit } from '../core/UPUnit';

export interface UPRateChangeEvent {
  value: number;
}

export interface UPRateOptions {
  modelValue?: UPRawValue;
  value?: UPRawValue;
  count?: UPRawValue;
  disabled?: UPRawValue;
  readonly?: UPRawValue;
  size?: UPRawValue;
  inactiveColor?: UPRawValue;
  activeColor?: UPRawValue;
  gutter?: UPRawValue;
  minCount?: UPRawValue;
  allowHalf?: UPRawValue;
  activeIcon?: UPRawValue;
  inactiveIcon?: UPRawValue;
  touchable?: UPRawValue;
  customStyle?: UPStyleInput;
  onChange?: (event: UPRateChangeEvent) => void;
}

export class UPRateProps {
  modelValue: UPRawValue = undefined;
  value: UPRawValue = 1;
  count: UPRawValue = 5;
  disabled: UPRawValue = false;
  readonly: UPRawValue = false;
  size: UPRawValue = 18;
  inactiveColor: UPRawValue = '#b2b2b2';
  activeColor: UPRawValue = '#fa3534';
  gutter: UPRawValue = 4;
  minCount: UPRawValue = 1;
  allowHalf: UPRawValue = false;
  activeIcon: UPRawValue = 'star-fill';
  inactiveIcon: UPRawValue = 'star';
  touchable: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  onChange?: (event: UPRateChangeEvent) => void;

  constructor(options?: UPRateOptions) {
    if (options === undefined) {
      return;
    }
    this.modelValue = options.modelValue ?? this.modelValue;
    this.value = options.value ?? this.value;
    this.count = options.count ?? this.count;
    this.disabled = options.disabled ?? this.disabled;
    this.readonly = options.readonly ?? this.readonly;
    this.size = options.size ?? this.size;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.gutter = options.gutter ?? this.gutter;
    this.minCount = options.minCount ?? this.minCount;
    this.allowHalf = options.allowHalf ?? this.allowHalf;
    this.activeIcon = options.activeIcon ?? this.activeIcon;
    this.inactiveIcon = options.inactiveIcon ?? this.inactiveIcon;
    this.touchable = options.touchable ?? this.touchable;
    this.customStyle = options.customStyle;
    this.onChange = options.onChange;
  }
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

@Component
export struct UPRate {
  @Prop props: UPRateProps = new UPRateProps();

  private countValue(): number {
    return Math.max(0, Math.min(10, Math.floor(rawNumber(this.props.count, 5))));
  }

  private valueNumber(): number {
    const raw: UPRawValue = this.props.modelValue === null || this.props.modelValue === undefined ? this.props.value : this.props.modelValue;
    const minValue: number = rawNumber(this.props.minCount, 1);
    return Math.max(minValue, Math.min(this.countValue(), rawNumber(raw, 1)));
  }

  private stars(): Array<number> {
    const output: Array<number> = [];
    for (let index = 0; index < this.countValue(); index += 1) {
      output.push(index + 1);
    }
    return output;
  }

  private select(index: number): void {
    if (upBoolean(this.props.disabled, false) || upBoolean(this.props.readonly, false) || !upBoolean(this.props.touchable, true)) {
      return;
    }
    const minValue: number = rawNumber(this.props.minCount, 1);
    this.props.onChange?.({ value: Math.max(minValue, index) });
  }

  private starText(index: number): string {
    const value: number = this.valueNumber();
    if (value >= index) {
      return '★';
    }
    if (upBoolean(this.props.allowHalf, false) && value + 0.5 >= index) {
      return '★';
    }
    return '☆';
  }

  private starColor(index: number): string {
    return this.starText(index) === '☆' ? UPColor.parse(this.props.inactiveColor, UP_DEFAULT_THEME, '#b2b2b2') : UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#fa3534');
  }

  private rateFontSize(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.fontSize ?? UPUnit.parse(this.props.size, 375, 18);
  }

  private rateWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? 'auto';
  }

  private rateHeight(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? 'auto';
  }

  build() {
    Row({ space: UPUnit.parse(this.props.gutter, 375, 4) }) {
      ForEach(this.stars(), (index: number) => {
        Text(this.starText(index))
          .fontSize(this.rateFontSize())
          .fontColor(this.starColor(index))
          .opacity(upBoolean(this.props.disabled, false) ? 0.45 : 1)
          .onClick((): void => {
            this.select(index);
          })
      }, (index: number) => String(index))
    }
    .width(this.rateWidth())
    .height(this.rateHeight())
  }
}
