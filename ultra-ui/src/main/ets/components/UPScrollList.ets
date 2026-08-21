import { UPRawValue, UPStyleInput, upBoolean } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics } from '../core/UPDiagnostics';
import {
  UPScrollListEdgeEvent,
  UPScrollListScrollEvent
} from '../internal/UPListContexts';

export { UPScrollListEdge, UPScrollListEdgeEvent, UPScrollListScrollEvent } from '../internal/UPListContexts';

export interface UPScrollListOptions {
  indicatorWidth?: UPRawValue;
  indicatorBarWidth?: UPRawValue;
  indicator?: UPRawValue;
  indicatorColor?: UPRawValue;
  indicatorActiveColor?: UPRawValue;
  indicatorStyle?: UPStyleInput;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onLeft?: (event: UPScrollListEdgeEvent) => void;
  onRight?: (event: UPScrollListEdgeEvent) => void;
  onScroll?: (event: UPScrollListScrollEvent) => void;
  contentBuilder?: () => void;
}

export class UPScrollListProps {
  indicatorWidth: UPRawValue = 50;
  indicatorBarWidth: UPRawValue = 20;
  indicator: UPRawValue = true;
  indicatorColor: UPRawValue = '#f2f2f2';
  indicatorActiveColor: UPRawValue = '#3c9cff';
  indicatorStyle: UPStyleInput = undefined;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onLeft?: (event: UPScrollListEdgeEvent) => void;
  onRight?: (event: UPScrollListEdgeEvent) => void;
  onScroll?: (event: UPScrollListScrollEvent) => void;
  contentBuilder?: () => void;

  constructor(options?: UPScrollListOptions) {
    if (options === undefined) return;
    this.indicatorWidth = options.indicatorWidth ?? this.indicatorWidth;
    this.indicatorBarWidth = options.indicatorBarWidth ?? this.indicatorBarWidth;
    this.indicator = options.indicator ?? this.indicator;
    this.indicatorColor = options.indicatorColor ?? this.indicatorColor;
    this.indicatorActiveColor = options.indicatorActiveColor ?? this.indicatorActiveColor;
    this.indicatorStyle = options.indicatorStyle;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onLeft = options.onLeft;
    this.onRight = options.onRight;
    this.onScroll = options.onScroll;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPScrollList {
  @Prop props: UPScrollListProps = new UPScrollListProps();
  private scroller: Scroller = new Scroller();
  @State private barOffset: number = 0;
  private measuredMaxOffset: number = 0;
  private currentEdge: string = '';
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  private trackWidth(): number {
    return Math.max(0, UPUnit.parse(this.props.indicatorWidth, 375, 50));
  }

  private barWidth(): number {
    return Math.min(this.trackWidth(), Math.max(0, UPUnit.parse(this.props.indicatorBarWidth, 375, 20)));
  }

  private updateScroll(): void {
    const offset: number = Math.max(0, this.scroller.currentOffset().xOffset);
    const maxOffset: number = this.measuredMaxOffset;
    const progress: number = maxOffset > 0 ? Math.min(1, Math.max(0, offset / maxOffset)) : 0;
    this.barOffset = progress * Math.max(this.trackWidth() - this.barWidth(), 0);
    this.props.onScroll?.({ offset, maxOffset });
    if (offset <= 0) {
      if (this.currentEdge !== 'left') {
        this.currentEdge = 'left';
        this.props.onLeft?.({ edge: 'left', offset, maxOffset });
      }
    } else if (maxOffset > 0 && offset >= maxOffset) {
      if (this.currentEdge !== 'right') {
        this.currentEdge = 'right';
        this.props.onRight?.({ edge: 'right', offset, maxOffset });
      }
    } else {
      this.currentEdge = '';
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll(this.scroller) {
        this.contentBuilder()
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .enableScrollInteraction(true)
      .onDidScroll((_xOffset: number, _yOffset: number, _scrollState: ScrollState): void => {
        this.updateScroll();
      })
      .onScrollEdge((edge: Edge): void => {
        if (edge === Edge.End) {
          this.measuredMaxOffset = Math.max(this.measuredMaxOffset, this.scroller.currentOffset().xOffset);
        }
        this.updateScroll();
      })

      if (upBoolean(this.props.indicator, true)) {
        Row() {
          Row()
            .width(this.barWidth())
            .height('100%')
            .backgroundColor(UPColor.parse(this.props.indicatorActiveColor, UP_DEFAULT_THEME, '#3c9cff'))
            .borderRadius(2)
            .translate({ x: this.barOffset })
        }
        .width(this.trackWidth())
        .height(4)
        .backgroundColor(UPColor.parse(this.props.indicatorColor, UP_DEFAULT_THEME, '#f2f2f2'))
        .borderRadius(2)
        .margin(UPStyle.parse(this.props.indicatorStyle).margin ?? { bottom: 2 })
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(UPStyle.parse(this.props.customStyle).height ?? 120)
    .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
    .borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 0)
  }
}
