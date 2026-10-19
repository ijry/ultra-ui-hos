import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPStyle, UPStyleResult } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPColor } from '../core/UPColor';

/** 上游 data.dot。/ Upstream data.dot. */
export const UP_NUMBER_KEYBOARD_DOT: string = '.';

/** 上游 data.cardX。/ Upstream data.cardX. */
export const UP_NUMBER_KEYBOARD_CARD_X: string = 'X';

/** 上游 data.backspace，退格键的图标名。/ Upstream data.backspace. */
export const UP_NUMBER_KEYBOARD_BACKSPACE: string = 'backspace';

/** 上游长按连续退格的间隔。/ Upstream 250ms backspace interval. */
export const UP_NUMBER_KEYBOARD_BACKSPACE_INTERVAL: number = 250;

/** 一枚按键，替代上游 `v-for` 里裸用的 index。/ One rendered key; replaces the upstream bare index. */
export interface UPNumberKeyboardKey {
  index: number;
  label: string;
}

/** change 事件载荷。/ Payload of the upstream change event. */
export interface UPNumberKeyboardChangeEvent {
  /** 上游 emit 的原值：`.` 与 `X` 保持字符串，其余转数字。/ Upstream value: string for `.`/`X`, number otherwise. */
  value: UPRawValue;
  /** 按键文本，便于宿主直接拼接。/ Raw key text. */
  text: string;
}

/** 上游 randomArray()：洗牌一份副本，不改动源数组。/ Upstream randomArray(). */
export function upNumberKeyboardShuffle(source: Array<string>): Array<string> {
  const shuffled: Array<string> = source.slice();
  for (let index: number = shuffled.length - 1; index > 0; index -= 1) {
    const target: number = Math.floor(Math.random() * (index + 1));
    const swap: string = shuffled[index];
    shuffled[index] = shuffled[target];
    shuffled[target] = swap;
  }
  return shuffled;
}

/**
 * 上游 numList 的四个分支。mode 既不是 number 也不是 card 时上游返回 undefined、键盘整体不渲染，
 * 这里回落到数字键盘布局并交由调用方读诊断。
 * Mirrors the four upstream numList branches; the undefined branch falls back to the number layout.
 */
export function upNumberKeyboardKeys(mode: string, dotDisabled: boolean, random: boolean): Array<string> {
  const digits: Array<string> = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
  let keys: Array<string> = [];
  if (mode === 'card') {
    keys = digits.concat([UP_NUMBER_KEYBOARD_CARD_X, '0']);
  } else if (dotDisabled) {
    keys = digits.concat(['0']);
  } else {
    keys = digits.concat([UP_NUMBER_KEYBOARD_DOT, '0']);
  }
  return random ? upNumberKeyboardShuffle(keys) : keys;
}

/** 上游 numList 是否有对应分支，false 时上游渲染空键盘。/ Whether upstream numList has a matching branch. */
export function upNumberKeyboardModeSupported(mode: string): boolean {
  return mode === 'number' || mode === 'card';
}

/** 上游 itemStyle()：非乱序数字键盘且不显示点时，index 为 9 的 0 键占两格。/ Mirrors upstream itemStyle(). */
export function upNumberKeyboardWideKey(mode: string, dotDisabled: boolean, index: number): boolean {
  return mode === 'number' && dotDisabled && index === 9;
}

/** 上游 btnBgGray()，模板并未使用，仅保留同名判断供宿主对齐。/ Mirrors the unused upstream btnBgGray(). */
export function upNumberKeyboardGrayKey(mode: string, dotDisabled: boolean, random: boolean, index: number): boolean {
  return !random && index === 9 && (mode !== 'number' || (mode === 'number' && !dotDisabled));
}

export interface UPNumberKeyboardOptions {
  mode?: UPRawValue;
  dotDisabled?: UPRawValue;
  random?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onChange?: (event: UPNumberKeyboardChangeEvent) => void;
  onBackspace?: () => void;
}

export class UPNumberKeyboardProps {
  mode: UPRawValue = 'number';
  dotDisabled: UPRawValue = false;
  random: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onChange?: (event: UPNumberKeyboardChangeEvent) => void;
  onBackspace?: () => void;

  constructor(options?: UPNumberKeyboardOptions) {
    if (options === undefined) {
      return;
    }
    this.mode = options.mode ?? this.mode;
    this.dotDisabled = options.dotDisabled ?? this.dotDisabled;
    this.random = options.random ?? this.random;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onChange = options.onChange;
    this.onBackspace = options.onBackspace;
  }
}

@Component
export struct UPNumberKeyboard {
  @Prop @Watch('rebuildKeys') props: UPNumberKeyboardProps = new UPNumberKeyboardProps();
  /** 上游 numList 的求值结果，只在入参变化时重算，避免每帧重排。/ Cached numList; never reshuffled per frame. */
  @State private keys: Array<string> = [];
  /** 按下态背景，替代上游 hover-class。/ Pressed background, replacing the upstream hover-class. */
  @State private pressedIndex: number = -1;
  private applied: string = '';
  private backspaceTimerId: number = -1;

  aboutToAppear(): void {
    this.applied = this.signature();
    this.keys = upNumberKeyboardKeys(this.modeName(), this.dotHidden(), this.randomOrder());
    this.report();
  }

  aboutToDisappear(): void {
    this.stopBackspace();
  }

  private signature(): string {
    return `${this.modeName()}|${String(this.dotHidden())}|${String(this.randomOrder())}`;
  }

