import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString, upValueKey } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';

/** One waterfall record. ArkTS forbids index signatures, so the fields are named. */
export interface UPWaterfallItem {
  id?: UPRawValue;
  title?: UPRawValue;
  label?: UPRawValue;
  price?: UPRawValue;
  shop?: UPRawValue;
  image?: UPRawValue;
  description?: UPRawValue;
  value?: UPRawValue;
  height?: UPRawValue;
}

/** One rendered column; mirrors an entry of the upstream columnList array. */
export interface UPWaterfallColumn {
  index: number;
  items: Array<UPWaterfallItem>;
}

export interface UPWaterfallColumnSlot {
  colIndex: number;
  colList: Array<UPWaterfallItem>;
}

export interface UPWaterfallItemSlot {
  item: UPWaterfallItem;
  itemIndex: number;
  colIndex: number;
}

/** Upstream after-add-one payload: the inserted record plus its measured column height. */
export interface UPWaterfallAddOneEvent {
  item: UPWaterfallItem;
  height: number;
  colIndex: number;
}

/** Upstream after-add-all payload. */
export interface UPWaterfallAddAllEvent {
  columnHeights: Array<number>;
  newData: Array<UPWaterfallItem>;
}

/** Read one addressable field; replaces upstream item[idKey]. */
export function upWaterfallValue(item: UPWaterfallItem, key: string): UPRawValue {
  if (key === 'id') {
    return item.id;
  }
  if (key === 'title') {
    return item.title;
  }
  if (key === 'label') {
    return item.label;
  }
  if (key === 'value') {
    return item.value;
  }
  if (key === 'price') {
    return item.price;
  }
  return undefined;
}

/** Field-wise copy; replaces the upstream JSON deep clone that ArkTS bans. */
export function upWaterfallClone(item: UPWaterfallItem): UPWaterfallItem {
  return {
    id: item.id,
    title: item.title,
    label: item.label,
    price: item.price,
    shop: item.shop,
    image: item.image,
    description: item.description,
    value: item.value,
    height: item.height
  };
}

/** Field-wise write used by modify(id, key, value). */
export function upWaterfallAssign(item: UPWaterfallItem, key: string, value: UPRawValue): UPWaterfallItem {
  const next: UPWaterfallItem = upWaterfallClone(item);
  if (key === 'id') {
    next.id = value;
  } else if (key === 'title') {
    next.title = value;
  } else if (key === 'label') {
    next.label = value;
  } else if (key === 'price') {
    next.price = value;
  } else if (key === 'shop') {
    next.shop = value;
  } else if (key === 'image') {
    next.image = value;
  } else if (key === 'description') {
    next.description = value;
  } else if (key === 'value') {
    next.value = value;
  } else if (key === 'height') {
    next.height = value;
  }
  return next;
}

/** Structural comparison; replaces the upstream JSON.stringify equality check. */
export function upWaterfallSame(left: UPWaterfallItem, right: UPWaterfallItem): boolean {
  return left.id === right.id && left.title === right.title && left.label === right.label &&
    left.price === right.price && left.shop === right.shop && left.image === right.image &&
    left.description === right.description && left.value === right.value && left.height === right.height;
}

export interface UPWaterfallOptions {
  modelValue?: Array<UPWaterfallItem>;
  addTime?: UPRawValue;
  idKey?: UPRawValue;
  columns?: UPRawValue;
  columnsMin?: UPRawValue;
  minColumnWidth?: UPRawValue;
  useColumnSlot?: UPRawValue;
  useLeftSlot?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onUpdateModelValue?: (value: Array<UPWaterfallItem>) => void;
  onInput?: (value: Array<UPWaterfallItem>) => void;
  onAfterAddOne?: (event: UPWaterfallAddOneEvent) => void;
  onAfterAddAll?: (event: UPWaterfallAddAllEvent) => void;
}

export class UPWaterfallProps {
  modelValue: Array<UPWaterfallItem> = [];
  addTime: UPRawValue = 200;
  idKey: UPRawValue = 'id';
  columns: UPRawValue = 2;
  columnsMin: UPRawValue = 2;
  minColumnWidth: UPRawValue = 230;
  useColumnSlot: UPRawValue = false;
  useLeftSlot: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onUpdateModelValue?: (value: Array<UPWaterfallItem>) => void;
  onInput?: (value: Array<UPWaterfallItem>) => void;
  onAfterAddOne?: (event: UPWaterfallAddOneEvent) => void;
  onAfterAddAll?: (event: UPWaterfallAddAllEvent) => void;

