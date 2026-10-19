import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString, upValueKey } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';

/** One sortable record. ArkTS forbids index signatures, so the fields are named. */
export interface UPDragSortItem {
  id: UPRawValue;
  label?: UPRawValue;
  value?: UPRawValue;
  description?: UPRawValue;
  disabled?: UPRawValue;
  draggable?: UPRawValue;
}

/** Single-parameter payload handed to the item and handler builders. */
export interface UPDragSortItemSlot {
  item: UPDragSortItem;
  index: number;
}

export interface UPDragSortOptions {
  initialList?: Array<UPDragSortItem>;
  draggable?: UPRawValue;
  vibrate?: UPRawValue;
  direction?: UPRawValue;
  columns?: UPRawValue;
  useHandler?: UPRawValue;
  itemHeight?: UPRawValue;
  itemWidth?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onDragEnd?: (sortedList: Array<UPDragSortItem>) => void;
}

export class UPDragSortProps {
  initialList: Array<UPDragSortItem> = [];
  draggable: UPRawValue = true;
  vibrate: UPRawValue = true;
  direction: UPRawValue = 'vertical';
  columns: UPRawValue = 3;
  useHandler: UPRawValue = false;
  itemHeight: UPRawValue = 40;
  itemWidth: UPRawValue = 80;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onDragEnd?: (sortedList: Array<UPDragSortItem>) => void;

  constructor(options?: UPDragSortOptions) {
    if (options === undefined) {
      return;
    }
    this.initialList = options.initialList ?? this.initialList;
    this.draggable = options.draggable ?? this.draggable;
    this.vibrate = options.vibrate ?? this.vibrate;
    this.direction = options.direction ?? this.direction;
    this.columns = options.columns ?? this.columns;
    this.useHandler = options.useHandler ?? this.useHandler;
    this.itemHeight = options.itemHeight ?? this.itemHeight;
    this.itemWidth = options.itemWidth ?? this.itemWidth;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onDragEnd = options.onDragEnd;
  }
}

@Component
export struct UPDragSort {
  @Prop @Watch('initList') props: UPDragSortProps = new UPDragSortProps();
  @State private orderKeys: Array<string> = [];
  @State private renderKeys: Array<string> = [];
  @State private dragKey: string = '';
  @State private floating: boolean = false;
  @State private dragX: number = 0;
  @State private dragY: number = 0;
  @State private measuredHeight: number = 0;
  @State private measuredWidth: number = 0;
  private baseX: number = 0;
  private baseY: number = 0;
  private sortChanged: boolean = false;
  private snapTimerId: number = -1;
  private clearTimerId: number = -1;

  @Builder
  private defaultItem(slot: UPDragSortItemSlot) {
    Row({ space: 6 }) {
      Text('序号：' + String(slot.index + 1)).fontSize(13).fontColor(UPColor.adaptive('#909399', 'tips-color'))
      Text(upValueKey(slot.item.label ?? slot.item.value ?? slot.item.id)).fontSize(14).fontColor(UPColor.adaptive('#303133', 'main-color'))
    }
    .padding(10)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  @BuilderParam itemBuilder: (slot: UPDragSortItemSlot) => void = this.defaultItem;

  @Builder
  private defaultHandler(slot: UPDragSortItemSlot) {
    Column({ space: 3 }) {
      Row().width(16).height(2).backgroundColor('#c0c4cc').borderRadius(1)
      Row().width(16).height(2).backgroundColor('#c0c4cc').borderRadius(1)
      Row().width(16).height(2).backgroundColor('#c0c4cc').borderRadius(1)
    }
    .padding({ left: 10, right: 10 })
    .justifyContent(FlexAlign.Center)
  }

  @BuilderParam handlerBuilder: (slot: UPDragSortItemSlot) => void = this.defaultHandler;

  aboutToAppear(): void {
    this.initList();
    if (upBoolean(this.props.vibrate, true)) {
      this.report('vibrate', this.props.vibrate,
        'uni.vibrateShort has no dependency-free ArkUI equivalent; haptics stay a no-op');
    }
  }

  aboutToDisappear(): void {
    this.stopTimers();
  }

  private report(property: string, value: UPRawValue, reason: string): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    diagnostics.report('UPDragSort', property, value, reason);
  }

  private stopTimers(): void {
    if (this.snapTimerId >= 0) {
      clearTimeout(this.snapTimerId);
      this.snapTimerId = -1;
    }
    if (this.clearTimerId >= 0) {
      clearTimeout(this.clearTimerId);
      this.clearTimerId = -1;
    }
  }

  private dragDirection(): string {
    const value: string = upString(this.props.direction, 'vertical').toLowerCase();
    return value === 'horizontal' || value === 'all' ? value : 'vertical';
  }

  private columnCount(): number {
    const count: number = Math.floor(upNumber(this.props.columns, 3));
    return count > 0 ? count : 3;
  }

