import { UPRate, UPRateChangeEvent, UPRateProps } from '@lingyun/ultra-ui-hos';

@Component
export struct RateDemo {
  @State private value: number = 3;
  @State private message: string = '点击星级评分';

  private change(event: UPRateChangeEvent): void {
    this.value = event.value;
    this.message = '评分：' + String(event.value);
  }

  build() {
    Column({ space: 18 }) {
      Text('评分')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPRate({ props: new UPRateProps({ modelValue: this.value, onChange: (event: UPRateChangeEvent): void => { this.change(event); } }) })
      UPRate({ props: new UPRateProps({ value: 4, count: 6, activeColor: 'warning', size: 24 }) })
      UPRate({ props: new UPRateProps({ value: 2, disabled: true }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
