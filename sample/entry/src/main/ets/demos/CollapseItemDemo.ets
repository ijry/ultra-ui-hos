import { UPCollapseItem, UPCollapseItemProps } from '@lingyun/ultra-ui-hos';
@Component
export struct CollapseItemDemo {
  @State private open: boolean = true;
  build() {
    Column({ space: 12 }) {
      Text('独立折叠项').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPCollapseItem({ props: new UPCollapseItemProps({ title: '独立内容', open: this.open, isOpen: false, onClick: (): void => { this.open = !this.open; } }) }) { Text('独立渲染时使用 open，其次回退 isOpen。').fontSize(14).fontColor('#606266') }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
