import {
  UPRefreshVirtualList,
  UPRefreshVirtualListController,
  UPRefreshVirtualListProps,
  UPVirtualListItem,
  UPVirtualListItemSlot
} from '@lingyun/ultra-ui-hos';

@Component
export struct RefreshVirtualListDemo {
  @State private items: Array<UPVirtualListItem> = [];
  @State private status: string = '下拉刷新 + 虚拟窗口的组合容器';
  private controller: UPRefreshVirtualListController = new UPRefreshVirtualListController();
  private timerId: number = -1;
  private round: number = 1;

  aboutToAppear(): void {
    this.items = this.buildItems(this.round, 120);
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
  }

  private buildItems(round: number, total: number): Array<UPVirtualListItem> {
    const list: Array<UPVirtualListItem> = [];
    for (let index = 0; index < total; index += 1) {
      list.push({
        id: String(round) + '-' + String(index + 1),
        label: '第 ' + String(round) + ' 批 · 记录 ' + String(index + 1),
        value: index + 1
      });
    }
    return list;
  }

  @Builder
  private customItem(slot: UPVirtualListItemSlot) {
    Row({ space: 10 }) {
      Text(String(slot.item.label)).fontSize(14).fontColor('#303133').layoutWeight(1)
      Text('#' + String(slot.index + 1)).fontSize(12).fontColor('#909399')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 0.5 }, color: '#f2f2f2' })
  }

  build() {
    Column({ space: 14 }) {
      Text('刷新虚拟列表与控制器方法')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPRefreshVirtualList({
        props: new UPRefreshVirtualListProps({
          listData: this.items,
          itemHeight: 46,
          buffer: 6,
          keyField: 'id',
          showScrollbar: true,
          controller: this.controller,
          customStyle: { height: 300, borderRadius: 10 },
          onRefresh: (): void => {
            this.status = '刷新中，1.2 秒后调用 finishRefresh()';
            this.stopTimer();
            this.timerId = setTimeout((): void => {
              this.timerId = -1;
              this.round = this.round + 1;
              this.items = this.buildItems(this.round, 120);
              this.controller.finishRefresh();
              this.status = '刷新完成，当前为第 ' + String(this.round) + ' 批数据';
            }, 1200);
          },
          onScroll: (scrollTop: number): void => {
            this.status = '滚动偏移 ' + String(Math.round(scrollTop));
          }
        }),
        itemBuilder: this.customItem
      })
      Row({ space: 12 }) {
        Button('scrollToTop()')
          .fontSize(13)
          .onClick((): void => {
            this.controller.scrollToTop();
            this.status = '已调用控制器 scrollToTop()';
          })
        Button('scrollTo(第 60 行)')
          .fontSize(13)
          .onClick((): void => {
            this.controller.scrollTo(59 * 46);
            this.status = '已调用控制器 scrollTo()';
          })
      }
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
