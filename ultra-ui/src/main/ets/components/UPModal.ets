import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPI18n } from '../core/UPI18n';

export type UPModalActionType = 'confirm' | 'cancel' | 'overlay' | 'close';
export type UPModalCloseReason = UPModalActionType;

/** Action callback payload. Call done() exactly once when async work finishes. */
export interface UPModalAction {
  action: UPModalActionType;
  done: () => void;
}

export interface UPModalCloseEvent {
  reason: UPModalCloseReason;
}

export interface UPModalOptions {
  show?: UPRawValue;
  title?: UPRawValue;
  content?: UPRawValue;
  confirmText?: UPRawValue;
  cancelText?: UPRawValue;
  showConfirmButton?: UPRawValue;
  showCancelButton?: UPRawValue;
  confirmColor?: UPRawValue;
  cancelColor?: UPRawValue;
  buttonReverse?: UPRawValue;
  zoom?: UPRawValue;
  asyncClose?: UPRawValue;
  closeOnClickOverlay?: UPRawValue;
  negativeTop?: UPRawValue;
  width?: UPRawValue;
  confirmButtonShape?: UPRawValue;
  duration?: UPRawValue;
  contentTextAlign?: UPRawValue;
  contentStyle?: UPStyleInput;
  asyncCloseTip?: UPRawValue;
  asyncCancelClose?: UPRawValue;
  customStyle?: UPStyleInput;
  onShowChange?: (show: boolean) => void;
  onClickOverlay?: () => void;
  onAction?: (event: UPModalAction) => void;
  onConfirm?: (event: UPModalAction) => void;
  onCancel?: (event: UPModalAction) => void;
  onCancelOnAsync?: () => void;
  onClose?: (event: UPModalCloseEvent) => void;
  contentBuilder?: UPBuilder;
  confirmButtonBuilder?: UPBuilder;
  popupBottomBuilder?: UPBuilder;
}

/** Controlled confirmation dialog with explicit, one-shot async completion. */
export class UPModalProps {
  show: UPRawValue = false;
  title: UPRawValue = '';
  content: UPRawValue = '';
  confirmText: UPRawValue = UPI18n.t('up.common.confirm');
  cancelText: UPRawValue = UPI18n.t('up.common.cancel');
  showConfirmButton: UPRawValue = true;
  showCancelButton: UPRawValue = true;
  confirmColor: UPRawValue = 'primary';
  cancelColor: UPRawValue = 'content';
  buttonReverse: UPRawValue = false;
  zoom: UPRawValue = true;
  asyncClose: UPRawValue = false;
  closeOnClickOverlay: UPRawValue = false;
  negativeTop: UPRawValue = 0;
  width: UPRawValue = '650rpx';
  confirmButtonShape: UPRawValue = 'square';
  duration: UPRawValue = 300;
  contentTextAlign: UPRawValue = 'center';
  contentStyle: UPStyleInput = undefined;
  asyncCloseTip: UPRawValue = UPI18n.t('up.common.inOperation') + '...';
  asyncCancelClose: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  onShowChange?: (show: boolean) => void;
  onClickOverlay?: () => void;
  onAction?: (event: UPModalAction) => void;
  onConfirm?: (event: UPModalAction) => void;
  onCancel?: (event: UPModalAction) => void;
  onCancelOnAsync?: () => void;
  onClose?: (event: UPModalCloseEvent) => void;
  contentBuilder?: UPBuilder;
  confirmButtonBuilder?: UPBuilder;
  popupBottomBuilder?: UPBuilder;

