import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPSelectionOption, upSelectionBoolean, upSelectionColor, upSelectionEqual, upSelectionText } from './UPSelectionTypes';
import { UPUnit } from '../core/UPUnit';

export interface UPRadioGroupChangeEvent { value: UPRawValue; }
export interface UPRadioGroupOptions {
  name?: UPRawValue; modelValue?: UPRawValue; value?: UPRawValue; shape?: UPRawValue; disabled?: UPRawValue; activeColor?: UPRawValue; inactiveColor?: UPRawValue;
  size?: UPRawValue; placement?: UPRawValue; labelSize?: UPRawValue; labelColor?: UPRawValue; labelDisabled?: UPRawValue; iconColor?: UPRawValue; iconSize?: UPRawValue;
  borderBottom?: UPRawValue; iconPlacement?: UPRawValue; gap?: UPRawValue; options?: Array<UPSelectionOption>; customStyle?: UPStyleInput; onInput?: (event: UPRadioGroupChangeEvent) => void; onChange?: (event: UPRadioGroupChangeEvent) => void; contentBuilder?: UPBuilder;
}
export class UPRadioGroupProps {
  name: UPRawValue = ''; modelValue: UPRawValue = undefined; value: UPRawValue = ''; shape: UPRawValue = 'circle'; disabled: UPRawValue = false; activeColor: UPRawValue = '#2979ff'; inactiveColor: UPRawValue = '#c8c9cc'; size: UPRawValue = 18; placement: UPRawValue = 'row'; labelSize: UPRawValue = 14; labelColor: UPRawValue = '#606266'; labelDisabled: UPRawValue = false; iconColor: UPRawValue = '#ffffff'; iconSize: UPRawValue = 12; borderBottom: UPRawValue = false; iconPlacement: UPRawValue = 'left'; gap: UPRawValue = 12; options: Array<UPSelectionOption> = []; customStyle: UPStyleInput = undefined; onInput?: (event: UPRadioGroupChangeEvent) => void; onChange?: (event: UPRadioGroupChangeEvent) => void; contentBuilder?: UPBuilder;
  constructor(options?: UPRadioGroupOptions) {
    if (options === undefined) return;
    this.name = options.name ?? this.name; this.modelValue = options.modelValue ?? this.modelValue; this.value = options.value ?? this.value; this.shape = options.shape ?? this.shape; this.disabled = options.disabled ?? this.disabled; this.activeColor = options.activeColor ?? this.activeColor; this.inactiveColor = options.inactiveColor ?? this.inactiveColor; this.size = options.size ?? this.size; this.placement = options.placement ?? this.placement; this.labelSize = options.labelSize ?? this.labelSize; this.labelColor = options.labelColor ?? this.labelColor; this.labelDisabled = options.labelDisabled ?? this.labelDisabled; this.iconColor = options.iconColor ?? this.iconColor; this.iconSize = options.iconSize ?? this.iconSize; this.borderBottom = options.borderBottom ?? this.borderBottom; this.iconPlacement = options.iconPlacement ?? this.iconPlacement; this.gap = options.gap ?? this.gap; this.options = options.options ?? this.options; this.customStyle = options.customStyle; this.onInput = options.onInput; this.onChange = options.onChange; this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPRadioGroup {
  @Prop props: UPRadioGroupProps = new UPRadioGroupProps();
  @State private selected: UPRawValue = '';
  @Builder private emptyContent() { Row().width(0).height(0); }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  aboutToAppear(): void { this.selected = this.props.modelValue === null || this.props.modelValue === undefined ? this.props.value : this.props.modelValue; }
  private choose(option: UPSelectionOption): void {
    if (upSelectionBoolean(this.props.disabled) || upSelectionBoolean(option.disabled) || upSelectionBoolean(this.props.labelDisabled)) return;
    this.selected = option.name;
    const event: UPRadioGroupChangeEvent = { value: option.name };
    this.props.onInput?.(event); this.props.onChange?.(event);
  }
  @Builder private optionView(option: UPSelectionOption) {
    Row({ space: 8 }) {
      Stack() { if (upSelectionEqual(this.selected, option.name)) Column().width(9).height(9).backgroundColor(upSelectionColor(this.props.activeColor, '#2979ff')).borderRadius(9) }
        .width(18).height(18).borderWidth(1).borderColor(upSelectionEqual(this.selected, option.name) ? upSelectionColor(this.props.activeColor, '#2979ff') : upSelectionColor(this.props.inactiveColor, '#c8c9cc')).borderRadius(9)
      Text(upSelectionText(option.label ?? option.name)).fontSize(UPUnit.parse(this.props.labelSize, 375, 14)).fontColor(upSelectionColor(this.props.labelColor, '#606266'))
    }.opacity(upSelectionBoolean(this.props.disabled) || upSelectionBoolean(option.disabled) ? 0.5 : 1).onClick((): void => this.choose(option))
  }
  build() {
    if (this.props.options.length > 0) {
      if (upSelectionText(this.props.placement) === 'column') Column({ space: UPUnit.parse(this.props.gap, 375, 12) }) { ForEach(this.props.options, (item: UPSelectionOption) => { this.optionView(item) }, (item: UPSelectionOption) => upSelectionText(item.name)) }.width('100%')
      else Row({ space: UPUnit.parse(this.props.gap, 375, 12) }) { ForEach(this.props.options, (item: UPSelectionOption) => { this.optionView(item) }, (item: UPSelectionOption) => upSelectionText(item.name)) }.width('100%')
    } else Column() { this.contentBuilder() }.width('100%')
  }
}
