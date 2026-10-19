import {
  UPAlbum,
  UPAlbumItem,
  UPAlbumPreviewEvent,
  UPAlbumProps,
  upAlbumItems,
  upAlbumRows
} from '@lingyun/ultra-ui-hos';

@Component
export struct AlbumDemo {
  @State private previewText: string = '点击任意图片查看 preview 回传';
  @State private widthText: string = '相册宽度待回传';
  private singleItem: Array<UPAlbumItem> = upAlbumItems(['$rawfile:app_icon.png']);
  private fourItems: Array<UPAlbumItem> = upAlbumItems([
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png'
  ]);
  private manyItems: Array<UPAlbumItem> = upAlbumItems([
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png',
    '$rawfile:app_icon.png'
  ]);
  private remoteItems: Array<UPAlbumItem> = [
    { url: 'ftp://example.invalid/a.png' },
    { url: 'ftp://example.invalid/b.png' }
  ];

  private handlePreview(event: UPAlbumPreviewEvent): void {
    this.previewText = '预览第 ' + String(event.currentIndex + 1) + ' 张，共 ' + String(event.urls.length) + ' 张';
  }

  private handleWidth(value: number): void {
    this.widthText = '相册宽度回传：' + String(Math.round(value)) + 'vp';
  }

  private rowSummary(total: number, rowCount: number, maxCount: number, autoWrap: boolean): string {
    const rows: Array<Array<number>> = upAlbumRows(total, rowCount, maxCount, autoWrap);
    const columns: Array<string> = rows.map((row: Array<number>): string => String(row.length));
    return String(total) + ' 张 / 每行 ' + String(rowCount) + ' / 上限 ' + String(maxCount)
      + (autoWrap ? '（autoWrap）' : '') + ' → ' + columns.join('+');
  }

  build() {
    Column({ space: 16 }) {
      Text('单图与九宫格')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPAlbum({
        props: new UPAlbumProps({
          urls: this.singleItem,
          singleSize: 120,
          previewFullImage: false,
          onPreview: (event: UPAlbumPreviewEvent): void => {
            this.handlePreview(event);
          },
          onAlbumWidth: (value: number): void => {
            this.handleWidth(value);
          }
        })
      })
      UPAlbum({
        props: new UPAlbumProps({
          urls: this.fourItems,
          multipleSize: 72,
          space: 8,
          previewFullImage: false,
          onPreview: (event: UPAlbumPreviewEvent): void => {
            this.handlePreview(event);
          }
        })
      })
      Text(this.previewText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.widthText).fontSize(13).fontColor('#606266').width('100%')

      Text('超出上限的 +N 罩层')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPAlbum({
        props: new UPAlbumProps({
          urls: this.manyItems,
          multipleSize: 64,
          maxCount: 8,
          rowCount: 4,
          space: 6,
          previewFullImage: false,
          onPreview: (event: UPAlbumPreviewEvent): void => {
            this.handlePreview(event);
          }
        })
      })
      Text(this.rowSummary(12, 4, 8, false)).fontSize(12).fontColor('#909399').width('100%')
      Text(this.rowSummary(12, 3, 9, false)).fontSize(12).fontColor('#909399').width('100%')
      Text(this.rowSummary(12, 3, 5, true)).fontSize(12).fontColor('#909399').width('100%')

      Text('圆形裁剪与单行横排')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPAlbum({
        props: new UPAlbumProps({
          urls: this.fourItems,
          multipleSize: 56,
          shape: 'circle',
          space: 10,
          previewFullImage: false
        })
      })
      UPAlbum({
        props: new UPAlbumProps({
          urls: this.fourItems,
          multipleSize: 48,
          radius: 8,
          autoWrap: true,
          maxCount: 4,
          previewFullImage: false
        })
      })

      Text('非本地地址回落占位')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPAlbum({
        props: new UPAlbumProps({
          urls: this.remoteItems,
          multipleSize: 72,
          keyName: 'url',
          previewFullImage: false
        })
      })
      Text('remote 地址不会发起加载，一律渲染本地占位并记录诊断；预览需宿主接 onPreview 打开自有页面。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
