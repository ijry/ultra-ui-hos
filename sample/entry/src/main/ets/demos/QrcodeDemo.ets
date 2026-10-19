import {
  UPButton,
  UPButtonProps,
  UPQrcode,
  UPQrcodeEncoder,
  UPQrcodeProps,
  UPSwitch,
  UPSwitchChangeEvent,
  UPSwitchProps,
  upQrcodeLevel,
  upQrcodeUtf8Bytes
} from '@lingyun/ultra-ui-hos';

@Component
export struct QrcodeDemo {
  @State private content: string = 'uview-plus.jiangruyi.com';
  @State private resultText: string = '生成完成后回传 data URL';
  @State private previewText: string = '点击码图触发 onPreview';
  @State private errorText: string = '内容为空时回传 onError';
  @State private quietZone: number = 0;
  @State private showLoading: boolean = true;
  private levels: Array<number> = [0, 1, 2, 3];
  private levelNames: Array<string> = ['L 7%', 'M 15%', 'Q 25%', 'H 30%'];

  private handleResult(result: string): void {
    this.resultText = result.length === 0
      ? '已调用 clear()，结果被重置为空串'
      : 'onResult：data URL 长度 ' + String(result.length) + ' 字符（上游为临时文件路径）';
  }

  private handlePreview(url: string): void {
    this.previewText = url.length === 0
      ? 'onPreview：尚未生成码图'
      : 'onPreview：收到 data URL（上游走 uni.previewImage）';
  }

  private handleError(message: string): void {
    this.errorText = 'onError：' + message;
  }

  private toggleContent(): void {
    this.content = this.content.length > 20 ? 'ultra-ui-hos' : 'uview-plus.jiangruyi.com';
    this.resultText = '内容已切换为 ' + String(upQrcodeUtf8Bytes(this.content).length) + ' 字节，watch 触发重绘';
  }

  private toggleQuietZone(): void {
    this.quietZone = this.quietZone === 0 ? 2 : 0;
  }

  private toggleLoading(event: UPSwitchChangeEvent): void {
    this.showLoading = event.checked;
  }

  private levelText(level: number): string {
    const encoder: UPQrcodeEncoder = new UPQrcodeEncoder(this.content, upQrcodeLevel(level));
    return 'lv=' + String(level) + '（' + this.levelNames[level] + '）→ 版本矩阵 '
      + String(encoder.getModuleCount()) + ' × ' + String(encoder.getModuleCount());
  }

  build() {
    Column({ space: 16 }) {
      Text('基础二维码')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPQrcode({
        props: new UPQrcodeProps({
          val: this.content,
          size: 180,
          showLoading: this.showLoading,
          quietZone: this.quietZone,
          onResult: (result: string): void => {
            this.handleResult(result);
          },
          onPreview: (url: string): void => {
            this.handlePreview(url);
          },
          onError: (message: string): void => {
            this.handleError(message);
          }
        })
      })
      Row({ space: 12 }) {
        UPButton({
          props: new UPButtonProps({
            text: '切换内容',
            size: 'small',
            onClick: (): void => {
              this.toggleContent();
            }
          })
        })
        UPButton({
          props: new UPButtonProps({
            text: this.quietZone === 0 ? '加白边' : '去白边',
            type: 'primary',
            size: 'small',
            onClick: (): void => {
              this.toggleQuietZone();
            }
          })
        })
      }
      .width('100%')
      Row({ space: 10 }) {
        Text('生成中蒙层').fontSize(13).fontColor('#606266')
        UPSwitch({
          props: new UPSwitchProps({
            modelValue: this.showLoading,
            size: 22,
            onChange: (event: UPSwitchChangeEvent): void => {
              this.toggleLoading(event);
            }
          })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Text(this.resultText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.previewText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.errorText).fontSize(13).fontColor('#606266').width('100%')

      Text('容错级别与定位角配色')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 14 }) {
        UPQrcode({
          props: new UPQrcodeProps({
            val: this.content,
            size: 120,
            lv: 0,
            showLoading: false
          })
        })
        UPQrcode({
          props: new UPQrcodeProps({
            val: this.content,
            size: 120,
            lv: 3,
            foreground: '#2979ff',
            pdground: '#fa3534',
            background: '#ecf5ff',
            showLoading: false
          })
        })
      }
      .width('100%')
      ForEach(this.levels, (level: number): void => {
        Text(this.levelText(level)).fontSize(12).fontColor('#909399').width('100%')
      }, (level: number): string => String(level))
      Text('foreground 铺满格子，pdground 只作用于三个定位角内核，与上游 getForeGround() 完全一致。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('rpx 单位与根节点自适应')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPQrcode({
        props: new UPQrcodeProps({
          val: 'unit=rpx',
          size: 400,
          unit: 'rpx',
          showLoading: false
        })
      })
      Text('size=400 且 unit=rpx 时按 375 设计稿换算为 200vp 边长；unit 只支持 px/rpx/upx，其余单位回落 px 并报诊断。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Column() {
        UPQrcode({
          props: new UPQrcodeProps({
            val: 'useRootHeightAndWidth',
            useRootHeightAndWidth: true,
            showLoading: false
          })
        })
      }
      .width(150)
      .height(150)
      Text('useRootHeightAndWidth 时取根节点短边作为边长，等价上游 setNewSize()。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text('长按码图触发 onLongpress，点击触发 onPreview；saveImageToPhotosAlbum 与 previewImage 不复刻，统一改回调透传 base64 data URL。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
