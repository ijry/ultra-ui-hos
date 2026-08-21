import { UPTabs, UPTabsClickEvent, UPTabsItemData, UPTabsProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TabsDemo {
  @State private current: number = 0;
  @State private message: string = '受控索引：0';
  private list: Array<UPTabsItemData> = [{ name: '推荐', badge: '3' }, { name: '最新' }, { name: '已禁用', disabled: true }, { name: '关注' }, { name: '收藏' }];
  private change(event: UPTabsClickEvent): void { this.current = event.index; this.message = '切换到：' + String(event.item.name); }
  build() {
    Column({ space: 14 }) {
      UPTabs({ props: new UPTabsProps({ list: this.list, current: this.current, onCurrentChange: (index: number): void => { this.current = index; }, onClick: (event: UPTabsClickEvent): void => { this.message = '点击：' + String(event.item.name); }, onChange: (event: UPTabsClickEvent): void => { this.change(event); }, onLongPress: (event: UPTabsClickEvent): void => { this.message = '长按：' + String(event.item.name); } }) })
      Text(this.message).fontSize(13).fontColor('#606266')
      Text('当前内容：' + String(this.list[this.current].name)).fontSize(16).fontColor('#2979ff')
      UPTabs({ props: new UPTabsProps({ list: this.list.slice(0, 3), current: 1, scrollable: false, shapeMode: 'capsule', lineColor: '#67c23a' }) })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
