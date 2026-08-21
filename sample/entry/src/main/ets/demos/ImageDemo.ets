import { UPImage, UPImageClickEvent, UPImageProps } from '@lingyun/ultra-ui-hos';

@Component
export struct ImageDemo {
  @State private message: string = '图片只读取示例工程中的本地资源';

  private selected(event: UPImageClickEvent): void {
    this.message = '点击图片：' + event.mode;
  }

  build() {
    Column({ space: 16 }) {
      Text('本地图片与占位回退')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 16 }) {
        UPImage({ props: new UPImageProps({
          src: '$rawfile:app_icon.png',
          width: 88,
          height: 88,
          shape: 'round',
          radius: 12,
          mode: 'aspectFit',
          onClick: (event: UPImageClickEvent): void => { this.selected(event); }
        }) })
        UPImage({ props: new UPImageProps({
          src: '',
          width: 88,
          height: 88,
          shape: 'circle',
          errorIcon: 'photo',
          bgColor: '#f3f4f6'
        }) })
      }
      Text('左侧使用 $rawfile 本地资源；右侧为空源时显示确定性图标回退。')
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
