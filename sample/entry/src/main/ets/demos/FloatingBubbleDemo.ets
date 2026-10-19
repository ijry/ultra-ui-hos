import { UPFloatingBubble, UPFloatingBubbleClickEvent, UPFloatingBubbleProps } from '@lingyun/ultra-ui-hos';

@Component
export struct FloatingBubbleDemo {
  @State private message: string = '点击悬浮球';

  build() {
    Column({ space: 12 }) {
      Text('悬浮按钮').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
      Stack() {
        UPFloatingBubble({ props: new UPFloatingBubbleProps({ text: '客服', bottom: 12, right: 12, size: 56,
          onClick: (event: UPFloatingBubbleClickEvent): void => { this.message = '位置：' + String(event.bottom) + '/' + String(event.right); } }) })
      }.width('100%').height(220).alignContent(Alignment.BottomEnd).borderRadius(12).backgroundColor('#f7f8fa')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
