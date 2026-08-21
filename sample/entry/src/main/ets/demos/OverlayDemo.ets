import { UPButton, UPButtonProps, UPOverlay, UPOverlayClickEvent, UPOverlayProps } from '@lingyun/ultra-ui-hos';

@Component
export struct OverlayDemo {
  @State private showOverlay: boolean = false;
  @State private message: string = '遮罩层使用受控 show';

  build() {
    Stack() {
      Column({ space: 16 }) {
        Text('点击按钮显示遮罩层')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#303133')
          .width('100%')
        UPButton({ props: new UPButtonProps({
          text: '显示遮罩层',
          type: 'primary',
          onClick: (): void => {
            this.showOverlay = true;
          }
        }) })
        Text(this.message)
          .fontSize(13)
          .fontColor('#909399')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      UPOverlay({ props: new UPOverlayProps({
        show: this.showOverlay,
        opacity: 0.55,
        onClickOverlay: (event: UPOverlayClickEvent): void => {
          this.message = '已点击 ' + event.source;
        },
        onShowChange: (show: boolean): void => {
          this.showOverlay = show;
        }
      }) })
    }
    .width('100%')
    .height(360)
  }
}
