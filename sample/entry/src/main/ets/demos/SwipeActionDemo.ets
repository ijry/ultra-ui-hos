import { UPSwipeAction, UPSwipeActionItem, UPSwipeActionItemProps, UPSwipeActionOption, UPSwipeActionProps, UPSwipeActionSelectEvent } from '@lingyun/ultra-ui-hos';

@Component
export struct SwipeActionDemo {
  @State private message: string = '向左拖动显示操作';
  private options(): Array<UPSwipeActionOption> {
    return [{ label: '删除', background: '#fa3534' }];
  }
  build() {
    Column({ space: 12 }) {
      Text('滑动操作').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSwipeAction({ props: new UPSwipeActionProps({ autoClose: true }) }) {
        UPCardLike()
      }
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}

@Component
struct UPCardLike {
  build() {
    UPSwipeActionItem({ props: new UPSwipeActionItemProps({ name: 'first', threshold: 20, options: [{ label: '删除', background: '#fa3534' }],
      onSelect: (): void => {} }) }) {
      Text('第一条消息').fontSize(14).padding(16)
    }
  }
}
