import { UPBuilder, UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPSwipeActionContext } from '../internal/UPNavigationMoreContexts';

export interface UPSwipeActionOptions {
  autoClose?: boolean; opendItem?: boolean; customStyle?: UPStyleInput;
  onOpenChange?: (name: UPRawValue) => void; onClose?: () => void;
  onOpendItemUpdate?: (opened: boolean) => void; contentBuilder?: UPBuilder;
}
export class UPSwipeActionProps {
  autoClose: boolean = true; opendItem: boolean = false; customStyle: UPStyleInput = undefined;
  onOpenChange?: (name: UPRawValue) => void; onClose?: () => void;
  onOpendItemUpdate?: (opened: boolean) => void; contentBuilder?: UPBuilder;
  constructor(options?: UPSwipeActionOptions) {
    if (options === undefined) return;
    this.autoClose = options.autoClose ?? this.autoClose; this.opendItem = options.opendItem ?? this.opendItem;
    this.customStyle = options.customStyle; this.onOpenChange = options.onOpenChange;
    this.onClose = options.onClose; this.onOpendItemUpdate = options.onOpendItemUpdate;
    this.contentBuilder = options.contentBuilder;
  }
}
@Component
export struct UPSwipeAction {
  @Prop @Watch('refreshContext') props: UPSwipeActionProps = new UPSwipeActionProps();
  @Provide('UPSwipeActionContext') swipeContext: UPSwipeActionContext = new UPSwipeActionContext();
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  aboutToAppear(): void { this.refreshContext(); }
  refreshContext(): void {
    this.swipeContext = new UPSwipeActionContext();
    this.swipeContext.beginComposition(this.props.opendItem ? 'first' : '', this.props.autoClose,
      (name: UPRawValue): void => {
        this.props.onOpenChange?.(name);
        /** 上游 `opendItem:update` 表示当前是否有展开项。/ Upstream opendItem:update flags an open item. */
        this.props.onOpendItemUpdate?.(true);
      },
      (): void => {
        this.props.onClose?.();
        this.props.onOpendItemUpdate?.(false);
      });
  }
  build() {
    Column() { this.contentBuilder() }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
