import { UPBox, UPBoxClickEvent, UPBoxProps } from '@lingyun/ultra-ui-hos';

@Component
export struct BoxDemo {
  @State private message: string = '点击面板查看标题回传';

  @Builder
  private body() {
    Column({ space: 8 }) {
      Text('面板主体通过 contentBuilder 注入。').fontSize(14).fontColor('#606266')
      Text('背景、圆角、边框和高度都由 Props 控制。').fontSize(12).fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column({ space: 14 }) {
      Text('信息面板').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPBox({
        props: new UPBoxProps({
          title: 'HarmonyOS NEXT',
          subTitle: '原生 ArkUI 内容卡片',
          height: 148,
          bgColor: '#ffffff',
          border: true,
          onClick: (event: UPBoxClickEvent): void => {
            this.message = '点击：' + event.title;
          }
        })
      }) {
        this.body()
      }
      UPBox({
        props: new UPBoxProps({ title: '轻量面板', height: 92, bgColor: '#fff7e6', borderRadius: 8 })
      }) {
        Text('无网络、无业务路由的稳定占位内容').fontSize(13).fontColor('#d48806')
      }
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
