import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPUnit } from '../core/UPUnit';
import { UPIcon, UPIconProps } from './UPIcon';

export interface UPInputChangeEvent {
  value: string;
}

export interface UPInputConfirmEvent {
  value: string;
  key: string;
}

export interface UPInputOptions {
  modelValue?: UPRawValue;
  value?: UPRawValue;
  type?: UPRawValue;
  fixed?: UPRawValue;
  disabled?: UPRawValue;
  disabledColor?: UPRawValue;
  clearable?: UPRawValue;
  onlyClearableOnFocused?: UPRawValue;
  password?: UPRawValue;
  maxlength?: UPRawValue;
  placeholder?: UPRawValue;
  placeholderClass?: UPRawValue;
  placeholderStyle?: UPStyleInput;
  showWordLimit?: UPRawValue;
  confirmType?: UPRawValue;
  confirmHold?: UPRawValue;
  holdKeyboard?: UPRawValue;
  focus?: UPRawValue;
  autoBlur?: UPRawValue;
  disableDefaultPadding?: UPRawValue;
  cursor?: UPRawValue;
  cursorSpacing?: UPRawValue;
  selectionStart?: UPRawValue;
  selectionEnd?: UPRawValue;
  adjustPosition?: UPRawValue;
  inputAlign?: UPRawValue;
  fontSize?: UPRawValue;
  color?: UPRawValue;
  prefixIcon?: UPRawValue;
  prefixIconStyle?: UPStyleInput;
  suffixIcon?: UPRawValue;
  suffixIconStyle?: UPStyleInput;
  border?: UPRawValue;
  readonly?: UPRawValue;
  shape?: UPRawValue;
  formatter?: UPRawValue;
  ignoreCompositionEvent?: UPRawValue;
  cursorColor?: UPRawValue;
  passwordVisibilityToggle?: UPRawValue;
  customStyle?: UPStyleInput;
  onInput?: (event: UPInputChangeEvent) => void;
  onChange?: (event: UPInputChangeEvent) => void;
  onConfirm?: (event: UPInputConfirmEvent) => void;
  onFocus?: () => void;
  onBlur?: (event: UPInputChangeEvent) => void;
  onClear?: () => void;
}

export class UPInputProps {
  modelValue: UPRawValue = undefined;
  value: UPRawValue = '';
  type: UPRawValue = 'text';
  fixed: UPRawValue = false;
  disabled: UPRawValue = false;
  disabledColor: UPRawValue = '#f5f7fa';
  clearable: UPRawValue = false;
  onlyClearableOnFocused: UPRawValue = false;
  password: UPRawValue = false;
  maxlength: UPRawValue = 140;
  placeholder: UPRawValue = '';
  placeholderClass: UPRawValue = '';
  placeholderStyle: UPStyleInput = undefined;
  showWordLimit: UPRawValue = false;
  confirmType: UPRawValue = 'done';
  confirmHold: UPRawValue = false;
  holdKeyboard: UPRawValue = false;
  focus: UPRawValue = false;
  autoBlur: UPRawValue = false;
  disableDefaultPadding: UPRawValue = false;
  cursor: UPRawValue = -1;
  cursorSpacing: UPRawValue = 100;
  selectionStart: UPRawValue = -1;
  selectionEnd: UPRawValue = -1;
  adjustPosition: UPRawValue = true;
  inputAlign: UPRawValue = 'left';
  fontSize: UPRawValue = 15;
  color: UPRawValue = '#303133';
  prefixIcon: UPRawValue = '';
  prefixIconStyle: UPStyleInput = undefined;
  suffixIcon: UPRawValue = '';
  suffixIconStyle: UPStyleInput = undefined;
  border: UPRawValue = 'surround';
  readonly: UPRawValue = false;
  shape: UPRawValue = 'square';
  formatter: UPRawValue = '';
  ignoreCompositionEvent: UPRawValue = true;
  cursorColor: UPRawValue = '#2979ff';
  passwordVisibilityToggle: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  onInput?: (event: UPInputChangeEvent) => void;
  onChange?: (event: UPInputChangeEvent) => void;
  onConfirm?: (event: UPInputConfirmEvent) => void;
  onFocus?: () => void;
  onBlur?: (event: UPInputChangeEvent) => void;
  onClear?: () => void;

