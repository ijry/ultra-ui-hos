import {
  UPAgreement,
  UPAgreementConfirmEvent,
  UPAgreementLinkEvent,
  UPAgreementProps,
  UPButton,
  UPButtonProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct AgreementDemo {
  @State private showAgreement: boolean = false;
  @State private agreed: boolean = false;
  @State private message: string = '协议链接只回传给宿主，不自动导航';

  build() {
    Stack() {
      Column({ space: 14 }) {
        Text('协议弹窗')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#303133')
          .width('100%')
        UPButton({
          props: new UPButtonProps({
            text: this.agreed ? '再次查看协议' : '查看并同意',
            type: 'primary',
            onClick: (): void => {
              this.showAgreement = true;
            }
          })
        })
        Text(this.message)
          .fontSize(13)
          .fontColor('#909399')
          .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      UPAgreement({
        props: new UPAgreementProps({
          show: this.showAgreement,
          title: '用户协议与隐私政策',
          content: '首次使用前，请阅读并同意以下协议。',
          urlProtocol: '/pages/user-agreement',
          urlPrivacy: '/pages/privacy-policy',
          onConfirm: (event: UPAgreementConfirmEvent): void => {
            this.agreed = event.accepted;
            this.message = '已同意用户协议和隐私政策';
          },
          onCancel: (): void => {
            this.message = '已取消协议确认';
          },
          onProtocolClick: (event: UPAgreementLinkEvent): void => {
            this.message = '用户协议：' + event.url;
          },
          onPrivacyClick: (event: UPAgreementLinkEvent): void => {
            this.message = '隐私政策：' + event.url;
          },
          onShowChange: (show: boolean): void => {
            this.showAgreement = show;
          }
        })
      })
    }
    .width('100%')
    .height(360)
  }
}
