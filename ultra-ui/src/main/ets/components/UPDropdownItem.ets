import { UPRawValue, UPStyleInput, upBoolean, upString, upValueKey } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPDropdownContext } from '../internal/UPInteractionContexts';

export interface UPDropdownOption { label: UPRawValue; value: UPRawValue; disabled?: UPRawValue; }
export interface UPDropdownItemSelectEvent { index: number; option: UPDropdownOption; value: UPRawValue | Array<UPRawValue>; }
export interface UPDropdownItemOptions {
  modelValue?: UPRawValue | Array<UPRawValue>; value?: UPRawValue | Array<UPRawValue>; title?: UPRawValue;
  options?: Array<UPDropdownOption>; disabled?: UPRawValue; height?: UPRawValue;
  closeOnClickOverlay?: UPRawValue; customStyle?: UPStyleInput; multiple?: UPRawValue;
  onValueChange?: (value: UPRawValue | Array<UPRawValue>) => void;
  onChange?: (value: UPRawValue | Array<UPRawValue>) => void;
  onSelect?: (event: UPDropdownItemSelectEvent) => void;
}
export class UPDropdownItemProps {
  modelValue: UPRawValue | Array<UPRawValue> = undefined; value: UPRawValue | Array<UPRawValue> = '';
  title: UPRawValue = ''; options: Array<UPDropdownOption> = []; disabled: UPRawValue = false;
  height: UPRawValue = 44; closeOnClickOverlay: UPRawValue = true; customStyle: UPStyleInput = undefined;
  multiple: UPRawValue = false; onValueChange?: (value: UPRawValue | Array<UPRawValue>) => void;
  onChange?: (value: UPRawValue | Array<UPRawValue>) => void; onSelect?: (event: UPDropdownItemSelectEvent) => void;
  constructor(options?: UPDropdownItemOptions) {
    if (options === undefined) return;
    this.modelValue = options.modelValue ?? this.modelValue; this.value = options.value ?? this.value; this.title = options.title ?? this.title;
    this.options = options.options ?? this.options; this.disabled = options.disabled ?? this.disabled; this.height = options.height ?? this.height;
    this.closeOnClickOverlay = options.closeOnClickOverlay ?? this.closeOnClickOverlay; this.customStyle = options.customStyle;
    this.multiple = options.multiple ?? this.multiple; this.onValueChange = options.onValueChange; this.onChange = options.onChange; this.onSelect = options.onSelect;
  }
}

@Component
export struct UPDropdownItem {
  @Prop props: UPDropdownItemProps = new UPDropdownItemProps();
  @Consume('UPDropdownContext') dropdownContext: UPDropdownContext = new UPDropdownContext();
  private itemIndex: number = 0;
  aboutToAppear(): void { this.itemIndex = this.dropdownContext.itemIndex(); }
  private text(value: UPRawValue): string { return value === null || value === undefined ? '' : String(value); }
  private selected(): UPRawValue | Array<UPRawValue> { return this.props.modelValue !== null && this.props.modelValue !== undefined ? this.props.modelValue : this.props.value; }
  private isSelected(value: UPRawValue): boolean {
    const current: UPRawValue | Array<UPRawValue> = this.selected();
    return Array.isArray(current) ? current.some((item: UPRawValue): boolean => upValueKey(item) === upValueKey(value)) : upValueKey(current) === upValueKey(value);
  }
  private selectedLabel(): string {
    const current: UPRawValue | Array<UPRawValue> = this.selected();
    const key: string = Array.isArray(current) ? upValueKey(current[0]) : upValueKey(current);
    const option: UPDropdownOption | undefined = this.props.options.find((item: UPDropdownOption): boolean => upValueKey(item.value) === key);
    return option === undefined ? '请选择' : this.text(option.label);
  }
  private optionAt(index: number): UPDropdownOption { return this.props.options[index]; }
  private choose(index: number): void {
    const option: UPDropdownOption | undefined = this.props.options[index];
    if (option === undefined || upBoolean(this.props.disabled, false) || upBoolean(option.disabled, false)) return;
    const current: UPRawValue | Array<UPRawValue> = this.selected();
    let next: UPRawValue | Array<UPRawValue> = option.value;
    if (upBoolean(this.props.multiple, false)) {
      const values: Array<UPRawValue> = Array.isArray(current) ? current.slice() : [];
      const existing: number = values.findIndex((item: UPRawValue): boolean => upValueKey(item) === upValueKey(option.value));
      if (existing >= 0) values.splice(existing, 1); else values.push(option.value);
      next = values;
    }
    this.props.onValueChange?.(next); this.props.onChange?.(next); this.props.onSelect?.({ index, option, value: next });
    if (!upBoolean(this.props.multiple, false)) this.dropdownContext.requestOpen(-1);
  }
  @Builder private optionView(index: number) {
    Row() {
      Text(this.text(this.optionAt(index).label)).fontSize(14).fontColor(this.isSelected(this.optionAt(index).value) ? '#2979ff' : '#303133').layoutWeight(1)
      if (this.isSelected(this.optionAt(index).value)) Text('✓').fontSize(16).fontColor('#2979ff')
    }.width('100%').height(42).padding({ left: 14, right: 14 }).opacity(upBoolean(this.optionAt(index).disabled, false) ? 0.45 : 1).onClick(() => this.choose(index))
  }
  @Builder private content() {
    if (this.dropdownContext.isOpen(this.itemIndex)) {
      Column() { ForEach(this.props.options, (option: UPDropdownOption, index: number) => { this.optionView(index); }, (option: UPDropdownOption): string => upValueKey(option.value)) }
        .width('100%').backgroundColor('#ffffff')
    }
  }
  build() {
    Column() {
      Row() {
        Text(this.text(this.props.title).length > 0 ? this.text(this.props.title) : this.selectedLabel()).fontSize(14)
          .fontColor(this.dropdownContext.isOpen(this.itemIndex) ? '#2979ff' : '#606266').layoutWeight(1)
        Text(this.dropdownContext.isOpen(this.itemIndex) ? '⌃' : '⌄').fontSize(16).fontColor('#909399')
      }.width('100%').height(UPUnit.parse(this.props.height, 375, 44)).padding({ left: 12, right: 12 })
        .border({ width: { bottom: 1 }, color: '#ebeef5' }).opacity(upBoolean(this.props.disabled, false) ? 0.5 : 1)
        .onClick(() => { if (!upBoolean(this.props.disabled, false)) this.dropdownContext.requestOpen(this.itemIndex); })
      this.content()
    }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