  constructor(options?: UPModalOptions) {
    if (options === undefined) {
      return;
    }
    this.show = options.show ?? this.show;
    this.title = options.title ?? this.title;
    this.content = options.content ?? this.content;
    this.confirmText = options.confirmText ?? this.confirmText;
    this.cancelText = options.cancelText ?? this.cancelText;
    this.showConfirmButton = options.showConfirmButton ?? this.showConfirmButton;
    this.showCancelButton = options.showCancelButton ?? this.showCancelButton;
    this.confirmColor = options.confirmColor ?? this.confirmColor;
    this.cancelColor = options.cancelColor ?? this.cancelColor;
    this.buttonReverse = options.buttonReverse ?? this.buttonReverse;
    this.zoom = options.zoom ?? this.zoom;
    this.asyncClose = options.asyncClose ?? this.asyncClose;
    this.closeOnClickOverlay = options.closeOnClickOverlay ?? this.closeOnClickOverlay;
    this.negativeTop = options.negativeTop ?? this.negativeTop;
    this.width = options.width ?? this.width;
    this.confirmButtonShape = options.confirmButtonShape ?? this.confirmButtonShape;
    this.duration = options.duration ?? this.duration;
    this.contentTextAlign = options.contentTextAlign ?? this.contentTextAlign;
    this.contentStyle = options.contentStyle;
    this.asyncCloseTip = options.asyncCloseTip ?? this.asyncCloseTip;
    this.asyncCancelClose = options.asyncCancelClose ?? this.asyncCancelClose;
    this.customStyle = options.customStyle;
    this.onShowChange = options.onShowChange;
    this.onClickOverlay = options.onClickOverlay;
    this.onAction = options.onAction;
    this.onConfirm = options.onConfirm;
    this.onCancel = options.onCancel;
    this.onCancelOnAsync = options.onCancelOnAsync;
    this.onClose = options.onClose;
    this.contentBuilder = options.contentBuilder;
    this.confirmButtonBuilder = options.confirmButtonBuilder;
    this.popupBottomBuilder = options.popupBottomBuilder;
  }
}

function modalColor(value: UPRawValue, fallback: string): string {
  const source: string = upString(value, '');
  if (source === 'primary') {
    return UP_DEFAULT_THEME.primary;
  }
  if (source === 'success') {
    return UP_DEFAULT_THEME.success;
  }
  if (source === 'warning') {
    return UP_DEFAULT_THEME.warning;
  }
  if (source === 'error') {
    return UP_DEFAULT_THEME.error;
  }
  return UPColor.parse(value, UP_DEFAULT_THEME, fallback);
}

@Component
export struct UPModal {
  @Prop props: UPModalProps = new UPModalProps();
  @State private pendingAction: string = '';
  private active: boolean = true;
  private actionSerial: number = 0;

  @Builder
  private defaultContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.defaultContent;

  aboutToDisappear(): void {
    this.active = false;
    this.actionSerial += 1;
  }

  private isVisible(): boolean {
    return upBoolean(this.props.show, false);
  }

  private text(value: UPRawValue): string {
    if (value === null || value === undefined) {
      return '';
    }
    return String(value);
  }

