import {
  UPButton,
  UPButtonProps,
  UPIcon,
  UPIconProps,
  UPKeyboard,
  UPKeyboardDeleteEvent,
  UPKeyboardKeyEvent,
  UPKeyboardProps,
  UPMessageInput,
  UPMessageInputProps
} from '@lingyun/ultra-ui-hos';

/**
 * 复刻上游 `pages/template/keyboardPay/index.vue` 的红包支付场景。
 * ArkTS port of the upstream keyboard-pay template: number keyboard drives a
 * six-box password input; the "pay" step is a local timer, no real network call.
 */
@Component
export struct TemplatePayDemo {
  @State private show: boolean = false;
  @State private password: string = '';
  @State private status: string = '点击按钮唤起支付键盘';
  private timerId: number = -1;

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
  }

  private open(): void {
    this.password = '';
    this.status = '请输入 6 位支付密码';
    this.show = true;
  }

  private appendKey(value: string): void {
    if (this.password.length < 6) {
      this.password = this.password + value;
    }
    if (this.password.length >= 6) {
      this.pay();
    }
  }

  private backspace(): void {
    if (this.password.length > 0) {
      this.password = this.password.substring(0, this.password.length - 1);
    }
  }

  private pay(): void {
    this.status = '支付中…';
    this.timerId = setTimeout((): void => {
      this.show = false;
      this.status = '支付成功（示例）';
      this.timerId = -1;
    }, 1200);
  }

  @Builder
  private payPanel() {
    Column({ space: 12 }) {
      Row() {
        Text('1.00').fontSize(40).fontColor('#ff9900').fontWeight(FontWeight.Medium)
        Text('元').fontSize(16).fontColor('#ff9900').margin({ left: 8, top: 12 })
        Blank()
        UPIcon({ props: new UPIconProps({ name: 'close', size: 22, color: '#333333',
          onClick: (): void => { this.show = false; } }) })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })
      UPMessageInput({ props: new UPMessageInputProps({
        mode: 'box',
        maxlength: 6,
        dotFill: true,
        modelValue: this.password
      }) })
      Text('支付键盘').fontSize(12).fontColor('#909399').textAlign(TextAlign.Center).width('100%')
    }
    .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      UPButton({ props: new UPButtonProps({
        text: '发送 1.00 元红包',
        type: 'success',
        icon: 'red-packet',
        onClick: (): void => {
          this.open();
        }
      }) })
      Text(this.status)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      Text('已输入 ' + String(this.password.length) + ' / 6 位')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      if (this.show) {
        Column() {
          UPKeyboard({ props: new UPKeyboardProps({
            mode: 'number',
            showCancel: false,
            contentBuilder: (): void => {
              this.payPanel();
            },
            onChange: (event: UPKeyboardKeyEvent): void => {
              this.appendKey(event.value);
            },
            onBackspace: (event: UPKeyboardDeleteEvent): void => {
              this.backspace();
            }
          }) })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
  }
}
