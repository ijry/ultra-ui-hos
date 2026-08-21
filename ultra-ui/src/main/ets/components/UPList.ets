import { UPRawValue, UPStyleInput, upBoolean, upNumber } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPListContext } from '../internal/UPListContexts';

export interface UPListScrollEvent {
  offset: number;
  viewportSize: number;
  contentSize: number;
}

export interface UPListOptions {
  showScrollbar?: UPRawValue;
  lowerThreshold?: UPRawValue;
  upperThreshold?: UPRawValue;
  scrollTop?: UPRawValue;
  offsetAccuracy?: UPRawValue;
  enableFlex?: UPRawValue;
  pagingEnabled?: UPRawValue;
  scrollable?: UPRawValue;
  scrollIntoView?: UPRawValue;
  scrollWithAnimation?: UPRawValue;
  enableBackToTop?: UPRawValue;
  height?: UPRawValue;
  width?: UPRawValue;
  preLoadScreen?: UPRawValue;
  refresherEnabled?: UPRawValue;
  refresherThreshold?: UPRawValue;
  refresherDefaultStyle?: UPRawValue;
  refresherBackground?: UPRawValue;
  refresherTriggered?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onScroll?: (event: UPListScrollEvent) => void;
  onScrollToLower?: () => void;
  onScrollToUpper?: () => void;
  onRefresherRefresh?: () => void;
  onRefresherTriggeredChange?: (triggered: boolean) => void;
  contentBuilder?: () => void;
}

export class UPListProps {
  showScrollbar: UPRawValue = false;
  lowerThreshold: UPRawValue = 50;
  upperThreshold: UPRawValue = 0;
  scrollTop: UPRawValue = 0;
  offsetAccuracy: UPRawValue = 10;
  enableFlex: UPRawValue = false;
  pagingEnabled: UPRawValue = false;
  scrollable: UPRawValue = true;
  scrollIntoView: UPRawValue = '';
  scrollWithAnimation: UPRawValue = false;
  enableBackToTop: UPRawValue = false;
  height: UPRawValue = 0;
  width: UPRawValue = 0;
  preLoadScreen: UPRawValue = 1;
  refresherEnabled: UPRawValue = false;
  refresherThreshold: UPRawValue = 45;
  refresherDefaultStyle: UPRawValue = 'black';
  refresherBackground: UPRawValue = '#FFF';
  refresherTriggered: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onScroll?: (event: UPListScrollEvent) => void;
  onScrollToLower?: () => void;
  onScrollToUpper?: () => void;
  onRefresherRefresh?: () => void;
  onRefresherTriggeredChange?: (triggered: boolean) => void;
  contentBuilder?: () => void;

