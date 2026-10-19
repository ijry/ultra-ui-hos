import { UPRawValue } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import {
  UPFieldRules,
  UPValidateError,
  UPValidateFieldValue,
  UPValidateMessages,
  UPValidateResult,
  UPValidateValue,
  UPValidator,
  upValidateMessagesFor
} from '../core/UPValidator';
import { UPI18n } from '../core/UPI18n';

/** 表单快照，用于 `resetFields()`。/ Snapshot used by resetFields(). */
interface UPFormSnapshot {
  field: string;
  value?: UPValidateValue;
}

export type UPFormControllerListener = (errors: Array<UPValidateError>) => void;

/**
 * 把上游 `u-form` 的实例方法（`validate()`、`validateField()`、`resetFields()`、
 * `clearValidate()`、`setRules()`）搬到 ArkTS 控制器，因为 struct 无法通过模板 ref 调用方法。
 * Bridges the upstream u-form instance methods into an ArkTS controller.
 */
export class UPFormController {
  private descriptors: Array<UPFieldRules> = [];
  private values: Array<UPValidateFieldValue> = [];
  private snapshot: Array<UPFormSnapshot> = [];
  private snapshotTaken: boolean = false;
  private errors: Array<UPValidateError> = [];
  private listener?: UPFormControllerListener;
  private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  private messages?: UPValidateMessages;

  constructor(diagnostics?: UPCompatibilityDiagnostics, messages?: UPValidateMessages) {
    this.diagnostics = diagnostics ?? UP_SILENT_DIAGNOSTICS;
    this.messages = messages;
  }

  /**
   * 未显式传文案时按当前语言挑选：中文走本端扩展的中文表，其余走上游英文表。
   * Picks the message table by the active locale unless the host supplied one.
   */
  private messageTable(): UPValidateMessages {
    return this.messages ?? upValidateMessagesFor(UPI18n.locale());
  }

  /** 覆盖校验文案表。/ Overrides the message table. */
  setMessages(messages?: UPValidateMessages): void {
    this.messages = messages;
  }

  /** `UPForm` 挂载时注册，卸载时注销。/ Mounted by UPForm. */
  mount(listener: UPFormControllerListener): void {
    this.listener = listener;
    this.publish();
  }

  unmount(): void {
    this.listener = undefined;
  }

  /** 上游 `setRules(rules)`。/ Upstream setRules(rules). */
  setRules(descriptors: Array<UPFieldRules>): void {
    this.descriptors = descriptors;
    if (descriptors.length > 0 && this.values.length === 0) {
      this.diagnostics.report('UPFormController', 'rules', String(descriptors.length),
        'rules are set but no model values were provided yet; call setValue()/setValues() first');
    }
  }

  /** 当前规则数量，便于宿主判断是否已配置。/ Rule descriptor count. */
  ruleCount(): number {
    return this.descriptors.length;
  }

  /** 写入单个字段值，并在首次写入时留下重置快照。/ Stores one field value. */
  setValue(field: string, value?: UPValidateValue): void {
    let replaced: boolean = false;
    for (let index: number = 0; index < this.values.length; index++) {
      if (this.values[index].field === field) {
        this.values[index] = { field, value };
        replaced = true;
        break;
      }
    }
    if (!replaced) {
      this.values.push({ field, value });
    }
    this.captureSnapshot();
  }

  /** 批量写入字段值。/ Replaces the whole value list. */
  setValues(values: Array<UPValidateFieldValue>): void {
    this.values = values.slice();
    this.snapshotTaken = false;
    this.captureSnapshot();
  }

  /** 读取当前字段值。/ Reads one field value. */
  valueOf(field: string): UPValidateValue | undefined {
    for (let index: number = 0; index < this.values.length; index++) {
      if (this.values[index].field === field) {
        return this.values[index].value;
      }
    }
    return undefined;
  }

