import {
  UPTransition,
  UPTransitionFrame,
  UPTransitionProps,
  upTransitionHiddenFrame,
  upTransitionModeSupported
} from '@lingyun/ultra-ui-hos';

@Component
export struct TransitionDemo {
  @State private fadeShow: boolean = true;
  @State private slideShow: boolean = false;
  @State private zoomShow: boolean = false;
  @State private lifecycle: string = '等待动画事件';

  private record(name: string): void {
    this.lifecycle = name;
  }

  private hiddenSummary(mode: string): string {
    if (!upTransitionModeSupported(mode)) {
      return mode + '：不在白名单内，回落 fade';
    }
    const frame: UPTransitionFrame = upTransitionHiddenFrame(mode);
    return mode + ' 隐藏端：opacity ' + String(frame.opacity) + '，位移 ' + frame.translateX + '/' + frame.translateY
      + '，缩放 ' + String(frame.scale);
  }

  @Builder
  private fadePanel() {
    Column() {
      Text('淡入淡出面板').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#303133')
      Text('mode=fade，时长 300ms').fontSize(12).fontColor('#909399').margin({ top: 6 })
    }
    .width('100%')
    .padding(16)
    .borderRadius(10)
    .backgroundColor('#eef4ff')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private slidePanel() {
    Column() {
      Text('上滑进入面板').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#ffffff')
      Text('mode=slide-up，仅位移不改透明度').fontSize(12).fontColor('#ffffff').opacity(0.85).margin({ top: 6 })
    }
    .width('100%')
    .padding(16)
    .borderRadius(10)
    .backgroundColor('#19be6b')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private zoomPanel() {
    Column() {
      Text('缩放淡入面板').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#ffffff')
      Text('mode=fade-zoom，时长 600ms').fontSize(12).fontColor('#ffffff').opacity(0.85).margin({ top: 6 })
    }
    .width('100%')
    .padding(16)
    .borderRadius(10)
    .backgroundColor('#ff9900')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column({ space: 16 }) {
      Text('淡入淡出与生命周期事件')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 12 }) {
        Text(this.fadeShow ? '隐藏面板' : '显示面板')
          .fontSize(13)
          .fontColor('#ffffff')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor('#2979ff')
          .onClick((): void => {
            this.fadeShow = !this.fadeShow;
          })
        Text('当前：' + (this.fadeShow ? '已展示' : '已隐藏')).fontSize(12).fontColor('#909399')
      }
      .width('100%')
      UPTransition({
        props: new UPTransitionProps({
          show: this.fadeShow,
          mode: 'fade',
          duration: '300',
          onBeforeEnter: (): void => {
            this.record('beforeEnter：准备进入');
          },
          onEnter: (): void => {
            this.record('enter：进入动画开始');
          },
          onAfterEnter: (): void => {
            this.record('afterEnter：进入动画结束');
          },
          onBeforeLeave: (): void => {
            this.record('beforeLeave：准备离开');
          },
          onLeave: (): void => {
            this.record('leave：离开动画开始');
          },
          onAfterLeave: (): void => {
            this.record('afterLeave：离开动画结束');
          },
          onClick: (): void => {
            this.record('click：点击了过渡内容');
          }
        }),
        contentBuilder: this.fadePanel
      })
      Text(this.lifecycle).fontSize(13).fontColor('#606266').width('100%')

      Text('位移与缩放模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 12 }) {
        Text(this.slideShow ? '收起上滑' : '触发上滑')
          .fontSize(13)
          .fontColor('#ffffff')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor('#19be6b')
          .onClick((): void => {
            this.slideShow = !this.slideShow;
          })
        Text(this.zoomShow ? '收起缩放' : '触发缩放')
          .fontSize(13)
          .fontColor('#ffffff')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor('#ff9900')
          .onClick((): void => {
            this.zoomShow = !this.zoomShow;
          })
      }
      .width('100%')
      UPTransition({
        props: new UPTransitionProps({ show: this.slideShow, mode: 'slide-up', duration: '400' }),
        contentBuilder: this.slidePanel
      })
      UPTransition({
        props: new UPTransitionProps({
          show: this.zoomShow,
          mode: 'fade-zoom',
          duration: 600,
          timingFunction: 'ease-in-out'
        }),
        contentBuilder: this.zoomPanel
      })

      Text('模式端点值速查')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.hiddenSummary('fade-up')).fontSize(12).fontColor('#909399').width('100%')
      Text(this.hiddenSummary('slide-left')).fontSize(12).fontColor('#909399').width('100%')
      Text(this.hiddenSummary('zoom')).fontSize(12).fontColor('#909399').width('100%')
      Text(this.hiddenSummary('spin')).fontSize(12).fontColor('#909399').width('100%')
      Text('timingFunction 只接受 linear/ease/ease-in/ease-out/ease-in-out，其余取值回落 ease-out 并记录诊断。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
