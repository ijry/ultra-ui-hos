import { UPText, UPTextCallEvent, UPTextClickEvent, UPTextOpenEvent, UPTextProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TextDemo {
  @State private message: string = '点击文本查看本地事件回传';

  private clicked(event: UPTextClickEvent): void {
    this.message = '点击：' + event.text + '（' + event.mode + '）';
  }

  build() {
    Column({ space: 16 }) {
      Text('文本模式与格式化')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPText({ props: new UPTextProps({
        text: '128.00',
        mode: 'price',
        prefixIcon: 'rmb',
        bold: true,
        color: 'primary',
        onClick: (event: UPTextClickEvent): void => { this.clicked(event); }
      }) })
      UPText({ props: new UPTextProps({
        text: '产品说明',
        mode: 'link',
        href: '产品说明',
        decoration: 'underline',
        onOpen: (event: UPTextOpenEvent): void => { this.message = '链接回传：' + event.href; }
      }) })
      UPText({ props: new UPTextProps({
        text: '13800138000',
        mode: 'phone',
        call: true,
        onCall: (event: UPTextCallEvent): void => { this.message = '号码回传：' + event.phone; }
      }) })
      UPText({ props: new UPTextProps({
        text: '这是一段会按单行安全截断的长文本，用于展示 block、行数与对齐行为。',
        block: true,
        lines: 1,
        color: '#606266'
      }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