  /** 上游 `validate()`：校验全部字段并回传结果。/ Validates every field. */
  validate(): UPValidateResult {
    if (this.descriptors.length === 0) {
      this.diagnostics.report('UPFormController', 'validate', '',
        'no rules configured; validate() resolves as valid');
      this.errors = [];
      this.publish();
      return { valid: true, errors: [] };
    }
    const result: UPValidateResult = new UPValidator(this.descriptors, this.messageTable()).validate(this.values);
    this.errors = result.errors;
    this.publish();
    return result;
  }

  /**
   * 上游 `validateField(prop, callback, event)`：只校验一个字段，可按触发时机过滤。
   * 校验结果会合并进已有错误集合，与上游逐字段更新 message 的行为一致。
   * Validates one field and merges the outcome into the current error set.
   */
  validateField(field: string, trigger: string = ''): UPValidateResult {
    if (this.descriptors.length === 0) {
      return { valid: true, errors: [] };
    }
    const result: UPValidateResult = new UPValidator(this.descriptors, this.messageTable())
      .validateField(field, this.values, trigger);
    const kept: Array<UPValidateError> = [];
    for (let index: number = 0; index < this.errors.length; index++) {
      if (this.errors[index].field !== field) {
        kept.push(this.errors[index]);
      }
    }
    this.errors = kept.concat(result.errors);
    this.publish();
    return result;
  }

  /** 上游 `clearValidate(props)`：不传则清空全部。/ Clears errors for the given fields. */
  clearValidate(fields?: Array<string>): void {
    if (fields === undefined || fields.length === 0) {
      this.errors = [];
      this.publish();
      return;
    }
    const kept: Array<UPValidateError> = [];
    for (let index: number = 0; index < this.errors.length; index++) {
      if (!fields.includes(this.errors[index].field)) {
        kept.push(this.errors[index]);
      }
    }
    this.errors = kept;
    this.publish();
  }

  /**
   * 上游 `resetFields()`：把值还原到首次快照并清空错误。
   * 上游直接改写调用方的 model 对象，本端只还原控制器内的值，
   * 宿主需要用 `valueOf()` 或 `resetValues()` 同步自己的 @State。
   * Restores the first snapshot; the host re-reads values to sync its own state.
   */
  resetFields(): void {
    const restored: Array<UPValidateFieldValue> = [];
    for (let index: number = 0; index < this.snapshot.length; index++) {
      restored.push({ field: this.snapshot[index].field, value: this.snapshot[index].value });
    }
    this.values = restored;
    this.errors = [];
    this.publish();
  }

  /** 快照内容，便于宿主一次性同步自己的状态。/ The snapshot the host should sync back. */
  resetValues(): Array<UPValidateFieldValue> {
    const copied: Array<UPValidateFieldValue> = [];
    for (let index: number = 0; index < this.snapshot.length; index++) {
      copied.push({ field: this.snapshot[index].field, value: this.snapshot[index].value });
    }
    return copied;
  }

  /** 当前错误集合的副本。/ A copy of the current error list. */
  currentErrors(): Array<UPValidateError> {
    return this.errors.slice();
  }

  /** 某字段的首条错误。/ First error message for one field. */
  errorOf(prop: UPRawValue): string {
    if (prop === null || prop === undefined) {
      return '';
    }
    const field: string = String(prop);
    for (let index: number = 0; index < this.errors.length; index++) {
      if (this.errors[index].field === field) {
        return this.errors[index].message;
      }
    }
    return '';
  }

  private captureSnapshot(): void {
    if (this.snapshotTaken) {
      return;
    }
    const taken: Array<UPFormSnapshot> = [];
    for (let index: number = 0; index < this.values.length; index++) {
      taken.push({ field: this.values[index].field, value: this.values[index].value });
    }
    this.snapshot = taken;
    this.snapshotTaken = taken.length > 0;
  }

  private publish(): void {
    this.listener?.(this.errors.slice());
  }
}
