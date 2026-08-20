import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPActionSheetAction {
  name: UPRawValue;
  subname?: UPRawValue;
  color?: UPRawValue;
  fontSize?: UPRawValue;
  disabled?: UPRawValue;
  loading?: UPRawValue;
}

export interface UPActionSheetSelectEvent { index: number; action: UPActionSheetAction; }
export type UPActionSheetCloseReason = 'action' | 'cancel' | 'overlay';
export interface UPActionSheetOptions {
  show?: UPRawValue; title?: UPRawValue; description?: UPRawValue;
  actions?: Array<UPActionSheetAction>; nameKey?: UPRawValue; subnameKey?: UPRawValue;
  cancelText?: UPRawValue; closeOnClickAction?: UPRawValue; safeAreaInsetBottom?: UPRawValue;
  openType?: UPRawValue; closeOnClickOverlay?: UPRawValue; round?: UPRawValue;
  wrapMaxHeight?: UPRawValue; index?: UPRawValue; customStyle?: UPStyleInput;
  onShowChange?: (show: boolean) => void; onSelect?: (event: UPActionSheetSelectEvent) => void;
  onCancel?: () => void; onClose?: (reason: UPActionSheetCloseReason) => void; onClickOverlay?: () => void;
}

export class UPActionSheetProps {
  show: UPRawValue = false; title: UPRawValue = ''; description: UPRawValue = '';
  actions: Array<UPActionSheetAction> = []; nameKey: UPRawValue = 'name'; subnameKey: UPRawValue = 'subname';
  cancelText: UPRawValue = '取消'; closeOnClickAction: UPRawValue = true; safeAreaInsetBottom: UPRawValue = true;
  openType: UPRawValue = ''; closeOnClickOverlay: UPRawValue = true; round: UPRawValue = 0;
  wrapMaxHeight: UPRawValue = 360; index: UPRawValue = ''; customStyle: UPStyleInput = undefined;
  onShowChange?: (show: boolean) => void; onSelect?: (event: UPActionSheetSelectEvent) => void;
  onCancel?: () => void; onClose?: (reason: UPActionSheetCloseReason) => void; onClickOverlay?: () => void;

  constructor(options?: UPActionSheetOptions) {
    if (options === undefined) return;
    this.show = options.show ?? this.show; this.title = options.title ?? this.title;
    this.description = options.description ?? this.description; this.actions = options.actions ?? this.actions;
    this.nameKey = options.nameKey ?? this.nameKey; this.subnameKey = options.subnameKey ?? this.subnameKey;
    this.cancelText = options.cancelText ?? this.cancelText; this.closeOnClickAction = options.closeOnClickAction ?? this.closeOnClickAction;
    this.safeAreaInsetBottom = options.safeAreaInsetBottom ?? this.safeAreaInsetBottom; this.openType = options.openType ?? this.openType;
    this.closeOnClickOverlay = options.closeOnClickOverlay ?? this.closeOnClickOverlay; this.round = options.round ?? this.round;
    this.wrapMaxHeight = options.wrapMaxHeight ?? this.wrapMaxHeight; this.index = options.index ?? this.index;
    this.customStyle = options.customStyle; this.onShowChange = options.onShowChange; this.onSelect = options.onSelect;
    this.onCancel = options.onCancel; this.onClose = options.onClose; this.onClickOverlay = options.onClickOverlay;
  }
}

@Component
export struct UPActionSheet {
  @Prop props: UPActionSheetProps = new UPActionSheetProps();

  private text(value: UPRawValue): string { return value === null || value === undefined ? '' : String(value); }
  private actionIndexes(): Array<number> { return this.props.actions.map((_item: UPActionSheetAction, index: number): number => index); }
  private panelRadius(): number { return UPStyle.parse(this.props.customStyle).borderRadius ?? Math.max(0, upNumber(this.props.round, 0)); }
  private actionDisabled(action: UPActionSheetAction): boolean { return upBoolean(action.disabled, false) || upBoolean(action.loading, false); }
  private close(reason: UPActionSheetCloseReason): void { this.props.onShowChange?.(false); this.props.onClose?.(reason); }
  private select(index: number): void {
    const action: UPActionSheetAction | undefined = this.props.actions[index];
    if (action === undefined || this.actionDisabled(action)) return;
    this.props.onSelect?.({ index, action });
    if (upBoolean(this.props.closeOnClickAction, true)) this.close('action');
  }
  private cancel(): void { this.props.onCancel?.(); this.close('cancel'); }
  private clickOverlay(): void {
    this.props.onClickOverlay?.();
    if (upBoolean(this.props.closeOnClickOverlay, true)) this.close('overlay');
  }

  @Builder
  private actionRow(index: number) {
    Row() {
      Column({ space: 3 }) {
        Text(upBoolean(this.props.actions[index].loading, false) ? '处理中…' : this.text(this.props.actions[index].name))
          .fontSize(UPUnit.parse(this.props.actions[index].fontSize, 375, 16))
          .fontColor(UPColor.parse(this.props.actions[index].color, UP_DEFAULT_THEME, '#303133'))
        if (this.text(this.props.actions[index].subname).length > 0) {
          Text(this.text(this.props.actions[index].subname)).fontSize(12).fontColor('#909399')
        }
      }.alignItems(HorizontalAlign.Center)
    }
    .width('100%').height(56).justifyContent(FlexAlign.Center)
    .border({ width: { bottom: 1 }, color: '#f2f2f2' })
    .opacity(this.actionDisabled(this.props.actions[index]) ? 0.45 : 1)
    .onClick(() => this.select(index))
  }

  @Builder
  private panel() {
    Column() {
      if (this.text(this.props.title).length > 0) Text(this.text(this.props.title)).fontSize(17).fontWeight(FontWeight.Bold).fontColor('#303133').padding({ top: 16, bottom: 6 })
      if (this.text(this.props.description).length > 0) Text(this.text(this.props.description)).fontSize(13).fontColor('#909399').padding({ left: 16, right: 16, bottom: 10 })
      Scroll() {
        Column() { ForEach(this.actionIndexes(), (index: number) => { this.actionRow(index) }, (index: number): string => String(index)) }.width('100%')
      }.constraintSize({ maxHeight: Math.max(80, UPUnit.parse(this.props.wrapMaxHeight, 375, 360)) })
      if (this.text(this.props.cancelText).length > 0) {
        Text(this.text(this.props.cancelText)).fontSize(16).fontColor('#303133').textAlign(TextAlign.Center).width('100%').height(54).padding({ top: 16 }).border({ width: { top: 8 }, color: '#f7f8fa' }).onClick(() => this.cancel())
      }
    }
    .width('100%').backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
    .borderRadius({ topLeft: this.panelRadius(), topRight: this.panelRadius() })
  }

  @Builder
  private content() {
    if (!upBoolean(this.props.show, false)) {
      Row().width(0).height(0)
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        Column().width('100%').height('100%').backgroundColor('#000000').opacity(0.5).onClick(() => this.clickOverlay())
        this.panel()
      }.width('100%').height('100%').zIndex(1002)
    }
  }
  build() { this.content() }
}
