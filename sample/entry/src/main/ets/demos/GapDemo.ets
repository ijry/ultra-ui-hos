import { UPGap, UPGapProps } from '@lingyun/ultra-ui-hos';

@Component
export struct GapDemo {
  build() {
    Column() {
      Text('上方内容')
        .fontSize(15)
        .fontColor('#303133')
        .width('100%')
        .padding(12)
        .backgroundColor('#ffffff')
      UPGap({ props: new UPGapProps({ height: 16, bgColor: '#f2f3f5' }) })
      Text('中间使用浅灰间隔')
        .fontSize(15)
        .fontColor('#303133')
        .width('100%')
        .padding(12)
        .backgroundColor('#ffffff')
      UPGap({ props: new UPGapProps({ height: 28, bgColor: 'primary', marginTop: 10, marginBottom: 10 }) })
      Text('下方内容')
        .fontSize(15)
        .fontColor('#303133')
        .width('100%')
        .padding(12)
        .backgroundColor('#ffffff')
    }
    .width('100%')
  }
}
