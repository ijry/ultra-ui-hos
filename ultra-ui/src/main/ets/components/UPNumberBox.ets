import { UPBuilder, UPRawValue, UPStyleInput, upBoolean } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPUnit } from '../core/UPUnit';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPNumberBoxChangeEvent {
  value: number;
  name: UPRawValue;
  type: string;
}

export interface UPNumberBoxOptions {
  name?: UPRawValue;
  value?: UPRawValue;
  modelValue?: UPRawValue;
  min?: UPRawValue;
  max?: UPRawValue;
  step?: UPRawValue;
  integer?: UPRawValue;
  disabled?: UPRawValue;
  disabledInput?: UPRawValue;
  asyncChange?: UPRawValue;
  inputWidth?: UPRawValue;
  showMinus?: UPRawValue;
  showPlus?: UPRawValue;
  decimalLength?: UPRawValue;
  longPress?: UPRawValue;
  color?: UPRawValue;
  buttonWidth?: UPRawValue;
  buttonSize?: UPRawValue;
  buttonRadius?: UPRawValue;
  bgColor?: UPRawValue;
  disabledBgColor?: UPRawValue;
  inputBgColor?: UPRawValue;
  cursorSpacing?: UPRawValue;
  disablePlus?: UPRawValue;
  disableMinus?: UPRawValue;
  iconStyle?: UPStyleInput;
  miniMode?: UPRawValue;
  customStyle?: UPStyleInput;
  onChange?: (event: UPNumberBoxChangeEvent) => void;
  onPlus?: (event: UPNumberBoxChangeEvent) => void;
  onMinus?: (event: UPNumberBoxChangeEvent) => void;
  onBlur?: (event: UPNumberBoxChangeEvent) => void;
  onFocus?: (event: UPNumberBoxChangeEvent) => void;
  onOverlimit?: (type: string) => void;
  minusBuilder?: UPBuilder;
  plusBuilder?: UPBuilder;
  inputBuilder?: UPBuilder;
}

export class UPNumberBoxProps {
  name: UPRawValue = '';
  value: UPRawValue = 0;
  modelValue: UPRawValue = undefined;
  min: UPRawValue = 1;
  max: UPRawValue = 9007199254740991;
  step: UPRawValue = 1;
  integer: UPRawValue = false;
  disabled: UPRawValue = false;
  disabledInput: UPRawValue = false;
  asyncChange: UPRawValue = false;
  inputWidth: UPRawValue = 35;
  showMinus: UPRawValue = true;
  showPlus: UPRawValue = true;
  decimalLength: UPRawValue = undefined;
  longPress: UPRawValue = true;
  color: UPRawValue = '#323233';
  buttonWidth: UPRawValue = 30;
  buttonSize: UPRawValue = 30;
  buttonRadius: UPRawValue = 4;
  bgColor: UPRawValue = '#f2f3f5';
  disabledBgColor: UPRawValue = '#f7f8fa';
  inputBgColor: UPRawValue = '#f2f3f5';
  cursorSpacing: UPRawValue = 100;
  disablePlus: UPRawValue = false;
  disableMinus: UPRawValue = false;
  iconStyle: UPStyleInput = undefined;
  miniMode: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  onChange?: (event: UPNumberBoxChangeEvent) => void;
  onPlus?: (event: UPNumberBoxChangeEvent) => void;
  onMinus?: (event: UPNumberBoxChangeEvent) => void;
  onBlur?: (event: UPNumberBoxChangeEvent) => void;
  onFocus?: (event: UPNumberBoxChangeEvent) => void;
  onOverlimit?: (type: string) => void;
  minusBuilder?: UPBuilder;
  plusBuilder?: UPBuilder;
  inputBuilder?: UPBuilder;

  constructor(options?: UPNumberBoxOptions) {
    if (options === undefined) {
      return;
    }
    this.name = options.name ?? this.name;
    this.value = options.value ?? this.value;
    this.modelValue = options.modelValue ?? this.modelValue;
    this.min = options.min ?? this.min;
    this.max = options.max ?? this.max;
    this.step = options.step ?? this.step;
    this.integer = options.integer ?? this.integer;
    this.disabled = options.disabled ?? this.disabled;
    this.disabledInput = options.disabledInput ?? this.disabledInput;
    this.asyncChange = options.asyncChange ?? this.asyncChange;
    this.inputWidth = options.inputWidth ?? this.inputWidth;
    this.showMinus = options.showMinus ?? this.showMinus;
    this.showPlus = options.showPlus ?? this.showPlus;
    this.decimalLength = options.decimalLength ?? this.decimalLength;
    this.longPress = options.longPress ?? this.longPress;
    this.color = options.color ?? this.color;
    this.buttonWidth = options.buttonWidth ?? this.buttonWidth;
    this.buttonSize = options.buttonSize ?? this.buttonSize;
    this.buttonRadius = options.buttonRadius ?? this.buttonRadius;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.disabledBgColor = options.disabledBgColor ?? this.disabledBgColor;
    this.inputBgColor = options.inputBgColor ?? this.inputBgColor;
    this.cursorSpacing = options.cursorSpacing ?? this.cursorSpacing;
    this.disablePlus = options.disablePlus ?? this.disablePlus;
    this.disableMinus = options.disableMinus ?? this.disableMinus;
    this.iconStyle = options.iconStyle;
    this.miniMode = options.miniMode ?? this.miniMode;
    this.customStyle = options.customStyle;
    this.onChange = options.onChange;
    this.onPlus = options.onPlus;
    this.onMinus = options.onMinus;
    this.onBlur = options.onBlur;
    this.onFocus = options.onFocus;
    this.onOverlimit = options.onOverlimit;
    this.minusBuilder = options.minusBuilder;
    this.plusBuilder = options.plusBuilder;
    this.inputBuilder = options.inputBuilder;
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

function rawText(value: UPRawValue): string {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value);
}

@Component
export struct UPNumberBox {
  @Prop props: UPNumberBoxProps = new UPNumberBoxProps();
  @State private innerValue: number = 0;

