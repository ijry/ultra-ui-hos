import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPCalendar, UPCalendarProps, UPCalendarSelectEvent, UP_CALENDAR_FORBID_TOAST } from './UPCalendar';
import { UPI18n, upWeekText } from '../core/UPI18n';

/** 单个日期格的渲染模型。/ Render model of one day cell. */
export interface UPCalendarStripDay {
  day: number;
  date: string;
  week: number;
  disabled: boolean;
  selected: boolean;
  today: boolean;
}

/** 日期变更事件载荷。/ Payload of the date change events. */
export interface UPCalendarStripChangeEvent {
  date: string;
  month: string;
  scene: string;
}

/** 展开收起事件载荷。/ Payload of the toggleFull event. */
export interface UPCalendarStripToggleEvent {
  show: boolean;
  source: string;
}

/** 补零到两位。/ Pads a number to two digits. */
export function upCalendarStripPad(value: number): string {
  return value < 10 ? `0${value}` : String(value);
}

/** 生成 YYYY-MM-DD。/ Formats a calendar date. */
export function upCalendarStripFormatDate(year: number, month: number, day: number): string {
  return `${year}-${upCalendarStripPad(month)}-${upCalendarStripPad(day)}`;
}

/** 生成 YYYY-MM。/ Formats a calendar month. */
export function upCalendarStripFormatMonth(year: number, month: number): string {
  return `${year}-${upCalendarStripPad(month)}`;
}

/** 当月天数，替代 dayjs daysInMonth。/ Days in month without dayjs. */
export function upCalendarStripDaysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate();
}

/** 解析 YYYY-MM-DD，失败回落空串。/ Parses a calendar date, empty when invalid. */
export function upCalendarStripNormalizeDate(value: UPRawValue): string {
  const source: string = upString(value, '').trim();
  const match: RegExpMatchArray | null = source.match(/^(\d{4})[-/](\d{1,2})[-/](\d{1,2})/);
  if (match === null) {
    return '';
  }
  const year: number = Number(match[1]);
  const month: number = Number(match[2]);
  const day: number = Number(match[3]);
  if (month < 1 || month > 12) {
    return '';
  }
  if (day < 1 || day > upCalendarStripDaysInMonth(year, month)) {
    return '';
  }
  return upCalendarStripFormatDate(year, month, day);
}

/** 日期字符串比较，等价 dayjs isBefore / isAfter。/ Lexicographic date comparison. */
export function upCalendarStripCompare(left: string, right: string): number {
  if (left === right) {
    return 0;
  }
  return left < right ? -1 : 1;
}

/** 按 minDate / maxDate 钳制日期，越界回落到边界。/ Clamps a date into the allowed range. */
export function upCalendarStripClamp(date: string, minDate: string, maxDate: string): string {
  if (date.length === 0) {
    return '';
  }
  if (minDate.length > 0 && upCalendarStripCompare(date, minDate) < 0) {
    return minDate;
  }
  if (maxDate.length > 0 && upCalendarStripCompare(date, maxDate) > 0) {
    return maxDate;
  }
  return date;
}

/** 月标题：monthFormat 为 no-op，中文环境用 YYYY年MM月。/ Month title text. */
export function upCalendarStripMonthLabel(year: number, month: number): string {
  return `${year}年${upCalendarStripPad(month)}月`;
}

/** weekText 索引换算：周日落到数组末位。/ Maps a JS weekday onto weekText. */
export function upCalendarStripWeekIndex(week: number): number {
  return week === 0 ? 6 : week - 1;
}

/**
 * 上游 `fullCalendarProps` 的具名子集，透传给展开面板。
 * Named subset of the upstream fullCalendarProps forwarded to the expanded panel.
 */
export interface UPCalendarStripFullProps {
  title?: string;
  activeColor?: string;
  monthFormat?: string;
  forbidDays?: Array<string>;
  forbidDaysToast?: string;
}

export interface UPCalendarStripOptions {
  modelValue?: UPRawValue;
  minDate?: UPRawValue;
  maxDate?: UPRawValue;
  color?: UPRawValue;
  weekText?: Array<string>;
  fullCalendar?: UPRawValue;
  fullCalendarProps?: UPCalendarStripFullProps;
  fullMonthNum?: UPRawValue;
  pullDownThreshold?: UPRawValue;
  collapseAfterSelect?: UPRawValue;
  readonly?: UPRawValue;
  showToday?: UPRawValue;
  monthFormat?: UPRawValue;
  expandHint?: UPRawValue;
  collapseHint?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onChange?: (event: UPCalendarStripChangeEvent) => void;
  onConfirm?: (event: UPCalendarStripChangeEvent) => void;
  onMonthChange?: (event: UPCalendarStripChangeEvent) => void;
  onToggleFull?: (event: UPCalendarStripToggleEvent) => void;
  onModelValueChange?: (value: string) => void;
}

