import { UPBuilder, UPRawValue, UPStyleInput, upBoolean } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics } from '../core/UPDiagnostics';
import { UPIndexListContext, UPIndexListSelectEvent } from '../internal/UPListContexts';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export { UPIndexListSelectEvent } from '../internal/UPListContexts';

export interface UPIndexListOptions {
  inactiveColor?: UPRawValue;
  activeColor?: UPRawValue;
  indexList?: Array<UPRawValue>;
  current?: UPRawValue;
  sticky?: UPRawValue;
  showSidebar?: UPRawValue;
  customNavHeight?: UPRawValue;
  safeBottomFix?: UPRawValue;
  itemMargin?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onSelect?: (event: UPIndexListSelectEvent) => void;
  onChange?: (event: UPIndexListSelectEvent) => void;
  onCurrentChange?: (value: UPRawValue) => void;
  contentBuilder?: () => void;
  headerBuilder?: UPBuilder;
  footerBuilder?: UPBuilder;
}

export class UPIndexListProps {
  inactiveColor: UPRawValue = '#606266';
  activeColor: UPRawValue = '#5677fc';
  indexList: Array<UPRawValue> = [];
  current: UPRawValue = undefined;
  sticky: UPRawValue = true;
  showSidebar: UPRawValue = true;
  customNavHeight: UPRawValue = 0;
  safeBottomFix: UPRawValue = false;
  itemMargin: UPRawValue = '0rpx';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onSelect?: (event: UPIndexListSelectEvent) => void;
  onChange?: (event: UPIndexListSelectEvent) => void;
  onCurrentChange?: (value: UPRawValue) => void;
  contentBuilder?: () => void;
  headerBuilder?: UPBuilder;
  footerBuilder?: UPBuilder;

  constructor(options?: UPIndexListOptions) {
    if (options === undefined) return;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.indexList = options.indexList ?? this.indexList;
    this.current = options.current ?? this.current;
    this.sticky = options.sticky ?? this.sticky;
    this.showSidebar = options.showSidebar ?? this.showSidebar;
    this.customNavHeight = options.customNavHeight ?? this.customNavHeight;
    this.safeBottomFix = options.safeBottomFix ?? this.safeBottomFix;
    this.itemMargin = options.itemMargin ?? this.itemMargin;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onSelect = options.onSelect;
    this.onChange = options.onChange;
    this.onCurrentChange = options.onCurrentChange;
    this.contentBuilder = options.contentBuilder;
    this.headerBuilder = options.headerBuilder;
    this.footerBuilder = options.footerBuilder;
  }
}

@Component
export struct UPIndexList {
  @Prop @Watch('refreshContext') props: UPIndexListProps = new UPIndexListProps();
  @Provide('UPIndexListContext') indexContext: UPIndexListContext = new UPIndexListContext();
  private scroller: Scroller = new Scroller();
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void { this.refreshContext(); }

  private refreshContext(): void {
    this.indexContext = new UPIndexListContext();
    this.indexContext.beginComposition(this.props.indexList, this.props.current,
      this.props.onSelect, this.props.onChange, this.props.onCurrentChange,
      (index: number): void => { this.scroller.scrollToIndex(index, true); }, this.props.diagnostics);
  }

  private sidebarBottom(): number {
    return upBoolean(this.props.safeBottomFix, false) ? 16 : 0;
  }

  @Builder
  private headerRegion() {
    UPSlotRegion({ contentBuilder: this.props.headerBuilder })
  }

  @Builder
  private footerRegion() {
    UPSlotRegion({ contentBuilder: this.props.footerBuilder })
  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      List({ scroller: this.scroller }) {
        if (this.props.headerBuilder !== undefined) {
          ListItem() {
            this.headerRegion()
          }
        }
        this.contentBuilder()
        if (this.props.footerBuilder !== undefined) {
          ListItem() {
            this.footerRegion()
          }
        }
      }
      .width('100%')
      .height('100%')
      .sticky(upBoolean(this.props.sticky, true) ? StickyStyle.Header : StickyStyle.None)
      .scrollBar(BarState.Off)

      if (upBoolean(this.props.showSidebar, true)) {
        Column() {
          ForEach(this.indexContext.normalizedItems(), (value: UPRawValue, index: number): void => {
            Text(String(value))
              .fontSize(12)
              .fontWeight(this.indexContext.isActive(value) ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(UPColor.parse(this.indexContext.isActive(value) ? this.props.activeColor : this.props.inactiveColor,
                UP_DEFAULT_THEME, this.indexContext.isActive(value) ? '#5677fc' : '#606266'))
              .width(24)
              .height(24)
              .textAlign(TextAlign.Center)
              .margin({ top: UPUnit.parse(this.props.itemMargin, 375, 0) })
              .onClick((): void => { this.indexContext.requestSelect(index); })
          }, (value: UPRawValue): string => String(value))
        }
        .padding({ right: 4, bottom: this.sidebarBottom() })
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(UPStyle.parse(this.props.customStyle).height ?? 360)
    .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
  }
}
