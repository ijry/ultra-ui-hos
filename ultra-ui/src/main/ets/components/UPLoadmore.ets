import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPLoadingIcon, UPLoadingIconProps } from './UPLoadingIcon';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPI18n } from '../core/UPI18n';

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
  onLoadmore?: () => void;
}

export class UPLoadmoreProps {
  status: UPRawValue = 'loadmore';
  loadingText: UPRawValue = UPI18n.t('up.common.loading2') + '...';
  loadmoreText: UPRawValue = UPI18n.t('up.loadmoe.loadmore');
  nomoreText: UPRawValue = UPI18n.t('up.loadmoe.nomore');
  icon: UPRawValue = true;
  iconSize: UPRawValue = 17;
  fontSize: UPRawValue = 14;
  color: UPRawValue = 'tips';
  line: UPRawValue = false;
  dashed: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  onLoadmore?: () => void;

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
    this.onLoadmore = options.onLoadmore;
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
    return style.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, UPColor.neutral('tips', '#909399'));
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
    .onClick((): void => this.requestMore())
  }

  /** 上游 `if (this.status == 'loadmore') this.$emit('loadmore')`。/ Mirrors the upstream guard. */
  private requestMore(): void {
    if (this.status() === 'loadmore') {
      this.props.onLoadmore?.();
    }
  }
}
