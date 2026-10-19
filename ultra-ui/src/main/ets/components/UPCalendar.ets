import { UPBuilder, UPStyleInput, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPI18n, upWeekText } from '../core/UPI18n';
import { UPColor } from '../core/UPColor';

/** 上游 forbidDaysToast 的默认文案（i18n `up.calendar.disabled`）。/ Default forbidden-day notice. */
export const UP_CALENDAR_FORBID_TOAST: string = UPI18n.t('up.calendar.disabled');

export interface UPCalendarSelectEvent { date: string; year: number; month: number; day: number; }
/** 上游 isForbid() 命中时的载荷。/ Payload emitted when isForbid() rejects a date. */
export interface UPCalendarForbidEvent { date: string; toast: string; }
export interface UPCalendarOptions {
  year?: number; month?: number; selectedDate?: string; weekStart?: number; title?: string;
  activeColor?: string; forbidDays?: Array<string>; forbidDaysToast?: string; monthFormat?: string;
  customStyle?: UPStyleInput; onSelect?: (event: UPCalendarSelectEvent) => void;
  onForbid?: (event: UPCalendarForbidEvent) => void;
  onConfirm?: (event: UPCalendarSelectEvent) => void;
  onClose?: () => void; onClosed?: () => void;
  footerBuilder?: UPBuilder;
}
export class UPCalendarProps {
  year: number = -1; month: number = -1; selectedDate: string = ''; weekStart: number = 0;
  title: string = '选择日期'; activeColor: string = '#2979ff';
  forbidDays: Array<string> = []; forbidDaysToast: string = UP_CALENDAR_FORBID_TOAST; monthFormat: string = '';
  customStyle: UPStyleInput = undefined;
  onSelect?: (event: UPCalendarSelectEvent) => void;
  onForbid?: (event: UPCalendarForbidEvent) => void;
  onConfirm?: (event: UPCalendarSelectEvent) => void;
  onClose?: () => void; onClosed?: () => void;
  footerBuilder?: UPBuilder;
  constructor(options?: UPCalendarOptions) {
    if (options === undefined) return;
    this.year = options.year ?? this.year; this.month = options.month ?? this.month;
    this.selectedDate = options.selectedDate ?? this.selectedDate; this.weekStart = options.weekStart ?? this.weekStart;
    this.title = options.title ?? this.title; this.activeColor = options.activeColor ?? this.activeColor;
    this.forbidDays = options.forbidDays ?? this.forbidDays;
    this.forbidDaysToast = options.forbidDaysToast ?? this.forbidDaysToast;
    this.monthFormat = options.monthFormat ?? this.monthFormat;
    this.customStyle = options.customStyle; this.onSelect = options.onSelect; this.onForbid = options.onForbid;
    this.onConfirm = options.onConfirm; this.onClose = options.onClose; this.onClosed = options.onClosed;
    this.footerBuilder = options.footerBuilder;
  }
}

/**
 * 上游 month.vue 的月份标题：`monthFormat` 为空时按「YYYY年MM月」，否则按占位符替换。
 * Mirrors the upstream month title, honouring the monthFormat placeholders.
 */
export function upCalendarMonthTitle(year: number, month: number, format: string): string {
  const monthText: string = String(month).padStart(2, '0');
  if (format.length === 0) {
    return String(year) + '年' + monthText + '月';
  }
  return format.replace('YYYY', String(year)).replace('MM', monthText).replace('M', String(month));
}

/** 上游 isForbid()：`forbidDays` 命中当天则禁止选择。/ Mirrors upstream isForbid(). */
export function upCalendarForbidden(date: string, forbidDays: Array<string>): boolean {
  return forbidDays.includes(date);
}

@Component
export struct UPCalendar {
  @Prop props: UPCalendarProps = new UPCalendarProps();
  @State private viewYear: number = 2026;
  @State private viewMonth: number = 1;
  @State private selectedDate: string = '';

