import {
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UPPdfReader,
  UPPdfReaderProps,
  UPPdfReaderViewerEvent,
  UP_PDF_READER_FILE_QUERY,
  UP_PDF_READER_HEIGHT,
  UP_PDF_READER_VIEWER_PATH,
  UP_PDF_READER_WIDTH,
  upPdfReaderEncode,
  upPdfReaderViewerUrl
} from '@lingyun/ultra-ui-hos';

@Component
export struct PdfReaderDemo {
  @State private status: string = '组件只计算 viewerUrl，不内嵌浏览器内核，也不发起网络请求';
  @State private boundary: string = '';
  @State private viewer: string = '';
  @State private hosted: boolean = false;
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private source: string = '/data/storage/el2/base/files/示例 报告.pdf';
  private probeSources: Array<string> = ['report.pdf', '/files/年度 报表.pdf', 'a~b(1).pdf'];

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private handleViewerUrl(event: UPPdfReaderViewerEvent): void {
    this.viewer = event.viewerUrl;
    this.status = 'onViewerUrl 已回传，长度 ' + String(event.viewerUrl.length) + ' 字符';
  }

  private probeText(source: string): string {
    return source + ' → ' + UP_PDF_READER_FILE_QUERY + upPdfReaderEncode(source);
  }

  private viewerPreview(): string {
    const url: string = upPdfReaderViewerUrl('', this.source);
    return url.length > 72 ? url.substring(0, 72) + '…' : url;
  }

  @Builder
  private hostViewer() {
    Column({ space: 6 }) {
      Text('宿主 viewerBuilder 已接入')
        .fontSize(14)
        .fontColor('#303133')
      Text('这里可以放入宿主自带的 PDF 渲染视图或外部打开入口')
        .fontSize(12)
        .fontColor('#909399')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 16, right: 16 })
  }

  build() {
    Column({ space: 16 }) {
      Text('PDF 阅读器')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      if (this.hosted) {
        UPPdfReader({
          props: new UPPdfReaderProps({
            src: this.source,
            height: '260px',
            diagnostics: this.diagnostics,
            onViewerUrl: (event: UPPdfReaderViewerEvent): void => {
              this.handleViewerUrl(event);
            }
          }),
          viewerBuilder: this.hostViewer
        })
      } else {
        UPPdfReader({
          props: new UPPdfReaderProps({
            src: this.source,
            height: '260px',
            diagnostics: this.diagnostics,
            onViewerUrl: (event: UPPdfReaderViewerEvent): void => {
              this.handleViewerUrl(event);
            }
          })
        })
      }
      Row({ space: 10 }) {
        Button(this.hosted ? '切回内置占位' : '接入宿主视图')
          .fontSize(14)
          .height(36)
          .backgroundColor('#ecf5ff')
          .fontColor('#2979ff')
          .onClick((): void => {
            this.hosted = !this.hosted;
            this.status = this.hosted
              ? 'viewerBuilder 已接入，占位内容被替换'
              : '未接入 viewerBuilder 时渲染内置占位';
          })
      }
      .width('100%')
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.viewer.length > 0 ? 'viewerUrl 前缀：' + this.viewerPreview() : '尚未收到 viewerUrl')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('文件参数编码')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      ForEach(this.probeSources, (source: string): void => {
        Text(this.probeText(source)).fontSize(12).fontColor('#909399').width('100%')
      }, (source: string): string => source)
      Text('viewer 路径固定为 ' + UP_PDF_READER_VIEWER_PATH + '，与上游 pdf.js 目录结构一致。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('上游默认高度 ' + UP_PDF_READER_HEIGHT + '，web-view 固定宽度 ' + UP_PDF_READER_WIDTH + ' 改为跟随容器宽度。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('上游 watch baseUrl 只把值赋回自身，实际生效的是 mounted 时读到的初值，这一行为不复刻。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
