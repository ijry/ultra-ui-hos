import { UPButton, UPButtonProps, UPNavbar, UPNavbarProps, UPNavigationAdapter } from '@lingyun/ultra-ui-hos';

export interface NavbarDemoOptions { onBack?: () => void; onRelaunch?: (url: string) => void; }
export class NavbarDemoProps {
  onBack?: () => void;
  onRelaunch?: (url: string) => void;
  constructor(options?: NavbarDemoOptions) {
    if (options === undefined) return;
    this.onBack = options.onBack; this.onRelaunch = options.onRelaunch;
  }
}

@Component
export struct NavbarDemo {
  @Prop props: NavbarDemoProps = new NavbarDemoProps();
  @State private message: string = '点击左右区域观察事件顺序';

  private adapter(): UPNavigationAdapter {
    return { navigateBack: (): void => { this.message = '回调后执行返回适配器'; this.props.onBack?.(); }, relaunch: (url: string): void => { this.message = '重启首页：' + url; this.props.onRelaunch?.(url); } };
  }

  build() {
    Column({ space: 14 }) {
      UPNavbar({ props: new UPNavbarProps({ title: '订单详情', leftText: '返回', rightText: '更多', border: true, autoBack: true, navigationAdapter: this.adapter(), onLeftClick: (): void => { this.message = '先收到左侧点击回调'; }, onRightClick: (): void => { this.message = '右侧点击'; } }) })
      UPNavbar({ props: new UPNavbarProps({ title: '占位导航', safeAreaInsetTop: false, placeholder: true, bgColor: '#ecf5ff' }) })
      Text(this.message).fontSize(13).fontColor('#606266').width('100%')
      UPButton({ props: new UPButtonProps({ text: '回到目录', type: 'primary', onClick: (): void => { this.props.onBack?.(); } }) })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
