import { UPTooltip, UPTooltipButtonEvent, UPTooltipCopyEvent, UPTooltipProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TooltipDemo {
  @State private show: boolean = true;
  @State private message: string = '长按文本打开提示';
  build() {
    Column({ space: 12 }) {
      Text('文字提示').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPTooltip({ props: new UPTooltipProps({ modelValue: this.show, text: '长按我', buttons: ['收藏'],
        onShowChange: (show: boolean): void => { this.show = show; },
        onCopy: (event: UPTooltipCopyEvent): void => { this.message = '复制：' + event.text; },
        onButtonClick: (event: UPTooltipButtonEvent): void => { this.message = '按钮：' + String(event.label); } }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
