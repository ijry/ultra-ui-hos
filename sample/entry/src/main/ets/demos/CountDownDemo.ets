import { UPCountDown, UPCountDownFinishEvent, UPCountDownProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CountDownDemo {
  @State private seconds: number = 75;
  @State private message: string = '倒计时运行中';

  build() {
    Column({ space: 12 }) {
      Text('倒计时').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPCountDown({ props: new UPCountDownProps({ remainTime: this.seconds, showDays: false,
        onFinish: (event: UPCountDownFinishEvent): void => { this.message = '已完成：' + String(event.remainTime); } }) })
      Text('剩余秒数：' + String(this.seconds) + '，' + this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
