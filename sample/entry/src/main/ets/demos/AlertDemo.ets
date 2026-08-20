import { UPAlert, UPAlertProps, UPButton, UPButtonProps } from '@lingyun/ultra-ui-hos';
@Component
export struct AlertDemo {
  @State private visible: boolean = true;
  build() {
    Column({ space: 14 }) {
      Text('提示条').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPAlert({ props: new UPAlertProps({ title: '操作成功', description: '页面状态控制提示条的显示与关闭。', type: 'success', closable: true, modelValue: this.visible, onVisibleChange: (value: boolean): void => { this.visible = value; } }) })
      UPButton({ props: new UPButtonProps({ text: this.visible ? '关闭后重新显示' : '显示提示条', type: 'primary', onClick: (): void => { this.visible = !this.visible; } }) })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
