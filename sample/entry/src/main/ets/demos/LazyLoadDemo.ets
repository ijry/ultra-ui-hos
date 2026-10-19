import {
  UPLazyLoad,
  UPLazyLoadEvent,
  UPLazyLoadProps,
  UP_LAZY_LOAD_STATUS_INITIAL,
  UP_LAZY_LOAD_STATUS_LOADED,
  upLazyLoadEffectSupported,
  upLazyLoadNextStatus,
  upLazyLoadThreshold
} from '@lingyun/ultra-ui-hos';

@Component
export struct LazyLoadDemo {
  @State private loadText: string = '向下滚动，图片进入可视区后回传 onLoad';
  @State private clickText: string = '点击图片回传 index';
  @State private errorText: string = '远端地址只渲染占位，不发起网络请求';
  private localImage: string = '$rawfile:app_icon.png';
  private remoteImage: string = 'remote://cdn/banner.png';
  private effectNames: Array<string> = ['linear', 'ease', 'ease-in', 'ease-out', 'ease-in-out', 'spring'];
  private thresholdValues: Array<number> = [100, 0, -200];

  private handleLoad(event: UPLazyLoadEvent): void {
    this.loadText = '第 ' + String(event.index) + ' 张已加载，loadStatus=' + UP_LAZY_LOAD_STATUS_LOADED;
  }

  private handleClick(event: UPLazyLoadEvent): void {
    this.clickText = '点击了第 ' + String(event.index) + ' 张';
  }

  private handleError(event: UPLazyLoadEvent): void {
    this.errorText = '第 ' + String(event.index) + ' 张解码失败，已切到 errorImg';
  }

  private thresholdText(value: number): string {
    return 'threshold ' + String(value) + ' → ' + String(upLazyLoadThreshold(value)) + 'vp（仅换算，不参与预加载）';
  }

  private effectText(name: string): string {
    return 'effect ' + name + (upLazyLoadEffectSupported(name) ? '：命中白名单' : '：白名单外，回落 ease-in-out');
  }

  private statusText(): string {
    const lazyed: string = upLazyLoadNextStatus(UP_LAZY_LOAD_STATUS_INITIAL);
    const loaded: string = upLazyLoadNextStatus(lazyed);
    return '状态机：空串 → ' + lazyed + ' → ' + loaded;
  }

  build() {
    Column({ space: 16 }) {
      Text('基础懒加载')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPLazyLoad({
        props: new UPLazyLoadProps({
          index: 0,
          image: this.localImage,
          height: '160',
          onLoad: (event: UPLazyLoadEvent): void => {
            this.handleLoad(event);
          },
          onClick: (event: UPLazyLoadEvent): void => {
            this.handleClick(event);
          }
        })
      })
      Text(this.loadText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.clickText).fontSize(13).fontColor('#606266').width('100%')

      Text('圆角、时长与曲线')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPLazyLoad({
        props: new UPLazyLoadProps({
          index: 1,
          image: this.localImage,
          height: '150',
          borderRadius: 24,
          duration: 1200,
          effect: 'linear',
          imgMode: 'aspectFill',
          onLoad: (event: UPLazyLoadEvent): void => {
            this.handleLoad(event);
          }
        })
      })
      Text('borderRadius 按 rpx 换算（24rpx → 12vp），duration/effect 落到 ArkUI animation 的 duration/curve。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      UPLazyLoad({
        props: new UPLazyLoadProps({
          index: 2,
          image: this.localImage,
          height: '120',
          isEffect: false,
          imgMode: 'aspectFit'
        })
      })
      Text('isEffect=false 时跳过淡入，进入可视区即全不透明显示。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('占位与错误态')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPLazyLoad({
        props: new UPLazyLoadProps({
          index: 3,
          image: this.remoteImage,
          height: '110',
          onError: (event: UPLazyLoadEvent): void => {
            this.handleError(event);
          }
        })
      })
      UPLazyLoad({
        props: new UPLazyLoadProps({
          index: 4,
          image: '',
          errorImg: this.localImage,
          height: '110'
        })
      })
      Text(this.errorText).fontSize(13).fontColor('#606266').width('100%')
      Text('空地址直接进入错误态并渲染本地 errorImg，onError 只在真实解码失败时回传；loadingImg 走 Image 的 alt 占位。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('阈值换算与状态机')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      ForEach(this.thresholdValues, (value: number): void => {
        Text(this.thresholdText(value)).fontSize(12).fontColor('#909399').width('100%')
      }, (value: number): string => String(value))
      ForEach(this.effectNames, (name: string): void => {
        Text(this.effectText(name)).fontSize(12).fontColor('#909399').width('100%')
      }, (name: string): string => name)
      Text(this.statusText()).fontSize(12).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
