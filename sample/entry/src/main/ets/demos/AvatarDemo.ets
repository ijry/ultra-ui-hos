import { UPAvatar, UPAvatarClickEvent, UPAvatarProps } from '@lingyun/ultra-ui-hos';

@Component
export struct AvatarDemo {
  @State private message: string = '点击头像查看事件回传';

  private select(event: UPAvatarClickEvent): void {
    this.message = 'name=' + String(event.name) + '，text=' + event.text;
  }

  build() {
    Column({ space: 18 }) {
      Text('头像回退')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 14 }) {
        UPAvatar({ props: new UPAvatarProps({ text: '林', name: 'lingyun', randomBgColor: true, onClick: (event: UPAvatarClickEvent): void => { this.select(event); } }) })
        UPAvatar({ props: new UPAvatarProps({ text: 'UI', shape: 'square', bgColor: 'primary', size: 48, onClick: (event: UPAvatarClickEvent): void => { this.select(event); } }) })
        UPAvatar({ props: new UPAvatarProps({ icon: 'account', bgColor: 'success', size: 56, onClick: (event: UPAvatarClickEvent): void => { this.select(event); } }) })
      }
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
