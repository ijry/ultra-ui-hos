import { UPBackTop, UPBackTopProps, UPButton, UPButtonProps } from '@lingyun/ultra-ui-hos';

@Component
export struct BackTopDemo {
  @State private scrollTop: number = 0;
  @State private message: string = '页面持有 scrollTop，并负责真正滚动';
  build() {
    Stack() {
      Column({ space: 14 }) {
        Text('返回顶部').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
        Text('当前 scrollTop：' + String(this.scrollTop)).fontSize(14).fontColor('#606266').width('100%')
        UPButton({ props: new UPButtonProps({ text: '增加 200', type: 'primary', onClick: (): void => { this.scrollTop += 200; } }) })
        UPButton({ props: new UPButtonProps({ text: '重置为 0', plain: true, type: 'primary', onClick: (): void => { this.scrollTop = 0; } }) })
        Text(this.message).fontSize(13).fontColor('#909399').width('100%')
      }.width('100%').alignItems(HorizontalAlign.Start)
      UPBackTop({ props: new UPBackTopProps({ scrollTop: this.scrollTop, top: 400, bottom: 16, right: 4, onBackToTop: (): void => { this.scrollTop = 0; this.message = '调用方已处理返回顶部请求'; } }) })
    }.width('100%').height(360)
  }
}
