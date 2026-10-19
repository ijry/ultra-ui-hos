import { UPTabbar, UPTabbarChangeEvent, UPTabbarItemData, UPTabbarProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TabbarDemo {
  @State private current: number = 0;
  @State private message: string = '请选择底部导航项';
  private list: Array<UPTabbarItemData> = [
    { name: '首页', value: 'home', icon: 'home', activeIcon: 'home', badge: '2', url: '/home', linkType: 'switchTab' },
    { name: '消息', value: 'message', icon: 'chat', badge: '5', url: '/message', linkType: 'navigateTo' },
    { name: '设置', value: 'settings', icon: 'setting', disabled: true, url: '/settings', linkType: 'navigateTo' },
    { name: '我的', value: 'profile', icon: 'account', url: '/profile', linkType: 'navigateTo' }
  ];

  private changed(event: UPTabbarChangeEvent): void {
    this.current = event.index;
    this.message = '切换：' + String(event.value) + ' / ' + String(event.linkType);
  }

  build() {
    Column({ space: 14 }) {
      Text('受控底部导航').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      Text('禁用项不会触发回调，url/linkType 仅通过事件回传。').fontSize(13).fontColor('#909399').width('100%')
      UPTabbar({
        props: new UPTabbarProps({
          list: this.list,
          current: this.current,
          fixed: false,
          placeholder: false,
          safeAreaInsetBottom: true,
          onChange: (event: UPTabbarChangeEvent): void => {
            this.changed(event);
          }
        })
      })
      Text('当前索引：' + String(this.current)).fontSize(13).fontColor('#606266')
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
