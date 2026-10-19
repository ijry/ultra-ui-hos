/**
 * 上游 `libs/function/test.js` 的 ArkTS 复刻：一组纯函数校验器。
 * ArkTS port of the upstream validator helpers; every check is a pure function
 * over `UPRawValue` so callers never need runtime type probing.
 */
import { UPRawValue } from './UPTypes';

/** 空值与空串统一转成空字符串，便于正则匹配。/ Normalizes a raw value into a string. */
function textOf(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

/** 上游 `email()`。/ Mirrors the upstream email check. */
export function upIsEmail(value: UPRawValue): boolean {
  return /^\w+((-\w+)|(\.\w+))*@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/.test(textOf(value));
}

/** 上游 `mobile()`：仅校验中国大陆 11 位号码。/ Mainland China mobile number. */
export function upIsMobile(value: UPRawValue): boolean {
  return /^1[23456789]\d{9}$/.test(textOf(value));
}

/** 上游 `url()`。/ Mirrors the upstream URL check. */
export function upIsUrl(value: UPRawValue): boolean {
  const source: string = textOf(value);
  const pattern: RegExp = /^((https|http|ftp|rtsp|mms):\/\/)(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?(([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9a-zA-Z_!~*'()-]+\.)*([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\.[a-zA-Z]{2,6})(:[0-9]{1,4})?((\/?)|(\/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+\/?)$/;
  return pattern.test(source);
}

/** 上游 `date()`：接受 10/13 位时间戳与 `yyyy-mm-dd hh:mm:ss` 区间。/ Timestamp or date string. */
export function upIsDate(value: UPRawValue): boolean {
  if (value === null || value === undefined || value === '') {
    return false;
  }
  if (typeof value === 'number') {
    const digits: string = String(value);
    if (digits.length !== 10 && digits.length !== 13) {
      return false;
    }
    return Number.isFinite(value);
  }
  if (typeof value !== 'string') {
    return false;
  }
  const source: string = value;
  const numeric: number = Number(source);
  if (Number.isFinite(numeric) && source.trim().length > 0) {
    const digits: string = String(numeric);
    if (digits.length === 10 || digits.length === 13) {
      return true;
    }
  }
  if (source.length < 10 || source.length > 19) {
    return false;
  }
  if (!/^\d{4}[-/]\d{2}[-/]\d{2}( \d{1,2}:\d{2}(:\d{2})?)?$/.test(source)) {
    return false;
  }
  return upDateParts(source) !== undefined;
}

/**
 * 解析 `yyyy-mm-dd[ hh:mm[:ss]]`，返回 `[年, 月, 日, 时, 分, 秒]`。
 * 区间判定与平台 `Date` 的 ISO 解析一致：月 1–12、日 1–31、时 0–23、分秒 0–59，
 * 因此 `2024-02-30` 这类溢出日期会通过（上游同样通过并在换算时进位）。
 * Parses a date without the platform Date parser, using the same range bounds.
 */
export function upDateParts(value: string): Array<number> | undefined {
  const match: RegExpMatchArray | null = value.match(/^(\d{4})[-/](\d{2})[-/](\d{2})(?: (\d{1,2}):(\d{2})(?::(\d{2}))?)?$/);
  if (match === null) {
    return undefined;
  }
  const year: number = Number(match[1]);
  const month: number = Number(match[2]);
  const day: number = Number(match[3]);
  const hour: number = match[4] === undefined ? 0 : Number(match[4]);
  const minute: number = match[5] === undefined ? 0 : Number(match[5]);
  const second: number = match[6] === undefined ? 0 : Number(match[6]);
  if (month < 1 || month > 12 || day < 1 || day > 31) {
    return undefined;
  }
  if (hour > 23 || minute > 59 || second > 59) {
    return undefined;
  }
  return [year, month, day, hour, minute, second];
}

/**
 * 严格日历判定：在 `upDateParts()` 的基础上要求日期落在该月实际天数内。
 * 上游 `date()` 依赖 `Date` 的溢出进位，因此 `2024-02-30` 在上游为真、在这里为假。
 * Stricter calendar check; upstream relies on Date rollover instead.
 */
export function upIsCalendarDate(value: UPRawValue): boolean {
  const parts: Array<number> | undefined = upDateParts(textOf(value));
  if (parts === undefined) {
    return false;
  }
  return parts[2] <= upDaysInMonth(parts[0], parts[1]);
}

/** 闰年判定。/ Gregorian leap year test. */
export function upIsLeapYear(year: number): boolean {
  return (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
}

/** 某年某月的天数。/ Days in the given month. */
export function upDaysInMonth(year: number, month: number): number {
  if (month === 2) {
    return upIsLeapYear(year) ? 29 : 28;
  }
  if (month === 4 || month === 6 || month === 9 || month === 11) {
    return 30;
  }
  return 31;
}

/** 上游 `dateISO()`。/ ISO-like `yyyy-mm-dd` shape. */
export function upIsDateISO(value: UPRawValue): boolean {
  return /^\d{4}[/-](0?[1-9]|1[012])[/-](0?[1-9]|[12][0-9]|3[01])$/.test(textOf(value));
}

/** 上游 `number()`：十进制数字，允许符号与指数。/ Decimal number. */
export function upIsNumeric(value: UPRawValue): boolean {
  return /^[+-]?(\d+\.?\d*|\.\d+|\d\.\d+e\+\d+)$/.test(textOf(value));
}

/** 上游 `digits()`：纯整数。/ Digits only. */
export function upIsDigits(value: UPRawValue): boolean {
  return /^\d+$/.test(textOf(value));
}

/** 上游 `idCard()`：18 位身份证。/ Mainland China resident ID. */
export function upIsIdCard(value: UPRawValue): boolean {
  return /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.test(textOf(value));
}

/** 上游 `carNo()`：7 位旧车牌或 8 位新能源车牌。/ Vehicle plate number. */
export function upIsCarNo(value: UPRawValue): boolean {
  const source: string = textOf(value);
  const energy: RegExp = /^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}(([0-9]{5}[DF]$)|([DF][A-HJ-NP-Z0-9][0-9]{4}$))/;
  const classic: RegExp = /^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[A-HJ-NP-Z0-9]{4}[A-HJ-NP-Z0-9挂学警港澳]{1}$/;
  if (source.length === 7) {
    return classic.test(source);
  }
  if (source.length === 8) {
    return energy.test(source);
  }
  return false;
}

/** 上游 `amount()`：最多两位小数的金额。/ Money with at most two decimals. */
export function upIsAmount(value: UPRawValue): boolean {
  return /^[1-9]\d*(,\d{3})*(\.\d{1,2})?$|^0\.\d{1,2}$/.test(textOf(value));
}

/** 上游 `chinese()`。/ Chinese characters only. */
export function upIsChinese(value: UPRawValue): boolean {
  return /^[\u4e00-\u9fa5]+$/.test(textOf(value));
}

/** 上游 `letter()`。/ Latin letters only (empty string passes, as upstream). */
export function upIsLetter(value: UPRawValue): boolean {
  return /^[a-zA-Z]*$/.test(textOf(value));
}

/** 上游 `enOrNum()`。/ Letters or digits (empty string passes, as upstream). */
export function upIsEnOrNum(value: UPRawValue): boolean {
  return /^[0-9a-zA-Z]*$/.test(textOf(value));
}

/** 上游 `contains()`。/ Substring containment. */
export function upContains(value: UPRawValue, keyword: UPRawValue): boolean {
  return textOf(value).indexOf(textOf(keyword)) >= 0;
}

/** 上游 `range()`：闭区间数值判定。/ Inclusive numeric range. */
export function upInRange(value: UPRawValue, minimum: number, maximum: number): boolean {
  const amount: number = Number(textOf(value));
  if (!Number.isFinite(amount)) {
    return false;
  }
  return amount >= minimum && amount <= maximum;
}

/** 上游 `rangeLength()`：闭区间长度判定。/ Inclusive length range. */
export function upInRangeLength(value: UPRawValue, minimum: number, maximum: number): boolean {
  const length: number = textOf(value).length;
  return length >= minimum && length <= maximum;
}

/** 上游 `landline()`：固定电话。/ Landline number. */
export function upIsLandline(value: UPRawValue): boolean {
  return /^\d{3,4}-\d{7,8}(-\d{3,4})?$/.test(textOf(value));
}

/** 上游 `code()`：定长短信验证码，默认 6 位。/ Fixed-length SMS code. */
export function upIsCode(value: UPRawValue, length: number = 6): boolean {
  const size: number = Math.max(1, Math.floor(length));
  const source: string = textOf(value);
  return source.length === size && /^\d+$/.test(source);
}

/** 上游 `image()`：按扩展名判定图片，忽略查询串。/ Image extension check. */
export function upIsImage(value: UPRawValue): boolean {
  const source: string = textOf(value).split('?')[0];
  return /\.(jpeg|jpg|gif|png|svg|webp|jfif|bmp|dpg)/i.test(source);
}

/** 上游 `video()`：按扩展名判定视频。/ Video extension check. */
export function upIsVideo(value: UPRawValue): boolean {
  return /\.(mp4|mpg|mpeg|dat|asf|avi|rm|rmvb|mov|wmv|flv|mkv|m3u8)/i.test(textOf(value));
}

/**
 * 上游 `empty()` 在 ArkTS 下的等价：`UPRawValue` 只有标量，
 * 空串（含纯空白）、`0`、`NaN`、`false`、`null`、`undefined` 均视为空。
 * Upstream `empty()` for scalar values.
 */
export function upIsEmpty(value: UPRawValue): boolean {
  if (value === null || value === undefined) {
    return true;
  }
  if (typeof value === 'string') {
    return value.replace(/(^[ \t\n\r]*)|([ \t\n\r]*$)/g, '').length === 0;
  }
  if (typeof value === 'boolean') {
    return !value;
  }
  return value === 0 || !Number.isFinite(value);
}

/** 空数组判定，替代上游对 object/array 的 `empty()` 分支。/ Empty list check. */
export function upIsEmptyList(value: Array<UPRawValue> | undefined | null): boolean {
  return value === null || value === undefined || value.length === 0;
}
