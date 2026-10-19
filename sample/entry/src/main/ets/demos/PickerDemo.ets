import {
  UPPicker,
  UPPickerChangeEvent,
  UPPickerConfirmEvent,
  UPPickerProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct PickerDemo {
  @State private show: boolean = false;
  @State private value: string = '请选择城市';

  private columns: Array<Array<string>> = [
    ['北京', '上海', '广州', '深圳', '杭州']
  ];

  private confirm(event: UPPickerConfirmEvent): void {
    this.value = event.value.map((item): string => String(item)).join(' / ');
  }

  build() {
    Column({ space: 16 }) {
      Text('选择器').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      Text(this.value).fontSize(15).fontColor('#606266').width('100%')
      Button('打开选择器').type(ButtonType.Capsule).onClick((): void => { this.show = true; })
      UPPicker({
        props: new UPPickerProps({
          show: this.show,
          columns: this.columns,
          title: '城市',
          onChange: (_event: UPPickerChangeEvent): void => {},
          onConfirm: (event: UPPickerConfirmEvent): void => { this.confirm(event); },
          onCancel: (): void => { this.show = false; },
          onShowChange: (show: boolean): void => { this.show = show; }
        })
      })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