export class UPCalendarStripProps {
  modelValue: UPRawValue = null;
  minDate: UPRawValue = 0;
  maxDate: UPRawValue = 0;
  color: UPRawValue = '#3c9cff';
  weekText: Array<string> = upWeekText();
  fullCalendar: UPRawValue = true;
  fullCalendarProps?: UPCalendarStripFullProps;
  fullMonthNum: UPRawValue = 24;
  pullDownThreshold: UPRawValue = 40;
  collapseAfterSelect: UPRawValue = true;
  readonly: UPRawValue = false;
  showToday: UPRawValue = true;
  monthFormat: UPRawValue = '';
  expandHint: UPRawValue = '下拉展开月历';
  collapseHint: UPRawValue = '上拉收起月历';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onChange?: (event: UPCalendarStripChangeEvent) => void;
  onConfirm?: (event: UPCalendarStripChangeEvent) => void;
  onMonthChange?: (event: UPCalendarStripChangeEvent) => void;
  onToggleFull?: (event: UPCalendarStripToggleEvent) => void;
  onModelValueChange?: (value: string) => void;

  constructor(options?: UPCalendarStripOptions) {
    if (options === undefined) {
      return;
    }
    this.modelValue = options.modelValue ?? this.modelValue;
    this.minDate = options.minDate ?? this.minDate;
    this.maxDate = options.maxDate ?? this.maxDate;
    this.color = options.color ?? this.color;
    this.weekText = options.weekText ?? this.weekText;
    this.fullCalendar = options.fullCalendar ?? this.fullCalendar;
    this.fullCalendarProps = options.fullCalendarProps;
    this.fullMonthNum = options.fullMonthNum ?? this.fullMonthNum;
    this.pullDownThreshold = options.pullDownThreshold ?? this.pullDownThreshold;
    this.collapseAfterSelect = options.collapseAfterSelect ?? this.collapseAfterSelect;
    this.readonly = options.readonly ?? this.readonly;
    this.showToday = options.showToday ?? this.showToday;
    this.monthFormat = options.monthFormat ?? this.monthFormat;
    this.expandHint = options.expandHint ?? this.expandHint;
    this.collapseHint = options.collapseHint ?? this.collapseHint;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onChange = options.onChange;
    this.onConfirm = options.onConfirm;
    this.onMonthChange = options.onMonthChange;
    this.onToggleFull = options.onToggleFull;
    this.onModelValueChange = options.onModelValueChange;
  }
}

const UP_CALENDAR_STRIP_CELL_WIDTH: number = 54;
const UP_CALENDAR_STRIP_CELL_HEIGHT: number = 62;

