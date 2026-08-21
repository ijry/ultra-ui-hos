import { UPLine, UPLineProps } from '@lingyun/ultra-ui-hos';

@Component
export struct LineDemo {
  build() {
    Column({ space: 18 }) {
      Text('基础线条')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPLine({ props: new UPLineProps() })
      UPLine({ props: new UPLineProps({ color: 'primary', length: '80%', hairline: false }) })
      Text('竖向线条与虚线兼容')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 18 }) {
        UPLine({ props: new UPLineProps({ direction: 'col', length: 48, color: 'success' }) })
        UPLine({ props: new UPLineProps({ direction: 'col', length: 48, color: 'warning', dashed: true, hairline: false }) })
        Text('dashed 在鸿蒙原生版保持安全静态表现')
          .fontSize(13)
          .fontColor('#909399')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
  }
}
