import {
  UPBarcodeEncodeResult,
  UPBarcode,
  UPBarcodeProps,
  UPBarcodeRenderedEvent,
  UPSubsection,
  UPSubsectionItem,
  UPSubsectionProps,
  upBarcodeEncode,
  upBarcodeFormatSupported
} from '@lingyun/ultra-ui-hos';

@Component
export struct BarcodeDemo {
  @State private current: number = 0;
  @State private renderedText: string = 'rendered 事件回传 canvasId';
  @State private errorText: string = '校验失败时回传 onError';
  @State private useCanvas: boolean = true;
  private formats: Array<UPSubsectionItem> = [{ name: 'CODE128' }, { name: 'EAN13' }, { name: 'CODE39' }];
  private formatNames: Array<string> = ['CODE128', 'EAN13', 'CODE39'];
  private formatValues: Array<string> = ['ULTRA-UI-2026', '6901234567892', 'HOS2026'];
  private probeFormats: Array<string> = ['CODE128', 'EAN13', 'ITF14', 'MSI', 'pharmacode'];

  private handleRendered(event: UPBarcodeRenderedEvent): void {
    this.renderedText = this.useCanvas
      ? 'rendered：type=' + event.type + '，id=' + event.id
      : 'rendered：type=' + event.type + '，data URL 长度 ' + String(event.path.length) + ' 字符';
  }

  private handleError(message: string): void {
    this.errorText = 'onError：' + message;
  }

  private selectFormat(index: number): void {
    this.current = index;
    this.errorText = '已切换到 ' + this.formatNames[index] + '，条码内容 ' + this.formatValues[index];
  }

  private toggleCanvas(): void {
    this.useCanvas = !this.useCanvas;
    this.renderedText = this.useCanvas ? '已切回 canvas 分支' : '已切到 image 分支，rendered 回传 data URL';
  }

  private probeText(format: string): string {
    const supported: boolean = upBarcodeFormatSupported(format);
    const encoded: UPBarcodeEncodeResult = upBarcodeEncode('123456789012', format);
    const detail: string = encoded.error.length > 0
      ? '编码失败：' + encoded.error
      : '模块数 ' + String(encoded.pattern.length);
    return format + (supported ? '：白名单内' : '：不在白名单，回落 CODE128') + '，' + detail;
  }

  build() {
    Column({ space: 16 }) {
      Text('多码制切换')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPSubsection({
        props: new UPSubsectionProps({
          list: this.formats,
          current: this.current,
          onChange: (index: number): void => {
            this.selectFormat(index);
          }
        })
      })
      UPBarcode({
        props: new UPBarcodeProps({
          value: this.formatValues[this.current],
          format: this.formatNames[this.current],
          width: 260,
          height: 90,
          useCanvas: this.useCanvas,
          onRendered: (event: UPBarcodeRenderedEvent): void => {
            this.handleRendered(event);
          },
          onError: (message: string): void => {
            this.handleError(message);
          }
        })
      })
      Row({ space: 12 }) {
        Button(this.useCanvas ? '切到 image 分支' : '切回 canvas 分支')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.toggleCanvas();
          })
      }
      .width('100%')
      Text(this.renderedText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.errorText).fontSize(13).fontColor('#606266').width('100%')

      Text('文本位置与对齐')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPBarcode({
        props: new UPBarcodeProps({
          value: '6901234567892',
          format: 'EAN13',
          width: 240,
          height: 70,
          textPosition: 'top',
          textAlign: 'left',
          fontSize: 12,
          textMargin: 6,
          lineColor: '#2979ff'
        })
      })
      UPBarcode({
        props: new UPBarcodeProps({
          value: 'NO-TEXT',
          width: 240,
          height: 60,
          displayValue: false,
          background: '#f7f8fa',
          margin: 6
        })
      })
      Text('textPosition 支持 top/bottom，textAlign 支持 left/center/right；font 与 fontOptions 上游从未写入画布上下文，这里同样只生效 fontSize 并报诊断。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('校验失败与格式白名单')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPBarcode({
        props: new UPBarcodeProps({
          value: '12345',
          format: 'EAN13',
          width: 240,
          height: 60,
          onError: (message: string): void => {
            this.handleError(message);
          }
        })
      })
      Text('EAN13 要求 13 位数字，位数不足时上游抛异常中断渲染，这里改为灰底红字错误态并回调 onError。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      ForEach(this.probeFormats, (format: string): void => {
        Text(this.probeText(format)).fontSize(12).fontColor('#909399').width('100%')
      }, (format: string): string => format)
      Text('CODE128/CODE39/EAN13/EAN8/EAN5/EAN2/UPCA/UPCE 逐码制复刻校验位算法，ITF/MSI/pharmacode 上游 switch 无分支，同样回落 CODE128。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
