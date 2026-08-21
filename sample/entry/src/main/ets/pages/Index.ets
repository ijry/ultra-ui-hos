import { UPToastHost } from '@lingyun/ultra-ui-hos';
import { SAMPLE_GROUPS, SampleGroup, SampleItem } from '../catalog/SampleCatalog';
import { SamplePage, SamplePageProps } from './SamplePage';

@Entry
@Component
struct Index {
  @State private pathStack: NavPathStack = new NavPathStack();

  private open(route: string): void {
    this.pathStack.pushPathByName('sample', route);
  }

  @Builder
  private group(group: SampleGroup) {
    Column({ space: 8 }) {
      Text(group.title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#606266')
        .width('100%')
        .margin({ top: 12, bottom: 4 })
      ForEach(group.items, (item: SampleItem) => {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row({ space: 10 }) {
            Column({ space: 3 }) {
              Text(item.title)
                .fontSize(16)
                .fontColor('#303133')
              Text(item.description)
                .fontSize(12)
                .fontColor('#909399')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text('›')
              .fontSize(22)
              .fontColor('#c0c4cc')
          }
        }
        .width('100%')
        .height(66)
        .padding({ left: 16, right: 12 })
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .onClick((): void => {
          this.open(item.route);
        })
      }, (item: SampleItem) => item.route)
    }
    .width('100%')
  }

  @Builder
  private home() {
    Column() {
      Column({ space: 8 }) {
        Text('UltraUI 鸿蒙示例')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#303133')
        Text('uview-plus HarmonyOS NEXT 原生组件库')
          .fontSize(14)
          .fontColor('#606266')
        Text('当前 61 个示例路由，使用受控状态和显式事件')
          .fontSize(12)
          .fontColor('#909399')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ top: 24, right: 18, bottom: 12, left: 18 })
      ForEach(SAMPLE_GROUPS, (group: SampleGroup) => {
        this.group(group)
      }, (group: SampleGroup) => group.title)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 28 })
  }

  @Builder
  private destination(name: string, param: Object) {
    if (name === 'sample') {
      SamplePage({
        props: new SamplePageProps({
          route: String(param),
          onBack: (): void => {
            this.pathStack.pop();
          },
          onRelaunch: (url: string): void => {
            if (url === 'home') this.pathStack.clear();
          }
        })
      })
    }
  }

  build() {
    Stack() {
      Navigation(this.pathStack) {
        Scroll() {
          this.home()
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      }
      .navDestination(this.destination)
      .title('组件目录')
      UPToastHost()
    }
    .width('100%')
    .height('100%')
  }
}
