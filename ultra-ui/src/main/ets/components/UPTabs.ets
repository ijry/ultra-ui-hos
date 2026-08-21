import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPTabsClickEvent, UPTabsContext, UPTabsItemData } from '../internal/UPNavigationContexts';

export { UPTabsClickEvent, UPTabsItemData } from '../internal/UPNavigationContexts';
export interface UPTabsOptions {
  duration?: UPRawValue; list?: Array<UPTabsItemData>; lineColor?: UPRawValue; activeStyle?: UPStyleInput; inactiveStyle?: UPStyleInput;
  lineWidth?: UPRawValue; lineHeight?: UPRawValue; lineBgSize?: UPRawValue; itemStyle?: UPStyleInput; scrollable?: UPRawValue;
  current?: UPRawValue; keyName?: UPRawValue; iconStyle?: UPStyleInput; shapeMode?: UPRawValue; customStyle?: UPStyleInput;
  onCurrentChange?: (index: number) => void; onChange?: (event: UPTabsClickEvent) => void; onClick?: (event: UPTabsClickEvent) => void;
  onLongPress?: (event: UPTabsClickEvent) => void; leftBuilder?: () => void; rightBuilder?: () => void;
  iconBuilder?: () => void; contentBuilder?: () => void;
}
export class UPTabsProps {
  duration: UPRawValue = 300; list: Array<UPTabsItemData> = []; lineColor: UPRawValue = '#3c9cff';
  activeStyle: UPStyleInput = undefined; inactiveStyle: UPStyleInput = undefined; lineWidth: UPRawValue = 20; lineHeight: UPRawValue = 3;
  lineBgSize: UPRawValue = 'cover'; itemStyle: UPStyleInput = undefined; scrollable: UPRawValue = true; current: UPRawValue = 0;
  keyName: UPRawValue = 'name'; iconStyle: UPStyleInput = undefined; shapeMode: UPRawValue = ''; customStyle: UPStyleInput = undefined;
  onCurrentChange?: (index: number) => void; onChange?: (event: UPTabsClickEvent) => void; onClick?: (event: UPTabsClickEvent) => void;
  onLongPress?: (event: UPTabsClickEvent) => void; leftBuilder?: () => void; rightBuilder?: () => void; iconBuilder?: () => void; contentBuilder?: () => void;
  constructor(options?: UPTabsOptions) {
    if (options === undefined) return;
    this.duration = options.duration ?? this.duration; this.list = options.list ?? this.list; this.lineColor = options.lineColor ?? this.lineColor;
    this.activeStyle = options.activeStyle; this.inactiveStyle = options.inactiveStyle; this.lineWidth = options.lineWidth ?? this.lineWidth;
    this.lineHeight = options.lineHeight ?? this.lineHeight; this.lineBgSize = options.lineBgSize ?? this.lineBgSize; this.itemStyle = options.itemStyle;
    this.scrollable = options.scrollable ?? this.scrollable; this.current = options.current ?? this.current; this.keyName = options.keyName ?? this.keyName;
    this.iconStyle = options.iconStyle; this.shapeMode = options.shapeMode ?? this.shapeMode; this.customStyle = options.customStyle;
    this.onCurrentChange = options.onCurrentChange; this.onChange = options.onChange; this.onClick = options.onClick; this.onLongPress = options.onLongPress;
    this.leftBuilder = options.leftBuilder; this.rightBuilder = options.rightBuilder; this.iconBuilder = options.iconBuilder; this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPTabs {
  @Prop @Watch('refreshContext') props: UPTabsProps = new UPTabsProps();
  @Provide('UPTabsContext') tabsContext: UPTabsContext = new UPTabsContext();
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam leftBuilder: () => void = this.emptyBuilder;
  @BuilderParam rightBuilder: () => void = this.emptyBuilder;
  @BuilderParam iconBuilder: () => void = this.emptyBuilder;
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void { this.refreshContext(); }
  refreshContext(): void {
    this.tabsContext = new UPTabsContext();
    this.tabsContext.beginComposition(this.props.list, this.current(), this.props.onCurrentChange, this.props.onChange, this.props.onClick, this.props.onLongPress);
  }
  private current(): number { return Math.max(0, upNumber(this.props.current, 0)); }
  private shape(): string {
    const value: string = upString(this.props.shapeMode, '').toLowerCase();
    return ['capsule', 'card', 'pill-arrow', 'tag'].includes(value) ? value : '';
  }
  private itemName(item: UPTabsItemData): string {
    const key: string = upString(this.props.keyName, 'name');
    const value: UPRawValue = key === 'name' ? item.name : item.name;
    return String(value ?? '');
  }
  private activeColor(item: UPTabsItemData): string { return UPColor.parse(item.activeColor, UP_DEFAULT_THEME, UPStyle.parse(this.props.activeStyle).color ?? '#303133'); }
  private inactiveColor(item: UPTabsItemData): string { return UPColor.parse(item.inactiveColor, UP_DEFAULT_THEME, UPStyle.parse(this.props.inactiveStyle).color ?? '#606266'); }
  private itemIndexes(): Array<number> { return this.props.list.map((_item: UPTabsItemData, index: number): number => index); }

  @Builder private tab(index: number) {
    Column({ space: 5 }) {
      Row({ space: 4 }) {
        if (String(this.props.list[index].icon ?? '').length > 0) UPIcon({ props: new UPIconProps({ name: this.props.list[index].icon, size: 16 }) })
        this.iconBuilder()
        Text(this.itemName(this.props.list[index])).fontSize(14)
          .fontWeight(this.current() === index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.current() === index ? this.activeColor(this.props.list[index]) : this.inactiveColor(this.props.list[index]))
        if (String(this.props.list[index].badge ?? '').length > 0) Text(String(this.props.list[index].badge)).fontSize(10).fontColor('#ffffff').backgroundColor('#fa3534').borderRadius(8).padding({ left: 4, right: 4 })
      }
      if (this.current() === index) Column().width(UPUnit.parse(this.props.lineWidth, 375, 20)).height(UPUnit.parse(this.props.lineHeight, 375, 3)).backgroundColor(UPColor.parse(this.props.lineColor, UP_DEFAULT_THEME, '#3c9cff')).borderRadius(2)
    }.height(44).padding(UPStyle.parse(this.props.itemStyle).padding ?? { left: 14, right: 14 })
      .justifyContent(FlexAlign.Center).opacity(upBoolean(this.props.list[index].disabled, false) ? 0.45 : 1)
      .backgroundColor(this.shape().length > 0 && this.current() === index ? '#ecf5ff' : 'transparent')
      .borderRadius(this.shape() === 'capsule' || this.shape() === 'tag' ? 18 : 4)
      .onClick(() => this.tabsContext.requestSelect(index))
      .gesture(LongPressGesture().onAction(() => this.tabsContext.requestLongPress(index)))
  }

  @Builder private tabsRow() {
    Row() { ForEach(this.itemIndexes(), (index: number) => { this.tab(index) }) }
      .width(upBoolean(this.props.scrollable, true) ? 'auto' : '100%')
  }
  build() {
    Column() {
      Row() {
        this.leftBuilder()
        if (upBoolean(this.props.scrollable, true)) Scroll() { this.tabsRow() }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).layoutWeight(1)
        else this.tabsRow()
        this.rightBuilder()
      }.width('100%')
      this.contentBuilder()
    }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
