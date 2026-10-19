import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle, UPStyleResult } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPEdgeValues, UPUnit } from '../core/UPUnit';

/** 验证码输入的回传事件。/ Payload shared by the change and finish events. */
export interface UPMessageInputChangeEvent {
  value: string;
}

export interface UPMessageInputOptions {
  maxlength?: UPRawValue;
  dotFill?: UPRawValue;
  mode?: UPRawValue;
  modelValue?: UPRawValue;
  breathe?: UPRawValue;
  focus?: UPRawValue;
  bold?: UPRawValue;
  fontSize?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
  width?: UPRawValue;
  disabledKeyboard?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onChange?: (event: UPMessageInputChangeEvent) => void;
  onFinish?: (event: UPMessageInputChangeEvent) => void;
}

export class UPMessageInputProps {
  maxlength: UPRawValue = 4;
  dotFill: UPRawValue = false;
  mode: UPRawValue = 'box';
  modelValue: UPRawValue = '';
  breathe: UPRawValue = true;
  focus: UPRawValue = false;
  bold: UPRawValue = false;
  fontSize: UPRawValue = 60;
  activeColor: UPRawValue = '#2979ff';
  inactiveColor: UPRawValue = '#606266';
  width: UPRawValue = '80';
  disabledKeyboard: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onChange?: (event: UPMessageInputChangeEvent) => void;
  onFinish?: (event: UPMessageInputChangeEvent) => void;

  constructor(options?: UPMessageInputOptions) {
    if (options === undefined) {
      return;
    }
    this.maxlength = options.maxlength ?? this.maxlength;
    this.dotFill = options.dotFill ?? this.dotFill;
    this.mode = options.mode ?? this.mode;
    this.modelValue = options.modelValue ?? this.modelValue;
    this.breathe = options.breathe ?? this.breathe;
    this.focus = options.focus ?? this.focus;
    this.bold = options.bold ?? this.bold;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.width = options.width ?? this.width;
    this.disabledKeyboard = options.disabledKeyboard ?? this.disabledKeyboard;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onChange = options.onChange;
    this.onFinish = options.onFinish;
  }
}

/** 上游呼吸动画一个周期 1.2 秒。/ Upstream breathing keyframe duration. */
const UP_MESSAGE_INPUT_BREATHE_DURATION: number = 1200;

/** 上游只接受数字，这里在写入前统一过滤。/ Upstream keeps digits only. */
function upMessageInputDigits(value: string): string {
  let digits: string = '';
  for (let index: number = 0; index < value.length; index += 1) {
    const char: string = value.charAt(index);
    if (char >= '0' && char <= '9') {
      digits += char;
    }
  }
  return digits;
}

function upMessageInputNumber(value: UPRawValue, fallback: number): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string' && value.trim().length > 0 && Number.isFinite(Number(value.trim()))) {
    return Number(value.trim());
  }
  return fallback;
}

@Component
export struct UPMessageInput {
  @Prop props: UPMessageInputProps = new UPMessageInputProps();
  @State private innerValue: string = '';
  @State private focused: boolean = false;
  @State private breatheOn: boolean = true;
  private finishedValue: string = '';
  private breatheTimerId: number = -1;

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  aboutToAppear(): void {
    this.innerValue = this.clipped(upMessageInputDigits(upString(this.props.modelValue, '')));
    this.focused = upBoolean(this.props.focus, false);
    const mode: string = this.modeName();
    if (mode !== upString(this.props.mode, 'box')) {
      this.diagnostics().report('UPMessageInput', 'mode', this.props.mode, 'unsupported mode; fallback to box');
    }
    this.startBreathe();
  }

  aboutToDisappear(): void {
    this.stopBreathe();
  }

  /** 上游用 CSS keyframes 呼吸，这里用定时器切换透明度 + 属性动画近似。/ Timer driven breathing halo. */
  private startBreathe(): void {
    this.stopBreathe();
    if (!upBoolean(this.props.breathe, true)) {
      return;
    }
    this.breatheTimerId = setInterval((): void => {
      this.breatheOn = !this.breatheOn;
    }, UP_MESSAGE_INPUT_BREATHE_DURATION);
  }

  private stopBreathe(): void {
    if (this.breatheTimerId >= 0) {
      clearInterval(this.breatheTimerId);
      this.breatheTimerId = -1;
    }
    this.breatheOn = true;
  }

