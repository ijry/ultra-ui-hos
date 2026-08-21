import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';

export interface UPTextClickEvent {
  text: string;
  mode: string;
  href: UPRawValue;
}

export interface UPTextOpenEvent {
  href: string;
  text: string;
}

export interface UPTextCallEvent {
  phone: string;
  text: string;
}

export interface UPTextOptions {
  type?: UPRawValue;
  show?: UPRawValue;
  text?: UPRawValue;
  prefixIcon?: UPRawValue;
  suffixIcon?: UPRawValue;
  mode?: UPRawValue;
  href?: UPRawValue;
  format?: UPRawValue;
  call?: UPRawValue;
  openType?: UPRawValue;
  bold?: UPRawValue;
  block?: UPRawValue;
  lines?: UPRawValue;
  color?: UPRawValue;
  size?: UPRawValue;
  iconStyle?: UPStyleInput;
  decoration?: UPRawValue;
  margin?: UPRawValue;
  lineHeight?: UPRawValue;
  align?: UPRawValue;
  wordWrap?: UPRawValue;
  flex1?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (event: UPTextClickEvent) => void;
  onOpen?: (event: UPTextOpenEvent) => void;
  onCall?: (event: UPTextCallEvent) => void;
}

export class UPTextProps {
  type: UPRawValue = '';
  show: UPRawValue = true;
  text: UPRawValue = '';
  prefixIcon: UPRawValue = '';
  suffixIcon: UPRawValue = '';
  mode: UPRawValue = 'text';
  href: UPRawValue = '';
  format: UPRawValue = '';
  call: UPRawValue = false;
  openType: UPRawValue = '';
  bold: UPRawValue = false;
  block: UPRawValue = false;
  lines: UPRawValue = 1;
  color: UPRawValue = '';
  size: UPRawValue = 15;
  iconStyle: UPStyleInput = undefined;
  decoration: UPRawValue = 'none';
  margin: UPRawValue = 0;
  lineHeight: UPRawValue = 'normal';
  align: UPRawValue = 'left';
  wordWrap: UPRawValue = 'normal';
  flex1: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (event: UPTextClickEvent) => void;
  onOpen?: (event: UPTextOpenEvent) => void;
  onCall?: (event: UPTextCallEvent) => void;

  constructor(options?: UPTextOptions) {
    if (options === undefined) {
      return;
    }
    this.type = options.type ?? this.type;
    this.show = options.show ?? this.show;
    this.text = options.text ?? this.text;
    this.prefixIcon = options.prefixIcon ?? this.prefixIcon;
    this.suffixIcon = options.suffixIcon ?? this.suffixIcon;
    this.mode = options.mode ?? this.mode;
    this.href = options.href ?? this.href;
    this.format = options.format ?? this.format;
    this.call = options.call ?? this.call;
    this.openType = options.openType ?? this.openType;
    this.bold = options.bold ?? this.bold;
    this.block = options.block ?? this.block;
    this.lines = options.lines ?? this.lines;
    this.color = options.color ?? this.color;
    this.size = options.size ?? this.size;
    this.iconStyle = options.iconStyle;
    this.decoration = options.decoration ?? this.decoration;
    this.margin = options.margin ?? this.margin;
    this.lineHeight = options.lineHeight ?? this.lineHeight;
    this.align = options.align ?? this.align;
    this.wordWrap = options.wordWrap ?? this.wordWrap;
    this.flex1 = options.flex1 ?? this.flex1;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
    this.onOpen = options.onOpen;
    this.onCall = options.onCall;
  }
}

function textValue(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

function numberValue(value: UPRawValue, fallback: number): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string' && Number.isFinite(Number(value.trim()))) {
    return Number(value.trim());
  }
  return fallback;
}

function safeMode(value: string, diagnostics: UPCompatibilityDiagnostics): string {
  const mode: string = value.toLowerCase();
  if (mode === 'text' || mode === 'price' || mode === 'phone' || mode === 'name' || mode === 'date' || mode === 'link') {
    return mode;
  }
  if (mode.length > 0) {
    diagnostics.report('UPText', 'mode', value, 'unsupported text mode; fallback to text');
  }
  return 'text';
}

function textDecoration(value: string): TextDecorationType {
  if (value.toLowerCase() === 'underline') {
    return TextDecorationType.Underline;
  }
  if (value.toLowerCase() === 'line-through') {
    return TextDecorationType.LineThrough;
  }
  return TextDecorationType.None;
}

