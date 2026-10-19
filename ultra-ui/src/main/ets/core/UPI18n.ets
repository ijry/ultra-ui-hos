/**
 * 上游 `libs/i18n/index.js` 的 ArkTS 复刻：语言标签、文案查表与占位符替换。
 * ArkTS port of the upstream i18n runtime. The platform locale is not read here —
 * `uni.getLocale()` / `uni.onLocaleChange()` have no ArkTS equivalent in this HAR,
 * so the host sets the tag explicitly and the default stays `zh-Hans` like upstream.
 */
import { UPRawValue } from './UPTypes';
import { UPLocaleCatalog } from '../internal/UPLocaleCatalog';

/** 上游默认语言。/ The upstream default locale. */
export const UP_DEFAULT_LOCALE: string = 'zh-Hans';

/** 一个占位符替换项，取代上游 `t(key, params)` 的对象入参。/ One placeholder binding. */
export interface UPI18nParam {
  name: string;
  value: UPRawValue;
}

/**
 * 全局文案状态。上游用模块级 `settings` 单例，本端同样用静态单例，
 * 以便组件默认值在不接收 props 时也能取到当前语言。
 * Module-level locale state, mirroring the upstream `settings` singleton.
 */
export class UPI18n {
  private static currentLocale: string = UP_DEFAULT_LOCALE;
  private static overrides: Map<string, Map<string, string>> = new Map<string, Map<string, string>>();

  /** 上游 `getLocale()`。/ Upstream getLocale(). */
  static locale(): string {
    return UPI18n.currentLocale;
  }

  /** 上游 `setLocale(locale)`：非法值不改变状态并返回当前值。/ Upstream setLocale(). */
  static setLocale(locale: string): string {
    if (locale.length === 0) {
      return UPI18n.currentLocale;
    }
    UPI18n.currentLocale = locale;
    return UPI18n.currentLocale;
  }

  /** 上游 `hasLocale(locale)`：内置或已注册均算命中。/ Upstream hasLocale(). */
  static hasLocale(locale: string): boolean {
    return UPLocaleCatalog.has(locale) || UPI18n.overrides.has(locale);
  }

  /** 内置语言标签，顺序与上游 `locales/all.js` 一致。/ Bundled locale tags. */
  static locales(): Array<string> {
    return UPLocaleCatalog.TAGS.slice();
  }

  /** 全部文案键。/ Every message key. */
  static keys(): Array<string> {
    return UPLocaleCatalog.keys();
  }

  /**
   * 上游 `registerLocale(locale, messages)`：注册或覆盖某语言的文案。
   * 同一语言重复注册时按键合并，未覆盖的键继续走内置表。
   * Registers or overrides copy for one locale; unset keys fall back to the bundle.
   */
  static registerLocale(locale: string, messages: Array<UPI18nParam>): void {
    if (locale.length === 0 || messages.length === 0) {
      return;
    }
    let table: Map<string, string> | undefined = UPI18n.overrides.get(locale);
    if (table === undefined) {
      table = new Map<string, string>();
      UPI18n.overrides.set(locale, table);
    }
    for (let index: number = 0; index < messages.length; index++) {
      const entry: UPI18nParam = messages[index];
      table.set(entry.name, entry.value === null || entry.value === undefined ? '' : String(entry.value));
    }
  }

  /** 清除某语言的注册覆盖；不传则清空全部。/ Drops registered overrides. */
  static clearLocale(locale?: string): void {
    if (locale === undefined || locale.length === 0) {
      UPI18n.overrides = new Map<string, Map<string, string>>();
      return;
    }
    UPI18n.overrides.delete(locale);
  }

  /**
   * 上游 `t(key, params)`：按当前语言取文案，缺失语言回落 `zh-Hans`，缺失键回落键名本身。
   * 占位符形如 `{days}`，与上游同一语法。
   * Upstream t(key, params); missing locales fall back to zh-Hans, missing keys to the key.
   */
  static t(key: string, params?: Array<UPI18nParam>): string {
    return UPI18n.translate(UPI18n.currentLocale, key, params);
  }

  /** 指定语言取文案，便于宿主并列展示多语言。/ Translates against an explicit locale. */
  static translate(locale: string, key: string, params?: Array<UPI18nParam>): string {
    if (key.length === 0) {
      return key;
    }
    let result: string = UPI18n.lookup(locale, key);
    if (result.length === 0) {
      result = UPI18n.lookup(UP_DEFAULT_LOCALE, key);
    }
    if (result.length === 0) {
      result = key;
    }
    if (params === undefined || params.length === 0) {
      return result;
    }
    for (let index: number = 0; index < params.length; index++) {
      const param: UPI18nParam = params[index];
      const replacement: string = param.value === null || param.value === undefined
        ? ''
        : String(param.value);
      result = result.replace(new RegExp('\\{' + param.name + '\\}', 'g'), replacement);
    }
    return result;
  }

  private static lookup(locale: string, key: string): string {
    const override: Map<string, string> | undefined = UPI18n.overrides.get(locale);
    if (override !== undefined) {
      const value: string | undefined = override.get(key);
      if (value !== undefined) {
        return value;
      }
    }
    const pack: Map<string, string> | undefined = UPLocaleCatalog.pack(locale);
    if (pack === undefined) {
      return '';
    }
    const value: string | undefined = pack.get(key);
    return value === undefined ? '' : value;
  }
}

/**
 * 上游 `weekText` 默认值：按 `up.week.one` 到 `up.week.seven` 取当前语言的星期简称。
 * The upstream weekText default, read from the current locale.
 */
export function upWeekText(): Array<string> {
  return [
    UPI18n.t('up.week.one'),
    UPI18n.t('up.week.two'),
    UPI18n.t('up.week.three'),
    UPI18n.t('up.week.four'),
    UPI18n.t('up.week.five'),
    UPI18n.t('up.week.six'),
    UPI18n.t('up.week.seven')
  ];
}

/** `UPI18n.t()` 的短别名，与上游 `t()` 同名语义。/ Short alias for UPI18n.t(). */
export function upText(key: string, params?: Array<UPI18nParam>): string {
  return UPI18n.t(key, params);
}
