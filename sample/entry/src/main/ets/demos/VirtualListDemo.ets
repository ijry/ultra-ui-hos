import {
  UPVirtualList,
  UPVirtualListItem,
  UPVirtualListItemSlot,
  UPVirtualListProps,
  UPVirtualListScrollEvent
} from '@lingyun/ultra-ui-hos';

@Component
export struct VirtualListDemo {
  @State private items: Array<UPVirtualListItem> = [];
  @State private status: string = '共 200 条数据，仅渲染可视窗口';
  @State private jumpTop: number = 0;

  aboutToAppear(): void {
    this.items = this.buildItems(200);
  }

  private buildItems(total: number): Array<UPVirtualListItem> {
    const list: Array<UPVirtualListItem> = [];
    for (let index = 0; index < total; index += 1) {
      list.push({
        id: index + 1,
        label: '虚拟列表第 ' + String(index + 1) + ' 行',
        description: index % 5 === 0 ? '每 5 行标记一次' : '',
        disabled: index % 17 === 0
      });
    }
    return list;
  }

  @Builder
  private customItem(slot: UPVirtualListItemSlot) {
    Row({ space: 10 }) {
      Text(String(slot.index + 1))
        .fontSize(12)
        .fontColor('#ffffff')
        .width(26)
        .height(26)
        .borderRadius(13)
        .textAlign(TextAlign.Center)
        .backgroundColor(slot.index % 2 === 0 ? '#3c9cff' : '#5ac725')
      Text(String(slot.item.label))
        .fontSize(14)
        .fontColor('#303133')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(slot.index % 2 === 0 ? '#ffffff' : '#fafafa')
  }

  build() {
    Column({ space: 14 }) {
      Text('默认行渲染与滚动窗口')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPVirtualList({
        props: new UPVirtualListProps({
          listData: this.items,
          itemHeight: 48,
          buffer: 6,
          keyField: 'id',
          showScrollbar: true,
          scrollTop: this.jumpTop,
          customStyle: { height: 260, borderRadius: 10 },
          onScroll: (event: UPVirtualListScrollEvent): void => {
            this.status = '偏移 ' + String(Math.round(event.scrollTop)) +
              '，窗口 ' + String(event.start + 1) + ' - ' + String(event.end);
          }
        })
      })
      Row({ space: 12 }) {
        Button('回到顶部')
          .fontSize(13)
          .onClick((): void => {
            this.jumpTop = 0;
          })
        Button('跳到第 100 行')
          .fontSize(13)
          .onClick((): void => {
            this.jumpTop = 99 * 48;
          })
      }
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')

      Text('自定义行 Builder')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPVirtualList({
        props: new UPVirtualListProps({
          listData: this.items,
          itemHeight: 44,
          height: 200,
          keyField: 'id'
        }),
        itemBuilder: this.customItem
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
