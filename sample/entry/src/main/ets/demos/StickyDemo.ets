import { UPSticky, UPStickyProps } from '@lingyun/ultra-ui-hos';

@Component
export struct StickyDemo {
  build() {
    Column({ space: 12 }) {
      Text('吸顶').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSticky({ props: new UPStickyProps({ offsetTop: 12, customNavHeight: 0, bgColor: '#ecf5ff' }) }) {
        Text('宿主滚动容器内可结合原生列表使用').fontSize(14).padding(12)
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
