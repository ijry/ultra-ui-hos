import {
  UPAvatar,
  UPAvatarProps,
  UPCell,
  UPCellGroup,
  UPCellGroupProps,
  UPCellProps,
  UPIcon,
  UPIconProps
} from '@lingyun/ultra-ui-hos';

/**
 * 复刻上游 `pages/template/wxCenter/index.vue` 的个人中心场景。
 * ArkTS port of the upstream user-center template: profile header plus grouped cells.
 * 头像原为远程图，这里用文字头像占位（组件库不加载远程图）。
 */
@Component
export struct TemplateMineDemo {
  @State private message: string = '点击任意入口查看回传';

  private tap(name: string): void {
    this.message = '进入：' + name;
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        UPAvatar({ props: new UPAvatarProps({ text: 'U', size: 60 }) })
        Column({ space: 6 }) {
          Text('ultra-ui plus').fontSize(18).fontColor('#303133').fontWeight(FontWeight.Medium)
          Text('鸿蒙号：test').fontSize(14).fontColor('#909399')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        UPIcon({ props: new UPIconProps({ name: 'scan', size: 24, color: '#969799' }) })
        UPIcon({ props: new UPIconProps({ name: 'arrow-right', size: 20, color: '#969799' }) })
      }
      .width('100%')
      .padding(16)
      .alignItems(VerticalAlign.Center)

      UPCellGroup({ props: new UPCellGroupProps({ inset: true }) }) {
        UPCell({ props: new UPCellProps({ title: '支付', icon: 'rmb-circle', arrow: true, clickable: true,
          onClick: (): void => { this.tap('支付'); } }) })
      }
      UPCellGroup({ props: new UPCellGroupProps({ inset: true }) }) {
        UPCell({ props: new UPCellProps({ title: '收藏', icon: 'star', arrow: true, clickable: true,
          onClick: (): void => { this.tap('收藏'); } }) })
        UPCell({ props: new UPCellProps({ title: '相册', icon: 'photo', arrow: true, clickable: true,
          onClick: (): void => { this.tap('相册'); } }) })
        UPCell({ props: new UPCellProps({ title: '卡券', icon: 'coupon', arrow: true, clickable: true,
          onClick: (): void => { this.tap('卡券'); } }) })
        UPCell({ props: new UPCellProps({ title: '关注', icon: 'heart', arrow: true, clickable: true,
          onClick: (): void => { this.tap('关注'); } }) })
      }
      UPCellGroup({ props: new UPCellGroupProps({ inset: true }) }) {
        UPCell({ props: new UPCellProps({ title: '设置', icon: 'setting', arrow: true, clickable: true,
          onClick: (): void => { this.tap('设置'); } }) })
      }
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
        .padding({ left: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f3f4f6')
    .alignItems(HorizontalAlign.Start)
  }
}
