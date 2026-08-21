import { UPGrid, UPGridItem, UPGridItemClickEvent, UPGridItemProps, UPGridProps } from '@lingyun/ultra-ui-hos';

@Component
export struct GridItemDemo {
  @State private message: string = '分别点击有 name 和无 name 的网格项';

  private selected(event: UPGridItemClickEvent): void {
    this.message = 'name=' + String(event.name) + ' index=' + event.index;
  }

  build() {
    Column({ space: 18 }) {
      Text('网格项点击值')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPGrid({ props: new UPGridProps({ col: 2, gap: '10px', border: true }) }) {
        UPGridItem({ props: new UPGridItemProps({
          name: 'named-item',
          bgColor: '#ecf5ff',
          onClick: (event: UPGridItemClickEvent): void => {
            this.selected(event);
          }
        }) }) {
          Column({ space: 4 }) {
            Text('有 name').fontSize(15).fontColor('#2979ff')
            Text('named-item').fontSize(12).fontColor('#909399')
          }
          .width('100%')
          .height(72)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        UPGridItem({ props: new UPGridItemProps({
          bgColor: '#fdf6ec',
          onClick: (event: UPGridItemClickEvent): void => {
            this.selected(event);
          }
        }) }) {
          Column({ space: 4 }) {
            Text('无 name').fontSize(15).fontColor('#ff9900')
            Text('回退到 index').fontSize(12).fontColor('#909399')
          }
          .width('100%')
          .height(72)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      Text('未传 name 时，事件 name 使用当前项的 index。')
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      Text(this.message)
        .fontSize(13)
        .fontColor('#606266')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
