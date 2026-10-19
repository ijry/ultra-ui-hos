import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPTag, UPTagProps } from './UPTag';
import { UPColor } from '../core/UPColor';

/** 选项的具名模型，替代上游任意对象。/ Named option entry instead of an arbitrary object. */
export interface UPChooseItem {
  id?: UPRawValue;
  title?: string;
  label?: string;
  name?: string;
  value?: UPRawValue;
}

/** 选中变更事件载荷。/ Payload of the selection change event. */
export interface UPChooseChangeEvent {
  index: number;
  item: UPChooseItem;
}

/** labelName 白名单读取，替代上游 item[labelName]。/ Named label lookup. */
/** 上游默认插槽作用域：逐项回传条目与下标。/ Scope handed to the upstream default slot. */
export interface UPChooseItemSlot { item: UPChooseItem; index: number; }

export function upChooseLabel(item: UPChooseItem, labelName: string): string {
  if (labelName === 'label' && item.label !== undefined) {
    return item.label;
  }
  if (labelName === 'name' && item.name !== undefined) {
    return item.name;
  }
  if (labelName === 'title' && item.title !== undefined) {
    return item.title;
  }
  return item.title ?? item.label ?? item.name ?? '';
}

/** valueName 白名单读取，替代上游 item[valueName]。/ Named value lookup. */
export function upChooseValue(item: UPChooseItem, valueName: string): UPRawValue {
  if (valueName === 'id' && item.id !== undefined) {
    return item.id;
  }
  if (valueName === 'value' && item.value !== undefined) {
    return item.value;
  }
  return item.value ?? item.id ?? '';
}

/** labelName / valueName 是否落在具名模型字段内。/ Whether the key targets a modelled field. */
export function upChooseKeySupported(keyName: string): boolean {
  return keyName.length === 0 || keyName === 'title' || keyName === 'label'
    || keyName === 'name' || keyName === 'value' || keyName === 'id';
}

export interface UPChooseOptions {
  options?: Array<UPChooseItem>;
  modelValue?: UPRawValue;
  type?: UPRawValue;
  itemWidth?: UPRawValue;
  itemHeight?: UPRawValue;
  itemPadding?: UPRawValue;
  labelName?: UPRawValue;
  valueName?: UPRawValue;
  customClick?: UPRawValue;
  wrap?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onChange?: (event: UPChooseChangeEvent) => void;
  onCustomClick?: (event: UPChooseChangeEvent) => void;
}

export class UPChooseProps {
  options: Array<UPChooseItem> = [];
  modelValue: UPRawValue = false;
  type: UPRawValue = 'radio';
  itemWidth: UPRawValue = 'auto';
  itemHeight: UPRawValue = '50px';
  itemPadding: UPRawValue = '8px';
  labelName: UPRawValue = 'title';
  valueName: UPRawValue = 'value';
  customClick: UPRawValue = false;
  wrap: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onChange?: (event: UPChooseChangeEvent) => void;
  onCustomClick?: (event: UPChooseChangeEvent) => void;

  constructor(options?: UPChooseOptions) {
    if (options === undefined) {
      return;
    }
    this.options = options.options ?? this.options;
    this.modelValue = options.modelValue ?? this.modelValue;
    this.type = options.type ?? this.type;
    this.itemWidth = options.itemWidth ?? this.itemWidth;
    this.itemHeight = options.itemHeight ?? this.itemHeight;
    this.itemPadding = options.itemPadding ?? this.itemPadding;
    this.labelName = options.labelName ?? this.labelName;
    this.valueName = options.valueName ?? this.valueName;
    this.customClick = options.customClick ?? this.customClick;
    this.wrap = options.wrap ?? this.wrap;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onChange = options.onChange;
    this.onCustomClick = options.onCustomClick;
  }
}

@Component
export struct UPChoose {
  @Prop @Watch('applyModelValue') props: UPChooseProps = new UPChooseProps();
  @State private currentIndex: number = -1;
  private appliedIndex: number = -2;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    const labelName: string = upString(this.props.labelName, 'title');
    if (!upChooseKeySupported(labelName)) {
      diagnostics.report('UPChoose', 'labelName', this.props.labelName, 'labelName must target title/label/name; fallback to the first available field');
    }
    const valueName: string = upString(this.props.valueName, 'value');
    if (!upChooseKeySupported(valueName)) {
      diagnostics.report('UPChoose', 'valueName', this.props.valueName, 'valueName must target value/id; fallback to the first available field');
    }
    if (upString(this.props.type, 'radio') !== 'radio') {
      diagnostics.report('UPChoose', 'type', this.props.type, 'the upstream tag list only renders a single-select row; type is a no-op');
    }
    this.applyModelValue();
  }

  /** modelValue 为下标，非法值回落未选中。/ modelValue carries the selected index. */
  private applyModelValue(): void {
    const next: number = typeof this.props.modelValue === 'number'
      ? Math.floor(upNumber(this.props.modelValue, -1))
      : -1;
    if (next === this.appliedIndex) {
      return;
    }
    this.appliedIndex = next;
    this.currentIndex = next >= 0 && next < this.props.options.length ? next : -1;
  }

  private itemIndexes(): Array<number> {
    const values: Array<number> = [];
    const total: number = this.props.options.length;
    for (let index: number = 0; index < total; index++) {
      values.push(index);
    }
    return values;
  }

  private labelOf(index: number): string {
    return upChooseLabel(this.props.options[index], upString(this.props.labelName, 'title'));
  }

  private selected(index: number): boolean {
    return this.currentIndex === index;
  }

  private handleChange(index: number): void {
    const item: UPChooseItem = this.props.options[index];
    if (upBoolean(this.props.customClick, false)) {
      const custom: ((event: UPChooseChangeEvent) => void) | undefined = this.props.onCustomClick;
      if (custom !== undefined) {
        custom({ index, item });
      }
      return;
    }
    this.currentIndex = index;
    this.appliedIndex = index;
    const change: ((event: UPChooseChangeEvent) => void) | undefined = this.props.onChange;
    if (change !== undefined) {
      change({ index, item });
    }
  }

  @Builder
  private defaultItem(slot: UPChooseItemSlot) {
    UPTag({ props: new UPTagProps({
      text: this.labelOf(slot.index),
      size: 'large',
      type: this.selected(slot.index) ? 'primary' : 'info',
      plain: !this.selected(slot.index),
      height: this.props.itemHeight,
      padding: this.props.itemPadding,
      onClick: (): void => this.handleChange(slot.index)
    }) })
  }

  @BuilderParam itemBuilder: (slot: UPChooseItemSlot) => void = this.defaultItem;

  private itemSlot(index: number): UPChooseItemSlot {
    return { item: this.props.options[index], index };
  }

  @Builder
  private itemContent(index: number) {
    Row() {
      this.itemBuilder(this.itemSlot(index))
    }
    .margin({ right: 8, bottom: upBoolean(this.props.wrap, true) ? 8 : 0 })
  }

  @Builder
  private itemList() {
    if (upBoolean(this.props.wrap, true)) {
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
        ForEach(this.itemIndexes(), (index: number) => {
          this.itemContent(index)
        }, (index: number) => String(index))
      }
      .width('100%')
    } else {
      Scroll() {
        Row() {
          ForEach(this.itemIndexes(), (index: number) => {
            this.itemContent(index)
          }, (index: number) => String(index))
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
  }

  build() {
    Column() {
      if (this.props.options.length === 0) {
        Text('暂无可选项').fontSize(14).fontColor(UPColor.adaptive('#909399', 'tips-color'))
      } else {
        this.itemList()
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
