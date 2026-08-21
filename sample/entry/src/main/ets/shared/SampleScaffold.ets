export interface SampleScaffoldOptions {
  title?: string;
  subtitle?: string;
  onBack?: () => void;
}

/** Props container avoids decorating callback functions directly with @Prop. */
export class SampleScaffoldProps {
  title: string = '示例';
  subtitle: string = '';
  onBack?: () => void;

  constructor(options?: SampleScaffoldOptions) {
    if (options === undefined) {
      return;
    }
    this.title = options.title ?? this.title;
    this.subtitle = options.subtitle ?? this.subtitle;
    this.onBack = options.onBack;
  }
}

@Component
export struct SampleScaffold {
  @Prop props: SampleScaffoldProps = new SampleScaffoldProps();

  @Builder
  private defaultContent() {
    Text('暂无示例内容')
      .fontSize(15)
      .fontColor('#606266')
  }

  @BuilderParam contentBuilder: () => void = this.defaultContent;

  @Builder
  private header() {
    Row({ space: 12 }) {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Text('返回')
      }
      .fontSize(14)
      .fontColor('#2979ff')
      .backgroundColor('#ffffff')
      .borderWidth(1)
      .borderColor('#d7e5ff')
      .borderRadius(6)
      .onClick((): void => {
        this.props.onBack?.();
      })

      Column({ space: 3 }) {
        Text(this.props.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#303133')
        if (this.props.subtitle.length > 0) {
          Text(this.props.subtitle)
            .fontSize(12)
            .fontColor('#909399')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 18, right: 18, bottom: 12, left: 18 })
  }

  build() {
    Column() {
      this.header()
      Scroll() {
        Column() {
          this.contentBuilder()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 28 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f7f8fa')
  }
}
