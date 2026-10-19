import {
  UPButton,
  UPButtonProps,
  UPColorPicker,
  UPColorPickerDirection,
  UPColorPickerProps,
  UPColorPickerStop,
  UPRawValue,
  UP_COLOR_PICKER_DIRECTIONS,
  UP_COLOR_PICKER_GRADIENT_MAX,
  UP_COLOR_PICKER_GRADIENT_MIN,
  upColorPickerAddStop,
  upColorPickerArkAngle,
  upColorPickerDirectionAngle,
  upColorPickerGradientCss,
  upColorPickerHslToRgb,
  upColorPickerRemoveStop
} from '@lingyun/ultra-ui-hos';

@Component
export struct ColorPickerDemo {
  @State private pickerVisible: boolean = false;
  @State private pickedColor: string = '#ff0000';
  @State private liveColor: string = '#ff0000';
  @State private resultText: string = '点击按钮打开取色面板';
  private commonColors: Array<UPRawValue> = ['#ff0000', '#ff9900', '#19be6b', '#2979ff', '#9c27b0', '#000000'];
  private demoStops: Array<UPColorPickerStop> = [
    { color: '#ff0000', percent: 0 },
    { color: '#0000ff', percent: 1 }
  ];

  private openPicker(): void {
    this.pickerVisible = true;
    this.resultText = '面板已打开，拖动色域或色相条实时取色';
  }

  private handleModelValueChange(color: string): void {
    this.liveColor = color;
  }

  private handleConfirm(color: string): void {
    this.pickedColor = color;
    this.liveColor = color;
    this.pickerVisible = false;
    this.resultText = '已确认：' + color;
  }

  private handleClose(): void {
    this.pickerVisible = false;
    this.resultText = '已取消，颜色回退到 ' + this.pickedColor;
  }

  private handleClosed(): void {
    this.liveColor = this.pickedColor;
  }

  /** 渐变值无法直接喂给 backgroundColor，只有纯色才上色。/ Only solid values can fill a preview block. */
  private previewColor(): string {
    if (this.pickedColor.startsWith('#') || this.pickedColor.startsWith('rgb')) {
      return this.pickedColor;
    }
    return '#f7f8fa';
  }

  private gradientText(): string {
    return upColorPickerGradientCss(this.demoStops, 'to bottom right');
  }

  private stopCountText(): string {
    const added: Array<UPColorPickerStop> = upColorPickerAddStop(this.demoStops);
    const removed: Array<UPColorPickerStop> = upColorPickerRemoveStop(added, 1);
    return '色标数量：' + String(this.demoStops.length) + ' → 追加后 ' + String(added.length)
      + ' → 删除后 ' + String(removed.length) + '（区间 ' + String(UP_COLOR_PICKER_GRADIENT_MIN)
      + '-' + String(UP_COLOR_PICKER_GRADIENT_MAX) + '）';
  }

  private hslText(): string {
    return 'upColorPickerHslToRgb(210, 90, 55, 0.8) = ' + upColorPickerHslToRgb(210, 90, 55, 0.8);
  }

  private directionText(item: UPColorPickerDirection): string {
    return item.label + '（' + item.value + '）→ CSS ' + String(upColorPickerDirectionAngle(item.value))
      + '° / ArkUI ' + String(upColorPickerArkAngle(item.value)) + '°';
  }

  build() {
    Column({ space: 16 }) {
      Text('受控取色面板')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Stack() {
        Column({ space: 12 }) {
          UPButton({
            props: new UPButtonProps({
              text: '打开取色面板',
              type: 'primary',
              onClick: (): void => {
                this.openPicker();
              }
            })
          })
          Row({ space: 10 }) {
            Column()
              .width(40)
              .height(40)
              .borderRadius(6)
              .backgroundColor(this.previewColor())
              .borderWidth(1)
              .borderColor('#dcdfe6')
            Text(this.pickedColor).fontSize(13).fontColor('#303133').layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          Text(this.resultText).fontSize(13).fontColor('#606266').width('100%')
          Text('实时值：' + this.liveColor).fontSize(13).fontColor('#606266').width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        UPColorPicker({
          props: new UPColorPickerProps({
            show: this.pickerVisible,
            modelValue: this.pickedColor,
            commonColors: this.commonColors,
            onModelValueChange: (color: string): void => {
              this.handleModelValueChange(color);
            },
            onConfirm: (color: string): void => {
              this.handleConfirm(color);
            },
            onClose: (): void => {
              this.handleClose();
            },
            onClosed: (): void => {
              this.handleClosed();
            }
          })
        })
      }
      .width('100%')
      .height(620)
      Text('上游 trigger 插槽换成受控 show：面板没有 onShowChange，onClose 与 onConfirm 后需要宿主自行把 show 置回 false。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text('纯色页有色域、色相、透明度三块，渐变页额外给出色标轨道与方向盘；常用色来自 commonColors。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('渐变色标与方向')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.gradientText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.stopCountText()).fontSize(12).fontColor('#909399').width('100%')
      ForEach(UP_COLOR_PICKER_DIRECTIONS, (item: UPColorPickerDirection): void => {
        Text(this.directionText(item)).fontSize(12).fontColor('#909399').width('100%')
      }, (item: UPColorPickerDirection): string => item.value)
      Text(this.hslText()).fontSize(12).fontColor('#909399').width('100%')
      Text('面板内的方向盘用 sweepGradient 近似 conic-gradient，透明度棋盘格用浅底加白色渐变近似。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
