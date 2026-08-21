import { UPList, UPListItem, UPListItemProps, UPListProps, UPListScrollEvent } from '@lingyun/ultra-ui-hos';

@Component
export struct ListDemo {
  @State private message: string = '等待滚动';
  @State private refreshing: boolean = false;
  private rows: Array<string> = ['顶部', '基础', '锚点目标', '状态', '底部'];

  @Builder
  private rowsBuilder() {
    ForEach(this.rows, (label: string, index: number): void => {
      UPListItem({ props: new UPListItemProps({ anchor: index === 2 ? 'target' : '', customStyle: { padding: 14 } }) }) {
        Text(label + '列表项').fontSize(15).fontColor('#303133')
      }
    }, (label: string): string => label)
  }

  build() {
    Column({ space: 12 }) {
      UPList({
        props: new UPListProps({
          height: 230,
          scrollTop: 0,
          scrollIntoView: 'target',
          upperThreshold: 0,
          lowerThreshold: 40,
          refresherEnabled: true,
          refresherTriggered: this.refreshing,
          customStyle: { borderRadius: 10 },
          onScroll: (event: UPListScrollEvent): void => { this.message = '滚动偏移：' + String(Math.round(event.offset)); },
          onScrollToUpper: (): void => { this.message = '进入顶部阈值'; },
          onScrollToLower: (): void => { this.message = '进入底部阈值'; },
          onRefresherRefresh: (): void => { this.message = '收到刷新请求'; },
          onRefresherTriggeredChange: (triggered: boolean): void => { this.refreshing = triggered; }
        })
      }) {
        this.rowsBuilder()
      }
      Text(this.message).fontSize(13).fontColor('#606266')
      Text('刷新状态：' + (this.refreshing ? '请求中' : '空闲')).fontSize(13).fontColor('#2979ff')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
