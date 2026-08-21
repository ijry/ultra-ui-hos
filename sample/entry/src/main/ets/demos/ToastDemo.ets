import { UPButton, UPButtonProps, UPToastCompleteEvent, UPToastController } from '@lingyun/ultra-ui-hos';

@Component
export struct ToastDemo {
  @State private message: string = '根页面仅挂载一个 UPToastHost';

  private show(position: string): void {
    UPToastController.shared().show({
      message: '这是 ' + position + ' 提示消息',
      position,
      duration: 1800,
      type: 'success',
      onComplete: (event: UPToastCompleteEvent): void => {
        this.message = 'Toast 完成：' + event.reason;
      }
    });
  }

  build() {
    Column({ space: 14 }) {
      Text('位置与替换')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPButton({ props: new UPButtonProps({
        text: '居中提示',
        type: 'primary',
        onClick: (): void => {
          this.show('center');
        }
      }) })
      UPButton({ props: new UPButtonProps({
        text: '顶部提示',
        plain: true,
        type: 'primary',
        onClick: (): void => {
          this.show('top');
        }
      }) })
      UPButton({ props: new UPButtonProps({
        text: '带遮罩加载',
        type: 'warning',
        onClick: (): void => {
          UPToastController.shared().show({ message: '加载中', loading: true, mask: true, duration: -1 });
        }
      }) })
      UPButton({ props: new UPButtonProps({
        text: '关闭当前提示',
        plain: true,
        type: 'info',
        onClick: (): void => {
          UPToastController.shared().close();
        }
      }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
