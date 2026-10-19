import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import {
  UPTriggerInputProps,
  UPTriggerInputStyle,
  UP_TRIGGER_BORDER_COLOR,
  UP_TRIGGER_DEFAULT_BORDER,
  UP_TRIGGER_HEIGHT,
  UP_TRIGGER_PADDING,
  UP_TRIGGER_PLACEHOLDER,
  UP_TRIGGER_PLACEHOLDER_COLOR,
  upTriggerBorderSupported,
  upTriggerBorderWidth,
  upTriggerBottomOnly,
  upTriggerFormat,
  upTriggerInputStyle,
  upTriggerRadius,
  upTriggerTextAlign
} from '../internal/UPTriggerInput';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPDatePickerChangeEvent { date: string; year: number; month: number; day: number; }
export interface UPDatePickerOptions {
  year?: number; month?: number; day?: number; selectedDate?: string; visible?: boolean; minYear?: number; maxYear?: number; title?: string;
  hasInput?: UPRawValue; inputBorder?: UPRawValue; inputProps?: UPTriggerInputProps; placeholder?: UPRawValue;
  disabled?: UPRawValue; disabledColor?: UPRawValue; format?: UPRawValue;
  customStyle?: UPStyleInput; diagnostics?: UPCompatibilityDiagnostics;
  onSelect?: (event: UPDatePickerChangeEvent) => void; onConfirm?: (event: UPDatePickerChangeEvent) => void; onCancel?: () => void;
  onTriggerClick?: () => void;
  onChange?: (event: UPDatePickerChangeEvent) => void; onInput?: (value: string) => void;
  onModelValueChange?: (value: string) => void; onClose?: () => void; onClosed?: () => void;
  triggerBuilder?: UPBuilder;
  toolbarRightBuilder?: UPBuilder;
  toolbarBottomBuilder?: UPBuilder;
}
export class UPDatePickerProps {
  year: number = -1; month: number = -1; day: number = -1; selectedDate: string = ''; visible: boolean = false; minYear: number = 1900; maxYear: number = 2999;
  title: string = '选择日期';
  hasInput: UPRawValue = false; inputBorder: UPRawValue = UP_TRIGGER_DEFAULT_BORDER; inputProps?: UPTriggerInputProps;
  placeholder: UPRawValue = UP_TRIGGER_PLACEHOLDER; disabled: UPRawValue = false; disabledColor: UPRawValue = ''; format: UPRawValue = '';
  customStyle: UPStyleInput = undefined; diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  onSelect?: (event: UPDatePickerChangeEvent) => void; onConfirm?: (event: UPDatePickerChangeEvent) => void; onCancel?: () => void;
  onTriggerClick?: () => void;
  onChange?: (event: UPDatePickerChangeEvent) => void; onInput?: (value: string) => void;
  onModelValueChange?: (value: string) => void; onClose?: () => void; onClosed?: () => void;
  triggerBuilder?: UPBuilder;
  toolbarRightBuilder?: UPBuilder;
  toolbarBottomBuilder?: UPBuilder;
  constructor(options?: UPDatePickerOptions) {
    if (options === undefined) return;
    this.year = options.year ?? this.year; this.month = options.month ?? this.month; this.day = options.day ?? this.day;
    this.selectedDate = options.selectedDate ?? this.selectedDate;
    this.visible = options.visible ?? this.visible; this.minYear = options.minYear ?? this.minYear; this.maxYear = options.maxYear ?? this.maxYear;
    this.title = options.title ?? this.title;
    this.hasInput = options.hasInput ?? this.hasInput; this.inputBorder = options.inputBorder ?? this.inputBorder;
    this.inputProps = options.inputProps; this.placeholder = options.placeholder ?? this.placeholder;
    this.disabled = options.disabled ?? this.disabled; this.disabledColor = options.disabledColor ?? this.disabledColor;
    this.format = options.format ?? this.format;
    this.customStyle = options.customStyle; this.diagnostics = options.diagnostics ?? this.diagnostics;
    this.onSelect = options.onSelect; this.onConfirm = options.onConfirm; this.onCancel = options.onCancel;
    this.onTriggerClick = options.onTriggerClick;
    this.onChange = options.onChange; this.onInput = options.onInput;
    this.onModelValueChange = options.onModelValueChange;
    this.onClose = options.onClose; this.onClosed = options.onClosed;
    this.triggerBuilder = options.triggerBuilder;
    this.toolbarRightBuilder = options.toolbarRightBuilder;
    this.toolbarBottomBuilder = options.toolbarBottomBuilder;
  }
}

