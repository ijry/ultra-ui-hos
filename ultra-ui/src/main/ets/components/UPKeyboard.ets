import { UPBuilder, UPRawValue, UPStyleInput, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPI18n } from '../core/UPI18n';
import { UPColor } from '../core/UPColor';

export interface UPKeyboardKeyEvent { key: string; value: string; }
export interface UPKeyboardDeleteEvent { value: string; }
export interface UPKeyboardConfirmEvent { value: string; }
export interface UPKeyboardOptions {
  mode?: string; value?: UPRawValue; modelValue?: UPRawValue; randomKeys?: boolean; confirmText?: string;
  maxLength?: number; showCancel?: boolean; cancelText?: string;
  customStyle?: UPStyleInput; onKey?: (event: UPKeyboardKeyEvent) => void;
  onDelete?: (event: UPKeyboardDeleteEvent) => void; onConfirm?: (event: UPKeyboardConfirmEvent) => void;
  onChange?: (event: UPKeyboardKeyEvent) => void; onBackspace?: (event: UPKeyboardDeleteEvent) => void;
  onCancel?: () => void; onClose?: () => void; onClosed?: () => void;
  contentBuilder?: UPBuilder;
}
export class UPKeyboardProps {
  mode: string = 'number'; value: UPRawValue = ''; modelValue: UPRawValue = null; randomKeys: boolean = false;
  confirmText: string = UPI18n.t('up.common.confirm'); maxLength: number = 20; showCancel: boolean = true; cancelText: string = UPI18n.t('up.common.cancel');
  customStyle: UPStyleInput = undefined;
  onKey?: (event: UPKeyboardKeyEvent) => void; onDelete?: (event: UPKeyboardDeleteEvent) => void;
  onConfirm?: (event: UPKeyboardConfirmEvent) => void;
  onChange?: (event: UPKeyboardKeyEvent) => void; onBackspace?: (event: UPKeyboardDeleteEvent) => void;
  onCancel?: () => void; onClose?: () => void; onClosed?: () => void;
  contentBuilder?: UPBuilder;
  constructor(options?: UPKeyboardOptions) {
    if (options === undefined) return;
    this.mode = options.mode ?? this.mode; this.value = options.value ?? this.value;
    this.modelValue = options.modelValue ?? this.modelValue; this.randomKeys = options.randomKeys ?? this.randomKeys;
    this.confirmText = options.confirmText ?? this.confirmText; this.maxLength = options.maxLength ?? this.maxLength;
    this.showCancel = options.showCancel ?? this.showCancel; this.cancelText = options.cancelText ?? this.cancelText;
    this.onChange = options.onChange; this.onBackspace = options.onBackspace;
    this.onCancel = options.onCancel; this.onClose = options.onClose; this.onClosed = options.onClosed;
    this.customStyle = options.customStyle; this.onKey = options.onKey; this.onDelete = options.onDelete;
    this.onConfirm = options.onConfirm;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPKeyboard {
  @Prop props: UPKeyboardProps = new UPKeyboardProps();
  @State private inputValue: string = '';
  aboutToAppear(): void {
    this.inputValue = this.props.modelValue !== null && this.props.modelValue !== undefined ?
      upString(this.props.modelValue, '') : upString(this.props.value, '');
  }
  private keys(): Array<string> {
    const base: Array<string> = this.props.mode.toLowerCase() === 'idcard' ?
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'X', '0'] :
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    return this.props.randomKeys ? base.slice().reverse() : base;
  }
  /** 上游 change 与本端 onKey 是同一时机的一对回调。/ Upstream change paired with the local onKey. */
  private press(key: string): void {
    if (this.inputValue.length >= Math.max(0, this.props.maxLength)) return;
    this.inputValue += key;
    const event: UPKeyboardKeyEvent = { key, value: this.inputValue };
    this.props.onKey?.(event);
    this.props.onChange?.(event);
  }
  /** 上游 backspace 与本端 onDelete 成对。/ Upstream backspace paired with the local onDelete. */
  private backspace(): void {
    this.inputValue = this.inputValue.substring(0, Math.max(0, this.inputValue.length - 1));
    const event: UPKeyboardDeleteEvent = { value: this.inputValue };
    this.props.onDelete?.(event);
    this.props.onBackspace?.(event);
  }
  /** 上游 cancel 同时抛出 close 与 closed。/ Upstream cancel also emits close and closed. */
  private cancel(): void {
    this.props.onCancel?.();
    this.dismiss();
  }
  /** ArkUI 无退场动画，close 与 closed 同帧触发。/ close and closed fire together on ArkUI. */
  private dismiss(): void {
    this.props.onClose?.();
    this.props.onClosed?.();
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  build() {
    Column({ space: 8 }) {
      this.slotRegion()
      Grid() {
        ForEach(this.keys(), (key: string) => {
          GridItem() {
            Text(key).fontSize(18).height(42).textAlign(TextAlign.Center).backgroundColor('#f5f7fa').borderRadius(5)
              .onClick((): void => this.press(key))
          }
        })
      }.columnsTemplate('1fr 1fr 1fr').columnsGap(6).rowsGap(6).height(148)
      Row({ space: 6 }) {
        Text('删除').fontSize(15).height(42).textAlign(TextAlign.Center).backgroundColor('#e6e8eb').borderRadius(5)
          .layoutWeight(1).onClick((): void => this.backspace())
        if (this.props.showCancel) {
          Text(this.props.cancelText).fontSize(15).fontColor(UPColor.adaptive('#606266', 'content-color')).height(42).textAlign(TextAlign.Center)
            .backgroundColor('#f2f3f5').borderRadius(5).layoutWeight(1).onClick((): void => this.cancel())
        }
        Text(this.props.confirmText).fontSize(15).fontColor(Color.White).height(42).textAlign(TextAlign.Center)
          .backgroundColor('#2979ff').borderRadius(5).layoutWeight(2).onClick((): void => {
            this.props.onConfirm?.({ value: this.inputValue });
            this.dismiss();
          })
      }.width('100%')
    }.padding(8).backgroundColor('#fafafa').width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
