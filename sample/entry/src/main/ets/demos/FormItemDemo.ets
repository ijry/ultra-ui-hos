import { UPFormItem, UPFormItemProps, UPInput, UPInputChangeEvent, UPInputProps } from '@lingyun/ultra-ui-hos';

@Component
export struct FormItemDemo {
  @State private value: string = '';
  build() {
    Column({ space: 12 }) {
      Text('表单项').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPFormItem({ props: new UPFormItemProps({ label: '姓名', required: true, error: this.value.length === 0 ? '请输入姓名' : '' }) }) {
        UPInput({ props: new UPInputProps({ modelValue: this.value, placeholder: '请输入姓名', onInput: (event: UPInputChangeEvent): void => { this.value = event.value; } }) })
      }
      Text('error、required、labelWidth 均可由调用方控制').fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