  aboutToAppear(): void {
    const now: Date = new Date();
    this.viewYear = this.props.year > 0 ? this.props.year : now.getFullYear();
    this.viewMonth = Math.max(1, Math.min(12, this.props.month > 0 ? this.props.month : now.getMonth() + 1));
    this.selectedDate = upString(this.props.selectedDate, '');
  }
  private changeMonth(delta: number): void {
    let month: number = this.viewMonth + delta;
    let year: number = this.viewYear;
    if (month < 1) { month = 12; year--; }
    if (month > 12) { month = 1; year++; }
    this.viewYear = Math.max(1900, Math.min(2999, year));
    this.viewMonth = Math.max(1, Math.min(12, month));
  }
  private weeks(): Array<string> {
    const values: Array<string> = upWeekText();
    return this.props.weekStart === 1 ? values : ['日', ...values.slice(0, 6)];
  }
  private days(): Array<number> {
    const firstWeekday: number = new Date(this.viewYear, this.viewMonth - 1, 1).getDay();
    const offset: number = this.props.weekStart === 1 ? (firstWeekday + 6) % 7 : firstWeekday;
    const count: number = new Date(this.viewYear, this.viewMonth, 0).getDate();
    const output: Array<number> = [];
    for (let index = 0; index < offset; index++) output.push(0);
    for (let day = 1; day <= count; day++) output.push(day);
    return output;
  }
  private dateOf(day: number): string {
    const monthText: string = String(this.viewMonth).padStart(2, '0');
    const dayText: string = String(day).padStart(2, '0');
    return `${this.viewYear}-${monthText}-${dayText}`;
  }
  /** 上游 clickHandler()：命中 forbidDays 时提示而不选中。/ Mirrors upstream clickHandler(). */
  private select(day: number): void {
    if (day <= 0) return;
    const date: string = this.dateOf(day);
    if (upCalendarForbidden(date, this.props.forbidDays)) {
      this.props.onForbid?.({ date, toast: this.props.forbidDaysToast });
      return;
    }
    this.selectedDate = date;
    this.props.onSelect?.({ date: this.selectedDate, year: this.viewYear, month: this.viewMonth, day });
  }
  /** 上游 confirm：回传当前选中的日期。/ Upstream confirm carries the selected date. */
  private confirm(): void {
    const parts: Array<string> = this.selectedDate.split('-');
    if (parts.length !== 3) {
      return;
    }
    this.props.onConfirm?.({
      date: this.selectedDate,
      year: Number.parseInt(parts[0]),
      month: Number.parseInt(parts[1]),
      day: Number.parseInt(parts[2])
    });
  }
  /** ArkUI 无退场动画，close 与 closed 同帧触发。/ close and closed fire together on ArkUI. */
  private dismiss(): void {
    this.props.onClose?.();
    this.props.onClosed?.();
  }
  private isForbidden(day: number): boolean {
    return day > 0 && upCalendarForbidden(this.dateOf(day), this.props.forbidDays);
  }
  @Builder
  private footerRegion() {
    UPSlotRegion({ contentBuilder: this.props.footerBuilder })
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('‹').fontSize(20).padding(6).onClick((): void => this.changeMonth(-1))
        Text(upCalendarMonthTitle(this.viewYear, this.viewMonth, this.props.monthFormat)).fontSize(15).fontWeight(FontWeight.Medium).layoutWeight(1).textAlign(TextAlign.Center)
        Text('›').fontSize(20).padding(6).onClick((): void => this.changeMonth(1))
      }.width('100%')
      Row() { ForEach(this.weeks(), (week: string) => Text(week).fontSize(12).fontColor(UPColor.adaptive('#909399', 'tips-color')).layoutWeight(1).textAlign(TextAlign.Center)) }.width('100%')
      Grid() {
        ForEach(this.days(), (day: number) => {
          GridItem() {
            Text(day > 0 ? String(day) : '').fontSize(13).width(32).height(32).textAlign(TextAlign.Center)
              .borderRadius(16)
              .fontColor(this.isForbidden(day) ? '#c0c4cc'
                : (String(day) === this.selectedDay() && day > 0 ? '#ffffff' : '#303133'))
              .backgroundColor(!this.isForbidden(day) && String(day) === this.selectedDay() && day > 0
                ? this.props.activeColor : 'transparent')
              .onClick((): void => this.select(day))
          }
        })
      }.columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr').rowsGap(5).height(240)
      Text(this.selectedDate.length > 0 ? `${this.props.title}：${this.selectedDate}` : this.props.title)
        .fontSize(12).fontColor(UPColor.adaptive('#909399', 'tips-color'))
      if (this.props.footerBuilder !== undefined) {
        this.footerRegion()
      } else if (this.props.onConfirm !== undefined || this.props.onClose !== undefined) {
        Row({ space: 12 }) {
          if (this.props.onClose !== undefined) {
            Text('关闭').fontSize(13).fontColor(UPColor.adaptive('#909399', 'tips-color')).layoutWeight(1).textAlign(TextAlign.Center)
              .onClick((): void => this.dismiss())
          }
          if (this.props.onConfirm !== undefined) {
            Text('确定').fontSize(13).fontColor(this.props.activeColor).layoutWeight(1).textAlign(TextAlign.Center)
              .onClick((): void => this.confirm())
          }
        }.width('100%')
      }
    }.padding(12).borderRadius(8).backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
     .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
  private selectedDay(): string {
    const parts: Array<string> = this.selectedDate.split('-');
    return parts.length === 3 ? parts[2] : '';
  }
}
