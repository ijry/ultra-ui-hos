import { UPCol, UPColProps, UPRow, UPRowProps } from '@lingyun/ultra-ui-hos';

@Component
export struct RowDemo {
  @State private message: string = '点击行或列查看回传';

  build() {
    Column({ space: 18 }) {
      Text('12 栅格基础行')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPRow({ props: new UPRowProps({ gutter: 12 }) }) {
        UPCol({ props: new UPColProps({ span: 6 }) }) {
          Column() { Text('span=6').fontSize(13).fontColor('#ffffff') }
          .width('100%').height(44).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#2979ff').borderRadius(4)
        }
        UPCol({ props: new UPColProps({ span: 6 }) }) {
          Column() { Text('span=6').fontSize(13).fontColor('#ffffff') }
          .width('100%').height(44).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#2979ff').borderRadius(4)
        }
      }
      Text('gutter=12 时相邻列保持半间距内边距')

      Text('偏移与换行')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPRow({ props: new UPRowProps({ gutter: 8 }) }) {
        UPCol({ props: new UPColProps({ span: 4, offset: 2 }) }) {
          Column() { Text('span=4 offset=2').fontSize(12).fontColor('#ffffff') }
          .width('100%').height(40).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#5cdbd3').borderRadius(4)
        }
        UPCol({ props: new UPColProps({ span: 4 }) }) {
          Column() { Text('span=4').fontSize(12).fontColor('#ffffff') }
          .width('100%').height(40).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#5cdbd3').borderRadius(4)
        }
        UPCol({ props: new UPColProps({ span: 8 }) }) {
          Column() { Text('span=8 换行').fontSize(12).fontColor('#ffffff') }
          .width('100%').height(40).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#ff9900').borderRadius(4)
        }
      }
      Text('span 之和超过 12 时自动换行')

      Text('对齐方式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPRow({ props: new UPRowProps({ justify: 'space-between', align: 'center' }) }) {
        UPCol({ props: new UPColProps({ span: 3 }) }) {
          Column() { Text('A').fontSize(13).fontColor('#ffffff') }
          .width('100%').height(36).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#909399').borderRadius(4)
        }
        UPCol({ props: new UPColProps({ span: 3 }) }) {
          Column() { Text('B').fontSize(13).fontColor('#ffffff') }
          .width('100%').height(36).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#909399').borderRadius(4)
        }
        UPCol({ props: new UPColProps({ span: 3 }) }) {
          Column() { Text('C').fontSize(13).fontColor('#ffffff') }
          .width('100%').height(36).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#909399').borderRadius(4)
        }
      }
      Text('justify=space-between 均匀分布')

      UPRow({ props: new UPRowProps({
        gutter: 8,
        onClick: (): void => { this.message = '点击了行容器'; }
      }) }) {
        UPCol({ props: new UPColProps({
          span: 12,
          onClick: (): void => { this.message = '点击了列容器'; }
        }) }) {
          Column() { Text('点击我').fontSize(14).fontColor('#2979ff') }
          .width('100%').height(40).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .backgroundColor('#ecf5ff').borderRadius(4)
        }
      }
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
