import { UPSwipeAction, UPSwipeActionItem, UPSwipeActionItemProps, UPSwipeActionOption, UPSwipeActionProps, UPSwipeActionSelectEvent } from '@lingyun/ultra-ui-hos';

@Component
export struct SwipeActionItemDemo {
  @State private message: string = '拖动超过 20vp 触发开启';
  private select(event: UPSwipeActionSelectEvent): void { this.message = '选中第 ' + event.index + ' 项'; }
  build() {
    Column({ space: 12 }) {
      Text('滑动操作项').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSwipeAction({ props: new UPSwipeActionProps({ autoClose: true }) }) {
        UPSwipeActionItem({ props: new UPSwipeActionItemProps({ name: 'demo', threshold: 20,
          options: [{ label: '标记', background: '#2979ff' }, { label: '删除', background: '#fa3534' }],
          onSelect: (event: UPSwipeActionSelectEvent): void => { this.select(event); } }) }) {
          Text('独立选项演示').fontSize(14).padding(16)
        }
      }
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
