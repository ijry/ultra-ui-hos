/**
 * 上游 `libs/util/async-validator.js` 的 ArkTS 复刻：同步规则引擎。
 * ArkTS port of the upstream async-validator schema engine. ArkTS has no index
 * signatures and no runtime reflection, so the "source object" becomes an explicit
 * list of field/value pairs and every rule is a declared interface.
 */
import { UPRawValue } from './UPTypes';
import { upDateParts, upIsEmpty } from './UPValidate';

/** 可校验的值：标量或标量数组。/ A validatable value: scalar or scalar list. */
export type UPValidateValue = UPRawValue | Array<UPRawValue>;

/** 一个字段的当前值，缺项等价于上游 `!source.hasOwnProperty(field)`。/ One field value. */
export interface UPValidateFieldValue {
  field: string;
  value?: UPValidateValue;
}

/** 单条规则，字段名与上游 rule 对象对齐。/ One rule, mirroring the upstream rule object. */
export interface UPValidateRule {
  /** `string`/`number`/`boolean`/`integer`/`float`/`array`/`email`/`url`/`hex`/`date`/`regexp`/`enum`/`pattern`。 */
  type?: string;
  required?: boolean;
  message?: string;
  min?: number;
  max?: number;
  len?: number;
  /** 正则源码字符串；ArkTS 的 props 不便传 `RegExp` 实例。/ Pattern source, not a RegExp instance. */
  pattern?: string;
  /** 对应上游 `rule.enum`；`enum` 在 ArkTS 是保留字。/ Upstream `rule.enum`. */
  enumValues?: Array<UPRawValue>;
  whitespace?: boolean;
  /** 触发时机，对应上游 `trigger`（可为数组）。/ Trigger names. */
  triggers?: Array<string>;
  /** 自定义校验：返回空串表示通过。/ Custom check; an empty string means "passed". */
  validator?: (value: UPValidateValue) => string;
  /** 上游 `transform`：校验前改写值。/ Upstream `transform`. */
  transform?: (value: UPValidateValue) => UPValidateValue;
}

/** 一个字段的规则集合。/ The rule list bound to one field. */
export interface UPFieldRules {
  field: string;
  /** 报错文案里的字段名，缺省用 `field`。/ Display name used in messages. */
  label?: string;
  rules: Array<UPValidateRule>;
}

/** 一条校验错误。/ One validation error. */
export interface UPValidateError {
  field: string;
  message: string;
}

/** 校验结果。/ The validation outcome. */
export interface UPValidateResult {
  valid: boolean;
  errors: Array<UPValidateError>;
}

/**
 * 上游 `newMessages()` 的文案表，模板与占位符逐字保留。
 * The upstream message table; templates and `%s` placeholders are kept verbatim.
 */
export class UPValidateMessages {
  fallback: string = 'Validation error on field %s';
  required: string = '%s is required';
  enumMessage: string = '%s must be one of %s';
  whitespace: string = '%s cannot be empty';
  typeMismatch: string = '%s is not a %s';
  typeArticleMismatch: string = '%s is not an %s';
  typeInvalid: string = '%s is not a valid %s';
  dateInvalid: string = '%s date %s is invalid';
  patternMismatch: string = '%s value %s does not match pattern %s';
  stringLen: string = '%s must be exactly %s characters';
  stringMin: string = '%s must be at least %s characters';
  stringMax: string = '%s cannot be longer than %s characters';
  stringRange: string = '%s must be between %s and %s characters';
  numberLen: string = '%s must equal %s';
  numberMin: string = '%s cannot be less than %s';
  numberMax: string = '%s cannot be greater than %s';
  numberRange: string = '%s must be between %s and %s';
  arrayLen: string = '%s must be exactly %s in length';
  arrayMin: string = '%s cannot be less than %s in length';
  arrayMax: string = '%s cannot be greater than %s in length';
  arrayRange: string = '%s must be between %s and %s in length';
}

/** 默认文案，与上游英文默认值一致。/ The default English message table. */
export const UP_DEFAULT_VALIDATE_MESSAGES: UPValidateMessages = new UPValidateMessages();

