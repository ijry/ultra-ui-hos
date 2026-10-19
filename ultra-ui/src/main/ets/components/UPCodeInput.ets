import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPEdgeValues, UPUnit } from '../core/UPUnit';

export interface UPCodeInputChangeEvent {
  value: string;
}

export interface UPCodeInputOptions {
  adjustPosition?: UPRawValue;
  maxlength?: UPRawValue;
  dot?: UPRawValue;
  mode?: UPRawValue;
  hairline?: UPRawValue;
  space?: UPRawValue;
  modelValue?: UPRawValue;
  value?: UPRawValue;
  focus?: UPRawValue;
  bold?: UPRawValue;
  color?: UPRawValue;
  fontSize?: UPRawValue;
  size?: UPRawValue;
  disabledKeyboard?: UPRawValue;
  borderColor?: UPRawValue;
  disabledDot?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onInput?: (event: UPCodeInputChangeEvent) => void;
  onChange?: (event: UPCodeInputChangeEvent) => void;
  onFinish?: (event: UPCodeInputChangeEvent) => void;
}

export class UPCodeInputProps {
  adjustPosition: UPRawValue = true;
  maxlength: UPRawValue = 6;
  dot: UPRawValue = false;
  mode: UPRawValue = 'box';
  hairline: UPRawValue = false;
  space: UPRawValue = 10;
  modelValue: UPRawValue = undefined;
  value: UPRawValue = '';
  focus: UPRawValue = false;
  bold: UPRawValue = false;
  color: UPRawValue = '#606266';
  fontSize: UPRawValue = 18;
  size: UPRawValue = 35;
  disabledKeyboard: UPRawValue = false;
  borderColor: UPRawValue = '#c9cacc';
  disabledDot: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  onInput?: (event: UPCodeInputChangeEvent) => void;
  onChange?: (event: UPCodeInputChangeEvent) => void;
  onFinish?: (event: UPCodeInputChangeEvent) => void;

  constructor(options?: UPCodeInputOptions) {
    if (options === undefined) {
      return;
    }
    this.adjustPosition = options.adjustPosition ?? this.adjustPosition;
    this.maxlength = options.maxlength ?? this.maxlength;
    this.dot = options.dot ?? this.dot;
    this.mode = options.mode ?? this.mode;
    this.hairline = options.hairline ?? this.hairline;
    this.space = options.space ?? this.space;
    this.modelValue = options.modelValue ?? this.modelValue;
    this.value = options.value ?? this.value;
    this.focus = options.focus ?? this.focus;
    this.bold = options.bold ?? this.bold;
    this.color = options.color ?? this.color;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.size = options.size ?? this.size;
    this.disabledKeyboard = options.disabledKeyboard ?? this.disabledKeyboard;
    this.borderColor = options.borderColor ?? this.borderColor;
    this.disabledDot = options.disabledDot ?? this.disabledDot;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onInput = options.onInput;
    this.onChange = options.onChange;
    this.onFinish = options.onFinish;
  }
}

