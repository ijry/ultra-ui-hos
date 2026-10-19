import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPI18n, upWeekText } from '../core/UPI18n';

export interface UPPaginationChangeEvent { currentPage: number; pageCount: number; pageSize: number; total: number; }
export interface UPPaginationState { current: number; pageCount: number; }
export interface UPPaginationOptions {
  currentPage?: UPRawValue; pageSize?: UPRawValue; total?: UPRawValue; prevText?: string; nextText?: string;
  buttonBgColor?: string; buttonBorderColor?: string; pageSizes?: Array<UPRawValue>; layout?: string;
  hideOnSinglePage?: boolean; customStyle?: UPStyleInput; onPageChange?: (event: UPPaginationChangeEvent) => void;
  onCurrentChange?: (currentPage: number) => void; onSizeChange?: (pageSize: number) => void;
}
export class UPPaginationProps {
  currentPage: UPRawValue = 1; pageSize: UPRawValue = 10; total: UPRawValue = 0;
  prevText: string = ''; nextText: string = ''; buttonBgColor: string = '#f5f7fa';
  buttonBorderColor: string = '#dcdfe6'; pageSizes: Array<UPRawValue> = [10, 20, 30, 40, 50];
  layout: string = 'prev, pager, next'; hideOnSinglePage: boolean = false; customStyle: UPStyleInput = undefined;
  onPageChange?: (event: UPPaginationChangeEvent) => void;
  onCurrentChange?: (currentPage: number) => void; onSizeChange?: (pageSize: number) => void;
  constructor(options?: UPPaginationOptions) {
    if (options === undefined) return;
    this.currentPage = options.currentPage ?? this.currentPage; this.pageSize = options.pageSize ?? this.pageSize;
    this.total = options.total ?? this.total; this.prevText = options.prevText ?? this.prevText;
    this.nextText = options.nextText ?? this.nextText; this.buttonBgColor = options.buttonBgColor ?? this.buttonBgColor;
    this.buttonBorderColor = options.buttonBorderColor ?? this.buttonBorderColor; this.pageSizes = options.pageSizes ?? this.pageSizes;
    this.layout = options.layout ?? this.layout; this.hideOnSinglePage = options.hideOnSinglePage ?? this.hideOnSinglePage;
    this.customStyle = options.customStyle; this.onPageChange = options.onPageChange;
    this.onCurrentChange = options.onCurrentChange; this.onSizeChange = options.onSizeChange;
  }
}
@Component
export struct UPPagination {
  @Prop props: UPPaginationProps = new UPPaginationProps();
  private values(): UPPaginationState {
    const size: number = Math.max(1, upNumber(this.props.pageSize, 10));
    const total: number = Math.max(0, upNumber(this.props.total, 0));
    const pageCount: number = Math.max(1, Math.ceil(total / size));
    const state: UPPaginationState = { current: Math.min(pageCount, Math.max(1, upNumber(this.props.currentPage, 1))), pageCount };
    return state;
  }
  private change(page: number): void {
    const state: UPPaginationState = this.values();
    const bounded: number = Math.min(state.pageCount, Math.max(1, page));
    if (bounded === state.current) return;
    this.props.onPageChange?.({ currentPage: bounded, pageCount: state.pageCount,
      pageSize: Math.max(1, upNumber(this.props.pageSize, 10)), total: Math.max(0, upNumber(this.props.total, 0)) });
    /** 上游 current-change 只回传页码。/ Upstream current-change carries the page number only. */
    this.props.onCurrentChange?.(bounded);
  }

  /** 上游 size-change：`pageSizes` 里换页长。/ Upstream size-change picks a new page size. */
  changeSize(pageSize: number): void {
    const bounded: number = Math.max(1, Math.floor(pageSize));
    if (bounded === Math.max(1, upNumber(this.props.pageSize, 10))) return;
    this.props.onSizeChange?.(bounded);
    const total: number = Math.max(0, upNumber(this.props.total, 0));
    this.props.onPageChange?.({ currentPage: 1, pageCount: Math.max(1, Math.ceil(total / bounded)),
      pageSize: bounded, total });
  }
  private pages(): Array<number> {
    const result: Array<number> = [];
    const count: number = this.values().pageCount;
    for (let page = 1; page <= count; page++) result.push(page);
    return result;
  }
  build() {
    Column() {
      if (upBoolean(this.props.hideOnSinglePage, false) && this.values().pageCount <= 1) {
        Row().width(0).height(0)
      } else {
      Row({ space: 6 }) {
        Text(this.props.prevText.length > 0 ? this.props.prevText : UPI18n.t('up.pagination.previous')).fontSize(13).padding(6)
          .onClick((): void => this.change(this.values().current - 1))
        ForEach(this.pages(), (page: number) => {
          Text(String(page)).fontSize(13).padding({ left: 9, right: 9, top: 6, bottom: 6 })
            .fontColor(page === this.values().current ? '#ffffff' : '#606266')
            .backgroundColor(page === this.values().current ? '#2979ff' : this.props.buttonBgColor)
            .borderRadius(4).onClick((): void => this.change(page))
        })
        Text(this.props.nextText.length > 0 ? this.props.nextText : UPI18n.t('up.pagination.next')).fontSize(13).padding(6)
          .onClick((): void => this.change(this.values().current + 1))
        if (this.props.layout.includes('sizes')) {
          ForEach(this.props.pageSizes, (size: UPRawValue) => {
            Text(String(size) + '条').fontSize(12)
              .padding({ left: 7, right: 7, top: 5, bottom: 5 })
              .fontColor(Math.max(1, upNumber(size, 10)) === Math.max(1, upNumber(this.props.pageSize, 10))
                ? '#2979ff' : '#909399')
              .onClick((): void => this.changeSize(Math.max(1, upNumber(size, 10))))
          })
        }
      }.justifyContent(FlexAlign.Center).width(UPStyle.parse(this.props.customStyle).width ?? '100%')
      }
    }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
