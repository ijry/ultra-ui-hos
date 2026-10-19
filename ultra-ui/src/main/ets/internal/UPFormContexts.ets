/**
 * 表单校验结果的共享上下文：`UPForm` 提供，`UPFormItem` 消费。
 * Shared validation state: provided by `UPForm`, consumed by every `UPFormItem`,
 * because ArkTS structs cannot reach into each other the way Vue refs do.
 */
import { UPRawValue } from '../core/UPTypes';
import { UPValidateError } from '../core/UPValidator';

/** 上游 `errorType` 的取值。/ Upstream errorType values. */
export type UPFormErrorType = 'message' | 'toast' | 'border-bottom' | 'none';

export class UPFormContext {
  /** 当前所有字段的错误。/ Errors for every field in the current pass. */
  errors: Array<UPValidateError> = [];
  /** 上游 `errorType`，决定 `UPFormItem` 怎样呈现错误。/ How items render an error. */
  errorType: UPFormErrorType = 'message';
  /** 上游 `borderBottom`，作为子项的默认下划线开关。/ Default underline switch. */
  borderBottom: boolean = false;
  /** 上游 `labelPosition` / `labelWidth` / `labelAlign` 的下发值。/ Inherited label layout. */
  labelPosition: string = 'left';
  labelWidth: UPRawValue = 80;
  labelAlign: string = 'left';
  /** 表单整体禁用态。/ Whether the whole form is disabled. */
  disabled: boolean = false;
  /** 是否由 `UPForm` 托管（未被 `UPForm` 包裹时为 false）。/ Whether a form owns this item. */
  managed: boolean = false;

  /** 某字段的首条错误文案。/ First error message bound to one field. */
  errorOf(prop: UPRawValue): string {
    if (prop === null || prop === undefined) {
      return '';
    }
    const field: string = String(prop);
    if (field.length === 0) {
      return '';
    }
    for (let index: number = 0; index < this.errors.length; index++) {
      if (this.errors[index].field === field) {
        return this.errors[index].message;
      }
    }
    return '';
  }

  /** 某字段是否有错误。/ Whether one field currently fails. */
  hasError(prop: UPRawValue): boolean {
    return this.errorOf(prop).length > 0;
  }
}
