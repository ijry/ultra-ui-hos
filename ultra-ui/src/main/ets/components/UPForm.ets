import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPFieldRules, UPValidateError, UPValidateFieldValue } from '../core/UPValidator';
import { UPFormController } from '../controllers/UPFormController';
import { UPFormContext, UPFormErrorType } from '../internal/UPFormContexts';

/** 上游 `validate()` 的结果载荷。/ Upstream validate() payload. */
export interface UPFormValidateEvent {
  valid: boolean;
  errors: Array<string>;
}

/** 上游 `errorType: 'toast'` 时的提示请求。/ Toast request raised by errorType. */
export interface UPFormErrorToastEvent {
  message: string;
  field: string;
}

/**
 * 上游 model 是任意对象；ArkTS 无索引签名，改为显式字段值数组。
 * 既有的具名快捷字段保留，方便早期调用方继续使用。
 * The upstream model is an arbitrary object; ArkTS needs explicit field entries.
 */
export interface UPFormModel {
  name?: UPRawValue;
  sex?: UPRawValue;
  age?: UPRawValue;
  birthday?: UPRawValue;
  interests?: Array<UPRawValue>;
}

export interface UPFormOptions {
  model?: UPFormModel;
  /** 显式字段值，优先于 `model`。/ Explicit field values; takes priority over `model`. */
  values?: Array<UPValidateFieldValue>;
  /** 上游 rules 的 ArkTS 形态。/ The ArkTS shape of the upstream rules object. */
  rules?: Array<UPFieldRules>;
  errorType?: UPRawValue;
  labelPosition?: UPRawValue;
  labelWidth?: UPRawValue;
  labelAlign?: UPRawValue;
  borderBottom?: UPRawValue;
  disabled?: UPRawValue;
  customStyle?: UPStyleInput;
  controller?: UPFormController;
  diagnostics?: UPCompatibilityDiagnostics;
  onSubmit?: (event: UPFormValidateEvent) => void;
  onValidate?: (event: UPFormValidateEvent) => void;
  /** `errorType` 为 toast 时由宿主承担提示。/ Raised when errorType is toast. */
  onErrorToast?: (event: UPFormErrorToastEvent) => void;
  contentBuilder?: UPBuilder;
}

export class UPFormProps {
  model: UPFormModel | undefined = undefined;
  values: Array<UPValidateFieldValue> = [];
  rules: Array<UPFieldRules> = [];
  errorType: UPRawValue = 'message';
  labelPosition: UPRawValue = 'left';
  labelWidth: UPRawValue = 80;
  labelAlign: UPRawValue = 'left';
  borderBottom: UPRawValue = false;
  disabled: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  controller?: UPFormController;
  diagnostics?: UPCompatibilityDiagnostics;
  onSubmit?: (event: UPFormValidateEvent) => void;
  onValidate?: (event: UPFormValidateEvent) => void;
  onErrorToast?: (event: UPFormErrorToastEvent) => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPFormOptions) {
    if (options === undefined) return;
    this.model = options.model ?? this.model;
    this.values = options.values ?? this.values;
    this.rules = options.rules ?? this.rules;
    this.errorType = options.errorType ?? this.errorType;
    this.labelPosition = options.labelPosition ?? this.labelPosition; this.labelWidth = options.labelWidth ?? this.labelWidth; this.labelAlign = options.labelAlign ?? this.labelAlign;
    this.borderBottom = options.borderBottom ?? this.borderBottom; this.disabled = options.disabled ?? this.disabled; this.customStyle = options.customStyle;
    this.controller = options.controller;
    this.diagnostics = options.diagnostics;
    this.onSubmit = options.onSubmit; this.onValidate = options.onValidate;
    this.onErrorToast = options.onErrorToast;
    this.contentBuilder = options.contentBuilder;
  }
}

