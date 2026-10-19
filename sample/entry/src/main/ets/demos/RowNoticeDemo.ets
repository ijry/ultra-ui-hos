import {
  UPRowNotice,
  UPRowNoticeProps,
  UP_ROW_NOTICE_FRAMES_PER_SECOND,
  UP_ROW_NOTICE_SLICE_LENGTH,
  upRowNoticeDuration,
  upRowNoticeSlices,
  upRowNoticeSpeedPx,
  upRowNoticeStep
} from '@lingyun/ultra-ui-hos';

@Component
export struct RowNoticeDemo {
  @State private status: string = '点击公告条触发 click';
  @State private speed: number = 80;
  @State private notice: string = '横向滚动公告：uview-plus 的 u-notice-bar 在 direction 为 row 时内部渲染 u-row-notice';
  private speeds: Array<number> = [40, 80, 160];
  private probeSpeeds: Array<string> = ['80', '300rpx', '2vw'];

  private handleClick(): void {
    this.status = '公告被点击，上游由 u-notice-bar 决定是否跳转';
  }

  private handleClose(): void {
    this.status = 'closable 模式点击右侧关闭图标，回调 onClose';
  }

  private selectSpeed(value: number): void {
    this.speed = value;
    this.status = 'speed=' + String(value) + 'px/s → Marquee step ' + String(upRowNoticeStep(value)) + 'vp/帧';
  }

  private toggleText(): void {
    this.notice = this.notice.length > 40 ? '短公告：文本不足一屏时依然循环滚动' : '横向滚动公告：uview-plus 的 u-notice-bar 在 direction 为 row 时内部渲染 u-row-notice';
    this.status = '文本长度 ' + String(this.notice.length) + ' 字符，切片 '
      + String(upRowNoticeSlices(this.notice).length) + ' 段（每段 '
      + String(UP_ROW_NOTICE_SLICE_LENGTH) + ' 字符）';
  }

  private speedText(value: string): string {
    const pixels: number = upRowNoticeSpeedPx(value);
    return 'speed=' + value + ' → ' + String(Math.round(pixels)) + 'px/s，step '
      + String(upRowNoticeStep(value)) + 'vp/帧（按 ' + String(UP_ROW_NOTICE_FRAMES_PER_SECOND) + 'fps 折算）';
  }

  private durationText(): string {
    return '上游 CSS 动画时长 ' + upRowNoticeDuration(this.notice, 14, this.speed)
      + '，本端改由 Marquee step 逐帧推进，无需 keyframes。';
  }

  build() {
    Column({ space: 16 }) {
      Text('默认横向公告')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Column() {
        UPRowNotice({
          props: new UPRowNoticeProps({
            text: this.notice,
            speed: this.speed,
            onClick: (): void => {
              this.handleClick();
            }
          })
        })
      }
      .width('100%')
      .padding({ top: 9, bottom: 9, left: 12, right: 12 })
      .backgroundColor('#fdf6ec')
      .borderRadius(4)
      Row({ space: 10 }) {
        ForEach(this.speeds, (value: number): void => {
          Button(String(value) + 'px/s')
            .fontSize(13)
            .height(32)
            .backgroundColor(this.speed === value ? '#2979ff' : '#f4f4f5')
            .fontColor(this.speed === value ? '#ffffff' : '#606266')
            .onClick((): void => {
              this.selectSpeed(value);
            })
        }, (value: number): string => String(value))
        Button('切换文本')
          .fontSize(13)
          .height(32)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.toggleText();
          })
      }
      .width('100%')
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')

      Text('link 与 closable 模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Column() {
        UPRowNotice({
          props: new UPRowNoticeProps({
            text: 'link 模式在右侧渲染箭头，点击整条触发 click',
            mode: 'link',
            onClick: (): void => {
              this.handleClick();
            }
          })
        })
      }
      .width('100%')
      .padding({ top: 9, bottom: 9, left: 12, right: 12 })
      .backgroundColor('#fdf6ec')
      .borderRadius(4)
      Column() {
        UPRowNotice({
          props: new UPRowNoticeProps({
            text: 'closable 模式在右侧渲染关闭图标',
            mode: 'closable',
            color: '#2979ff',
            icon: 'volume-fill',
            onClose: (): void => {
              this.handleClose();
            }
          })
        })
      }
      .width('100%')
      .padding({ top: 9, bottom: 9, left: 12, right: 12 })
      .backgroundColor('#ecf5ff')
      .borderRadius(4)
      Text('mode 只有 link 与 closable 两个分支；bgColor 上游在 u-row-notice 内部并未落地绘制，本端保持 no-op，底色由外层 u-notice-bar 或 customStyle 提供。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('滚动速度换算')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      ForEach(this.probeSpeeds, (value: string): void => {
        Text(this.speedText(value)).fontSize(12).fontColor('#909399').width('100%')
      }, (value: string): string => value)
      Text(this.durationText()).fontSize(12).fontColor('#909399').width('100%')
      Text('文本按 20 字符切片以复刻上游多段 text 结构；离场时清理定时器并停止滚动，等价上游 beforeUnmount 的 stopAnimation。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