/**
 * 中文校验文案（本端扩展，上游不存在）。
 * 上游 `async-validator` 的文案表只有英文，且不经 `libs/i18n` 的 `t()`，
 * 因此这里额外提供一份简体中文表，由调用方显式传给 `UPValidator`。
 * A Simplified Chinese message table. This is a local addition: upstream keeps the
 * validator copy English-only and never routes it through the i18n runtime.
 */
export function upZhHansValidateMessages(): UPValidateMessages {
  const messages: UPValidateMessages = new UPValidateMessages();
  messages.fallback = '%s 校验未通过';
  messages.required = '请填写%s';
  messages.enumMessage = '%s 必须是 %s 之一';
  messages.whitespace = '%s 不能为空';
  messages.typeMismatch = '%s 不是有效的 %s';
  messages.typeArticleMismatch = '%s 不是有效的 %s';
  messages.typeInvalid = '%s 不是有效的 %s';
  messages.dateInvalid = '%s 的日期 %s 无效';
  messages.patternMismatch = '%s 的值 %s 不符合格式要求';
  messages.stringLen = '%s 长度须为 %s 个字符';
  messages.stringMin = '%s 长度不能少于 %s 个字符';
  messages.stringMax = '%s 长度不能超过 %s 个字符';
  messages.stringRange = '%s 长度须在 %s 到 %s 个字符之间';
  messages.numberLen = '%s 须等于 %s';
  messages.numberMin = '%s 不能小于 %s';
  messages.numberMax = '%s 不能大于 %s';
  messages.numberRange = '%s 须在 %s 到 %s 之间';
  messages.arrayLen = '%s 须选择 %s 项';
  messages.arrayMin = '%s 不能少于 %s 项';
  messages.arrayMax = '%s 不能多于 %s 项';
  messages.arrayRange = '%s 须选择 %s 到 %s 项';
  return messages;
}

/**
 * 按语言标签挑选校验文案：`zh-Hans` / `zh-Hant` 走中文表，其余走上游英文表。
 * 同属本端扩展，上游没有对应能力。
 * Picks a message table by locale tag; also a local addition.
 */
export function upValidateMessagesFor(locale: string): UPValidateMessages {
  return locale === 'zh-Hans' || locale === 'zh-Hant'
    ? upZhHansValidateMessages()
    : UP_DEFAULT_VALIDATE_MESSAGES;
}

/** 上游 `pattern.email`。/ Upstream email pattern. */
const UP_EMAIL_PATTERN: RegExp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

/** 上游 `pattern.url`。/ Upstream URL pattern. */
const UP_URL_PATTERN: RegExp = new RegExp(
  '^(?!mailto:)(?:(?:http|https|ftp)://|//)(?:\\S+(?::\\S*)?@)?(?:(?:(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[0-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\u00a1-\\uffff0-9]+-*)*[a-z\\u00a1-\\uffff0-9]+)(?:\\.(?:[a-z\\u00a1-\\uffff0-9]+-*)*[a-z\\u00a1-\\uffff0-9]+)*(?:\\.(?:[a-z\\u00a1-\\uffff]{2,})))|localhost)(?::\\d{2,5})?(?:(/|\\?|#)[^\\s]*)?$',
  'i'
);

/** 上游 `pattern.hex`。/ Upstream hex pattern. */
const UP_HEX_PATTERN: RegExp = /^#?([a-f0-9]{6}|[a-f0-9]{3})$/i;

/** 上游用来修正补充平面字符长度的正则。/ Surrogate pair fix used by the range rule. */
const UP_SURROGATE_PATTERN: RegExp = /[\uD800-\uDBFF][\uDC00-\uDFFF]/g;

/** 上游 `isNativeStringType()`。/ Types whose empty string counts as empty. */
function isNativeStringType(type: string): boolean {
  return type === 'string' || type === 'url' || type === 'hex' || type === 'email' || type === 'pattern';
}

function textOf(value: UPValidateValue | undefined): string {
  if (value === null || value === undefined) {
    return '';
  }
  if (Array.isArray(value)) {
    const parts: Array<string> = [];
    for (let index: number = 0; index < value.length; index++) {
      const item: UPRawValue = value[index];
      parts.push(item === null || item === undefined ? '' : String(item));
    }
    return parts.join(',');
  }
  return String(value);
}

/**
 * 同步规则引擎。上游用 Promise 串联校验，本端全部同步返回，
 * 因为 ArkTS 侧禁用 `async`/`await`，且所有内置规则都是纯计算。
 * A synchronous schema validator; every built-in rule is pure computation.
 */
