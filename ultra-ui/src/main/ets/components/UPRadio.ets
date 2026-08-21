import { UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { upSelectionBoolean, upSelectionColor, upSelectionNumber, upSelectionShape, upSelectionText } from './UPSelectionTypes';

export interface UPRadioChangeEvent {
  name: UPRawValue;
  checked: boolean;
  value: UPRawValue;
}

export interface UPRadioOptions {
  name?: UPRawValue;
  shape?: UPRawValue;
  checked?: UPRawValue;
  disabled?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
  iconSize?: UPRawValue;
  iconColor?: UPRawValue;
  label?: UPRawValue;
  labelSize?: UPRawValue;
  labelColor?: UPRawValue;
  labelDisabled?: UPRawValue;
  customStyle?: UPStyleInput;
  onChange?: (event: UPRadioChangeEvent) => void;
}

export class UPRadioProps {
  name: UPRawValue = '';
  shape: UPRawValue = 'round';
  checked: UPRawValue = false;
  disabled: UPRawValue = false;
  activeColor: UPRawValue = '#2979ff';
  inactiveColor: UPRawValue = '#c8c9cc';
  iconSize: UPRawValue = 12;
  iconColor: UPRawValue = '#ffffff';
  label: UPRawValue = '';
  labelSize: UPRawValue = 14;
  labelColor: UPRawValue = '#606266';
  labelDisabled: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  onChange?: (event: UPRadioChangeEvent) => void;

  constructor(options?: UPRadioOptions) {
    if (options === undefined) return;
    this.name = options.name ?? this.name;
    this.shape = options.shape ?? this.shape;
    this.checked = options.checked ?? this.checked;
    this.disabled = options.disabled ?? this.disabled;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.iconSize = options.iconSize ?? this.iconSize;
    this.iconColor = options.iconColor ?? this.iconColor;
    this.label = options.label ?? this.label;
    this.labelSize = options.labelSize ?? this.labelSize;
    this.labelColor = options.labelColor ?? this.labelColor;
    this.labelDisabled = options.labelDisabled ?? this.labelDisabled;
    this.customStyle = options.customStyle;
    this.onChange = options.onChange;
  }
}

@Component
export struct UPRadio {
  @Prop props: UPRadioProps = new UPRadioProps();
  @State private selected: boolean = false;

  aboutToAppear(): void { this.selected = upSelectionBoolean(this.props.checked, false); }

  private sizeValue(): number { return UPUnit.parse(this.props.iconSize, 375, 18); }

  private toggle(): void {
    if (upSelectionBoolean(this.props.disabled) || upSelectionBoolean(this.props.labelDisabled) || this.selected) return;
    this.selected = true;
    this.props.onChange?.({ name: this.props.name, checked: true, value: this.props.name });
  }

  build() {
    Row({ space: 8 }) {
      Stack() {
        if (this.selected) {
          Column().width(this.sizeValue() * 0.5).height(this.sizeValue() * 0.5)
            .backgroundColor(upSelectionColor(this.props.activeColor, '#2979ff'))
            .borderRadius(this.sizeValue() / 2)
        }
      }
      .width(this.sizeValue())
      .height(this.sizeValue())
      .borderWidth(1)
      .borderColor(this.selected ? upSelectionColor(this.props.activeColor, '#2979ff') : upSelectionColor(this.props.inactiveColor, '#c8c9cc'))
      .borderRadius(this.sizeValue() / 2)
      .onClick((): void => this.toggle())
      if (upSelectionText(this.props.label).length > 0) {
        Text(upSelectionText(this.props.label))
          .fontSize(UPUnit.parse(this.props.labelSize, 375, 14))
          .fontColor(upSelectionColor(this.props.labelColor, '#606266'))
          .opacity(upSelectionBoolean(this.props.disabled) || upSelectionBoolean(this.props.labelDisabled) ? 0.5 : 1)
          .onClick((): void => this.toggle())
      }
    }
    .opacity(upSelectionBoolean(this.props.disabled) ? 0.5 : 1)
    .enabled(!upSelectionBoolean(this.props.disabled))
    .padding(UPStyle.parse(this.props.customStyle).padding ?? { top: 2, right: 2, bottom: 2, left: 2 })
  }
}