  private itemHeightValue(): number {
    if (this.measuredHeight > 0) {
      return this.measuredHeight;
    }
    return Math.max(1, UPUnit.parse(this.props.itemHeight, 375, 40));
  }

  private itemWidthValue(): number {
    if (this.measuredWidth > 0) {
      return this.measuredWidth;
    }
    return Math.max(1, UPUnit.parse(this.props.itemWidth, 375, 80));
  }

  private keyOf(item: UPDragSortItem): string {
    return upValueKey(item.id);
  }

  /** Upstream initList(): keep the current render order and append newly added ids. */
  private initList(): void {
    const nextOrder: Array<string> = this.props.initialList.map(
      (item: UPDragSortItem): string => this.keyOf(item));
    const known: Array<string> = this.renderKeys.filter((key: string): boolean => nextOrder.includes(key));
    const appended: Array<string> = nextOrder.filter((key: string): boolean => !this.renderKeys.includes(key));
    this.orderKeys = nextOrder;
    this.renderKeys = known.concat(appended);
  }

  private itemFor(key: string): UPDragSortItem | undefined {
    return this.props.initialList.find((item: UPDragSortItem): boolean => this.keyOf(item) === key);
  }

  private slotFor(key: string): UPDragSortItemSlot {
    const item: UPDragSortItem | undefined = this.itemFor(key);
    return { item: item ?? { id: key }, index: this.itemIndex(key) };
  }

  /** Upstream getItemIndex(id). */
  private itemIndex(key: string): number {
    return this.orderKeys.indexOf(key);
  }

  private slotOffsetX(key: string): number {
    if (this.floating && this.dragKey === key) {
      return this.dragX;
    }
    const index: number = Math.max(0, this.itemIndex(key));
    if (this.dragDirection() === 'horizontal') {
      return index * this.itemWidthValue();
    }
    if (this.dragDirection() === 'all') {
      return (index % this.columnCount()) * this.itemWidthValue();
    }
    return 0;
  }

  private slotOffsetY(key: string): number {
    if (this.floating && this.dragKey === key) {
      return this.dragY;
    }
    const index: number = Math.max(0, this.itemIndex(key));
    if (this.dragDirection() === 'horizontal') {
      return 0;
    }
    if (this.dragDirection() === 'all') {
      return Math.floor(index / this.columnCount()) * this.itemHeightValue();
    }
    return index * this.itemHeightValue();
  }

  private itemDraggable(key: string): boolean {
    if (!upBoolean(this.props.draggable, true)) {
      return false;
    }
    const item: UPDragSortItem | undefined = this.itemFor(key);
    return item === undefined ? false : upBoolean(item.draggable, true);
  }

  private panDirection(): PanDirection {
    if (this.dragDirection() === 'horizontal') {
      return PanDirection.Horizontal;
    }
    if (this.dragDirection() === 'all') {
      return PanDirection.All;
    }
    return PanDirection.Vertical;
  }

  private areaWidth(): Length {
    if (this.dragDirection() === 'horizontal') {
      return Math.max(1, this.renderKeys.length) * this.itemWidthValue();
    }
    return '100%';
  }

