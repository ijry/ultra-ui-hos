import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPLoadingIcon, UPLoadingIconProps } from './UPLoadingIcon';
import { UPIcon, UPIconProps } from './UPIcon';

export interface UPLoadmoreOptions {
  status?: UPRawValue;
  loadingText?: UPRawValue;
  loadmoreText?: UPRawValue;
  nomoreText?: UPRawValue;
  icon?: UPRawValue;
  iconSize?: UPRawValue;
  fontSize?: UPRawValue;
  color?: UPRawValue;
  line?: UPRawValue;
  dashed?: UPRawValue;
  customStyle?: UPStyleInput;
}

export class UPLoadmoreProps {
  status: UPRawValue = 'loadmore';
  loadingText: UPRawValue = '正在加载...';
  loadmoreText: UPRawValue = '加载更多';
  nomoreText: UPRawValue = '没有更多了';
  icon: UPRawValue = true;
  iconSize: UPRawValue = 17;
  fontSize: UPRawValue = 14;
  color: UPRawValue = 'tips';
  line: UPRawValue = false;
  dashed: UPRawValue = false;
  customStyle: UPStyleInput = undefined;

  constructor(options?: UPLoadmoreOptions) {
    if (options === undefined) {
      return;
    }
    this.status = options.status ?? this.status;
    this.loadingText = options.loadingText ?? this.loadingText;
    this.loadmoreText = options.loadmoreText ?? this.loadmoreText;
    this.nomoreText = options.nomoreText ?? this.nomoreText;
    this.icon = options.icon ?? this.icon;
    this.iconSize = options.iconSize ?? this.iconSize;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.color = options.color ?? this.color;
    this.line = options.line ?? this.line;
    this.dashed = options.dashed ?? this.dashed;
    this.customStyle = options.customStyle;
  }
}

@Component
export struct UPLoadmore {
  @Prop props: UPLoadmoreProps = new UPLoadmoreProps();

  private status(): string {
    const status: string = upString(this.props.status, 'loadmore').toLowerCase();
    return status === 'loading' || status === 'nomore' ? status : 'loadmore';
  }

  private label(): string {
    if (this.status() === 'loading') {
      return String(this.props.loadingText ?? '正在加载...');
    }
    if (this.status() === 'nomore') {
      return String(this.props.nomoreText ?? '没有更多了');
    }
    return String(this.props.loadmoreText ?? '加载更多');
  }

  private textColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, UP_DEFAULT_THEME.tips);
  }

  @Builder
  private sideLine() {
    if (upBoolean(this.props.line, false)) {
      Column()
        .layoutWeight(1)
        .height(0.5)
        .backgroundColor(this.textColor())
        .opacity(upBoolean(this.props.dashed, false) ? 0.55 : 0.35)
    }
  }

  @Builder
  private statusIcon() {
    if (this.status() === 'loading' && upBoolean(this.props.icon, true)) {
      UPLoadingIcon({ props: new UPLoadingIconProps({
        color: this.textColor(),
        size: this.props.iconSize,
        text: ''
      }) })
    } else if (this.status() === 'loadmore' && upBoolean(this.props.icon, false)) {
      UPIcon({ props: new UPIconProps({
        name: 'arrow-down',
        color: this.textColor(),
        size: this.props.iconSize
      }) })
    }
  }

  build() {
    Row({ space: 10 }) {
      this.sideLine()
      Row({ space: 6 }) {
        this.statusIcon()
        Text(this.label())
          .fontSize(UPUnit.parse(this.props.fontSize, 375, 14))
          .fontColor(this.textColor())
      }
      .alignItems(VerticalAlign.Center)
      this.sideLine()
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}