  /** 上游 mode/dotDisabled/random 变化时 numList 重新求值。/ Recomputes numList when its inputs change. */
  private rebuildKeys(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.keys = upNumberKeyboardKeys(this.modeName(), this.dotHidden(), this.randomOrder());
    this.pressedIndex = -1;
    this.report();
  }

  private report(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (!upNumberKeyboardModeSupported(this.modeName())) {
      diagnostics.report('UPNumberKeyboard', 'mode', this.props.mode,
        'upstream numList has no branch for this mode and renders an empty keyboard; the number layout is used instead');
    }
    diagnostics.report('UPNumberKeyboard', 'hoverClass', 'u-hover-class',
      'hover-class and hover-stay-time have no ArkUI equivalent; a pressed background is applied through onTouch instead');
  }

  private modeName(): string {
    const value: string = upString(this.props.mode, 'number').trim();
    return value.length === 0 ? 'number' : value;
  }

  private dotHidden(): boolean {
    return upBoolean(this.props.dotDisabled, false);
  }

  private randomOrder(): boolean {
    return upBoolean(this.props.random, false);
  }

  private keyList(): Array<UPNumberKeyboardKey> {
    const list: Array<UPNumberKeyboardKey> = [];
    for (let index: number = 0; index < this.keys.length; index += 1) {
      list.push({ index, label: this.keys[index] });
    }
    return list;
  }

  private keyWidth(index: number): number {
    if (upNumberKeyboardWideKey(this.modeName(), this.dotHidden(), index)) {
      return UPUnit.parse('464rpx', 375, 232);
    }
    return UPUnit.parse('222rpx', 375, 111);
  }

  private keyHeight(): number {
    return UPUnit.parse('90rpx', 375, 45);
  }

  private keyGap(): number {
    return UPUnit.parse('6rpx', 375, 3);
  }

  /** 上游 keyboardClick()：允许点模式时把非点、非 X 的按键转成数字。/ Mirrors upstream keyboardClick(). */
  private press(key: UPNumberKeyboardKey): void {
    const label: string = key.label;
    const isSymbol: boolean = label === UP_NUMBER_KEYBOARD_DOT || label === UP_NUMBER_KEYBOARD_CARD_X;
    const value: UPRawValue = !this.dotHidden() && !isSymbol ? Number(label) : label;
    this.props.onChange?.({ value, text: label });
  }

  /** 上游 backspaceClick()：先触发一次，随后每 250ms 连续触发。/ Mirrors upstream backspaceClick(). */
  private beginBackspace(): void {
    this.props.onBackspace?.();
    this.stopBackspace();
    this.backspaceTimerId = setInterval((): void => {
      this.props.onBackspace?.();
    }, UP_NUMBER_KEYBOARD_BACKSPACE_INTERVAL);
  }

  /** 上游 clearTimer()。/ Mirrors upstream clearTimer(). */
  private stopBackspace(): void {
    if (this.backspaceTimerId >= 0) {
      clearInterval(this.backspaceTimerId);
      this.backspaceTimerId = -1;
    }
  }

  @Builder
  private keyButton(key: UPNumberKeyboardKey) {
    Text(key.label)
      .fontSize(20)
      .fontWeight(FontWeight.Medium)
      .fontColor(UPColor.adaptive('#303133', 'main-color'))
      .textAlign(TextAlign.Center)
      .width(this.keyWidth(key.index))
      .height(this.keyHeight())
      .backgroundColor(this.pressedIndex === key.index ? '#bbbcc6' : '#ffffff')
      .borderRadius(4)
      .margin({ top: 4, bottom: 4, left: this.keyGap(), right: this.keyGap() })
      .shadow({ radius: 0, color: '#bbbcbe', offsetX: 0, offsetY: 2 })
      .onTouch((event: TouchEvent): void => {
        if (event.type === TouchType.Down) {
          this.pressedIndex = key.index;
          return;
        }
        if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.pressedIndex = -1;
        }
      })
      .onClick((): void => this.press(key))
  }

  @Builder
  private backspaceButton() {
    Row() {
      UPIcon({
        props: new UPIconProps({ name: UP_NUMBER_KEYBOARD_BACKSPACE, size: 28, color: '#303133' })
      })
    }
    .width(this.keyWidth(-1))
    .height(this.keyHeight())
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.pressedIndex === this.keys.length ? '#bbbcc6' : 'rgb(200, 202, 210)')
    .borderRadius(4)
    .margin({ top: 4, bottom: 4, left: this.keyGap(), right: this.keyGap() })
    .shadow({ radius: 0, color: '#bbbcbe', offsetX: 0, offsetY: 2 })
    .onTouch((event: TouchEvent): void => {
      if (event.type === TouchType.Down) {
        this.pressedIndex = this.keys.length;
        this.beginBackspace();
        return;
      }
      if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedIndex = -1;
        this.stopBackspace();
      }
    })
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      ForEach(this.keyList(), (key: UPNumberKeyboardKey) => {
        this.keyButton(key)
      }, (key: UPNumberKeyboardKey): string => `${String(key.index)}-${key.label}`)
      this.backspaceButton()
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .padding({ top: 8, bottom: 8, left: UPUnit.parse('10rpx', 375, 5), right: UPUnit.parse('10rpx', 375, 5) })
    .backgroundColor(this.rootBackground())
  }

  private rootBackground(): string {
    const style: UPStyleResult = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? 'rgb(224, 228, 230)';
  }
}
