import { UPSwiper, UPSwiperChangeEvent, UPSwiperClickEvent, UPSwiperItem, UPSwiperProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SwiperDemo {
  @State private current: number = 0;
  @State private message: string = '点击或滑动轮播';
  private list: Array<UPSwiperItem> = [
    { title: '第一屏', text: '本地文本轮播', bgColor: '#2979ff' },
    { title: '第二屏', text: '原生 Swiper 循环', bgColor: '#19be6b' },
    { title: '第三屏', text: '切换事件回传', bgColor: '#ff9900' }
  ];

  private changed(event: UPSwiperChangeEvent): void {
    this.current = event.index;
    this.message = '切换到：' + String(event.item.title) + ' / ' + event.source;
  }

  private clicked(event: UPSwiperClickEvent): void {
    this.message = '点击：' + String(event.item.title) + ' / url=' + String(event.url ?? '');
  }

  build() {
    Column({ space: 14 }) {
      Text('本地轮播').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSwiper({
        props: new UPSwiperProps({
          list: this.list,
          current: this.current,
          autoplay: false,
          circular: true,
          indicator: true,
          height: 180,
          onChange: (event: UPSwiperChangeEvent): void => {
            this.changed(event);
          },
          onClick: (event: UPSwiperClickEvent): void => {
            this.clicked(event);
          }
        })
      })
      Text('当前索引：' + String(this.current)).fontSize(13).fontColor('#606266')
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
