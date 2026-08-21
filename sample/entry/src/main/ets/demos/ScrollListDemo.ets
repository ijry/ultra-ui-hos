import {
  UPScrollList,
  UPScrollListEdgeEvent,
  UPScrollListProps,
  UPScrollListScrollEvent
} from '@lingyun/ultra-ui-hos';

@Component
export struct ScrollListDemo {
  @State private status: string = '向右滑动卡片';
  private labels: Array<string> = ['新品', '推荐', '热门', '家居', '数码', '运动'];

  @Builder
  private cards() {
    Row({ space: 12 }) {
      ForEach(this.labels, (label: string, index: number): void => {
        Column({ space: 8 }) {
          Text(label).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#303133')
          Text('本地卡片 ' + String(index + 1)).fontSize(12).fontColor('#909399')
        }
        .width(132)
        .height(92)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(index % 2 === 0 ? '#ecf5ff' : '#f0f9eb')
        .borderRadius(10)
      }, (label: string): string => label)
    }
    .padding({ right: 16 })
  }

  build() {
    Column({ space: 14 }) {
      Text('横向滚动与比例指示器').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133')
      UPScrollList({
        props: new UPScrollListProps({
          indicatorWidth: 72,
          indicatorBarWidth: 24,
          customStyle: { height: 118 },
          onScroll: (event: UPScrollListScrollEvent): void => {
            this.status = '偏移 ' + String(Math.round(event.offset)) + ' / ' + String(Math.round(event.maxOffset));
          },
          onLeft: (_event: UPScrollListEdgeEvent): void => { this.status = '已到左边界'; },
          onRight: (_event: UPScrollListEdgeEvent): void => { this.status = '已到右边界'; }
        })
      }) {
        this.cards()
      }
      Text(this.status).fontSize(13).fontColor('#606266')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