@Component
export struct UPDatePicker {
  @Prop props: UPDatePickerProps = new UPDatePickerProps();
  @State private selectedYear: number = 2026; @State private selectedMonth: number = 1; @State private selectedDay: number = 1;
  aboutToAppear(): void {
    const now: Date = new Date();
    const dateParts: Array<string> = this.props.selectedDate.split('-');
    const parsedYear: number = dateParts.length === 3 ? Number(dateParts[0]) : 0;
    const parsedMonth: number = dateParts.length === 3 ? Number(dateParts[1]) : 0;
    const parsedDay: number = dateParts.length === 3 ? Number(dateParts[2]) : 0;
    this.selectedYear = Math.max(this.props.minYear, Math.min(this.props.maxYear, this.props.year > 0 ? this.props.year : parsedYear > 0 ? parsedYear : now.getFullYear()));
    this.selectedMonth = Math.max(1, Math.min(12, this.props.month > 0 ? this.props.month : parsedMonth > 0 ? parsedMonth : now.getMonth() + 1));
    this.selectedDay = Math.max(1, Math.min(this.daysInMonth(), this.props.day > 0 ? this.props.day : parsedDay > 0 ? parsedDay : now.getDate()));
    this.reportCompatibility();
  }
  private daysInMonth(): number { return new Date(this.selectedYear, this.selectedMonth, 0).getDate(); }
  /** 上游 inputPropsInner。/ Mirrors the upstream inputPropsInner. */
  private triggerStyle(): UPTriggerInputStyle {
    return upTriggerInputStyle(this.props.inputBorder, this.props.placeholder,
      upBoolean(this.props.disabled, false), this.props.disabledColor, this.props.inputProps);
  }
  /** 上游 format：为空时按 `YYYY-MM-DD`。/ Mirrors the upstream format fallback. */
  private triggerLabel(): string {
    const format: string = upString(this.props.format, '');
    const pattern: string = format.length > 0 ? format : 'YYYY-MM-DD';
    return upTriggerFormat(pattern, this.selectedYear, this.selectedMonth, this.selectedDay, 0, 0, 0);
  }
  private openByTrigger(): void {
    if (upBoolean(this.props.disabled, false)) return;
    this.props.onTriggerClick?.();
  }
  private reportCompatibility(): void {
    if (!upTriggerBorderSupported(upString(this.props.inputBorder, UP_TRIGGER_DEFAULT_BORDER))) {
      this.props.diagnostics.report('UPDatePicker', 'inputBorder', this.props.inputBorder,
        'inputBorder falls back to surround because only surround, bottom and none are modelled');
    }
    if (this.props.inputProps !== undefined) {
      this.props.diagnostics.report('UPDatePicker', 'inputProps', '',
        'inputProps only forwards the modelled trigger fields: border, placeholder, disabled, disabledColor, fontSize, color, inputAlign and shape');
    }
  }

