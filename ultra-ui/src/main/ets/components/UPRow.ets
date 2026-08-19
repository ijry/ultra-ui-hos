import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { upLayoutEnum, UPRowLayoutContext } from '../internal/UPLayoutContexts';

export interface UPRowOptions {
  gutter?: UPRawValue;
  justify?: UPRawValue;
  align?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  onClick?: () => void;
}

/** 12-unit wrap-capable row container, source-compatible with uview-plus `u-row`. */
export class UPRowProps {
  gutter: UPRawValue = 0;
  justify: UPRawValue = 'start';
  align: UPRawValue = 'center';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  onClick?: () => void;

  constructor(options?: UPRowOptions) {
    if (options === undefined) {
      return;
    }
    this.gutter = options.gutter ?? this.gutter;
    this.justify = options.justify ?? this.justify;
    this.align = options.align ?? this.align;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.onClick = options.onClick;
  }
}

@Component
export struct UPRow {
  @Prop @Watch('onPropsChange') props: UPRowProps = new UPRowProps();
  @Provide('UPRowLayoutContext') rowContext: UPRowLayoutContext = new UPRowLayoutContext(0);

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  aboutToAppear(): void {
    this.refreshContext();
  }

  onPropsChange(): void {
    this.refreshContext();
  }

  private refreshContext(): void {
    this.rowContext = new UPRowLayoutContext(UPUnit.parse(this.props.gutter, 375, 0));
  }

  private rowJustify(): FlexAlign {
    const justify: string = upLayoutEnum(this.props.justify, ['start', 'center', 'end', 'space-between', 'space-around', 'space-evenly'], 'start');
    switch (justify) {
      case 'center': return FlexAlign.Center;
      case 'end': return FlexAlign.End;
      case 'space-between': return FlexAlign.SpaceBetween;
      case 'space-around': return FlexAlign.SpaceAround;
      case 'space-evenly': return FlexAlign.SpaceEvenly;
      default: return FlexAlign.Start;
    }
  }

  private rowAlign(): ItemAlign {
    const align: string = upLayoutEnum(this.props.align, ['start', 'center', 'end', 'stretch'], 'center');
    switch (align) {
      case 'start': return ItemAlign.Start;
      case 'end': return ItemAlign.End;
      case 'stretch': return ItemAlign.Stretch;
      default: return ItemAlign.Center;
    }
  }

  private rowPadding(): Padding {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.padding !== undefined) {
      return {
        top: style.padding.top,
        right: style.padding.right,
        bottom: style.padding.bottom,
        left: style.padding.left
      };
    }
    return { top: 0, right: 0, bottom: 0, left: 0 };
  }

  private rowMargin(): Margin {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.margin !== undefined) {
      return {
        top: style.margin.top,
        right: style.margin.right,
        bottom: style.margin.bottom,
        left: style.margin.left
      };
    }
    return { top: 0, right: 0, bottom: 0, left: 0 };
  }

  private rowOpacity(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.opacity ?? 1;
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.Wrap,
      justifyContent: this.rowJustify(),
      alignItems: this.rowAlign()
    }) {
      this.contentBuilder()
    }
    .width('100%')
    .padding(this.rowPadding())
    .margin(this.rowMargin())
    .opacity(this.rowOpacity())
    .onClick(() => {
      if (this.props.onClick !== undefined) {
        this.props.onClick();
      }
    })
  }
}
