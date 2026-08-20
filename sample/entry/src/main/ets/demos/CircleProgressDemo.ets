import { UPCircleProgress, UPCircleProgressProps } from '@lingyun/ultra-ui-hos';
@Component
export struct CircleProgressDemo {
  build() {
    Column({ space: 18 }) {
      Text('环形进度').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      Row({ space: 20 }) {
        UPCircleProgress({ props: new UPCircleProgressProps({ percentage: 30 }) })
        UPCircleProgress({ props: new UPCircleProgressProps({ percentage: 0, activeColor: 'primary', width: 112 }) })
        UPCircleProgress({ props: new UPCircleProgressProps({ percentage: 100, activeColor: 'success' }) })
      }.width('100%').justifyContent(FlexAlign.SpaceAround)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
