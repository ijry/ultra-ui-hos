import { UPBuilder, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPSlotRegion } from '../internal/UPSlotRegion';

/** 上游展开列表的单项。/ One entry of the upstream expandable list. */
export interface UPFloatingBubbleItem {
  name?: string;
  text?: string;
  color?: string;
  backgroundColor?: string;
  borderColor?: string;
}

export interface UPFloatingBubbleClickEvent { bottom: number; right: number; }
/** 上游 item-click 事件。/ Upstream item-click payload. */
export interface UPFloatingBubbleItemClickEvent { item: UPFloatingBubbleItem; index: number; }
export interface UPFloatingBubbleOptions {
  text?: string; icon?: string; bottom?: number; right?: number; size?: number; color?: string;
  backgroundColor?: string; borderColor?: string; disabled?: boolean; list?: Array<UPFloatingBubbleItem>;
  customStyle?: UPStyleInput;
  onClick?: (event: UPFloatingBubbleClickEvent) => void;
  onItemClick?: (event: UPFloatingBubbleItemClickEvent) => void;
  contentBuilder?: UPBuilder;
  listBuilder?: UPBuilder;
}
export class UPFloatingBubbleProps {
  text: string = ''; icon: string = ''; bottom: number = 24; right: number = 24; size: number = 52;
  color: string = '#ffffff'; backgroundColor: string = '#2979ff'; borderColor: string = '';
  disabled: boolean = false; list: Array<UPFloatingBubbleItem> = [];
  customStyle: UPStyleInput = undefined;
  onClick?: (event: UPFloatingBubbleClickEvent) => void;
  onItemClick?: (event: UPFloatingBubbleItemClickEvent) => void;
  contentBuilder?: UPBuilder;
  listBuilder?: UPBuilder;
  constructor(options?: UPFloatingBubbleOptions) {
    if (options === undefined) return;
    this.text = options.text ?? this.text; this.icon = options.icon ?? this.icon;
    this.bottom = options.bottom ?? this.bottom; this.right = options.right ?? this.right;
    this.size = options.size ?? this.size; this.color = options.color ?? this.color;
    this.backgroundColor = options.backgroundColor ?? this.backgroundColor;
    this.borderColor = options.borderColor ?? this.borderColor;
    this.disabled = options.disabled ?? this.disabled; this.list = options.list ?? this.list;
    this.customStyle = options.customStyle; this.onClick = options.onClick; this.onItemClick = options.onItemClick;
    this.contentBuilder = options.contentBuilder;
    this.listBuilder = options.listBuilder;
  }
}

@Component
export struct UPFloatingBubble {
  @Prop props: UPFloatingBubbleProps = new UPFloatingBubbleProps();
  @State private listVisible: boolean = false;
  private sizeValue(): number { return Math.max(36, upNumber(this.props.size, 52)); }
  private itemColor(item: UPFloatingBubbleItem): string { return item.color ?? this.props.color; }
  private itemBackground(item: UPFloatingBubbleItem): string { return item.backgroundColor ?? this.props.backgroundColor; }
  private itemBorder(item: UPFloatingBubbleItem): string { return item.borderColor ?? this.props.borderColor; }
  private itemLabel(item: UPFloatingBubbleItem): string { return item.text ?? item.name ?? ''; }
  /** 上游 clickHandler()：有 list 时切换展开态。/ Mirrors upstream clickHandler(). */
  private handleClick(): void {
    if (upBoolean(this.props.disabled, false)) return;
    if (this.props.list.length > 0) this.listVisible = !this.listVisible;
    this.props.onClick?.({ bottom: upNumber(this.props.bottom, 24), right: upNumber(this.props.right, 24) });
  }
  /** 上游 itemClick()。/ Mirrors upstream itemClick(). */
  private handleItemClick(item: UPFloatingBubbleItem, index: number): void {
    this.listVisible = false;
    this.props.onItemClick?.({ item, index });
  }
  @Builder
  private mainBubble() {
    Column({ space: 3 }) {
      if (this.props.contentBuilder !== undefined) {
        this.slotRegion()
      } else if (upString(this.props.icon, '').length > 0) {
        Text(String(this.props.icon)).fontSize(19).fontColor(this.props.color)
      }
      if (this.props.list.length > 0 && upString(this.props.icon, '').length === 0) {
        UPIcon({ props: new UPIconProps({ name: 'plus', size: 19, color: this.props.color }) })
      }
      if (upString(this.props.text, '').length > 0) Text(this.props.text).fontSize(11).fontColor(this.props.color)
    }.justifyContent(FlexAlign.Center).width(this.sizeValue()).height(this.sizeValue())
     .borderRadius(this.sizeValue() / 2).backgroundColor(this.props.backgroundColor)
     .borderWidth(upString(this.props.borderColor, '').length > 0 ? 1 : 0)
     .borderColor(upString(this.props.borderColor, '#00000000'))
     .opacity(upBoolean(this.props.disabled, false) ? 0.55 : 1)
     .shadow({ radius: 10, color: '#14000000', offsetY: 3 })
     .onClick((): void => this.handleClick())
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  @Builder
  private listRegion() {
    UPSlotRegion({ contentBuilder: this.props.listBuilder })
  }

  build() {
    Column({ space: 10 }) {
      if (this.listVisible && this.props.listBuilder !== undefined) {
        this.listRegion()
      } else if (this.listVisible) {
        ForEach(this.props.list, (item: UPFloatingBubbleItem, index: number) => {
          Column() {
            if (upString(item.name, '').length > 0) {
              UPIcon({ props: new UPIconProps({ name: upString(item.name, ''), size: 18, color: this.itemColor(item) }) })
            }
            if (this.itemLabel(item).length > 0 && upString(item.name, '').length === 0) {
              Text(this.itemLabel(item)).fontSize(11).fontColor(this.itemColor(item))
            }
          }
          .width(this.sizeValue()).height(this.sizeValue()).justifyContent(FlexAlign.Center)
          .borderRadius(this.sizeValue() / 2).backgroundColor(this.itemBackground(item))
          .borderWidth(this.itemBorder(item).length > 0 ? 1 : 0).borderColor(this.itemBorder(item).length > 0 ? this.itemBorder(item) : '#00000000')
          .shadow({ radius: 8, color: '#14000000', offsetY: 2 })
          .onClick((): void => this.handleItemClick(item, index))
        }, (item: UPFloatingBubbleItem, index: number): string => String(index) + '-' + upString(item.name, ''))
      }
      this.mainBubble()
    }
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: Math.max(0, upNumber(this.props.bottom, 24)), right: Math.max(0, upNumber(this.props.right, 24)) })
  }
}