function textAlign(value: string): TextAlign {
  if (value.toLowerCase() === 'center') {
    return TextAlign.Center;
  }
  if (value.toLowerCase() === 'right') {
    return TextAlign.End;
  }
  return TextAlign.Start;
}

function wordBreak(value: string): WordBreak {
  if (value.toLowerCase() === 'break-word') {
    return WordBreak.BREAK_WORD;
  }
  if (value.toLowerCase() === 'anywhere') {
    return WordBreak.BREAK_ALL;
  }
  return WordBreak.NORMAL;
}

function formatText(value: string, mode: string, format: UPRawValue): string {
  if (mode === 'price') {
    const amount: number = numberValue(value, Number.NaN);
    if (Number.isFinite(amount)) {
      return amount.toFixed(2);
    }
  }
  if (mode === 'phone' && value.length >= 8) {
    return value.slice(0, 3) + '****' + value.slice(value.length - 4);
  }
  const template: string = textValue(format);
  if (template.length > 0 && template.includes('{value}')) {
    return template.replace('{value}', value);
  }
  return value;
}

@Component
export struct UPText {
  @Prop props: UPTextProps = new UPTextProps();

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private mode(): string {
    return safeMode(textValue(this.props.mode), this.diagnostics());
  }

  private label(): string {
    return formatText(textValue(this.props.text), this.mode(), this.props.format);
  }

  private color(): string {
    const style = UPStyle.parse(this.props.customStyle);
    const requested: string = textValue(this.props.color);
    if (style.color !== undefined) {
      return style.color;
    }
    if (requested.length > 0) {
      return UPColor.parse(requested, UP_DEFAULT_THEME, UP_DEFAULT_THEME.content);
    }
    if (this.mode() === 'link') {
      return UP_DEFAULT_THEME.primary;
    }
    return UP_DEFAULT_THEME.content;
  }

  private fontSize(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.fontSize ?? UPUnit.parse(this.props.size, 375, 15);
  }

  private lineCount(): number {
    const count: number = Math.floor(numberValue(this.props.lines, 1));
    return count <= 0 ? 1 : count;
  }

  private click(): void {
    const raw: string = textValue(this.props.text);
    const mode: string = this.mode();
    const event: UPTextClickEvent = { text: raw, mode, href: this.props.href };
    this.props.onClick?.(event);
    if (mode === 'link' && textValue(this.props.href).length > 0) {
      this.props.onOpen?.({ href: textValue(this.props.href), text: raw });
    }
    if (mode === 'phone' && upBoolean(this.props.call, false)) {
      this.props.onCall?.({ phone: raw, text: raw });
    }
  }

  @Builder
  private icon(name: string) {
    if (name.length > 0) {
      UPIcon({ props: new UPIconProps({ name, size: Math.max(12, this.fontSize()), color: this.color(), customStyle: this.props.iconStyle }) })
    }
  }

  @Builder
  private content() {
    if (!upBoolean(this.props.show, true)) {
      Row().width(0).height(0)
    } else {
      Row({ space: 4 }) {
        this.icon(textValue(this.props.prefixIcon))
        Text(this.label())
          .fontSize(this.fontSize())
          .fontColor(this.color())
          .fontWeight(upBoolean(this.props.bold, false) ? FontWeight.Bold : FontWeight.Normal)
          .textAlign(textAlign(textValue(this.props.align)))
          .maxLines(this.lineCount())
          .wordBreak(wordBreak(textValue(this.props.wordWrap)))
          .decoration({ type: textDecoration(textValue(this.props.decoration)), color: this.color() })
          .lineHeight(UPUnit.parseOptional(this.props.lineHeight, 375))
          .id('up-text')
        this.icon(textValue(this.props.suffixIcon))
      }
      .width(UPStyle.parse(this.props.customStyle).width ?? (upBoolean(this.props.block, false) || upBoolean(this.props.flex1, false) ? '100%' : 'auto'))
      .margin(UPStyle.parse(this.props.customStyle).margin ?? UPUnit.parseEdges(this.props.margin, 375, 0))
      .onClick((): void => {
        this.click();
      })
    }
  }

  aboutToAppear(): void {
    if (textValue(this.props.openType).length > 0) {
      this.diagnostics().report('UPText', 'openType', this.props.openType, 'mini-program openType is not available; callback ownership remains with caller');
    }
  }

  build() {
    this.content()
  }
}
