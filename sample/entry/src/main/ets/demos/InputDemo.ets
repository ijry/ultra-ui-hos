import { UPInput, UPInputChangeEvent, UPInputConfirmEvent, UPInputProps } from '@lingyun/ultra-ui-hos';

@Component
export struct InputDemo {
  @State private value: string = 'UltraUI';
  @State private message: string = '输入会同步回传 onInput/onChange';

  private change(event: UPInputChangeEvent): void {
    this.value = event.value;
    this.message = '当前值：' + event.value;
  }

  build() {
    Column({ space: 14 }) {
      Text('单行输入')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPInput({ props: new UPInputProps({
        modelValue: this.value,
        placeholder: '请输入名称',
        clearable: true,
        showWordLimit: true,
        maxlength: 16,
        prefixIcon: 'edit-pen',
        onInput: (event: UPInputChangeEvent): void => { this.change(event); },
        onConfirm: (event: UPInputConfirmEvent): void => { this.message = '确认：' + event.value; },
        onClear: (): void => { this.message = '已清空'; }
      }) })
      UPInput({ props: new UPInputProps({ value: '只读内容', readonly: true, suffixIcon: 'lock' }) })
      UPInput({ props: new UPInputProps({ value: '禁用输入', disabled: true }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
