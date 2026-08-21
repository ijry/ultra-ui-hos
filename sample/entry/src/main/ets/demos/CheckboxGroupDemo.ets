import { UPCheckboxGroup, UPCheckboxGroupChangeEvent, UPCheckboxGroupProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CheckboxGroupDemo {
  @State private values: Array<string> = ['read'];
  @State private message: string = '请选择权限';
  private change(event: UPCheckboxGroupChangeEvent): void { this.values = event.value.map((item): string => String(item)); this.message = '已选：' + this.values.join('、'); }
  build() {
    Column({ space: 16 }) {
      Text('复选框组').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPCheckboxGroup({ props: new UPCheckboxGroupProps({ modelValue: this.values, placement: 'column', options: [
        { name: 'read', label: '读取数据' }, { name: 'write', label: '编辑数据' }, { name: 'share', label: '分享数据', disabled: true }
      ], onChange: (event: UPCheckboxGroupChangeEvent): void => { this.change(event); } }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
