import { UPCheckbox, UPCheckboxChangeEvent, UPCheckboxProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CheckboxDemo {
  @State private checked: boolean = false;
  @State private message: string = '点击复选框';
  private change(event: UPCheckboxChangeEvent): void { this.checked = event.checked; this.message = 'checked=' + String(event.checked); }
  build() {
    Column({ space: 16 }) {
      Text('独立复选框').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPCheckbox({ props: new UPCheckboxProps({ name: 'alone', label: '同意服务条款', checked: this.checked, onChange: (event: UPCheckboxChangeEvent): void => { this.change(event); } }) })
      UPCheckbox({ props: new UPCheckboxProps({ label: '禁用项', checked: true, disabled: true }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
