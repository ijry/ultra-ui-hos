import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPI18n } from '../core/UPI18n';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPToolbarActionEvent {
  action: 'cancel' | 'confirm';
}

export interface UPToolbarOptions {
  show?: UPRawValue;
  cancelText?: UPRawValue;
  confirmText?: UPRawValue;
  title?: UPRawValue;
  cancelColor?: UPRawValue;
  confirmColor?: UPRawValue;
  titleColor?: UPRawValue;
  height?: UPRawValue;
  border?: UPRawValue;
  customStyle?: UPStyleInput;
  onCancel?: () => void;
  onConfirm?: () => void;
  onAction?: (event: UPToolbarActionEvent) => void;
  rightBuilder?: UPBuilder;
}

export class UPToolbarProps {
  show: UPRawValue = true;
  cancelText: UPRawValue = UPI18n.t('up.common.cancel');
  confirmText: UPRawValue = UPI18n.t('up.common.confirm');
  title: UPRawValue = '';
  cancelColor: UPRawValue = '#606266';
  confirmColor: UPRawValue = '#2979ff';
  titleColor: UPRawValue = '#303133';
  height: UPRawValue = 44;
  border: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  onCancel?: () => void;
  onConfirm?: () => void;
  onAction?: (event: UPToolbarActionEvent) => void;
  rightBuilder?: UPBuilder;

  constructor(options?: UPToolbarOptions) {
    if (options === undefined) return;
    this.show = options.show ?? this.show;
    this.cancelText = options.cancelText ?? this.cancelText;
    this.confirmText = options.confirmText ?? this.confirmText;
    this.title = options.title ?? this.title;
    this.cancelColor = options.cancelColor ?? this.cancelColor;
    this.confirmColor = options.confirmColor ?? this.confirmColor;
    this.titleColor = options.titleColor ?? this.titleColor;
    this.height = options.height ?? this.height;
    this.border = options.border ?? this.border;
    this.customStyle = options.customStyle;
    this.onCancel = options.onCancel;
    this.onConfirm = options.onConfirm;
    this.onAction = options.onAction;
    this.rightBuilder = options.rightBuilder;
  }
}

@Component
export struct UPToolbar {
  @Prop props: UPToolbarProps = new UPToolbarProps();

  private textValue(value: UPRawValue): string {
    return value === null || value === undefined ? '' : String(value);
  }

  private toolbarHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(36, style.height ?? UPUnit.parse(this.props.height, 375, 44));
  }

  private toolbarWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? '100%';
  }

  private toolbarPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? { top: 0, right: 16, bottom: 0, left: 16 };
  }

  private toolbarBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? '#ffffff';
  }

  private titleColor(): string {
    return UPColor.parse(this.props.titleColor, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133'));
  }

  private cancelColor(): string {
    return UPColor.parse(this.props.cancelColor, UP_DEFAULT_THEME, UPColor.neutral('content', '#606266'));
  }

  private confirmColor(): string {
    return UPColor.parse(this.props.confirmColor, UP_DEFAULT_THEME, '#2979ff');
  }

  private emitCancel(): void {
    this.props.onCancel?.();
    this.props.onAction?.({ action: 'cancel' });
  }

  private emitConfirm(): void {
    this.props.onConfirm?.();
    this.props.onAction?.({ action: 'confirm' });
  }

  @Builder
  private toolbarContent() {
    Row() {
      Text(this.textValue(this.props.cancelText))
        .fontSize(15)
        .fontColor(this.cancelColor())
        .padding({ right: 12 })
        .onClick(() => this.emitCancel())
      Text(this.textValue(this.props.title))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.titleColor())
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
      if (this.props.rightBuilder !== undefined) {
        this.rightRegion()
      } else {
        Text(this.textValue(this.props.confirmText))
          .fontSize(15)
          .fontColor(this.confirmColor())
          .padding({ left: 12 })
          .onClick(() => this.emitConfirm())
      }
    }
    .width(this.toolbarWidth())
    .height(this.toolbarHeight())
    .padding(this.toolbarPadding())
    .backgroundColor(this.toolbarBackground())
    .borderWidth(upBoolean(this.props.border, true) ? 0.5 : 0)
    .borderColor(UPColor.adaptive('#ebeef5', 'border-color'))
  }

  @Builder
  private rightRegion() {
    UPSlotRegion({ contentBuilder: this.props.rightBuilder })
  }

  build() {
    if (upBoolean(this.props.show, true)) this.toolbarContent()
    else Row().width(0).height(0)
  }
}
