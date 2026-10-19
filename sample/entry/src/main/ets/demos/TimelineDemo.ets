import { UPTimeline, UPTimelineItem, UPTimelineProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TimelineDemo {
  @State private selected: string = '';
  private items: Array<UPTimelineItem> = [
    { title: '提交订单', content: '订单已创建', time: '10:00', color: '#2979ff', disabled: false },
    { title: '支付完成', content: '等待商家发货', time: '10:05', color: '#19be6b', disabled: false },
    { title: '已发货', content: '当前节点不可点击', time: '', color: '#ff9900', disabled: true }
  ];

  build() {
    Column({ space: 12 }) {
      Text('时间线').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPTimeline({ props: new UPTimelineProps({ items: this.items, direction: 'column',
        onItemClick: (item: UPTimelineItem, index: number): void => { this.selected = item.title + ' #' + String(index); } }) })
      Text('选中：' + (this.selected.length > 0 ? this.selected : '无')).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