  /** 上游 mode 只有 box / bottomLine / middleLine 三种。/ Upstream mode whitelist. */
  private modeName(): string {
    const mode: string = upString(this.props.mode, 'box');
    if (mode === 'bottomLine' || mode === 'middleLine') {
      return mode;
    }
    return 'box';
  }

  private maxLength(): number {
    const parsed: number = Math.floor(upMessageInputNumber(this.props.maxlength, 4));
    return parsed <= 0 ? 4 : Math.min(parsed, 100);
  }

  private clipped(value: string): string {
    const maximum: number = this.maxLength();
    return value.length > maximum ? value.slice(0, maximum) : value;
  }

  /** 上游 change/finish 语义：每次输入回传，满位再回传一次 finish。/ Upstream emit order. */
  private setValue(value: string): void {
    const next: string = this.clipped(upMessageInputDigits(value));
    this.innerValue = next;
    const event: UPMessageInputChangeEvent = { value: next };
    this.props.onChange?.(event);
    if (next.length >= this.maxLength()) {
      if (this.finishedValue !== next) {
        this.finishedValue = next;
        this.props.onFinish?.(event);
      }
      return;
    }
    this.finishedValue = '';
  }

  private cellSize(): number {
    return Math.max(1, UPUnit.parse(this.props.width, 375, 40));
  }

  private codeFontSize(): number {
    const style: UPStyleResult = UPStyle.parse(this.props.customStyle);
    return Math.max(1, style.fontSize ?? UPUnit.parse(this.props.fontSize, 375, 30));
  }

  private activeColorValue(): string {
    return UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#2979ff');
  }

  private inactiveColorValue(): string {
    return UPColor.parse(this.props.inactiveColor, UP_DEFAULT_THEME, UPColor.neutral('content', '#606266'));
  }

  private lineThickness(): number {
    return upBoolean(this.props.bold, false) ? 4 : 2;
  }

  /** 上游 activeColor 只作用于当前待输入格。/ Only the pending cell uses activeColor. */
  private isActiveCell(index: number): boolean {
    return this.innerValue.length === index;
  }

  private cellColor(index: number): string {
    return this.isActiveCell(index) ? this.activeColorValue() : this.inactiveColorValue();
  }

  /** 呼吸态仅在 breathe 且当前格待输入时生效。/ Breathing halo mirrors upstream. */
  private cellOpacity(index: number): number {
    if (!upBoolean(this.props.breathe, true) || !this.isActiveCell(index)) {
      return 1;
    }
    return this.breatheOn ? 1 : 0.2;
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
    return upBoolean(this.props.dotFill, false) ? '●' : this.innerValue.charAt(index);
  }

  private contentMargin(): UPEdgeValues {
    const style: UPStyleResult = UPStyle.parse(this.props.customStyle);
    return style.margin ?? UPUnit.parseEdges(0, 375);
  }

  @Builder
  private cell(index: number) {
    Stack({ alignContent: Alignment.Center }) {
      if (this.modeName() === 'middleLine' && this.cellValue(index).length === 0) {
        Column()
          .width('60%')
          .height(this.lineThickness())
          .backgroundColor(this.cellColor(index))
          .borderRadius(this.lineThickness() / 2)
      }
      Text(this.cellValue(index))
        .fontSize(this.codeFontSize())
        .fontColor(this.inactiveColorValue())
        .fontWeight(upBoolean(this.props.bold, false) ? FontWeight.Bold : FontWeight.Normal)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height('100%')
      if (this.modeName() === 'bottomLine') {
        Column()
          .width('100%')
          .height(this.lineThickness())
          .backgroundColor(this.cellColor(index))
          .borderRadius(this.lineThickness() / 2)
          .alignSelf(ItemAlign.End)
      }
    }
    .width(this.cellSize())
    .height(this.cellSize())
    .margin({ left: 5, right: 5 })
    .borderWidth(this.modeName() === 'box' ? this.lineThickness() / 2 : 0)
    .borderColor(this.cellColor(index))
    .borderRadius(this.modeName() === 'box' ? 6 : 0)
    .opacity(this.cellOpacity(index))
    .animation({ duration: UP_MESSAGE_INPUT_BREATHE_DURATION, curve: Curve.EaseInOut })
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
      Row() {
        ForEach(this.cellIndexes(), (index: number) => {
          this.cell(index)
        }, (index: number): string => String(index))
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      this.hiddenInput()
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(this.cellSize())
    .margin(this.contentMargin())
    .id('up-message-input')
  }
}