function rawText(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
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
export struct UPCodeInput {
  @Prop props: UPCodeInputProps = new UPCodeInputProps();
  @State private innerValue: string = '';
  @State private focused: boolean = false;
  @State private finishedValue: string = '';

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  aboutToAppear(): void {
    this.innerValue = this.clipped(this.currentValue());
    this.focused = upBoolean(this.props.focus, false);
    const mode: string = upString(this.props.mode, 'box').toLowerCase();
    if (mode !== 'box' && mode !== 'line') {
      this.diagnostics().report('UPCodeInput', 'mode', this.props.mode, 'unsupported mode; fallback to box');
    }
    if (!upBoolean(this.props.adjustPosition, true)) {
      this.diagnostics().report('UPCodeInput', 'adjustPosition', this.props.adjustPosition, 'keyboard avoidance is managed by the native input container');
    }
  }

  private currentValue(): string {
    return this.props.modelValue === null || this.props.modelValue === undefined ? rawText(this.props.value) : rawText(this.props.modelValue);
  }

  private maxLength(): number {
    const parsed: number = Math.floor(rawNumber(this.props.maxlength, 6));
    return parsed <= 0 ? 6 : Math.min(parsed, 100);
  }

  private clipped(value: string): string {
    const maximum: number = this.maxLength();
    return value.length > maximum ? value.slice(0, maximum) : value;
  }

  private acceptedValue(value: string): string {
    let next: string = value;
    if (upBoolean(this.props.disabledDot, true)) {
      next = next.replaceAll('.', '');
    }
    return this.clipped(next);
  }

  private setValue(value: string): void {
    const next: string = this.acceptedValue(value);
    this.innerValue = next;
    const event: UPCodeInputChangeEvent = { value: next };
    this.props.onInput?.(event);
    this.props.onChange?.(event);
    if (next.length >= this.maxLength() && this.finishedValue !== next) {
      this.finishedValue = next;
      this.props.onFinish?.(event);
    } else if (next.length < this.maxLength()) {
      this.finishedValue = '';
    }
  }

  private modeName(): string {
    return upString(this.props.mode, 'box').toLowerCase() === 'line' ? 'line' : 'box';
  }

  private cellSize(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(1, style.height ?? UPUnit.parse(this.props.size, 375, 35));
  }

  private cellWidth(): number {
    return Math.max(1, UPUnit.parse(this.props.size, 375, 35));
  }

  private codeFontSize(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(1, style.fontSize ?? UPUnit.parse(this.props.fontSize, 375, 18));
  }

  private codeColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, UPColor.neutral('content', '#606266'));
  }

  private cellBorderColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderColor ?? UPColor.parse(this.props.borderColor, UP_DEFAULT_THEME, '#c9cacc');
  }

  private cellRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(0, style.borderRadius ?? 4);
  }

  private cellIndexes(): Array<number> {
    const result: Array<number> = [];
    for (let index: number = 0; index < this.maxLength(); index += 1) {
      result.push(index);
    }
    return result;
  }

  private cellValue(index: number): string {
    if (index >= this.innerValue.length) {
      return '';
    }
    if (upBoolean(this.props.dot, false)) {
      return '●';
    }
    return this.innerValue.charAt(index);
  }

  private cellBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? '#ffffff';
  }

  private cellPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? UPUnit.parseEdges(0, 375);
  }

  private cellGap(): number {
    return Math.max(0, UPUnit.parse(this.props.space, 375, 10));
  }

  private contentWidth(): number {
    return this.cellWidth() * this.maxLength() + this.cellGap() * Math.max(0, this.maxLength() - 1);
  }

  private contentMargin(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.margin ?? UPUnit.parseEdges(0, 375);
  }

  @Builder
  private cell(index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Text(this.cellValue(index))
        .fontSize(this.codeFontSize())
        .fontColor(this.codeColor())
        .fontWeight(upBoolean(this.props.bold, false) ? FontWeight.Bold : FontWeight.Normal)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height('100%')
      if (this.modeName() === 'line') {
        Column()
          .width('100%')
          .height(upBoolean(this.props.hairline, false) ? 1 : 2)
          .backgroundColor(this.cellBorderColor())
          .alignSelf(ItemAlign.End)
      }
      if (this.focused && index === this.innerValue.length && index < this.maxLength()) {
        Column()
          .width(1)
          .height(Math.max(12, this.codeFontSize() + 4))
          .backgroundColor(this.codeColor())
      }
    }
    .width(this.cellWidth())
    .height(this.cellSize())
    .padding(this.cellPadding())
    .backgroundColor(this.cellBackground())
    .borderWidth(this.modeName() === 'box' ? (upBoolean(this.props.hairline, false) ? 0.5 : 1) : 0)
    .borderColor(this.cellBorderColor())
    .borderRadius(this.modeName() === 'box' ? this.cellRadius() : 0)
  }

  @Builder
  private hiddenInput() {
    TextInput({ text: this.innerValue, placeholder: '' })
      .type(InputType.Number)
      .enabled(!upBoolean(this.props.disabledKeyboard, false))
      .maxLength(this.maxLength())
      .fontSize(1)
      .fontColor('transparent')
      .caretColor('transparent')
      .backgroundColor('transparent')
      .opacity(0.01)
      .width('100%')
      .height(this.cellSize())
      .onFocus((): void => {
        this.focused = true;
      })
      .onBlur((): void => {
        this.focused = false;
      })
      .onChange((value: string): void => {
        this.setValue(value);
      })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row({ space: this.cellGap() }) {
        ForEach(this.cellIndexes(), (index: number) => {
          this.cell(index)
        }, (index: number) => String(index))
      }
      .width(this.contentWidth())
      .height(this.cellSize())
      this.hiddenInput()
    }
    .width(this.contentWidth())
    .height(this.cellSize())
    .margin(this.contentMargin())
    .id('up-code-input')
  }
}
