import { UPNavbarMini, UPNavbarMiniProps, UPNavigationAdapter } from '@lingyun/ultra-ui-hos';

export interface NavbarMiniDemoOptions { onBack?: () => void; onRelaunch?: (url: string) => void; }
export class NavbarMiniDemoProps {
  onBack?: () => void; onRelaunch?: (url: string) => void;
  constructor(options?: NavbarMiniDemoOptions) { if (options !== undefined) { this.onBack = options.onBack; this.onRelaunch = options.onRelaunch; } }
}

@Component
export struct NavbarMiniDemo {
  @Prop props: NavbarMiniDemoProps = new NavbarMiniDemoProps();
  @State private message: string = '默认返回与首页按钮均由适配器承接';
  private adapter(): UPNavigationAdapter { return { navigateBack: (): void => { this.message = 'mini 返回适配器'; this.props.onBack?.(); }, relaunch: (url: string): void => { this.message = 'mini 首页：' + url; this.props.onRelaunch?.(url); } }; }
  build() {
    Column({ space: 16 }) {
      UPNavbarMini({ props: new UPNavbarMiniProps({ homeUrl: 'home', navigationAdapter: this.adapter(), onLeftClick: (): void => { this.message = '先收到 mini 左侧回调'; }, onHomeClick: (): void => { this.message = '收到首页回调'; } }) })
      Text(this.message).fontSize(13).fontColor('#606266').width('100%')
      Text('safeAreaInsetTop=false').fontSize(12).fontColor('#909399')
      UPNavbarMini({ props: new UPNavbarMiniProps({ safeAreaInsetTop: false, bgColor: '#2979ff', autoBack: false, homeUrl: '' }) })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
