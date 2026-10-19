import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString, upValueKey } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';

/** One virtual list record. ArkTS forbids index signatures, so fields are named. */
export interface UPVirtualListItem {
  id?: UPRawValue;
  key?: UPRawValue;
  label?: UPRawValue;
  value?: UPRawValue;
  description?: UPRawValue;
  disabled?: UPRawValue;
}

/** Single-parameter payload handed to the item builder; ArkTS builders take one argument. */
export interface UPVirtualListItemSlot {
  item: UPVirtualListItem;
  index: number;
}

/** Rendered window of the data source, mirroring upstream getVisibleRange(). */
export interface UPVirtualListVisibleRange {
  start: number;
  end: number;
}

export interface UPVirtualListScrollEvent {
  scrollTop: number;
  start: number;
  end: number;
}

/** Read one addressable field of a record; replaces upstream item[keyField]. */
export function upVirtualListValue(item: UPVirtualListItem, key: string): UPRawValue {
  if (key === 'id') {
    return item.id;
  }
  if (key === 'key') {
    return item.key;
  }
  if (key === 'value') {
    return item.value;
  }
  if (key === 'label') {
    return item.label;
  }
  return undefined;
}

export interface UPVirtualListOptions {
  listData?: Array<UPVirtualListItem>;
  itemHeight?: UPRawValue;
  height?: UPRawValue;
  buffer?: UPRawValue;
  keyField?: UPRawValue;
  scrollTop?: UPRawValue;
  showScrollbar?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onScroll?: (event: UPVirtualListScrollEvent) => void;
  onScrollTopChange?: (scrollTop: number) => void;
}

export class UPVirtualListProps {
  listData: Array<UPVirtualListItem> = [];
  itemHeight: UPRawValue = 50;
  height: UPRawValue = '100%';
  buffer: UPRawValue = 4;
  keyField: UPRawValue = 'id';
  scrollTop: UPRawValue = 0;
  showScrollbar: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onScroll?: (event: UPVirtualListScrollEvent) => void;
  onScrollTopChange?: (scrollTop: number) => void;

  constructor(options?: UPVirtualListOptions) {
    if (options === undefined) {
      return;
    }
    this.listData = options.listData ?? this.listData;
    this.itemHeight = options.itemHeight ?? this.itemHeight;
    this.height = options.height ?? this.height;
    this.buffer = options.buffer ?? this.buffer;
    this.keyField = options.keyField ?? this.keyField;
    this.scrollTop = options.scrollTop ?? this.scrollTop;
    this.showScrollbar = options.showScrollbar ?? this.showScrollbar;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onScroll = options.onScroll;
    this.onScrollTopChange = options.onScrollTopChange;
  }
}

@Component
export struct UPVirtualList {
  @Prop @Watch('applyScrollTop') props: UPVirtualListProps = new UPVirtualListProps();
  @State private startIndex: number = 0;
  @State private measuredHeight: number = 0;
  private scroller: Scroller = new Scroller();
  private appliedScrollTop: number = -1;

