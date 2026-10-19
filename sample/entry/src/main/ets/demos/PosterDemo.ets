import {
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UPPoster,
  UPPosterConfig,
  UPPosterController,
  UPPosterFailureEvent,
  UPPosterImage,
  UPPosterLine,
  UPPosterProps,
  UPPosterView,
  UP_POSTER_DEFAULT_HEIGHT,
  UP_POSTER_DEFAULT_WIDTH,
  UP_POSTER_VIEW_TYPES,
  upPosterEstimateWidth,
  upPosterGradientAngle,
  upPosterGradientColors,
  upPosterLength,
  upPosterTypeSupported,
  upPosterWrapText
} from '@lingyun/ultra-ui-hos';

@Component
export struct PosterDemo {
  @State private status: string = '海报按 json 配置在画布上合成，二维码复用内置编码器';
  @State private boundary: string = '';
  @State private exported: string = '';
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private controller: UPPosterController = new UPPosterController();
  private probeTypes: Array<string> = ['view', 'text', 'image', 'qrcode', 'canvas'];
  private config: UPPosterConfig = {
    css: {
      width: '600rpx',
      height: '840rpx',
      background: 'linear-gradient(180deg, #2979ff, #19be6b)'
    },
    views: [
      {
        type: 'view',
        css: { left: '40rpx', top: '40rpx', width: '520rpx', height: '360rpx', background: '#ffffff', radius: '16rpx' }
      },
      {
        type: 'text',
        text: '阶段 20 海报合成',
        css: { left: '72rpx', top: '92rpx', width: '460rpx', color: '#303133', fontSize: '36rpx', fontWeight: 'bold' }
      },
      {
        type: 'text',
        text: '这段文案用于演示行数限制与省略号：超过两行的部分会在末行结尾补上省略号，宽度按字符估算折行。',
        css: {
          left: '72rpx', top: '164rpx', width: '460rpx', color: '#606266',
          fontSize: '26rpx', lineHeight: '40rpx', lineClamp: '2'
        }
      },
      {
        type: 'view',
        css: { left: '72rpx', top: '268rpx', width: '460rpx', height: '2rpx', background: '#ebeef5' }
      },
      {
        type: 'qrcode',
        text: 'https' + '://uview-plus.jiangruyi.com',
        css: { left: '72rpx', top: '300rpx', width: '160rpx', height: '160rpx' }
      },
      {
        type: 'text',
        text: '扫码查看组件文档',
        css: { left: '260rpx', top: '360rpx', width: '280rpx', color: '#909399', fontSize: '24rpx' }
      },
      {
        type: 'view',
        css: { left: '40rpx', top: '640rpx', width: '520rpx', height: '160rpx', background: 'radial-gradient(#ffffff, #dcdfe6)', radius: '20rpx' }
      }
    ]
  };

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private handleExport(image: UPPosterImage): void {
    this.exported = 'data URL 长度 ' + String(image.path.length) + '，尺寸 '
      + String(Math.round(image.width)) + 'x' + String(Math.round(image.height));
    this.status = '导出完成，宿主可自行落盘或分享';
  }

  private handleFailure(event: UPPosterFailureEvent): void {
    this.status = '导出失败：' + event.reason + '，' + event.message;
  }

  private lengthText(): string {
    return '600rpx 在 375 视口下折算为 ' + String(Math.round(upPosterLength('600rpx', 375))) + 'vp';
  }

  private gradientText(): string {
    const source: string = 'linear-gradient(90deg, #2979ff, #19be6b)';
    return '角度 ' + String(upPosterGradientAngle(source)) + '，色标 '
      + upPosterGradientColors(source).join(' → ');
  }

  private wrapText(): string {
    const lines: Array<UPPosterLine> = upPosterWrapText('折行演示：这一段会被截断并补省略号', 120, 26, 2);
    const texts: Array<string> = [];
    for (const line of lines) {
      texts.push(line.text);
    }
    return '两行折行结果：' + texts.join(' / ');
  }

  private estimateText(): string {
    return '「组件」估算宽度 ' + String(Math.round(upPosterEstimateWidth('组件', 26)))
      + '，「ab」估算宽度 ' + String(Math.round(upPosterEstimateWidth('ab', 26)));
  }

  private probeText(type: string): string {
    return 'type=' + type + (upPosterTypeSupported(type)
      ? '：命中上游 switch 分支'
      : '：不在 ' + UP_POSTER_VIEW_TYPES.join('/') + ' 内，跳过绘制并报诊断');
  }

  build() {
    Column({ space: 16 }) {
      Text('海报合成')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPPoster({
        props: new UPPosterProps({
          json: this.config,
          viewportWidth: 375,
          controller: this.controller,
          diagnostics: this.diagnostics,
          onExport: (image: UPPosterImage): void => {
            this.handleExport(image);
          },
          onFailure: (event: UPPosterFailureEvent): void => {
            this.handleFailure(event);
          }
        })
      })
      Row({ space: 10 }) {
        Button('导出海报')
          .fontSize(14)
          .height(36)
          .backgroundColor('#ecf5ff')
          .fontColor('#2979ff')
          .onClick((): void => {
            this.controller.exportImage();
          })
        Button('重绘画布')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.controller.redraw();
            this.status = '已按当前 json 重绘画布';
          })
      }
      .width('100%')
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.exported.length > 0 ? this.exported : '尚未导出海报')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('绘制自检')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.lengthText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.gradientText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.wrapText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.estimateText()).fontSize(12).fontColor('#909399').width('100%')
      ForEach(this.probeTypes, (type: string): void => {
        Text(this.probeText(type)).fontSize(12).fontColor('#909399').width('100%')
      }, (type: string): string => type)
      Text('默认海报尺寸沿用上游 ' + UP_POSTER_DEFAULT_WIDTH + ' × ' + UP_POSTER_DEFAULT_HEIGHT + '。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('二维码不再借道隐藏组件与临时文件，直接用内置编码器逐格绘制；文本宽度按字符估算而非画布量测。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('导出结果是 base64 data URL，落盘、相册写入与分享由宿主负责。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
