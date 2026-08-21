import { UPGrid, UPGridItem, UPGridItemClickEvent, UPGridItemProps, UPGridProps } from '@lingyun/ultra-ui-hos';

@Component
export struct GridDemo {
  @State private message: string = '点击网格项查看回传';

  build() {
    Column({ space: 18 }) {
      Text('三列网格')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPGrid({ props: new UPGridProps({ col: 3, gap: '8px', border: true }) }) {
        UPGridItem({ props: new UPGridItemProps({
          name: 'grid-a',
          onClick: (event: UPGridItemClickEvent): void => {
            this.message = 'name=' + String(event.name) + ' index=' + event.index;
          }
        }) }) {
          Column() { Text('A').fontSize(16).fontColor('#2979ff') }
          .width('100%').height(56).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        UPGridItem({ props: new UPGridItemProps({
          name: 'grid-b',
          onClick: (event: UPGridItemClickEvent): void => {
            this.message = 'name=' + String(event.name) + ' index=' + event.index;
          }
        }) }) {
          Column() { Text('B').fontSize(16).fontColor('#2979ff') }
          .width('100%').height(56).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        UPGridItem({ props: new UPGridItemProps({
          name: 'grid-c',
          onClick: (event: UPGridItemClickEvent): void => {
            this.message = 'name=' + String(event.name) + ' index=' + event.index;
          }
        }) }) {
          Column() { Text('C').fontSize(16).fontColor('#2979ff') }
          .width('100%').height(56).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        UPGridItem({ props: new UPGridItemProps({
          name: 'grid-d',
          onClick: (event: UPGridItemClickEvent): void => {
            this.message = 'name=' + String(event.name) + ' index=' + event.index;
          }
        }) }) {
          Column() { Text('D').fontSize(16).fontColor('#2979ff') }
          .width('100%').height(56).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
      }
      Text('col=3 gap=8px border=true，末行不足时左对齐')

      Text('末行对齐')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPGrid({ props: new UPGridProps({ col: 3, gap: '8px', align: 'center' }) }) {
        UPGridItem({ props: new UPGridItemProps({ bgColor: '#ecf5ff' }) }) {
          Column() { Text('1').fontSize(15).fontColor('#2979ff') }
          .width('100%').height(48).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        UPGridItem({ props: new UPGridItemProps({ bgColor: '#ecf5ff' }) }) {
          Column() { Text('2').fontSize(15).fontColor('#2979ff') }
          .width('100%').height(48).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        UPGridItem({ props: new UPGridItemProps({ bgColor: '#ecf5ff' }) }) {
          Column() { Text('3').fontSize(15).fontColor('#2979ff') }
          .width('100%').height(48).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        UPGridItem({ props: new UPGridItemProps({ bgColor: '#ecf5ff' }) }) {
          Column() { Text('4').fontSize(15).fontColor('#2979ff') }
          .width('100%').height(48).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
      }
      Text('align=center 时不足一行的子项组水平居中')

      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
