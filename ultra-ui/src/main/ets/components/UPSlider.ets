import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export type UPSliderChangeMode = 'start' | 'changing' | 'change';
export interface UPSliderChangeEvent { value: number; mode: UPSliderChangeMode; }
interface UPSliderBounds { min: number; max: number; step: number; }
export interface UPSliderOptions {
  modelValue?: UPRawValue; value?: UPRawValue; min?: UPRawValue; max?: UPRawValue; step?: UPRawValue;
  disabled?: UPRawValue; vertical?: UPRawValue; length?: UPRawValue; showValue?: UPRawValue;
  blockSize?: UPRawValue; blockColor?: UPRawValue; blockStyle?: UPStyleInput; activeColor?: UPRawValue;
  inactiveColor?: UPRawValue; size?: UPRawValue; height?: UPRawValue; innerStyle?: UPStyleInput;
  useNative?: UPRawValue; isRange?: UPRawValue; rangeValue?: Array<UPRawValue>;
  diagnostics?: UPCompatibilityDiagnostics; onStart?: (event: UPSliderChangeEvent) => void;
  onChanging?: (event: UPSliderChangeEvent) => void; onChange?: (event: UPSliderChangeEvent) => void;
  onModelValueChange?: (value: number) => void;
  contentBuilder?: UPBuilder;
  minBuilder?: UPBuilder;
  maxBuilder?: UPBuilder;
}

export class UPSliderProps {
  modelValue: UPRawValue = undefined; value: UPRawValue = 0; min: UPRawValue = 0; max: UPRawValue = 100;
  step: UPRawValue = 1; disabled: UPRawValue = false; vertical: UPRawValue = false; length: UPRawValue = 'auto';
  showValue: UPRawValue = false; blockSize: UPRawValue = 18; blockColor: UPRawValue = '#ffffff'; blockStyle: UPStyleInput = undefined;
  activeColor: UPRawValue = '#2979ff'; inactiveColor: UPRawValue = '#c0c4cc'; size: UPRawValue = '2px'; height: UPRawValue = '';
  innerStyle: UPStyleInput = undefined; useNative: UPRawValue = false; isRange: UPRawValue = false; rangeValue: Array<UPRawValue> = [0, 0];
  diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  onStart?: (event: UPSliderChangeEvent) => void; onChanging?: (event: UPSliderChangeEvent) => void;
  onChange?: (event: UPSliderChangeEvent) => void; onModelValueChange?: (value: number) => void;
  contentBuilder?: UPBuilder;
  minBuilder?: UPBuilder;
  maxBuilder?: UPBuilder;
  constructor(options?: UPSliderOptions) {
    if (options === undefined) return;
    this.modelValue = options.modelValue ?? this.modelValue; this.value = options.value ?? this.value; this.min = options.min ?? this.min;
    this.max = options.max ?? this.max; this.step = options.step ?? this.step; this.disabled = options.disabled ?? this.disabled;
    this.vertical = options.vertical ?? this.vertical; this.length = options.length ?? this.length; this.showValue = options.showValue ?? this.showValue;
    this.blockSize = options.blockSize ?? this.blockSize; this.blockColor = options.blockColor ?? this.blockColor; this.blockStyle = options.blockStyle;
    this.activeColor = options.activeColor ?? this.activeColor; this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.size = options.size ?? this.size; this.height = options.height ?? this.height; this.innerStyle = options.innerStyle;
    this.useNative = options.useNative ?? this.useNative; this.isRange = options.isRange ?? this.isRange; this.rangeValue = options.rangeValue?.slice() ?? this.rangeValue;
    this.diagnostics = options.diagnostics ?? this.diagnostics; this.onStart = options.onStart; this.onChanging = options.onChanging;
    this.onChange = options.onChange; this.onModelValueChange = options.onModelValueChange;
    this.contentBuilder = options.contentBuilder;
    this.minBuilder = options.minBuilder;
    this.maxBuilder = options.maxBuilder;
  }
}

function decimalLength(value: number): number { const text: string = String(value); const point: number = text.indexOf('.'); return point < 0 ? 0 : text.length - point - 1; }

@Component
export struct UPSlider {
  @Prop props: UPSliderProps = new UPSliderProps();

