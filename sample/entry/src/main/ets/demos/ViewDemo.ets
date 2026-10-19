import { UPView, UPViewClickEvent, UPViewProps } from '@lingyun/ultra-ui-hos';

@Component
export struct ViewDemo {
  @State private message: string = '点击容器查看回传';

  @Builder
  private content() {
    Column({ space: 6 }) {
      Text('UPView 是通用内容容器').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133')
      Text('支持 Flex 方向、尺寸、边距、边框与自定义 Builder。').fontSize(13).fontColor('#606266')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column({ space: 14 }) {
      Text('容器与样式').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPView({
        props: new UPViewProps({
          name: 'view-card',
          index: 1,
          flexDirection: 'row',
          alignItems: 'center',
          bgColor: '#ecf5ff',
          padding: { top: 16, right: 16, bottom: 16, left: 16 },
          border: true,
          borderColor: '#b3d8ff',
          borderRadius: 10,
          onClick: (event: UPViewClickEvent): void => {
            this.message = '点击：' + String(event.name) + ' / index=' + String(event.index);
          }
        })
      }) {
        this.content()
      }
      UPView({
        props: new UPViewProps({
          flexDirection: 'row',
          justifyContent: 'space-between',
          bgColor: '#f0f9eb',
          padding: 12,
          customStyle: { margin: { top: 4, bottom: 4 }, borderRadius: 8 }
        })
      }) {
        Text('自定义样式').fontSize(14).fontColor('#67c23a')
        Text('Builder').fontSize(12).fontColor('#909399')
      }
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
