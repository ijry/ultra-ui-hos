import { UPPopover, UPPopoverProps, UPPopoverSelectEvent } from '@lingyun/ultra-ui-hos';

@Component
export struct PopoverDemo {
  @State private show: boolean = false;
  @State private message: string = '点击锚点切换气泡';
  private change(show: boolean): void { this.show = show; this.message = show ? '气泡已打开' : '气泡已关闭'; }
  build() {
    Column({ space: 12 }) {
      Text('气泡').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPPopover({ props: new UPPopoverProps({ modelValue: this.show, text: '顶部提示', placement: 'top',
        onShowChange: (show: boolean): void => { this.change(show); },
        onSelect: (event: UPPopoverSelectEvent): void => { this.message = event.show ? 'select：打开' : 'select：关闭'; } }) }) {
        Text('受控锚点').fontSize(14).padding(10).backgroundColor('#f5f7fa').borderRadius(6)
      }
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
