import {
  UPTabsClickEvent,
  UPTabsItemData,
  UPTabsPro,
  UPTabsProContentSlot,
  UPTabsProProps,
  upTabsProNormalizeCurrent
} from '@lingyun/ultra-ui-hos';

@Component
export struct TabsProDemo {
  @State private current: number = 0;
  @State private status: string = '受控索引：0';
  @State private plainCurrent: number = 2;
  private list: Array<UPTabsItemData> = [
    { name: '全部订单' },
    { name: '待付款', badge: '2' },
    { name: '待发货' },
    { name: '待收货' },
    { name: '已完成' },
    { name: '售后中', disabled: true }
  ];
  private contents: Array<string> = [
    '全部订单：共 18 笔，最近一笔来自昨天。',
    '待付款：2 笔订单等待支付，超时将自动取消。',
    '待发货：1 笔订单已通知仓库备货。',
    '待收货：3 笔订单在途，预计 3 天内送达。',
    '已完成：12 笔订单已签收，可申请开票。',
    '售后中：该分组在示例里被禁用，无法切换。'
  ];

  private track(event: UPTabsClickEvent): void {
    this.current = event.index;
    this.status = '切换到：' + String(event.item.name) + '（索引 ' + String(event.index) + '）';
  }

  private clampSummary(): string {
    const low: number = upTabsProNormalizeCurrent(-3, this.list.length);
    const high: number = upTabsProNormalizeCurrent(99, this.list.length);
    return '越界索引钳制：-3 → ' + String(low) + '，99 → ' + String(high);
  }

  private contentText(index: number): string {
    if (index < 0 || index >= this.contents.length) {
      return '暂无内容';
    }
    return this.contents[index];
  }

  @Builder
  private leftRegion() {
    Text('订单')
      .fontSize(13)
      .fontColor('#909399')
      .padding({ left: 4, right: 8 })
  }

  @Builder
  private rightRegion() {
    Text('筛选')
      .fontSize(13)
      .fontColor('#2979ff')
      .padding({ left: 8, right: 4 })
  }

  @Builder
  private orderContent(slot: UPTabsProContentSlot) {
    Column({ space: 8 }) {
      Text(this.contentText(slot.index))
        .fontSize(14)
        .fontColor('#303133')
        .width('100%')
      Text('插槽入参：current=' + String(slot.current) +
        '，value=' + String(slot.value ?? '') +
        '，共 ' + String(slot.list.length) + ' 个分组')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .padding(12)
    .borderRadius(8)
    .backgroundColor('#ffffff')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column({ space: 16 }) {
      Text('内容区联动与左右插槽')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTabsPro({
        props: new UPTabsProProps({
          list: this.list,
          current: this.current,
          lineColor: '#2979ff',
          onCurrentChange: (index: number): void => {
            this.current = index;
          },
          onChange: (event: UPTabsClickEvent): void => {
            this.track(event);
          },
          onClick: (event: UPTabsClickEvent): void => {
            this.status = '点击：' + String(event.item.name);
          },
          onLongPress: (event: UPTabsClickEvent): void => {
            this.status = '长按：' + String(event.item.name);
          }
        }),
        leftBuilder: this.leftRegion,
        rightBuilder: this.rightRegion,
        contentBuilder: this.orderContent
      })
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.clampSummary()).fontSize(12).fontColor('#909399').width('100%')

      Text('默认内容与胶囊样式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTabsPro({
        props: new UPTabsProProps({
          list: this.list.slice(0, 4),
          current: this.plainCurrent,
          shapeMode: 'capsule',
          lineColor: '#67c23a',
          scrollable: false,
          onCurrentChange: (index: number): void => {
            this.plainCurrent = index;
          }
        })
      })

      Text('隐藏内容区')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTabsPro({
        props: new UPTabsProProps({
          list: this.list.slice(0, 3),
          current: 1,
          showContent: false
        })
      })
      Text('showContent 为 false 时仅渲染标签栏，内容由外部自行承接')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
