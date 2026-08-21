import { UPRadioGroup, UPRadioGroupChangeEvent, UPRadioGroupProps } from '@lingyun/ultra-ui-hos';

@Component
export struct RadioGroupDemo {
  @State private value: string = 'apple';
  @State private message: string = '请选择水果';
  private change(event: UPRadioGroupChangeEvent): void { this.value = String(event.value); this.message = '当前：' + this.value; }
  build() {
    Column({ space: 16 }) {
      Text('单选组').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPRadioGroup({ props: new UPRadioGroupProps({ modelValue: this.value, placement: 'column', options: [
        { name: 'apple', label: '苹果' }, { name: 'banana', label: '香蕉' }, { name: 'orange', label: '橙子', disabled: true }
      ], onChange: (event: UPRadioGroupChangeEvent): void => { this.change(event); } }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%').margin({ top: 4 })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
