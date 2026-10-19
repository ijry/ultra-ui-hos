import { UPSection, UPSectionClickEvent, UPSectionProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SectionDemo {
  @State private message: string = '点击右侧辅助文案';

  build() {
    Column({ space: 14 }) {
      Text('区块标题').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSection({
        props: new UPSectionProps({
          title: '热门推荐',
          subTitle: '查看全部',
          onClick: (event: UPSectionClickEvent): void => {
            this.message = event.title + '：' + event.subTitle;
          }
        })
      })
      UPSection({
        props: new UPSectionProps({
          title: '无标识线区块',
          right: false,
          showLine: false,
          customStyle: { backgroundColor: '#f5f7fa', padding: 12 }
        })
      })
      UPSection({
        props: new UPSectionProps({ title: '自定义箭头', subTitle: '下一步', arrow: true, lineColor: '#19be6b' })
      })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
