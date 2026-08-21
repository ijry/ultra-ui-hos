import { UPDivider, UPDividerClickEvent, UPDividerProps } from '@lingyun/ultra-ui-hos';

@Component
export struct DividerDemo {
  @State private message: string = '点击分割线查看事件';

  private select(event: UPDividerClickEvent): void {
    this.message = '点击：' + event.text;
  }

  build() {
    Column({ space: 18 }) {
      UPDivider({ props: new UPDividerProps() })
      UPDivider({ props: new UPDividerProps({
        text: '居中文本',
        onClick: (event: UPDividerClickEvent): void => {
          this.select(event);
        }
      }) })
      UPDivider({ props: new UPDividerProps({ text: '靠左文本', textPosition: 'left', lineColor: 'primary' }) })
      UPDivider({ props: new UPDividerProps({ dot: true, textColor: 'warning', dashed: true }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
  }
}