  private modalWidth(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.width !== undefined) {
      return style.width;
    }
    return UPUnit.parse(this.props.width, 375, 325);
  }

  private panelRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderRadius ?? 8;
  }

  private panelPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? { top: 22, right: 20, bottom: 8, left: 20 };
  }

  private panelColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? '#ffffff';
  }

  private contentColor(): string {
    const style = UPStyle.parse(this.props.contentStyle);
    return style.color ?? UPColor.neutral('content', '#606266');
  }

  private contentFontSize(): number {
    const style = UPStyle.parse(this.props.contentStyle);
    return style.fontSize ?? 15;
  }

  private contentTextAlign(): TextAlign {
    const value: string = upString(this.props.contentTextAlign, 'center').toLowerCase();
    if (value === 'left') {
      return TextAlign.Start;
    }
    if (value === 'right') {
      return TextAlign.End;
    }
    return TextAlign.Center;
  }

  private titleText(): string {
    return this.text(this.props.title);
  }

  private bodyText(): string {
    return this.text(this.props.content);
  }

  private actionIsAsync(action: UPModalActionType): boolean {
    if (action === 'cancel') {
      return upBoolean(this.props.asyncCancelClose, false);
    }
    return action === 'confirm' && upBoolean(this.props.asyncClose, false);
  }

  private dispatchAction(action: UPModalActionType): void {
    if (this.pendingAction.length > 0) {
      return;
    }
    this.actionSerial += 1;
    const serial: number = this.actionSerial;
    let completed: boolean = false;
    const done = (): void => {
      if (completed || !this.active || serial !== this.actionSerial) {
        return;
      }
      completed = true;
      this.pendingAction = '';
      this.props.onShowChange?.(false);
      this.props.onClose?.({ reason: action });
    };

    const asynchronous: boolean = this.actionIsAsync(action);
    this.pendingAction = asynchronous ? action : '';
    const request: UPModalAction = { action, done };
    this.props.onAction?.(request);
    /** 上游按动作分派 confirm / cancel / cancelOnAsync。/ Upstream dispatches per action. */
    if (action === 'confirm') {
      this.props.onConfirm?.(request);
    } else if (action === 'cancel') {
      if (asynchronous) {
        this.props.onCancelOnAsync?.();
      }
      this.props.onCancel?.(request);
    }
    const handled: boolean = this.props.onAction !== undefined
      || (action === 'confirm' && this.props.onConfirm !== undefined)
      || (action === 'cancel' && this.props.onCancel !== undefined);
    if (!asynchronous || !handled) {
      done();
    }
  }

  private clickOverlay(): void {
    this.props.onClickOverlay?.();
    if (upBoolean(this.props.closeOnClickOverlay, false)) {
      this.dispatchAction('overlay');
    }
  }

  private confirmLabel(): string {
    return this.text(this.props.confirmText);
  }

  private cancelLabel(): string {
    return this.text(this.props.cancelText);
  }

  private waitingLabel(): string {
    return this.text(this.props.asyncCloseTip);
  }

  @Builder
  private actionButtons() {
    Row({ space: 12 }) {
      if (upBoolean(this.props.showCancelButton, true) && !upBoolean(this.props.buttonReverse, false)) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text(this.cancelLabel())
        }
        .fontColor(modalColor(this.props.cancelColor, UPColor.neutral('content', '#606266')))
        .backgroundColor('#f5f6f8')
        .borderRadius(UPUnit.parse(this.props.confirmButtonShape, 375, 4))
        .onClick(() => this.dispatchAction('cancel'))
      }
      if (upBoolean(this.props.showConfirmButton, true) && !upBoolean(this.props.buttonReverse, false)) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text(this.confirmLabel())
        }
        .fontColor('#ffffff')
        .backgroundColor(modalColor(this.props.confirmColor, UP_DEFAULT_THEME.primary))
        .borderRadius(4)
        .onClick(() => this.dispatchAction('confirm'))
      }
      if (upBoolean(this.props.showConfirmButton, true) && upBoolean(this.props.buttonReverse, false)) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text(this.confirmLabel())
        }
        .fontColor('#ffffff')
        .backgroundColor(modalColor(this.props.confirmColor, UP_DEFAULT_THEME.primary))
        .borderRadius(4)
        .onClick(() => this.dispatchAction('confirm'))
      }
      if (upBoolean(this.props.showCancelButton, true) && upBoolean(this.props.buttonReverse, false)) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text(this.cancelLabel())
        }
        .fontColor(modalColor(this.props.cancelColor, UPColor.neutral('content', '#606266')))
        .backgroundColor('#f5f6f8')
        .borderRadius(4)
        .onClick(() => this.dispatchAction('cancel'))
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  private modalPanel() {
    Column() {
      if (this.titleText().length > 0) {
        Text(this.titleText())
          .width('100%')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(UPColor.neutral('main', '#303133'))
          .textAlign(TextAlign.Center)
      }
      if (this.bodyText().length > 0) {
        Text(this.bodyText())
          .width('100%')
          .margin({ top: 14 })
          .fontSize(this.contentFontSize())
          .fontColor(this.contentColor())
          .textAlign(this.contentTextAlign())
      }
      this.contentBuilder()
      if (this.pendingAction.length > 0 && this.waitingLabel().length > 0) {
        Text(this.waitingLabel())
          .width('100%')
          .margin({ top: 10 })
          .fontSize(13)
          .fontColor(UPColor.neutral('tips', '#909399'))
          .textAlign(TextAlign.Center)
      }
      Divider()
        .margin({ top: 12 })
        .color('#eeeeee')
      if (this.props.confirmButtonBuilder !== undefined) {
        this.confirmButtonRegion()
      } else {
        this.actionButtons()
      }
    }
    .width(this.modalWidth())
    .padding(this.panelPadding())
    .backgroundColor(this.panelColor())
    .borderRadius(this.panelRadius())
    .offset({ y: UPUnit.parse(this.props.negativeTop, 375, 0, true) })
  }

  @Builder
  private content() {
    if (!this.isVisible()) {
      Row().width(0).height(0)
    } else {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.5)
          .onClick(() => this.clickOverlay())
        Column() {
          this.modalPanel()
          this.popupBottomRegion()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .align(Alignment.Center)
      }
      .width('100%')
      .height('100%')
      .zIndex(1002)
    }
  }

  @Builder
  private confirmButtonRegion() {
    UPSlotRegion({ contentBuilder: this.props.confirmButtonBuilder })
  }

  @Builder
  private popupBottomRegion() {
    UPSlotRegion({ contentBuilder: this.props.popupBottomBuilder })
  }

  build() {
    this.content()
  }
}
