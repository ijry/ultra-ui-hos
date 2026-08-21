import { UPTextarea, UPTextareaChangeEvent, UPTextareaConfirmEvent, UPTextareaProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TextareaDemo {
  @State private value: string = '鸿蒙 NEXT 原生组件';
  @State private message: string = '多行输入支持计数';

  private change(event: UPTextareaChangeEvent): void {
    this.value = event.value;
    this.message = '长度：' + String(event.value.length);
  }

  build() {
    Column({ space: 14 }) {
      Text('文本域')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTextarea({ props: new UPTextareaProps({
        modelValue: this.value,
        placeholder: '请输入说明',
        count: true,
        maxlength: 40,
        height: 96,
        onInput: (event: UPTextareaChangeEvent): void => { this.change(event); },
        onConfirm: (event: UPTextareaConfirmEvent): void => { this.message = '提交：' + event.value; }
      }) })
      UPTextarea({ props: new UPTextareaProps({ value: '禁用态文本域', disabled: true, height: 70 }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
