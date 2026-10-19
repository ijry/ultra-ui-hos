import { UPCountTo, UPCountToFinishEvent, UPCountToProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CountToDemo {
  @State private result: number = 0;

  build() {
    Column({ space: 12 }) {
      Text('数字滚动').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPCountTo({ props: new UPCountToProps({ startValue: 0, endValue: 128.5, duration: 1600,
        decimals: 1, autoplay: true, onFinish: (event: UPCountToFinishEvent): void => { this.result = event.value; } }) })
      Text('结束值：' + this.result.toFixed(1)).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
