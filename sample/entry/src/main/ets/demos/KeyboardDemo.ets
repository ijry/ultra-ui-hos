import { UPKeyboard, UPKeyboardConfirmEvent, UPKeyboardDeleteEvent, UPKeyboardKeyEvent, UPKeyboardProps } from '@lingyun/ultra-ui-hos';

@Component
export struct KeyboardDemo {
  @State private value: string = '';
  @State private message: string = '等待输入';

  build() {
    Column({ space: 12 }) {
      Text('虚拟键盘').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      Text('输入值：' + this.value).fontSize(14).fontColor('#303133').width('100%')
      UPKeyboard({ props: new UPKeyboardProps({ mode: 'idcard', maxLength: 8, confirmText: '完成',
        onKey: (event: UPKeyboardKeyEvent): void => { this.value = event.value; this.message = '按键：' + event.key; },
        onDelete: (event: UPKeyboardDeleteEvent): void => { this.value = event.value; this.message = '删除'; },
        onConfirm: (event: UPKeyboardConfirmEvent): void => { this.message = '确认：' + event.value; } }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