  constructor(options?: UPWaterfallOptions) {
    if (options === undefined) {
      return;
    }
    this.modelValue = options.modelValue ?? this.modelValue;
    this.addTime = options.addTime ?? this.addTime;
    this.idKey = options.idKey ?? this.idKey;
    this.columns = options.columns ?? this.columns;
    this.columnsMin = options.columnsMin ?? this.columnsMin;
    this.minColumnWidth = options.minColumnWidth ?? this.minColumnWidth;
    this.useColumnSlot = options.useColumnSlot ?? this.useColumnSlot;
    this.useLeftSlot = options.useLeftSlot ?? this.useLeftSlot;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onUpdateModelValue = options.onUpdateModelValue;
    this.onInput = options.onInput;
    this.onAfterAddOne = options.onAfterAddOne;
    this.onAfterAddAll = options.onAfterAddAll;
  }
}

@Component
export struct UPWaterfall {
  @Prop @Watch('syncModelValue') props: UPWaterfallProps = new UPWaterfallProps();
  @State private columnData: Array<UPWaterfallColumn> = [];
  private measuredWidth: number = 375;
  private columnHeights: Array<number> = [];
  private appliedData: Array<UPWaterfallItem> = [];
  private queue: Array<UPWaterfallItem> = [];
  private batchData: Array<UPWaterfallItem> = [];
  private generation: number = 0;
  private timerId: number = -1;

