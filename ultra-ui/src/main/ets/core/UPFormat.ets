/**
 * 上游 `libs/function/index.js` 里格式化相关工具的 ArkTS 复刻。
 * ArkTS port of the upstream formatting helpers: time formatting, relative time,
 * price formatting, duration normalisation, trimming and query-string building.
 */
import { UPRawValue } from './UPTypes';
import { UPMath } from './UPMath';
import { upDateParts } from './UPValidate';

/** 一天、一小时、一分钟的秒数。/ Second counts used by the relative formatter. */
const UP_SECONDS_PER_MINUTE: number = 60;
const UP_SECONDS_PER_HOUR: number = 3600;
const UP_SECONDS_PER_DAY: number = 86400;
const UP_SECONDS_PER_MONTH: number = 2592000;

/** 查询串数组序列化规则。/ Array serialisation modes for query strings. */
export type UPQueryArrayFormat = 'indices' | 'brackets' | 'repeat' | 'comma';

/** 单个查询参数。/ One query-string entry. */
export interface UPQueryEntry {
  key: string;
  value?: UPRawValue;
  values?: Array<UPRawValue>;
}

/** 时间分量，取代上游对 `Date` 的直接依赖。/ Calendar parts of a moment. */
export interface UPTimeParts {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
}

function textOf(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

export class UPFormat {
  /** 上游 `padZero()`：补足两位。/ Pads a value to two digits. */
  static padZero(value: UPRawValue): string {
    const source: string = '00' + textOf(value);
    return source.slice(source.length - 2);
  }

  /**
   * 上游 `timeFormat()`：把时间戳按 `yyyy-mm-dd hh:MM:ss` 模板格式化。
   * 接受毫秒或 10 位秒级时间戳。上游把假值当作「当前时间」，这里保持纯函数，
   * `0` 就是 1970 起点；需要当前时间时由调用方传入 `Date.now()`。
   * Formats a timestamp with the upstream token set; `0` stays at the epoch.
   */
  static timeFormat(timestamp: number, pattern: string = 'yyyy-mm-dd'): string {
    const parts: UPTimeParts = UPFormat.partsOf(timestamp);
    let result: string = pattern;
    const tokens: Array<string> = ['y', 'm', 'd', 'h', 'M', 's'];
    const values: Array<string> = [
      String(parts.year),
      UPFormat.padZero(parts.month),
      UPFormat.padZero(parts.day),
      UPFormat.padZero(parts.hour),
      UPFormat.padZero(parts.minute),
      UPFormat.padZero(parts.second)
    ];
    for (let index: number = 0; index < tokens.length; index++) {
      const token: string = tokens[index];
      const match: RegExpMatchArray | null = result.match(new RegExp(token + '+'));
      if (match === null) {
        continue;
      }
      const found: string = match[0];
      // 上游允许 `yy` 只取后两位。/ Upstream lets `yy` keep the last two digits.
      const begin: number = token === 'y' && found.length === 2 ? 2 : 0;
      result = result.replace(found, values[index].slice(begin));
    }
    return result;
  }

  /**
   * 上游 `timeFrom()`：5 分钟内「刚刚」，其余按分/时/天分档，超过 30 天走模板或「个月前/年前」。
   * `now` 由调用方传入（组件侧一般传 `Date.now()`），保证纯函数可测。
   * Relative time label; the caller supplies `now`.
   */
  static timeFrom(timestamp: number, now: number, pattern: string = 'yyyy-mm-dd', relativeOnly: boolean = false): string {
    const normalized: number = UPFormat.toMilliseconds(timestamp);
    const elapsed: number = Math.floor((now - normalized) / 1000);
    if (elapsed < 300) {
      return '刚刚';
    }
    if (elapsed < UP_SECONDS_PER_HOUR) {
      return String(Math.floor(elapsed / UP_SECONDS_PER_MINUTE)) + '分钟前';
    }
    if (elapsed < UP_SECONDS_PER_DAY) {
      return String(Math.floor(elapsed / UP_SECONDS_PER_HOUR)) + '小时前';
    }
    if (elapsed < UP_SECONDS_PER_MONTH) {
      return String(Math.floor(elapsed / UP_SECONDS_PER_DAY)) + '天前';
    }
    if (relativeOnly) {
      if (elapsed < 365 * UP_SECONDS_PER_DAY) {
        return String(Math.floor(elapsed / (UP_SECONDS_PER_DAY * 30))) + '个月前';
      }
      return String(Math.floor(elapsed / (UP_SECONDS_PER_DAY * 365))) + '年前';
    }
    return UPFormat.timeFormat(normalized, pattern);
  }

  /**
   * 上游 `priceFormat()`：千分位与定长小数。
   * 清洗字符类与上游逐字一致（`+-E` 在上游是一个字符区间，会连带保留逗号等符号），
   * 因此像 `'1,234.56'` 这样已带千分位的输入在上游与本端都会落到 `0`。
   * Thousands separator plus fixed decimals, keeping the upstream character class verbatim.
   */
  static priceFormat(value: UPRawValue, decimals: number = 0, decimalPoint: string = '.',
                     thousandsSeparator: string = ','): string {
    const cleaned: string = textOf(value).replace(/[^0-9+-Ee.]/g, '');
    const amount: number = Number(cleaned);
    const safeAmount: number = Number.isFinite(amount) ? amount : 0;
    const precision: number = Number.isFinite(decimals) ? Math.abs(Math.floor(decimals)) : 0;
    const rounded: string = precision > 0
      ? String(UPMath.round(safeAmount, precision))
      : String(Math.round(safeAmount));
    const segments: Array<string> = rounded.split('.');
    let head: string = segments[0];
    const pattern: RegExp = /(-?\d+)(\d{3})/;
    while (pattern.test(head)) {
      head = head.replace(pattern, '$1' + thousandsSeparator + '$2');
    }
    let tail: string = segments.length > 1 ? segments[1] : '';
    while (tail.length < precision) {
      tail = tail + '0';
    }
    return precision > 0 ? head + decimalPoint + tail : head;
  }

  /**
   * 上游 `getDuration()`：带单位直接返回，纯数字大于 30 视为毫秒。
   * Normalises an animation duration into a CSS-like string.
   */
  static durationText(value: UPRawValue): string {
    const source: string = textOf(value).trim();
    if (/s$/.test(source)) {
      return source;
    }
    const amount: number = UPFormat.leadingNumber(source);
    return amount > 30 ? String(amount) + 'ms' : String(amount) + 's';
  }

  /** 上游 `getDuration(value, false)`：统一换算为毫秒数。/ Duration in milliseconds. */
  static durationValue(value: UPRawValue): number {
    const source: string = textOf(value).trim();
    const amount: number = UPFormat.leadingNumber(source);
    if (/ms$/.test(source)) {
      return amount;
    }
    if (/s$/.test(source)) {
      return amount > 30 ? amount : amount * 1000;
    }
    return amount;
  }

  /** 上游 `trim()`：`both`/`left`/`right`/`all` 四种模式。/ Trims whitespace. */
  static trim(value: UPRawValue, position: string = 'both'): string {
    const source: string = textOf(value);
    if (position === 'left') {
      return source.replace(/^\s*/, '');
    }
    if (position === 'right') {
      return source.replace(/\s*$/, '');
    }
    if (position === 'all') {
      return source.replace(/\s+/g, '');
    }
    return source.replace(/^\s+|\s+$/g, '');
  }

  /**
   * 上游 `queryParams()`：对象转查询串。ArkTS 无索引签名，改为显式条目数组。
   * Builds a query string from explicit entries.
   */
  static queryParams(entries: Array<UPQueryEntry>, prefix: boolean = true,
                     arrayFormat: UPQueryArrayFormat = 'brackets'): string {
    const parts: Array<string> = [];
    for (let index: number = 0; index < entries.length; index++) {
      const entry: UPQueryEntry = entries[index];
      if (entry.key.length === 0) {
        continue;
      }
      if (entry.values !== undefined) {
        UPFormat.appendList(parts, entry.key, entry.values, arrayFormat);
        continue;
      }
      if (entry.value === null || entry.value === undefined || textOf(entry.value).length === 0) {
        continue;
      }
      parts.push(entry.key + '=' + textOf(entry.value));
    }
    if (parts.length === 0) {
      return '';
    }
    return (prefix ? '?' : '') + parts.join('&');
  }

  /** 上游 `type2icon()`：主题名映射到图标名。/ Maps a theme type to an icon name. */
  static typeIcon(type: string = 'success', fill: boolean = false): string {
    let name: string = 'checkmark-circle';
    if (type === 'primary' || type === 'info') {
      name = 'info-circle';
    } else if (type === 'warning') {
      name = 'error-circle';
    } else if (type === 'error') {
      name = 'close-circle';
    }
    return fill ? name + '-fill' : name;
  }

  /** 毫秒时间戳拆成日历分量，按 UTC 计算以保证跨设备一致。/ UTC calendar parts. */
  static partsOf(timestamp: number): UPTimeParts {
    const value: number = UPFormat.toMilliseconds(timestamp);
    const totalSeconds: number = Math.floor(value / 1000);
    const daySeconds: number = ((totalSeconds % UP_SECONDS_PER_DAY) + UP_SECONDS_PER_DAY) % UP_SECONDS_PER_DAY;
    const dayCount: number = Math.floor((totalSeconds - daySeconds) / UP_SECONDS_PER_DAY);
    const civil: Array<number> = UPFormat.civilFromDays(dayCount);
    return {
      year: civil[0],
      month: civil[1],
      day: civil[2],
      hour: Math.floor(daySeconds / UP_SECONDS_PER_HOUR),
      minute: Math.floor((daySeconds % UP_SECONDS_PER_HOUR) / UP_SECONDS_PER_MINUTE),
      second: daySeconds % UP_SECONDS_PER_MINUTE
    };
  }

  /** `yyyy-mm-dd hh:MM:ss` 转毫秒时间戳（UTC），非法输入返回 0。/ Parses a date string to UTC ms. */
  static timestampOf(value: string): number {
    const parts: Array<number> | undefined = upDateParts(value);
    if (parts === undefined) {
      return 0;
    }
    const days: number = UPFormat.daysFromCivil(parts[0], parts[1], parts[2]);
    return ((days * UP_SECONDS_PER_DAY) + parts[3] * UP_SECONDS_PER_HOUR
      + parts[4] * UP_SECONDS_PER_MINUTE + parts[5]) * 1000;
  }

  /** 10 位时间戳视为秒级，自动放大到毫秒。/ Upgrades 10-digit seconds to milliseconds. */
  static toMilliseconds(timestamp: number): number {
    if (!Number.isFinite(timestamp)) {
      return 0;
    }
    const value: number = Math.floor(timestamp);
    return String(Math.abs(value)).length === 10 ? value * 1000 : value;
  }

  private static leadingNumber(source: string): number {
    const match: RegExpMatchArray | null = source.match(/^-?\d+/);
    if (match === null) {
      return 0;
    }
    const amount: number = Number(match[0]);
    return Number.isFinite(amount) ? amount : 0;
  }

  private static appendList(parts: Array<string>, key: string, values: Array<UPRawValue>,
                            arrayFormat: UPQueryArrayFormat): void {
    if (arrayFormat === 'comma') {
      const joined: Array<string> = [];
      for (let index: number = 0; index < values.length; index++) {
        joined.push(textOf(values[index]));
      }
      parts.push(key + '=' + joined.join(','));
      return;
    }
    for (let index: number = 0; index < values.length; index++) {
      const item: string = textOf(values[index]);
      if (arrayFormat === 'indices') {
        parts.push(key + '[' + String(index) + ']=' + item);
      } else if (arrayFormat === 'repeat') {
        parts.push(key + '=' + item);
      } else {
        parts.push(key + '[]=' + item);
      }
    }
  }

  /** Howard Hinnant 的 days-from-civil 算法，避免依赖平台日期解析。 */
  private static daysFromCivil(year: number, month: number, day: number): number {
    const shiftedYear: number = month <= 2 ? year - 1 : year;
    const era: number = Math.floor((shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) / 400);
    const yearOfEra: number = shiftedYear - era * 400;
    const monthShift: number = month > 2 ? -3 : 9;
    const dayOfYear: number = Math.floor((153 * (month + monthShift) + 2) / 5) + day - 1;
    const dayOfEra: number = yearOfEra * 365 + Math.floor(yearOfEra / 4) - Math.floor(yearOfEra / 100) + dayOfYear;
    return era * 146097 + dayOfEra - 719468;
  }

  private static civilFromDays(dayCount: number): Array<number> {
    const shifted: number = dayCount + 719468;
    const era: number = Math.floor((shifted >= 0 ? shifted : shifted - 146096) / 146097);
    const dayOfEra: number = shifted - era * 146097;
    const yearOfEra: number = Math.floor((dayOfEra - Math.floor(dayOfEra / 1460) + Math.floor(dayOfEra / 36524)
      - Math.floor(dayOfEra / 146096)) / 365);
    const year: number = yearOfEra + era * 400;
    const dayOfYear: number = dayOfEra - (365 * yearOfEra + Math.floor(yearOfEra / 4) - Math.floor(yearOfEra / 100));
    const monthPortion: number = Math.floor((5 * dayOfYear + 2) / 153);
    const day: number = dayOfYear - Math.floor((153 * monthPortion + 2) / 5) + 1;
    const month: number = monthPortion < 10 ? monthPortion + 3 : monthPortion - 9;
    return [month <= 2 ? year + 1 : year, month, day];
  }
}
