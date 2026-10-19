import {
  UPLoadmoreProps,
  UPPullRefresh,
  UPPullRefreshProps,
  UPPullRefreshScrollEvent
} from '@lingyun/ultra-ui-hos';

@Component
export struct PullRefreshDemo {
  @State private refreshing: boolean = false;
  @State private rows: Array<string> = [];
  @State private status: string = '在内容区顶部下拉即可触发刷新';
  @State private loadStatus: string = 'loadmore';
  private timerId: number = -1;
  private round: number = 1;

  aboutToAppear(): void {
    this.rows = this.buildRows(this.round);
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

  private buildRows(round: number): Array<string> {
    const list: Array<string> = [];
    for (let index = 0; index < 12; index += 1) {
      list.push('第 ' + String(round) + ' 批 · 数据 ' + String(index + 1));
    }
    return list;
  }

  @Builder
  private listBody() {
    Column() {
      ForEach(this.rows, (row: string): void => {
        Row() {
          Text(row).fontSize(14).fontColor('#303133')
        }
        .width('100%')
        .height(44)
        .padding({ left: 14, right: 14 })
        .alignItems(VerticalAlign.Center)
        .border({ width: { bottom: 0.5 }, color: '#f2f2f2' })
      }, (row: string): string => row)
    }
    .width('100%')
  }

  build() {
    Column({ space: 14 }) {
      Text('三态下拉刷新与触底加载')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPPullRefresh({
        props: new UPPullRefreshProps({
          refreshing: this.refreshing,
          threshold: 60,
          maxDistance: 110,
          showLoadmore: true,
          loadmoreProps: new UPLoadmoreProps({ status: this.loadStatus, line: true }),
          customStyle: { height: 300, backgroundColor: '#ffffff' },
          onRefresh: (): void => {
            this.status = '正在刷新，1.2 秒后自动结束';
            this.stopTimer();
            this.timerId = setTimeout((): void => {
              this.timerId = -1;
              this.round = this.round + 1;
              this.rows = this.buildRows(this.round);
              this.loadStatus = 'loadmore';
              this.refreshing = false;
              this.status = '刷新完成，已载入第 ' + String(this.round) + ' 批数据';
            }, 1200);
          },
          onLoadmore: (): void => {
            this.loadStatus = 'nomore';
            this.status = '已触底，加载状态切换为 nomore';
          },
          onStatusChange: (state: string): void => {
            this.status = '下拉状态：' + state;
          },
          onScroll: (event: UPPullRefreshScrollEvent): void => {
            if (event.atTop) {
              this.status = '已回到顶部，可继续下拉刷新';
            }
          }
        }),
        contentBuilder: this.listBody
      })
      Row({ space: 12 }) {
        Button('手动开始刷新')
          .fontSize(13)
          .enabled(!this.refreshing)
          .onClick((): void => {
            this.refreshing = true;
          })
        Button('手动结束刷新')
          .fontSize(13)
          .enabled(this.refreshing)
          .onClick((): void => {
            this.stopTimer();
            this.refreshing = false;
            this.status = '已通过 refreshing 绑定结束刷新';
          })
      }
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
