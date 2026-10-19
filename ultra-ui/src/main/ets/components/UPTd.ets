import { UPRawValue, UPStyleInput, UPBuilder, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UPTableStyleContext, upTableAlign } from '../internal/UPTableContexts';
import { upTableColumnAlign, upTableTextAlign } from './UPTh';

export interface UPTdOptions {
  width?: UPRawValue;
  textAlign?: UPRawValue;
  fontSize?: UPRawValue;
  borderColor?: UPRawValue;
  color?: UPRawValue;
  text?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

/** Table body cell, source-compatible with uview-plus `u-td`. */
export class UPTdProps {
  width: UPRawValue = 'auto';
  textAlign: UPRawValue = '';
  fontSize: UPRawValue = '';
  borderColor: UPRawValue = '';
  color: UPRawValue = '';
  text: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPTdOptions) {
    if (options === undefined) return;
    this.width = options.width ?? this.width;
    this.textAlign = options.textAlign ?? this.textAlign;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.borderColor = options.borderColor ?? this.borderColor;
    this.color = options.color ?? this.color;
    this.text = options.text ?? this.text;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPTd {
  @Prop props: UPTdProps = new UPTdProps();
  @Consume('UPTableStyleContext') tableContext: UPTableStyleContext = new UPTableStyleContext();
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  private fixedWidth(): number {
    const declared: string = upString(this.props.width, '').trim();
    if (declared.length === 0 || declared === 'auto') return 0;
    const parsed: number = UPUnit.parse(declared, 375, 0);
    return parsed > 0 ? parsed : 0;
  }

  private cellPadding(): Padding {
    const style: UPEdgeValues | undefined = UPStyle.parse(this.props.customStyle).padding;
    const source: UPEdgeValues = style ?? UPUnit.parseEdges(this.tableContext.padding, 375, 0);
    return { top: source.top, right: source.right, bottom: source.bottom, left: source.left };
  }

  private alignValue(): string {
    const local: string = upString(this.props.textAlign, '').trim();
    if (local.length > 0) return upTableAlign(local, this.tableContext.align);
    return upTableAlign(UPStyle.parse(this.props.customStyle).textAlign ?? this.tableContext.align, this.tableContext.align);
  }

  private textColor(): string {
    const local: string = upString(this.props.color, '').trim();
    if (local.length > 0) return local;
    return UPStyle.parse(this.props.customStyle).color ?? this.tableContext.color;
  }

  private textSize(): number {
    const local: string = upString(this.props.fontSize, '').trim();
    if (local.length > 0) return UPUnit.parse(local, 375, 14);
    return UPStyle.parse(this.props.customStyle).fontSize ?? UPUnit.parse(this.tableContext.fontSize, 375, 14);
  }

  private cellBorderColor(): string {
    const local: string = upString(this.props.borderColor, '').trim();
    if (local.length > 0) return local;
    return UPStyle.parse(this.props.customStyle).borderColor ?? this.tableContext.borderColor;
  }

  private cellBackground(): string {
    const style: UPStyleInput = this.props.customStyle;
    return UPStyle.parse(style).backgroundColor ?? UPStyle.parse(style).background ?? 'transparent';
  }

  @Builder
  private content() {
    Column() {
      if (upString(this.props.text, '').length > 0) {
        Text(upString(this.props.text, ''))
          .fontSize(this.textSize())
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
    .border({ width: { bottom: 1, right: 1 }, color: this.cellBorderColor() })
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
