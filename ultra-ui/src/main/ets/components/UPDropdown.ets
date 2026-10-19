import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPDropdownContext } from '../internal/UPInteractionContexts';

export type UPDropdownDirection = 'down' | 'up';
export interface UPDropdownOptions {
  activeColor?: UPRawValue; inactiveColor?: UPRawValue; closeOnClickMask?: UPRawValue;
  closeOnClickSelf?: UPRawValue; duration?: UPRawValue; height?: UPRawValue;
  borderBottom?: UPRawValue; titleSize?: UPRawValue; borderRadius?: UPRawValue;
  menuIcon?: UPRawValue; menuIconSize?: UPRawValue; customStyle?: UPStyleInput;
  closeOnClickOverlay?: UPRawValue; direction?: UPRawValue; menu?: UPRawValue;
  bgColor?: UPRawValue; openIndex?: UPRawValue; onOpenChange?: (index: number) => void;
  onOpen?: (index: number) => void; onClose?: () => void; contentBuilder?: UPBuilder;
}
export class UPDropdownProps {
  activeColor: UPRawValue = '#2979ff'; inactiveColor: UPRawValue = '#606266';
  closeOnClickMask: UPRawValue = true; closeOnClickSelf: UPRawValue = true;
  duration: UPRawValue = 300; height: UPRawValue = 44; borderBottom: UPRawValue = true;
  titleSize: UPRawValue = 14; borderRadius: UPRawValue = 0; menuIcon: UPRawValue = '⌄';
  menuIconSize: UPRawValue = 16; customStyle: UPStyleInput = undefined;
  closeOnClickOverlay: UPRawValue = undefined; direction: UPRawValue = 'down';
  menu: UPRawValue = true; bgColor: UPRawValue = '#ffffff'; openIndex: UPRawValue = -1;
  onOpenChange?: (index: number) => void; onOpen?: (index: number) => void;
  onClose?: () => void; contentBuilder?: UPBuilder;
  constructor(options?: UPDropdownOptions) {
    if (options === undefined) return;
    this.activeColor = options.activeColor ?? this.activeColor; this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.closeOnClickMask = options.closeOnClickMask ?? this.closeOnClickMask; this.closeOnClickSelf = options.closeOnClickSelf ?? this.closeOnClickSelf;
    this.duration = options.duration ?? this.duration; this.height = options.height ?? this.height;
    this.borderBottom = options.borderBottom ?? this.borderBottom; this.titleSize = options.titleSize ?? this.titleSize;
    this.borderRadius = options.borderRadius ?? this.borderRadius; this.menuIcon = options.menuIcon ?? this.menuIcon;
    this.menuIconSize = options.menuIconSize ?? this.menuIconSize; this.customStyle = options.customStyle;
    this.closeOnClickOverlay = options.closeOnClickOverlay ?? this.closeOnClickOverlay; this.direction = options.direction ?? this.direction;
    this.menu = options.menu ?? this.menu; this.bgColor = options.bgColor ?? this.bgColor; this.openIndex = options.openIndex ?? this.openIndex;
    this.onOpenChange = options.onOpenChange; this.onOpen = options.onOpen; this.onClose = options.onClose; this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPDropdown {
  @Prop @Watch('refreshContext') props: UPDropdownProps = new UPDropdownProps();
  @Provide('UPDropdownContext') dropdownContext: UPDropdownContext = new UPDropdownContext();
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;

  aboutToAppear(): void { this.refreshContext(); }
  private currentIndex(): number { return upNumber(this.props.openIndex, -1); }
  refreshContext(): void {
    this.dropdownContext = new UPDropdownContext();
    this.dropdownContext.beginComposition(this.currentIndex(), this.props.onOpenChange, this.props.onOpen, this.props.onClose);
  }
  private isOpen(): boolean { return this.dropdownContext.openIndex() >= 0; }
  private clickMask(): void {
    const enabled: boolean = this.props.closeOnClickOverlay !== null && this.props.closeOnClickOverlay !== undefined
      ? upBoolean(this.props.closeOnClickOverlay, true) : upBoolean(this.props.closeOnClickMask, true);
    if (enabled) this.dropdownContext.close();
  }
  private dropdownBackground(): string { return UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color')); }
  private radius(): number { return UPStyle.parse(this.props.customStyle).borderRadius ?? Math.max(0, upNumber(this.props.borderRadius, 0)); }

  @Builder private menuLayer() {
    if (this.isOpen()) {
      Column().width('100%').height(260).backgroundColor('#000000').opacity(0.04).onClick(() => this.clickMask())
    }
    Column() { this.contentBuilder() }
      .width('100%').backgroundColor(this.dropdownBackground()).borderRadius(this.radius())
  }

  build() {
    Stack() { this.menuLayer() }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
