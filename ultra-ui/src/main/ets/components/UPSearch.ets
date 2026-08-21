import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPEdgeValues, UPUnit } from '../core/UPUnit';
import { UPIcon, UPIconProps } from './UPIcon';

export interface UPSearchChangeEvent {
  value: string;
}

export interface UPSearchConfirmEvent {
  value: string;
  action: string;
}

export interface UPSearchOptions {
  modelValue?: UPRawValue;
  value?: UPRawValue;
  shape?: UPRawValue;
  bgColor?: UPRawValue;
  placeholder?: UPRawValue;
  clearabled?: UPRawValue;
  onlyClearableOnFocused?: UPRawValue;
  focus?: UPRawValue;
  showAction?: UPRawValue;
  actionText?: UPRawValue;
  label?: UPRawValue;
  inputAlign?: UPRawValue;
  disabled?: UPRawValue;
  animation?: UPRawValue;
  borderColor?: UPRawValue;
  searchIconColor?: UPRawValue;
  searchIconSize?: UPRawValue;
  color?: UPRawValue;
  placeholderColor?: UPRawValue;
  searchIcon?: UPRawValue;
  margin?: UPRawValue;
  iconPosition?: UPRawValue;
  maxlength?: UPRawValue;
  height?: UPRawValue;
  adjustPosition?: UPRawValue;
  autoBlur?: UPRawValue;
  inputStyle?: UPStyleInput;
  actionStyle?: UPStyleInput;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onInput?: (event: UPSearchChangeEvent) => void;
  onChange?: (event: UPSearchChangeEvent) => void;
  onClear?: () => void;
  onSearch?: (event: UPSearchConfirmEvent) => void;
  onCustom?: (event: UPSearchConfirmEvent) => void;
  onFocus?: (event: UPSearchChangeEvent) => void;
  onBlur?: (event: UPSearchChangeEvent) => void;
  onClick?: () => void;
  onClickIcon?: (event: UPSearchConfirmEvent) => void;
}

export class UPSearchProps {
  modelValue: UPRawValue = undefined;
  value: UPRawValue = '';
  shape: UPRawValue = 'round';
  bgColor: UPRawValue = '';
  placeholder: UPRawValue = '请输入关键词';
  clearabled: UPRawValue = true;
  onlyClearableOnFocused: UPRawValue = false;
  focus: UPRawValue = false;
  showAction: UPRawValue = true;
  actionText: UPRawValue = '搜索';
  label: UPRawValue = '';
  inputAlign: UPRawValue = 'left';
  disabled: UPRawValue = false;
  animation: UPRawValue = false;
  borderColor: UPRawValue = 'transparent';
  searchIconColor: UPRawValue = '#909399';
  searchIconSize: UPRawValue = 22;
  color: UPRawValue = '';
  placeholderColor: UPRawValue = '';
  searchIcon: UPRawValue = 'search';
  margin: UPRawValue = 0;
  iconPosition: UPRawValue = 'left';
  maxlength: UPRawValue = '-1';
  height: UPRawValue = 32;
  adjustPosition: UPRawValue = true;
  autoBlur: UPRawValue = true;
  inputStyle: UPStyleInput = undefined;
  actionStyle: UPStyleInput = undefined;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  onInput?: (event: UPSearchChangeEvent) => void;
  onChange?: (event: UPSearchChangeEvent) => void;
  onClear?: () => void;
  onSearch?: (event: UPSearchConfirmEvent) => void;
  onCustom?: (event: UPSearchConfirmEvent) => void;
  onFocus?: (event: UPSearchChangeEvent) => void;
  onBlur?: (event: UPSearchChangeEvent) => void;
  onClick?: () => void;
  onClickIcon?: (event: UPSearchConfirmEvent) => void;

