import {
  UPSignature,
  UPSignatureProps,
  UP_SIGNATURE_ICON_COLOR,
  UP_SIGNATURE_ICON_DISABLED_COLOR,
  UP_SIGNATURE_PRESET_COLORS,
  upSignatureLineWidth,
  upSignatureStrokeColor
} from '@lingyun/ultra-ui-hos';

@Component
export struct SignatureDemo {
  @State private confirmText: string = '签名后点击工具栏最右侧的勾选导出';
  @State private clearText: string = '点击垃圾桶图标清空';
  @State private errorText: string = '导出异常时回传 onError';
  private thicknessValues: Array<number> = [0, 3, 12, 26];

  private handleConfirm(imagePath: string): void {
    this.confirmText = '导出成功，data URL 长度 ' + String(imagePath.length) + ' 字符';
  }

  private handleClear(): void {
    this.clearText = '已清空签名，撤销栈同时归零';
  }

  private handleError(message: string): void {
    this.errorText = 'onError：' + message;
  }

  private thicknessText(value: number): string {
    return 'thickness ' + String(value) + ' → lineWidth ' + String(upSignatureLineWidth(value)) + '（钳制到 1-20）';
  }

  private colorText(): string {
    return "空值回落：upSignatureStrokeColor('') = " + upSignatureStrokeColor('');
  }

  build() {
    Column({ space: 16 }) {
      Text('默认签名板')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPSignature({
        props: new UPSignatureProps({
          width: 300,
          height: 180,
          onConfirm: (imagePath: string): void => {
            this.handleConfirm(imagePath);
          },
          onClear: (): void => {
            this.handleClear();
          },
          onError: (message: string): void => {
            this.handleError(message);
          }
        })
      })
      Text(this.confirmText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.clearText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.errorText).fontSize(13).fontColor('#606266').width('100%')
      Text('工具栏五个按钮依次是撤销、清空、画笔粗细、颜色、导出；撤销与导出在空签名时置灰。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('自定义底色、笔色与粗细')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPSignature({
        props: new UPSignatureProps({
          width: 300,
          height: 150,
          bgColor: '#f7f8fa',
          color: '#2979ff',
          thickness: 8
        })
      })
      Text('画笔面板的滑块与颜色面板的色块会覆盖 color/thickness 初值，props 变更后同样即时生效。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('隐藏工具栏')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPSignature({
        props: new UPSignatureProps({
          width: 300,
          height: 120,
          showToolbar: false,
          color: '#fa3534',
          thickness: 2
        })
      })
      Text('showToolbar=false 时只保留画布，宿主自行提供清空与导出入口。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('预设色板与粗细钳制')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 8 }) {
        ForEach(UP_SIGNATURE_PRESET_COLORS, (color: string): void => {
          Column()
            .width(24)
            .height(24)
            .borderRadius(4)
            .backgroundColor(color)
            .borderWidth(1)
            .borderColor('#dcdfe6')
        }, (color: string): string => color)
      }
      .width('100%')
      ForEach(this.thicknessValues, (value: number): void => {
        Text(this.thicknessText(value)).fontSize(12).fontColor('#909399').width('100%')
      }, (value: number): string => String(value))
      Text(this.colorText()).fontSize(12).fontColor('#909399').width('100%')
      Text('图标常态色 ' + UP_SIGNATURE_ICON_COLOR + '，禁用色 ' + UP_SIGNATURE_ICON_DISABLED_COLOR
        + '；导出返回 base64 data URL，上游返回临时文件路径。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
