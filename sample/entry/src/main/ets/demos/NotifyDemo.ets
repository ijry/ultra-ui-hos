import { UPNotify, UPNotifyProps, UPButton, UPButtonProps } from '@lingyun/ultra-ui-hos';
@Component
export struct NotifyDemo {
  @State private show: boolean = false;
  build() {
    Column({ space: 14 }) {
      Text('顶部通知').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPButton({ props: new UPButtonProps({ text: this.show ? '关闭通知' : '显示通知', type: 'primary', onClick: (): void => { this.show = !this.show; } }) })
      UPNotify({ props: new UPNotifyProps({ show: this.show, message: '这是由页面控制 show 的本地通知。', type: 'primary', onShowChange: (value: boolean): void => { this.show = value; } }) })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
