import { UPRawValue, UPStyleInput, upNumber, upString, upValueKey } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPImage, UPImageProps } from './UPImage';

/** 右侧分组下的子项。/ One child record of a category group. */
export interface UPCateTabChildItem {
  name?: UPRawValue;
  label?: UPRawValue;
  value?: UPRawValue;
  icon?: UPRawValue;
}

/** 左侧栏目与右侧分组共用的数据模型。/ One category record shared by the menu and the pages. */
export interface UPCateTabItem {
  name?: UPRawValue;
  label?: UPRawValue;
  value?: UPRawValue;
  icon?: UPRawValue;
  children?: Array<UPCateTabChildItem>;
}

/** 左侧栏目插槽入参。/ Payload of the tabItem slot. */
export interface UPCateTabItemSlot {
  item: UPCateTabItem;
  index: number;
}

/** 右侧分组插槽入参。/ Payload of the itemList slot. */
export interface UPCateTabPageSlot {
  item: UPCateTabItem;
  index: number;
}

/** 分组子项插槽入参。/ Payload of the pageItem slot. */
export interface UPCateTabPageItemSlot {
  pageItem: UPCateTabChildItem;
  index: number;
}

/** 右上角插槽入参。/ Payload of the rightTop slot. */
export interface UPCateTabRightTopSlot {
  tabList: Array<UPCateTabItem>;
}

/** 读取栏目的具名字段，替代上游 item[tabKeyName]。/ Named replacement of item[tabKeyName]. */
export function upCateTabValue(item: UPCateTabItem, key: string): UPRawValue {
  if (key === 'label') {
    return item.label;
  }
  if (key === 'value') {
    return item.value;
  }
  if (key === 'icon') {
    return item.icon;
  }
  return item.name;
}

/** 读取子项的具名字段，替代上游 item1[itemKeyName]。/ Named replacement of item1[itemKeyName]. */
export function upCateTabChildValue(item: UPCateTabChildItem, key: string): UPRawValue {
  if (key === 'label') {
    return item.label;
  }
  if (key === 'value') {
    return item.value;
  }
  if (key === 'icon') {
    return item.icon;
  }
  return item.name;
}

export interface UPCateTabOptions {
  mode?: UPRawValue;
  height?: UPRawValue;
  tabList?: Array<UPCateTabItem>;
  tabKeyName?: UPRawValue;
  itemKeyName?: UPRawValue;
  current?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onCurrentChange?: (value: number) => void;
}

export class UPCateTabProps {
  mode: UPRawValue = 'follow';
  height: UPRawValue = '100%';
  tabList: Array<UPCateTabItem> = [];
  tabKeyName: UPRawValue = 'name';
  itemKeyName: UPRawValue = 'name';
  current: UPRawValue = 0;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onCurrentChange?: (value: number) => void;

  constructor(options?: UPCateTabOptions) {
    if (options === undefined) {
      return;
    }
    this.mode = options.mode ?? this.mode;
    this.height = options.height ?? this.height;
    this.tabList = options.tabList ?? this.tabList;
    this.tabKeyName = options.tabKeyName ?? this.tabKeyName;
    this.itemKeyName = options.itemKeyName ?? this.itemKeyName;
    this.current = options.current ?? this.current;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onCurrentChange = options.onCurrentChange;
  }
}

@Component
export struct UPCateTab {
  @Prop @Watch('applyCurrent') props: UPCateTabProps = new UPCateTabProps();
  @State private innerCurrent: number = 0;
  @State private menuHeight: number = 0;
  private groupOffsets: Array<number> = [];
  private menuScroller: Scroller = new Scroller();
  private pageScroller: Scroller = new Scroller();
  private appliedCurrent: number = -1;
  private scrollLocked: boolean = false;

