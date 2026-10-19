import { UPBuilder, UPRawValue, UPStyleInput, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPBackTopEvent { duration: number; }
export interface UPBackTopOptions {
  mode?: UPRawValue; icon?: UPRawValue; text?: UPRawValue; duration?: UPRawValue;
  scrollTop?: UPRawValue; top?: UPRawValue; bottom?: UPRawValue; right?: UPRawValue;
  zIndex?: UPRawValue; iconStyle?: UPStyleInput; customStyle?: UPStyleInput;
  onClick?: () => void; onBackToTop?: (event: UPBackTopEvent) => void;
  contentBuilder?: UPBuilder;
}
export class UPBackTopProps {
  mode: UPRawValue = 'circle'; icon: UPRawValue = 'arrow-up'; text: UPRawValue = '';
  duration: UPRawValue = 100; scrollTop: UPRawValue = 0; top: UPRawValue = 400;
  bottom: UPRawValue = 100; right: UPRawValue = 20; zIndex: UPRawValue = 9;
  iconStyle: UPStyleInput = undefined; customStyle: UPStyleInput = undefined;
  onClick?: () => void; onBackToTop?: (event: UPBackTopEvent) => void;
  contentBuilder?: UPBuilder;
  constructor(options?: UPBackTopOptions) {
    if (options === undefined) return;
    this.mode = options.mode ?? this.mode; this.icon = options.icon ?? this.icon; this.text = options.text ?? this.text;
    this.duration = options.duration ?? this.duration; this.scrollTop = options.scrollTop ?? this.scrollTop;
    this.top = options.top ?? this.top; this.bottom = options.bottom ?? this.bottom; this.right = options.right ?? this.right;
    this.zIndex = options.zIndex ?? this.zIndex; this.iconStyle = options.iconStyle; this.customStyle = options.customStyle;
    this.onClick = options.onClick; this.onBackToTop = options.onBackToTop;
    this.contentBuilder = options.contentBuilder;
  }
}
@Component
export struct UPBackTop {
  @Prop props: UPBackTopProps = new UPBackTopProps();
  private visible(): boolean { return upNumber(this.props.scrollTop, 0) >= upNumber(this.props.top, 400); }
  private modeName(): string { return upString(this.props.mode, 'circle').toLowerCase() === 'square' ? 'square' : 'circle'; }
  private modeFallback(): string { return 'circle'; }
  private label(): string { const text: string = upString(this.props.text, ''); return text.length > 0 ? text : '↑'; }
  private click(): void { this.props.onClick?.(); this.props.onBackToTop?.({ duration: Math.max(0, upNumber(this.props.duration, 100)) }); }
  @Builder
  private content() {
    if (!this.visible()) {
      Row().width(0).height(0)
    } else {
      Stack({ alignContent: Alignment.BottomEnd }) {
        if (this.props.contentBuilder !== undefined) {
          this.slotRegion()
        } else {
        Text(this.label()).fontSize(UPStyle.parse(this.props.iconStyle).fontSize ?? 18)
          .fontColor(UPStyle.parse(this.props.iconStyle).color ?? UPColor.parse('primary', UP_DEFAULT_THEME))
          .textAlign(TextAlign.Center).width(44).height(44).padding({ top: 11 })
          .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
          .borderRadius(this.modeName() === 'circle' ? 22 : 4).shadow({ radius: 8, color: '#22000000' })
          .margin({ right: Math.max(0, UPUnit.parse(this.props.right, 375, 20)), bottom: Math.max(0, UPUnit.parse(this.props.bottom, 375, 100)) })
          .onClick(() => this.click())
        }
      }.width('100%').height('100%').zIndex(Math.max(0, upNumber(this.props.zIndex, 9)))
    }
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  build() { this.content() }
}
