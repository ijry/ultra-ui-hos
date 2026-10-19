import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upString, upValueKey } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPNumberBox, UPNumberBoxChangeEvent, UPNumberBoxProps } from './UPNumberBox';
import { UPButton, UPButtonProps } from './UPButton';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPI18n } from '../core/UPI18n';
import { UPColor } from '../core/UPColor';

/** 上游 maxBuy 默认值。/ Upstream maxBuy default. */
export const UP_GOODS_SKU_MAX_BUY: number = 999;

/** 上游头图 180rpx 换算成 vp。/ Upstream 180rpx header image in vp. */
export const UP_GOODS_SKU_IMAGE_SIZE: number = 90;

/** 上游 scroll-view 的 max-height 600rpx 换算成 vp。/ Upstream 600rpx scroll cap in vp. */
export const UP_GOODS_SKU_CONTENT_MAX_HEIGHT: number = 300;

/** 上游 --up-error 主色，价格与选中态复用。/ Upstream error color used by price and active option. */
export const UP_GOODS_SKU_ERROR_COLOR: string = '#fa3534';

/**
 * 上游 skuList 元素是扁平对象，维度键与这些字段同名时会互相覆盖。
 * Upstream sku combinations are flat objects, so these field names cannot double as dimension keys.
 */
export const UP_GOODS_SKU_RESERVED_KEYS: Array<string> = ['price', 'price_fee', 'stock', 'quantity'];

/** 单个规格值，对应上游 treeItem.children 元素。/ One sku leaf. */
export interface UPGoodsSkuLeaf {
  id: UPRawValue;
  name: UPRawValue;
}

/** 一个规格维度，对应上游 skuTree 元素。/ One sku dimension. */
export interface UPGoodsSkuTreeItem {
  label?: UPRawValue;
  name: string;
  children?: Array<UPGoodsSkuLeaf>;
}

/** 一次维度选择，替代上游 selectedSku 的对象键。/ One dimension choice replacing the upstream object key. */
export interface UPGoodsSkuSelection {
  name: string;
  id: UPRawValue;
}

/**
 * 一条 SKU 组合。ArkTS 没有索引签名，所以维度值集中放在 values 里，
 * 而不是上游那种 sku[key] 的扁平写法。
 * One sku combination; dimension values live in values because ArkTS has no index signatures.
 */
export interface UPGoodsSkuCombination {
  values: Array<UPGoodsSkuSelection>;
  price?: UPRawValue;
  price_fee?: UPRawValue;
  stock?: UPRawValue;
  quantity?: UPRawValue;
}

/** 商品信息，对应上游 goodsInfo。/ Goods payload mirroring upstream goodsInfo. */
export interface UPGoodsSkuInfo {
  image?: UPRawValue;
  picture?: UPRawValue;
  title?: UPRawValue;
  price?: UPRawValue;
  price_fee?: UPRawValue;
  stock?: UPRawValue;
  quantity?: UPRawValue;
}

/** confirm 事件载荷，字段与上游 $emit('confirm', ...) 一致。/ Confirm payload mirroring upstream. */
export interface UPGoodsSkuConfirmEvent {
  sku: UPGoodsSkuCombination | null;
  goodsInfo: UPGoodsSkuInfo;
  num: number;
  selectedText: string;
}

/** 渲染一个规格按钮所需的全部信息。/ Everything needed to render one option chip. */
export interface UPGoodsSkuChoice {
  name: string;
  id: UPRawValue;
  label: string;
  selected: boolean;
  disabled: boolean;
}

/** 上游 `a || b` 的真值判定：0、空串、false、null、undefined 都算假。/ Upstream `||` falsiness. */
function upGoodsSkuTruthy(value: UPRawValue): boolean {
  if (value === null || value === undefined) {
    return false;
  }
  if (typeof value === 'number') {
    return value !== 0 && !Number.isNaN(value);
  }
  if (typeof value === 'string') {
    return value.length > 0;
  }
  return value === true;
}

