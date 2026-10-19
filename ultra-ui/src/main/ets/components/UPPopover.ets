import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics } from '../core/UPDiagnostics';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export type UPPopoverPlacement = 'top' | 'bottom' | 'left' | 'right';
export interface UPPopoverSelectEvent { show: boolean; }
export interface UPPopoverOptions {
  text?: UPRawValue; color?: UPRawValue; bgColor?: UPRawValue; popupBgColor?: UPRawValue;
  placement?: UPRawValue; triggerMode?: UPRawValue; show?: boolean; modelValue?: boolean;
  value?: boolean; zIndex?: UPRawValue; customStyle?: UPStyleInput;
  onShowChange?: (show: boolean) => void; onSelect?: (event: UPPopoverSelectEvent) => void;
  onClick?: () => void; onOpen?: () => void; onClose?: () => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
}
export class UPPopoverProps {
  text: UPRawValue = ''; color: string = '#333'; bgColor: string = '#f7f7f7';
  popupBgColor: string = '#f7f7f7'; placement: UPRawValue = 'top'; triggerMode: UPRawValue = 'click';
  show: boolean = false; modelValue: UPRawValue = undefined; value: boolean = false;
  zIndex: UPRawValue = 10070; customStyle: UPStyleInput = undefined;
  onShowChange?: (show: boolean) => void; onSelect?: (event: UPPopoverSelectEvent) => void;
  onClick?: () => void; onOpen?: () => void; onClose?: () => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
  constructor(options?: UPPopoverOptions) {
    if (options === undefined) return;
    this.text = options.text ?? this.text; this.color = upString(options.color, this.color);
    this.bgColor = upString(options.bgColor, this.bgColor); this.popupBgColor = upString(options.popupBgColor, this.popupBgColor);
    this.placement = options.placement ?? this.placement; this.triggerMode = options.triggerMode ?? this.triggerMode;
    this.show = options.show ?? this.show; this.modelValue = options.modelValue ?? this.modelValue;
    this.value = options.value ?? this.value; this.zIndex = options.zIndex ?? this.zIndex;
    this.customStyle = options.customStyle; this.onShowChange = options.onShowChange;
    this.onSelect = options.onSelect; this.onClick = options.onClick;
    this.onOpen = options.onOpen; this.onClose = options.onClose; this.contentBuilder = options.contentBuilder;
    this.triggerBuilder = options.triggerBuilder;
  }
}
@Component
export struct UPPopover {
  @Prop props: UPPopoverProps = new UPPopoverProps();
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  @Builder private emptyContent() { Row().width(0).height(0) }
  aboutToAppear(): void {
    const placement: string = upString(this.props.placement, 'top').toLowerCase();
    if (placement !== 'top' && placement !== 'bottom' && placement !== 'left' && placement !== 'right') {
      new UPCompatibilityDiagnostics().report('UPPopover', 'placement', this.props.placement, 'unsupported placement falls back to top');
    }
    if (upString(this.props.triggerMode, 'click').toLowerCase() !== 'click') {
      new UPCompatibilityDiagnostics().report('UPPopover', 'triggerMode', this.props.triggerMode, 'unsupported trigger falls back to click');
    }
  }
  private visible(): boolean {
    const controlled: boolean = this.props.modelValue !== null && this.props.modelValue !== undefined ?
      upBoolean(this.props.modelValue, false) : this.props.show || this.props.value;
    return controlled;
  }
  private placement(): UPPopoverPlacement {
    const value: string = upString(this.props.placement, 'top').toLowerCase();
    return value === 'bottom' || value === 'left' || value === 'right' ? value as UPPopoverPlacement : 'top';
  }
  /** 上游 click / open / close 三个事件在切换时分派。/ Upstream click, open and close split. */
  private toggle(): void {
    const show: boolean = !this.visible();
    this.props.onClick?.();
    this.props.onShowChange?.(show); this.props.onSelect?.({ show });
    if (show) {
      this.props.onOpen?.();
      return;
    }
    this.props.onClose?.();
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
        }
        this.contentBuilder()
      }.onClick((): void => this.toggle())
      if (this.visible()) {
        Row() {
          Text(upString(this.props.text, '')).fontSize(13).fontColor(this.props.color)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        }.backgroundColor(UPColor.parse(this.props.popupBgColor, undefined, this.props.bgColor))
        .borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 6)
        .constraintSize({ minWidth: 64 }).justifyContent(FlexAlign.Center)
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? 'auto')
    .alignContent(this.placement() === 'bottom' ? Alignment.Bottom : this.placement() === 'left' ? Alignment.Start :
      this.placement() === 'right' ? Alignment.End : Alignment.Top)
    .zIndex(upNumber(this.props.zIndex, 10070))
  }
}
