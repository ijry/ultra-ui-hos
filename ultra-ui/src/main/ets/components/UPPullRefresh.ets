import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPLoadingIcon, UPLoadingIconProps } from './UPLoadingIcon';
import { UPLoadmore, UPLoadmoreProps } from './UPLoadmore';
import { UPColor } from '../core/UPColor';

/** Scroll payload forwarded to the host, mirroring upstream @scroll. */
export interface UPPullRefreshScrollEvent {
  scrollTop: number;
  atTop: boolean;
}

export interface UPPullRefreshOptions {
  refreshing?: UPRawValue;
  threshold?: UPRawValue;
  damping?: UPRawValue;
  maxDistance?: UPRawValue;
  showLoadmore?: UPRawValue;
  loadmoreProps?: UPLoadmoreProps;
  useScrollView?: UPRawValue;
  enableBackToTop?: UPRawValue;
  lowerThreshold?: UPRawValue;
  scrollTop?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  pullBuilder?: UPBuilder;
  releaseBuilder?: UPBuilder;
  refreshingBuilder?: UPBuilder;
  onRefresh?: () => void;
  onLoadmore?: () => void;
  onScroll?: (event: UPPullRefreshScrollEvent) => void;
  onStatusChange?: (status: string) => void;
}

export class UPPullRefreshProps {
  refreshing: UPRawValue = false;
  threshold: UPRawValue = 80;
  damping: UPRawValue = 0.4;
  maxDistance: UPRawValue = 120;
  showLoadmore: UPRawValue = false;
  loadmoreProps: UPLoadmoreProps = new UPLoadmoreProps();
  useScrollView: UPRawValue = true;
  enableBackToTop: UPRawValue = false;
  lowerThreshold: UPRawValue = 50;
  scrollTop: UPRawValue = 0;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  pullBuilder?: UPBuilder;
  releaseBuilder?: UPBuilder;
  refreshingBuilder?: UPBuilder;
  onRefresh?: () => void;
  onLoadmore?: () => void;
  onScroll?: (event: UPPullRefreshScrollEvent) => void;
  onStatusChange?: (status: string) => void;

  constructor(options?: UPPullRefreshOptions) {
    if (options === undefined) {
      return;
    }
    this.refreshing = options.refreshing ?? this.refreshing;
    this.threshold = options.threshold ?? this.threshold;
    this.damping = options.damping ?? this.damping;
    this.maxDistance = options.maxDistance ?? this.maxDistance;
    this.showLoadmore = options.showLoadmore ?? this.showLoadmore;
    this.loadmoreProps = options.loadmoreProps ?? this.loadmoreProps;
    this.useScrollView = options.useScrollView ?? this.useScrollView;
    this.enableBackToTop = options.enableBackToTop ?? this.enableBackToTop;
    this.lowerThreshold = options.lowerThreshold ?? this.lowerThreshold;
    this.scrollTop = options.scrollTop ?? this.scrollTop;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.pullBuilder = options.pullBuilder;
    this.releaseBuilder = options.releaseBuilder;
    this.refreshingBuilder = options.refreshingBuilder;
    this.onRefresh = options.onRefresh;
    this.onLoadmore = options.onLoadmore;
    this.onScroll = options.onScroll;
    this.onStatusChange = options.onStatusChange;
  }
}

@Component
struct UPPullRefreshRegion {
  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  build() {
    Column() {
      this.contentBuilder()
    }
    .width('100%')
  }
}

