import {
  UPIndexAnchor,
  UPIndexAnchorProps,
  UPIndexItem,
  UPIndexItemProps,
  UPIndexList,
  UPIndexListProps,
  UPIndexListSelectEvent,
  UPRawValue
} from '@lingyun/ultra-ui-hos';

@Component
export struct IndexListDemo {
  @State private current: UPRawValue = 'A';
  @State private message: string = '当前索引：A';
  private indexes: Array<UPRawValue> = ['A', 'B', 0];

  @Builder private headerA() { UPIndexAnchor({ props: new UPIndexAnchorProps({ text: 'A' }) }) }
  @Builder private contentA() { Column() { Text('Apple'); Text('Aurora') }.padding(12).alignItems(HorizontalAlign.Start) }
  @Builder private headerB() { UPIndexAnchor({ props: new UPIndexAnchorProps({ text: 'B' }) }) }
  @Builder private contentB() { Column() { Text('Banana'); Text('Blue') }.padding(12).alignItems(HorizontalAlign.Start) }
  @Builder private headerZero() { UPIndexAnchor({ props: new UPIndexAnchorProps({ text: 0 }) }) }
  @Builder private contentZero() { Text('数字 0 是有效索引').padding(12) }

  @Builder
  private groups() {
    UPIndexItem({ props: new UPIndexItemProps({ index: 'A' }), headerBuilder: this.headerA, contentBuilder: this.contentA })
    UPIndexItem({ props: new UPIndexItemProps({ index: 'B' }), headerBuilder: this.headerB, contentBuilder: this.contentB })
    UPIndexItem({ props: new UPIndexItemProps({ index: 0 }), headerBuilder: this.headerZero, contentBuilder: this.contentZero })
  }

  build() {
    Column({ space: 12 }) {
      UPIndexList({ props: new UPIndexListProps({
        indexList: this.indexes,
        current: this.current,
        sticky: true,
        showSidebar: true,
        customStyle: { height: 300 },
        onSelect: (event: UPIndexListSelectEvent): void => { this.message = '选择：' + String(event.value); },
        onChange: (event: UPIndexListSelectEvent): void => { this.message = '变化：' + String(event.value); },
        onCurrentChange: (value: UPRawValue): void => { this.current = value; }
      }) }) {
        this.groups()
      }
      Text(this.message).fontSize(13).fontColor('#606266')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
