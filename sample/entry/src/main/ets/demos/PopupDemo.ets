import { UPButton, UPButtonProps, UPPopup, UPPopupCloseEvent, UPPopupProps } from '@lingyun/ultra-ui-hos';

@Component
export struct PopupDemo {
  @State private showPopup: boolean = false;
  @State private mode: string = 'bottom';
  @State private message: string = '弹出层受控显示';

  private open(mode: string): void {
    this.mode = mode;
    this.showPopup = true;
    this.message = '打开 ' + mode + ' 弹出层';
  }

  build() {
    Stack() {
      Column({ space: 12 }) {
        Text('不同方向')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#303133')
          .width('100%')
        UPButton({ props: new UPButtonProps({
          text: '底部弹出',
          type: 'primary',
          onClick: (): void => {
            this.open('bottom');
          }
        }) })
        UPButton({ props: new UPButtonProps({
          text: '居中弹出',
          plain: true,
          type: 'primary',
          onClick: (): void => {
            this.open('center');
          }
        }) })
        Text(this.message)
          .fontSize(13)
          .fontColor('#909399')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      UPPopup({ props: new UPPopupProps({
        show: this.showPopup,
        mode: this.mode,
        round: true,
        closeable: true,
        safeAreaInsetBottom: true,
        onClose: (event: UPPopupCloseEvent): void => {
          this.message = '关闭原因：' + event.reason;
        },
        onShowChange: (show: boolean): void => {
          this.showPopup = show;
        }
      }) })
    }
    .width('100%')
    .height(420)
  }
}
