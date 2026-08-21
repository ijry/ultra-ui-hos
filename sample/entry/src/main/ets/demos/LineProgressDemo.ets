import { UPLineProgress, UPLineProgressProps } from '@lingyun/ultra-ui-hos';

@Component
export struct LineProgressDemo {
  build() {
    Column({ space: 18 }) {
      Text('进度状态')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPLineProgress({ props: new UPLineProgressProps({ percentage: 20 }) })
      UPLineProgress({ props: new UPLineProgressProps({ percentage: 55, activeColor: 'success', height: 14 }) })
      UPLineProgress({ props: new UPLineProgressProps({ percentage: 85, activeColor: 'warning', striped: true }) })
      UPLineProgress({ props: new UPLineProgressProps({ percentage: 100, activeColor: 'error', showText: false }) })
    }
    .width('100%')
  }
}
