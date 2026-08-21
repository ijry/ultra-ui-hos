import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';

export interface UPTextareaChangeEvent {
  value: string;
}

export interface UPTextareaConfirmEvent {
  value: string;
  key: string;
}

export interface UPTextareaOptions {
  value?: UPRawValue;
  modelValue?: UPRawValue;
  placeholder?: UPRawValue;
  placeholderClass?: UPRawValue;
  placeholderStyle?: UPStyleInput;
  height?: UPRawValue;
  confirmType?: UPRawValue;
  disabled?: UPRawValue;
  count?: UPRawValue;
  focus?: UPRawValue;
  autoHeight?: UPRawValue;
  fixed?: UPRawValue;
  cursorSpacing?: UPRawValue;
  cursor?: UPRawValue;
  showConfirmBar?: UPRawValue;
  selectionStart?: UPRawValue;
  selectionEnd?: UPRawValue;
  adjustPosition?: UPRawValue;
  disableDefaultPadding?: UPRawValue;
  holdKeyboard?: UPRawValue;
  maxlength?: UPRawValue;
  border?: UPRawValue;
  formatter?: UPRawValue;
  ignoreCompositionEvent?: UPRawValue;
  customStyle?: UPStyleInput;
  onInput?: (event: UPTextareaChangeEvent) => void;
  onChange?: (event: UPTextareaChangeEvent) => void;
  onConfirm?: (event: UPTextareaConfirmEvent) => void;
  onFocus?: () => void;
  onBlur?: (event: UPTextareaChangeEvent) => void;
}

export class UPTextareaProps {
  value: UPRawValue = '';
  modelValue: UPRawValue = undefined;
  placeholder: UPRawValue = '';
  placeholderClass: UPRawValue = '';
  placeholderStyle: UPStyleInput = undefined;
  height: UPRawValue = 70;
  confirmType: UPRawValue = 'done';
  disabled: UPRawValue = false;
  count: UPRawValue = false;
  focus: UPRawValue = false;
  autoHeight: UPRawValue = false;
  fixed: UPRawValue = false;
  cursorSpacing: UPRawValue = 100;
  cursor: UPRawValue = -1;
  showConfirmBar: UPRawValue = true;
  selectionStart: UPRawValue = -1;
  selectionEnd: UPRawValue = -1;
  adjustPosition: UPRawValue = true;
  disableDefaultPadding: UPRawValue = false;
  holdKeyboard: UPRawValue = false;
  maxlength: UPRawValue = 140;
  border: UPRawValue = 'surround';
  formatter: UPRawValue = '';
  ignoreCompositionEvent: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  onInput?: (event: UPTextareaChangeEvent) => void;
  onChange?: (event: UPTextareaChangeEvent) => void;
  onConfirm?: (event: UPTextareaConfirmEvent) => void;
  onFocus?: () => void;
  onBlur?: (event: UPTextareaChangeEvent) => void;

  constructor(options?: UPTextareaOptions) {
    if (options === undefined) {
      return;
    }
    this.value = options.value ?? this.value;
    this.modelValue = options.modelValue ?? this.modelValue;
    this.placeholder = options.placeholder ?? this.placeholder;
    this.placeholderClass = options.placeholderClass ?? this.placeholderClass;
    this.placeholderStyle = options.placeholderStyle;
    this.height = options.height ?? this.height;
    this.confirmType = options.confirmType ?? this.confirmType;
    this.disabled = options.disabled ?? this.disabled;
    this.count = options.count ?? this.count;
    this.focus = options.focus ?? this.focus;
    this.autoHeight = options.autoHeight ?? this.autoHeight;
    this.fixed = options.fixed ?? this.fixed;
    this.cursorSpacing = options.cursorSpacing ?? this.cursorSpacing;
    this.cursor = options.cursor ?? this.cursor;
    this.showConfirmBar = options.showConfirmBar ?? this.showConfirmBar;
    this.selectionStart = options.selectionStart ?? this.selectionStart;
    this.selectionEnd = options.selectionEnd ?? this.selectionEnd;
    this.adjustPosition = options.adjustPosition ?? this.adjustPosition;
    this.disableDefaultPadding = options.disableDefaultPadding ?? this.disableDefaultPadding;
    this.holdKeyboard = options.holdKeyboard ?? this.holdKeyboard;
    this.maxlength = options.maxlength ?? this.maxlength;
    this.border = options.border ?? this.border;
    this.formatter = options.formatter ?? this.formatter;
    this.ignoreCompositionEvent = options.ignoreCompositionEvent ?? this.ignoreCompositionEvent;
    this.customStyle = options.customStyle;
    this.onInput = options.onInput;
    this.onChange = options.onChange;
    this.onConfirm = options.onConfirm;
    this.onFocus = options.onFocus;
    this.onBlur = options.onBlur;
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

@Component
export struct UPTextarea {
  @Prop props: UPTextareaProps = new UPTextareaProps();
  @State private innerValue: string = '';

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

  private setValue(value: string): void {
    this.innerValue = value.length > this.maxLength() ? value.slice(0, this.maxLength()) : value;
    const event: UPTextareaChangeEvent = { value: this.innerValue };
    this.props.onInput?.(event);
    this.props.onChange?.(event);
  }

  private textareaFontSize(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.fontSize ?? 15;
  }

  private textareaColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.color ?? UP_DEFAULT_THEME.main;
  }

  private textareaHeight(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? UPUnit.parse(this.props.height, 375, 70);
  }

  private textareaPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? { left: 10, right: 10, top: 8, bottom: 8 };
  }

  private textareaBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? '#ffffff';
  }

  private textareaBorderColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderColor ?? '#dadbde';
  }

  private textareaRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderRadius ?? 4;
  }

  private textareaWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? '100%';
  }

  build() {
    Column({ space: 4 }) {
      TextArea({ text: this.innerValue, placeholder: rawText(this.props.placeholder) })
        .enabled(!upBoolean(this.props.disabled, false))
        .fontSize(this.textareaFontSize())
        .fontColor(this.textareaColor())
        .placeholderColor('#c0c4cc')
        .maxLength(this.maxLength())
        .width('100%')
        .height(this.textareaHeight())
        .padding(this.textareaPadding())
        .backgroundColor(this.textareaBackground())
        .borderWidth(upString(this.props.border, 'surround') === 'none' ? 0 : 1)
        .borderColor(this.textareaBorderColor())
        .borderRadius(this.textareaRadius())
        .onFocus((): void => {
          this.props.onFocus?.();
        })
        .onBlur((): void => {
          this.props.onBlur?.({ value: this.innerValue });
        })
        .onChange((value: string): void => {
          this.setValue(value);
        })
        .onSubmit((enterKey: EnterKeyType): void => {
          this.props.onConfirm?.({ value: this.innerValue, key: String(enterKey) });
        })
      if (upBoolean(this.props.count, false)) {
        Text(String(this.innerValue.length) + '/' + String(this.maxLength()))
          .fontSize(11)
          .fontColor(UPColor.parse('tips', UP_DEFAULT_THEME))
          .width('100%')
          .textAlign(TextAlign.End)
      }
    }
    .width(this.textareaWidth())
  }
}
