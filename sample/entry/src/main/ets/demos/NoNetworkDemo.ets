import {
  UPButton,
  UPButtonProps,
  UPNoNetwork,
  UPNoNetworkProps,
  UPNoNetworkRetryEvent,
  UPNoNetworkStatusEvent
} from '@lingyun/ultra-ui-hos';

@Component
export struct NoNetworkDemo {
  @State private connected: boolean = false;
  @State private message: string = '当前模拟为无网络状态';

  private toggleConnection(): void {
    this.connected = !this.connected;
    this.message = this.connected ? '已模拟恢复 Wi-Fi' : '已模拟断开网络';
  }

  build() {
    Column({ space: 14 }) {
      Text('无网络占位')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPButton({
        props: new UPButtonProps({
          text: this.connected ? '模拟断网' : '模拟恢复网络',
          type: 'primary',
          onClick: (): void => {
            this.toggleConnection();
          }
        })
      })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      Stack() {
        Text('业务内容区域')
          .fontSize(14)
          .fontColor('#606266')
          .backgroundColor('#ffffff')
          .width('100%')
          .height(180)
          .textAlign(TextAlign.Center)
          .align(Alignment.Center)
        UPNoNetwork({
          props: new UPNoNetworkProps({
            isConnected: this.connected,
            networkType: this.connected ? 'wifi' : 'none',
            onRetry: (event: UPNoNetworkRetryEvent): void => {
              this.message = '重试事件：' + event.networkType;
            },
            onConnected: (event: UPNoNetworkStatusEvent): void => {
              this.message = '连接状态：' + event.networkType;
            },
            onDisconnected: (event: UPNoNetworkStatusEvent): void => {
              this.message = '连接状态：' + event.networkType;
            }
          })
        })
      }
      .width('100%')
      .height(220)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
