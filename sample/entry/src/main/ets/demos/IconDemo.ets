import { UPIcon, UPIconProps, UPRawValue } from '@lingyun/ultra-ui-hos';

@Component
export struct IconDemo {
  @State private message: string = '点击图标查看 index 回传';

  private select(index: string): void {
    this.message = '已点击：' + index;
  }

  build() {
    Column({ space: 18 }) {
      Text('常用图标')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 20 }) {
        UPIcon({ props: new UPIconProps({
          name: 'check', color: 'success', size: 28, label: '完成', labelPos: 'bottom', index: 'check',
          onClick: (index: UPRawValue): void => {
            this.select(String(index));
          }
        }) })
        UPIcon({ props: new UPIconProps({
          name: 'warning', color: 'warning', size: 28, label: '提醒', labelPos: 'bottom', index: 'warning',
          onClick: (index: UPRawValue): void => {
            this.select(String(index));
          }
        }) })
        UPIcon({ props: new UPIconProps({
          name: 'search', color: 'primary', size: 28, label: '搜索', labelPos: 'bottom', index: 'search',
          onClick: (index: UPRawValue): void => {
            this.select(String(index));
          }
        }) })
        UPIcon({ props: new UPIconProps({
          name: 'heart', color: 'error', size: 28, label: '喜欢', labelPos: 'bottom', index: 'heart',
          onClick: (index: UPRawValue): void => {
            this.select(String(index));
          }
        }) })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      Text('标签方向')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPIcon({ props: new UPIconProps({ name: 'info', color: 'primary', label: '标签在左侧', labelPos: 'left', size: 22 }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
  }
}
