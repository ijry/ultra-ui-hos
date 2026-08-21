import { UPList, UPListItem, UPListItemProps, UPListProps } from '@lingyun/ultra-ui-hos';

@Component
export struct ListItemDemo {
  @Builder
  private groupedItems() {
    UPListItem({ props: new UPListItemProps({ anchor: 'first', customStyle: { padding: 12 } }) }) {
      Text('分组列表项 · first').fontSize(15).fontColor('#303133')
    }
    UPListItem({ props: new UPListItemProps({ anchor: 'second', customStyle: { padding: 12 } }) }) {
      Text('分组列表项 · second').fontSize(15).fontColor('#303133')
    }
  }

  build() {
    Column({ space: 14 }) {
      Text('独立安全回退').fontSize(16).fontWeight(FontWeight.Bold)
      UPListItem({ props: new UPListItemProps({ customStyle: { padding: 12, backgroundColor: '#f4f8ff', borderRadius: 8 } }) }) {
        Text('脱离 UPList 仍可显示').fontSize(14).fontColor('#606266')
      }
      Text('原生 ListItem 分组').fontSize(16).fontWeight(FontWeight.Bold)
      UPList({ props: new UPListProps({ height: 130, scrollIntoView: 'second' }) }) {
        this.groupedItems()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
