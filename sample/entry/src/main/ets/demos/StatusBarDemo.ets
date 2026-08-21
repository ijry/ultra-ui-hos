import { UPStatusBar, UPStatusBarProps } from '@lingyun/ultra-ui-hos';

@Component
export struct StatusBarDemo {
  @State private statusBarHeight: number = 0;
  build() {
    Column({ space: 14 }) {
      UPStatusBar({ props: new UPStatusBarProps({ bgColor: '#2979ff', onHeightChange: (height: number): void => { this.statusBarHeight = height; } }) })
      Text('系统高度回调：' + String(this.statusBarHeight) + ' px').fontSize(14).fontColor('#303133')
      UPStatusBar({ props: new UPStatusBarProps({ height: 18, bgColor: '#ecf5ff' }) })
      Text('显式 height=18px，系统信息不可用时安全回退为 0').fontSize(12).fontColor('#909399')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
