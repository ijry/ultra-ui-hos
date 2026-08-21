import { UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPIndexListContext } from '../internal/UPListContexts';
import { UPIndexAnchor, UPIndexAnchorProps } from './UPIndexAnchor';

export interface UPIndexItemOptions {
  index?: UPRawValue;
  customStyle?: UPStyleInput;
  headerBuilder?: () => void;
  contentBuilder?: () => void;
}

export class UPIndexItemProps {
  index: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  headerBuilder?: () => void;
  contentBuilder?: () => void;

  constructor(options?: UPIndexItemOptions) {
    if (options === undefined) return;
    this.index = options.index ?? this.index;
    this.customStyle = options.customStyle;
    this.headerBuilder = options.headerBuilder;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPIndexItem {
  @Prop props: UPIndexItemProps = new UPIndexItemProps();
  @Consume('UPIndexListContext') indexContext: UPIndexListContext = new UPIndexListContext();
  private itemPosition: number = 0;
  @Builder private defaultHeader() { UPIndexAnchor({ props: new UPIndexAnchorProps({ text: this.props.index }) }) }
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam headerBuilder: () => void = this.defaultHeader;
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void {
    this.itemPosition = this.indexContext.itemIndex(this.props.index);
  }

  @Builder
  private resolvedHeaderBuilder() {
    this.headerBuilder()
  }

  @Builder
  private content() {
    Column() {
      this.contentBuilder()
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? 'transparent')
  }

  build() {
    if (this.indexContext.grouped) {
      ListItemGroup({ header: this.resolvedHeaderBuilder }) {
        ListItem() {
          Column() {
            this.contentBuilder()
          }
          .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
          .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
        }
      }
    } else {
      Column() {
        this.resolvedHeaderBuilder()
        this.content()
      }
      .width('100%')
    }
  }
}
