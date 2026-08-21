import {
  UPButton,
  UPButtonProps,
  UPModal,
  UPModalAction,
  UPModalCloseEvent,
  UPModalProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct ModalDemo {
  @State private showModal: boolean = false;
  @State private message: string = '模态框使用受控 show 和显式 action';

  build() {
    Stack() {
      Column({ space: 16 }) {
        Text('确认与取消')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#303133')
          .width('100%')
        UPButton({ props: new UPButtonProps({
          text: '打开模态框',
          type: 'primary',
          onClick: (): void => {
            this.showModal = true;
          }
        }) })
        Text(this.message)
          .fontSize(13)
          .fontColor('#909399')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      UPModal({ props: new UPModalProps({
        show: this.showModal,
        title: '删除提示',
        content: '是否确认执行此操作？',
        onAction: (event: UPModalAction): void => {
          this.message = '操作：' + event.action;
        },
        onClose: (event: UPModalCloseEvent): void => {
          this.message = '关闭原因：' + event.reason;
        },
        onShowChange: (show: boolean): void => {
          this.showModal = show;
        }
      }) })
    }
    .width('100%')
    .height(360)
  }
}
