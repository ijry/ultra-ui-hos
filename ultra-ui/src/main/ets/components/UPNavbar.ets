import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle, UPStyleResult } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';

export interface UPNavigationAdapter { navigateBack?: () => void; relaunch?: (url: string) => void; }
export interface UPNavbarOptions {
  safeAreaInsetTop?: UPRawValue; placeholder?: UPRawValue; fixed?: UPRawValue; border?: UPRawValue;
  leftIcon?: UPRawValue; leftText?: UPRawValue; rightText?: UPRawValue; rightIcon?: UPRawValue;
  title?: UPRawValue; titleColor?: UPRawValue; bgColor?: UPRawValue; statusBarBgColor?: UPRawValue;
  titleWidth?: UPRawValue; height?: UPRawValue; leftIconSize?: UPRawValue; leftIconColor?: UPRawValue;
  autoBack?: UPRawValue; titleStyle?: UPStyleInput; customStyle?: UPStyleInput; navigationAdapter?: UPNavigationAdapter;
  onLeftClick?: () => void; onRightClick?: () => void; leftBuilder?: () => void; centerBuilder?: () => void; rightBuilder?: () => void;
}
export class UPNavbarProps {
  safeAreaInsetTop: UPRawValue = true; placeholder: UPRawValue = false; fixed: UPRawValue = true; border: UPRawValue = false;
  leftIcon: UPRawValue = 'arrow-left'; leftText: UPRawValue = ''; rightText: UPRawValue = ''; rightIcon: UPRawValue = '';
  title: UPRawValue = ''; titleColor: UPRawValue = ''; bgColor: UPRawValue = ''; statusBarBgColor: UPRawValue = '';
  titleWidth: UPRawValue = '400rpx'; height: UPRawValue = '44px'; leftIconSize: UPRawValue = 20; leftIconColor: UPRawValue = '';
  autoBack: UPRawValue = false; titleStyle: UPStyleInput = undefined; customStyle: UPStyleInput = undefined;
  navigationAdapter?: UPNavigationAdapter; onLeftClick?: () => void; onRightClick?: () => void;
  leftBuilder?: () => void; centerBuilder?: () => void; rightBuilder?: () => void;
  constructor(options?: UPNavbarOptions) {
    if (options === undefined) return;
    this.safeAreaInsetTop = options.safeAreaInsetTop ?? this.safeAreaInsetTop; this.placeholder = options.placeholder ?? this.placeholder;
    this.fixed = options.fixed ?? this.fixed; this.border = options.border ?? this.border; this.leftIcon = options.leftIcon ?? this.leftIcon;
    this.leftText = options.leftText ?? this.leftText; this.rightText = options.rightText ?? this.rightText; this.rightIcon = options.rightIcon ?? this.rightIcon;
    this.title = options.title ?? this.title; this.titleColor = options.titleColor ?? this.titleColor; this.bgColor = options.bgColor ?? this.bgColor;
    this.statusBarBgColor = options.statusBarBgColor ?? this.statusBarBgColor; this.titleWidth = options.titleWidth ?? this.titleWidth;
    this.height = options.height ?? this.height; this.leftIconSize = options.leftIconSize ?? this.leftIconSize; this.leftIconColor = options.leftIconColor ?? this.leftIconColor;
    this.autoBack = options.autoBack ?? this.autoBack; this.titleStyle = options.titleStyle; this.customStyle = options.customStyle;
    this.navigationAdapter = options.navigationAdapter; this.onLeftClick = options.onLeftClick; this.onRightClick = options.onRightClick;
    this.leftBuilder = options.leftBuilder; this.centerBuilder = options.centerBuilder; this.rightBuilder = options.rightBuilder;
  }
}

@Component
export struct UPNavbar {
  @Prop props: UPNavbarProps = new UPNavbarProps();
  @Builder private emptyLeft() { Row().width(0).height(0) }
  @Builder private emptyCenter() { Row().width(0).height(0) }
  @Builder private emptyRight() { Row().width(0).height(0) }
  @BuilderParam leftBuilder: () => void = this.emptyLeft;
  @BuilderParam centerBuilder: () => void = this.emptyCenter;
  @BuilderParam rightBuilder: () => void = this.emptyRight;

  private resolvedStyle(): UPStyleResult { return UPStyle.parse(this.props.customStyle); }
  private topInset(): number { return upBoolean(this.props.safeAreaInsetTop, true) ? 0 : 0; }
  private barHeight(): number { return this.resolvedStyle().height ?? UPUnit.parse(this.props.height, 375, 44); }
  private bg(): string { return UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#ffffff'); }
  private title(): string { return String(this.props.title ?? ''); }
  private clickLeft(): void { this.props.onLeftClick?.(); if (upBoolean(this.props.autoBack, false)) this.props.navigationAdapter?.navigateBack?.(); }
  private clickRight(): void { this.props.onRightClick?.(); }

  @Builder private leftContent() {
    Row({ space: 4 }) {
      if (String(this.props.leftIcon ?? '').length > 0) UPIcon({ props: new UPIconProps({ name: this.props.leftIcon, size: this.props.leftIconSize, color: this.props.leftIconColor }) })
      if (String(this.props.leftText ?? '').length > 0) Text(String(this.props.leftText)).fontSize(14)
    }.height('100%').onClick(() => this.clickLeft())
  }
  @Builder private rightContent() {
    Row({ space: 4 }) {
      if (String(this.props.rightText ?? '').length > 0) Text(String(this.props.rightText)).fontSize(14)
      if (String(this.props.rightIcon ?? '').length > 0) UPIcon({ props: new UPIconProps({ name: this.props.rightIcon, size: 20 }) })
    }.height('100%').onClick(() => this.clickRight())
  }

  @Builder private bar() {
    Row() {
      Row() { this.leftBuilder(); if (String(this.props.leftIcon ?? '').length > 0 || String(this.props.leftText ?? '').length > 0) this.leftContent() }
        .width(92).height('100%').justifyContent(FlexAlign.Start)
      Stack({ alignContent: Alignment.Center }) {
        this.centerBuilder()
        if (this.title().length > 0) Text(this.title()).fontSize(16).fontWeight(FontWeight.Bold)
      }.layoutWeight(1).height('100%')
      Row() { this.rightBuilder(); if (String(this.props.rightIcon ?? '').length > 0 || String(this.props.rightText ?? '').length > 0) this.rightContent() }
        .width(92).height('100%').justifyContent(FlexAlign.End)
    }.width('100%').height(this.barHeight()).padding({ left: 12, right: 12 })
      .backgroundColor(this.bg()).border({ width: { bottom: upBoolean(this.props.border, false) ? 1 : 0 }, color: '#e5e6eb' })
  }

  build() {
    Column() {
      Column() {
        Column().height(this.topInset()).backgroundColor(UPColor.parse(this.props.statusBarBgColor, UP_DEFAULT_THEME, this.bg()))
        this.bar()
      }.width('100%').zIndex(upBoolean(this.props.fixed, true) ? 10 : 0)
      if (upBoolean(this.props.placeholder, false)) Column().height(this.topInset() + this.barHeight()).width('100%')
    }.width('100%')
  }
}
