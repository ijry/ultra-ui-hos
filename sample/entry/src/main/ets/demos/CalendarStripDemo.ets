import {
  UPCalendarStrip,
  UPCalendarStripChangeEvent,
  UPCalendarStripProps,
  UPCalendarStripToggleEvent,
  upCalendarStripClamp,
  upCalendarStripDaysInMonth,
  upCalendarStripMonthLabel
} from '@lingyun/ultra-ui-hos';

@Component
export struct CalendarStripDemo {
  @State private selected: string = '2026-09-03';
  @State private rangeSelected: string = '2026-09-10';
  @State private changeText: string = '滑动或点击日期查看回传';
  @State private toggleText: string = '下拉条带可展开月历';

  private handleChange(event: UPCalendarStripChangeEvent): void {
    this.selected = event.date;
    this.changeText = 'change：' + event.date + '（月份 ' + event.month + '，来源 ' + event.scene + '）';
  }

  private handleRangeChange(event: UPCalendarStripChangeEvent): void {
    this.rangeSelected = event.date;
    this.changeText = '限定范围内选择：' + event.date + '（来源 ' + event.scene + '）';
  }

  private handleToggle(event: UPCalendarStripToggleEvent): void {
    this.toggleText = 'toggleFull：' + (event.show ? '展开' : '收起') + '（来源 ' + event.source + '）';
  }

  private handleMonthChange(event: UPCalendarStripChangeEvent): void {
    this.changeText = 'monthChange：切到 ' + event.month + '（来源 ' + event.scene + '）';
  }

  private clampSummary(date: string): string {
    const clamped: string = upCalendarStripClamp(date, '2026-09-05', '2026-09-20');
    return date + ' 钳制到 [2026-09-05, 2026-09-20] → ' + (clamped.length > 0 ? clamped : '无效日期');
  }

  build() {
    Column({ space: 16 }) {
      Text('横向日期条与展开月历')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCalendarStrip({
        props: new UPCalendarStripProps({
          modelValue: this.selected,
          onChange: (event: UPCalendarStripChangeEvent): void => {
            this.handleChange(event);
          },
          onMonthChange: (event: UPCalendarStripChangeEvent): void => {
            this.handleMonthChange(event);
          },
          onToggleFull: (event: UPCalendarStripToggleEvent): void => {
            this.handleToggle(event);
          },
          onModelValueChange: (value: string): void => {
            this.selected = value;
          }
        })
      })
      Text(this.changeText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.toggleText).fontSize(13).fontColor('#606266').width('100%')

      Text('限定可选范围与主题色')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCalendarStrip({
        props: new UPCalendarStripProps({
          modelValue: this.rangeSelected,
          minDate: '2026-09-05',
          maxDate: '2026-09-20',
          color: 'success',
          expandHint: '下拉查看整月',
          collapseHint: '上拉回到条带',
          onChange: (event: UPCalendarStripChangeEvent): void => {
            this.handleRangeChange(event);
          },
          onModelValueChange: (value: string): void => {
            this.rangeSelected = value;
          }
        })
      })
      Text(this.clampSummary('2026-09-01')).fontSize(12).fontColor('#909399').width('100%')
      Text(this.clampSummary('2026-09-28')).fontSize(12).fontColor('#909399').width('100%')
      Text(this.clampSummary('2026-13-01')).fontSize(12).fontColor('#909399').width('100%')

      Text('只读态与隐藏今天入口')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCalendarStrip({
        props: new UPCalendarStripProps({
          modelValue: '2026-09-15',
          readonly: true,
          showToday: false,
          fullCalendar: false,
          color: '#ff9900'
        })
      })
      Text(upCalendarStripMonthLabel(2026, 9) + ' 共 ' + String(upCalendarStripDaysInMonth(2026, 9)) + ' 天；'
        + upCalendarStripMonthLabel(2026, 2) + ' 共 ' + String(upCalendarStripDaysInMonth(2026, 2)) + ' 天')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text('monthFormat 的 dayjs 占位符为 no-op，月标题恒为 YYYY年MM月；fullMonthNum 不影响展开面板每次只渲染一个月。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