  @Builder
  private triggerRow() {
    Row() {
      Text(this.triggerLabel())
        .fontSize(this.triggerStyle().fontSize)
        .fontColor(UPColor.parse(this.triggerStyle().color, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133')))
        .textAlign(upTriggerTextAlign(this.triggerStyle().inputAlign))
        .layoutWeight(1)
    }
    .width('100%')
    .height(UP_TRIGGER_HEIGHT)
    .padding({ left: UP_TRIGGER_PADDING, right: UP_TRIGGER_PADDING })
    .backgroundColor(this.triggerStyle().disabled ? this.triggerStyle().disabledColor : '#ffffff')
    .borderRadius(upTriggerRadius(this.triggerStyle().shape, UP_TRIGGER_HEIGHT))
    .border(upTriggerBottomOnly(this.triggerStyle().border)
      ? { width: { bottom: upTriggerBorderWidth(this.triggerStyle().border) }, color: UP_TRIGGER_BORDER_COLOR }
      : { width: upTriggerBorderWidth(this.triggerStyle().border), color: UP_TRIGGER_BORDER_COLOR })
    .onClick((): void => this.openByTrigger())
  }
  private event(): UPDatePickerChangeEvent {
    return { date: `${this.selectedYear}-${String(this.selectedMonth).padStart(2, '0')}-${String(this.selectedDay).padStart(2, '0')}`, year: this.selectedYear, month: this.selectedMonth, day: this.selectedDay };
  }
  private chooseYear(value: number): void { this.selectedYear = value; this.selectedDay = Math.min(this.selectedDay, this.daysInMonth()); this.publishSelect(); }
  private chooseMonth(value: number): void { this.selectedMonth = value; this.selectedDay = Math.min(this.selectedDay, this.daysInMonth()); this.publishSelect(); }
  private chooseDay(value: number): void { this.selectedDay = value; this.publishSelect(); }
  /** 上游滚动即抛 change；select 是本端别名。/ Upstream emits change while scrolling. */
  private publishSelect(): void {
    const event: UPDatePickerChangeEvent = this.event();
    this.props.onSelect?.(event);
    this.props.onChange?.(event);
  }
  /** 上游确认时抛 confirm、input 与 update:modelValue。/ Upstream confirm also emits input and the model value. */
  private publishConfirm(): void {
    const event: UPDatePickerChangeEvent = this.event();
    this.props.onConfirm?.(event);
    this.props.onInput?.(event.date);
    this.props.onModelValueChange?.(event.date);
    this.dismiss();
  }
  /** ArkUI 无退场动画，close 与 closed 同帧触发。/ close and closed fire together on ArkUI. */
  private dismiss(): void {
    this.props.onClose?.();
    this.props.onClosed?.();
  }
  private cancel(): void {
    this.props.onCancel?.();
    this.dismiss();
  }
  private years(): Array<number> { const values: Array<number> = []; for (let year = this.props.minYear; year <= this.props.maxYear; year++) values.push(year); return values; }
  private months(): Array<number> { return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]; }
  private days(): Array<number> { const values: Array<number> = []; for (let day = 1; day <= this.daysInMonth(); day++) values.push(day); return values; }
  @Builder
  private triggerRegion() {
    UPSlotRegion({ contentBuilder: this.props.triggerBuilder })
  }

  @Builder
  private toolbarRightRegion() {
    UPSlotRegion({ contentBuilder: this.props.toolbarRightBuilder })
  }

  @Builder
  private toolbarBottomRegion() {
    UPSlotRegion({ contentBuilder: this.props.toolbarBottomBuilder })
  }

  build() {
    Column({ space: 10 }) {
      if (upBoolean(this.props.hasInput, false) && this.props.triggerBuilder !== undefined) {
        this.triggerRegion()
      } else if (upBoolean(this.props.hasInput, false)) {
        this.triggerRow()
      }
      Row() {
        Text(this.props.title).fontSize(15).fontWeight(FontWeight.Medium).layoutWeight(1)
        if (this.props.toolbarRightBuilder !== undefined) {
          this.toolbarRightRegion()
        } else {
          Text('取消').fontSize(13).fontColor(UPColor.adaptive('#909399', 'tips-color')).onClick((): void => this.cancel())
        }
      }.width('100%')
      this.toolbarBottomRegion()
      Row({ space: 6 }) {
        Scroll() { Column() { ForEach(this.years(), (year: number) => Text(String(year)).fontSize(14).padding(8).fontColor(year === this.selectedYear ? '#2979ff' : '#303133').onClick((): void => this.chooseYear(year))) } }.height(180).layoutWeight(1)
        Scroll() { Column() { ForEach(this.months(), (month: number) => Text(String(month) + '月').fontSize(14).padding(8).fontColor(month === this.selectedMonth ? '#2979ff' : '#303133').onClick((): void => this.chooseMonth(month))) } }.height(180).layoutWeight(1)
        Scroll() { Column() { ForEach(this.days(), (day: number) => Text(String(day) + '日').fontSize(14).padding(8).fontColor(day === this.selectedDay ? '#2979ff' : '#303133').onClick((): void => this.chooseDay(day))) } }.height(180).layoutWeight(1)
      }.width('100%')
      Text('确定').fontSize(14).fontColor('#2979ff').width('100%').textAlign(TextAlign.Center).padding(8).onClick((): void => this.publishConfirm())
    }.padding(12).backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color')).borderRadius(8).width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
