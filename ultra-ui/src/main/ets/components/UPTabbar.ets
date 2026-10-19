import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPTabbarItem, UPTabbarItemData, UPTabbarItemClickEvent, UPTabbarItemProps } from './UPTabbarItem';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export { UPTabbarItemData, UPTabbarItemClickEvent } from './UPTabbarItem';

export interface UPTabbarChangeEvent {
  index: number;
  item: UPTabbarItemData;
  value: UPRawValue;
  url: UPRawValue;
  linkType: UPRawValue;
}

export interface UPTabbarOptions {
  list?: Array<UPTabbarItemData>;
  current?: UPRawValue;
  value?: UPRawValue;
  fixed?: UPRawValue;
  placeholder?: UPRawValue;
  safeAreaInsetBottom?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
  backgroundColor?: UPRawValue;
  border?: UPRawValue;
  height?: UPRawValue;
  customStyle?: UPStyleInput;
  onChange?: (event: UPTabbarChangeEvent) => void;
  onClick?: (event: UPTabbarChangeEvent) => void;
  contentBuilder?: UPBuilder;
}

export class UPTabbarProps {
  list: Array<UPTabbarItemData> = [];
  current: UPRawValue = 0;
  value: UPRawValue = undefined;
  fixed: UPRawValue = true;
  placeholder: UPRawValue = false;
  safeAreaInsetBottom: UPRawValue = true;
  activeColor: UPRawValue = '#2979ff';
  inactiveColor: UPRawValue = '#909399';
  backgroundColor: UPRawValue = '#ffffff';
  border: UPRawValue = true;
  height: UPRawValue = 52;
  customStyle: UPStyleInput = undefined;
  onChange?: (event: UPTabbarChangeEvent) => void;
  onClick?: (event: UPTabbarChangeEvent) => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPTabbarOptions) {
    if (options === undefined) return;
    this.list = options.list ?? this.list;
    this.current = options.current ?? this.current;
    this.value = options.value;
    this.fixed = options.fixed ?? this.fixed;
    this.placeholder = options.placeholder ?? this.placeholder;
    this.safeAreaInsetBottom = options.safeAreaInsetBottom ?? this.safeAreaInsetBottom;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.backgroundColor = options.backgroundColor ?? this.backgroundColor;
    this.border = options.border ?? this.border;
    this.height = options.height ?? this.height;
    this.customStyle = options.customStyle;
    this.onChange = options.onChange;
    this.onClick = options.onClick;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPTabbar {
  @Prop props: UPTabbarProps = new UPTabbarProps();

  private textValue(value: UPRawValue): string {
    return value === null || value === undefined ? '' : String(value);
  }

  private numberValue(value: UPRawValue, fallback: number): number {
    if (typeof value === 'number' && Number.isFinite(value)) return value;
    if (typeof value === 'string' && Number.isFinite(Number(value.trim()))) return Number(value.trim());
    return fallback;
  }

  private itemIndexes(): Array<number> {
    return this.props.list.map((_item: UPTabbarItemData, index: number): number => index);
  }

  private requestedValue(): UPRawValue {
    return this.props.value === null || this.props.value === undefined ? this.props.current : this.props.value;
  }

  private selectedIndex(): number {
    if (this.props.list.length === 0) return 0;
    const requested: UPRawValue = this.requestedValue();
    if (typeof requested === 'number' && Number.isFinite(requested)) {
      return Math.max(0, Math.min(this.props.list.length - 1, Math.floor(requested)));
    }
    if (typeof requested === 'string' && Number.isFinite(Number(requested.trim()))) {
      const numeric: number = Math.floor(Number(requested.trim()));
      return Math.max(0, Math.min(this.props.list.length - 1, numeric));
    }
    const requestedText: string = this.textValue(requested);
    for (let index = 0; index < this.props.list.length; index += 1) {
      const item: UPTabbarItemData = this.props.list[index];
      if (this.textValue(item.value) === requestedText || this.textValue(item.name ?? item.text) === requestedText) return index;
    }
    return 0;
  }

  private tabbarHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(40, style.height ?? UPUnit.parse(this.props.height, 375, 52));
  }

  private tabbarWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? '100%';
  }

  private tabbarPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    const parsed: UPEdgeValues = style.padding ?? { top: 0, right: 4, bottom: 0, left: 4 };
    return {
      top: parsed.top,
      right: parsed.right,
      bottom: parsed.bottom + this.bottomInset(),
      left: parsed.left
    };
  }

  private bottomInset(): number {
    return upBoolean(this.props.safeAreaInsetBottom, true) ? 0 : 0;
  }

  private tabbarBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? UPColor.parse(this.props.backgroundColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color'));
  }

  private itemName(item: UPTabbarItemData): UPRawValue {
    return item.name ?? item.text ?? '';
  }

  private itemValue(item: UPTabbarItemData): UPRawValue {
    return item.value === null || item.value === undefined ? this.itemName(item) : item.value;
  }

  private click(index: number): void {
    if (index < 0 || index >= this.props.list.length) return;
    const item: UPTabbarItemData = this.props.list[index];
    if (upBoolean(item.disabled, false)) return;
    const event: UPTabbarChangeEvent = {
      index,
      item,
      value: this.itemValue(item),
      url: item.url,
      linkType: item.linkType
    };
    this.props.onChange?.(event);
    this.props.onClick?.(event);
  }

  private itemClick(index: number, _event: UPTabbarItemClickEvent): void {
    this.click(index);
  }

  @Builder
  private bar() {
    Row() {
      ForEach(this.itemIndexes(), (index: number) => {
        UPTabbarItem({ props: new UPTabbarItemProps({
          name: this.itemName(this.props.list[index]),
          text: this.props.list[index].text,
          icon: this.props.list[index].icon,
          activeIcon: this.props.list[index].activeIcon,
          value: this.itemValue(this.props.list[index]),
          badge: this.props.list[index].badge,
          url: this.props.list[index].url,
          linkType: this.props.list[index].linkType,
          active: this.selectedIndex() === index,
          disabled: this.props.list[index].disabled,
          color: this.props.list[index].color ?? this.props.inactiveColor,
          activeColor: this.props.list[index].activeColor ?? this.props.activeColor,
          inactiveColor: this.props.list[index].color ?? this.props.inactiveColor,
          height: this.tabbarHeight(),
          customStyle: this.props.list[index].customStyle,
          index,
          onClick: (event: UPTabbarItemClickEvent): void => this.itemClick(index, event)
        }) })
        .layoutWeight(1)
      }, (index: number) => String(index))
      this.slotRegion()
    }
    .width(this.tabbarWidth())
    .height(this.tabbarHeight() + this.bottomInset())
    .padding(this.tabbarPadding())
    .backgroundColor(this.tabbarBackground())
    .borderWidth(upBoolean(this.props.border, true) ? 0.5 : 0)
    .borderColor(UPColor.adaptive('#ebeef5', 'border-color'))
    .zIndex(upBoolean(this.props.fixed, true) ? 10 : 0)
  }

  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  build() {
    Column() {
      this.bar()
      if (upBoolean(this.props.placeholder, false) && upBoolean(this.props.fixed, true)) {
        Column().width(this.tabbarWidth()).height(this.tabbarHeight() + this.bottomInset())
      }
    }.width('100%')
  }
}
