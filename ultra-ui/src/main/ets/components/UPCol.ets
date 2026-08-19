import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { upLayoutEnum, upLayoutInt, UPRowLayoutContext, UP_GRID_UNITS } from '../internal/UPLayoutContexts';

export interface UPColOptions {
  span?: UPRawValue;
  offset?: UPRawValue;
  justify?: UPRawValue;
  align?: UPRawValue;
  textAlign?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  onClick?: () => void;
}

/** 12-grid column item that can also render safely outside a UPRow. */
export class UPColProps {
  span: UPRawValue = 12;
  offset: UPRawValue = 0;
  justify: UPRawValue = 'start';
  align: UPRawValue = 'stretch';
  textAlign: UPRawValue = 'left';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  onClick?: () => void;

  constructor(options?: UPColOptions) {
    if (options === undefined) {
      return;
    }
    this.span = options.span ?? this.span;
    this.offset = options.offset ?? this.offset;
    this.justify = options.justify ?? this.justify;
    this.align = options.align ?? this.align;
    this.textAlign = options.textAlign ?? this.textAlign;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.onClick = options.onClick;
  }
}

@Component
export struct UPCol {
  @Prop props: UPColProps = new UPColProps();
  @Consume('UPRowLayoutContext') rowContext: UPRowLayoutContext;

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private colSpan(): number {
    return upLayoutInt(this.props.span, UP_GRID_UNITS, 0, UP_GRID_UNITS);
  }

  private colOffset(): number {
    return upLayoutInt(this.props.offset, 0, 0, UP_GRID_UNITS);
  }

  private colWidthPercent(): string {
    const span: number = this.colSpan();
    return `${span * 100 / UP_GRID_UNITS}%`;
  }

  private colOffsetPercent(): string {
    const offset: number = this.colOffset();
    return `${offset * 100 / UP_GRID_UNITS}%`;
  }

  private colGutter(): number {
    return this.rowContext.gutter;
  }

  private colPadding(): Padding {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.padding !== undefined) {
      return {
        top: style.padding.top,
        right: style.padding.right,
        bottom: style.padding.bottom,
        left: style.padding.left
      };
    }
    const half: number = this.colGutter() / 2;
    return { top: 0, right: half, bottom: 0, left: half };
  }

  private colMargin(): Margin {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.margin !== undefined) {
      return {
        top: style.margin.top,
        right: style.margin.right,
        bottom: style.margin.bottom,
        left: style.margin.left
      };
    }
    const offset: number = this.colOffset();
    if (offset > 0) {
      return { top: 0, right: 0, bottom: 0, left: this.colOffsetPercent() };
    }
    return { top: 0, right: 0, bottom: 0, left: 0 };
  }

  private colHorizontalAlign(): HorizontalAlign {
    const textAlign: string = upLayoutEnum(this.props.textAlign, ['left', 'center', 'right'], 'left');
    if (textAlign === 'center') {
      return HorizontalAlign.Center;
    }
    if (textAlign === 'right') {
      return HorizontalAlign.End;
    }
    return HorizontalAlign.Start;
  }

  private colJustify(): FlexAlign {
    const justify: string = upLayoutEnum(this.props.justify,
      ['start', 'center', 'end', 'space-between', 'space-around', 'space-evenly'], 'start');
    switch (justify) {
      case 'center': return FlexAlign.Center;
      case 'end': return FlexAlign.End;
      case 'space-between': return FlexAlign.SpaceBetween;
      case 'space-around': return FlexAlign.SpaceAround;
      case 'space-evenly': return FlexAlign.SpaceEvenly;
      default: return FlexAlign.Start;
    }
  }

  private colOpacity(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.opacity ?? 1;
  }

  build() {
    Column() {
      this.contentBuilder()
    }
    .width(this.colWidthPercent())
    .margin(this.colMargin())
    .padding(this.colPadding())
    .alignItems(this.colHorizontalAlign())
    .justifyContent(this.colJustify())
    .opacity(this.colOpacity())
    .onClick(() => {
      if (this.props.onClick !== undefined) {
        this.props.onClick();
      }
    })
  }
}
