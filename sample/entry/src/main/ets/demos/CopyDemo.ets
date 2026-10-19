import {
  UPCopy,
  UPCopyFailureEvent,
  UPCopyProps,
  UPCopySuccessEvent
} from '@lingyun/ultra-ui-hos';

@Component
export struct CopyDemo {
  @State private message: string = '点击复制，剪贴板能力由宿主注入';

  private hostClipboard(content: string): boolean {
    this.message = '宿主已收到：' + content;
    return true;
  }

  build() {
    Column({ space: 16 }) {
      Text('复制工具')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 10 }) {
        Text('阶段 12 示例文本')
          .fontSize(14)
          .fontColor('#606266')
        UPCopy({
          props: new UPCopyProps({
            content: '阶段 12 示例文本',
            clipboard: (content: string): boolean => {
              return this.hostClipboard(content);
            },
            onSuccess: (event: UPCopySuccessEvent): void => {
              this.message = event.notice + '：' + event.content;
            },
            onFailure: (event: UPCopyFailureEvent): void => {
              this.message = '复制失败：' + event.reason;
            }
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(12)
      .backgroundColor('#ffffff')
      .borderRadius(8)
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      Text('组件不会直接调用系统剪贴板，也不会自动弹出 Toast。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
