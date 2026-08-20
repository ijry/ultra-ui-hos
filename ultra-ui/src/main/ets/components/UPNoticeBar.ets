import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPNoticeBarClickEvent { index: number; url: string; linkType: string; }
export interface UPNoticeBarOptions {
  show?: UPRawValue; text?: UPRawValue | Array<UPRawValue>; direction?: UPRawValue; step?: UPRawValue;
  icon?: UPRawValue; mode?: UPRawValue; color?: UPRawValue; bgColor?: UPRawValue; speed?: UPRawValue;
  fontSize?: UPRawValue; duration?: UPRawValue; disableTouch?: UPRawValue; url?: UPRawValue; linkType?: UPRawValue;
  justifyContent?: UPRawValue; customStyle?: UPStyleInput; onShowChange?: (show: boolean) => void;
  onClick?: (event: UPNoticeBarClickEvent) => void; onClose?: () => void;
}
export class UPNoticeBarProps {
  show: UPRawValue = true; text: UPRawValue | Array<UPRawValue> = ''; direction: UPRawValue = 'row'; step: UPRawValue = false;
  icon: UPRawValue = ''; mode: UPRawValue = ''; color: UPRawValue = '#f60'; bgColor: UPRawValue = '#fff7e6'; speed: UPRawValue = 50;
  fontSize: UPRawValue = 14; duration: UPRawValue = 0; disableTouch: UPRawValue = false; url: UPRawValue = ''; linkType: UPRawValue = '';
  justifyContent: UPRawValue = 'start'; customStyle: UPStyleInput = undefined; onShowChange?: (show: boolean) => void;
  onClick?: (event: UPNoticeBarClickEvent) => void; onClose?: () => void;
  constructor(options?: UPNoticeBarOptions) {
    if (options === undefined) return;
    this.show = options.show ?? this.show; this.text = options.text ?? this.text; this.direction = options.direction ?? this.direction;
    this.step = options.step ?? this.step; this.icon = options.icon ?? this.icon; this.mode = options.mode ?? this.mode; this.color = options.color ?? this.color;
    this.bgColor = options.bgColor ?? this.bgColor; this.speed = options.speed ?? this.speed; this.fontSize = options.fontSize ?? this.fontSize;
    this.duration = options.duration ?? this.duration; this.disableTouch = options.disableTouch ?? this.disableTouch; this.url = options.url ?? this.url;
    this.linkType = options.linkType ?? this.linkType; this.justifyContent = options.justifyContent ?? this.justifyContent; this.customStyle = options.customStyle;
    this.onShowChange = options.onShowChange; this.onClick = options.onClick; this.onClose = options.onClose;
  }
}
@Component
export struct UPNoticeBar {
  @Prop props: UPNoticeBarProps = new UPNoticeBarProps();
  private values(): Array<string> {
    if (Array.isArray(this.props.text)) return this.props.text.filter((v: UPRawValue): boolean => v !== null && v !== undefined && String(v).length > 0).map((v: UPRawValue): string => String(v));
    return this.props.text === null || this.props.text === undefined ? [] : [String(this.props.text)];
  }
  private close(): void { this.props.onShowChange?.(false); this.props.onClose?.(); }
  private click(): void { this.props.onClick?.({ index: 0, url: upString(this.props.url, ''), linkType: upString(this.props.linkType, '') }); }
  private color(): string { return UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#f60'); }
  private contentText(): string { const items: Array<string> = this.values(); return items.length > 0 ? items.join('  ·  ') : '暂无公告'; }
  @Builder
  private content() {
    if (!upBoolean(this.props.show, true)) {
      Row().width(0).height(0)
    } else {
      Row({ space: 8 }) {
        Text(upString(this.props.icon, '').length > 0 ? upString(this.props.icon, '') : '!').fontSize(14).fontColor(this.color())
        Text(this.contentText()).fontSize(UPUnit.parse(this.props.fontSize, 375, 14)).fontColor(this.color()).maxLines(1).layoutWeight(1).onClick(() => this.click())
        if (upString(this.props.mode, '') === 'closable') Text('×').fontSize(18).fontColor(this.color()).onClick(() => this.close())
        else if (upString(this.props.mode, '') === 'link') Text('>').fontSize(20).fontColor(this.color()).onClick(() => this.click())
      }.width('100%').padding({ top: 10, right: 12, bottom: 10, left: 12 }).backgroundColor(UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#fff7e6')).borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 0).opacity(UPStyle.parse(this.props.customStyle).opacity ?? 1)
    }
  }

  build() {
    this.content()
  }
}
