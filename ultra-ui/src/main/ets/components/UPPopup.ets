import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export type UPPopupMode = 'top' | 'bottom' | 'left' | 'right' | 'center';
export type UPPopupCloseReason = 'overlay' | 'close' | 'programmatic';

export interface UPPopupCloseEvent {
  reason: UPPopupCloseReason;
}

export interface UPPopupOptions {
  show?: UPRawValue;
  overlay?: UPRawValue;
  mode?: UPRawValue;
  duration?: UPRawValue;
  closeable?: UPRawValue;
  closeOnClickOverlay?: UPRawValue;
  zIndex?: UPRawValue;
  safeAreaInsetBottom?: UPRawValue;
  safeAreaInsetTop?: UPRawValue;
  closeIconPos?: UPRawValue;
  round?: UPRawValue;
  zoom?: UPRawValue;
  bgColor?: UPRawValue;
  overlayOpacity?: UPRawValue;
  touchable?: UPRawValue;
  minHeight?: UPRawValue;
  maxHeight?: UPRawValue;
  customStyle?: UPStyleInput;
  onShowChange?: (show: boolean) => void;
  onClose?: (event: UPPopupCloseEvent) => void;
  onOpen?: () => void;
  onClosed?: (event: UPPopupCloseEvent) => void;
  onClick?: () => void;
  onClickOverlay?: () => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
  bottomBuilder?: UPBuilder;
}

/** Controlled panel that keeps placement and close reasons source-compatible with uview-plus. */
export class UPPopupProps {
  show: UPRawValue = false;
  overlay: UPRawValue = true;
  mode: UPRawValue = 'bottom';
  duration: UPRawValue = 300;
  closeable: UPRawValue = false;
  closeOnClickOverlay: UPRawValue = true;
  zIndex: UPRawValue = 1001;
  safeAreaInsetBottom: UPRawValue = false;
  safeAreaInsetTop: UPRawValue = false;
  closeIconPos: UPRawValue = 'top-right';
  round: UPRawValue = false;
  zoom: UPRawValue = true;
  bgColor: UPRawValue = '#ffffff';
  overlayOpacity: UPRawValue = 0.5;
  touchable: UPRawValue = true;
  minHeight: UPRawValue = '';
  maxHeight: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  onShowChange?: (show: boolean) => void;
  onClose?: (event: UPPopupCloseEvent) => void;
  onOpen?: () => void;
  onClosed?: (event: UPPopupCloseEvent) => void;
  onClick?: () => void;
  onClickOverlay?: () => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
  bottomBuilder?: UPBuilder;

  constructor(options?: UPPopupOptions) {
    if (options === undefined) {
      return;
    }
    this.show = options.show ?? this.show;
    this.overlay = options.overlay ?? this.overlay;
    this.mode = options.mode ?? this.mode;
    this.duration = options.duration ?? this.duration;
    this.closeable = options.closeable ?? this.closeable;
    this.closeOnClickOverlay = options.closeOnClickOverlay ?? this.closeOnClickOverlay;
    this.zIndex = options.zIndex ?? this.zIndex;
    this.safeAreaInsetBottom = options.safeAreaInsetBottom ?? this.safeAreaInsetBottom;
    this.safeAreaInsetTop = options.safeAreaInsetTop ?? this.safeAreaInsetTop;
    this.closeIconPos = options.closeIconPos ?? this.closeIconPos;
    this.round = options.round ?? this.round;
    this.zoom = options.zoom ?? this.zoom;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.overlayOpacity = options.overlayOpacity ?? this.overlayOpacity;
    this.touchable = options.touchable ?? this.touchable;
    this.minHeight = options.minHeight ?? this.minHeight;
    this.maxHeight = options.maxHeight ?? this.maxHeight;
    this.customStyle = options.customStyle;
    this.onShowChange = options.onShowChange;
    this.onClose = options.onClose;
    this.onOpen = options.onOpen;
    this.onClosed = options.onClosed;
    this.onClick = options.onClick;
    this.onClickOverlay = options.onClickOverlay;
    this.contentBuilder = options.contentBuilder;
    this.triggerBuilder = options.triggerBuilder;
    this.bottomBuilder = options.bottomBuilder;
  }
}

@Component
export struct UPPopup {
  @Prop props: UPPopupProps = new UPPopupProps();
  @Builder
  private defaultContent() {
    Text('弹出层内容')
  }

  @BuilderParam contentBuilder: () => void = this.defaultContent;

  private isVisible(): boolean {
    return upBoolean(this.props.show, false);
  }

  private modeName(): UPPopupMode {
    const mode: string = upString(this.props.mode, 'bottom').toLowerCase();
    if (mode === 'top' || mode === 'left' || mode === 'right' || mode === 'center') {
      return mode as UPPopupMode;
    }
    return 'bottom';
  }

