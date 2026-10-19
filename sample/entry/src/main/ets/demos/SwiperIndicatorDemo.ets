import { UPSwiperIndicator, UPSwiperIndicatorClickEvent, UPSwiperIndicatorProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SwiperIndicatorDemo {
  @State private current: number = 1;
  @State private message: string = '点击指示器切换索引';

  private select(event: UPSwiperIndicatorClickEvent): void {
    this.current = event.index;
    this.message = '选中索引：' + String(event.index);
  }

  build() {
    Column({ space: 18 }) {
      Text('点状模式').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSwiperIndicator({
        props: new UPSwiperIndicatorProps({ current: this.current, count: 4, mode: 'dot', onClick: (event: UPSwiperIndicatorClickEvent): void => { this.select(event); } })
      })
      Text('线状模式').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSwiperIndicator({ props: new UPSwiperIndicatorProps({ current: this.current, count: 4, mode: 'line' }) })
      Text('数字模式').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSwiperIndicator({ props: new UPSwiperIndicatorProps({ current: this.current, count: 4, mode: 'number' }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