@Component
export struct UPCalendarStrip {
  @Prop @Watch('applyModelValue') props: UPCalendarStripProps = new UPCalendarStripProps();
  @State private selectedDate: string = '';
  @State private viewYear: number = 2026;
  @State private viewMonth: number = 1;
  @State private fullVisible: boolean = false;
  private appliedModelValue: string = '\u0000';
  private touchStartX: number = 0;
  private touchStartY: number = 0;
  private touching: boolean = false;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (upString(this.props.monthFormat, '').length > 0) {
      diagnostics.report('UPCalendarStrip', 'monthFormat', this.props.monthFormat, 'dayjs format tokens are unavailable; the month title always renders YYYY年MM月');
    }
    if (this.props.fullCalendarProps !== undefined) {
      diagnostics.report('UPCalendarStrip', 'fullCalendarProps', '',
        'fullCalendarProps only forwards the modelled panel fields: title, activeColor, monthFormat, forbidDays and forbidDaysToast');
    }
    if (Math.floor(upNumber(this.props.fullMonthNum, 24)) !== 24) {
      diagnostics.report('UPCalendarStrip', 'fullMonthNum', this.props.fullMonthNum, 'the expanded panel renders one month at a time; the month window size is a no-op');
    }
    const today: Date = new Date();
    this.viewYear = today.getFullYear();
    this.viewMonth = today.getMonth() + 1;
    this.applyModelValue();
    if (this.selectedDate.length === 0) {
      const fallback: string = upCalendarStripClamp(
        upCalendarStripFormatDate(today.getFullYear(), today.getMonth() + 1, today.getDate()),
        this.minDateValue(),
        this.maxDateValue()
      );
      if (fallback.length > 0) {
        this.selectedDate = fallback;
        this.syncViewToSelected();
      }
    }
  }

  /** modelValue 同步，非法值忽略。/ Syncs the controlled modelValue. */
  private applyModelValue(): void {
    const next: string = upCalendarStripNormalizeDate(this.props.modelValue);
    if (next === this.appliedModelValue) {
      return;
    }
    this.appliedModelValue = next;
    if (next.length === 0) {
      return;
    }
    const clamped: string = upCalendarStripClamp(next, this.minDateValue(), this.maxDateValue());
    if (clamped === this.selectedDate) {
      return;
    }
    this.selectedDate = clamped;
    this.syncViewToSelected();
  }

  private syncViewToSelected(): void {
    if (this.selectedDate.length < 7) {
      return;
    }
    this.viewYear = Number(this.selectedDate.substring(0, 4));
    this.viewMonth = Number(this.selectedDate.substring(5, 7));
  }

  private minDateValue(): string {
    return upCalendarStripNormalizeDate(this.props.minDate);
  }

  private maxDateValue(): string {
    return upCalendarStripNormalizeDate(this.props.maxDate);
  }

  /** `fullCalendarProps` 覆盖展开面板的标题。/ fullCalendarProps overrides the expanded title. */
  private fullTitle(): string {
    const overrides: UPCalendarStripFullProps | undefined = this.props.fullCalendarProps;
    const title: string = overrides === undefined ? '' : (overrides.title ?? '');
    return title.length > 0 ? title : this.monthLabel();
  }

  private fullActiveColor(): string {
    const overrides: UPCalendarStripFullProps | undefined = this.props.fullCalendarProps;
    const color: string = overrides === undefined ? '' : (overrides.activeColor ?? '');
    return color.length > 0 ? color : this.accentColor();
  }

  private fullMonthFormat(): string {
    const overrides: UPCalendarStripFullProps | undefined = this.props.fullCalendarProps;
    return overrides === undefined ? '' : (overrides.monthFormat ?? '');
  }

  private fullForbidDays(): Array<string> {
    const overrides: UPCalendarStripFullProps | undefined = this.props.fullCalendarProps;
    return overrides === undefined ? [] : (overrides.forbidDays ?? []);
  }

  private fullForbidToast(): string {
    const overrides: UPCalendarStripFullProps | undefined = this.props.fullCalendarProps;
    const toast: string = overrides === undefined ? '' : (overrides.forbidDaysToast ?? '');
    return toast.length > 0 ? toast : UP_CALENDAR_FORBID_TOAST;
  }

  private accentColor(): string {
    return UPColor.parse(upString(this.props.color, '#3c9cff'), UP_DEFAULT_THEME, '#3c9cff');
  }

  private todayDate(): string {
    const today: Date = new Date();
    return upCalendarStripFormatDate(today.getFullYear(), today.getMonth() + 1, today.getDate());
  }

  private monthLabel(): string {
    return upCalendarStripMonthLabel(this.viewYear, this.viewMonth);
  }

  private currentMonth(): string {
    return upCalendarStripFormatMonth(this.viewYear, this.viewMonth);
  }

  /** 当月日期格集合。/ Day cells of the visible month. */
  private dayCells(): Array<UPCalendarStripDay> {
    const total: number = upCalendarStripDaysInMonth(this.viewYear, this.viewMonth);
    const minDate: string = this.minDateValue();
    const maxDate: string = this.maxDateValue();
    const today: string = this.todayDate();
    const cells: Array<UPCalendarStripDay> = [];
    for (let day: number = 1; day <= total; day++) {
      const date: string = upCalendarStripFormatDate(this.viewYear, this.viewMonth, day);
      const outOfRange: boolean = (minDate.length > 0 && upCalendarStripCompare(date, minDate) < 0)
        || (maxDate.length > 0 && upCalendarStripCompare(date, maxDate) > 0);
      cells.push({
        day,
        date,
        week: new Date(this.viewYear, this.viewMonth - 1, day).getDay(),
        disabled: outOfRange,
        selected: date === this.selectedDate,
        today: date === today
      });
    }
    return cells;
  }

  private weekLabel(week: number): string {
    const labels: Array<string> = this.props.weekText;
    const index: number = upCalendarStripWeekIndex(week);
    return index < labels.length ? labels[index] : '';
  }

  private switchPrevDisabled(): boolean {
    const minDate: string = this.minDateValue();
    if (minDate.length === 0) {
      return false;
    }
    return upCalendarStripCompare(this.currentMonth(), minDate.substring(0, 7)) <= 0;
  }

  private switchNextDisabled(): boolean {
    const maxDate: string = this.maxDateValue();
    if (maxDate.length === 0) {
      return false;
    }
    return upCalendarStripCompare(this.currentMonth(), maxDate.substring(0, 7)) >= 0;
  }

  private emitChange(date: string, scene: string, monthChanged: boolean): void {
    const payload: UPCalendarStripChangeEvent = { date, month: this.currentMonth(), scene };
    if (date !== this.appliedModelValue) {
      this.appliedModelValue = date;
      const modelValueChange: ((value: string) => void) | undefined = this.props.onModelValueChange;
      if (modelValueChange !== undefined) {
        modelValueChange(date);
      }
    }
    const change: ((event: UPCalendarStripChangeEvent) => void) | undefined = this.props.onChange;
    if (change !== undefined) {
      change(payload);
    }
    const confirm: ((event: UPCalendarStripChangeEvent) => void) | undefined = this.props.onConfirm;
    if (confirm !== undefined) {
      confirm(payload);
    }
    if (monthChanged) {
      const monthChange: ((event: UPCalendarStripChangeEvent) => void) | undefined = this.props.onMonthChange;
      if (monthChange !== undefined) {
        monthChange(payload);
      }
    }
  }

  /** 选择日期，readonly 与越界日期直接忽略。/ Selects a date unless readonly or out of range. */
  private selectDate(date: string, scene: string): void {
    if (upBoolean(this.props.readonly, false)) {
      return;
    }
    const clamped: string = upCalendarStripClamp(date, this.minDateValue(), this.maxDateValue());
    if (clamped.length === 0 || clamped !== date) {
      return;
    }
    const previousMonth: string = this.currentMonth();
    this.selectedDate = clamped;
    this.syncViewToSelected();
    if (this.fullVisible && upBoolean(this.props.collapseAfterSelect, true)) {
      this.toggleFull(false, 'auto');
    }
    this.emitChange(clamped, scene, previousMonth !== this.currentMonth());
  }

  /** 当月首个可选日期，供跨月切换回落。/ First selectable date of the visible month. */
  private firstEnabledDate(): string {
    const cells: Array<UPCalendarStripDay> = this.dayCells();
    for (let index: number = 0; index < cells.length; index++) {
      if (!cells[index].disabled) {
        return cells[index].date;
      }
    }
    return '';
  }

  private switchMonth(step: number): void {
    if (step < 0 && this.switchPrevDisabled()) {
      return;
    }
    if (step > 0 && this.switchNextDisabled()) {
      return;
    }
    let month: number = this.viewMonth + step;
    let year: number = this.viewYear;
    if (month < 1) {
      month = 12;
      year--;
    }
    if (month > 12) {
      month = 1;
      year++;
    }
    this.viewYear = year;
    this.viewMonth = month;
    const day: number = this.selectedDate.length > 0 ? Number(this.selectedDate.substring(8, 10)) : 1;
    const target: string = upCalendarStripFormatDate(year, month, Math.min(day, upCalendarStripDaysInMonth(year, month)));
    const clamped: string = upCalendarStripClamp(target, this.minDateValue(), this.maxDateValue());
    const resolved: string = clamped === target ? target : this.firstEnabledDate();
    if (resolved.length === 0) {
      return;
    }
    const previousSelected: string = this.selectedDate;
    this.selectedDate = resolved;
    if (upBoolean(this.props.readonly, false)) {
      this.selectedDate = previousSelected;
    }
    this.emitChange(this.selectedDate, 'switch', true);
  }

  private jumpToday(): void {
    this.selectDate(this.todayDate(), 'button');
  }

  private toggleFull(show: boolean, source: string): void {
    if (!upBoolean(this.props.fullCalendar, true)) {
      return;
    }
    if (this.fullVisible === show) {
      return;
    }
    this.fullVisible = show;
    const toggle: ((event: UPCalendarStripToggleEvent) => void) | undefined = this.props.onToggleFull;
    if (toggle !== undefined) {
      toggle({ show, source });
    }
  }

  private thresholdValue(): number {
    return Math.max(1, upNumber(this.props.pullDownThreshold, 40));
  }

  /** 纵向位移超过阈值且大于横向位移时切换展开态。/ Vertical drags toggle the expanded panel. */
  private handleTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.touching = true;
      this.touchStartX = event.touches[0].windowX;
      this.touchStartY = event.touches[0].windowY;
      return;
    }
    if (event.type !== TouchType.Up) {
      return;
    }
    if (!this.touching) {
      return;
    }
    this.touching = false;
    const deltaX: number = event.touches[0].windowX - this.touchStartX;
    const deltaY: number = event.touches[0].windowY - this.touchStartY;
    if (Math.abs(deltaY) < this.thresholdValue() || Math.abs(deltaY) <= Math.abs(deltaX)) {
      return;
    }
    if (deltaY > 0 && !this.fullVisible) {
      this.toggleFull(true, 'pull-down');
      return;
    }
    if (deltaY < 0 && this.fullVisible) {
      this.toggleFull(false, 'pull-up');
    }
  }

  private hintText(): string {
    return this.fullVisible
      ? upString(this.props.collapseHint, '上拉收起月历')
      : upString(this.props.expandHint, '下拉展开月历');
  }

  private handleFullSelect(event: UPCalendarSelectEvent): void {
    this.selectDate(event.date, 'full');
  }

  @Builder
  private header() {
    Row() {
      Text('‹')
        .width(40)
        .fontSize(20)
        .fontColor(UPColor.adaptive('#303133', 'main-color'))
        .textAlign(TextAlign.Center)
        .opacity(this.switchPrevDisabled() ? 0.35 : 1)
        .onClick((): void => this.switchMonth(-1))
      Text(this.monthLabel())
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(UPColor.adaptive('#303133', 'main-color'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Text('›')
        .width(40)
        .fontSize(20)
        .fontColor(UPColor.adaptive('#303133', 'main-color'))
        .textAlign(TextAlign.Center)
        .opacity(this.switchNextDisabled() ? 0.35 : 1)
        .onClick((): void => this.switchMonth(1))
      if (upBoolean(this.props.fullCalendar, true)) {
        Text('▾')
          .width(40)
          .fontSize(18)
          .fontColor(UPColor.adaptive('#303133', 'main-color'))
          .textAlign(TextAlign.Center)
          .onClick((): void => this.toggleFull(!this.fullVisible, 'hint'))
      }
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private dayCell(cell: UPCalendarStripDay) {
    Column() {
      Text(String(cell.day))
        .fontSize(18)
        .lineHeight(22)
        .fontColor(cell.selected ? '#ffffff' : '#303133')
      Text(this.weekLabel(cell.week))
        .fontSize(12)
        .lineHeight(16)
        .fontColor(cell.selected ? '#ffffff' : '#909399')
        .margin({ top: 4 })
    }
    .width(UP_CALENDAR_STRIP_CELL_WIDTH)
    .height(UP_CALENDAR_STRIP_CELL_HEIGHT)
    .margin({ right: 8 })
    .borderRadius(8)
    .borderWidth(1)
    .borderColor(cell.today && upBoolean(this.props.showToday, true) && !cell.selected ? this.accentColor() : 'transparent')
    .backgroundColor(cell.selected ? this.accentColor() : '#f7f8fa')
    .opacity(cell.disabled ? 0.4 : 1)
    .justifyContent(FlexAlign.Center)
    .onClick((): void => this.selectDate(cell.date, 'tap'))
  }

  @Builder
  private strip() {
    Scroll() {
      Row() {
        ForEach(this.dayCells(), (cell: UPCalendarStripDay) => {
          this.dayCell(cell)
        }, (cell: UPCalendarStripDay) => cell.date)
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  build() {
    Column() {
      this.header()
      if (this.fullVisible) {
        UPCalendar({ props: new UPCalendarProps({
          year: this.viewYear,
          month: this.viewMonth,
          selectedDate: this.selectedDate,
          weekStart: 1,
          title: this.fullTitle(),
          activeColor: this.fullActiveColor(),
          monthFormat: this.fullMonthFormat(),
          forbidDays: this.fullForbidDays(),
          forbidDaysToast: this.fullForbidToast(),
          onSelect: (event: UPCalendarSelectEvent): void => this.handleFullSelect(event)
        }) })
      } else {
        this.strip()
      }
      if (upBoolean(this.props.showToday, true)) {
        Text('回到今天')
          .fontSize(12)
          .fontColor(this.accentColor())
          .margin({ top: 8 })
          .onClick((): void => this.jumpToday())
      }
      if (upBoolean(this.props.fullCalendar, true)) {
        Text(this.hintText())
          .fontSize(12)
          .fontColor(UPColor.adaptive('#909399', 'tips-color'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 8 })
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .padding(12)
    .margin({ left: 8, right: 8 })
    .borderRadius(10)
    .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
    .onTouch((event: TouchEvent): void => this.handleTouch(event))
  }
}
