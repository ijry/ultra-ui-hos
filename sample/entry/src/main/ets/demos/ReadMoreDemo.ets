import { UPReadMore, UPReadMoreProps } from '@lingyun/ultra-ui-hos';

@Component
export struct ReadMoreDemo {
  @State private open: boolean = false;
  build() {
    Column({ space: 12 }) {
      Text('展开阅读').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPReadMore({ props: new UPReadMoreProps({ modelValue: this.open, showHeight: 48, closeText: '展开', openText: '收起',
        onOpenChange: (open: boolean): void => { this.open = open; } }) }) {
        Text('这里是较长的本地示例内容。折叠时高度被限制，展开后完整显示，状态始终由页面持有。')
          .fontSize(14).fontColor('#606266')
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
