import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export type UPAlertType = 'primary' | 'success' | 'warning' | 'error' | 'info';
export type UPAlertEffect = 'light' | 'dark';
export interface UPAlertVisibleEvent { visible: boolean; }
export interface UPAlertClickEvent { type: UPAlertType; }

export interface UPAlertOptions {
  title?: UPRawValue; type?: UPRawValue; description?: UPRawValue; closable?: UPRawValue;
  showIcon?: UPRawValue; effect?: UPRawValue; center?: UPRawValue; fontSize?: UPRawValue;
  transitionMode?: UPRawValue; duration?: UPRawValue; icon?: UPRawValue;
  modelValue?: UPRawValue; value?: UPRawValue; customStyle?: UPStyleInput;
  onVisibleChange?: (visible: boolean) => void; onClick?: (event: UPAlertClickEvent) => void;
  onClose?: () => void; onClosed?: () => void;
}

export class UPAlertProps {
  title: UPRawValue = '';
  type: UPRawValue = 'warning';
  description: UPRawValue = '';
  closable: UPRawValue = false;
  showIcon: UPRawValue = true;
  effect: UPRawValue = 'light';
  center: UPRawValue = false;
  fontSize: UPRawValue = 14;
  transitionMode: UPRawValue = '';
  duration: UPRawValue = 300;
  icon: UPRawValue = '';
  modelValue: UPRawValue = undefined;
  value: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  onVisibleChange?: (visible: boolean) => void;
  onClick?: (event: UPAlertClickEvent) => void;
  onClose?: () => void;
  onClosed?: () => void;

  constructor(options?: UPAlertOptions) {
    if (options === undefined) return;
    this.title = options.title ?? this.title; this.type = options.type ?? this.type;
    this.description = options.description ?? this.description; this.closable = options.closable ?? this.closable;
    this.showIcon = options.showIcon ?? this.showIcon; this.effect = options.effect ?? this.effect;
    this.center = options.center ?? this.center; this.fontSize = options.fontSize ?? this.fontSize;
    this.transitionMode = options.transitionMode ?? this.transitionMode; this.duration = options.duration ?? this.duration;
    this.icon = options.icon ?? this.icon; this.modelValue = options.modelValue ?? this.modelValue;
    this.value = options.value ?? this.value; this.customStyle = options.customStyle;
    this.onVisibleChange = options.onVisibleChange; this.onClick = options.onClick;
    this.onClose = options.onClose; this.onClosed = options.onClosed;
  }
}

function alertColor(type: UPAlertType): string {
  switch (type) {
    case 'primary': return UP_DEFAULT_THEME.primary;
    case 'success': return UP_DEFAULT_THEME.success;
    case 'error': return UP_DEFAULT_THEME.error;
    case 'info': return UP_DEFAULT_THEME.info;
    default: return UP_DEFAULT_THEME.warning;
  }
}

@Component
export struct UPAlert {
  @Prop props: UPAlertProps = new UPAlertProps();

  private visible(): boolean {
    const value: UPRawValue = this.props.modelValue !== null && this.props.modelValue !== undefined ?
      this.props.modelValue : this.props.value;
    return upBoolean(value, true);
  }
  private type(): UPAlertType {
    const value: string = upString(this.props.type, 'warning').toLowerCase();
    return value === 'primary' || value === 'success' || value === 'error' || value === 'info' ? value as UPAlertType : 'warning';
  }
  private text(value: UPRawValue): string { return value === null || value === undefined ? '' : String(value); }
  private close(): void {
    this.props.onVisibleChange?.(false); this.props.onClose?.(); this.props.onClosed?.();
  }
  private color(): string { return alertColor(this.type()); }
  private alertPadding(): UPEdgeValues {
    return UPStyle.parse(this.props.customStyle).padding ?? { top: 12, right: 14, bottom: 12, left: 14 };
  }
  @Builder
  private content() {
    if (!this.visible()) {
      Row().width(0).height(0)
    } else {
      Row({ space: 10 }) {
        if (upBoolean(this.props.showIcon, true)) {
          Text(this.text(this.props.icon).length > 0 ? this.text(this.props.icon) : '●')
            .fontSize(14).fontColor(this.color())
        }
        Column({ space: 3 }) {
          if (this.text(this.props.title).length > 0) Text(this.text(this.props.title)).fontSize(UPUnit.parse(this.props.fontSize, 375, 14)).fontColor(this.color()).fontWeight(FontWeight.Bold)
          if (this.text(this.props.description).length > 0) Text(this.text(this.props.description)).fontSize(13).fontColor(this.color()).maxLines(3)
        }.layoutWeight(1).alignItems(upBoolean(this.props.center, false) ? HorizontalAlign.Center : HorizontalAlign.Start)
        if (upBoolean(this.props.closable, false)) Text('×').fontSize(20).fontColor(this.color()).onClick(() => this.close())
      }
      .width('100%').padding(this.alertPadding()).backgroundColor(upString(this.props.effect, 'light') === 'dark' ? this.color() : this.color() + '18')
      .borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 4).opacity(UPStyle.parse(this.props.customStyle).opacity ?? 1)
      .onClick(() => this.props.onClick?.({ type: this.type() }))
    }
  }

  build() {
    this.content()
  }
}