  constructor(options?: UPListOptions) {
    if (options === undefined) return;
    this.showScrollbar = options.showScrollbar ?? this.showScrollbar;
    this.lowerThreshold = options.lowerThreshold ?? this.lowerThreshold;
    this.upperThreshold = options.upperThreshold ?? this.upperThreshold;
    this.scrollTop = options.scrollTop ?? this.scrollTop;
    this.offsetAccuracy = options.offsetAccuracy ?? this.offsetAccuracy;
    this.enableFlex = options.enableFlex ?? this.enableFlex;
    this.pagingEnabled = options.pagingEnabled ?? this.pagingEnabled;
    this.scrollable = options.scrollable ?? this.scrollable;
    this.scrollIntoView = options.scrollIntoView ?? this.scrollIntoView;
    this.scrollWithAnimation = options.scrollWithAnimation ?? this.scrollWithAnimation;
    this.enableBackToTop = options.enableBackToTop ?? this.enableBackToTop;
    this.height = options.height ?? this.height;
    this.width = options.width ?? this.width;
    this.preLoadScreen = options.preLoadScreen ?? this.preLoadScreen;
    this.refresherEnabled = options.refresherEnabled ?? this.refresherEnabled;
    this.refresherThreshold = options.refresherThreshold ?? this.refresherThreshold;
    this.refresherDefaultStyle = options.refresherDefaultStyle ?? this.refresherDefaultStyle;
    this.refresherBackground = options.refresherBackground ?? this.refresherBackground;
    this.refresherTriggered = options.refresherTriggered ?? this.refresherTriggered;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onScroll = options.onScroll;
    this.onScrollToLower = options.onScrollToLower;
    this.onScrollToUpper = options.onScrollToUpper;
    this.onRefresherRefresh = options.onRefresherRefresh;
    this.onRefresherTriggeredChange = options.onRefresherTriggeredChange;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPList {
  @Prop @Watch('refreshContext') props: UPListProps = new UPListProps();
  @Provide('UPListContext') listContext: UPListContext = new UPListContext();
  private scroller: Scroller = new Scroller();
  private lastOffset: number = -1;
  private lastUpperState: boolean = false;
  private lastLowerState: boolean = false;
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void {
    this.refreshContext();
    this.reportCompatibility();
  }

  private refreshContext(): void {
    this.listContext = new UPListContext();
    this.listContext.beginComposition((index: number): void => {
      this.scroller.scrollToIndex(index, upBoolean(this.props.scrollWithAnimation, false));
    }, this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS);
  }

  private reportCompatibility(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (upBoolean(this.props.pagingEnabled, false)) diagnostics.report('UPList', 'pagingEnabled', this.props.pagingEnabled, 'native paging is a no-op compatibility field');
    if (upBoolean(this.props.enableBackToTop, false)) diagnostics.report('UPList', 'enableBackToTop', this.props.enableBackToTop, 'native back-to-top gesture is a no-op compatibility field');
    if (upNumber(this.props.preLoadScreen, 1) !== 1) diagnostics.report('UPList', 'preLoadScreen', this.props.preLoadScreen, 'native pre-render screen count is a no-op compatibility field');
    if (upBoolean(this.props.refresherEnabled, false)) diagnostics.report('UPList', 'refresherEnabled', this.props.refresherEnabled, 'native refresher visuals are approximated by reach-start requests');
  }

  private mounted(): void {
    const top: number = Math.max(0, upNumber(this.props.scrollTop, 0));
    if (top > 0) {
      this.scroller.scrollTo({ xOffset: 0, yOffset: top, animation: upBoolean(this.props.scrollWithAnimation, false) });
    }
    this.listContext.requestScrollIntoView(this.props.scrollIntoView);
  }

  private handleScroll(offset: number): void {
    const safeOffset: number = Math.max(0, offset);
    const accuracy: number = Math.max(0, upNumber(this.props.offsetAccuracy, 10));
    if (this.lastOffset >= 0 && Math.abs(safeOffset - this.lastOffset) < accuracy) return;
    this.lastOffset = safeOffset;
    const contentSize: number = 0;
    const viewportSize: number = Math.max(0, UPUnit.parse(this.props.height, 375, UPStyle.parse(this.props.customStyle).height ?? 0));
    this.props.onScroll?.({ offset: safeOffset, viewportSize, contentSize });
    const upper: boolean = safeOffset <= Math.max(0, upNumber(this.props.upperThreshold, 0));
    const lower: boolean = false;
    if (upper && !this.lastUpperState) this.props.onScrollToUpper?.();
    if (lower && !this.lastLowerState) this.props.onScrollToLower?.();
    this.lastUpperState = upper;
    this.lastLowerState = lower;
  }

  private requestRefresh(): void {
    if (!upBoolean(this.props.refresherEnabled, false)) return;
    this.props.onRefresherRefresh?.();
    this.props.onRefresherTriggeredChange?.(true);
  }

  build() {
    List({ scroller: this.scroller }) {
      this.contentBuilder()
    }
    .width(UPUnit.parse(this.props.width, 375, UPStyle.parse(this.props.customStyle).width ?? 0) || '100%')
    .height(UPUnit.parse(this.props.height, 375, UPStyle.parse(this.props.customStyle).height ?? 0) || '100%')
    .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
    .borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 0)
    .scrollBar(upBoolean(this.props.showScrollbar, false) ? BarState.On : BarState.Off)
    .enableScrollInteraction(upBoolean(this.props.scrollable, true))
    .onAppear((): void => { this.mounted(); })
    .onDidScroll((scrollOffset: number, _scrollState: ScrollState): void => { this.handleScroll(scrollOffset); })
    .onReachStart((): void => {
      this.handleScroll(0);
      this.requestRefresh();
    })
    .onReachEnd((): void => {
      if (!this.lastLowerState) this.props.onScrollToLower?.();
      this.lastLowerState = true;
    })
  }
}
