import { UPCoupon, UPCouponProps, UPIcon, UPIconProps } from '@lingyun/ultra-ui-hos';

/**
 * 复刻上游 `pages/template/coupon/index.vue` 的优惠券列表场景。
 * ArkTS port of the upstream coupon template: a stack of coupon cards in different
 * styles, rebuilt on top of the library's own UPCoupon plus a店铺 header card.
 */
@Component
export struct TemplateCouponDemo {
  @State private status: string = '点击优惠券的按钮查看回传';

  private use(name: string): void {
    this.status = '使用：' + name;
  }

  @Builder
  private storeCoupon() {
    Column({ space: 0 }) {
      Row() {
        Row({ space: 8 }) {
          Column().width(28).height(28).backgroundColor('#f3f4f6').borderRadius(14)
          Text('袜子精保护协会').fontSize(14).fontColor('#303133').fontWeight(FontWeight.Medium)
        }
        Blank()
        Text('进店')
          .fontSize(12)
          .fontColor('#ed3f14')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .border({ width: 1, color: '#ed3f14' })
          .borderRadius(12)
      }
      .width('100%')
      .padding({ bottom: 10 })
      Row() {
        Row() {
          Text('￥').fontSize(14).fontColor('#ed3f14')
          Text('3').fontSize(30).fontColor('#ed3f14').fontWeight(FontWeight.Bold)
          Column({ space: 2 }) {
            Text('满 88 减 3').fontSize(13).fontColor('#303133')
            Text('店铺优惠券').fontSize(11).fontColor('#909399')
            Text('2019.11.28 - 2020.01.24').fontSize(11).fontColor('#c0c4cc')
          }
          .margin({ left: 10 })
          .alignItems(HorizontalAlign.Start)
        }
        Blank()
        Text('去使用')
          .fontSize(13)
          .fontColor('#ffffff')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor('#ed3f14')
          .borderRadius(16)
          .onClick((): void => { this.use('店铺满88减3'); })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#ffffff')
    .borderRadius(8)
  }

  build() {
    Column({ space: 12 }) {
      UPCoupon({ props: new UPCouponProps({
        type: 'error',
        amount: 8,
        title: '【洗牙】8元无门槛红包',
        desc: '满 8.1 元可用 · 限最新版本客户端',
        time: '今日到期',
        actionText: '立即使用',
        onClick: (): void => { this.use('8元无门槛红包'); }
      }) })
      UPCoupon({ props: new UPCouponProps({
        type: 'primary',
        amount: 100,
        limit: '满 149 元可用',
        title: '限品类东券',
        desc: '仅可购买个人护理部分商品',
        time: '2020.01.01 - 2020.01.31',
        actionText: '立即使用',
        onClick: (): void => { this.use('满149减100'); }
      }) })
      this.storeCoupon()
      Text(this.status)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      Text('前两张用组件 UPCoupon 渲染，店铺券展示手动拼装的卡片样式。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#f3f4f6')
    .alignItems(HorizontalAlign.Start)
  }
}
