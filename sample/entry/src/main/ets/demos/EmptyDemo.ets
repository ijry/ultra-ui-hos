import { UPEmpty, UPEmptyProps } from '@lingyun/ultra-ui-hos';

@Component
export struct EmptyDemo {
  build() {
    Column({ space: 18 }) {
      Text('空状态')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPEmpty({ props: new UPEmptyProps({
        mode: 'search',
        text: '没有匹配的数据',
        iconSize: 72,
        width: '100%',
        height: 148
      }) })
      UPEmpty({ props: new UPEmptyProps({
        mode: 'unrecognized',
        text: '未知模式会安全回退为数据空状态',
        iconColor: '#909399',
        iconSize: 56,
        width: '100%',
        height: 120
      }) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
