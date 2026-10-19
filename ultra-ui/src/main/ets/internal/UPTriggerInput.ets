/**
 * 上游 picker 与 datetime-picker 的 `hasInput` 触发输入框：具名模型加只读展示行。
 * The `hasInput` trigger row shared by the upstream picker and datetime-picker.
 */
import { UPRawValue, UPStyleInput, upString } from '../core/UPTypes';
import { UPI18n, upWeekText } from '../core/UPI18n';

/** 上游 `up-input` 的 border 取值。/ Accepted border values of the upstream input. */
export const UP_TRIGGER_BORDER_MODES: Array<string> = ['surround', 'bottom', 'none'];
/** 上游 `defProps.input.border` 的默认值。/ Default border of the upstream input. */
export const UP_TRIGGER_DEFAULT_BORDER: string = 'surround';
/** 上游 `up.common.pleaseChoose` 的默认占位文案。/ Default placeholder from the upstream i18n table. */
export const UP_TRIGGER_PLACEHOLDER: string = UPI18n.t('up.common.pleaseChoose');
/** 上游 `defProps.input.disabledColor` 的禁用底色。/ Disabled background of the upstream input. */
export const UP_TRIGGER_DISABLED_COLOR: string = '#f5f7fa';
/** 触发行的高度与内边距，对应 `up-input` 的默认外观。/ Height and padding of the trigger row. */
export const UP_TRIGGER_HEIGHT: number = 38;
export const UP_TRIGGER_PADDING: number = 9;
/** 触发行的描边与文字取色。/ Border and text colors of the trigger row. */
export const UP_TRIGGER_BORDER_COLOR: string = '#dadbde';
export const UP_TRIGGER_TEXT_COLOR: string = '#303133';
export const UP_TRIGGER_PLACEHOLDER_COLOR: string = '#c0c4cc';

/**
 * 上游 `inputProps` 的具名子集，替代任意透传对象。
 * Named subset of the upstream inputProps instead of an arbitrary pass-through object.
 */
export interface UPTriggerInputProps {
  border?: string;
  placeholder?: string;
  disabled?: boolean;
  disabledColor?: string;
  fontSize?: number;
  color?: string;
  inputAlign?: string;
  shape?: string;
  customStyle?: UPStyleInput;
}

/** 触发行的最终外观，合并 `inputProps` 与外层字段。/ Resolved trigger appearance. */
export class UPTriggerInputStyle {
  border: string = UP_TRIGGER_DEFAULT_BORDER;
  placeholder: string = UP_TRIGGER_PLACEHOLDER;
  disabled: boolean = false;
  disabledColor: string = UP_TRIGGER_DISABLED_COLOR;
  fontSize: number = 15;
  color: string = UP_TRIGGER_TEXT_COLOR;
  inputAlign: string = 'left';
  shape: string = 'square';
}

/** border 是否落在上游取值内。/ Whether the border mode is modelled upstream. */
export function upTriggerBorderSupported(border: string): boolean {
  return border.length === 0 || UP_TRIGGER_BORDER_MODES.includes(border);
}

/**
 * 上游 `inputPropsInner`：外层字段先落位，`inputProps` 覆盖同名键。
 * Mirrors the upstream inputPropsInner spread order.
 */
export function upTriggerInputStyle(border: UPRawValue, placeholder: UPRawValue, disabled: boolean,
  disabledColor: UPRawValue, overrides?: UPTriggerInputProps): UPTriggerInputStyle {
  const style: UPTriggerInputStyle = new UPTriggerInputStyle();
  const borderValue: string = upString(border, UP_TRIGGER_DEFAULT_BORDER);
  style.border = borderValue.length > 0 ? borderValue : UP_TRIGGER_DEFAULT_BORDER;
  const placeholderValue: string = upString(placeholder, UP_TRIGGER_PLACEHOLDER);
  style.placeholder = placeholderValue.length > 0 ? placeholderValue : UP_TRIGGER_PLACEHOLDER;
  style.disabled = disabled;
  const disabledValue: string = upString(disabledColor, '');
  style.disabledColor = disabledValue.length > 0 ? disabledValue : UP_TRIGGER_DISABLED_COLOR;
  if (overrides === undefined) {
    return style;
  }
  style.border = overrides.border ?? style.border;
  style.placeholder = overrides.placeholder ?? style.placeholder;
  style.disabled = overrides.disabled ?? style.disabled;
  style.disabledColor = overrides.disabledColor ?? style.disabledColor;
  style.fontSize = overrides.fontSize ?? style.fontSize;
  style.color = overrides.color ?? style.color;
  style.inputAlign = overrides.inputAlign ?? style.inputAlign;
  style.shape = overrides.shape ?? style.shape;
  return style;
}

/** 触发行的描边宽度。/ Border width of the trigger row. */
export function upTriggerBorderWidth(border: string): number {
  return border === 'none' ? 0 : 1;
}

/** `bottom` 模式只画下边框。/ The bottom mode draws a single underline. */
export function upTriggerBottomOnly(border: string): boolean {
  return border === 'bottom';
}

/** 触发行圆角，`circle` 形状按半高。/ Trigger radius; the circle shape uses half the height. */
export function upTriggerRadius(shape: string, height: number): number {
  return shape === 'circle' ? height / 2 : 3;
}

/** 触发行文本对齐。/ Text alignment of the trigger row. */
export function upTriggerTextAlign(inputAlign: string): TextAlign {
  if (inputAlign === 'center') {
    return TextAlign.Center;
  }
  return inputAlign === 'right' ? TextAlign.End : TextAlign.Start;
}

/**
 * 上游 dayjs 的 format 子集：`YYYY`/`MM`/`DD`/`HH`/`mm`/`ss`。
 * Subset of the upstream dayjs tokens used by the datetime picker.
 */
export function upTriggerFormat(format: string, year: number, month: number, day: number,
  hour: number, minute: number, second: number): string {
  const pad = (value: number): string => String(value).padStart(2, '0');
  return format
    .replace('YYYY', String(year))
    .replace('MM', pad(month))
    .replace('DD', pad(day))
    .replace('HH', pad(hour))
    .replace('mm', pad(minute))
    .replace('ss', pad(second));
}
