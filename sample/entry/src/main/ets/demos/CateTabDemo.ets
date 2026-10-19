import {
  UPCateTab,
  UPCateTabChildItem,
  UPCateTabItem,
  UPCateTabItemSlot,
  UPCateTabPageItemSlot,
  UPCateTabProps,
  UPCateTabRightTopSlot,
  upCateTabChildValue,
  upCateTabValue
} from '@lingyun/ultra-ui-hos';

@Component
export struct CateTabDemo {
  @State private current: number = 0;
  @State private status: string = '左侧点击或右侧滚动都会联动';
  @State private tabCurrent: number = 1;
  @State private tabStatus: string = 'tab 模式只显示当前分组';
  private tabList: Array<UPCateTabItem> = [
    {
      name: '家用电器',
      children: [
        { name: '电视', icon: '$rawfile:app_icon.png' },
        { name: '空调', icon: '$rawfile:app_icon.png' },
        { name: '洗衣机', icon: '$rawfile:app_icon.png' },
        { name: '冰箱', icon: '$rawfile:app_icon.png' },
        { name: '热水器', icon: '$rawfile:app_icon.png' },
        { name: '油烟机', icon: '$rawfile:app_icon.png' }
      ]
    },
    {
      name: '手机通讯',
      children: [
        { name: '手机', icon: '$rawfile:app_icon.png' },
        { name: '平板', icon: '$rawfile:app_icon.png' },
        { name: '对讲机', icon: '$rawfile:app_icon.png' },
        { name: '手机配件', icon: '$rawfile:app_icon.png' }
      ]
    },
    {
      name: '电脑办公',
      children: [
        { name: '笔记本', icon: '$rawfile:app_icon.png' },
        { name: '台式机', icon: '$rawfile:app_icon.png' },
        { name: '显示器', icon: '$rawfile:app_icon.png' },
        { name: '打印机', icon: '$rawfile:app_icon.png' },
        { name: '路由器', icon: '$rawfile:app_icon.png' }
      ]
    },
    {
      name: '家居家装',
      children: [
        { name: '床品', icon: '$rawfile:app_icon.png' },
        { name: '灯具', icon: '$rawfile:app_icon.png' },
        { name: '厨具', icon: '$rawfile:app_icon.png' }
      ]
    },
    {
      name: '服饰鞋包',
      children: [
        { name: '女装', icon: '$rawfile:app_icon.png' },
        { name: '男装', icon: '$rawfile:app_icon.png' },
        { name: '运动鞋', icon: '$rawfile:app_icon.png' },
        { name: '箱包', icon: '$rawfile:app_icon.png' }
      ]
    },
    {
      name: '生鲜果蔬',
      children: [
        { name: '水果', icon: '$rawfile:app_icon.png' },
        { name: '蔬菜', icon: '$rawfile:app_icon.png' },
        { name: '海鲜', icon: '$rawfile:app_icon.png' },
        { name: '肉禽蛋', icon: '$rawfile:app_icon.png' }
      ]
    }
  ];
  private labeledList: Array<UPCateTabItem> = [
    {
      label: '推荐榜单',
      children: [{ label: '热销榜' }, { label: '新品榜' }, { label: '口碑榜' }]
    },
    {
      label: '限时活动',
      children: [{ label: '秒杀' }, { label: '拼团' }, { label: '满减' }]
    },
    {
      label: '会员专区',
      children: [{ label: '积分兑换' }, { label: '专属券' }]
    }
  ];

  private trackFollow(value: number): void {
    this.current = value;
    this.status = '当前分组：' + String(upCateTabValue(this.tabList[value], 'name'));
  }

  private trackTab(value: number): void {
    this.tabCurrent = value;
    this.tabStatus = 'tab 模式切到：' + String(upCateTabValue(this.labeledList[value], 'label'));
  }

  @Builder
  private customMenuItem(slot: UPCateTabItemSlot) {
    Row({ space: 4 }) {
      Text(String(upCateTabValue(slot.item, 'label') ?? ''))
        .fontSize(this.current === slot.index ? 14 : 13)
        .fontColor(slot.index === this.tabCurrent ? '#2979ff' : '#606266')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private customPageItem(slot: UPCateTabPageItemSlot) {
    Column({ space: 4 }) {
      Text(String(slot.index + 1))
        .fontSize(12)
        .fontColor('#ffffff')
        .width(28)
        .height(28)
        .borderRadius(14)
        .textAlign(TextAlign.Center)
        .backgroundColor('#3c9cff')
      Text(String(upCateTabChildValue(slot.pageItem, 'label') ?? ''))
        .fontSize(12)
        .fontColor('#303133')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private rightTop(slot: UPCateTabRightTopSlot) {
    Row() {
      Text('共 ' + String(slot.tabList.length) + ' 个分组')
        .fontSize(12)
        .fontColor('#909399')
    }
    .width('100%')
    .padding({ left: 10, top: 8, bottom: 4 })
  }

  private childCount(): number {
    let total: number = 0;
    for (let index: number = 0; index < this.tabList.length; index += 1) {
      const children: Array<UPCateTabChildItem> = this.tabList[index].children ?? [];
      total += children.length;
    }
    return total;
  }

  build() {
    Column({ space: 16 }) {
      Text('follow 联动模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCateTab({
        props: new UPCateTabProps({
          tabList: this.tabList,
          current: this.current,
          height: 320,
          onCurrentChange: (value: number): void => {
            this.trackFollow(value);
          }
        }),
        rightTopBuilder: this.rightTop
      })
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text('全部分组共 ' + String(this.childCount()) + ' 个子项，图标读取示例工程本地资源')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('tab 单显模式与自定义插槽')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCateTab({
        props: new UPCateTabProps({
          mode: 'tab',
          tabList: this.labeledList,
          tabKeyName: 'label',
          itemKeyName: 'label',
          current: this.tabCurrent,
          height: 240,
          onCurrentChange: (value: number): void => {
            this.trackTab(value);
          }
        }),
        tabItemBuilder: this.customMenuItem,
        pageItemBuilder: this.customPageItem
      })
      Text(this.tabStatus).fontSize(13).fontColor('#606266').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