  aboutToAppear(): void {
    if (upBoolean(this.props.isRange, false)) this.props.diagnostics.report('UPSlider', 'isRange', this.props.isRange, 'range slider is unsupported; rendering one native slider');
    if (upBoolean(this.props.useNative, false)) this.props.diagnostics.report('UPSlider', 'useNative', this.props.useNative, 'native mode is already used; property is a no-op');
  }

  private bounds(): UPSliderBounds {
    let min: number = upNumber(this.props.min, 0); let max: number = upNumber(this.props.max, 100);
    if (max < min) { const swap: number = min; min = max; max = swap; }
    const rawStep: number = upNumber(this.props.step, 1); const step: number = rawStep > 0 ? rawStep : 1;
    if (rawStep <= 0) this.props.diagnostics.report('UPSlider', 'step', this.props.step, 'step must be positive; fallback to 1');
    return { min, max, step };
  }

  private formatByStep(value: number): number {
    const bounds: UPSliderBounds = this.bounds();
    const bounded: number = Math.max(bounds.min, Math.min(bounds.max, value));
    const stepped: number = bounds.min + Math.round((bounded - bounds.min) / bounds.step) * bounds.step;
    const precision: number = Math.max(decimalLength(bounds.min), decimalLength(bounds.step));
    return Number(stepped.toFixed(Math.min(12, precision)));
  }

  private currentValue(): number { const raw: UPRawValue = this.props.modelValue === null || this.props.modelValue === undefined ? this.props.value : this.props.modelValue; return this.formatByStep(upNumber(raw, 0)); }
  private emit(value: number, mode: UPSliderChangeMode): void {
    const event: UPSliderChangeEvent = { value: this.formatByStep(value), mode };
    if (mode === 'start') this.props.onStart?.(event); else if (mode === 'changing') this.props.onChanging?.(event); else { this.props.onChange?.(event); this.props.onModelValueChange?.(event.value); }
  }
  private lengthValue(): number | string {
    const style = UPStyle.parse(this.props.innerStyle);
    if (style.width !== undefined) return style.width;
    const length: number = UPUnit.parse(this.props.length, 375, 0);
    return length > 0 ? length : 'auto';
  }
  private heightValue(): number | string {
    const style = UPStyle.parse(this.props.innerStyle);
    if (style.height !== undefined) return style.height;
    const length: number = UPUnit.parse(this.props.length, 375, 0);
    return length > 0 ? length : 'auto';
  }

  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  @Builder
  private minRegion() {
    UPSlotRegion({ contentBuilder: this.props.minBuilder })
  }

  @Builder
  private maxRegion() {
    UPSlotRegion({ contentBuilder: this.props.maxBuilder })
  }

  build() {
    Column({ space: 4 }) {
      if (upBoolean(this.props.showValue, false)) Text(String(this.currentValue())).fontSize(13).fontColor(UPColor.adaptive('#606266', 'content-color'))
      Row({ space: 6 }) {
        this.minRegion()
        this.slotRegion()
        this.maxRegion()
      }
      Slider({ value: this.currentValue(), min: this.bounds().min, max: this.bounds().max, step: this.bounds().step, direction: upBoolean(this.props.vertical, false) ? Axis.Vertical : Axis.Horizontal })
        .blockSize({ width: Math.max(12, Math.min(28, upNumber(this.props.blockSize, 18))), height: Math.max(12, Math.min(28, upNumber(this.props.blockSize, 18))) })
        .blockColor(UPColor.parse(this.props.blockColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')))
        .trackColor(UPColor.parse(this.props.inactiveColor, UP_DEFAULT_THEME, UPColor.neutral('light', '#c0c4cc')))
        .selectedColor(UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#2979ff'))
        .enabled(!upBoolean(this.props.disabled, false))
        .onChange((value: number, mode: SliderChangeMode): void => this.emit(value, mode === SliderChangeMode.Begin ? 'start' : mode === SliderChangeMode.Moving ? 'changing' : 'change'))
    }
    .width(upBoolean(this.props.vertical, false) ? 'auto' : this.lengthValue())
    .height(upBoolean(this.props.vertical, false) ? this.heightValue() : 'auto')
  }
}
