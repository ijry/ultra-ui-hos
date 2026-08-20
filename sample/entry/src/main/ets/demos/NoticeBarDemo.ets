import { UPNoticeBar, UPNoticeBarProps, UPButton, UPButtonProps } from '@lingyun/ultra-ui-hos';
@Component
export struct NoticeBarDemo {
  @State private show: boolean = true;
  @State private feedback: string = '点击公告或关闭按钮';
  build() {
    Column({ space: 14 }) {
      Text('公告栏').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPNoticeBar({ props: new UPNoticeBarProps({ show: this.show, text: ['HarmonyOS NEXT 原生实现', '无网络静态示例'], mode: 'closable', url: 'local://notice', linkType: 'local', onClick: (): void => { this.feedback = '公告已点击'; }, onShowChange: (value: boolean): void => { this.show = value; } }) })
      Text(this.feedback).fontSize(13).fontColor('#909399').width('100%')
      UPButton({ props: new UPButtonProps({ text: this.show ? '隐藏公告' : '显示公告', type: 'primary', onClick: (): void => { this.show = !this.show; } }) })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