  constructor(options?: UPSearchOptions) {
    if (options === undefined) {
      return;
    }
    this.modelValue = options.modelValue ?? this.modelValue;
    this.value = options.value ?? this.value;
    this.shape = options.shape ?? this.shape;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.placeholder = options.placeholder ?? this.placeholder;
    this.clearabled = options.clearabled ?? this.clearabled;
    this.onlyClearableOnFocused = options.onlyClearableOnFocused ?? this.onlyClearableOnFocused;
    this.focus = options.focus ?? this.focus;
    this.showAction = options.showAction ?? this.showAction;
    this.actionText = options.actionText ?? this.actionText;
    this.label = options.label ?? this.label;
    this.inputAlign = options.inputAlign ?? this.inputAlign;
    this.disabled = options.disabled ?? this.disabled;
    this.animation = options.animation ?? this.animation;
    this.borderColor = options.borderColor ?? this.borderColor;
    this.searchIconColor = options.searchIconColor ?? this.searchIconColor;
    this.searchIconSize = options.searchIconSize ?? this.searchIconSize;
    this.color = options.color ?? this.color;
    this.placeholderColor = options.placeholderColor ?? this.placeholderColor;
    this.searchIcon = options.searchIcon ?? this.searchIcon;
    this.margin = options.margin ?? this.margin;
    this.iconPosition = options.iconPosition ?? this.iconPosition;
    this.maxlength = options.maxlength ?? this.maxlength;
    this.height = options.height ?? this.height;
    this.adjustPosition = options.adjustPosition ?? this.adjustPosition;
    this.autoBlur = options.autoBlur ?? this.autoBlur;
    this.inputStyle = options.inputStyle;
    this.actionStyle = options.actionStyle;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onInput = options.onInput;
    this.onChange = options.onChange;
    this.onClear = options.onClear;
    this.onSearch = options.onSearch;
    this.onCustom = options.onCustom;
    this.onFocus = options.onFocus;
    this.onBlur = options.onBlur;
    this.onClick = options.onClick;
    this.onClickIcon = options.onClickIcon;
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
export struct UPSearch {
  @Prop props: UPSearchProps = new UPSearchProps();
  @State private innerValue: string = '';
  @State private focused: boolean = false;

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  aboutToAppear(): void {
    this.innerValue = this.clipped(this.currentValue());
    if (this.props.focus === true) {
      this.focused = true;
    }
    const shape: string = upString(this.props.shape, 'round').toLowerCase();
    if (shape !== 'round' && shape !== 'square') {
      this.diagnostics().report('UPSearch', 'shape', this.props.shape, 'unsupported shape; fallback to round');
    }
    const align: string = upString(this.props.inputAlign, 'left').toLowerCase();
    if (align !== 'left' && align !== 'center' && align !== 'right') {
      this.diagnostics().report('UPSearch', 'inputAlign', this.props.inputAlign, 'unsupported alignment; fallback to left');
    }
    const position: string = upString(this.props.iconPosition, 'left').toLowerCase();
    if (position !== 'left' && position !== 'right') {
      this.diagnostics().report('UPSearch', 'iconPosition', this.props.iconPosition, 'unsupported icon position; fallback to left');
    }
    if (!upBoolean(this.props.adjustPosition, true)) {
      this.diagnostics().report('UPSearch', 'adjustPosition', this.props.adjustPosition, 'keyboard avoidance is managed by the native input container');
    }
  }

  private currentValue(): string {
    return this.props.modelValue === null || this.props.modelValue === undefined ? rawText(this.props.value) : rawText(this.props.modelValue);
  }

  private maxLength(): number {
    const parsed: number = Math.floor(rawNumber(this.props.maxlength, -1));
    return parsed < 0 ? 100000 : Math.max(0, parsed);
  }

  private clipped(value: string): string {
    const maximum: number = this.maxLength();
    return value.length > maximum ? value.slice(0, maximum) : value;
  }

  private setValue(value: string): void {
    const next: string = this.clipped(value);
    this.innerValue = next;
    const event: UPSearchChangeEvent = { value: next };
    this.props.onInput?.(event);
    this.props.onChange?.(event);
  }

  private clearValue(): void {
    if (this.innerValue.length === 0) {
      return;
    }
    this.setValue('');
    this.props.onClear?.();
  }

  private confirm(action: string): void {
    const event: UPSearchConfirmEvent = { value: this.innerValue, action };
    if (action === 'search') {
      this.props.onSearch?.(event);
    } else {
      this.props.onCustom?.(event);
    }
    if (upBoolean(this.props.autoBlur, true)) {
      this.focused = false;
    }
  }

  private textAlignValue(): TextAlign {
    const align: string = upString(this.props.inputAlign, 'left').toLowerCase();
    if (align === 'center') {
      return TextAlign.Center;
    }
    if (align === 'right') {
      return TextAlign.End;
    }
    return TextAlign.Start;
  }

  private shapeName(): string {
    const shape: string = upString(this.props.shape, 'round').toLowerCase();
    return shape === 'square' ? 'square' : 'round';
  }

  private iconPositionName(): string {
    return upString(this.props.iconPosition, 'left').toLowerCase() === 'right' ? 'right' : 'left';
  }

  private searchHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(1, style.height ?? UPUnit.parse(this.props.height, 375, 32));
  }

  private searchWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? '100%';
  }

