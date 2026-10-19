import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPI18n } from '../core/UPI18n';
import { UPColor } from '../core/UPColor';

export interface UPCascaderOption { value: UPRawValue; label: string; disabled?: UPRawValue; children?: Array<UPCascaderOption>; }
export interface UPCascaderChangeEvent { value: UPRawValue; path: Array<UPRawValue>; labels: Array<string>; }
export interface UPCascaderOptions {
  options?: Array<UPCascaderOption>; value?: UPRawValue; modelValue?: UPRawValue; visible?: UPRawValue;
  column?: UPRawValue; title?: string; activeColor?: string; customStyle?: UPStyleInput;
  onChange?: (event: UPCascaderChangeEvent) => void; onConfirm?: (event: UPCascaderChangeEvent) => void;
  onCancel?: () => void; onShowChange?: (visible: boolean) => void;
}
export class UPCascaderProps {
  options: Array<UPCascaderOption> = []; value: UPRawValue = ''; modelValue: UPRawValue = null; visible: UPRawValue = false;
  column: UPRawValue = 0; title: string = UPI18n.t('up.common.pleaseChoose'); activeColor: string = '#2979ff'; customStyle: UPStyleInput = undefined;
  onChange?: (event: UPCascaderChangeEvent) => void; onConfirm?: (event: UPCascaderChangeEvent) => void;
  onCancel?: () => void; onShowChange?: (visible: boolean) => void;
  constructor(options?: UPCascaderOptions) {
    if (options === undefined) return;
    this.options = options.options ?? this.options; this.value = options.value ?? this.value; this.modelValue = options.modelValue ?? this.modelValue;
    this.visible = options.visible ?? this.visible; this.column = options.column ?? this.column; this.title = options.title ?? this.title;
    this.activeColor = options.activeColor ?? this.activeColor; this.customStyle = options.customStyle;
    this.onChange = options.onChange; this.onConfirm = options.onConfirm; this.onCancel = options.onCancel; this.onShowChange = options.onShowChange;
  }
}

@Component
export struct UPCascader {
  @Prop props: UPCascaderProps = new UPCascaderProps();
  @State private path: Array<UPRawValue> = [];
  @State private labels: Array<string> = [];
  @State private columnIndex: number = 0;

  aboutToAppear(): void {
    const initial: UPRawValue = this.props.modelValue !== null && this.props.modelValue !== undefined ? this.props.modelValue : this.props.value;
    if (initial !== null && initial !== undefined && String(initial).length > 0) this.selectByValue(this.props.options, initial, [], []);
    this.columnIndex = Math.max(0, Math.floor(typeof this.props.column === 'number' ? this.props.column : 0));
  }
  private columns(): Array<UPCascaderOption> {
    let options: Array<UPCascaderOption> = this.props.options;
    for (let index = 0; index < this.columnIndex; index++) {
      const found: UPCascaderOption | undefined = options.find((item: UPCascaderOption): boolean => String(item.value) === String(this.path[index]));
      options = found?.children ?? [];
    }
    return options;
  }
  private selectByValue(options: Array<UPCascaderOption>, value: UPRawValue, path: Array<UPRawValue>, labels: Array<string>): boolean {
    for (const option of options) {
      if (String(option.value) === String(value)) { this.path = [...path, option.value]; this.labels = [...labels, option.label]; return true; }
      if (option.children !== undefined && this.selectByValue(option.children, value, [...path, option.value], [...labels, option.label])) return true;
    }
    return false;
  }
  private currentEvent(): UPCascaderChangeEvent {
    return { value: this.path.length > 0 ? this.path[this.path.length - 1] : '', path: this.path.slice(), labels: this.labels.slice() };
  }
  private choose(option: UPCascaderOption): void {
    if (upBoolean(option.disabled, false)) return;
    const nextPath: Array<UPRawValue> = [...this.path.slice(0, this.columnIndex), option.value];
    const nextLabels: Array<string> = [...this.labels.slice(0, this.columnIndex), option.label];
    this.path = nextPath; this.labels = nextLabels;
    if (option.children !== undefined && option.children.length > 0) this.columnIndex = Math.min(this.columnIndex + 1, nextPath.length);
    const event: UPCascaderChangeEvent = this.currentEvent();
    this.props.onChange?.(event);
  }
  /** 上游取消同时抛出 `update:show`。/ Upstream cancel also emits update:show. */
  private dismiss(): void {
    this.props.onCancel?.();
    this.props.onShowChange?.(false);
  }
  /** 上游确认同时抛出 `update:show`。/ Upstream confirm also emits update:show. */
  private confirm(): void {
    this.props.onConfirm?.(this.currentEvent());
    this.props.onShowChange?.(false);
  }
  build() {
    Column({ space: 10 }) {
      Row() { Text(this.props.title).fontSize(15).fontWeight(FontWeight.Medium).layoutWeight(1)
        Text('取消').fontSize(13).fontColor(UPColor.adaptive('#909399', 'tips-color')).onClick((): void => this.dismiss()) }.width('100%')
      if (this.labels.length > 0) Text(this.labels.join(' / ')).fontSize(12).fontColor(UPColor.adaptive('#909399', 'tips-color')).width('100%')
      Row({ space: 4 }) { ForEach(this.columns(), (option: UPCascaderOption) =>
        Text(option.label).fontSize(14).padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .fontColor(String(option.value) === String(this.path[this.columnIndex]) ? this.props.activeColor : '#303133')
          .opacity(upBoolean(option.disabled, false) ? 0.45 : 1).onClick((): void => this.choose(option))
      ) }.width('100%')
      Text('确定').fontSize(14).fontColor(this.props.activeColor).width('100%').textAlign(TextAlign.Center).padding(8)
        .onClick((): void => this.confirm())
    }.padding(12).backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color')).borderRadius(8).width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