@Component
export struct UPPullRefresh {
  @Prop @Watch('syncRefreshing') props: UPPullRefreshProps = new UPPullRefreshProps();
  @State private refreshStatus: string = 'pull';
  @State private refreshDistance: number = 0;
  @State private contentTranslateY: number = 0;
  @State private isRefreshing: boolean = false;
  private startY: number = 0;
  private currentY: number = 0;
  private touching: boolean = false;
  private scrollOffset: number = 0;
  private appliedScrollTop: number = -1;
  private scroller: Scroller = new Scroller();

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  aboutToAppear(): void {
    if (upBoolean(this.props.refreshing, false)) {
      this.startRefresh();
    }
    if (upBoolean(this.props.enableBackToTop, false)) {
      this.report('enableBackToTop', this.props.enableBackToTop,
        'backToTop requires API 15; the pull-refresh shell keeps manual scrolling only');
    }
    this.applyScrollTop();
  }

  private report(property: string, value: UPRawValue, reason: string): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    diagnostics.report('UPPullRefresh', property, value, reason);
  }

  private thresholdValue(): number {
    return Math.max(1, UPUnit.parse(this.props.threshold, 375, 80));
  }

  private dampingValue(): number {
    const damping: number = upNumber(this.props.damping, 0.4);
    return damping > 0 ? damping : 0.4;
  }

  private maxDistanceValue(): number {
    return Math.max(this.thresholdValue(), UPUnit.parse(this.props.maxDistance, 375, 120));
  }

  private lowerThresholdValue(): number {
    return Math.max(0, UPUnit.parse(this.props.lowerThreshold, 375, 50));
  }

  private statusText(): string {
    if (this.refreshStatus === 'release') {
      return '释放刷新';
    }
    if (this.refreshStatus === 'refreshing') {
      return '正在刷新...';
    }
    return '下拉刷新';
  }

  private statusIcon(): string {
    return this.refreshStatus === 'release' ? 'arrow-upward' : 'arrow-downward';
  }

  private hasPullBuilder(): boolean {
    return this.props.pullBuilder !== undefined;
  }

  private hasReleaseBuilder(): boolean {
    return this.props.releaseBuilder !== undefined;
  }

  private hasRefreshingBuilder(): boolean {
    return this.props.refreshingBuilder !== undefined;
  }

  private showLoadmoreBar(): boolean {
    return upBoolean(this.props.showLoadmore, false);
  }

  private useScroll(): boolean {
    return upBoolean(this.props.useScrollView, true);
  }

  private atTop(): boolean {
    return this.scrollOffset <= 0.5;
  }

  private setStatus(status: string): void {
    if (this.refreshStatus === status) {
      return;
    }
    this.refreshStatus = status;
    this.props.onStatusChange?.(status);
  }

  private startRefresh(): void {
    this.isRefreshing = true;
    this.setStatus('refreshing');
    this.refreshDistance = this.thresholdValue();
    this.contentTranslateY = this.thresholdValue();
  }

  /** Upstream finishRefresh(): leave the refreshing state and spring back. */
  finishRefresh(): void {
    this.isRefreshing = false;
    this.setStatus('pull');
    this.resetRefresh();
  }

  private resetRefresh(): void {
    this.refreshDistance = 0;
    this.contentTranslateY = 0;
  }

  private syncRefreshing(): void {
    const refreshing: boolean = upBoolean(this.props.refreshing, false);
    if (refreshing === this.isRefreshing) {
      this.applyScrollTop();
      return;
    }
    if (refreshing) {
      this.startRefresh();
    } else {
      this.finishRefresh();
    }
    this.applyScrollTop();
  }

  private applyScrollTop(): void {
    const top: number = Math.max(0, UPUnit.parse(this.props.scrollTop, 375, 0));
    if (top === this.appliedScrollTop) {
      return;
    }
    this.appliedScrollTop = top;
    this.scrollOffset = top;
    if (this.useScroll()) {
      this.scroller.scrollTo({ xOffset: 0, yOffset: top });
    }
  }

  private handleTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.onTouchStart(event);
      return;
    }
    if (event.type === TouchType.Move) {
      this.onTouchMove(event);
      return;
    }
    this.onTouchEnd();
  }

  private onTouchStart(event: TouchEvent): void {
    if (this.isRefreshing || event.touches.length === 0) {
      return;
    }
    this.touching = true;
    this.startY = event.touches[0].windowY;
    this.currentY = this.startY;
    this.setStatus('pull');
  }

  private onTouchMove(event: TouchEvent): void {
    if (!this.touching || this.isRefreshing || event.touches.length === 0) {
      return;
    }
    this.currentY = event.touches[0].windowY;
    const diff: number = this.currentY - this.startY;
    if (diff > 0 && this.atTop()) {
      this.refreshDistance = Math.min(diff * this.dampingValue(), this.maxDistanceValue());
      this.contentTranslateY = this.refreshDistance;
      this.setStatus(this.refreshDistance >= this.thresholdValue() ? 'release' : 'pull');
    }
  }

  private onTouchEnd(): void {
    if (!this.touching) {
      return;
    }
    this.touching = false;
    if (this.refreshDistance >= this.thresholdValue() && !this.isRefreshing) {
      this.startRefresh();
      this.props.onRefresh?.();
    } else {
      this.resetRefresh();
    }
  }

  private handleScroll(offset: number): void {
    this.scrollOffset = Math.max(0, offset);
    this.appliedScrollTop = this.scrollOffset;
    this.props.onScroll?.({ scrollTop: this.scrollOffset, atTop: this.atTop() });
  }

  private handleScrollToLower(): void {
    if (this.showLoadmoreBar() && upString(this.props.loadmoreProps.status, 'loadmore') === 'loadmore') {
      this.props.onLoadmore?.();
    }
  }

  @Builder
  private refreshIndicator() {
    Column() {
      if (this.refreshStatus === 'refreshing') {
        UPLoadingIcon({ props: new UPLoadingIconProps({ size: 16, color: 'content' }) })
      } else {
        UPIcon({ props: new UPIconProps({ name: this.statusIcon(), size: '26px', color: '#606266' }) })
      }
      Text(this.statusText()).fontSize(14).fontColor(UPColor.adaptive('#303133', 'main-color')).margin({ top: 4 })
    }
    .width('100%')
    .padding({ bottom: 10 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private refreshArea() {
    Column() {
      if (this.refreshStatus === 'release' && this.hasReleaseBuilder()) {
        UPPullRefreshRegion({ contentBuilder: this.props.releaseBuilder })
      } else if (this.refreshStatus === 'refreshing' && this.hasRefreshingBuilder()) {
        UPPullRefreshRegion({ contentBuilder: this.props.refreshingBuilder })
      } else if (this.refreshStatus === 'pull' && this.hasPullBuilder()) {
        UPPullRefreshRegion({ contentBuilder: this.props.pullBuilder })
      } else {
        this.refreshIndicator()
      }
    }
    .width('100%')
    .height(this.refreshDistance)
    .clip(true)
    .justifyContent(FlexAlign.End)
  }

  @Builder
  private bodyContent() {
    Column() {
      this.contentBuilder()
      if (this.showLoadmoreBar()) {
        UPLoadmore({ props: this.props.loadmoreProps })
      }
    }
    .width('100%')
  }

  build() {
    Column() {
      this.refreshArea()
      Column() {
        if (this.useScroll()) {
          Scroll(this.scroller) {
            this.bodyContent()
          }
          .width('100%')
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .onDidScroll((_xOffset: number, _yOffset: number, _state: ScrollState): void => {
            this.handleScroll(this.scroller.currentOffset().yOffset);
          })
          .onScrollEdge((side: Edge): void => {
            if (side === Edge.Bottom) {
              this.handleScrollToLower();
            }
          })
        } else {
          this.bodyContent()
        }
      }
      .width('100%')
      .layoutWeight(1)
      .translate({ y: this.contentTranslateY })
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(UPStyle.parse(this.props.customStyle).height ?? '100%')
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? 'transparent')
    .clip(true)
    .onTouch((event: TouchEvent): void => this.handleTouch(event))
  }
}
