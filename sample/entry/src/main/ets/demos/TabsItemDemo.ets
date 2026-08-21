import { UPTabsItem, UPTabsItemProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TabsItemDemo {
  build() {
    Column({ space: 12 }) {
      Text('独立标签项').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133')
      UPTabsItem({ props: new UPTabsItemProps({ customStyle: { backgroundColor: '#ecf5ff', padding: 16 } }) }) { Text('这是可单独使用的内容 Builder').fontSize(14).fontColor('#2979ff') }
      UPTabsItem({ props: new UPTabsItemProps() }) { Text('无内容时安全呈现空 Builder').fontSize(13).fontColor('#909399') }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
