import {
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UPCropper,
  UPCropperConfirmEvent,
  UPCropperFailureEvent,
  UPCropperInitEvent,
  UPCropperProps,
  UPCropperRect,
  UP_CROPPER_MAX_SCALE,
  UP_CROPPER_MIN_SCALE,
  UP_CROPPER_MIN_SELECTION,
  UP_CROPPER_STRETCH_MODES,
  UP_CROPPER_TAB_HEIGHT,
  upCropperHandleAt,
  upCropperLength,
  upCropperQuality,
  upCropperStretchSupported
} from '@lingyun/ultra-ui-hos';

@Component
export struct CropperDemo {
  @State private status: string = '裁剪面板由宿主提供图片地址与原图尺寸';
  @State private boundary: string = '';
  @State private result: string = '';
  @State private inner: boolean = false;
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private probeStretches: Array<string> = ['x', 'y', 'long', 'shortSel', 'diagonal'];
  private source: string = '/data/storage/el2/base/files/sample.png';

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private pickImage(): string {
    this.status = '宿主 chooseImage 回调返回了本地示例图片';
    return this.source;
  }

  private handleInit(event: UPCropperInitEvent): void {
    this.status = 'avtinit：画布 ' + String(Math.round(event.width)) + 'x' + String(Math.round(event.height))
      + '，裁剪框 ' + String(Math.round(event.selectionWidth)) + 'x' + String(Math.round(event.selectionHeight));
  }

  private handleConfirm(event: UPCropperConfirmEvent): void {
    this.result = 'data URL 长度 ' + String(event.path.length) + '，导出尺寸 '
      + String(Math.round(event.width)) + 'x' + String(Math.round(event.height));
    this.status = 'confirm：index=' + String(event.index);
  }

  private handleFailure(event: UPCropperFailureEvent): void {
    this.status = '失败：' + event.reason + '，' + event.message;
  }

  private areaText(): string {
    return '300rpx 在 375 视口下折算为 ' + String(upCropperLength('300rpx', 375)) + 'vp';
  }

  private qualityText(): string {
    return 'quality 空串回落 ' + String(upCropperQuality('')) + '，传 1 时为 ' + String(upCropperQuality('1'));
  }

  private handleText(): string {
    const rect: UPCropperRect = new UPCropperRect(100, 100, 120, 120);
    return '命中判定：(100,100) → ' + upCropperHandleAt({ x: 100, y: 100 }, rect)
      + '，(220,220) → ' + upCropperHandleAt({ x: 220, y: 220 }, rect);
  }

  private probeText(stretch: string): string {
    return 'stretch=' + stretch + (upCropperStretchSupported(stretch)
      ? '：命中上游分支'
      : '：不在 ' + UP_CROPPER_STRETCH_MODES.join('/') + ' 内，回落默认适配并报诊断');
  }

  build() {
    Column({ space: 16 }) {
      Text('图片裁剪')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCropper({
        props: new UPCropperProps({
          imageSrc: this.source,
          imageWidth: 1200,
          imageHeight: 900,
          areaWidth: '300rpx',
          areaHeight: '300rpx',
          exportWidth: '260rpx',
          exportHeight: '260rpx',
          canChangeSize: true,
          inner: this.inner,
          viewportWidth: 340,
          viewportHeight: 420,
          fillColor: '#ffffff',
          diagnostics: this.diagnostics,
          chooseImage: (): string => {
            return this.pickImage();
          },
          onInit: (event: UPCropperInitEvent): void => {
            this.handleInit(event);
          },
          onConfirm: (event: UPCropperConfirmEvent): void => {
            this.handleConfirm(event);
          },
          onCancel: (): void => {
            this.status = '已取消裁剪';
          },
          onFailure: (event: UPCropperFailureEvent): void => {
            this.handleFailure(event);
          }
        })
      })
      Row({ space: 10 }) {
        Button(this.inner ? '关闭 inner 模式' : '开启 inner 模式')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.inner = !this.inner;
            this.status = this.inner
              ? 'inner=true：裁剪框不会超出图片，且禁用旋转'
              : 'inner=false：可自由平移与旋转';
          })
      }
      .width('100%')
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.result.length > 0 ? this.result : '尚未导出裁剪结果')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('几何自检')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.areaText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.qualityText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.handleText()).fontSize(12).fontColor('#909399').width('100%')
      Text('缩放区间 ' + String(UP_CROPPER_MIN_SCALE) + '~' + String(UP_CROPPER_MAX_SCALE)
        + '，裁剪框最小边 ' + String(UP_CROPPER_MIN_SELECTION) + 'vp，操作条高 '
        + String(UP_CROPPER_TAB_HEIGHT) + 'vp')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      ForEach(this.probeStretches, (stretch: string): void => {
        Text(this.probeText(stretch)).fontSize(12).fontColor('#909399').width('100%')
      }, (stretch: string): string => stretch)
      Text('上游三层 canvas 合并成一张画布：图片、遮罩与预览分别重绘，不再依赖多个 canvas 上下文。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('系统相册与相机由宿主 chooseImage 提供，导出结果是 base64 data URL 而不是临时文件路径。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
