import { UPIcon, UPIconProps } from '@lingyun/ultra-ui-hos';

/** 一个分类下的商品项。/ One product tile inside a category. */
interface MallFood {
  name: string;
  icon: string;
}

/** 一个左侧分类。/ One left-rail category. */
interface MallCategory {
  name: string;
  foods: Array<MallFood>;
}

/**
 * 复刻上游 `pages/template/mallMenu/index1.vue` 的商城左右联动分类场景。
 * ArkTS port of the upstream mall-menu template: a left category rail linked to a
 * right product grid. 商品图改用图标占位（组件库不加载远程图）。
 */
@Component
export struct TemplateMallDemo {
  @State private current: number = 0;
  private categories: Array<MallCategory> = [
    {
      name: '推荐', foods: [
        { name: '甘露青提', icon: 'gift' }, { name: '烟熏红茶', icon: 'shopping-cart' },
        { name: '海盐芝士', icon: 'gift' }, { name: '手冲挂耳', icon: 'shopping-cart' }
      ]
    },
    {
      name: '茶饮', foods: [
        { name: '茉莉初雪', icon: 'shopping-cart' }, { name: '桂花乌龙', icon: 'shopping-cart' },
        { name: '鸭屎香', icon: 'shopping-cart' }
      ]
    },
    {
      name: '烘焙', foods: [
        { name: '可颂', icon: 'gift' }, { name: '贝果', icon: 'gift' },
        { name: '司康', icon: 'gift' }, { name: '玛德琳', icon: 'gift' }
      ]
    },
    {
      name: '周边', foods: [
        { name: '保温杯', icon: 'bag' }, { name: '帆布袋', icon: 'bag' }
      ]
    }
  ];

  private active(): MallCategory {
    return this.categories[this.current];
  }

  @Builder
  private foodTile(food: MallFood) {
    Column({ space: 6 }) {
      Column() {
        UPIcon({ props: new UPIconProps({ name: food.icon, size: 30, color: '#909399' }) })
      }
      .width(56)
      .height(56)
      .backgroundColor('#f3f4f6')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      Text(food.name).fontSize(12).fontColor('#606266').maxLines(1)
    }
    .width('25%')
    .padding({ top: 8, bottom: 8 })
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        UPIcon({ props: new UPIconProps({ name: 'search', size: 18, color: '#909399' }) })
        Text('搜索 ultra-ui').fontSize(13).fontColor('#909399')
      }
      .width('100%')
      .height(40)
      .padding({ left: 12 })
      .backgroundColor('#f3f4f6')
      .borderRadius(20)
      .margin({ bottom: 8 })
      Row() {
        Column() {
          ForEach(this.categories, (item: MallCategory, index: number) => {
            Text(item.name)
              .fontSize(14)
              .fontColor(this.current === index ? '#303133' : '#606266')
              .fontWeight(this.current === index ? FontWeight.Medium : FontWeight.Normal)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 16, bottom: 16 })
              .backgroundColor(this.current === index ? '#ffffff' : '#f3f4f6')
              .onClick((): void => { this.current = index; })
          }, (item: MallCategory): string => item.name)
        }
        .width(88)
        .height('100%')
        .backgroundColor('#f3f4f6')
        Scroll() {
          Column({ space: 8 }) {
            Text(this.active().name).fontSize(14).fontColor('#303133').fontWeight(FontWeight.Medium).width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.active().foods, (food: MallFood) => {
                this.foodTile(food)
              }, (food: MallFood): string => food.name)
            }
            .width('100%')
          }
          .width('100%')
          .padding(12)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .height('100%')
        .scrollBar(BarState.Off)
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
