import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPNavigationAdapter } from './UPNavbar';

export interface UPNavbarMiniOptions {
  safeAreaInsetTop?: UPRawValue; fixed?: UPRawValue; leftIcon?: UPRawValue; bgColor?: UPRawValue; height?: UPRawValue;
  iconSize?: UPRawValue; iconColor?: UPRawValue; autoBack?: UPRawValue; homeUrl?: UPRawValue; customStyle?: UPStyleInput;
  navigationAdapter?: UPNavigationAdapter; onLeftClick?: () => void; onHomeClick?: () => void; leftBuilder?: () => void; centerBuilder?: () => void;
}
export class UPNavbarMiniProps {
  safeAreaInsetTop: UPRawValue = true; fixed: UPRawValue = true; leftIcon: UPRawValue = 'arrow-leftward'; bgColor: UPRawValue = 'rgba(0,0,0,.15)';
  height: UPRawValue = '32px'; iconSize: UPRawValue = '20px'; iconColor: UPRawValue = '#fff'; autoBack: UPRawValue = true; homeUrl: UPRawValue = '';
  customStyle: UPStyleInput = undefined; navigationAdapter?: UPNavigationAdapter; onLeftClick?: () => void; onHomeClick?: () => void;
  leftBuilder?: () => void; centerBuilder?: () => void;
  constructor(options?: UPNavbarMiniOptions) {
    if (options === undefined) return;
    this.safeAreaInsetTop = options.safeAreaInsetTop ?? this.safeAreaInsetTop; this.fixed = options.fixed ?? this.fixed;
    this.leftIcon = options.leftIcon ?? this.leftIcon; this.bgColor = options.bgColor ?? this.bgColor; this.height = options.height ?? this.height;
    this.iconSize = options.iconSize ?? this.iconSize; this.iconColor = options.iconColor ?? this.iconColor; this.autoBack = options.autoBack ?? this.autoBack;
    this.homeUrl = options.homeUrl ?? this.homeUrl; this.customStyle = options.customStyle; this.navigationAdapter = options.navigationAdapter;
    this.onLeftClick = options.onLeftClick; this.onHomeClick = options.onHomeClick; this.leftBuilder = options.leftBuilder; this.centerBuilder = options.centerBuilder;
  }
}

@Component
export struct UPNavbarMini {
  @Prop props: UPNavbarMiniProps = new UPNavbarMiniProps();
  @Builder private emptyLeft() { Row().width(0).height(0) }
  @Builder private emptyCenter() { Row().width(0).height(0) }
  @BuilderParam leftBuilder: () => void = this.emptyLeft;
  @BuilderParam centerBuilder: () => void = this.emptyCenter;

  private clickLeft(): void { this.props.onLeftClick?.(); if (upBoolean(this.props.autoBack, true)) this.props.navigationAdapter?.navigateBack?.(); }
  private clickHome(): void { this.props.onHomeClick?.(); const url: string = upString(this.props.homeUrl, ''); if (url.length > 0) this.props.navigationAdapter?.relaunch?.(url); }
  private barHeight(): number { return UPStyle.parse(this.props.customStyle).height ?? UPUnit.parse(this.props.height, 375, 32); }

  build() {
    Column() {
      Column().height(upBoolean(this.props.safeAreaInsetTop, true) ? 0 : 0)
      Row() {
        Row() { this.leftBuilder(); UPIcon({ props: new UPIconProps({ name: this.props.leftIcon, size: this.props.iconSize, color: this.props.iconColor }) }) }
          .width(56).height('100%').onClick(() => this.clickLeft())
        Row() { this.centerBuilder() }.layoutWeight(1).height('100%')
        Row() { UPIcon({ props: new UPIconProps({ name: 'home', size: this.props.iconSize, color: this.props.iconColor }) }) }
          .width(56).height('100%').justifyContent(FlexAlign.End).onClick(() => this.clickHome())
      }.width('100%').height(this.barHeight()).padding({ left: 8, right: 8 })
        .backgroundColor(UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, 'rgba(0,0,0,.15)'))
    }.width('100%').zIndex(upBoolean(this.props.fixed, true) ? 10 : 0)
  }
}
