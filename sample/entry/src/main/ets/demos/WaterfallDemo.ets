import {
  UPWaterfall,
  UPWaterfallAddAllEvent,
  UPWaterfallColumnSlot,
  UPWaterfallItem,
  UPWaterfallItemSlot,
  UPWaterfallProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct WaterfallDemo {
  @State private flowList: Array<UPWaterfallItem> = [];
  @State private status: string = '两列瀑布流按最短列依次入列';
  private titles: Array<string> = [
    '北国风光，千里冰封，万里雪飘',
    '望长城内外，惟余莽莽',
    '大河上下，顿失滔滔',
    '欲与天公试比高',
    '须晴日，看红装素裹，分外妖娆',
    '江山如此多娇，引无数英雄竞折腰'
  ];
  private prices: Array<number> = [35, 75, 385, 784, 7891, 2341];
  private seed: number = 0;

  aboutToAppear(): void {
    this.flowList = this.nextBatch();
  }

  private nextBatch(): Array<UPWaterfallItem> {
    const batch: Array<UPWaterfallItem> = this.flowList.slice();
    for (let index = 0; index < this.titles.length; index += 1) {
      this.seed = this.seed + 1;
      batch.push({
        id: 'flow-' + String(this.seed),
        title: this.titles[index],
        price: this.prices[index],
        shop: '李白杜甫白居易旗舰店',
        description: '本地占位内容，第 ' + String(this.seed) + ' 条'
      });
    }
    return batch;
  }

  @Builder
  private customColumn(slot: UPWaterfallColumnSlot) {
    Column() {
      ForEach(slot.colList, (item: UPWaterfallItem): void => {
        Column({ space: 6 }) {
          Row()
            .width('100%')
            .height(String(item.price).length > 3 ? 120 : 84)
            .borderRadius(8)
            .backgroundColor(slot.colIndex === 0 ? '#ecf5ff' : '#f0f9eb')
          Text(String(item.title)).fontSize(14).fontColor('#303133')
          Text(String(item.price) + '元').fontSize(14).fontColor('#fa3534')
          Text(String(item.shop)).fontSize(12).fontColor('#909399')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(10)
        .margin({ bottom: 8 })
        .borderRadius(10)
        .backgroundColor('#ffffff')
        .border({ width: 0.5, color: '#ebeef5' })
      }, (item: UPWaterfallItem): string => String(item.id))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private customItem(slot: UPWaterfallItemSlot) {
    Column({ space: 4 }) {
      Text(String(slot.item.title)).fontSize(13).fontColor('#303133')
      Text(String(slot.item.description)).fontSize(12).fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .margin({ bottom: 8 })
    .borderRadius(8)
    .backgroundColor(slot.colIndex === 0 ? '#fdf6ec' : '#f4f4f5')
  }

  build() {
    Column({ space: 14 }) {
      Text('列插槽与自动列数')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPWaterfall({
        props: new UPWaterfallProps({
          modelValue: this.flowList,
          columns: 'auto',
          columnsMin: 2,
          minColumnWidth: 150,
          addTime: 120,
          useColumnSlot: true,
          onUpdateModelValue: (value: Array<UPWaterfallItem>): void => {
            this.flowList = value;
            this.status = '数据已更新，剩余 ' + String(value.length) + ' 条';
          },
          onAfterAddAll: (event: UPWaterfallAddAllEvent): void => {
            this.status = '本批入列 ' + String(event.newData.length) +
              ' 条，列数 ' + String(event.columnHeights.length);
          }
        }),
        columnBuilder: this.customColumn
      })
      Row({ space: 12 }) {
        Button('追加一批')
          .fontSize(13)
          .onClick((): void => {
            this.flowList = this.nextBatch();
          })
        Button('清空')
          .fontSize(13)
          .onClick((): void => {
            this.flowList = [];
            this.status = '已清空数据，布局同步重置';
          })
      }
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')

      Text('默认两列与自定义项 Builder')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPWaterfall({
        props: new UPWaterfallProps({
          modelValue: this.flowList,
          columns: 2,
          addTime: 0
        }),
        itemBuilder: this.customItem
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