  @Builder
  private defaultItem(slot: UPVirtualListItemSlot) {
    Row({ space: 8 }) {
      Column({ space: 2 }) {
        Text(upValueKey(slot.item.label ?? slot.item.value ?? slot.item.id ?? slot.index))
          .fontSize(15)
          .fontColor(upBoolean(slot.item.disabled, false) ? '#c0c4cc' : '#303133')
        if (slot.item.description !== undefined && slot.item.description !== null) {
          Text(upValueKey(slot.item.description)).fontSize(12).fontColor(UPColor.adaptive('#909399', 'tips-color'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text('#' + String(slot.index + 1)).fontSize(12).fontColor(UPColor.adaptive('#c0c4cc', 'light-color'))
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 0.5 }, color: '#f2f2f2' })
  }

  @BuilderParam itemBuilder: (slot: UPVirtualListItemSlot) => void = this.defaultItem;

  aboutToAppear(): void {
    this.reportCompatibility();
    this.applyScrollTop();
  }

  private reportCompatibility(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    const field: string = upString(this.props.keyField, 'id');
    if (field !== 'id' && field !== 'key' && field !== 'value' && field !== 'label') {
      diagnostics.report('UPVirtualList', 'keyField', this.props.keyField, 'only the named fields id/key/value/label are addressable; the window index is used instead');
    }
  }

  /** Item extent in vp; the window math requires a positive fixed row height. */
  private itemSize(): number {
    const parsed: number = UPUnit.parse(this.props.itemHeight, 375, 50);
    return parsed > 0 ? parsed : 50;
  }

  private bufferCount(): number {
    return Math.max(0, Math.floor(upNumber(this.props.buffer, 4)));
  }

  /** Upstream remain: viewport rows, or a 500vp estimate before the first measure. */
  private remainCount(): number {
    if (this.measuredHeight <= 0) {
      const estimated: number = Math.ceil(500 / this.itemSize());
      return estimated > 0 ? estimated : 10;
    }
    return Math.max(1, Math.ceil(this.measuredHeight / this.itemSize()));
  }

  private windowStart(): number {
    return Math.max(0, this.startIndex - Math.floor(this.bufferCount() / 2));
  }

  private windowEnd(): number {
    const total: number = this.props.listData.length;
    return Math.min(total, this.windowStart() + this.remainCount() + this.bufferCount());
  }

  private windowItems(): Array<UPVirtualListItemSlot> {
    const slots: Array<UPVirtualListItemSlot> = [];
    const end: number = this.windowEnd();
    for (let index = this.windowStart(); index < end; index += 1) {
      slots.push({ item: this.props.listData[index], index });
    }
    return slots;
  }

  private topPlaceholder(): number {
    return this.windowStart() * this.itemSize();
  }

  private bottomPlaceholder(): number {
    return Math.max(0, this.props.listData.length - this.windowEnd()) * this.itemSize();
  }

  private itemKey(slot: UPVirtualListItemSlot): string {
    const raw: UPRawValue = upVirtualListValue(slot.item, upString(this.props.keyField, 'id'));
    return raw === undefined || raw === null ? String(slot.index) : upValueKey(raw);
  }

  private viewportHeight(): string | number {
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

  /** Public window accessor, matching upstream getVisibleRange(). */
  getVisibleRange(): UPVirtualListVisibleRange {
    return { start: this.windowStart(), end: this.windowEnd() };
  }

  private applyScrollTop(): void {
    const top: number = Math.max(0, UPUnit.parse(this.props.scrollTop, 375, 0));
    if (top === this.appliedScrollTop) {
      return;
    }
    this.appliedScrollTop = top;
    this.startIndex = Math.max(0, Math.floor(top / this.itemSize()));
    this.scroller.scrollTo({ xOffset: 0, yOffset: top });
  }

  private handleScroll(offset: number): void {
    const top: number = Math.max(0, offset);
    this.appliedScrollTop = top;
    const next: number = Math.max(0, Math.floor(top / this.itemSize()));
    if (next !== this.startIndex) {
      this.startIndex = next;
    }
    this.props.onScrollTopChange?.(top);
    this.props.onScroll?.({ scrollTop: top, start: this.windowStart(), end: this.windowEnd() });
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Row().width('100%').height(this.topPlaceholder())
        ForEach(this.windowItems(), (slot: UPVirtualListItemSlot) => {
          Row() {
            this.itemBuilder(slot)
          }
          .width('100%')
          .height(this.itemSize())
        }, (slot: UPVirtualListItemSlot): string => this.itemKey(slot))
        Row().width('100%').height(this.bottomPlaceholder())
      }
      .width('100%')
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(this.viewportHeight())
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
    .borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 0)
    .scrollBar(upBoolean(this.props.showScrollbar, false) ? BarState.Auto : BarState.Off)
    .align(Alignment.Top)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      const height: number = this.measure(newValue.height);
      if (height > 0 && Math.abs(height - this.measuredHeight) >= 1) {
        this.measuredHeight = height;
      }
    })
    .onDidScroll((_xOffset: number, _yOffset: number, _state: ScrollState): void => {
      this.handleScroll(this.scroller.currentOffset().yOffset);
    })
  }
}
