import { UPTabbarItem, UPTabbarItemClickEvent, UPTabbarItemProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TabbarItemDemo {
  @State private message: string = '点击独立导航项';

  private clicked(event: UPTabbarItemClickEvent): void {
    this.message = '点击：' + String(event.name) + ' / index=' + String(event.index);
  }

  build() {
    Column({ space: 16 }) {
      Text('独立底部导航项').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      Row() {
        UPTabbarItem({
          props: new UPTabbarItemProps({ name: '首页', icon: 'home', active: true, index: 0, badge: '1', onClick: (event: UPTabbarItemClickEvent): void => { this.clicked(event); } })
        }).layoutWeight(1)
        UPTabbarItem({
          props: new UPTabbarItemProps({ name: '收藏', icon: 'star', index: 1, onClick: (event: UPTabbarItemClickEvent): void => { this.clicked(event); } })
        }).layoutWeight(1)
        UPTabbarItem({
          props: new UPTabbarItemProps({ name: '禁用', icon: 'setting', disabled: true, index: 2, onClick: (event: UPTabbarItemClickEvent): void => { this.clicked(event); } })
        }).layoutWeight(1)
      }
      .width('100%')
      .height(68)
      .backgroundColor('#ffffff')
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
