import { UPRawValue, UPEdgeInput, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPViewClickEvent {
  name: UPRawValue;
  index: UPRawValue;
}

export interface UPViewOptions {
  flexDirection?: UPRawValue;
  flexWrap?: UPRawValue;
  justifyContent?: UPRawValue;
  alignItems?: UPRawValue;
  width?: UPRawValue;
  height?: UPRawValue;
  bgColor?: UPRawValue;
  backgroundColor?: UPRawValue;
  flex1?: UPRawValue;
  color?: UPRawValue;
  padding?: UPRawValue | UPEdgeInput;
  margin?: UPRawValue | UPEdgeInput;
  border?: UPRawValue;
  borderColor?: UPRawValue;
  borderWidth?: UPRawValue;
  borderRadius?: UPRawValue;
  opacity?: UPRawValue;
  name?: UPRawValue;
  index?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  onClick?: (event: UPViewClickEvent) => void;
}

export class UPViewProps {
  flexDirection: UPRawValue = 'column';
  flexWrap: UPRawValue = 'nowrap';
  justifyContent: UPRawValue = 'start';
  alignItems: UPRawValue = 'stretch';
  width: UPRawValue = '100%';
  height: UPRawValue = '';
  bgColor: UPRawValue = 'transparent';
  backgroundColor: UPRawValue = '';
  flex1: UPRawValue = '';
  color: UPRawValue = '#303133';
  padding: UPRawValue | UPEdgeInput = 0;
  margin: UPRawValue | UPEdgeInput = 0;
  border: UPRawValue = false;
  borderColor: UPRawValue = '#ebeef5';
  borderWidth: UPRawValue = 1;
  borderRadius: UPRawValue = 0;
  opacity: UPRawValue = 1;
  name: UPRawValue = '';
  index: UPRawValue = 0;
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  onClick?: (event: UPViewClickEvent) => void;

  constructor(options?: UPViewOptions) {
    if (options === undefined) return;
    this.flexDirection = options.flexDirection ?? this.flexDirection;
    this.flexWrap = options.flexWrap ?? this.flexWrap;
    this.justifyContent = options.justifyContent ?? this.justifyContent;
    this.alignItems = options.alignItems ?? this.alignItems;
    this.width = options.width ?? this.width;
    this.height = options.height ?? this.height;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.backgroundColor = options.backgroundColor ?? this.backgroundColor;
    this.flex1 = options.flex1 ?? this.flex1;
    this.color = options.color ?? this.color;
    this.padding = options.padding ?? this.padding;
    this.margin = options.margin ?? this.margin;
    this.border = options.border ?? this.border;
    this.borderColor = options.borderColor ?? this.borderColor;
    this.borderWidth = options.borderWidth ?? this.borderWidth;
    this.borderRadius = options.borderRadius ?? this.borderRadius;
    this.opacity = options.opacity ?? this.opacity;
    this.name = options.name ?? this.name;
    this.index = options.index ?? this.index;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.onClick = options.onClick;
  }
}

@Component
export struct UPView {
  @Prop props: UPViewProps = new UPViewProps();

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private dimensionValue(value: UPRawValue, fallback: number | string): number | string {
    if (typeof value === 'string' && value.trim().endsWith('%')) return value.trim();
    const parsed: number = UPUnit.parse(value, 375, Number.NaN);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  private viewWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? this.dimensionValue(this.props.width, '100%');
  }

  private viewHeight(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? this.dimensionValue(this.props.height, 'auto');
  }

  private viewPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? UPUnit.parseEdges(this.props.padding, 375, 0);
  }

  private viewMargin(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.margin ?? UPUnit.parseEdges(this.props.margin, 375, 0);
  }

  /** `backgroundColor` 是上游名，`bgColor` 为本端别名。/ backgroundColor is upstream, bgColor is the local alias. */
  private viewBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.backgroundColor !== undefined) return style.backgroundColor;
    if (style.background !== undefined) return style.background;
    const upstream: string = upString(this.props.backgroundColor, '').trim();
    const source: UPRawValue = upstream.length > 0 ? this.props.backgroundColor : this.props.bgColor;
    if (upString(source, 'transparent').trim().toLowerCase() === 'transparent') return '#00000000';
    return UPColor.parse(source, UP_DEFAULT_THEME, '#00000000');
  }

  /** 上游 flex1：非空即让容器占满剩余主轴空间。/ Upstream flex1 fills the remaining main-axis space. */
  private viewFlexGrow(): number {
    return upString(this.props.flex1, '').trim().length > 0 || upBoolean(this.props.flex1, false) ? 1 : 0;
  }

  private viewDirection(): FlexDirection {
    switch (upString(this.props.flexDirection, 'column').toLowerCase()) {
      case 'row': return FlexDirection.Row;
      case 'row-reverse': return FlexDirection.RowReverse;
      case 'column-reverse': return FlexDirection.ColumnReverse;
      default: return FlexDirection.Column;
    }
  }

  private viewWrap(): FlexWrap {
    switch (upString(this.props.flexWrap, 'nowrap').toLowerCase()) {
      case 'wrap': return FlexWrap.Wrap;
      case 'wrap-reverse': return FlexWrap.WrapReverse;
      default: return FlexWrap.NoWrap;
    }
  }

  private viewJustify(): FlexAlign {
    switch (upString(this.props.justifyContent, 'start').toLowerCase()) {
      case 'center': return FlexAlign.Center;
      case 'end': return FlexAlign.End;
      case 'space-between': return FlexAlign.SpaceBetween;
      case 'space-around': return FlexAlign.SpaceAround;
      case 'space-evenly': return FlexAlign.SpaceEvenly;
      default: return FlexAlign.Start;
    }
  }

  private viewAlign(): ItemAlign {
    switch (upString(this.props.alignItems, 'stretch').toLowerCase()) {
      case 'start': return ItemAlign.Start;
      case 'center': return ItemAlign.Center;
      case 'end': return ItemAlign.End;
      default: return ItemAlign.Stretch;
    }
  }

  private viewRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(0, style.borderRadius ?? UPUnit.parse(this.props.borderRadius, 375, 0));
  }

  private viewBorderWidth(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderWidth !== undefined) return Math.max(0, style.borderWidth);
    if (typeof this.props.border === 'string' && this.props.border.trim().toLowerCase() === 'none') return 0;
    return upBoolean(this.props.border, false) ? Math.max(0, UPUnit.parse(this.props.borderWidth, 375, 1)) : 0;
  }

  private viewBorderColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderColor ?? UPColor.parse(this.props.borderColor, UP_DEFAULT_THEME, '#ebeef5');
  }

  private viewOpacity(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(0, Math.min(1, style.opacity ?? upNumber(this.props.opacity, 1)));
  }

  private handleClick(): void {
    this.props.onClick?.({ name: this.props.name, index: this.props.index });
  }

  build() {
    Flex({
      direction: this.viewDirection(),
      wrap: this.viewWrap(),
      justifyContent: this.viewJustify(),
      alignItems: this.viewAlign()
    }) {
      this.contentBuilder()
    }
    .width(this.viewWidth())
    .height(this.viewHeight())
    .padding(this.viewPadding())
    .margin(this.viewMargin())
    .backgroundColor(this.viewBackground())
    .borderRadius(this.viewRadius())
    .borderWidth(this.viewBorderWidth())
    .borderColor(this.viewBorderColor())
    .opacity(this.viewOpacity())
    .flexGrow(this.viewFlexGrow())
    .onClick(() => this.handleClick())
  }
}
