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
  upTriggerBorderSupported,
  upTriggerBorderWidth,
  upTriggerBottomOnly,
  upTriggerFormat,
  upTriggerInputStyle,
  upTriggerRadius,
  upTriggerTextAlign
} from '../internal/UPTriggerInput';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPTimePickerChangeEvent { time: string; hour: number; minute: number; second: number; }
export interface UPTimePickerOptions {
  hour?: number; minute?: number; second?: number; selectedTime?: string; minuteStep?: number; secondStep?: number; visible?: boolean; title?: string;
  hasInput?: UPRawValue; inputBorder?: UPRawValue; inputProps?: UPTriggerInputProps; placeholder?: UPRawValue;
  disabled?: UPRawValue; disabledColor?: UPRawValue; format?: UPRawValue;
  customStyle?: UPStyleInput; diagnostics?: UPCompatibilityDiagnostics;
  onSelect?: (event: UPTimePickerChangeEvent) => void; onConfirm?: (event: UPTimePickerChangeEvent) => void; onCancel?: () => void;
  onTriggerClick?: () => void;
  onChange?: (event: UPTimePickerChangeEvent) => void; onInput?: (value: string) => void;
  onModelValueChange?: (value: string) => void; onClose?: () => void; onClosed?: () => void;
  triggerBuilder?: UPBuilder;
  toolbarRightBuilder?: UPBuilder;
  toolbarBottomBuilder?: UPBuilder;
}
export class UPTimePickerProps {
  hour: number = 0; minute: number = 0; second: number = 0; selectedTime: string = ''; minuteStep: number = 1; secondStep: number = 1; visible: boolean = false;
  title: string = '选择时间';
  hasInput: UPRawValue = false; inputBorder: UPRawValue = UP_TRIGGER_DEFAULT_BORDER; inputProps?: UPTriggerInputProps;
  placeholder: UPRawValue = UP_TRIGGER_PLACEHOLDER; disabled: UPRawValue = false; disabledColor: UPRawValue = ''; format: UPRawValue = '';
  customStyle: UPStyleInput = undefined; diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  onSelect?: (event: UPTimePickerChangeEvent) => void; onConfirm?: (event: UPTimePickerChangeEvent) => void; onCancel?: () => void;
  onTriggerClick?: () => void;
  onChange?: (event: UPTimePickerChangeEvent) => void; onInput?: (value: string) => void;
  onModelValueChange?: (value: string) => void; onClose?: () => void; onClosed?: () => void;
  triggerBuilder?: UPBuilder;
  toolbarRightBuilder?: UPBuilder;
  toolbarBottomBuilder?: UPBuilder;
  constructor(options?: UPTimePickerOptions) {
    if (options === undefined) return;
    this.hour = options.hour ?? this.hour; this.minute = options.minute ?? this.minute; this.second = options.second ?? this.second;
    this.selectedTime = options.selectedTime ?? this.selectedTime;
    this.minuteStep = options.minuteStep ?? this.minuteStep; this.secondStep = options.secondStep ?? this.secondStep; this.visible = options.visible ?? this.visible;
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
export struct UPTimePicker {
  @Prop props: UPTimePickerProps = new UPTimePickerProps();
  @State private selectedHour: number = 0; @State private selectedMinute: number = 0; @State private selectedSecond: number = 0;
  aboutToAppear(): void {
    const timeParts: Array<string> = this.props.selectedTime.split(':');
    const parsedHour: number = timeParts.length >= 2 ? Number(timeParts[0]) : -1;
    const parsedMinute: number = timeParts.length >= 2 ? Number(timeParts[1]) : -1;
    const parsedSecond: number = timeParts.length >= 3 ? Number(timeParts[2]) : -1;
    this.selectedHour = Math.max(0, Math.min(23, this.props.hour > 0 ? this.props.hour : parsedHour >= 0 ? parsedHour : 0));
    this.selectedMinute = Math.max(0, Math.min(59, this.props.minute > 0 ? this.props.minute : parsedMinute >= 0 ? parsedMinute : 0));
    this.selectedSecond = Math.max(0, Math.min(59, this.props.second > 0 ? this.props.second : parsedSecond >= 0 ? parsedSecond : 0));
    this.reportCompatibility();
  }
  /** 上游 inputPropsInner。/ Mirrors the upstream inputPropsInner. */
  private triggerStyle(): UPTriggerInputStyle {
    return upTriggerInputStyle(this.props.inputBorder, this.props.placeholder,
      upBoolean(this.props.disabled, false), this.props.disabledColor, this.props.inputProps);
  }
  /** 上游 format：为空时按 `HH:mm:ss`。/ Mirrors the upstream format fallback. */
  private triggerLabel(): string {
    const format: string = upString(this.props.format, '');
    const pattern: string = format.length > 0 ? format : 'HH:mm:ss';
    return upTriggerFormat(pattern, 0, 1, 1, this.selectedHour, this.selectedMinute, this.selectedSecond);
  }
  private openByTrigger(): void {
    if (upBoolean(this.props.disabled, false)) return;
    this.props.onTriggerClick?.();
  }
  private reportCompatibility(): void {
    if (!upTriggerBorderSupported(upString(this.props.inputBorder, UP_TRIGGER_DEFAULT_BORDER))) {
      this.props.diagnostics.report('UPTimePicker', 'inputBorder', this.props.inputBorder,
        'inputBorder falls back to surround because only surround, bottom and none are modelled');
    }
    if (this.props.inputProps !== undefined) {
      this.props.diagnostics.report('UPTimePicker', 'inputProps', '',
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
  private event(): UPTimePickerChangeEvent { return { time: `${String(this.selectedHour).padStart(2, '0')}:${String(this.selectedMinute).padStart(2, '0')}:${String(this.selectedSecond).padStart(2, '0')}`, hour: this.selectedHour, minute: this.selectedMinute, second: this.selectedSecond }; }
  /** 上游滚动即抛 change；select 是本端别名。/ Upstream emits change while scrolling. */
  private publishSelect(): void {
    const event: UPTimePickerChangeEvent = this.event();
    this.props.onSelect?.(event);
    this.props.onChange?.(event);
  }
  /** 上游确认时抛 confirm、input 与 update:modelValue。/ Upstream confirm also emits input and the model value. */
  private publishConfirm(): void {
    const event: UPTimePickerChangeEvent = this.event();
    this.props.onConfirm?.(event);
    this.props.onInput?.(event.time);
    this.props.onModelValueChange?.(event.time);
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
  private values(max: number, step: number): Array<number> { const values: Array<number> = []; const safeStep: number = Math.max(1, Math.floor(step)); for (let value = 0; value <= max; value += safeStep) values.push(value); return values; }
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
        Scroll() { Column() { ForEach(this.values(23, 1), (hour: number) => Text(String(hour).padStart(2, '0')).fontSize(14).padding(8).fontColor(hour === this.selectedHour ? '#2979ff' : '#303133').onClick((): void => { this.selectedHour = hour; this.publishSelect(); })) } }.height(180).layoutWeight(1)
        Scroll() { Column() { ForEach(this.values(59, this.props.minuteStep), (minute: number) => Text(String(minute).padStart(2, '0')).fontSize(14).padding(8).fontColor(minute === this.selectedMinute ? '#2979ff' : '#303133').onClick((): void => { this.selectedMinute = minute; this.publishSelect(); })) } }.height(180).layoutWeight(1)
        Scroll() { Column() { ForEach(this.values(59, this.props.secondStep), (second: number) => Text(String(second).padStart(2, '0')).fontSize(14).padding(8).fontColor(second === this.selectedSecond ? '#2979ff' : '#303133').onClick((): void => { this.selectedSecond = second; this.publishSelect(); })) } }.height(180).layoutWeight(1)
      }.width('100%')
      Text('确定').fontSize(14).fontColor('#2979ff').width('100%').textAlign(TextAlign.Center).padding(8).onClick((): void => this.publishConfirm())
    }.padding(12).backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color')).borderRadius(8).width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
