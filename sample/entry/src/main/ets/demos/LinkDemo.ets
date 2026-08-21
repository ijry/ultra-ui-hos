import { UPLink, UPLinkClickEvent, UPLinkProps } from '@lingyun/ultra-ui-hos';

@Component
export struct LinkDemo {
  @State private message: string = '点击链接只回传 href，不自动打开网络地址';

  private select(event: UPLinkClickEvent): void {
    this.message = 'href=' + String(event.href) + '，text=' + event.text;
  }

  build() {
    Column({ space: 18 }) {
      Text('基础链接')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPLink({ props: new UPLinkProps({
        text: '查看组件文档',
        href: '/pages/components/link',
        onClick: (event: UPLinkClickEvent): void => {
          this.select(event);
        }
      }) })
      UPLink({ props: new UPLinkProps({
        text: '无下划线链接',
        href: '/pages/no-underline',
        underLine: false,
        color: 'success',
        onTap: (event: UPLinkClickEvent): void => {
          this.select(event);
        }
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