  private searchPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? { left: 10, right: 10, top: 4, bottom: 4 };
  }

  private searchBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#f5f5f5');
  }

  private searchBorderColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderColor ?? UPColor.parse(this.props.borderColor, UP_DEFAULT_THEME, 'transparent');
  }

  private searchRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderRadius !== undefined) {
      return Math.max(0, style.borderRadius);
    }
    return this.shapeName() === 'round' ? this.searchHeight() / 2 : 4;
  }

  private inputFontSize(): number {
    const style = UPStyle.parse(this.props.inputStyle);
    const custom = UPStyle.parse(this.props.customStyle);
    return Math.max(1, style.fontSize ?? custom.fontSize ?? 14);
  }

  private inputColor(): string {
    const style = UPStyle.parse(this.props.inputStyle);
    const custom = UPStyle.parse(this.props.customStyle);
    if (upBoolean(this.props.disabled, false)) {
      return '#c8c9cc';
    }
    return style.color ?? custom.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#303133');
  }

  private placeholderColorValue(): string {
    return UPColor.parse(this.props.placeholderColor, UP_DEFAULT_THEME, '#909399');
  }

  private searchIconSizeValue(): number {
    return Math.max(0, UPUnit.parse(this.props.searchIconSize, 375, 22));
  }

  private clearVisible(): boolean {
    if (!upBoolean(this.props.clearabled, true) || this.innerValue.length === 0 || upBoolean(this.props.disabled, false)) {
      return false;
    }
    return !upBoolean(this.props.onlyClearableOnFocused, false) || this.focused;
  }

  private actionVisible(): boolean {
    return upBoolean(this.props.showAction, true) && (!upBoolean(this.props.animation, false) || this.focused);
  }

  private marginValue(): object {
    return UPUnit.parseEdges(this.props.margin, 375);
  }

  @Builder
  private searchIconView() {
    if (rawText(this.props.searchIcon).length > 0) {
      UPIcon({ props: new UPIconProps({
        name: rawText(this.props.searchIcon),
        size: this.searchIconSizeValue(),
        color: UPColor.parse(this.props.searchIconColor, UP_DEFAULT_THEME, '#909399'),
        onClick: (): void => {
          this.props.onClickIcon?.({ value: this.innerValue, action: 'icon' });
        }
      }) })
    }
  }

  @Builder
  private clearView() {
    if (this.clearVisible()) {
      Text('×')
        .fontSize(Math.max(12, this.searchHeight() * 0.52))
        .fontColor('#ffffff')
        .width(Math.max(16, this.searchHeight() * 0.58))
        .height(Math.max(16, this.searchHeight() * 0.58))
        .textAlign(TextAlign.Center)
        .backgroundColor('#c0c4cc')
        .borderRadius(Math.max(8, this.searchHeight() * 0.29))
        .onClick((): void => {
          this.clearValue();
        })
    }
  }

  @Builder
  private inputView() {
    TextInput({ text: this.innerValue, placeholder: rawText(this.props.placeholder) })
      .enabled(!upBoolean(this.props.disabled, false))
      .fontSize(this.inputFontSize())
      .fontColor(this.inputColor())
      .placeholderColor(this.placeholderColorValue())
      .maxLength(this.maxLength())
      .backgroundColor('transparent')
      .textAlign(this.textAlignValue())
      .height('100%')
      .layoutWeight(1)
      .onFocus((): void => {
        this.focused = true;
        this.props.onFocus?.({ value: this.innerValue });
      })
      .onBlur((): void => {
        this.focused = false;
        this.props.onBlur?.({ value: this.innerValue });
      })
      .onChange((value: string): void => {
        this.setValue(value);
      })
      .onSubmit((_key: EnterKeyType): void => {
        this.confirm('search');
      })
  }

  @Builder
  private inputContent() {
    Row({ space: 6 }) {
      if (this.iconPositionName() === 'left') {
        this.searchIconView()
      }
      this.inputView()
      this.clearView()
      if (this.iconPositionName() === 'right') {
        this.searchIconView()
      }
    }
    .width('100%')
    .height(this.searchHeight())
    .padding(this.searchPadding())
  }

  @Builder
  private content() {
    Row({ space: 8 }) {
      if (rawText(this.props.label).length > 0) {
        Text(rawText(this.props.label))
          .fontSize(this.inputFontSize())
          .fontColor(this.inputColor())
      }
      Row() {
        this.inputContent()
      }
      .layoutWeight(1)
      .height(this.searchHeight())
      .backgroundColor(this.searchBackground())
      .borderWidth(UPColor.parse(this.props.borderColor, UP_DEFAULT_THEME, 'transparent') === 'transparent' ? 0 : 1)
      .borderColor(this.searchBorderColor())
      .borderRadius(this.searchRadius())
      .onClick((): void => {
        this.props.onClick?.();
      })
      if (this.actionVisible()) {
        Text(rawText(this.props.actionText))
          .fontSize(Math.max(1, UPStyle.parse(this.props.actionStyle).fontSize ?? 14))
          .fontColor(UPStyle.parse(this.props.actionStyle).color ?? '#2979ff')
          .padding(UPStyle.parse(this.props.actionStyle).padding ?? { left: 4, right: 4 })
          .onClick((): void => {
            this.confirm('custom');
          })
      }
    }
    .width(this.searchWidth())
    .margin(this.marginValue())
    .opacity(upBoolean(this.props.disabled, false) ? 0.58 : 1)
    .id('up-search')
  }

  build() {
    this.content()
  }
}