export class UPValidator {
  private descriptors: Array<UPFieldRules>;
  private messages: UPValidateMessages;

  constructor(descriptors: Array<UPFieldRules>, messages?: UPValidateMessages) {
    this.descriptors = descriptors;
    this.messages = messages ?? UP_DEFAULT_VALIDATE_MESSAGES;
  }

  /** 上游 `format()` 的 `%s` 替换。/ Positional `%s` substitution. */
  static format(template: string, args: Array<string>): string {
    let index: number = 0;
    return template.replace(/%[sdj%]/g, (token: string): string => {
      if (token === '%%') {
        return '%';
      }
      if (index >= args.length) {
        return token;
      }
      const value: string = args[index];
      index += 1;
      return value;
    });
  }

  /** 上游 `isEmptyValue()`。/ Upstream empty-value probe. */
  static isEmptyValue(value: UPValidateValue | undefined, type: string): boolean {
    if (value === null || value === undefined) {
      return true;
    }
    if (type === 'array' && Array.isArray(value) && value.length === 0) {
      return true;
    }
    if (isNativeStringType(type) && typeof value === 'string' && value.length === 0) {
      return true;
    }
    return false;
  }

  /** 上游 `types` 映射表的同步实现。/ Upstream type probes. */
  static matchesType(value: UPValidateValue | undefined, type: string): boolean {
    const source: string = textOf(value);
    switch (type) {
      case 'string': return typeof value === 'string';
      case 'boolean': return typeof value === 'boolean';
      case 'integer': return /^(-)?\d+$/.test(source);
      case 'float': return /^(-)?\d+(\.\d+)?$/.test(source);
      case 'array': return Array.isArray(value);
      case 'number': return source.length > 0 && Number.isFinite(Number(source));
      case 'email': return typeof value === 'string' && UP_EMAIL_PATTERN.test(value) && value.length < 255;
      case 'url': return typeof value === 'string' && UP_URL_PATTERN.test(value);
      case 'hex': return typeof value === 'string' && UP_HEX_PATTERN.test(value);
      case 'date': return upDateParts(source) !== undefined;
      case 'regexp': return UPValidator.compiles(source);
      default: return true;
    }
  }

  /** 上游 `range()` 用到的长度口径：数组取长度，字符串修正补充平面。/ Range metric. */
  static rangeMetric(value: UPValidateValue | undefined): number {
    if (Array.isArray(value)) {
      return value.length;
    }
    if (typeof value === 'number') {
      return value;
    }
    return textOf(value).replace(UP_SURROGATE_PATTERN, '_').length;
  }

  /** 校验全部字段。/ Validates every declared field. */
  validate(values: Array<UPValidateFieldValue>): UPValidateResult {
    const errors: Array<UPValidateError> = [];
    for (let index: number = 0; index < this.descriptors.length; index++) {
      this.collect(this.descriptors[index], values, '', errors);
    }
    return { valid: errors.length === 0, errors };
  }

  /** 只校验一个字段，可按触发时机过滤。/ Validates a single field, optionally by trigger. */
  validateField(field: string, values: Array<UPValidateFieldValue>, trigger: string = ''): UPValidateResult {
    const errors: Array<UPValidateError> = [];
    for (let index: number = 0; index < this.descriptors.length; index++) {
      if (this.descriptors[index].field === field) {
        this.collect(this.descriptors[index], values, trigger, errors);
      }
    }
    return { valid: errors.length === 0, errors };
  }

  /** 某字段的首条错误文案，无错误返回空串。/ First message for one field. */
  firstMessage(field: string, errors: Array<UPValidateError>): string {
    for (let index: number = 0; index < errors.length; index++) {
      if (errors[index].field === field) {
        return errors[index].message;
      }
    }
    return '';
  }

  private static compiles(source: string): boolean {
    if (source.length === 0) {
      return false;
    }
    // 上游用 try/catch 探测 new RegExp；这里只做保守的括号配平检查。
    let depth: number = 0;
    for (let index: number = 0; index < source.length; index++) {
      const glyph: string = source.charAt(index);
      if (glyph === '\\') {
        index += 1;
        continue;
      }
      if (glyph === '(') {
        depth += 1;
      } else if (glyph === ')') {
        depth -= 1;
        if (depth < 0) {
          return false;
        }
      }
    }
    return depth === 0;
  }

