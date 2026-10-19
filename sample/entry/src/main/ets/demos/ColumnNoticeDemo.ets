import {
  UPColumnNotice,
  UPColumnNoticeProps,
  UPSwitch,
  UPSwitchChangeEvent,
  UPSwitchProps,
  UP_COLUMN_NOTICE_SWIPER_HEIGHT,
  upColumnNoticeItems
} from '@lingyun/ultra-ui-hos';

@Component
export struct ColumnNoticeDemo {
  @State private status: string = '点击公告条回传当前索引';
  @State private step: boolean = false;
  @State private disableTouch: boolean = true;
  @State private duration: number = 1500;
  private notices: Array<string> = [
    '第一条：uview-plus 的 u-notice-bar 在 direction 为 column 时内部渲染 u-column-notice',
    '第二条：轮播由原生 Swiper 承载，autoPlay 与 loop 常开',
    '第三条：step 为真时改成横向步进，等价上游 vertical=false'
  ];
  private durations: Array<number> = [800, 1500, 3000];
  private aligns: Array<string> = ['flex-start', 'center', 'flex-end'];

  private handleClick(index: number): void {
    this.status = 'click：当前索引 ' + String(index) + '，文案「' + this.notices[index] + '」';
  }

  private handleClose(): void {
    this.status = 'closable 模式点击关闭图标，回调 onClose';
  }

  private toggleStep(event: UPSwitchChangeEvent): void {
    this.step = event.checked;
    this.status = event.checked ? 'step=true：改为横向步进轮播' : 'step=false：恢复纵向轮播';
  }

  private toggleTouch(event: UPSwitchChangeEvent): void {
    this.disableTouch = event.checked;
    this.status = event.checked ? 'disableTouch=true：禁止手动滑动' : 'disableTouch=false：可手动滑动切换';
  }

  private selectDuration(value: number): void {
    this.duration = value;
    this.status = 'duration=' + String(value) + 'ms → Swiper interval 同值（低于 100ms 时兜底 1500）';
  }

  private alignText(value: string): string {
    return 'justifyContent=' + value + '：单条公告在 '
      + String(UP_COLUMN_NOTICE_SWIPER_HEIGHT) + 'vp 高的可视区内按该主轴对齐';
  }

  private itemsText(): string {
    return '数组入参 ' + String(upColumnNoticeItems(this.notices).length) + ' 条；'
      + "非数组入参按单条兜底并报诊断，例如 upColumnNoticeItems('单条') = "
      + String(upColumnNoticeItems('单条').length) + ' 条。';
  }

  build() {
    Column({ space: 16 }) {
      Text('默认纵向轮播')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Column() {
        UPColumnNotice({
          props: new UPColumnNoticeProps({
            text: this.notices,
            duration: this.duration,
            step: this.step,
            disableTouch: this.disableTouch,
            onClick: (index: number): void => {
              this.handleClick(index);
            }
          })
        })
      }
      .width('100%')
      .padding({ top: 9, bottom: 9, left: 12, right: 12 })
      .backgroundColor('#fdf6ec')
      .borderRadius(4)
      Row({ space: 10 }) {
        Text('横向步进').fontSize(13).fontColor('#606266')
        UPSwitch({
          props: new UPSwitchProps({
            modelValue: this.step,
            size: 22,
            onChange: (event: UPSwitchChangeEvent): void => {
              this.toggleStep(event);
            }
          })
        })
        Text('禁止滑动').fontSize(13).fontColor('#606266')
        UPSwitch({
          props: new UPSwitchProps({
            modelValue: this.disableTouch,
            size: 22,
            onChange: (event: UPSwitchChangeEvent): void => {
              this.toggleTouch(event);
            }
          })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Row({ space: 10 }) {
        ForEach(this.durations, (value: number): void => {
          Button(String(value) + 'ms')
            .fontSize(13)
            .height(32)
            .backgroundColor(this.duration === value ? '#2979ff' : '#f4f4f5')
            .fontColor(this.duration === value ? '#ffffff' : '#606266')
            .onClick((): void => {
              this.selectDuration(value);
            })
        }, (value: number): string => String(value))
      }
      .width('100%')
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')

      Text('link 与 closable 模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Column() {
        UPColumnNotice({
          props: new UPColumnNoticeProps({
            text: this.notices,
            mode: 'link',
            icon: 'volume-fill',
            onClick: (index: number): void => {
              this.handleClick(index);
            }
          })
        })
      }
      .width('100%')
      .padding({ top: 9, bottom: 9, left: 12, right: 12 })
      .backgroundColor('#fdf6ec')
      .borderRadius(4)
      Column() {
        UPColumnNotice({
          props: new UPColumnNoticeProps({
            text: this.notices,
            mode: 'closable',
            color: '#2979ff',
            fontSize: 13,
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

      Text('主轴对齐与入参兜底')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Column() {
        UPColumnNotice({
          props: new UPColumnNoticeProps({
            text: ['居中对齐的公告一', '居中对齐的公告二'],
            justifyContent: 'center',
            icon: ''
          })
        })
      }
      .width('100%')
      .padding({ top: 9, bottom: 9, left: 12, right: 12 })
      .backgroundColor('#f7f8fa')
      .borderRadius(4)
      ForEach(this.aligns, (value: string): void => {
        Text(this.alignText(value)).fontSize(12).fontColor('#909399').width('100%')
      }, (value: string): string => value)
      Text(this.itemsText()).fontSize(12).fontColor('#909399').width('100%')
      Text('speed 与 bgColor 上游在 u-column-notice 内部声明后从未读取，本端保持 no-op；滚动节奏统一由 duration 决定。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
