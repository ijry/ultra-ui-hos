import {
  UPCoupon,
  UPCouponActionSlot,
  UPCouponAmountSlot,
  UPCouponGradient,
  UPCouponInfoSlot,
  UPCouponProps,
  upCouponGradient
} from '@lingyun/ultra-ui-hos';

@Component
export struct CouponDemo {
  @State private status: string = '点击任意优惠券查看回传';
  @State private received: number = 0;

  private pick(name: string): void {
    this.received = this.received + 1;
    this.status = '第 ' + String(this.received) + ' 次领取：' + name;
  }

  private themeSummary(type: string): string {
    const gradient: UPCouponGradient | undefined = upCouponGradient(type);
    if (gradient === undefined) {
      return type + '：无内置渐变，使用默认浅红底';
    }
    return type + ' 渐变：' + gradient.from + ' → ' + gradient.to;
  }

  @Builder
  private customAmount(slot: UPCouponAmountSlot) {
    Column({ space: 2 }) {
      Text('立减')
        .fontSize(12)
        .fontColor('#ffffff')
      Text(String(slot.amount) + slot.unit)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
      if (slot.limit.length > 0) {
        Text(slot.limit).fontSize(11).fontColor('#ffffff').opacity(0.9)
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private customInfo(slot: UPCouponInfoSlot) {
    Column({ space: 4 }) {
      Text(slot.title)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
      Text(slot.desc)
        .fontSize(12)
        .fontColor('#ffffff')
        .opacity(0.9)
      Text(slot.time)
        .fontSize(11)
        .fontColor('#ffffff')
        .opacity(0.8)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private customAction(slot: UPCouponActionSlot) {
    Text(slot.actionText)
      .fontSize(13)
      .fontColor('#ff4747')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(14)
      .backgroundColor('#ffffff')
  }

  build() {
    Column({ space: 16 }) {
      Text('默认券形与金额单位')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCoupon({
        props: new UPCouponProps({
          amount: 30,
          limit: '满 199 元可用',
          title: '全品类通用券',
          desc: '仅限自营商品使用',
          time: '2026.09.01 - 2026.09.30',
          onClick: (): void => {
            this.pick('全品类通用券');
          }
        })
      })
      UPCoupon({
        props: new UPCouponProps({
          amount: 8.5,
          unit: '折',
          unitPosition: 'right',
          limit: '无门槛',
          title: '会员折扣券',
          desc: '会员日专享折扣',
          time: '每月 8 日可用',
          actionText: '立即用',
          size: 'small',
          onClick: (): void => {
            this.pick('会员折扣券');
          }
        })
      })

      Text('内置主题渐变')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCoupon({
        props: new UPCouponProps({
          amount: 50,
          limit: '满 300 元可用',
          title: '生鲜专享券',
          desc: '蔬菜水果均可使用',
          time: '领取后 7 天有效',
          type: 'success',
          onClick: (): void => {
            this.pick('生鲜专享券');
          }
        })
      })
      UPCoupon({
        props: new UPCouponProps({
          amount: 100,
          limit: '满 999 元可用',
          title: '大额家电券',
          desc: '限指定品牌家电',
          time: '2026.10.01 前使用',
          type: 'error',
          size: 'large',
          onClick: (): void => {
            this.pick('大额家电券');
          }
        })
      })
      Text(this.themeSummary('primary')).fontSize(12).fontColor('#909399').width('100%')
      Text(this.themeSummary('success')).fontSize(12).fontColor('#909399').width('100%')
      Text(this.themeSummary('custom')).fontSize(12).fontColor('#909399').width('100%')

      Text('红包与卡片形态')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCoupon({
        props: new UPCouponProps({
          amount: 6.6,
          title: '新人红包',
          desc: '注册即得，下单直抵',
          time: '24 小时内有效',
          shape: 'envelope',
          actionText: '拆开',
          onClick: (): void => {
            this.pick('新人红包');
          }
        })
      })
      UPCoupon({
        props: new UPCouponProps({
          amount: 20,
          title: '卡片形优惠券',
          desc: '无缺口，直角卡片风格',
          time: '2026.12.31 到期',
          shape: 'card',
          bgColor: '#eef4ff',
          color: '#2979ff',
          onClick: (): void => {
            this.pick('卡片形优惠券');
          }
        })
      })

      Text('自定义插槽与禁用态')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCoupon({
        props: new UPCouponProps({
          amount: 15,
          limit: '满 88 元可用',
          title: '插槽自定义券',
          desc: '金额、信息与动作全部自绘',
          time: '本周内有效',
          type: 'warning',
          onClick: (): void => {
            this.pick('插槽自定义券');
          }
        }),
        amountBuilder: this.customAmount,
        infoBuilder: this.customInfo,
        actionBuilder: this.customAction
      })
      UPCoupon({
        props: new UPCouponProps({
          amount: 10,
          limit: '满 100 元可用',
          title: '已失效券',
          desc: '禁用后点击不再回传',
          time: '已于 2026.08.31 过期',
          actionText: '已过期',
          disabled: true,
          onClick: (): void => {
            this.pick('已失效券');
          }
        })
      })

      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
