import { UPButton, UPButtonProps, UPLoadingPage, UPLoadingPageProps } from '@lingyun/ultra-ui-hos';

@Component
export struct LoadingPageDemo {
  @State private loading: boolean = false;

  build() {
    Column({ space: 16 }) {
      Text('加载页')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPButton({ props: new UPButtonProps({
        text: this.loading ? '隐藏加载页' : '显示加载页',
        type: 'primary',
        onClick: (): void => { this.loading = !this.loading; }
      }) })
      Stack({ alignContent: Alignment.Center }) {
        Text('此区域由页面持有 loading 状态')
          .fontSize(14)
          .fontColor('#909399')
        UPLoadingPage({ props: new UPLoadingPageProps({
          loading: this.loading,
          loadingText: '正在加载示例内容',
          loadingMode: 'semicircle',
          bgColor: '#ffffff'
        }) })
      }
      .width('100%')
      .height(180)
      .border({ width: 1, color: '#ebeef5', radius: 8 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
