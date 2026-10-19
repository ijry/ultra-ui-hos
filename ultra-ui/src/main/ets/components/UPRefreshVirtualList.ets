import { UPRawValue, UPStyleInput, upBoolean, upString, upValueKey } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import {
  UPVirtualList,
  UPVirtualListItem,
  UPVirtualListItemSlot,
  UPVirtualListProps,
  UPVirtualListScrollEvent
} from './UPVirtualList';
import { UPPullRefresh, UPPullRefreshProps } from './UPPullRefresh';
import {
  UPRefreshVirtualListCommand,
  UPRefreshVirtualListController
} from '../controllers/UPRefreshVirtualListController';
import { UPColor } from '../core/UPColor';

export interface UPRefreshVirtualListOptions {
  listData?: Array<UPVirtualListItem>;
  itemHeight?: UPRawValue;
  height?: UPRawValue;
  buffer?: UPRawValue;
  keyField?: UPRawValue;
  showScrollbar?: UPRawValue;
  customStyle?: UPStyleInput;
  controller?: UPRefreshVirtualListController;
  diagnostics?: UPCompatibilityDiagnostics;
  onRefresh?: () => void;
  onScroll?: (scrollTop: number) => void;
  onRefreshingChange?: (refreshing: boolean) => void;
}

export class UPRefreshVirtualListProps {
  listData: Array<UPVirtualListItem> = [];
  itemHeight: UPRawValue = 50;
  height: UPRawValue = '100%';
  buffer: UPRawValue = 4;
  keyField: UPRawValue = 'id';
  showScrollbar: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  controller?: UPRefreshVirtualListController;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onRefresh?: () => void;
  onScroll?: (scrollTop: number) => void;
  onRefreshingChange?: (refreshing: boolean) => void;

  constructor(options?: UPRefreshVirtualListOptions) {
    if (options === undefined) {
      return;
    }
    this.listData = options.listData ?? this.listData;
    this.itemHeight = options.itemHeight ?? this.itemHeight;
    this.height = options.height ?? this.height;
    this.buffer = options.buffer ?? this.buffer;
    this.keyField = options.keyField ?? this.keyField;
    this.showScrollbar = options.showScrollbar ?? this.showScrollbar;
    this.customStyle = options.customStyle;
    this.controller = options.controller;
    this.diagnostics = options.diagnostics;
    this.onRefresh = options.onRefresh;
    this.onScroll = options.onScroll;
    this.onRefreshingChange = options.onRefreshingChange;
  }
}

@Component
export struct UPRefreshVirtualList {
  @Prop props: UPRefreshVirtualListProps = new UPRefreshVirtualListProps();
  @State private refreshing: boolean = false;
  @State private scrollTop: number = 0;

  @Builder
  private defaultItem(slot: UPVirtualListItemSlot) {
    Row({ space: 8 }) {
      Text(upValueKey(slot.item.label ?? slot.item.value ?? slot.item.id ?? slot.index))
        .fontSize(15)
        .fontColor(upBoolean(slot.item.disabled, false) ? '#c0c4cc' : '#303133')
        .layoutWeight(1)
      Text('#' + String(slot.index + 1)).fontSize(12).fontColor(UPColor.adaptive('#c0c4cc', 'light-color'))
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 0.5 }, color: '#f2f2f2' })
  }

  @BuilderParam itemBuilder: (slot: UPVirtualListItemSlot) => void = this.defaultItem;

  aboutToAppear(): void {
    this.props.controller?.mount((command: UPRefreshVirtualListCommand): void => this.execute(command));
  }

  aboutToDisappear(): void {
    this.props.controller?.unmount();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private execute(command: UPRefreshVirtualListCommand): void {
    if (command.action === 'finishRefresh') {
      this.finishRefresh();
      return;
    }
    if (command.action === 'scrollTo') {
      this.scrollTo(command.scrollTop);
      return;
    }
    this.diagnostics().report('UPRefreshVirtualList', 'controller', command.action, 'unknown controller command ignored');
  }

  /** Upstream finishRefresh(): clears the refreshing flag driven by the parent page. */
  finishRefresh(): void {
    if (!this.refreshing) {
      return;
    }
    this.refreshing = false;
    this.props.onRefreshingChange?.(false);
  }

  /** Upstream scrollTo(top): moves the virtual window through the scrollTop binding. */
  scrollTo(top: number): void {
    const target: number = Number.isFinite(top) ? Math.max(0, top) : 0;
    if (target === this.scrollTop) {
      return;
    }
    this.scrollTop = target;
  }

  /** Upstream scrollToTop(). */
  scrollToTop(): void {
    this.scrollTo(0);
  }

  private handleRefresh(): void {
    this.refreshing = true;
    this.props.onRefreshingChange?.(true);
    this.props.onRefresh?.();
  }

  private handleScroll(event: UPVirtualListScrollEvent): void {
    this.scrollTop = event.scrollTop;
    this.props.onScroll?.(event.scrollTop);
  }

  private listHeight(): string | number {
    const raw: UPRawValue = this.props.height;
    if (typeof raw === 'string' && raw.trim().endsWith('%')) {
      return raw.trim();
    }
    const parsed: number = UPUnit.parse(raw, 375, 0);
    return parsed > 0 ? parsed : '100%';
  }

  @Builder
  private listRegion() {
    UPVirtualList({
      props: new UPVirtualListProps({
        listData: this.props.listData,
        itemHeight: this.props.itemHeight,
        height: this.props.height,
        buffer: this.props.buffer,
        keyField: upString(this.props.keyField, 'id'),
        scrollTop: this.scrollTop,
        showScrollbar: this.props.showScrollbar,
        diagnostics: this.props.diagnostics,
        onScroll: (event: UPVirtualListScrollEvent): void => this.handleScroll(event)
      }),
      itemBuilder: this.itemBuilder
    })
  }

  build() {
    Column() {
      UPPullRefresh({
        props: new UPPullRefreshProps({
          refreshing: this.refreshing,
          threshold: 50,
          useScrollView: false,
          scrollTop: this.scrollTop,
          diagnostics: this.props.diagnostics,
          onRefresh: (): void => this.handleRefresh()
        }),
        contentBuilder: this.listRegion
      })
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(UPStyle.parse(this.props.customStyle).height ?? this.listHeight())
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
    .clip(true)
  }
}
