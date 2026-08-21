import { UPStepsItem, UPStepsItemProps } from '@lingyun/ultra-ui-hos';

@Component
export struct StepsItemDemo {
  @State private message: string = '独立项默认使用 wait 状态';
  @Builder
  private customContent() {
    Text('content Builder').fontSize(12).fontColor('#fa3534')
  }
  build() {
    Column({ space: 12 }) {
      UPStepsItem({ props: new UPStepsItemProps({ title: '独立步骤', desc: '脱离 UPSteps 时仍安全呈现', onClick: (index: number): void => { this.message = '点击索引：' + String(index); } }) })
      UPStepsItem({ props: new UPStepsItemProps({ title: '自定义内容', error: true }), contentBuilder: this.customContent })
      Text(this.message).fontSize(13).fontColor('#606266')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
