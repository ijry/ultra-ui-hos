import { UPIndexAnchor, UPIndexAnchorProps, UPIndexItem, UPIndexItemProps } from '@lingyun/ultra-ui-hos';

@Component
export struct IndexItemDemo {
  @Builder private header() { UPIndexAnchor({ props: new UPIndexAnchorProps({ text: 'A', bgColor: '#ecf5ff' }) }) }
  @Builder private content() { Text('显式双 Builder 内容').fontSize(15).fontColor('#303133').padding(14) }

  build() {
    Column({ space: 12 }) {
      Text('独立索引项').fontSize(16).fontWeight(FontWeight.Bold)
      UPIndexItem({
        props: new UPIndexItemProps({ index: 'A' }),
        headerBuilder: this.header,
        contentBuilder: this.content
      })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
