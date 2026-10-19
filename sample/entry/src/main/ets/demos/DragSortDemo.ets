import {
  UPDragSort,
  UPDragSortItem,
  UPDragSortItemSlot,
  UPDragSortProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct DragSortDemo {
  @State private status: string = '长按并拖动条目即可重新排序';
  private list: Array<UPDragSortItem> = [
    { id: 1, label: '项目 A' },
    { id: 2, label: '项目 B' },
    { id: 3, label: '项目 C' },
    { id: 4, label: '项目 D' },
    { id: 5, label: '项目 E' },
    { id: 6, label: '项目 F' },
    { id: 7, label: '项目 G' },
    { id: 8, label: '项目 H' }
  ];
  private list2: Array<UPDragSortItem> = [
    { id: 1, label: '横向 A' },
    { id: 2, label: '横向 B' },
    { id: 3, label: '横向 C' },
    { id: 4, label: '横向 D' },
    { id: 5, label: '横向 E' },
    { id: 6, label: '横向 F' },
    { id: 7, label: '横向 G' },
    { id: 8, label: '横向 H' }
  ];

  private describe(sorted: Array<UPDragSortItem>, scene: string): void {
    const labels: Array<string> = sorted.map((item: UPDragSortItem): string => String(item.label));
    this.status = scene + '新顺序：' + labels.join(' · ');
  }

  @Builder
  private verticalItem(slot: UPDragSortItemSlot) {
    Row({ space: 6 }) {
      Text('序号：' + String(slot.index + 1)).fontSize(13).fontColor('#909399')
      Text(String(slot.item.label)).fontSize(14).fontColor('#303133')
    }
    .width('100%')
    .height(40)
    .padding({ left: 12, right: 12 })
    .alignItems(VerticalAlign.Center)
    .borderRadius(6)
    .backgroundColor('#f4f4f5')
  }

  @Builder
  private compactItem(slot: UPDragSortItemSlot) {
    Text(String(slot.item.label))
      .fontSize(13)
      .fontColor('#303133')
      .width(72)
      .height(36)
      .textAlign(TextAlign.Center)
      .borderRadius(6)
      .backgroundColor('#ecf5ff')
  }

  build() {
    Column({ space: 16 }) {
      Text('单列多行模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPDragSort({
        props: new UPDragSortProps({
          initialList: this.list,
          itemHeight: 46,
          onDragEnd: (sorted: Array<UPDragSortItem>): void => {
            this.describe(sorted, '单列 ');
          }
        }),
        itemBuilder: this.verticalItem
      })

      Text('自定义拖动句柄')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPDragSort({
        props: new UPDragSortProps({
          initialList: this.list,
          useHandler: true,
          itemHeight: 46,
          onDragEnd: (sorted: Array<UPDragSortItem>): void => {
            this.describe(sorted, '句柄 ');
          }
        }),
        itemBuilder: this.verticalItem
      })

      Text('多行多列模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPDragSort({
        props: new UPDragSortProps({
          initialList: this.list,
          direction: 'all',
          columns: 3,
          itemWidth: 84,
          itemHeight: 44,
          onDragEnd: (sorted: Array<UPDragSortItem>): void => {
            this.describe(sorted, '多列 ');
          }
        }),
        itemBuilder: this.compactItem
      })

      Text('单行横向拖动')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPDragSort({
        props: new UPDragSortProps({
          initialList: this.list2,
          direction: 'horizontal',
          itemWidth: 84,
          itemHeight: 44,
          onDragEnd: (sorted: Array<UPDragSortItem>): void => {
            this.describe(sorted, '横向 ');
          }
        }),
        itemBuilder: this.compactItem
      })

      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
