import { UPDatePicker, UPDatePickerChangeEvent, UPDatePickerProps } from '@lingyun/ultra-ui-hos';

@Component
export struct DatePickerDemo {
  @State private date: string = '未选择';
  build() {
    Column({ space: 12 }) {
      Text('日期选择').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPDatePicker({ props: new UPDatePickerProps({ year: 2026, month: 8, day: 24,
        onSelect: (event: UPDatePickerChangeEvent): void => { this.date = event.date; },
        onConfirm: (event: UPDatePickerChangeEvent): void => { this.date = '已确认 ' + event.date; } }) })
      Text('日期：' + this.date).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
