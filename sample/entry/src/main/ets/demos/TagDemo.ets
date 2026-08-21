import { UPTag, UPTagProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TagDemo {
  @State private closeableVisible: boolean = true;
  @State private message: string = '关闭标签会回传 name 原始值';

  private close(): void {
    this.closeableVisible = false;
    this.message = '标签 name=demo-tag 已关闭';
  }

  build() {
    Column({ space: 18 }) {
      Text('类型与朴素样式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 10 }) {
        UPTag({ props: new UPTagProps({ text: '主要', type: 'primary' }) })
        UPTag({ props: new UPTagProps({ text: '成功', type: 'success', plain: true, plainFill: true }) })
        UPTag({ props: new UPTagProps({ text: '警告', type: 'warning', plain: true }) })
      }
      Text('可关闭标签')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTag({ props: new UPTagProps({
        text: '点击右侧关闭',
        type: 'error',
        closable: true,
        show: this.closeableVisible,
        name: 'demo-tag',
        onClose: (): void => {
          this.close();
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
