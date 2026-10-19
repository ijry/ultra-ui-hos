import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPTableStyleContext } from '../internal/UPTableContexts';

export interface UPTrOptions {
  bgColor?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

/** Table row container, source-compatible with uview-plus `u-tr`. */
export class UPTrProps {
  bgColor: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPTrOptions) {
    if (options === undefined) return;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPTr {
  @Prop props: UPTrProps = new UPTrProps();
  @Consume('UPTableStyleContext') tableContext: UPTableStyleContext = new UPTableStyleContext();
  private visualIndex: number = 0;
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void {
    this.visualIndex = this.tableContext.rowIndex();
  }

  private rowBackground(): string {
    const style: UPStyleInput = this.props.customStyle;
    const parsed: string | undefined = UPStyle.parse(style).backgroundColor ?? UPStyle.parse(style).background;
    if (parsed !== undefined) return parsed;
    return typeof this.props.bgColor === 'string' && this.props.bgColor.trim().length > 0 ? this.props.bgColor.trim() : 'transparent';
  }

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
      this.contentBuilder()
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .backgroundColor(this.rowBackground())
  }
}
