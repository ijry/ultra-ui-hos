import { UPCard, UPCardClickEvent, UPCardProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CardDemo {
  @State private showHead: boolean = true;
  @State private showFoot: boolean = true;
  @State private message: string = '点击卡片分区查看回传';

  private selected(event: UPCardClickEvent, source: string): void {
    this.message = source + '：area=' + event.area + ' index=' + String(event.index);
  }

  @Builder
  private customHead() {
    Row({ space: 8 }) {
      Text('自定义头部').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#303133')
      Blank()
      Text('Builder').fontSize(12).fontColor('#2979ff')
    }
    .width('100%')
  }

  @Builder
  private customFoot() {
    Row() {
      Text('自定义底部').fontSize(13).fontColor('#909399')
      Blank()
      Text('了解详情').fontSize(13).fontColor('#2979ff')
    }
    .width('100%')
  }

  @Builder
  private defaultBody() {
    Column({ space: 6 }) {
      Text('卡片主体使用 contentBuilder 提供。').fontSize(14).fontColor('#606266')
      Text('缩略图只读取示例工程本地资源。').fontSize(12).fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private customBody() {
    Text('命名 Builder 可替换默认头部，并提供可点击底部。')
      .fontSize(14)
      .fontColor('#606266')
      .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      Text('默认头部与本地缩略图')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCard({ props: new UPCardProps({
          index: 'default-card',
          title: 'UltraUI 鸿蒙 NEXT',
          subTitle: '原生 ArkUI 卡片',
          thumb: '$rawfile:app_icon.png',
          thumbCircle: true,
          showHead: this.showHead,
          showFoot: false,
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.08)',
          onClick: (event: UPCardClickEvent): void => {
            this.selected(event, '通用点击');
          },
          onHeadClick: (event: UPCardClickEvent): void => {
            this.selected(event, '头部点击');
          },
          onBodyClick: (event: UPCardClickEvent): void => {
            this.selected(event, '主体点击');
          }
        })
      }) {
        this.defaultBody()
      }

      Text('命名头部与底部 Builder')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCard({
        props: new UPCardProps({
          index: 2,
          showHead: this.showHead,
          showFoot: this.showFoot,
          onClick: (event: UPCardClickEvent): void => {
            this.selected(event, '通用点击');
          },
          onFootClick: (event: UPCardClickEvent): void => {
            this.selected(event, '底部点击');
          },
          headBuilder: this.customHead,
          footBuilder: this.customFoot
        })
      }) {
        this.customBody()
      }

      Row({ space: 12 }) {
        Button(this.showHead ? '隐藏头部' : '显示头部')
          .fontSize(13)
          .onClick((): void => {
            this.showHead = !this.showHead;
          })
        Button(this.showFoot ? '隐藏底部' : '显示底部')
          .fontSize(13)
          .onClick((): void => {
            this.showFoot = !this.showFoot;
          })
      }
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
