import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { upLayoutEnum } from '../internal/UPLayoutContexts';
import { LengthMetrics } from '@kit.ArkUI';

/** Cross-platform glass options. Accepted for parity; not rendered on HarmonyOS
 *  yet — a real frosted effect via .backgroundBlurStyle() is a future upgrade. */
export interface UPFlexGlass {
  enabled?: boolean;
  variant?: string;
  tint?: string;
  interactive?: boolean;
  cornerRadius?: UPRawValue;
}

export interface UPFlexOptions {
  direction?: UPRawValue;
  justify?: UPRawValue;
  align?: UPRawValue;
  wrap?: UPRawValue;
  gap?: UPRawValue;
  glass?: UPFlexGlass;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  onClick?: () => void;
}

export class UPFlexProps {
  direction: UPRawValue = 'row';
  justify: UPRawValue = 'flex-start';
  align: UPRawValue = 'stretch';
  wrap: UPRawValue = false;
  gap: UPRawValue = 0;
  glass?: UPFlexGlass;
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  onClick?: () => void;

  constructor(options?: UPFlexOptions) {
    if (options === undefined) { return; }
    this.direction = options.direction ?? this.direction;
    this.justify = options.justify ?? this.justify;
    this.align = options.align ?? this.align;
    this.wrap = options.wrap ?? this.wrap;
    this.gap = options.gap ?? this.gap;
    this.glass = options.glass;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.onClick = options.onClick;
  }
}
@Component
export struct UPFlex {
  @Prop props: UPFlexProps = new UPFlexProps();

  @Builder
  private emptyContent() {}

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private flexDirection(): FlexDirection {
    const v: string = upLayoutEnum(this.props.direction, ['row', 'row-reverse', 'column', 'column-reverse'], 'row');
    switch (v) {
      case 'row-reverse': return FlexDirection.RowReverse;
      case 'column': return FlexDirection.Column;
      case 'column-reverse': return FlexDirection.ColumnReverse;
      default: return FlexDirection.Row;
    }
  }

  private justifyContent(): FlexAlign {
    const v: string = upLayoutEnum(this.props.justify,
      ['flex-start', 'start', 'flex-end', 'end', 'center', 'space-between', 'space-around', 'space-evenly'], 'flex-start');
    switch (v) {
      case 'flex-end':
      case 'end': return FlexAlign.End;
      case 'center': return FlexAlign.Center;
      case 'space-between': return FlexAlign.SpaceBetween;
      case 'space-around': return FlexAlign.SpaceAround;
      case 'space-evenly': return FlexAlign.SpaceEvenly;
      default: return FlexAlign.Start;
    }
  }
  private alignItems(): ItemAlign {
    const v: string = upLayoutEnum(this.props.align, ['flex-start', 'flex-end', 'center', 'stretch', 'baseline'], 'stretch');
    switch (v) {
      case 'flex-start': return ItemAlign.Start;
      case 'flex-end': return ItemAlign.End;
      case 'center': return ItemAlign.Center;
      case 'baseline': return ItemAlign.Baseline;
      default: return ItemAlign.Stretch;
    }
  }

  private flexWrap(): FlexWrap {
    const on: boolean = this.props.wrap === true || `${this.props.wrap}` === 'true';
    return on ? FlexWrap.Wrap : FlexWrap.NoWrap;
  }

  private gapMetrics(): LengthMetrics {
    return LengthMetrics.vp(UPUnit.parse(this.props.gap, 375, 0));
  }

  private flexPadding(): Padding {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.padding !== undefined) {
      return { top: style.padding.top, right: style.padding.right, bottom: style.padding.bottom, left: style.padding.left };
    }
    return { top: 0, right: 0, bottom: 0, left: 0 };
  }

  private flexMargin(): Margin {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.margin !== undefined) {
      return { top: style.margin.top, right: style.margin.right, bottom: style.margin.bottom, left: style.margin.left };
    }
    return { top: 0, right: 0, bottom: 0, left: 0 };
  }

  private flexOpacity(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.opacity ?? 1;
  }

  build() {
    Flex({
      direction: this.flexDirection(),
      wrap: this.flexWrap(),
      justifyContent: this.justifyContent(),
      alignItems: this.alignItems(),
      space: { main: this.gapMetrics(), cross: this.gapMetrics() }
    }) {
      this.contentBuilder()
    }
    .width('100%')
    .padding(this.flexPadding())
    .margin(this.flexMargin())
    .opacity(this.flexOpacity())
    .onClick(() => {
      if (this.props.onClick !== undefined) {
        this.props.onClick();
      }
    })
  }
}
