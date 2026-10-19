import { UPBuilder, UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import {
  upSelectionBoolean, upSelectionColor, upSelectionEqual, upSelectionNumber,
  upSelectionShape, upSelectionText
} from './UPSelectionTypes';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPCheckboxChangeEvent {
  name: UPRawValue;
  checked: boolean;
  value: UPRawValue;
}

export interface UPCheckboxOptions {
  name?: UPRawValue;
  shape?: UPRawValue;
  size?: UPRawValue;
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
  usedAlone?: UPRawValue;
  customStyle?: UPStyleInput;
  onChange?: (event: UPCheckboxChangeEvent) => void;
  iconBuilder?: UPBuilder;
  labelBuilder?: UPBuilder;
}

export class UPCheckboxProps {
  name: UPRawValue = '';
  shape: UPRawValue = 'square';
  size: UPRawValue = 18;
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
  usedAlone: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  onChange?: (event: UPCheckboxChangeEvent) => void;
  iconBuilder?: UPBuilder;
  labelBuilder?: UPBuilder;

  constructor(options?: UPCheckboxOptions) {
    if (options === undefined) return;
    this.name = options.name ?? this.name;
    this.shape = options.shape ?? this.shape;
    this.size = options.size ?? this.size;
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
    this.usedAlone = options.usedAlone ?? this.usedAlone;
    this.customStyle = options.customStyle;
    this.onChange = options.onChange;
    this.iconBuilder = options.iconBuilder;
    this.labelBuilder = options.labelBuilder;
  }
}

@Component
export struct UPCheckbox {
  @Prop props: UPCheckboxProps = new UPCheckboxProps();
  @State private selected: boolean = false;

  aboutToAppear(): void {
    this.selected = upSelectionBoolean(this.props.checked, false);
  }

  private sizeValue(): number {
    return UPUnit.parse(this.props.size, 375, 18);
  }

  private radius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderRadius !== undefined) return style.borderRadius;
    return upSelectionShape(this.props.shape, 'square') === 'circle' ? this.sizeValue() / 2 : 4;
  }

  private toggle(): void {
    if (upSelectionBoolean(this.props.disabled) || upSelectionBoolean(this.props.labelDisabled)) return;
    this.selected = !this.selected;
    this.props.onChange?.({ name: this.props.name, checked: this.selected, value: this.selected });
  }

  @Builder
  private iconRegion() {
    UPSlotRegion({ contentBuilder: this.props.iconBuilder })
  }

  @Builder
  private labelRegion() {
    UPSlotRegion({ contentBuilder: this.props.labelBuilder })
  }

  build() {
    Row({ space: 8 }) {
      Stack() {
        if (this.props.iconBuilder !== undefined) {
          this.iconRegion()
        } else {
          Text(this.selected ? '✓' : '')
            .fontSize(UPUnit.parse(this.props.iconSize, 375, 12))
            .fontColor(upSelectionColor(this.props.iconColor, '#ffffff'))
            .fontWeight(FontWeight.Bold)
        }
      }
      .width(this.sizeValue())
      .height(this.sizeValue())
      .backgroundColor(this.selected ? upSelectionColor(this.props.activeColor, '#2979ff') : 'transparent')
      .borderWidth(1)
      .borderColor(this.selected ? upSelectionColor(this.props.activeColor, '#2979ff') : upSelectionColor(this.props.inactiveColor, '#c8c9cc'))
      .borderRadius(this.radius())
      .onClick((): void => this.toggle())
      if (this.props.labelBuilder !== undefined) {
        this.labelRegion()
      } else if (upSelectionText(this.props.label).length > 0) {
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
