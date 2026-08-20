import { UPRawValue, UPStyleInput, UPBuilder, upBoolean } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCollapseContext, UPCollapseContextChange, UPCollapseValue } from '../internal/UPInteractionContexts';

export interface UPCollapseChangeEvent extends UPCollapseContextChange {}
export interface UPCollapseOptions {
  value?: UPCollapseValue; modelValue?: UPCollapseValue; accordion?: UPRawValue; border?: UPRawValue;
  arrow?: UPRawValue; disabled?: UPRawValue; clickable?: UPRawValue; customStyle?: UPStyleInput;
  onChange?: (event: UPCollapseChangeEvent) => void; onValueChange?: (value: UPCollapseValue) => void;
  contentBuilder?: UPBuilder;
}
export class UPCollapseProps {
  value: UPCollapseValue = []; modelValue: UPCollapseValue = undefined; accordion: UPRawValue = false;
  border: UPRawValue = true; arrow: UPRawValue = true; disabled: UPRawValue = false;
  clickable: UPRawValue = true; customStyle: UPStyleInput = undefined;
  onChange?: (event: UPCollapseChangeEvent) => void; onValueChange?: (value: UPCollapseValue) => void;
  contentBuilder?: UPBuilder;
  constructor(options?: UPCollapseOptions) {
    if (options === undefined) return;
    this.value = options.value ?? this.value; this.modelValue = options.modelValue ?? this.modelValue;
    this.accordion = options.accordion ?? this.accordion; this.border = options.border ?? this.border;
    this.arrow = options.arrow ?? this.arrow; this.disabled = options.disabled ?? this.disabled;
    this.clickable = options.clickable ?? this.clickable; this.customStyle = options.customStyle;
    this.onChange = options.onChange; this.onValueChange = options.onValueChange; this.contentBuilder = options.contentBuilder;
  }
}
@Component
export struct UPCollapse {
  @Prop @Watch('refreshContext') props: UPCollapseProps = new UPCollapseProps();
  @Provide('UPCollapseContext') collapseContext: UPCollapseContext = new UPCollapseContext();
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  aboutToAppear(): void { this.refreshContext(); }
  private controlledValue(): UPCollapseValue {
    return this.props.modelValue !== null && this.props.modelValue !== undefined ? this.props.modelValue : this.props.value;
  }
  refreshContext(): void {
    this.collapseContext = new UPCollapseContext();
    this.collapseContext.beginComposition(this.controlledValue(), upBoolean(this.props.accordion, false),
      upBoolean(this.props.disabled, false), upBoolean(this.props.clickable, true), this.props.onValueChange, this.props.onChange);
  }
  build() {
    Column() { this.contentBuilder() }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