  aboutToAppear(): void {
    this.innerValue = this.normalized(this.currentNumber());
  }

  private currentNumber(): number {
    const raw: UPRawValue = this.props.modelValue === null || this.props.modelValue === undefined ? this.props.value : this.props.modelValue;
    return rawNumber(raw, 0);
  }

  private minValue(): number {
    return rawNumber(this.props.min, 1);
  }

  private maxValue(): number {
    return Math.max(this.minValue(), rawNumber(this.props.max, 9007199254740991));
  }

  private decimalPlaces(): number | undefined {
    if (this.props.decimalLength === null || this.props.decimalLength === undefined) {
      return undefined;
    }
    return Math.max(0, Math.min(8, Math.floor(rawNumber(this.props.decimalLength, 0))));
  }

  private normalized(value: number): number {
    let result: number = Math.max(this.minValue(), Math.min(this.maxValue(), value));
    if (upBoolean(this.props.integer, false)) {
      result = Math.round(result);
    }
    const places: number | undefined = this.decimalPlaces();
    if (places !== undefined) {
      const power: number = Math.pow(10, places);
      result = Math.round(result * power) / power;
    }
    return result;
  }

  private emit(value: number, type: string): void {
    const next: number = this.normalized(value);
    this.innerValue = next;
    const event: UPNumberBoxChangeEvent = { value: next, name: this.props.name, type };
    this.props.onChange?.(event);
    if (type === 'plus') {
      this.props.onPlus?.(event);
    } else if (type === 'minus') {
      this.props.onMinus?.(event);
    } else if (type === 'blur') {
      this.props.onBlur?.(event);
    }
  }

  private canMinus(): boolean {
    return !upBoolean(this.props.disabled, false) && !upBoolean(this.props.disableMinus, false) && this.innerValue > this.minValue();
  }

  private canPlus(): boolean {
    return !upBoolean(this.props.disabled, false) && !upBoolean(this.props.disablePlus, false) && this.innerValue < this.maxValue();
  }

  private numberBoxWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? 'auto';
  }

  private numberBoxHeight(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? 'auto';
  }

  @Builder
  private button(text: string, enabled: boolean, type: string) {
    Text(text)
      .fontSize(20)
      .fontColor(enabled ? UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#323233') : '#c8c9cc')
      .textAlign(TextAlign.Center)
      .width(UPUnit.parse(this.props.buttonWidth, 375, 30))
      .height(UPUnit.parse(this.props.buttonSize, 375, 30))
      .backgroundColor(enabled ? UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#f2f3f5') : UPColor.parse(this.props.disabledBgColor, UP_DEFAULT_THEME, '#f7f8fa'))
      .borderRadius(UPUnit.parse(this.props.buttonRadius, 375, 4))
      .onClick((): void => {
        if (!enabled) {
          /** 上游 overlimit：越界时只抛事件不改值。/ Upstream overlimit fires without changing the value. */
          this.props.onOverlimit?.(type);
          return;
        }
        const delta: number = rawNumber(this.props.step, 1);
        this.emit(this.innerValue + (type === 'plus' ? delta : -delta), type);
      })
  }

  @Builder
  private minusRegion() {
    UPSlotRegion({ contentBuilder: this.props.minusBuilder })
  }

  @Builder
  private plusRegion() {
    UPSlotRegion({ contentBuilder: this.props.plusBuilder })
  }

  @Builder
  private inputRegion() {
    UPSlotRegion({ contentBuilder: this.props.inputBuilder })
  }

  build() {
    Row({ space: 2 }) {
      if (upBoolean(this.props.showMinus, true)) {
        if (this.props.minusBuilder !== undefined) {
          this.minusRegion()
        } else {
          this.button('−', this.canMinus(), 'minus')
        }
      }
      if (this.props.inputBuilder !== undefined) {
        this.inputRegion()
      } else {
        TextInput({ text: rawText(this.innerValue), placeholder: '' })
          .type(InputType.Number)
          .enabled(!upBoolean(this.props.disabled, false) && !upBoolean(this.props.disabledInput, false))
          .fontSize(14)
          .fontColor(UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#323233'))
          .textAlign(TextAlign.Center)
          .width(UPUnit.parse(this.props.inputWidth, 375, 35))
          .height(UPUnit.parse(this.props.buttonSize, 375, 30))
          .backgroundColor(UPColor.parse(this.props.inputBgColor, UP_DEFAULT_THEME, '#f2f3f5'))
          .borderWidth(0)
          .onChange((value: string): void => {
            this.innerValue = this.normalized(rawNumber(value, this.innerValue));
          })
          .onFocus((): void => {
            this.props.onFocus?.({ value: this.innerValue, name: this.props.name, type: 'focus' });
          })
          .onBlur((): void => {
            this.emit(this.innerValue, 'blur');
          })
      }
      if (upBoolean(this.props.showPlus, true)) {
        if (this.props.plusBuilder !== undefined) {
          this.plusRegion()
        } else {
          this.button('+', this.canPlus(), 'plus')
        }
      }
    }
    .width(this.numberBoxWidth())
    .height(this.numberBoxHeight())
    .opacity(upBoolean(this.props.disabled, false) ? 0.55 : 1)
  }
}