/** 模板插值口径：null/undefined 渲染成空串，其余走 String()。/ Template interpolation. */
function upGoodsSkuText(value: UPRawValue): string {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value);
}

/** 数值比较口径：兼容 '10' 这类数字字符串，对应上游 JS 的隐式转换。/ Numeric coercion. */
function upGoodsSkuNumber(value: UPRawValue, fallback: number = 0): number {
  if (typeof value === 'number') {
    return Number.isFinite(value) ? value : fallback;
  }
  if (typeof value === 'string') {
    const parsed: number = Number.parseFloat(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}

/**
 * 取某个维度在该组合里的值，等价于上游的 sku[key]。
 * Reads one dimension value from a combination, mirroring upstream sku[key].
 */
export function upGoodsSkuValueOf(combination: UPGoodsSkuCombination, name: string): UPRawValue {
  const values: Array<UPGoodsSkuSelection> = combination.values ?? [];
  for (let index: number = 0; index < values.length; index++) {
    if (values[index].name === name) {
      return values[index].id;
    }
  }
  return undefined;
}

/**
 * 维度键是否可用：空串与 price/price_fee/stock/quantity 在上游的扁平结构里会被覆盖。
 * Reports whether a dimension key survives the upstream flat sku object.
 */
export function upGoodsSkuKeySupported(name: string): boolean {
  if (name.length === 0) {
    return false;
  }
  for (let index: number = 0; index < UP_GOODS_SKU_RESERVED_KEYS.length; index++) {
    if (UP_GOODS_SKU_RESERVED_KEYS[index] === name) {
      return false;
    }
  }
  return true;
}

/** 上游 price 计算属性：组合优先，其次商品信息，最后 0。/ Mirrors upstream price(). */
export function upGoodsSkuPrice(combination: UPGoodsSkuCombination | null, info: UPGoodsSkuInfo | null): string {
  if (combination !== null && combination !== undefined) {
    if (upGoodsSkuTruthy(combination.price)) {
      return upGoodsSkuText(combination.price);
    }
    return upGoodsSkuText(combination.price_fee);
  }
  if (info === null || info === undefined) {
    return '0';
  }
  if (upGoodsSkuTruthy(info.price)) {
    return upGoodsSkuText(info.price);
  }
  if (upGoodsSkuTruthy(info.price_fee)) {
    return upGoodsSkuText(info.price_fee);
  }
  return '0';
}

/** 上游 stock 计算属性：组合优先，其次商品信息，最后 0。/ Mirrors upstream stock(). */
export function upGoodsSkuStock(combination: UPGoodsSkuCombination | null, info: UPGoodsSkuInfo | null): number {
  if (combination !== null && combination !== undefined) {
    if (upGoodsSkuTruthy(combination.stock)) {
      return upGoodsSkuNumber(combination.stock, 0);
    }
    return upGoodsSkuNumber(combination.quantity, 0);
  }
  if (info === null || info === undefined) {
    return 0;
  }
  if (upGoodsSkuTruthy(info.stock)) {
    return upGoodsSkuNumber(info.stock, 0);
  }
  if (upGoodsSkuTruthy(info.quantity)) {
    return upGoodsSkuNumber(info.quantity, 0);
  }
  return 0;
}

/**
 * 在 skuList 里找第一条满足全部已选维度的组合，等价于上游 getSkuComb() 的匹配循环。
 * Finds the first combination matching every active selection, mirroring the upstream match loop.
 */
export function upGoodsSkuMatch(list: Array<UPGoodsSkuCombination>,
                                selections: Array<UPGoodsSkuSelection>): UPGoodsSkuCombination | null {
  for (let index: number = 0; index < list.length; index++) {
    const combination: UPGoodsSkuCombination = list[index];
    let matched: boolean = true;
    for (let cursor: number = 0; cursor < selections.length; cursor++) {
      const selection: UPGoodsSkuSelection = selections[cursor];
      if (upValueKey(upGoodsSkuValueOf(combination, selection.name)) !== upValueKey(selection.id)) {
        matched = false;
        break;
      }
    }
    if (matched) {
      return combination;
    }
  }
  return null;
}

/** 只渲染本地图片，远端地址一律占位。/ Only local image sources are rendered. */
export function isLocalGoodsSkuSource(value: string): boolean {
  return value.startsWith('resource://') || value.startsWith('file://')
    || value.startsWith('/') || value.startsWith('$rawfile:');
}

export interface UPGoodsSkuOptions {
  goodsInfo?: UPGoodsSkuInfo;
  skuTree?: Array<UPGoodsSkuTreeItem>;
  skuList?: Array<UPGoodsSkuCombination>;
  maxBuy?: UPRawValue;
  confirmText?: UPRawValue;
  closeable?: UPRawValue;
  pageInline?: UPRawValue;
  show?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onOpen?: () => void;
  onConfirm?: (event: UPGoodsSkuConfirmEvent) => void;
  onClose?: () => void;
  onClosed?: () => void;
  headerBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
}

export class UPGoodsSkuProps {
  goodsInfo: UPGoodsSkuInfo = {};
  skuTree: Array<UPGoodsSkuTreeItem> = [];
  skuList: Array<UPGoodsSkuCombination> = [];
  maxBuy: UPRawValue = UP_GOODS_SKU_MAX_BUY;
  confirmText: UPRawValue = UPI18n.t('up.common.confirm');
  closeable: UPRawValue = true;
  pageInline: UPRawValue = false;
  show: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onOpen?: () => void;
  onConfirm?: (event: UPGoodsSkuConfirmEvent) => void;
  onClose?: () => void;
  onClosed?: () => void;
  headerBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;

  constructor(options?: UPGoodsSkuOptions) {
    if (options === undefined) {
      return;
    }
    this.goodsInfo = options.goodsInfo ?? this.goodsInfo;
    this.skuTree = options.skuTree ?? this.skuTree;
    this.skuList = options.skuList ?? this.skuList;
    this.maxBuy = options.maxBuy ?? this.maxBuy;
    this.confirmText = options.confirmText ?? this.confirmText;
    this.closeable = options.closeable ?? this.closeable;
    this.pageInline = options.pageInline ?? this.pageInline;
    this.show = options.show ?? this.show;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onOpen = options.onOpen;
    this.onConfirm = options.onConfirm;
    this.onClose = options.onClose;
    this.onClosed = options.onClosed;
    this.headerBuilder = options.headerBuilder;
    this.triggerBuilder = options.triggerBuilder;
  }
}

@Component
export struct UPGoodsSku {
  @Prop @Watch('applyProps') props: UPGoodsSkuProps = new UPGoodsSkuProps();
  @State private selectedSku: Array<UPGoodsSkuSelection> = [];
  @State private buyNum: number = 1;

  private appliedShow: boolean = false;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    diagnostics.report('UPGoodsSku', 'trigger', 'slot',
      'the upstream trigger slot is replaced by the controlled show property');
    diagnostics.report('UPGoodsSku', 'header', 'slot',
      'the upstream header slot is not portable; the built-in image plus price header is always rendered');
    diagnostics.report('UPGoodsSku', 'borderRadius', 'no-op',
      'up-popup has no border-radius prop upstream so the hard-coded 20 is a no-op; pass customStyle borderRadius to round the panel');
    diagnostics.report('UPGoodsSku', 'skuList', 'values',
      'ArkTS has no index signatures so every combination carries values: Array<UPGoodsSkuSelection> instead of flat sku[key] fields');
    diagnostics.report('UPGoodsSku', 'close', 'no-op',
      'upstream close() assigns this.false = true which is a no-op; the port only emits close and closed');
    diagnostics.report('UPGoodsSku', 'reset', 'method',
      'the imperative reset() method is not exposed; toggle show or replace skuTree to clear the selection');
    diagnostics.report('UPGoodsSku', 'scrollView', 'Scroll',
      'the 600rpx max-height scroll-view is approximated with Scroll plus constraintSize maxHeight');
    this.appliedShow = this.panelVisible();
    this.reportInputs();
  }

  /** show 由 false 变 true 时补发 open，等价于上游 open() 里的 $emit。/ Emits open on the false to true edge. */
  private applyProps(): void {
    const next: boolean = this.panelVisible();
    if (next && !this.appliedShow) {
      this.props.onOpen?.();
    }
    this.appliedShow = next;
  }

  private reportInputs(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    const tree: Array<UPGoodsSkuTreeItem> = this.treeList();
    for (let index: number = 0; index < tree.length; index++) {
      if (!upGoodsSkuKeySupported(tree[index].name)) {
        diagnostics.report('UPGoodsSku', 'skuTree', tree[index].name,
          'dimension names must be non-empty and must not collide with price/price_fee/stock/quantity');
      }
    }
    const source: string = this.imageSource();
    if (source.length > 0 && !isLocalGoodsSkuSource(source)) {
      diagnostics.report('UPGoodsSku', 'goodsInfo.image', source,
        'only local sources are rendered; remote images stay a placeholder');
    }
  }

  private panelVisible(): boolean {
    return upBoolean(this.props.pageInline, false) || upBoolean(this.props.show, false);
  }

  private treeList(): Array<UPGoodsSkuTreeItem> {
    return this.props.skuTree ?? [];
  }

  private combinationList(): Array<UPGoodsSkuCombination> {
    return this.props.skuList ?? [];
  }

  private info(): UPGoodsSkuInfo {
    return this.props.goodsInfo ?? {};
  }

  private imageSource(): string {
    const image: string = upString(this.info().image, '');
    if (image.length > 0) {
      return image;
    }
    return upString(this.info().picture, '');
  }

  /** 上游 selectedSku 用 '' 表示取消，这里同样保留占位以维持文案顺序。/ Keeps '' placeholders like upstream. */
  private activeSelections(selections: Array<UPGoodsSkuSelection>): Array<UPGoodsSkuSelection> {
    const result: Array<UPGoodsSkuSelection> = [];
    for (let index: number = 0; index < selections.length; index++) {
      if (upGoodsSkuTruthy(selections[index].id)) {
        result.push(selections[index]);
      }
    }
    return result;
  }

  /** 等价于上游的 { ...selectedSku, [key]: id }。/ Mirrors the upstream object spread. */
  private selectionsWith(name: string, id: UPRawValue): Array<UPGoodsSkuSelection> {
    const result: Array<UPGoodsSkuSelection> = [];
    let replaced: boolean = false;
    for (let index: number = 0; index < this.selectedSku.length; index++) {
      const item: UPGoodsSkuSelection = this.selectedSku[index];
      if (item.name === name) {
        result.push({ name: name, id: id });
        replaced = true;
      } else {
        result.push({ name: item.name, id: item.id });
      }
    }
    if (!replaced) {
      result.push({ name: name, id: id });
    }
    return result;
  }

  /** 上游 getSkuComb()：先剔空值，维度数不足直接返回 null。/ Mirrors upstream getSkuComb(). */
  private combinationOf(selections: Array<UPGoodsSkuSelection>): UPGoodsSkuCombination | null {
    const active: Array<UPGoodsSkuSelection> = this.activeSelections(selections);
    if (active.length !== this.treeList().length) {
      return null;
    }
    return upGoodsSkuMatch(this.combinationList(), active);
  }

  private combination(): UPGoodsSkuCombination | null {
    return this.combinationOf(this.selectedSku);
  }

  private priceText(): string {
    return upGoodsSkuPrice(this.combination(), this.info());
  }

  private stockValue(): number {
    return upGoodsSkuStock(this.combination(), this.info());
  }

  private maxBuyValue(): number {
    return upGoodsSkuNumber(this.props.maxBuy, UP_GOODS_SKU_MAX_BUY);
  }

  /** 上游 maxBuyNum 计算属性。/ Mirrors upstream maxBuyNum(). */
  private maxBuyNum(): number {
    const stock: number = this.stockValue();
    return stock > this.maxBuyValue() ? this.maxBuyValue() : stock;
  }

  /** 上游 canBuy 用 `!== ''` 计数，这里保持一致。/ Upstream counts keys whose value is not ''. */
  private chosenCount(): number {
    let count: number = 0;
    for (let index: number = 0; index < this.selectedSku.length; index++) {
      if (upValueKey(this.selectedSku[index].id) !== '') {
        count++;
      }
    }
    return count;
  }

  private canBuy(): boolean {
    return this.chosenCount() === this.treeList().length && this.buyNum > 0 && this.stockValue() > 0;
  }

  /** 上游 selectedSkuText 计算属性。/ Mirrors upstream selectedSkuText(). */
  private selectedText(): string {
    const parts: Array<string> = [];
    const tree: Array<UPGoodsSkuTreeItem> = this.treeList();
    for (let index: number = 0; index < this.selectedSku.length; index++) {
      const selection: UPGoodsSkuSelection = this.selectedSku[index];
      if (!upGoodsSkuTruthy(selection.id)) {
        continue;
      }
      for (let treeIndex: number = 0; treeIndex < tree.length; treeIndex++) {
        if (tree[treeIndex].name !== selection.name) {
          continue;
        }
        const children: Array<UPGoodsSkuLeaf> = tree[treeIndex].children ?? [];
        for (let leafIndex: number = 0; leafIndex < children.length; leafIndex++) {
          if (upValueKey(children[leafIndex].id) === upValueKey(selection.id)) {
            parts.push(upGoodsSkuText(children[leafIndex].name));
          }
        }
      }
    }
    return parts.join(', ');
  }

  private isSelected(name: string, id: UPRawValue): boolean {
    for (let index: number = 0; index < this.selectedSku.length; index++) {
      if (this.selectedSku[index].name === name) {
        return upValueKey(this.selectedSku[index].id) === upValueKey(id);
      }
    }
    return false;
  }

  /**
   * 上游 isDisabled() 分两支：维度选满时判组合是否存在，否则扫 skuList 找可行组合。
   * 剔空后两支都等价于「不存在匹配组合」，这里合并成一次匹配。
   * Both upstream branches reduce to the same predicate once empty values are dropped.
   */
  private isDisabled(name: string, id: UPRawValue): boolean {
    const active: Array<UPGoodsSkuSelection> = this.activeSelections(this.selectionsWith(name, id));
    return upGoodsSkuMatch(this.combinationList(), active) === null;
  }

  /** 上游 onSkuClick()：禁用直接返回，已选则取消。/ Mirrors upstream onSkuClick(). */
  private chooseSku(name: string, id: UPRawValue): void {
    if (this.isDisabled(name, id)) {
      return;
    }
    if (this.isSelected(name, id)) {
      this.selectedSku = this.selectionsWith(name, '');
    } else {
      this.selectedSku = this.selectionsWith(name, id);
    }
  }

  private changeNum(event: UPNumberBoxChangeEvent): void {
    this.buyNum = event.value;
  }

  /** 上游 onConfirm()：不可购买时静默返回。/ Mirrors upstream onConfirm(). */
  private confirm(): void {
    if (!this.canBuy()) {
      return;
    }
    const event: UPGoodsSkuConfirmEvent = {
      sku: this.combination(),
      goodsInfo: this.info(),
      num: this.buyNum,
      selectedText: this.selectedText()
    };
    this.props.onConfirm?.(event);
  }

  private close(): void {
    this.props.onClose?.();
    this.props.onClosed?.();
  }

  /** 触发插槽点击等价于上游 open()：面板显隐仍由宿主的 show 决定。/ The trigger slot mirrors upstream open(). */
  private openByTrigger(): void {
    this.props.onOpen?.();
  }

  private closeIconVisible(): boolean {
    return !upBoolean(this.props.pageInline, false) && upBoolean(this.props.closeable, true);
  }

  private confirmLabel(): string {
    return upString(this.props.confirmText, '确定');
  }

  private panelColor(): string {
    return UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff';
  }

  private panelRadius(): number {
    return UPStyle.parse(this.props.customStyle).borderRadius ?? 0;
  }

  private containerPadding(): number {
    return upBoolean(this.props.pageInline, false) ? 0 : 15;
  }

  private containerPaddingTop(): number {
    return upBoolean(this.props.pageInline, false) ? 0 : 2;
  }

  private treeIndexes(): Array<number> {
    const result: Array<number> = [];
    const tree: Array<UPGoodsSkuTreeItem> = this.treeList();
    for (let index: number = 0; index < tree.length; index++) {
      result.push(index);
    }
    return result;
  }

  private groupLabel(treeIndex: number): string {
    const tree: Array<UPGoodsSkuTreeItem> = this.treeList();
    if (treeIndex < 0 || treeIndex >= tree.length) {
      return '';
    }
    return upGoodsSkuText(tree[treeIndex].label);
  }

  private groupChoices(treeIndex: number): Array<UPGoodsSkuChoice> {
    const result: Array<UPGoodsSkuChoice> = [];
    const tree: Array<UPGoodsSkuTreeItem> = this.treeList();
    if (treeIndex < 0 || treeIndex >= tree.length) {
      return result;
    }
    const item: UPGoodsSkuTreeItem = tree[treeIndex];
    const children: Array<UPGoodsSkuLeaf> = item.children ?? [];
    for (let index: number = 0; index < children.length; index++) {
      result.push({
        name: item.name,
        id: children[index].id,
        label: upGoodsSkuText(children[index].name),
        selected: this.isSelected(item.name, children[index].id),
        disabled: this.isDisabled(item.name, children[index].id)
      });
    }
    return result;
  }

  /** ForEach 用内容键，保证选中态变化后分组重绘。/ Content key so groups repaint on selection change. */
  private selectionKey(): string {
    const parts: Array<string> = [];
    for (let index: number = 0; index < this.selectedSku.length; index++) {
      parts.push(`${this.selectedSku[index].name}=${upValueKey(this.selectedSku[index].id)}`);
    }
    return parts.join('|');
  }

  private optionColor(choice: UPGoodsSkuChoice): string {
    if (choice.disabled) {
      return '#cccccc';
    }
    return choice.selected ? UP_GOODS_SKU_ERROR_COLOR : '#333333';
  }

  private optionBorderColor(choice: UPGoodsSkuChoice): string {
    return choice.selected && !choice.disabled ? UP_GOODS_SKU_ERROR_COLOR : '#eeeeee';
  }

  @Builder
  private headerImage() {
    if (isLocalGoodsSkuSource(this.imageSource())) {
      Image(this.imageSource())
        .width(UP_GOODS_SKU_IMAGE_SIZE)
        .height(UP_GOODS_SKU_IMAGE_SIZE)
        .borderRadius(5)
        .objectFit(ImageFit.Cover)
        .margin({ right: 10 })
    } else {
      Column() {
        Text('图片占位')
          .fontSize(12)
          .fontColor(UPColor.adaptive('#c0c4cc', 'light-color'))
      }
      .width(UP_GOODS_SKU_IMAGE_SIZE)
      .height(UP_GOODS_SKU_IMAGE_SIZE)
      .borderRadius(5)
      .backgroundColor('#f7f8fa')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 10 })
    }
  }

  @Builder
  private header() {
    Row() {
      this.headerImage()
      Column() {
        Row() {
          Text('¥')
            .fontSize(12)
            .fontColor(UP_GOODS_SKU_ERROR_COLOR)
            .margin({ right: 2 })
          Text(this.priceText())
            .fontSize(18)
            .fontColor(UP_GOODS_SKU_ERROR_COLOR)
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({ bottom: 10 })
        Text(`库存 ${this.stockValue()} 件`)
          .fontSize(13)
          .fontColor('#999999')
          .margin({ bottom: 10 })
        Text(`已选: ${this.selectedText()}`)
          .fontSize(13)
          .fontColor('#333333')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: 15, bottom: 15 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private option(choice: UPGoodsSkuChoice) {
    Text(choice.label)
      .fontSize(13)
      .fontColor(this.optionColor(choice))
      .padding({ top: 5, bottom: 5, left: 10, right: 10 })
      .border({ width: 1, color: this.optionBorderColor(choice), style: BorderStyle.Solid })
      .borderRadius(5)
      .margin({ right: 10, bottom: 10 })
      .onClick((): void => this.chooseSku(choice.name, choice.id))
  }

  @Builder
  private group(treeIndex: number) {
    Column() {
      Text(this.groupLabel(treeIndex))
        .fontSize(14)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 10 })
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
        ForEach(this.groupChoices(treeIndex), (choice: UPGoodsSkuChoice) => {
          this.option(choice)
        }, (choice: UPGoodsSkuChoice, index: number): string =>
          `${index}:${upValueKey(choice.id)}:${choice.selected}:${choice.disabled}`)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 15 })
  }

  @Builder
  private countRow() {
    Row() {
      Text(UPI18n.t('up.goodsSku.buyAmount'))
        .fontSize(14)
        .fontColor('#333333')
      UPNumberBox({ props: new UPNumberBoxProps({
        modelValue: this.buyNum,
        min: 1,
        max: this.maxBuyNum(),
        disabled: !this.canBuy(),
        onChange: (event: UPNumberBoxChangeEvent): void => this.changeNum(event)
      }) })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .margin({ top: 10 })
  }

  @Builder
  private footer() {
    Column() {
      UPButton({ props: new UPButtonProps({
        type: 'primary',
        disabled: !this.canBuy(),
        text: this.confirmLabel(),
        onClick: (): void => this.confirm()
      }) })
    }
    .width('100%')
    .padding({ top: 10, bottom: 20 })
  }

  @Builder
  private panel() {
    Column() {
      if (this.closeIconVisible()) {
        Text('×')
          .fontSize(24)
          .fontColor('#666666')
          .width('100%')
          .textAlign(TextAlign.End)
          .onClick((): void => this.close())
      }
      if (this.props.headerBuilder !== undefined) {
        this.headerRegion()
      } else {
        this.header()
      }
      Scroll() {
        Column() {
          ForEach(this.treeIndexes(), (treeIndex: number) => {
            this.group(treeIndex)
          }, (treeIndex: number): string => `${treeIndex}:${this.selectionKey()}`)
          this.countRow()
        }
        .width('100%')
      }
      .width('100%')
      .constraintSize({ maxHeight: UP_GOODS_SKU_CONTENT_MAX_HEIGHT })
      this.footer()
    }
    .width('100%')
    .padding({
      top: this.containerPaddingTop(),
      bottom: this.containerPaddingTop(),
      left: this.containerPadding(),
      right: this.containerPadding()
    })
    .backgroundColor(this.panelColor())
    .borderRadius({ topLeft: this.panelRadius(), topRight: this.panelRadius() })
  }

  @Builder
  private content() {
    if (upBoolean(this.props.pageInline, false)) {
      this.panel()
    } else if (!upBoolean(this.props.show, false)) {
      Row().width(0).height(0)
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.5)
          .onClick((): void => this.close())
        this.panel()
      }
      .width('100%')
      .height('100%')
      .zIndex(1002)
    }
  }

  @Builder
  private headerRegion() {
    UPSlotRegion({ contentBuilder: this.props.headerBuilder })
  }

  @Builder
  private triggerRegion() {
    UPSlotRegion({ contentBuilder: this.props.triggerBuilder })
  }

  build() {
    Column() {
      if (this.props.triggerBuilder !== undefined) {
        Column() {
          this.triggerRegion()
        }
        .onClick((): void => this.openByTrigger())
      }
      this.content()
    }
  }
}