/** 把上游 `errorType` 字符串收敛到白名单。/ Narrows errorType to the upstream whitelist. */
export function upFormErrorType(value: UPRawValue): UPFormErrorType {
  const source: string = upString(value, 'message').toLowerCase();
  if (source === 'toast' || source === 'border-bottom' || source === 'none') {
    return source as UPFormErrorType;
  }
  return 'message';
}

/** 具名 model 字段转成显式字段值数组。/ Flattens the named model into field entries. */
function modelValues(model: UPFormModel | undefined): Array<UPValidateFieldValue> {
  if (model === undefined) {
    return [];
  }
  const values: Array<UPValidateFieldValue> = [];
  if (model.name !== undefined) values.push({ field: 'name', value: model.name });
  if (model.sex !== undefined) values.push({ field: 'sex', value: model.sex });
  if (model.age !== undefined) values.push({ field: 'age', value: model.age });
  if (model.birthday !== undefined) values.push({ field: 'birthday', value: model.birthday });
  if (model.interests !== undefined) values.push({ field: 'interests', value: model.interests });
  return values;
}

@Component
export struct UPForm {
  @Prop @Watch('syncModel') props: UPFormProps = new UPFormProps();
  @Provide('UPFormContext') formContext: UPFormContext = new UPFormContext();
  @Builder private emptyContent() { Row().width(0).height(0); }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  private owned: UPFormController = new UPFormController();
  private mounted: boolean = false;

  aboutToAppear(): void {
    this.mounted = true;
    this.controller().mount((errors: Array<UPValidateError>): void => this.receive(errors));
    this.syncModel();
  }

  aboutToDisappear(): void {
    this.mounted = false;
    this.controller().unmount();
  }

  private controller(): UPFormController {
    return this.props.controller ?? this.owned;
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  /** props 变更时把规则与值同步给控制器，并刷新下发的布局口径。/ Re-syncs rules and values. */
  private syncModel(): void {
    const controller: UPFormController = this.controller();
    controller.setRules(this.props.rules);
    const values: Array<UPValidateFieldValue> = this.props.values.length > 0
      ? this.props.values
      : modelValues(this.props.model);
    controller.setValues(values);
    if (this.props.rules.length > 0 && values.length === 0) {
      this.diagnostics().report('UPForm', 'rules', String(this.props.rules.length),
        'rules are set but the model carries no values; pass `values` or a populated `model`');
    }
    this.refreshContext(controller.currentErrors());
  }

  private refreshContext(errors: Array<UPValidateError>): void {
    const next: UPFormContext = new UPFormContext();
    next.errors = errors;
    next.errorType = upFormErrorType(this.props.errorType);
    next.borderBottom = upBoolean(this.props.borderBottom, false);
    next.labelPosition = upString(this.props.labelPosition, 'left');
    next.labelWidth = this.props.labelWidth;
    next.labelAlign = upString(this.props.labelAlign, 'left');
    next.disabled = upBoolean(this.props.disabled, false);
    next.managed = true;
    this.formContext = next;
  }

  /** 控制器回传错误时刷新上下文，并按 errorType 决定是否请求 toast。/ Applies new errors. */
  private receive(errors: Array<UPValidateError>): void {
    if (!this.mounted) {
      return;
    }
    this.refreshContext(errors);
    const messages: Array<string> = [];
    for (let index: number = 0; index < errors.length; index++) {
      messages.push(errors[index].message);
    }
    const event: UPFormValidateEvent = { valid: errors.length === 0, errors: messages };
    this.props.onValidate?.(event);
    if (errors.length > 0 && upFormErrorType(this.props.errorType) === 'toast') {
      // ArkUI 没有全局 toast，交给宿主用 UPToastController 呈现。
      this.props.onErrorToast?.({ message: errors[0].message, field: errors[0].field });
    }
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
      const result = this.controller().validate();
      const messages: Array<string> = [];
      for (let index: number = 0; index < result.errors.length; index++) {
        messages.push(result.errors[index].message);
      }
      this.props.onSubmit?.({ valid: result.valid, errors: messages });
    })
  }
}