  private areaHeight(): number {
    const total: number = this.renderKeys.length;
    if (this.dragDirection() === 'horizontal') {
      return this.itemHeightValue();
    }
    if (this.dragDirection() === 'all') {
      return Math.ceil(total / this.columnCount()) * this.itemHeightValue();
    }
    return total * this.itemHeightValue();
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

  private captureSize(key: string, area: Area): void {
    if (this.renderKeys.length === 0 || this.renderKeys[0] !== key) {
      return;
    }
    const height: number = this.measure(area.height);
    const width: number = this.measure(area.width);
    if (height > 0 && Math.abs(height - this.measuredHeight) >= 1) {
      this.measuredHeight = height;
    }
    if (width > 0 && Math.abs(width - this.measuredWidth) >= 1) {
      this.measuredWidth = width;
    }
  }

  private beginDrag(key: string): void {
    if (!this.itemDraggable(key)) {
      return;
    }
    this.stopTimers();
    this.sortChanged = false;
    this.baseX = this.slotOffsetX(key);
    this.baseY = this.slotOffsetY(key);
    this.dragX = this.baseX;
    this.dragY = this.baseY;
    this.dragKey = key;
    this.floating = true;
  }

  private updateDrag(key: string, offsetX: number, offsetY: number): void {
    if (this.dragKey !== key || !this.floating) {
      return;
    }
    this.dragX = this.baseX + offsetX;
    this.dragY = this.baseY + offsetY;
    const index: number = this.itemIndex(key);
    if (index === -1) {
      return;
    }
    const target: number = this.targetIndex();
    if (target !== index) {
      this.reorderItems(index, target);
    }
  }

  /** Upstream onChange()/handleAllModeChange(): snap the live offset onto a slot index. */
  private targetIndex(): number {
    const total: number = this.orderKeys.length;
    if (this.dragDirection() === 'vertical') {
      return this.clampIndex(Math.round(this.dragY / this.itemHeightValue()), total);
    }
    if (this.dragDirection() === 'horizontal') {
      return this.clampIndex(Math.round(this.dragX / this.itemWidthValue()), total);
    }
    const columns: number = this.columnCount();
    const column: number = Math.max(0, Math.min(Math.round(this.dragX / this.itemWidthValue()), columns - 1));
    const row: number = Math.max(0, Math.round(this.dragY / this.itemHeightValue()));
    return this.clampIndex(row * columns + column, total);
  }

  private clampIndex(value: number, total: number): number {
    return Math.max(0, Math.min(value, total - 1));
  }

  private reorderItems(fromIndex: number, toIndex: number): void {
    const next: Array<string> = this.orderKeys.slice();
    const moved: Array<string> = next.splice(fromIndex, 1);
    if (moved.length === 0) {
      return;
    }
    next.splice(toIndex, 0, moved[0]);
    this.orderKeys = next;
    this.sortChanged = true;
    if (upBoolean(this.props.vibrate, true)) {
      this.report('vibrateShort', 'light', 'haptic feedback skipped; the reorder itself still applies');
    }
  }

  private endDrag(key: string): void {
    if (this.dragKey !== key) {
      return;
    }
    this.dragX = this.dragX + 0.001;
    this.dragY = this.dragY + 0.001;
    this.snapTimerId = setTimeout((): void => {
      this.snapTimerId = -1;
      this.floating = false;
      if (this.sortChanged) {
        this.props.onDragEnd?.(this.sortedList());
        this.sortChanged = false;
      }
      this.clearTimerId = setTimeout((): void => {
        this.clearTimerId = -1;
        this.dragKey = '';
      }, 600);
    }, 50);
  }

  /** Upstream drag-end payload: the records in their new order. */
  sortedList(): Array<UPDragSortItem> {
    const sorted: Array<UPDragSortItem> = [];
    this.orderKeys.forEach((key: string): void => {
      const item: UPDragSortItem | undefined = this.itemFor(key);
      if (item !== undefined) {
        sorted.push(item);
      }
    });
    return sorted;
  }

  private useHandlerValue(): boolean {
    return upBoolean(this.props.useHandler, false);
  }

  @Builder
  private itemContent(key: string) {
    Row() {
      if (this.useHandlerValue()) {
        Row() {
          this.handlerBuilder(this.slotFor(key))
        }
        .gesture(PanGesture({ direction: this.panDirection() })
          .onActionStart((): void => this.beginDrag(key))
          .onActionUpdate((event: GestureEvent): void => this.updateDrag(key, event.offsetX, event.offsetY))
          .onActionEnd((): void => this.endDrag(key))
          .onActionCancel((): void => this.endDrag(key)))
      }
      this.itemBuilder(this.slotFor(key))
    }
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private itemRegion(key: string) {
    Row() {
      this.itemContent(key)
    }
    .width(this.dragDirection() === 'vertical' ? '100%' : undefined)
    .position({ x: this.slotOffsetX(key), y: this.slotOffsetY(key) })
    .zIndex(this.dragKey === key ? 1000 : 1)
    .shadow(this.dragKey === key
      ? { radius: 20, color: 'rgba(0, 0, 0, 0.15)', offsetY: 6 }
      : { radius: 0, color: 'rgba(0, 0, 0, 0)', offsetY: 0 })
    .opacity(this.itemDraggable(key) ? 1 : 0.6)
    .onAreaChange((_oldValue: Area, newValue: Area): void => this.captureSize(key, newValue))
    .gesture(PanGesture({ direction: this.panDirection() })
      .onActionStart((): void => {
        if (!this.useHandlerValue()) {
          this.beginDrag(key);
        }
      })
      .onActionUpdate((event: GestureEvent): void => {
        if (!this.useHandlerValue()) {
          this.updateDrag(key, event.offsetX, event.offsetY);
        }
      })
      .onActionEnd((): void => {
        if (!this.useHandlerValue()) {
          this.endDrag(key);
        }
      })
      .onActionCancel((): void => {
        if (!this.useHandlerValue()) {
          this.endDrag(key);
        }
      }))
  }

  build() {
    Stack() {
      ForEach(this.renderKeys, (key: string): void => {
        this.itemRegion(key)
      }, (key: string): string => key)
    }
    .alignContent(Alignment.TopStart)
    .width(UPStyle.parse(this.props.customStyle).width ?? this.areaWidth())
    .height(UPStyle.parse(this.props.customStyle).height ?? this.areaHeight())
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? 'transparent')
  }
}
