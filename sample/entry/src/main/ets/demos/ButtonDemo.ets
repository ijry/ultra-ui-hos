import { UPButton, UPButtonProps } from '@lingyun/ultra-ui-hos';

@Component
export struct ButtonDemo {
  @State private loading: boolean = false;
  @State private message: string = '点击任意按钮查看回调';

  private click(label: string): void {
    this.message = label + ' 已点击';
  }

  build() {
    Column({ space: 14 }) {
      Text('基础类型')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPButton({ props: new UPButtonProps({
        text: '主要按钮',
        type: 'primary',
        onClick: (): void => {
          this.click('主要按钮');
        }
      }) })
      UPButton({ props: new UPButtonProps({
        text: '成功按钮',
        type: 'success',
        onClick: (): void => {
          this.click('成功按钮');
        }
      }) })
      UPButton({ props: new UPButtonProps({
        text: '朴素按钮',
        type: 'warning',
        plain: true,
        onClick: (): void => {
          this.click('朴素按钮');
        }
      }) })
      Text('加载与禁用')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
        .margin({ top: 8 })
      UPButton({ props: new UPButtonProps({
        text: '切换加载状态',
        loading: this.loading,
        loadingText: '处理中',
        type: 'primary',
        onClick: (): void => {
          this.loading = !this.loading;
        }
      }) })
      UPButton({ props: new UPButtonProps({ text: '禁用按钮', disabled: true, type: 'info' }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
  }
}
