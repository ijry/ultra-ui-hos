import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPSwipeActionContext } from '../internal/UPNavigationMoreContexts';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPSwipeActionOption {
  label?: UPRawValue; value?: UPRawValue; text?: UPRawValue; disabled?: boolean;
  background?: UPRawValue; color?: UPRawValue;
}
export interface UPSwipeActionSelectEvent { name: UPRawValue; option: UPSwipeActionOption; index: number; }
export interface UPSwipeActionItemOptions {
  show?: boolean; closeOnClick?: boolean; name?: UPRawValue; disabled?: boolean; autoClose?: boolean;
  scrolling?: boolean; threshold?: UPRawValue; options?: Array<UPSwipeActionOption>; duration?: UPRawValue;
  customStyle?: UPStyleInput; onSelect?: (event: UPSwipeActionSelectEvent) => void;
  onShowChange?: (show: boolean) => void;
  onClick?: (event: UPSwipeActionSelectEvent) => void; onScrolling?: (scrolling: boolean) => void;
  contentBuilder?: UPBuilder;
  buttonBuilder?: UPBuilder;
}
export class UPSwipeActionItemProps {
  show: boolean = false; closeOnClick: boolean = true; name: UPRawValue = ''; disabled: boolean = false;
  autoClose: boolean = true; scrolling: boolean = false; threshold: UPRawValue = 20;
  options: Array<UPSwipeActionOption> = []; duration: UPRawValue = 300; customStyle: UPStyleInput = undefined;
  onSelect?: (event: UPSwipeActionSelectEvent) => void; onShowChange?: (show: boolean) => void;
  onClick?: (event: UPSwipeActionSelectEvent) => void; onScrolling?: (scrolling: boolean) => void;
  contentBuilder?: UPBuilder;
  buttonBuilder?: UPBuilder;
  constructor(options?: UPSwipeActionItemOptions) {
    if (options === undefined) return;
    this.show = options.show ?? this.show; this.closeOnClick = options.closeOnClick ?? this.closeOnClick;
    this.name = options.name ?? this.name; this.disabled = options.disabled ?? this.disabled;
    this.autoClose = options.autoClose ?? this.autoClose; this.scrolling = options.scrolling ?? this.scrolling;
    this.threshold = options.threshold ?? this.threshold; this.options = options.options ?? this.options;
    this.duration = options.duration ?? this.duration; this.customStyle = options.customStyle;
    this.onSelect = options.onSelect; this.onClick = options.onClick; this.onScrolling = options.onScrolling; this.onShowChange = options.onShowChange; this.contentBuilder = options.contentBuilder;
    this.buttonBuilder = options.buttonBuilder;
  }
}
@Component
export struct UPSwipeActionItem {
  @Prop props: UPSwipeActionItemProps = new UPSwipeActionItemProps();
  @Consume('UPSwipeActionContext') swipeContext: UPSwipeActionContext;
  @State private offsetX: number = 0;
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  private itemName: UPRawValue = '';
  aboutToAppear(): void { this.itemName = this.swipeContext.itemName(this.props.name); }
  private visible(): boolean { return this.props.show || this.swipeContext.isOpen(this.itemName); }
  private threshold(): number { return Math.max(1, upNumber(this.props.threshold, 20)); }
  private close(): void { this.offsetX = 0; this.props.onShowChange?.(false); if (this.props.autoClose) this.swipeContext.closeAll(); }
  /** 上游 click 与本端 onSelect 是同一时机的一对回调。/ Upstream click paired with the local onSelect. */
  private select(option: UPSwipeActionOption, index: number): void {
    if (upBoolean(option.disabled, false)) return;
    const event: UPSwipeActionSelectEvent = { name: this.itemName, option, index };
    this.props.onSelect?.(event);
    this.props.onClick?.(event);
    if (upBoolean(this.props.closeOnClick, true)) this.close();
  }
  /** 上游 scrolling：拖动开始与结束时回传。/ Upstream scrolling toggles while dragging. */
  private setScrolling(scrolling: boolean): void {
    this.props.onScrolling?.(scrolling);
  }
  @Builder
  private buttonRegion() {
    UPSlotRegion({ contentBuilder: this.props.buttonBuilder })
  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      if (this.props.buttonBuilder !== undefined) {
        this.buttonRegion()
      }
      Row({ space: 0 }) {
        ForEach(this.props.options, (option: UPSwipeActionOption, index: number) => {
          Text(upString(option.label ?? option.text ?? option.value, '')).fontSize(14)
            .fontColor(UPColor.parse(option.color, undefined, UPColor.adaptive('#ffffff', 'card-bg-color'))).textAlign(TextAlign.Center)
            .width(72).height('100%')
            .backgroundColor(UPColor.parse(option.background, undefined, UPColor.adaptive('#909399', 'swipe-action-button-bg-color')))
            .onClick((): void => this.select(option, index))
        })
      }
      Row() { this.contentBuilder() }
        .width('100%').backgroundColor(UPStyle.parse(this.props.customStyle).background ?? '#ffffff')
        .translate({ x: this.visible() ? -Math.min(this.props.options.length * 72, 216) : this.offsetX, y: 0 })
        .gesture(PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart((): void => {
            if (upBoolean(this.props.disabled, false) || upBoolean(this.props.scrolling, false)) return;
            this.setScrolling(true);
          })
          .onActionUpdate((event: GestureEvent): void => {
            if (upBoolean(this.props.disabled, false) || upBoolean(this.props.scrolling, false)) return;
            this.offsetX = Math.max(-216, Math.min(0, event.offsetX));
          })
          .onActionEnd((): void => {
            if (upBoolean(this.props.disabled, false) || upBoolean(this.props.scrolling, false)) return;
            this.setScrolling(false);
            if (this.offsetX < -this.threshold()) this.swipeContext.requestOpen(this.itemName); else this.close();
          }))
    }.height(UPStyle.parse(this.props.customStyle).height ?? 56).width('100%')
  }
}