  private valueOf(field: string, values: Array<UPValidateFieldValue>): UPValidateFieldValue | undefined {
    for (let index: number = 0; index < values.length; index++) {
      if (values[index].field === field) {
        return values[index];
      }
    }
    return undefined;
  }

  private collect(descriptor: UPFieldRules, values: Array<UPValidateFieldValue>, trigger: string,
                  errors: Array<UPValidateError>): void {
    const label: string = descriptor.label !== undefined && descriptor.label.length > 0
      ? descriptor.label
      : descriptor.field;
    const entry: UPValidateFieldValue | undefined = this.valueOf(descriptor.field, values);
    const present: boolean = entry !== undefined;
    for (let index: number = 0; index < descriptor.rules.length; index++) {
      const rule: UPValidateRule = descriptor.rules[index];
      if (trigger.length > 0 && !UPValidator.matchesTrigger(rule, trigger)) {
        continue;
      }
      const message: string = this.check(rule, entry, present, label);
      if (message.length > 0) {
        errors.push({ field: descriptor.field, message });
        // 上游对同一字段的多条规则会逐条收集，这里保持一致：不提前退出。
      }
    }
  }

  private static matchesTrigger(rule: UPValidateRule, trigger: string): boolean {
    const triggers: Array<string> | undefined = rule.triggers;
    if (triggers === undefined || triggers.length === 0) {
      return false;
    }
    return triggers.includes(trigger);
  }

  private check(rule: UPValidateRule, entry: UPValidateFieldValue | undefined, present: boolean,
                label: string): string {
    const type: string = rule.type ?? 'string';
    const required: boolean = rule.required === true;
    // 上游：非必填且字段不在 source 里就整条跳过。
    if (!required && !present) {
      return '';
    }
    let value: UPValidateValue | undefined = entry === undefined ? undefined : entry.value;
    if (rule.transform !== undefined && value !== undefined) {
      value = rule.transform(value);
    }
    // 上游 number 分支把空串视作 undefined。
    if (type === 'number' && value === '') {
      value = undefined;
    }
    const empty: boolean = UPValidator.isEmptyValue(value, type);
    if (required && (!present || empty)) {
      return rule.message ?? UPValidator.format(this.messages.required, [label]);
    }
    if (empty) {
      return '';
    }
    const typeError: string = this.checkType(rule, value, type, label);
    if (typeError.length > 0) {
      return typeError;
    }
    const rangeError: string = this.checkRange(rule, value, type, label);
    if (rangeError.length > 0) {
      return rangeError;
    }
    const enumError: string = this.checkEnum(rule, value, label);
    if (enumError.length > 0) {
      return enumError;
    }
    const patternError: string = this.checkPattern(rule, value, label);
    if (patternError.length > 0) {
      return patternError;
    }
    if (rule.whitespace === true && /^\s+$/.test(textOf(value))) {
      return rule.message ?? UPValidator.format(this.messages.whitespace, [label]);
    }
    if (rule.validator !== undefined && value !== undefined) {
      const custom: string = rule.validator(value);
      if (custom.length > 0) {
        return custom;
      }
    }
    return '';
  }

  private checkType(rule: UPValidateRule, value: UPValidateValue | undefined, type: string,
                    label: string): string {
    if (type === 'enum' || type === 'pattern') {
      return '';
    }
    if (UPValidator.matchesType(value, type)) {
      return '';
    }
    if (rule.message !== undefined) {
      return rule.message;
    }
    if (type === 'date') {
      return UPValidator.format(this.messages.dateInvalid, [label, textOf(value)]);
    }
    if (type === 'email' || type === 'url' || type === 'hex' || type === 'regexp') {
      return UPValidator.format(this.messages.typeInvalid, [label, type]);
    }
    if (type === 'array' || type === 'integer') {
      return UPValidator.format(this.messages.typeArticleMismatch, [label, type]);
    }
    return UPValidator.format(this.messages.typeMismatch, [label, type]);
  }

