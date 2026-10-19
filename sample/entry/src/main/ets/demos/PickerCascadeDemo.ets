import {
  UPPicker,
  UPPickerChangeEvent,
  UPPickerController,
  UPPickerConfirmEvent,
  UPPickerProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct PickerCascadeDemo {
  @State private show: boolean = false;
  @State private value: string = '请选择地区';
  private controller: UPPickerController = new UPPickerController();
  private columns: Array<Array<string>> = [
    ['浙江', '江苏'],
    ['杭州', '宁波']
  ];

  private change(event: UPPickerChangeEvent): void {
    if (event.columnIndex === 0) {
      const cities: Array<string> = event.indexs[0] === 1 ? ['南京', '苏州'] : ['杭州', '宁波'];
      this.controller.setColumnValues(1, cities);
    }
  }

  private confirm(event: UPPickerConfirmEvent): void {
    this.value = event.value.map((item): string => String(item)).join(' / ');
  }

  build() {
    Column({ space: 16 }) {
      Text('级联选择器').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      Text(this.value).fontSize(15).fontColor('#606266').width('100%')
      Button('打开级联选择器').type(ButtonType.Capsule).onClick((): void => { this.show = true; })
      UPPicker({
        props: new UPPickerProps({
          show: this.show,
          columns: this.columns,
          controller: this.controller,
          title: '地区',
          onChange: (event: UPPickerChangeEvent): void => { this.change(event); },
          onConfirm: (event: UPPickerConfirmEvent): void => { this.confirm(event); },
          onCancel: (): void => { this.show = false; },
          onShowChange: (show: boolean): void => { this.show = show; }
        })
      })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
