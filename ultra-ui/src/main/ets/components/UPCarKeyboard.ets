import { UPRawValue, UPStyleInput, upBoolean } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPIcon, UPIconProps } from './UPIcon';

/** 车牌键盘的一行按键。/ One rendered keyboard row, mirroring the upstream 2D slice. */
export interface UPCarKeyboardRow {
  index: number;
  keys: Array<string>;
}

/** 按键回传事件。/ Payload of the upstream change event. */
export interface UPCarKeyboardChangeEvent {
  value: string;
}

/** 省份中文简称，与上游 areaList 完全一致。/ Upstream areaList. */
const UP_CAR_KEYBOARD_AREA: Array<string> = [
  '京', '沪', '粤', '津', '冀', '豫', '云', '辽', '黑', '湘',
  '皖', '鲁', '苏', '浙', '赣', '鄂', '桂', '甘', '晋', '陕',
  '蒙', '吉', '闽', '贵', '渝', '川', '青', '琼', '宁', '挂',
  '藏', '港', '澳', '新', '使', '学'
];

/** 数字与字母键，与上游 engKeyBoardList 完全一致。/ Upstream engKeyBoardList. */
const UP_CAR_KEYBOARD_ENG: Array<string> = [
  '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
  'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
  'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Z',
  'X', 'C', 'V', 'B', 'N', 'M'
];

/** 上游 randomArray()：洗牌一份副本，不改动源数组。/ Upstream randomArray(). */
export function upCarKeyboardShuffle(source: Array<string>): Array<string> {
  const shuffled: Array<string> = source.slice();
  for (let index: number = shuffled.length - 1; index > 0; index -= 1) {
    const target: number = Math.floor(Math.random() * (index + 1));
    const swap: string = shuffled[index];
    shuffled[index] = shuffled[target];
    shuffled[target] = swap;
  }
  return shuffled;
}

/** 上游把 36 个键切成 10/10/10/6 四行。/ Upstream 10/10/10/6 slicing. */
export function upCarKeyboardRows(source: Array<string>): Array<UPCarKeyboardRow> {
  return [
    { index: 0, keys: source.slice(0, 10) },
    { index: 1, keys: source.slice(10, 20) },
    { index: 2, keys: source.slice(20, 30) },
    { index: 3, keys: source.slice(30, 36) }
  ];
}

export interface UPCarKeyboardOptions {
  random?: UPRawValue;
  autoChange?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onChange?: (event: UPCarKeyboardChangeEvent) => void;
  onBackspace?: () => void;
}

export class UPCarKeyboardProps {
  random: UPRawValue = false;
  autoChange: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onChange?: (event: UPCarKeyboardChangeEvent) => void;
  onBackspace?: () => void;

  constructor(options?: UPCarKeyboardOptions) {
    if (options === undefined) {
      return;
    }
    this.random = options.random ?? this.random;
    this.autoChange = options.autoChange ?? this.autoChange;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onChange = options.onChange;
    this.onBackspace = options.onBackspace;
  }
}

@Component
export struct UPCarKeyboard {
  @Prop @Watch('rebuildKeys') props: UPCarKeyboardProps = new UPCarKeyboardProps();
  /** 上游 abc：false 输入省份简称，true 输入车牌号码。/ Upstream abc flag. */
  @State private abc: boolean = false;
  @State private areaKeys: Array<string> = UP_CAR_KEYBOARD_AREA;
  @State private engKeys: Array<string> = UP_CAR_KEYBOARD_ENG;
  private autoTimerId: number = -1;
  private backspaceTimerId: number = -1;

  aboutToAppear(): void {
    this.rebuildKeys();
  }

  aboutToDisappear(): void {
    this.clearAutoTimer();
    this.stopBackspace();
  }

  /** 只在 random 变化时洗牌一次，避免每帧重排按键。/ Shuffle once, never per frame. */
  private rebuildKeys(): void {
    if (upBoolean(this.props.random, false)) {
      this.areaKeys = upCarKeyboardShuffle(UP_CAR_KEYBOARD_AREA);
      this.engKeys = upCarKeyboardShuffle(UP_CAR_KEYBOARD_ENG);
      return;
    }
    this.areaKeys = UP_CAR_KEYBOARD_AREA;
    this.engKeys = UP_CAR_KEYBOARD_ENG;
  }

