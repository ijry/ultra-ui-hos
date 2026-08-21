import { UPLoadmore, UPLoadmoreProps } from '@lingyun/ultra-ui-hos';

@Component
export struct LoadmoreDemo {
  build() {
    Column({ space: 18 }) {
      Text('加载状态')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPLoadmore({ props: new UPLoadmoreProps({ status: 'loadmore', line: true }) })
      UPLoadmore({ props: new UPLoadmoreProps({ status: 'loading', loadingText: '努力加载中', icon: true }) })
      UPLoadmore({ props: new UPLoadmoreProps({ status: 'nomore', nomoreText: '到底了', line: true, dashed: true }) })
    }
    .width('100%')
  }
}
