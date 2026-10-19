import { UPProgressButton, UPProgressButtonClickEvent, UPProgressButtonProps, UPProgressButtonState } from '@lingyun/ultra-ui-hos';

@Component
export struct ProgressButtonDemo {
  @State private message: string = '等待点击';
  build() {
    Column({ space: 12 }) {
      Text('进度按钮').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPProgressButton({ props: new UPProgressButtonProps({ text: '上传', progress: 68, state: 'loading',
        onClick: (event: UPProgressButtonClickEvent): void => { this.message = event.state + ' ' + String(event.progress) + '%'; },
        onStateChange: (event: UPProgressButtonState): void => { this.message = '状态：' + event.state; } }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
