import { UPToolbar, UPToolbarActionEvent, UPToolbarProps } from '@lingyun/ultra-ui-hos';

@Component
export struct ToolbarDemo {
  @State private message: string = '等待工具栏操作';

  build() {
    Column({ space: 16 }) {
      Text('Picker 复用工具栏').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPToolbar({
        props: new UPToolbarProps({
          title: '选择城市',
          cancelText: '取消',
          confirmText: '完成',
          onCancel: (): void => {
            this.message = '点击取消';
          },
          onConfirm: (): void => {
            this.message = '点击确认';
          },
          onAction: (event: UPToolbarActionEvent): void => {
            this.message = '动作：' + event.action;
          }
        })
      })
      UPToolbar({
        props: new UPToolbarProps({ show: false, title: '隐藏工具栏' })
      })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
