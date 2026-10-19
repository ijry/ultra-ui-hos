import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics } from '../core/UPDiagnostics';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPTooltipButton { label: UPRawValue; index: number; }
export interface UPTooltipButtonEvent extends UPTooltipButton {}
export interface UPTooltipCopyEvent { text: string; }
export interface UPTooltipOptions {
  text?: UPRawValue; copyText?: UPRawValue; size?: UPRawValue; color?: UPRawValue; bgColor?: UPRawValue;
  direction?: UPRawValue; zIndex?: UPRawValue; showCopy?: boolean; buttons?: Array<UPRawValue>;
  overlay?: boolean; showToast?: boolean; popupBgColor?: UPRawValue; triggerMode?: UPRawValue;
  show?: boolean; modelValue?: boolean; customStyle?: UPStyleInput;
  onShowChange?: (show: boolean) => void; onCopy?: (event: UPTooltipCopyEvent) => void;
  onButtonClick?: (event: UPTooltipButtonEvent) => void;
  onClick?: (event: UPTooltipButtonEvent) => void; onOpen?: () => void; onClose?: () => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
}
export class UPTooltipProps {
  text: UPRawValue = ''; copyText: UPRawValue = ''; size: UPRawValue = 14; color: string = '#606266';
  bgColor: string = 'transparent'; direction: UPRawValue = 'top'; zIndex: UPRawValue = 10071;
  showCopy: boolean = true; buttons: Array<UPRawValue> = []; overlay: boolean = true;
  showToast: boolean = true; popupBgColor: string = ''; triggerMode: UPRawValue = 'longpress';
  show: boolean = false; modelValue: UPRawValue = undefined; customStyle: UPStyleInput = undefined;
  onShowChange?: (show: boolean) => void; onCopy?: (event: UPTooltipCopyEvent) => void;
  onButtonClick?: (event: UPTooltipButtonEvent) => void;
  onClick?: (event: UPTooltipButtonEvent) => void; onOpen?: () => void; onClose?: () => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
  constructor(options?: UPTooltipOptions) {
    if (options === undefined) return;
    this.text = options.text ?? this.text; this.copyText = options.copyText ?? this.copyText;
    this.size = options.size ?? this.size; this.color = upString(options.color, this.color);
    this.bgColor = upString(options.bgColor, this.bgColor); this.direction = options.direction ?? this.direction;
    this.zIndex = options.zIndex ?? this.zIndex; this.showCopy = options.showCopy ?? this.showCopy;
    this.buttons = options.buttons ?? this.buttons; this.overlay = options.overlay ?? this.overlay;
    this.showToast = options.showToast ?? this.showToast; this.popupBgColor = upString(options.popupBgColor, this.popupBgColor);
    this.triggerMode = options.triggerMode ?? this.triggerMode; this.show = options.show ?? this.show;
    this.modelValue = options.modelValue ?? this.modelValue; this.customStyle = options.customStyle;
    this.onShowChange = options.onShowChange; this.onCopy = options.onCopy; this.onButtonClick = options.onButtonClick;
    this.onClick = options.onClick; this.onOpen = options.onOpen; this.onClose = options.onClose;
    this.contentBuilder = options.contentBuilder;
    this.triggerBuilder = options.triggerBuilder;
  }
}
@Component
export struct UPTooltip {
  @Prop props: UPTooltipProps = new UPTooltipProps();
  aboutToAppear(): void {
    const mode: string = upString(this.props.triggerMode, 'longpress').toLowerCase();
    if (mode !== 'longpress' && mode !== 'click') {
      new UPCompatibilityDiagnostics().report('UPTooltip', 'triggerMode', this.props.triggerMode, 'unsupported trigger falls back to longpress');
    }
  }
  private visible(): boolean {
    return this.props.modelValue !== null && this.props.modelValue !== undefined ?
      upBoolean(this.props.modelValue, false) : this.props.show;
  }
  private copyText(): string {
    const fallback: string = upString(this.props.text, '');
    return upString(this.props.copyText, fallback);
  }
  /** 上游 open / close 在显隐切换时分派。/ Upstream open and close on visibility toggle. */
  private toggle(show: boolean): void {
    this.props.onShowChange?.(show);
    if (show) {
      this.props.onOpen?.();
      return;
    }
    this.props.onClose?.();
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  @Builder
  private triggerRegion() {
    UPSlotRegion({ contentBuilder: this.props.triggerBuilder })
  }

  build() {
    Stack() {
      Column() {
        if (this.props.triggerBuilder !== undefined) {
          this.triggerRegion()
        } else {
          Text(upString(this.props.text, '')).fontSize(UPUnit.parse(this.props.size, 375, 14)).fontColor(this.props.color)
            .backgroundColor(UPColor.parse(this.props.bgColor, undefined, 'transparent'))
        }
      }
      .onClick((): void => { if (upString(this.props.triggerMode, 'longpress').toLowerCase() === 'click') this.toggle(!this.visible()); })
      .gesture(LongPressGesture().onAction((): void => this.toggle(!this.visible())))
      if (this.visible()) {
        Column({ space: 8 }) {
          if (this.props.contentBuilder !== undefined) {
            this.slotRegion()
          } else {
            Text(upString(this.props.text, '')).fontSize(13).fontColor('#ffffff')
          }
          Row({ space: 12 }) {
            if (upBoolean(this.props.showCopy, true)) {
              Text('复制').fontSize(12).fontColor('#ffffff').onClick((): void => this.props.onCopy?.({ text: this.copyText() }))
            }
            ForEach(this.props.buttons, (label: UPRawValue, index: number) => {
              Text(label === null || label === undefined ? '' : String(label)).fontSize(12).fontColor('#ffffff')
                .onClick((): void => {
                  this.props.onButtonClick?.({ label, index });
                  this.props.onClick?.({ label, index });
                })
            })
          }
        }.padding(10).backgroundColor(UPColor.parse(this.props.popupBgColor, undefined, UPColor.neutral('main', '#303133'))).borderRadius(6)
      }
      if (this.visible() && upBoolean(this.props.overlay, true)) {
        Column().width('100%').height('100%').backgroundColor('#00000000')
          .onClick((): void => this.toggle(false))
      }
    }.zIndex(upNumber(this.props.zIndex, 10071))
    .alignContent(upString(this.props.direction, 'top').toLowerCase() === 'bottom' ? Alignment.Bottom : Alignment.Top)
  }
}
