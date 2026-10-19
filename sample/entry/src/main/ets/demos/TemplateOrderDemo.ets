import {
  UPIcon,
  UPIconProps,
  UPLoadmore,
  UPLoadmoreProps,
  UPTabs,
  UPTabsClickEvent,
  UPTabsItemData,
  UPTabsProps
} from '@lingyun/ultra-ui-hos';

/** 订单中的一件商品。/ One goods line inside an order. */
interface OrderGoods {
  title: string;
  spec: string;
  deliveryTime: string;
  price: number;
  count: number;
}

/** 一个订单。/ One order card. */
interface OrderCard {
  id: number;
  store: string;
  deal: string;
  goods: Array<OrderGoods>;
}

/**
 * 复刻上游 `pages/template/order/index.vue` 的订单列表场景。
 * ArkTS port of the upstream order template: UPTabs by状态 + per-store order cards.
 * 上游用 swiper + scroll-view 分页,这里用受控 UPTabs 切换本地数据集。
 */
@Component
export struct TemplateOrderDemo {
  @State private current: number = 0;
  private tabs: Array<UPTabsItemData> = [
    { name: '全部' }, { name: '待付款' }, { name: '待收货' }, { name: '待评价' }
  ];
  private orders: Array<Array<OrderCard>> = [
    [
      {
        id: 1, store: '甘露茶饮旗舰店', deal: '交易成功',
        goods: [
          { title: '甘露青提乌龙 500ml 大杯', spec: '少冰 / 三分糖', deliveryTime: '今日 14:20', price: 29.9, count: 2 },
          { title: '烟熏红茶 冷萃版', spec: '常温', deliveryTime: '今日 14:20', price: 18.5, count: 1 }
      ]
      },
      {
        id: 2, store: '海盐芝士烘焙坊', deal: '交易成功',
        goods: [
          { title: '海盐芝士可颂', spec: '原味', deliveryTime: '昨日 09:10', price: 22, count: 3 }
        ]
      }
    ],
    [
      {
        id: 3, store: '待付款示例店', deal: '等待付款',
        goods: [
          { title: '限时预售 · 手冲挂耳礼盒', spec: '10 片装', deliveryTime: '付款后 48 小时', price: 88, count: 1 }
        ]
      }
    ],
    [], []
  ];

  private priceText(value: number): string {
    return '￥' + value.toFixed(2);
  }

  private totalCount(order: OrderCard): number {
    let total: number = 0;
    for (let index: number = 0; index < order.goods.length; index++) {
      total += order.goods[index].count;
    }
    return total;
  }

  private totalPrice(order: OrderCard): number {
    let total: number = 0;
    for (let index: number = 0; index < order.goods.length; index++) {
      total += order.goods[index].price * order.goods[index].count;
    }
    return total;
  }

  private activeOrders(): Array<OrderCard> {
    return this.orders[this.current];
  }

  @Builder
  private goodsRow(item: OrderGoods) {
    Row({ space: 10 }) {
      Column()
        .width(64)
        .height(64)
        .backgroundColor('#f3f4f6')
        .borderRadius(6)
      Column({ space: 4 }) {
        Text(item.title).fontSize(14).fontColor('#303133').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(item.spec).fontSize(12).fontColor('#909399')
        Text('发货时间 ' + item.deliveryTime).fontSize(11).fontColor('#c0c4cc')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column({ space: 4 }) {
        Text(this.priceText(item.price)).fontSize(14).fontColor('#303133')
        Text('x' + String(item.count)).fontSize(12).fontColor('#909399')
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  private orderCard(order: OrderCard) {
    Column({ space: 6 }) {
      Row() {
        Row({ space: 6 }) {
          UPIcon({ props: new UPIconProps({ name: 'home', size: 18, color: '#5e5e5e' }) })
          Text(order.store).fontSize(14).fontColor('#303133').fontWeight(FontWeight.Medium)
          UPIcon({ props: new UPIconProps({ name: 'arrow-right', size: 14, color: '#cbcbcb' }) })
        }
        Blank()
        Text(order.deal).fontSize(12).fontColor('#f29100')
      }
      .width('100%')
      ForEach(order.goods, (item: OrderGoods) => {
        this.goodsRow(item)
      }, (item: OrderGoods): string => item.title)
      Row() {
        Blank()
        Text('共 ' + String(this.totalCount(order)) + ' 件商品 合计：')
          .fontSize(12)
          .fontColor('#606266')
        Text(this.priceText(this.totalPrice(order)))
          .fontSize(14)
          .fontColor('#303133')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      Row({ space: 8 }) {
        Blank()
        Text('查看物流').fontSize(12).fontColor('#606266')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .border({ width: 1, color: '#dcdfe6' }).borderRadius(14)
        Text('评价').fontSize(12).fontColor('#606266')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .border({ width: 1, color: '#dcdfe6' }).borderRadius(14)
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .margin({ bottom: 10 })
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      UPTabs({ props: new UPTabsProps({
        list: this.tabs,
        current: this.current,
        lineColor: '#f29100',
        scrollable: false,
        onCurrentChange: (index: number): void => {
          this.current = index;
        }
      }) })
      Scroll() {
        Column() {
          if (this.activeOrders().length === 0) {
            Text('该状态下暂无订单')
              .fontSize(13)
              .fontColor('#c0c4cc')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(40)
          } else {
            ForEach(this.activeOrders(), (order: OrderCard) => {
              this.orderCard(order)
            }, (order: OrderCard): string => String(order.id))
            UPLoadmore({ props: new UPLoadmoreProps({ status: 'nomore' }) })
          }
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#f3f4f6')
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
