import { UPBadge, UPBadgeProps, UPIcon, UPIconProps } from '@lingyun/ultra-ui-hos';

/**
 * 复刻上游 `pages/template/submitBar/index.vue` 的商品底部操作栏场景。
 * ArkTS port of the upstream商品 submit-bar template: left icon group with a cart
 * badge, right dual action buttons. Pure layout, no host callbacks beyond taps.
 */
@Component
export struct TemplateSubmitBarDemo {
  @State private message: string = '点击右侧按钮查看回传';

  @Builder
  private navItem(icon: string, label: string) {
    Column({ space: 2 }) {
      UPIcon({ props: new UPIconProps({ name: icon, size: 20, color: '#606266' }) })
      Text(label).fontSize(10).fontColor('#606266').maxLines(1)
    }
    .alignItems(HorizontalAlign.Center)
    .width(48)
  }

  build() {
    Column({ space: 16 }) {
      Text('商品底部操作栏')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row() {
        Row({ space: 12 }) {
          this.navItem('server-fill', '客服')
          this.navItem('home', '店铺')
          Stack({ alignContent: Alignment.TopEnd }) {
            this.navItem('shopping-cart', '购物车')
            UPBadge({ props: new UPBadgeProps({ value: 9, type: 'error' }) })
          }
        }
        Blank()
        Row({ space: 12 }) {
          Text('加入购物车')
            .fontSize(14)
            .fontColor('#ffffff')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('#ed3f14')
            .borderRadius(18)
            .onClick((): void => { this.message = '加入购物车'; })
          Text('立即购买')
            .fontSize(14)
            .fontColor('#ffffff')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('#ff7900')
            .borderRadius(18)
            .onClick((): void => { this.message = '立即购买'; })
        }
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .border({ width: { top: 1, bottom: 1 }, color: '#ebeef5' })
      .alignItems(VerticalAlign.Center)
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
  }
}
