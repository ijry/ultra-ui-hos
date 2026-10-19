import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPTabbarItemData {
  name?: UPRawValue;
  text?: UPRawValue;
  icon?: UPRawValue;
  activeIcon?: UPRawValue;
  value?: UPRawValue;
  badge?: UPRawValue;
  url?: UPRawValue;
  linkType?: UPRawValue;
  disabled?: UPRawValue;
  color?: UPRawValue;
  activeColor?: UPRawValue;
  customStyle?: UPStyleInput;
}

export interface UPTabbarItemClickEvent {
  index: number;
  name: UPRawValue;
  value: UPRawValue;
  url: UPRawValue;
  linkType: UPRawValue;
}

export interface UPTabbarItemOptions {
  name?: UPRawValue;
  text?: UPRawValue;
  icon?: UPRawValue;
  activeIcon?: UPRawValue;
  value?: UPRawValue;
  badge?: UPRawValue;
  url?: UPRawValue;
  linkType?: UPRawValue;
  active?: UPRawValue;
  disabled?: UPRawValue;
  color?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
  height?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  index?: number;
  onClick?: (event: UPTabbarItemClickEvent) => void;
  onChange?: (event: UPTabbarItemClickEvent) => void;
  activeIconBuilder?: UPBuilder;
  inactiveIconBuilder?: UPBuilder;
  textBuilder?: UPBuilder;
}

export class UPTabbarItemProps {
  name: UPRawValue = '';
  text: UPRawValue = '';
  icon: UPRawValue = '';
  activeIcon: UPRawValue = '';
  value: UPRawValue = '';
  badge: UPRawValue = '';
  url: UPRawValue = '';
  linkType: UPRawValue = '';
  active: UPRawValue = false;
  disabled: UPRawValue = false;
  color: UPRawValue = '#909399';
  activeColor: UPRawValue = '#2979ff';
  inactiveColor: UPRawValue = '#909399';
  height: UPRawValue = 52;
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  index: number = 0;
  onClick?: (event: UPTabbarItemClickEvent) => void;
  onChange?: (event: UPTabbarItemClickEvent) => void;
  activeIconBuilder?: UPBuilder;
  inactiveIconBuilder?: UPBuilder;
  textBuilder?: UPBuilder;

  constructor(options?: UPTabbarItemOptions) {
    if (options === undefined) return;
    this.name = options.name ?? this.name;
    this.text = options.text ?? this.text;
    this.icon = options.icon ?? this.icon;
    this.activeIcon = options.activeIcon ?? this.activeIcon;
    this.value = options.value ?? this.value;
    this.badge = options.badge ?? this.badge;
    this.url = options.url ?? this.url;
    this.linkType = options.linkType ?? this.linkType;
    this.active = options.active ?? this.active;
    this.disabled = options.disabled ?? this.disabled;
    this.color = options.color ?? this.color;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.height = options.height ?? this.height;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.index = options.index ?? this.index;
    this.onClick = options.onClick;
    this.onChange = options.onChange;
    this.activeIconBuilder = options.activeIconBuilder;
    this.inactiveIconBuilder = options.inactiveIconBuilder;
    this.textBuilder = options.textBuilder;
  }
}

@Component
export struct UPTabbarItem {
  @Prop props: UPTabbarItemProps = new UPTabbarItemProps();

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private textValue(value: UPRawValue): string {
    return value === null || value === undefined ? '' : String(value);
  }

  private label(): string {
    const text: string = this.textValue(this.props.text);
    return text.length > 0 ? text : this.textValue(this.props.name);
  }

  private iconName(): string {
    const active: string = this.textValue(this.props.activeIcon);
    const normal: string = this.textValue(this.props.icon);
    return upBoolean(this.props.active, false) && active.length > 0 ? active : normal;
  }

  private itemHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(40, style.height ?? UPUnit.parse(this.props.height, 375, 52));
  }

  private itemColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.color !== undefined) return style.color;
    return UPColor.parse(upBoolean(this.props.active, false) ? this.props.activeColor : this.props.inactiveColor,
      UP_DEFAULT_THEME, UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#909399'));
  }

  private itemWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? '100%';
  }

  private itemPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? { top: 5, right: 4, bottom: 5, left: 4 };
  }

  /** 上游 click 与 change 同时抛出。/ Upstream emits click and change together. */
  private handleClick(): void {
    if (upBoolean(this.props.disabled, false)) return;
    const event: UPTabbarItemClickEvent = {
      index: this.props.index,
      name: this.props.name,
      value: this.props.value,
      url: this.props.url,
      linkType: this.props.linkType
    };
    this.props.onClick?.(event);
    this.props.onChange?.(event);
  }

  @Builder
  private activeIconRegion() {
    UPSlotRegion({ contentBuilder: this.props.activeIconBuilder })
  }

  @Builder
  private inactiveIconRegion() {
    UPSlotRegion({ contentBuilder: this.props.inactiveIconBuilder })
  }

  @Builder
  private textRegion() {
    UPSlotRegion({ contentBuilder: this.props.textBuilder })
  }

  build() {
    Column({ space: 3 }) {
      if (this.iconName().length > 0) {
        UPIcon({ props: new UPIconProps({ name: this.iconName(), size: 21, color: this.itemColor() }) })
      } else if (upBoolean(this.props.active, false) && this.props.activeIconBuilder !== undefined) {
        this.activeIconRegion()
      } else if (!upBoolean(this.props.active, false) && this.props.inactiveIconBuilder !== undefined) {
        this.inactiveIconRegion()
      } else {
        Column().width(21).height(21)
      }
      if (this.props.textBuilder !== undefined) {
        this.textRegion()
      } else if (this.label().length > 0) {
        Text(this.label()).fontSize(11).fontColor(this.itemColor())
      }
      this.contentBuilder()
      if (this.textValue(this.props.badge).length > 0) {
        Text(this.textValue(this.props.badge))
          .fontSize(9)
          .fontColor('#ffffff')
          .backgroundColor('#fa3534')
          .borderRadius(8)
          .padding({ left: 4, right: 4 })
      }
    }
    .width(this.itemWidth())
    .height(this.itemHeight())
    .padding(this.itemPadding())
    .justifyContent(FlexAlign.Center)
    .opacity(upBoolean(this.props.disabled, false) ? 0.45 : 1)
    .onClick(() => this.handleClick())
  }
}
