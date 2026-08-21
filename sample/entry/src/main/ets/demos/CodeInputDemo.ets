import { UPCodeInput, UPCodeInputChangeEvent, UPCodeInputProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CodeInputDemo {
  @State private value: string = '';
  @State private message: string = '请输入四位验证码';

  private changed(event: UPCodeInputChangeEvent): void {
    this.value = event.value;
    this.message = '当前长度：' + String(event.value.length);
  }

  build() {
    Column({ space: 18 }) {
      Text('验证码输入')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCodeInput({ props: new UPCodeInputProps({
        modelValue: this.value,
        maxlength: 4,
        mode: 'box',
        color: 'primary',
        onInput: (event: UPCodeInputChangeEvent): void => { this.changed(event); },
        onChange: (event: UPCodeInputChangeEvent): void => { this.message = '变更：' + event.value; },
        onFinish: (event: UPCodeInputChangeEvent): void => { this.message = '输入完成：' + event.value; }
      }) })
      Text('下方示例为掩码、线框与禁用键盘状态。')
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      UPCodeInput({ props: new UPCodeInputProps({
        value: '9527',
        maxlength: 4,
        mode: 'line',
        dot: true,
        bold: true,
        disabledKeyboard: true,
        space: 12
      }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
