import { UPCol, UPColProps } from '@lingyun/ultra-ui-hos';

@Component
export struct ColDemo {
  @State private message: string = '列可脱离行安全渲染';

  build() {
    Column({ space: 18 }) {
      Text('独立列（脱离 UPRow）')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCol({ props: new UPColProps({ span: 8 }) }) {
        Column() { Text('span=8 独立列').fontSize(13).fontColor('#ffffff') }
        .width('100%').height(44).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .backgroundColor('#2979ff').borderRadius(4)
      }
      Text('脱离父行时 gutter 回退为 0，仍按 span 表现为百分比列')

      Text('内部对齐')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCol({ props: new UPColProps({ span: 12, textAlign: 'center' }) }) {
        Column() { Text('textAlign=center').fontSize(13).fontColor('#ffffff') }
        .width('100%').height(40).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .backgroundColor('#5cdbd3').borderRadius(4)
      }
      UPCol({ props: new UPColProps({ span: 12, textAlign: 'right' }) }) {
        Column() { Text('textAlign=right').fontSize(13).fontColor('#ffffff') }
        .width('100%').height(40).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .backgroundColor('#5cdbd3').borderRadius(4)
      }
      Text('textAlign 决定列内子内容水平锚点')

      Text('justify 与 align')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCol({ props: new UPColProps({ span: 12, justify: 'center', align: 'center' }) }) {
        Column() { Text('justify=center align=center').fontSize(13).fontColor('#ffffff') }
        .width('100%').height(48).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .backgroundColor('#ff9900').borderRadius(4)
      }
      Text('justify 控制主轴、align 控制交叉轴')

      UPCol({ props: new UPColProps({
        span: 12,
        onClick: (): void => { this.message = '点击了独立列'; }
      }) }) {
        Column() { Text('点击我').fontSize(14).fontColor('#2979ff') }
        .width('100%').height(40).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .backgroundColor('#ecf5ff').borderRadius(4)
      }
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
