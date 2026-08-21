import { UPForm, UPFormItem, UPFormItemProps, UPFormProps, UPInput, UPInputChangeEvent, UPInputProps, UPCheckboxGroup, UPCheckboxGroupChangeEvent, UPCheckboxGroupProps, UPRadioGroup, UPRadioGroupChangeEvent, UPRadioGroupProps } from '@lingyun/ultra-ui-hos';

@Component
export struct FormDemo {
  @State private name: string = '';
  @State private sex: string = 'female';
  @State private interests: Array<string> = ['ui'];
  @State private message: string = '填写后点击页面进行本地校验回调';
  private validateMessage(): void { this.message = this.name.length > 0 ? '表单数据已就绪' : '请先填写姓名'; }
  build() {
    Column({ space: 12 }) {
      Text('基础表单').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPForm({ props: new UPFormProps({ model: { name: this.name, sex: this.sex, interests: this.interests }, onValidate: (): void => { this.validateMessage(); } }) }) {
        UPFormItem({ props: new UPFormItemProps({ label: '姓名', required: true, error: this.name.length === 0 ? '请输入姓名' : '' }) }) {
          UPInput({ props: new UPInputProps({ modelValue: this.name, placeholder: '请输入姓名', onInput: (event: UPInputChangeEvent): void => { this.name = event.value; } }) })
        }
        UPFormItem({ props: new UPFormItemProps({ label: '性别' }) }) {
          UPRadioGroup({ props: new UPRadioGroupProps({ modelValue: this.sex, options: [{ name: 'male', label: '男' }, { name: 'female', label: '女' }], onChange: (event: UPRadioGroupChangeEvent): void => { this.sex = String(event.value); } }) })
        }
        UPFormItem({ props: new UPFormItemProps({ label: '兴趣' }) }) {
          UPCheckboxGroup({ props: new UPCheckboxGroupProps({ modelValue: this.interests, placement: 'column', options: [{ name: 'ui', label: '界面设计' }, { name: 'code', label: '原生开发' }], onChange: (event: UPCheckboxGroupChangeEvent): void => { this.interests = event.value.map((item): string => String(item)); } }) })
        }
      }
      Text(this.message).fontSize(13).fontColor('#909399').width('100%').onClick((): void => { this.validateMessage(); })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
