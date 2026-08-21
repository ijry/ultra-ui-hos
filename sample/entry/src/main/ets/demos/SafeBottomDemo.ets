import { UPSafeBottom, UPSafeBottomProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SafeBottomDemo {
  build() {
    Column({ space: 14 }) {
      Text('底部内容').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133')
      Text('安全区能力不可用时使用 0 的确定性回退').fontSize(13).fontColor('#606266')
      UPSafeBottom({ props: new UPSafeBottomProps({ safeAreaInsetBottom: true }) }) { Text('safeAreaInsetBottom=true').fontSize(12).fontColor('#909399') }
      UPSafeBottom({ props: new UPSafeBottomProps({ safeAreaInsetBottom: false, customStyle: { backgroundColor: '#ecf5ff', padding: { bottom: 10 } } }) }) { Text('关闭安全区并指定 padding').fontSize(12).fontColor('#2979ff') }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