  @Builder
  private defaultItem(slot: UPWaterfallItemSlot) {
    Column({ space: 4 }) {
      Text(upValueKey(slot.item.title ?? slot.item.label ?? slot.item.id ?? slot.itemIndex))
        .fontSize(14)
        .fontColor(UPColor.adaptive('#303133', 'main-color'))
      if (slot.item.price !== undefined && slot.item.price !== null) {
        Text(upValueKey(slot.item.price) + '元').fontSize(13).fontColor('#fa3534')
      }
      if (slot.item.shop !== undefined && slot.item.shop !== null) {
        Text(upValueKey(slot.item.shop)).fontSize(12).fontColor(UPColor.adaptive('#909399', 'tips-color'))
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .margin({ bottom: 8 })
    .borderRadius(8)
    .backgroundColor('#f8f8f8')
  }

  @BuilderParam itemBuilder: (slot: UPWaterfallItemSlot) => void = this.defaultItem;

  @Builder
  private defaultColumn(slot: UPWaterfallColumnSlot) {
    Column() {
      ForEach(this.itemSlots(slot), (itemSlot: UPWaterfallItemSlot): void => {
        this.itemBuilder(itemSlot)
      }, (itemSlot: UPWaterfallItemSlot): string => this.itemKey(itemSlot))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @BuilderParam columnBuilder: (slot: UPWaterfallColumnSlot) => void = this.defaultColumn;

  @Builder
  private defaultLeft(slot: UPWaterfallColumnSlot) {
    this.defaultColumn(slot)
  }

  @BuilderParam leftBuilder: (slot: UPWaterfallColumnSlot) => void = this.defaultLeft;

  aboutToAppear(): void {
    this.initColumnList();
    this.syncModelValue();
  }

  aboutToDisappear(): void {
    this.generation += 1;
    this.stopTimer();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
  }

  private addTimeValue(): number {
    const value: number = upNumber(this.props.addTime, 200);
    return value >= 0 ? value : 200;
  }

  private idKeyValue(): string {
    return upString(this.props.idKey, 'id');
  }

  private autoColumns(): boolean {
    return upString(this.props.columns, '2').toLowerCase() === 'auto';
  }

  /** Upstream getColumnsCount(); auto mode measures the container instead of the window. */
  private columnsCount(): number {
    const minimum: number = Math.max(1, Math.floor(upNumber(this.props.columnsMin, 2)));
    if (!this.autoColumns()) {
      const fixed: number = Math.floor(upNumber(this.props.columns, 2));
      return fixed > 0 ? fixed : 2;
    }
    const gap: number = 7;
    const minWidth: number = Math.max(1, UPUnit.parse(this.props.minColumnWidth, 375, 230));
    const count: number = Math.max(1, Math.floor(this.measuredWidth / (minWidth + gap)));
    return count < minimum ? minimum : count;
  }

  private initColumnList(): void {
    const count: number = this.columnsCount();
    const columns: Array<UPWaterfallColumn> = [];
    const heights: Array<number> = [];
    for (let index = 0; index < count; index += 1) {
      columns.push({ index, items: [] });
      heights.push(0);
    }
    this.columnData = columns;
    this.columnHeights = heights;
  }

  private itemSlots(slot: UPWaterfallColumnSlot): Array<UPWaterfallItemSlot> {
    return slot.colList.map((item: UPWaterfallItem, itemIndex: number): UPWaterfallItemSlot =>
      ({ item, itemIndex, colIndex: slot.colIndex }));
  }

  private itemKey(slot: UPWaterfallItemSlot): string {
    const raw: UPRawValue = upWaterfallValue(slot.item, this.idKeyValue());
    return raw === undefined || raw === null
      ? String(slot.colIndex) + '-' + String(slot.itemIndex)
      : upValueKey(raw);
  }

  private columnKey(column: UPWaterfallColumn): string {
    return String(column.index) + '-' + String(column.items.length);
  }

  private columnSlot(column: UPWaterfallColumn): UPWaterfallColumnSlot {
    return { colIndex: column.index, colList: column.items };
  }

  private setColumnHeight(index: number, value: number): void {
    if (index < 0 || index >= this.columnHeights.length) {
      return;
    }
    this.columnHeights[index] = value;
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

  /** Upstream getMinHeightColumnIndex(): shortest column, ties broken by item count. */
  private minHeightColumnIndex(): number {
    let minIndex: number = 0;
    for (let index = 1; index < this.columnData.length; index += 1) {
      const current: number = this.columnHeights[index] ?? 0;
      const minimum: number = this.columnHeights[minIndex] ?? 0;
      if (current < minimum) {
        minIndex = index;
      } else if (current === minimum &&
        this.columnData[index].items.length < this.columnData[minIndex].items.length) {
        minIndex = index;
      }
    }
    return minIndex;
  }

  private appendItem(colIndex: number, item: UPWaterfallItem): void {
    this.columnData = this.columnData.map((column: UPWaterfallColumn): UPWaterfallColumn => {
      if (column.index !== colIndex) {
        return { index: column.index, items: column.items };
      }
      const items: Array<UPWaterfallItem> = column.items.slice();
      items.push(item);
      return { index: column.index, items };
    });
  }

  /** Upstream isPureAppend(): the new array only grows at the tail. */
  private isPureAppend(newData: Array<UPWaterfallItem>, oldData: Array<UPWaterfallItem>): boolean {
    if (oldData.length === 0) {
      return true;
    }
    if (newData.length < oldData.length) {
      return false;
    }
    for (let index = 0; index < oldData.length; index += 1) {
      if (!upWaterfallSame(oldData[index], newData[index])) {
        return false;
      }
    }
    return true;
  }

  private syncModelValue(): void {
    const incoming: Array<UPWaterfallItem> = this.props.modelValue.map(
      (item: UPWaterfallItem): UPWaterfallItem => upWaterfallClone(item));
    if (incoming.length === 0) {
      this.appliedData = [];
      this.clear(false);
      return;
    }
    if (this.columnData.length !== this.columnsCount()) {
      this.appliedData = incoming;
      this.redistribute(incoming);
      return;
    }
    if (!this.isPureAppend(incoming, this.appliedData)) {
      this.appliedData = incoming;
      this.redistribute(incoming);
      return;
    }
    const startIndex: number = this.appliedData.length;
    this.appliedData = incoming;
    this.enqueue(incoming.slice(startIndex));
  }

  /** Upstream redistributeData(): drop the layout and re-run the whole distribution. */
  private redistribute(data: Array<UPWaterfallItem>): void {
    this.generation += 1;
    this.stopTimer();
    this.queue = [];
    this.initColumnList();
    this.enqueue(data);
  }

  private enqueue(data: Array<UPWaterfallItem>): void {
    if (data.length === 0) {
      return;
    }
    data.forEach((item: UPWaterfallItem): void => {
      this.queue.push(item);
    });
    if (this.timerId < 0) {
      this.batchData = [];
      this.step(this.generation);
    }
  }

  private step(generation: number): void {
    if (generation !== this.generation) {
      return;
    }
    const item: UPWaterfallItem | undefined = this.queue.shift();
    if (item === undefined) {
      this.timerId = -1;
      this.props.onAfterAddAll?.({ columnHeights: this.columnHeights.slice(), newData: this.batchData.slice() });
      this.batchData = [];
      return;
    }
    const colIndex: number = this.minHeightColumnIndex();
    this.appendItem(colIndex, item);
    this.batchData.push(item);
    this.timerId = setTimeout((): void => {
      this.timerId = -1;
      if (generation !== this.generation) {
        return;
      }
      const height: number = this.columnHeights[colIndex] ?? 0;
      if (height > 0) {
        this.props.onAfterAddOne?.({ item, height, colIndex });
      }
      this.step(generation);
    }, this.addTimeValue());
  }

  /** Upstream clear(bak): reset the layout and optionally empty the bound data. */
  clear(bak: boolean = true): void {
    this.generation += 1;
    this.stopTimer();
    this.queue = [];
    this.batchData = [];
    this.initColumnList();
    if (bak) {
      this.appliedData = [];
      this.props.onUpdateModelValue?.([]);
      this.props.onInput?.([]);
    }
  }

  /** Upstream remove(id). */
  remove(id: UPRawValue): void {
    const key: string = this.idKeyValue();
    let removed: boolean = false;
    this.columnData = this.columnData.map((column: UPWaterfallColumn): UPWaterfallColumn => {
      if (removed) {
        return { index: column.index, items: column.items };
      }
      const items: Array<UPWaterfallItem> = column.items.filter((item: UPWaterfallItem): boolean =>
        upValueKey(upWaterfallValue(item, key)) !== upValueKey(id));
      if (items.length !== column.items.length) {
        removed = true;
      }
      return { index: column.index, items };
    });
    if (!removed) {
      this.diagnostics().report('UPWaterfall', 'remove', id, 'no record matched the requested id');
      return;
    }
    const next: Array<UPWaterfallItem> = this.appliedData.filter((item: UPWaterfallItem): boolean =>
      upValueKey(upWaterfallValue(item, key)) !== upValueKey(id));
    this.appliedData = next;
    this.props.onUpdateModelValue?.(next);
    this.props.onInput?.(next);
  }

  /** Upstream modify(id, key, value). */
  modify(id: UPRawValue, key: string, value: UPRawValue): void {
    const idKey: string = this.idKeyValue();
    let found: boolean = false;
    this.columnData = this.columnData.map((column: UPWaterfallColumn): UPWaterfallColumn => {
      const items: Array<UPWaterfallItem> = column.items.map((item: UPWaterfallItem): UPWaterfallItem => {
        if (upValueKey(upWaterfallValue(item, idKey)) !== upValueKey(id)) {
          return item;
        }
        found = true;
        return upWaterfallAssign(item, key, value);
      });
      return { index: column.index, items };
    });
    if (!found) {
      this.diagnostics().report('UPWaterfall', 'modify', id, 'no record matched the requested id');
      return;
    }
    const next: Array<UPWaterfallItem> = this.appliedData.map((item: UPWaterfallItem): UPWaterfallItem =>
      upValueKey(upWaterfallValue(item, idKey)) === upValueKey(id) ? upWaterfallAssign(item, key, value) : item);
    this.appliedData = next;
    this.props.onUpdateModelValue?.(next);
    this.props.onInput?.(next);
  }

  private useColumnSlotValue(): boolean {
    return upBoolean(this.props.useColumnSlot, false);
  }

  /** 上游 left 与 column 同为整列插槽，useLeftSlot 决定走哪一个。/ left mirrors column per upstream. */
  private useLeftSlotValue(): boolean {
    return upBoolean(this.props.useLeftSlot, false);
  }

  @Builder
  private columnRegion(column: UPWaterfallColumn) {
    Column() {
      if (this.useColumnSlotValue()) {
        this.columnBuilder(this.columnSlot(column))
      } else if (this.useLeftSlotValue()) {
        this.leftBuilder(this.columnSlot(column))
      } else {
        this.defaultColumn(this.columnSlot(column))
      }
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .clip(true)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.setColumnHeight(column.index, this.measure(newValue.height));
    })
  }

  build() {
    Row({ space: 7 }) {
      ForEach(this.columnData, (column: UPWaterfallColumn): void => {
        this.columnRegion(column)
      }, (column: UPWaterfallColumn): string => this.columnKey(column))
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .alignItems(VerticalAlign.Top)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? 'transparent')
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      const width: number = this.measure(newValue.width);
      if (width > 0 && Math.abs(width - this.measuredWidth) >= 1) {
        this.measuredWidth = width;
        if (this.autoColumns() && this.columnData.length !== this.columnsCount()) {
          this.redistribute(this.appliedData);
        }
      }
    })
  }
}