  private checkRange(rule: UPValidateRule, value: UPValidateValue | undefined, type: string,
                     label: string): string {
    const hasLen: boolean = rule.len !== undefined;
    const hasMin: boolean = rule.min !== undefined;
    const hasMax: boolean = rule.max !== undefined;
    if (!hasLen && !hasMin && !hasMax) {
      return '';
    }
    const bucket: string = UPValidator.rangeBucket(value, type);
    if (bucket.length === 0) {
      return '';
    }
    const metric: number = UPValidator.rangeMetric(value);
    if (hasLen) {
      if (metric !== rule.len) {
        return rule.message ?? UPValidator.format(this.lenMessage(bucket), [label, String(rule.len)]);
      }
      return '';
    }
    if (hasMin && !hasMax && metric < (rule.min as number)) {
      return rule.message ?? UPValidator.format(this.minMessage(bucket), [label, String(rule.min)]);
    }
    if (hasMax && !hasMin && metric > (rule.max as number)) {
      return rule.message ?? UPValidator.format(this.maxMessage(bucket), [label, String(rule.max)]);
    }
    if (hasMin && hasMax && (metric < (rule.min as number) || metric > (rule.max as number))) {
      return rule.message
        ?? UPValidator.format(this.rangeMessage(bucket), [label, String(rule.min), String(rule.max)]);
    }
    return '';
  }

  /** 上游按 value 的运行时类型挑选文案分组。/ Picks the message bucket like upstream. */
  private static rangeBucket(value: UPValidateValue | undefined, type: string): string {
    if (Array.isArray(value)) {
      return 'array';
    }
    if (typeof value === 'number') {
      return 'number';
    }
    if (typeof value === 'string') {
      // 上游对 number/integer/float 规则收到字符串时按 string 分组取文案，这里保持一致。
      return type === 'array' ? 'array' : 'string';
    }
    return '';
  }

  private checkEnum(rule: UPValidateRule, value: UPValidateValue | undefined, label: string): string {
    const allowed: Array<UPRawValue> | undefined = rule.enumValues;
    if (allowed === undefined || allowed.length === 0) {
      return '';
    }
    const target: string = textOf(value);
    for (let index: number = 0; index < allowed.length; index++) {
      const item: UPRawValue = allowed[index];
      if ((item === null || item === undefined ? '' : String(item)) === target) {
        return '';
      }
    }
    const labels: Array<string> = [];
    for (let index: number = 0; index < allowed.length; index++) {
      const item: UPRawValue = allowed[index];
      labels.push(item === null || item === undefined ? '' : String(item));
    }
    return rule.message
      ?? UPValidator.format(this.messages.enumMessage, [label, labels.join(', ')]);
  }

  private checkPattern(rule: UPValidateRule, value: UPValidateValue | undefined, label: string): string {
    const source: string | undefined = rule.pattern;
    if (source === undefined || source.length === 0) {
      return '';
    }
    const target: string = textOf(value);
    if (new RegExp(source).test(target)) {
      return '';
    }
    return rule.message
      ?? UPValidator.format(this.messages.patternMismatch, [label, target, source]);
  }

  private lenMessage(bucket: string): string {
    if (bucket === 'number') {
      return this.messages.numberLen;
    }
    return bucket === 'array' ? this.messages.arrayLen : this.messages.stringLen;
  }

  private minMessage(bucket: string): string {
    if (bucket === 'number') {
      return this.messages.numberMin;
    }
    return bucket === 'array' ? this.messages.arrayMin : this.messages.stringMin;
  }

  private maxMessage(bucket: string): string {
    if (bucket === 'number') {
      return this.messages.numberMax;
    }
    return bucket === 'array' ? this.messages.arrayMax : this.messages.stringMax;
  }

  private rangeMessage(bucket: string): string {
    if (bucket === 'number') {
      return this.messages.numberRange;
    }
    return bucket === 'array' ? this.messages.arrayRange : this.messages.stringRange;
  }
}

/** 便捷构造：单字段单规则。/ Convenience helper for a one-rule descriptor. */
export function upFieldRule(field: string, rule: UPValidateRule, label?: string): UPFieldRules {
  return { field, label, rules: [rule] };
}

/** 便捷判空，复用 `UPValidate` 的标量口径。/ Reuses the scalar empty probe. */
export function upValueEmpty(value: UPValidateValue | undefined): boolean {
  if (Array.isArray(value)) {
    return value.length === 0;
  }
  return upIsEmpty(value);
}
