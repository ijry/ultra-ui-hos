import { UPRawValue, UPStyleInput, UPBuilder, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UPTableStyleContext, upTableAlign } from '../internal/UPTableContexts';

export interface UPThOptions {
  width?: UPRawValue;
  text?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

/** Table header cell, source-compatible with uview-plus `u-th`. */
export class UPThProps {
  width: UPRawValue = '';
  text: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPThOptions) {
    if (options === undefined) return;
    this.width = options.width ?? this.width;
    this.text = options.text ?? this.text;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

/** Map a normalized table alignment token to the ArkUI text alignment. */
export function upTableTextAlign(value: string): TextAlign {
  switch (value) {
    case 'left': return TextAlign.Start;
    case 'right': return TextAlign.End;
    default: return TextAlign.Center;
  }
}

/** Map a normalized table alignment token to the ArkUI horizontal alignment. */
export function upTableColumnAlign(value: string): HorizontalAlign {
  switch (value) {
    case 'left': return HorizontalAlign.Start;
    case 'right': return HorizontalAlign.End;
    default: return HorizontalAlign.Center;
  }
}

@Component
export struct UPTh {
  @Prop props: UPThProps = new UPThProps();
  @Consume('UPTableStyleContext') tableContext: UPTableStyleContext = new UPTableStyleContext();
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  private headerStyle(): UPStyleInput {
    return this.props.customStyle ?? this.tableContext.thStyle;
  }

  private fixedWidth(): number {
    const declared: string = upString(this.props.width, '').trim();
    if (declared.length === 0) return 0;
    const parsed: number = UPUnit.parse(declared, 375, 0);
    return parsed > 0 ? parsed : 0;
  }

  private cellPadding(): Padding {
    const edges: UPEdgeValues = UPUnit.parseEdges(this.tableContext.padding, 375, 0);
    const style: UPEdgeValues | undefined = UPStyle.parse(this.headerStyle()).padding;
    const source: UPEdgeValues = style ?? edges;
    return { top: source.top, right: source.right, bottom: source.bottom, left: source.left };
  }

  private alignValue(): string {
    return upTableAlign(UPStyle.parse(this.headerStyle()).textAlign ?? this.tableContext.align, this.tableContext.align);
  }

  private textColor(): string {
    return UPStyle.parse(this.headerStyle()).color ?? '#303133';
  }

  private textSize(): number {
    return UPStyle.parse(this.headerStyle()).fontSize ?? 14;
  }

  private cellBackground(): string {
    const style: UPStyleInput = this.headerStyle();
    return UPStyle.parse(style).backgroundColor ?? UPStyle.parse(style).background ?? '#f5f6f8';
  }

  @Builder
  private content() {
    Column() {
      if (upString(this.props.text, '').length > 0) {
        Text(upString(this.props.text, ''))
          .fontSize(this.textSize())
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textColor())
          .textAlign(upTableTextAlign(this.alignValue()))
          .width('100%')
      }
      this.contentBuilder()
    }
    .alignItems(upTableColumnAlign(this.alignValue()))
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding(this.cellPadding())
    .backgroundColor(this.cellBackground())
    .border({ width: { bottom: 1, right: 1 }, color: this.tableContext.borderColor })
  }

  build() {
    if (this.fixedWidth() > 0) {
      Column() {
        this.content()
      }
      .width(this.fixedWidth())
    } else {
      Column() {
        this.content()
      }
      .layoutWeight(1)
    }
  }
}
