import {
  UPGuide,
  UPGuideChangeEvent,
  UPGuideItem,
  UPGuideProps,
  UPGuideStorage,
  upGuideRemembered
} from '@lingyun/ultra-ui-hos';

class DemoGuideStorage implements UPGuideStorage {
  private value: number | undefined = undefined;

  get(key: string): number | undefined {
    return this.value;
  }

  set(key: string, value: number): void {
    this.value = value;
  }

  remove(key: string): void {
    this.value = undefined;
  }
}

@Component
export struct GuideDemo {
  @State private guideShow: boolean = false;
  @State private onceShow: boolean = false;
  @State private status: string = '点击按钮打开首次引导';
  private storage: DemoGuideStorage = new DemoGuideStorage();
  private pages: Array<UPGuideItem> = [
    { image: '$rawfile:app_icon.png', title: '欢迎使用 Ultra UI', desc: '鸿蒙 NEXT 原生 ArkUI 组件库' },
    { image: '$rawfile:app_icon.png', title: '组件即取即用', desc: '每个组件都对齐 uview-plus 的属性与事件', backgroundColor: '#1f3b73' },
    { title: '开始你的第一个页面', desc: '缺少插图时自动渲染占位块', backgroundColor: '#2f6b4f' }
  ];

  private handleChange(event: UPGuideChangeEvent): void {
    this.status = 'change：当前第 ' + String(event.current + 1) + ' / ' + String(this.pages.length) + ' 页';
  }

  private rememberedText(): string {
    return upGuideRemembered(this.storage.get('phase-16-guide')) ? '已记录「不再提示」' : '尚未记录「不再提示」';
  }

  build() {
    Column({ space: 16 }) {
      Text('引导页翻页与事件')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 12 }) {
        Text('打开引导')
          .fontSize(13)
          .fontColor('#ffffff')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor('#2979ff')
          .onClick((): void => {
            this.guideShow = true;
            this.status = '引导已打开，可跳过或逐页前进';
          })
        Text('关闭引导')
          .fontSize(13)
          .fontColor('#606266')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor('#f4f4f5')
          .onClick((): void => {
            this.guideShow = false;
            this.status = '宿主主动关闭引导';
          })
      }
      .width('100%')
      Column() {
        UPGuide({
          props: new UPGuideProps({
            show: this.guideShow,
            list: this.pages,
            once: false,
            onChange: (event: UPGuideChangeEvent): void => {
              this.handleChange(event);
            },
            onSkip: (): void => {
              this.status = 'skip：用户跳过引导';
            },
            onFinish: (): void => {
              this.status = 'finish：用户完成全部引导';
            },
            onClose: (): void => {
              this.status = this.status + '；close 已触发';
            },
            onShowChange: (value: boolean): void => {
              this.guideShow = value;
            }
          })
        })
      }
      .width('100%')
      .height(this.guideShow ? 520 : 0)
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')

      Text('once 记忆与宿主存储')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 12 }) {
        Text('打开一次性引导')
          .fontSize(13)
          .fontColor('#ffffff')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor('#19be6b')
          .onClick((): void => {
            this.onceShow = true;
          })
        Text('清除记忆')
          .fontSize(13)
          .fontColor('#606266')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor('#f4f4f5')
          .onClick((): void => {
            this.storage.remove('phase-16-guide');
            this.status = '记忆已清除，可再次展示一次性引导';
          })
      }
      .width('100%')
      Column() {
        UPGuide({
          props: new UPGuideProps({
            show: this.onceShow,
            list: this.pages,
            storageKey: 'phase-16-guide',
            storage: this.storage,
            skipText: '暂不查看',
            nextText: '继续',
            finishText: '进入应用',
            bgColor: '#22252b',
            onShowChange: (value: boolean): void => {
              this.onceShow = value;
            },
            onFinish: (): void => {
              this.status = '一次性引导已完成并写入记忆';
            }
          })
        })
      }
      .width('100%')
      .height(this.onceShow ? 520 : 0)
      Text(this.rememberedText()).fontSize(12).fontColor('#909399').width('100%')
      Text('once 记忆经宿主实现的 UPGuideStorage 读写，示例用内存对象代替本地存储，不接入网络。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