  private panelWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.width !== undefined) {
      return style.width;
    }
    const mode: UPPopupMode = this.modeName();
    return mode === 'left' || mode === 'right' || mode === 'center' ? '86%' : '100%';
  }

  private panelHeight(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.height !== undefined) {
      return style.height;
    }
    const mode: UPPopupMode = this.modeName();
    return mode === 'left' || mode === 'right' || mode === 'center' ? 'auto' : 'auto';
  }

  private panelRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderRadius !== undefined) {
      return style.borderRadius;
    }
    if (!upBoolean(this.props.round, false)) {
      return 0;
    }
    switch (this.modeName()) {
      case 'top': return 16;
      case 'bottom': return 16;
      case 'left': return 16;
      case 'right': return 16;
      default: return 12;
    }
  }

  private panelColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color'));
  }

  private panelPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    const padding = style.padding;
    if (padding !== undefined) {
      return padding;
    }
    const top: number = upBoolean(this.props.safeAreaInsetTop, false) ? 24 : 16;
    const bottom: number = upBoolean(this.props.safeAreaInsetBottom, false) ? 24 : 16;
    return { top, right: 16, bottom, left: 16 };
  }

  private overlayOpacity(): number {
    const value: number = upNumber(this.props.overlayOpacity, 0.5);
    return Math.max(0, Math.min(1, value));
  }

  private popupZIndex(): number {
    return Math.max(0, upNumber(this.props.zIndex, 1001));
  }

  /** 上游 close 与 closed 是动画前后的一对事件；ArkUI 立即完成，两者同帧触发。/ Upstream close/closed pair. */
  private close(reason: UPPopupCloseReason): void {
    this.props.onClose?.({ reason });
    this.props.onShowChange?.(false);
    this.props.onClosed?.({ reason });
  }

  private clickOverlay(): void {
    this.props.onClickOverlay?.();
    if (upBoolean(this.props.closeOnClickOverlay, true)) {
      this.close('overlay');
    }
  }

  private closeIconVisible(): boolean {
    return upBoolean(this.props.closeable, false);
  }

  private closeIcon(): void {
    this.close('close');
  }

  @Builder
  private panelContent() {
    Stack() {
      Column() {
        this.contentBuilder()
      }
      .width(this.panelWidth())
      .height(this.panelHeight())
      .padding(this.panelPadding())
      .backgroundColor(this.panelColor())
      .borderRadius(this.panelRadius())
      .constraintSize({
        minHeight: UPUnit.parseOptional(this.props.minHeight, 375),
        maxHeight: UPUnit.parseOptional(this.props.maxHeight, 375)
      })
      .onClick(() => {
        if (upBoolean(this.props.touchable, true)) {
          // A panel click is intentionally consumed so it does not close its overlay.
          this.props.onClick?.();
        }
      })

      if (this.closeIconVisible()) {
        Text('×')
          .fontSize(24)
          .fontColor('#666666')
          .position({ x: this.closeIconPositionX(), y: this.closeIconPositionY() })
          .onClick(() => this.closeIcon())
      }
    }
    .width(this.panelWidth())
    .height(this.panelHeight())
  }

  private closeIconPositionX(): number | string {
    const position: string = upString(this.props.closeIconPos, 'top-right').toLowerCase();
    return position.indexOf('left') >= 0 ? 12 : 'auto';
  }

  private closeIconPositionY(): number | string {
    const position: string = upString(this.props.closeIconPos, 'top-right').toLowerCase();
    return position.indexOf('bottom') >= 0 ? 'auto' : 8;
  }

  @Builder
  private placement() {
    if (this.modeName() === 'top') {
      Column() {
        this.panelContent()
      }
      .width('100%')
      .align(Alignment.Top)
    } else if (this.modeName() === 'left') {
      Row() {
        this.panelContent()
      }
      .width('100%')
      .align(Alignment.Start)
    } else if (this.modeName() === 'right') {
      Row() {
        this.panelContent()
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .align(Alignment.End)
    } else if (this.modeName() === 'center') {
      Column() {
        this.panelContent()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .align(Alignment.Center)
    } else {
      Column() {
        this.panelContent()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .align(Alignment.Bottom)
    }
  }

  @Builder
  private content() {
    if (!this.isVisible()) {
      Row().width(0).height(0)
    } else {
      Stack() {
        if (upBoolean(this.props.overlay, true)) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(this.overlayOpacity())
            .onClick(() => this.clickOverlay())
        }
        this.placement()
        this.bottomRegion()
      }
      .width('100%')
      .height('100%')
      .zIndex(this.popupZIndex())
      .onAppear(() => this.props.onOpen?.())
    }
  }

  @Builder
  private triggerRegion() {
    UPSlotRegion({ contentBuilder: this.props.triggerBuilder })
  }

  @Builder
  private bottomRegion() {
    UPSlotRegion({ contentBuilder: this.props.bottomBuilder })
  }

  build() {
    Stack() {
      this.triggerRegion()
      this.content()
    }
  }
}