  constructor(options?: UPInputOptions) {
    if (options === undefined) {
      return;
    }
    this.modelValue = options.modelValue ?? this.modelValue;
    this.value = options.value ?? this.value;
    this.type = options.type ?? this.type;
    this.fixed = options.fixed ?? this.fixed;
    this.disabled = options.disabled ?? this.disabled;
    this.disabledColor = options.disabledColor ?? this.disabledColor;
    this.clearable = options.clearable ?? this.clearable;
    this.onlyClearableOnFocused = options.onlyClearableOnFocused ?? this.onlyClearableOnFocused;
    this.password = options.password ?? this.password;
    this.maxlength = options.maxlength ?? this.maxlength;
    this.placeholder = options.placeholder ?? this.placeholder;
    this.placeholderClass = options.placeholderClass ?? this.placeholderClass;
    this.placeholderStyle = options.placeholderStyle;
    this.showWordLimit = options.showWordLimit ?? this.showWordLimit;
    this.confirmType = options.confirmType ?? this.confirmType;
    this.confirmHold = options.confirmHold ?? this.confirmHold;
    this.holdKeyboard = options.holdKeyboard ?? this.holdKeyboard;
    this.focus = options.focus ?? this.focus;
    this.autoBlur = options.autoBlur ?? this.autoBlur;
    this.disableDefaultPadding = options.disableDefaultPadding ?? this.disableDefaultPadding;
    this.cursor = options.cursor ?? this.cursor;
    this.cursorSpacing = options.cursorSpacing ?? this.cursorSpacing;
    this.selectionStart = options.selectionStart ?? this.selectionStart;
    this.selectionEnd = options.selectionEnd ?? this.selectionEnd;
    this.adjustPosition = options.adjustPosition ?? this.adjustPosition;
    this.inputAlign = options.inputAlign ?? this.inputAlign;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.color = options.color ?? this.color;
    this.prefixIcon = options.prefixIcon ?? this.prefixIcon;
    this.prefixIconStyle = options.prefixIconStyle;
    this.suffixIcon = options.suffixIcon ?? this.suffixIcon;
    this.suffixIconStyle = options.suffixIconStyle;
    this.border = options.border ?? this.border;
    this.readonly = options.readonly ?? this.readonly;
    this.shape = options.shape ?? this.shape;
    this.formatter = options.formatter ?? this.formatter;
    this.ignoreCompositionEvent = options.ignoreCompositionEvent ?? this.ignoreCompositionEvent;
    this.cursorColor = options.cursorColor ?? this.cursorColor;
    this.passwordVisibilityToggle = options.passwordVisibilityToggle ?? this.passwordVisibilityToggle;
    this.customStyle = options.customStyle;
    this.onInput = options.onInput;
    this.onChange = options.onChange;
    this.onConfirm = options.onConfirm;
    this.onFocus = options.onFocus;
    this.onBlur = options.onBlur;
    this.onClear = options.onClear;
  }
}

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

function inputTypeOf(type: string, password: boolean): InputType {
  const lower: string = type.toLowerCase();
  if (password || lower === 'password') {
    return InputType.Password;
  }
  if (lower === 'number' || lower === 'digit') {
    return InputType.Number;
  }
  if (lower === 'tel' || lower === 'phone') {
    return InputType.PhoneNumber;
  }
  if (lower === 'email') {
    return InputType.Email;
  }
  return InputType.Normal;
}

@Component
export struct UPInput {
  @Prop props: UPInputProps = new UPInputProps();
  @State private innerValue: string = '';
  @State private focused: boolean = false;

  aboutToAppear(): void {
    this.innerValue = this.currentValue();
  }

  private currentValue(): string {
    return this.props.modelValue === null || this.props.modelValue === undefined ? rawText(this.props.value) : rawText(this.props.modelValue);
  }

  private maxLength(): number {
    const parsed: number = Math.floor(rawNumber(this.props.maxlength, 140));
    return parsed < 0 ? 100000 : Math.max(0, parsed);
  }

  private clipped(value: string): string {
    return value.length > this.maxLength() ? value.slice(0, this.maxLength()) : value;
  }

