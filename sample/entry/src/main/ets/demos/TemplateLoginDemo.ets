import {
  UPButton,
  UPButtonProps,
  UPIcon,
  UPIconProps,
  UPInput,
  UPInputChangeEvent,
  UPInputProps,
  upIsMobile
} from '@lingyun/ultra-ui-hos';

/**
 * 复刻上游 `pages/template/login/index.vue` 的登录页场景。
 * ArkTS port of the upstream login template page; a scenario built from library
 * components, not a component demo. Navigation to the code page is host-owned.
 */
@Component
export struct TemplateLoginDemo {
  @State private tel: string = '';
  @State private hint: string = '未注册的手机号验证后自动创建账号';

  private valid(): boolean {
    return upIsMobile(this.tel);
  }

  private submit(): void {
    if (this.valid()) {
      this.hint = '验证码已发送至 ' + this.tel + '（示例不含真实网络请求）';
    } else {
      this.hint = '请输入正确的手机号';
    }
  }

  @Builder
  private socialItem(icon: string, color: string, label: string) {
    Column({ space: 6 }) {
      UPIcon({ props: new UPIconProps({ name: icon, size: 40, color }) })
      Text(label).fontSize(14).fontColor('#606266')
    }
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      Column({ space: 10 }) {
        Text('欢迎登录')
          .fontSize(30)
          .fontWeight(FontWeight.Medium)
          .fontColor('#303133')
          .width('100%')
          .margin({ bottom: 30 })
        UPInput({ props: new UPInputProps({
          modelValue: this.tel,
          type: 'number',
          placeholder: '请输入手机号',
          border: 'bottom',
          onInput: (event: UPInputChangeEvent): void => {
            this.tel = event.value;
          }
        }) })
        Text(this.hint)
          .fontSize(12)
          .fontColor('#909399')
          .width('100%')
        UPButton({ props: new UPButtonProps({
          text: '获取短信验证码',
          type: this.valid() ? 'warning' : 'info',
          disabled: !this.valid(),
          onClick: (): void => {
            this.submit();
          }
        }) })
        Row() {
          Text('密码登录').fontSize(14).fontColor('#909399')
          Blank()
          Text('遇到问题').fontSize(14).fontColor('#909399')
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .width('80%')
      .margin({ top: 40 })
      Blank()
      Row({ space: 80 }) {
        this.socialItem('weixin-fill', 'rgb(83,194,64)', '微信')
        this.socialItem('qq-fill', 'rgb(17,183,233)', 'QQ')
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      Text('登录代表同意用户协议、隐私政策，并授权使用您的账号信息以便统一管理')
        .fontSize(11)
        .fontColor('#909399')
        .textAlign(TextAlign.Center)
        .padding({ left: 30, right: 30, top: 16, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