  private report(property: string, value: UPRawValue, reason: string): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    diagnostics.report('UPCarKeyboard', property, value, reason);
  }

  private rows(): Array<UPCarKeyboardRow> {
    return upCarKeyboardRows(this.abc ? this.engKeys : this.areaKeys);
  }

  private clearAutoTimer(): void {
    if (this.autoTimerId >= 0) {
      clearTimeout(this.autoTimerId);
      this.autoTimerId = -1;
    }
  }

  private stopBackspace(): void {
    if (this.backspaceTimerId >= 0) {
      clearInterval(this.backspaceTimerId);
      this.backspaceTimerId = -1;
    }
  }

  /** 上游 carInputClick()：回传按键并按需自动切到英文。/ Upstream carInputClick(). */
  private press(value: string): void {
    if (!this.abc && upBoolean(this.props.autoChange, false)) {
      this.clearAutoTimer();
      this.autoTimerId = setTimeout((): void => {
        this.autoTimerId = -1;
        this.abc = true;
      }, 200);
    }
    this.props.onChange?.({ value });
  }

  /** 上游 changeCarInputMode()。/ Upstream changeCarInputMode(). */
  toggleMode(): void {
    this.clearAutoTimer();
    this.abc = !this.abc;
  }

  /** 上游 backspaceClick()：立即触发一次，随后每 250ms 连续触发。/ Upstream backspaceClick(). */
  private beginBackspace(): void {
    this.props.onBackspace?.();
    this.stopBackspace();
    this.backspaceTimerId = setInterval((): void => {
      this.props.onBackspace?.();
    }, 250);
  }

  private keyWidth(): number {
    return UPUnit.parse('64rpx', 375, 32);
  }

  private keyHeight(): number {
    return UPUnit.parse('80rpx', 375, 40);
  }

  private specialWidth(): number {
    return UPUnit.parse('134rpx', 375, 67);
  }

  private activeColor(): string {
    return UPColor.parse('primary', UP_DEFAULT_THEME, '#2979ff');
  }

  @Builder
  private keyButton(key: string) {
    Text(key)
      .fontSize(16)
      .fontColor(UPColor.adaptive('#303133', 'main-color'))
      .textAlign(TextAlign.Center)
      .width(this.keyWidth())
      .height(this.keyHeight())
      .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
      .borderRadius(4)
      .margin({ top: 4, bottom: 4, left: 2.5, right: 2.5 })
      .shadow({ radius: 1, color: '#999992', offsetY: 1 })
      .onClick((): void => this.press(key))
  }

  @Builder
  private langButton() {
    Row() {
      Text('中')
        .fontSize(16)
        .fontColor(this.abc ? '#303133' : this.activeColor())
      Text('/')
        .fontSize(15)
        .fontColor(UPColor.adaptive('#303133', 'main-color'))
        .margin({ left: 1, right: 1 })
      Text('英')
        .fontSize(16)
        .fontColor(this.abc ? this.activeColor() : '#303133')
    }
    .width(this.specialWidth())
    .height(this.keyHeight())
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#bbbcc6')
    .borderRadius(4)
    .margin({ top: 4, bottom: 4, left: 2.5, right: 2.5 })
    .shadow({ radius: 1, color: '#999992', offsetY: 1 })
    .onClick((): void => this.toggleMode())
  }

  @Builder
  private backspaceButton() {
    Row() {
      UPIcon({ props: new UPIconProps({ name: 'backspace', size: 18, color: '#303133' }) })
    }
    .width(this.specialWidth())
    .height(this.keyHeight())
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#bbbcc6')
    .borderRadius(4)
    .margin({ top: 4, bottom: 4, left: 2.5, right: 2.5 })
    .shadow({ radius: 1, color: '#999992', offsetY: 1 })
    .onTouch((event: TouchEvent): void => {
      if (event.type === TouchType.Down) {
        this.beginBackspace();
        return;
      }
      if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.stopBackspace();
      }
    })
  }

  @Builder
  private keyboardRow(row: UPCarKeyboardRow) {
    Row() {
      if (row.index === 3) {
        this.langButton()
      }
      ForEach(row.keys, (key: string) => {
        this.keyButton(key)
      }, (key: string): string => key)
      if (row.index === 3) {
        this.backspaceButton()
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      ForEach(this.rows(), (row: UPCarKeyboardRow) => {
        this.keyboardRow(row)
      }, (row: UPCarKeyboardRow): string => String(row.index) + '-' + String(this.abc))
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .padding({ top: 6, bottom: 6 })
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? 'rgb(224, 228, 230)')
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(HorizontalAlign.Center)
  }
}
