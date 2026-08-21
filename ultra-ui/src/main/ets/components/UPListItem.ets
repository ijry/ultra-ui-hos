import { UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPListContext } from '../internal/UPListContexts';

export interface UPListItemOptions {
  anchor?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: () => void;
}

export class UPListItemProps {
  anchor: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: () => void;

  constructor(options?: UPListItemOptions) {
    if (options === undefined) return;
    this.anchor = options.anchor ?? this.anchor;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPListItem {
  @Prop props: UPListItemProps = new UPListItemProps();
  @Consume('UPListContext') listContext: UPListContext = new UPListContext();
  private index: number = 0;
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void {
    this.index = this.listContext.itemIndex();
    this.listContext.registerAnchor(this.props.anchor, this.index);
  }

  @Builder
  private content() {
    Column() {
      this.contentBuilder()
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? 'transparent')
    .borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 0)
  }

  build() {
    if (this.listContext.grouped) {
      ListItem() {
        this.content()
      }
    } else {
      this.content()
    }
  }
}
