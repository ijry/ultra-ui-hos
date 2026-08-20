import { UPActionSheet, UPActionSheetAction, UPActionSheetProps, UPActionSheetSelectEvent, UPButton, UPButtonProps } from '@lingyun/ultra-ui-hos';

@Component
export struct ActionSheetDemo {
  @State private show: boolean = false;
  @State private message: string = '请选择一个操作';
  private actions: Array<UPActionSheetAction> = [
    { name: '保存到本地', subname: '仅触发本地回调' },
    { name: '处理中', loading: true },
    { name: '不可用操作', disabled: true },
  ];
  build() {
    Stack() {
      Column({ space: 14 }) {
        Text('操作面板').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
        UPButton({ props: new UPButtonProps({ text: '打开操作面板', type: 'primary', onClick: (): void => { this.show = true; } }) })
        Text(this.message).fontSize(13).fontColor('#909399').width('100%')
      }.width('100%').alignItems(HorizontalAlign.Start)
      UPActionSheet({ props: new UPActionSheetProps({
        show: this.show, title: '本地操作', description: '禁用项和加载项不会触发选择', actions: this.actions, round: 12,
        onShowChange: (show: boolean): void => { this.show = show; },
        onSelect: (event: UPActionSheetSelectEvent): void => { this.message = '已选择第 ' + String(event.index + 1) + ' 项'; },
        onCancel: (): void => { this.message = '已取消'; }
      }) })
    }.width('100%').height(420)
  }
}
