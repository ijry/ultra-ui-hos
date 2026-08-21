import { UPLoadingIcon, UPLoadingIconProps } from '@lingyun/ultra-ui-hos';

@Component
export struct LoadingIconDemo {
  build() {
    Column({ space: 22 }) {
      Text('三种加载模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPLoadingIcon({ props: new UPLoadingIconProps({ mode: 'spinner', color: 'primary', text: 'spinner 模式' }) })
      UPLoadingIcon({ props: new UPLoadingIconProps({ mode: 'semicircle', color: 'warning', text: 'semicircle 模式' }) })
      UPLoadingIcon({ props: new UPLoadingIconProps({ mode: 'circle', color: 'success', text: 'circle 模式', vertical: true }) })
      Text('加载图标的可见性由 show 属性受控。')
        .fontSize(13)
        .fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
