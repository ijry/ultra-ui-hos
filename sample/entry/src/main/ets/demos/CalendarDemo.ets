import { UPCalendar, UPCalendarSelectEvent, UPCalendarProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CalendarDemo {
  @State private date: string = '';

  build() {
    Column({ space: 12 }) {
      Text('日历').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPCalendar({ props: new UPCalendarProps({ weekStart: 1, activeColor: '#2979ff',
        onSelect: (event: UPCalendarSelectEvent): void => { this.date = event.date; } }) })
      Text('选中日期：' + (this.date.length > 0 ? this.date : '未选择')).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
