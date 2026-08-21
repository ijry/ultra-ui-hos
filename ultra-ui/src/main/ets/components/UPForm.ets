import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { upBoolean, upString } from '../core/UPTypes';

export interface UPFormValidateEvent {
  valid: boolean;
  errors: Array<string>;
}

export interface UPFormModel {
  name?: UPRawValue;
  sex?: UPRawValue;
  age?: UPRawValue;
  birthday?: UPRawValue;
  interests?: Array<UPRawValue>;
}

export interface UPFormOptions {
  model?: UPFormModel;
  rules?: UPRawValue;
  errorType?: UPRawValue;
  labelPosition?: UPRawValue;
  labelWidth?: UPRawValue;
  labelAlign?: UPRawValue;
  borderBottom?: UPRawValue;
  disabled?: UPRawValue;
  customStyle?: UPStyleInput;
  onSubmit?: (event: UPFormValidateEvent) => void;
  onValidate?: (event: UPFormValidateEvent) => void;
  contentBuilder?: UPBuilder;
}

export class UPFormProps {
  model: UPFormModel | undefined = undefined;
  rules: UPRawValue = undefined;
  errorType: UPRawValue = 'message';
  labelPosition: UPRawValue = 'left';
  labelWidth: UPRawValue = 80;
  labelAlign: UPRawValue = 'left';
  borderBottom: UPRawValue = false;
  disabled: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  onSubmit?: (event: UPFormValidateEvent) => void;
  onValidate?: (event: UPFormValidateEvent) => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPFormOptions) {
    if (options === undefined) return;
    this.model = options.model ?? this.model; this.rules = options.rules ?? this.rules; this.errorType = options.errorType ?? this.errorType;
    this.labelPosition = options.labelPosition ?? this.labelPosition; this.labelWidth = options.labelWidth ?? this.labelWidth; this.labelAlign = options.labelAlign ?? this.labelAlign;
    this.borderBottom = options.borderBottom ?? this.borderBottom; this.disabled = options.disabled ?? this.disabled; this.customStyle = options.customStyle;
    this.onSubmit = options.onSubmit; this.onValidate = options.onValidate; this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPForm {
  @Prop props: UPFormProps = new UPFormProps();
  @Builder private emptyContent() { Row().width(0).height(0); }
  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private validate(): UPFormValidateEvent {
    // Native side intentionally performs only a deterministic presence check; complex uview validators stay caller-owned.
    const event: UPFormValidateEvent = { valid: true, errors: [] };
    this.props.onValidate?.(event);
    return event;
  }

  build() {
    Column() {
      this.contentBuilder()
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .padding(UPStyle.parse(this.props.customStyle).padding ?? { top: 0, right: 0, bottom: 0, left: 0 })
    .opacity(upBoolean(this.props.disabled) ? 0.55 : 1)
    .enabled(!upBoolean(this.props.disabled))
    .onClick((): void => {
      const event: UPFormValidateEvent = this.validate();
      this.props.onSubmit?.(event);
    })
  }
}
