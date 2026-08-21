import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPSelectionOption, upSelectionBoolean, upSelectionColor, upSelectionEqual, upSelectionNumber, upSelectionText } from './UPSelectionTypes';

export interface UPCheckboxGroupChangeEvent { value: Array<UPRawValue>; }
export interface UPCheckboxGroupOptions {
  name?: UPRawValue; modelValue?: Array<UPRawValue>; value?: Array<UPRawValue>; shape?: UPRawValue; disabled?: UPRawValue;
  activeColor?: UPRawValue; inactiveColor?: UPRawValue; size?: UPRawValue; placement?: UPRawValue;
  labelSize?: UPRawValue; labelColor?: UPRawValue; labelDisabled?: UPRawValue; iconColor?: UPRawValue;
  iconSize?: UPRawValue; borderBottom?: UPRawValue; iconPlacement?: UPRawValue; gap?: UPRawValue;
  options?: Array<UPSelectionOption>; customStyle?: UPStyleInput; onInput?: (event: UPCheckboxGroupChangeEvent) => void;
  onChange?: (event: UPCheckboxGroupChangeEvent) => void; contentBuilder?: UPBuilder;
}
export class UPCheckboxGroupProps {
  name: UPRawValue = ''; modelValue: Array<UPRawValue> | undefined = undefined; value: Array<UPRawValue> = [];
  shape: UPRawValue = 'square'; disabled: UPRawValue = false; activeColor: UPRawValue = '#2979ff'; inactiveColor: UPRawValue = '#c8c9cc';
  size: UPRawValue = 18; placement: UPRawValue = 'row'; labelSize: UPRawValue = 14; labelColor: UPRawValue = '#606266'; labelDisabled: UPRawValue = false;
  iconColor: UPRawValue = '#ffffff'; iconSize: UPRawValue = 12; borderBottom: UPRawValue = false; iconPlacement: UPRawValue = 'left'; gap: UPRawValue = 12;
  options: Array<UPSelectionOption> = []; customStyle: UPStyleInput = undefined; onInput?: (event: UPCheckboxGroupChangeEvent) => void; onChange?: (event: UPCheckboxGroupChangeEvent) => void; contentBuilder?: UPBuilder;
  constructor(options?: UPCheckboxGroupOptions) {
    if (options === undefined) return;
    this.name = options.name ?? this.name; this.modelValue = options.modelValue ?? this.modelValue; this.value = options.value ?? this.value;
    this.shape = options.shape ?? this.shape; this.disabled = options.disabled ?? this.disabled; this.activeColor = options.activeColor ?? this.activeColor; this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.size = options.size ?? this.size; this.placement = options.placement ?? this.placement; this.labelSize = options.labelSize ?? this.labelSize; this.labelColor = options.labelColor ?? this.labelColor; this.labelDisabled = options.labelDisabled ?? this.labelDisabled;
    this.iconColor = options.iconColor ?? this.iconColor; this.iconSize = options.iconSize ?? this.iconSize; this.borderBottom = options.borderBottom ?? this.borderBottom; this.iconPlacement = options.iconPlacement ?? this.iconPlacement; this.gap = options.gap ?? this.gap;
    this.options = options.options ?? this.options; this.customStyle = options.customStyle; this.onInput = options.onInput; this.onChange = options.onChange; this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPCheckboxGroup {
  @Prop props: UPCheckboxGroupProps = new UPCheckboxGroupProps();
  @State private selected: Array<UPRawValue> = [];
  @Builder private emptyContent() { Row().width(0).height(0); }
  @BuilderParam contentBuilder: () => void = this.emptyContent;

  aboutToAppear(): void { this.selected = this.initialValues(); }
  private initialValues(): Array<UPRawValue> {
    return this.props.modelValue === undefined ? this.props.value : this.props.modelValue;
  }
  private has(value: UPRawValue): boolean { return this.selected.some((item: UPRawValue): boolean => upSelectionEqual(item, value)); }
  private toggle(option: UPSelectionOption): void {
    if (upSelectionBoolean(this.props.disabled) || upSelectionBoolean(option.disabled) || upSelectionBoolean(this.props.labelDisabled)) return;
    const next: Array<UPRawValue> = this.selected.filter((item: UPRawValue): boolean => !upSelectionEqual(item, option.name));
    if (!this.has(option.name)) next.push(option.name);
    this.selected = next;
    const event: UPCheckboxGroupChangeEvent = { value: next };
    this.props.onInput?.(event); this.props.onChange?.(event);
  }
  @Builder private optionView(option: UPSelectionOption) {
    Row({ space: 8 }) {
      Stack() { Text(this.has(option.name) ? '✓' : '').fontSize(UPUnit.parse(this.props.iconSize, 375, 12)).fontColor('#ffffff') }
        .width(UPUnit.parse(this.props.size, 375, 18)).height(UPUnit.parse(this.props.size, 375, 18))
        .backgroundColor(this.has(option.name) ? upSelectionColor(this.props.activeColor, '#2979ff') : 'transparent').borderWidth(1)
        .borderColor(this.has(option.name) ? upSelectionColor(this.props.activeColor, '#2979ff') : upSelectionColor(this.props.inactiveColor, '#c8c9cc'))
        .borderRadius(upSelectionText(this.props.shape) === 'circle' ? UPUnit.parse(this.props.size, 375, 18) / 2 : 4)
      Text(upSelectionText(option.label ?? option.name)).fontSize(UPUnit.parse(this.props.labelSize, 375, 14)).fontColor(upSelectionColor(this.props.labelColor, '#606266'))
    }.opacity(upSelectionBoolean(this.props.disabled) || upSelectionBoolean(option.disabled) ? 0.5 : 1).onClick((): void => this.toggle(option))
  }
  build() {
    if (this.props.options.length > 0) {
      if (upSelectionText(this.props.placement) === 'column') {
        Column({ space: UPUnit.parse(this.props.gap, 375, 12) }) { ForEach(this.props.options, (item: UPSelectionOption) => { this.optionView(item) }, (item: UPSelectionOption) => upSelectionText(item.name)) }
          .width('100%')
      } else {
        Row({ space: UPUnit.parse(this.props.gap, 375, 12) }) { ForEach(this.props.options, (item: UPSelectionOption) => { this.optionView(item) }, (item: UPSelectionOption) => upSelectionText(item.name)) }
          .width('100%')
      }
    } else {
      Column() { this.contentBuilder() }.width('100%')
    }
  }
}