  private setValue(value: string): void {
    this.innerValue = this.clipped(value);
    const event: UPInputChangeEvent = { value: this.innerValue };
    this.props.onInput?.(event);
    this.props.onChange?.(event);
  }

  private clear(): void {
    this.setValue('');
    this.props.onClear?.();
  }

  private inputBorderWidth(): number {
    return upString(this.props.border, 'surround') === 'none' ? 0 : 1;
  }

  private radius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderRadius ?? (upString(this.props.shape, 'square') === 'circle' ? 18 : 4);
  }

  private inputBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    if (upBoolean(this.props.disabled, false)) {
      return UPColor.parse(this.props.disabledColor, UP_DEFAULT_THEME, '#f5f7fa');
    }
    return style.backgroundColor ?? style.background ?? '#ffffff';
  }

  private showClear(): boolean {
    if (!upBoolean(this.props.clearable, false) || this.innerValue.length === 0 || upBoolean(this.props.disabled, false) || upBoolean(this.props.readonly, false)) {
      return false;
    }
    return !upBoolean(this.props.onlyClearableOnFocused, false) || this.focused;
  }

  private textAlignValue(): TextAlign {
    const align: string = upString(this.props.inputAlign, 'left');
    if (align === 'center') {
      return TextAlign.Center;
    }
    if (align === 'right') {
      return TextAlign.End;
    }
    return TextAlign.Start;
  }

  @Builder
  private content() {
    Column({ space: 4 }) {
      Row({ space: 8 }) {
        if (rawText(this.props.prefixIcon).length > 0) {
          UPIcon({ props: new UPIconProps({ name: rawText(this.props.prefixIcon), size: 18, color: '#909399', customStyle: this.props.prefixIconStyle }) })
        }
        TextInput({ text: this.innerValue, placeholder: rawText(this.props.placeholder) })
          .type(inputTypeOf(rawText(this.props.type), upBoolean(this.props.password, false)))
          .enabled(!upBoolean(this.props.disabled, false))
          .fontSize(UPStyle.parse(this.props.customStyle).fontSize ?? UPUnit.parse(this.props.fontSize, 375, 15))
          .fontColor(UPStyle.parse(this.props.customStyle).color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#303133'))
          .placeholderColor('#c0c4cc')
          .caretColor(UPColor.parse(this.props.cursorColor, UP_DEFAULT_THEME, '#2979ff'))
          .maxLength(this.maxLength())
          .backgroundColor('transparent')
          .textAlign(this.textAlignValue())
          .height(32)
          .layoutWeight(1)
          .onFocus((): void => {
            this.focused = true;
            this.props.onFocus?.();
          })
          .onBlur((): void => {
            this.focused = false;
            this.props.onBlur?.({ value: this.innerValue });
          })
          .onChange((value: string): void => {
            if (!upBoolean(this.props.readonly, false)) {
              this.setValue(value);
            }
          })
          .onSubmit((enterKey: EnterKeyType): void => {
            this.props.onConfirm?.({ value: this.innerValue, key: String(enterKey) });
          })
        if (this.showClear()) {
          Text('×')
            .fontSize(16)
            .fontColor('#ffffff')
            .width(18)
            .height(18)
            .textAlign(TextAlign.Center)
            .backgroundColor('#c0c4cc')
            .borderRadius(9)
            .onClick((): void => {
              this.clear();
            })
        }
        if (rawText(this.props.suffixIcon).length > 0) {
          UPIcon({ props: new UPIconProps({ name: rawText(this.props.suffixIcon), size: 18, color: '#909399', customStyle: this.props.suffixIconStyle }) })
        }
      }
      .width('100%')
      .height(UPStyle.parse(this.props.customStyle).height ?? 44)
      .padding(UPStyle.parse(this.props.customStyle).padding ?? { left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.inputBackground())
      .borderWidth(this.inputBorderWidth())
      .borderColor(UPStyle.parse(this.props.customStyle).borderColor ?? '#dadbde')
      .borderRadius(this.radius())
      if (upBoolean(this.props.showWordLimit, false)) {
        Text(String(this.innerValue.length) + '/' + String(this.maxLength()))
          .fontSize(11)
          .fontColor('#909399')
          .width('100%')
          .textAlign(TextAlign.End)
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }

  build() {
    this.content()
  }
}