  @Builder
  private defaultTabItem(slot: UPCateTabItemSlot) {
    Text(upValueKey(upCateTabValue(slot.item, upString(this.props.tabKeyName, 'name'))))
      .fontSize(this.isActive(slot.index) ? this.activeFontSize() : this.normalFontSize())
      .fontColor(this.isActive(slot.index) ? '#303133' : '#606266')
      .fontWeight(this.isActive(slot.index) ? FontWeight.Bold : FontWeight.Normal)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .textAlign(TextAlign.Center)
      .width('100%')
      .padding({ left: 6, right: 6 })
  }

  @Builder
  private defaultRightTop(slot: UPCateTabRightTopSlot) {
    Row().width(0).height(0)
  }

  @Builder
  private defaultPageItem(slot: UPCateTabPageItemSlot) {
    Column({ space: 4 }) {
      UPImage({ props: new UPImageProps({
        src: upCateTabChildValue(slot.pageItem, 'icon'),
        width: this.thumbSize(),
        height: this.thumbSize(),
        mode: 'aspectFit'
      }) })
      Text(upValueKey(upCateTabChildValue(slot.pageItem, upString(this.props.itemKeyName, 'name'))))
        .fontSize(this.childFontSize())
        .fontColor(UPColor.adaptive('#303133', 'main-color'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .margin({ top: this.childGap() })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private defaultItemList(slot: UPCateTabPageSlot) {
    Column() {
      Text(upValueKey(upCateTabValue(slot.item, upString(this.props.tabKeyName, 'name'))))
        .fontSize(this.normalFontSize())
        .fontColor(UPColor.adaptive('#303133', 'main-color'))
        .fontWeight(FontWeight.Bold)
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.children(slot.item), (child: UPCateTabChildItem, childIndex: number) => {
          Column() {
            this.pageItemBuilder({ pageItem: child, index: childIndex })
          }
          .width('33.33%')
        }, (child: UPCateTabChildItem, childIndex: number): string => this.childKey(child, childIndex))
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @BuilderParam tabItemBuilder: (slot: UPCateTabItemSlot) => void = this.defaultTabItem;
  @BuilderParam rightTopBuilder: (slot: UPCateTabRightTopSlot) => void = this.defaultRightTop;
  @BuilderParam itemListBuilder: (slot: UPCateTabPageSlot) => void = this.defaultItemList;
  @BuilderParam pageItemBuilder: (slot: UPCateTabPageItemSlot) => void = this.defaultPageItem;

  aboutToAppear(): void {
    this.reportCompatibility();
    this.applyCurrent();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private reportCompatibility(): void {
    if (this.modeName() !== upString(this.props.mode, 'follow')) {
      this.diagnostics().report('UPCateTab', 'mode', this.props.mode, 'unsupported mode; fallback to follow');
    }
    const tabKey: string = upString(this.props.tabKeyName, 'name');
    if (tabKey !== 'name' && tabKey !== 'label' && tabKey !== 'value' && tabKey !== 'icon') {
      this.diagnostics().report('UPCateTab', 'tabKeyName', this.props.tabKeyName, 'only the named fields name/label/value/icon are addressable; name is used instead');
    }
    const itemKey: string = upString(this.props.itemKeyName, 'name');
    if (itemKey !== 'name' && itemKey !== 'label' && itemKey !== 'value' && itemKey !== 'icon') {
      this.diagnostics().report('UPCateTab', 'itemKeyName', this.props.itemKeyName, 'only the named fields name/label/value/icon are addressable; name is used instead');
    }
  }

  /** 上游 mode 仅 follow 联动与 tab 单显两种。/ Upstream mode whitelist. */
  private modeName(): string {
    return upString(this.props.mode, 'follow') === 'tab' ? 'tab' : 'follow';
  }

  private tabItems(): Array<UPCateTabItem> {
    return this.props.tabList;
  }

  private children(item: UPCateTabItem): Array<UPCateTabChildItem> {
    return item.children ?? [];
  }

  private normalizeIndex(value: number): number {
    const total: number = this.tabItems().length;
    if (total <= 0) {
      return 0;
    }
    if (value < 0) {
      return 0;
    }
    return value > total - 1 ? total - 1 : Math.floor(value);
  }

  /** current 变化时同步内部值并联动两侧滚动。/ Mirrors the upstream current watcher. */
  private applyCurrent(): void {
    const next: number = this.normalizeIndex(Math.floor(upNumber(this.props.current, 0)));
    if (next === this.appliedCurrent) {
      return;
    }
    this.appliedCurrent = next;
    this.innerCurrent = next;
    this.scrollMenuTo(next);
    this.scrollPageTo(next);
  }

  private isActive(index: number): boolean {
    return this.innerCurrent === index;
  }

  private itemKey(item: UPCateTabItem, index: number): string {
    const raw: UPRawValue = upCateTabValue(item, upString(this.props.tabKeyName, 'name'));
    return raw === undefined || raw === null ? String(index) : upValueKey(raw) + '-' + String(index);
  }

  private childKey(item: UPCateTabChildItem, index: number): string {
    const raw: UPRawValue = upCateTabChildValue(item, upString(this.props.itemKeyName, 'name'));
    return raw === undefined || raw === null ? String(index) : upValueKey(raw) + '-' + String(index);
  }

  private menuWidth(): number {
    return UPUnit.parse('200rpx', 375, 100);
  }

  private menuItemHeight(): number {
    return UPUnit.parse('110rpx', 375, 55);
  }

  private normalFontSize(): number {
    return UPUnit.parse('26rpx', 375, 13);
  }

  private activeFontSize(): number {
    return UPUnit.parse('30rpx', 375, 15);
  }

  private childFontSize(): number {
    return UPUnit.parse('24rpx', 375, 12);
  }

  private childGap(): number {
    return UPUnit.parse('20rpx', 375, 10);
  }

  private thumbSize(): number {
    return UPUnit.parse('120rpx', 375, 60);
  }

  private pagePadding(): number {
    return UPUnit.parse('16rpx', 375, 8);
  }

  private pageGap(): number {
    return UPUnit.parse('30rpx', 375, 15);
  }

  private pageRadius(): number {
    return UPUnit.parse('8rpx', 375, 4);
  }

  private activeBarHeight(): number {
    return UPUnit.parse('32rpx', 375, 16);
  }

  private primaryColor(): string {
    return UPColor.parse('primary', UP_DEFAULT_THEME, '#2979ff');
  }

  private containerHeight(): string | number {
    const style: UPRawValue = UPStyle.parse(this.props.customStyle).height;
    if (typeof style === 'number' && style > 0) {
      return style;
    }
    const raw: UPRawValue = this.props.height;
    if (typeof raw === 'string' && raw.trim().endsWith('%')) {
      return raw.trim();
    }
    const parsed: number = UPUnit.parse(raw, 375, 0);
    return parsed > 0 ? parsed : '100%';
  }

  private measure(value: Length): number {
    if (typeof value === 'number') {
      return Math.max(0, value);
    }
    if (typeof value === 'string') {
      return Math.max(0, UPUnit.parse(value, 375, 0));
    }
    return 0;
  }

  /** 上游用 createSelectorQuery 量算分组位置，这里改用 onAreaChange。/ onAreaChange replaces createSelectorQuery. */
  private recordOffset(index: number, area: Area): void {
    const top: number = this.measure(area.position.y ?? 0);
    while (this.groupOffsets.length <= index) {
      this.groupOffsets.push(0);
    }
    this.groupOffsets[index] = top;
  }

  /** 把左侧激活项滚动到可视区中部，对齐上游 leftMenuStatus()。/ Upstream leftMenuStatus(). */
  private scrollMenuTo(index: number): void {
    const viewport: number = this.menuHeight > 0 ? this.menuHeight : this.menuItemHeight() * 6;
    const target: number = index * this.menuItemHeight() + this.menuItemHeight() / 2 - viewport / 2;
    this.menuScroller.scrollTo({ xOffset: 0, yOffset: Math.max(0, target), animation: true });
  }

  /** follow 模式点击左侧时滚动右侧到对应分组。/ Upstream scroll-into-view behaviour. */
  private scrollPageTo(index: number): void {
    if (this.modeName() !== 'follow') {
      return;
    }
    if (index < 0 || index >= this.groupOffsets.length) {
      return;
    }
    this.scrollLocked = true;
    this.pageScroller.scrollTo({ xOffset: 0, yOffset: Math.max(0, this.groupOffsets[index]), animation: true });
  }

  /** 上游 swichMenu()。/ Upstream swichMenu(). */
  private selectMenu(index: number): void {
    const next: number = this.normalizeIndex(index);
    this.scrollPageTo(next);
    if (next === this.innerCurrent) {
      return;
    }
    this.innerCurrent = next;
    this.appliedCurrent = next;
    this.props.onCurrentChange?.(next);
  }

  /** 上游 rightScroll() 节流联动，这里直接按量算偏移换算。/ Upstream rightScroll(). */
  private syncFromScroll(offset: number): void {
    if (this.modeName() !== 'follow' || this.groupOffsets.length === 0) {
      return;
    }
    if (this.scrollLocked) {
      this.scrollLocked = false;
      return;
    }
    const position: number = Math.max(0, offset) + 1;
    let matched: number = 0;
    for (let index: number = 0; index < this.groupOffsets.length; index += 1) {
      if (position >= this.groupOffsets[index]) {
        matched = index;
      }
    }
    if (matched === this.innerCurrent) {
      return;
    }
    this.innerCurrent = matched;
    this.appliedCurrent = matched;
    this.scrollMenuTo(matched);
    this.props.onCurrentChange?.(matched);
  }

  private isVisibleGroup(index: number): boolean {
    return this.modeName() === 'follow' || index === this.innerCurrent;
  }

  @Builder
  private menuItem(slot: UPCateTabItemSlot) {
    Stack({ alignContent: Alignment.Start }) {
      Row() {
        this.tabItemBuilder(slot)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      if (this.isActive(slot.index)) {
        Column()
          .width(4)
          .height(this.activeBarHeight())
          .backgroundColor(this.primaryColor())
      }
    }
    .width('100%')
    .height(this.menuItemHeight())
    .backgroundColor(this.isActive(slot.index) ? '#ffffff' : '#f6f6f6')
    .onClick((): void => {
      this.selectMenu(slot.index);
    })
  }

  @Builder
  private groupCard(slot: UPCateTabPageSlot) {
    Column() {
      this.itemListBuilder(slot)
    }
    .width('100%')
    .padding(this.pagePadding())
    .margin({ bottom: this.pageGap() })
    .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
    .border({ width: 1, color: '#e5e7eb' })
    .borderRadius(this.pageRadius())
    .alignItems(HorizontalAlign.Start)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.recordOffset(slot.index, newValue);
    })
  }

  build() {
    Row() {
      Scroll(this.menuScroller) {
        Column() {
          ForEach(this.tabItems(), (item: UPCateTabItem, index: number) => {
            this.menuItem({ item, index })
          }, (item: UPCateTabItem, index: number): string => this.itemKey(item, index))
        }
        .width('100%')
      }
      .width(this.menuWidth())
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#f6f6f6')
      .onAreaChange((_oldValue: Area, newValue: Area): void => {
        this.menuHeight = this.measure(newValue.height);
      })

      Scroll(this.pageScroller) {
        Column() {
          this.rightTopBuilder({ tabList: this.tabItems() })
          Column() {
            ForEach(this.tabItems(), (item: UPCateTabItem, index: number) => {
              if (this.isVisibleGroup(index)) {
                this.groupCard({ item, index })
              }
            }, (item: UPCateTabItem, index: number): string => this.itemKey(item, index))
          }
          .width('100%')
          .padding(this.pagePadding())
        }
        .width('100%')
      }
      .layoutWeight(1)
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#fafafa')
      .onDidScroll((_xOffset: number, _yOffset: number, _state: ScrollState): void => {
        this.syncFromScroll(this.pageScroller.currentOffset().yOffset);
      })
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(this.containerHeight())
    .alignItems(VerticalAlign.Top)
    .clip(true)
    .id('up-cate-tab')
  }
}
