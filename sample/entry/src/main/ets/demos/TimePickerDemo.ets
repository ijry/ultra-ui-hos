import { UPTimePicker, UPTimePickerChangeEvent, UPTimePickerProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TimePickerDemo {
  @State private time: string = '未选择';
  build() {
    Column({ space: 12 }) {
      Text('时间选择').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPTimePicker({ props: new UPTimePickerProps({ hour: 9, minute: 30, second: 0, minuteStep: 5,
        onSelect: (event: UPTimePickerChangeEvent): void => { this.time = event.time; },
        onConfirm: (event: UPTimePickerChangeEvent): void => { this.time = '已确认 ' + event.time; } }) })
      Text('时间：' + this.time).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
