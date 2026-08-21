import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPImage, UPImageProps } from './UPImage';

export type UPCardArea = 'card' | 'head' | 'body' | 'foot';

export interface UPCardClickEvent {
  index: UPRawValue;
  area: UPCardArea;
}

export interface UPCardOptions {
  full?: UPRawValue;
  title?: UPRawValue;
  titleColor?: UPRawValue;
  titleSize?: UPRawValue;
  subTitle?: UPRawValue;
  subTitleColor?: UPRawValue;
  subTitleSize?: UPRawValue;
  border?: UPRawValue;
  index?: UPRawValue;
  margin?: UPRawValue;
  borderRadius?: UPRawValue;
  headStyle?: UPStyleInput;
  bodyStyle?: UPStyleInput;
  footStyle?: UPStyleInput;
  headBorderBottom?: UPRawValue;
  footBorderTop?: UPRawValue;
  thumb?: UPRawValue;
  thumbWidth?: UPRawValue;
  thumbCircle?: UPRawValue;
  padding?: UPRawValue;
  paddingHead?: UPRawValue;
  paddingBody?: UPRawValue;
  paddingFoot?: UPRawValue;
  showHead?: UPRawValue;
  showFoot?: UPRawValue;
  boxShadow?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  headBuilder?: UPBuilder;
  footBuilder?: UPBuilder;
  onClick?: (event: UPCardClickEvent) => void;
  onHeadClick?: (event: UPCardClickEvent) => void;
  onBodyClick?: (event: UPCardClickEvent) => void;
  onFootClick?: (event: UPCardClickEvent) => void;
}

/** Card container with optional head/body/foot regions, source-compatible with uview-plus `u-card`. */
export class UPCardProps {
  full: UPRawValue = false;
  title: UPRawValue = '';
  titleColor: UPRawValue = '#303133';
  titleSize: UPRawValue = '15px';
  subTitle: UPRawValue = '';
  subTitleColor: UPRawValue = '#909399';
  subTitleSize: UPRawValue = '13px';
  border: UPRawValue = true;
  index: UPRawValue = '';
  margin: UPRawValue = '15px';
  borderRadius: UPRawValue = '8px';
  headStyle: UPStyleInput = undefined;
  bodyStyle: UPStyleInput = undefined;
  footStyle: UPStyleInput = undefined;
  headBorderBottom: UPRawValue = true;
  footBorderTop: UPRawValue = true;
  thumb: UPRawValue = '';
  thumbWidth: UPRawValue = '30px';
  thumbCircle: UPRawValue = false;
  padding: UPRawValue = '15px';
  paddingHead: UPRawValue = '';
  paddingBody: UPRawValue = '';
  paddingFoot: UPRawValue = '';
  showHead: UPRawValue = true;
  showFoot: UPRawValue = true;
  boxShadow: UPRawValue = 'none';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  headBuilder?: UPBuilder;
  footBuilder?: UPBuilder;
  onClick?: (event: UPCardClickEvent) => void;
  onHeadClick?: (event: UPCardClickEvent) => void;
  onBodyClick?: (event: UPCardClickEvent) => void;
  onFootClick?: (event: UPCardClickEvent) => void;

  constructor(options?: UPCardOptions) {
    if (options === undefined) {
      return;
    }
    this.full = options.full ?? this.full;
    this.title = options.title ?? this.title;
    this.titleColor = options.titleColor ?? this.titleColor;
    this.titleSize = options.titleSize ?? this.titleSize;
    this.subTitle = options.subTitle ?? this.subTitle;
    this.subTitleColor = options.subTitleColor ?? this.subTitleColor;
    this.subTitleSize = options.subTitleSize ?? this.subTitleSize;
    this.border = options.border ?? this.border;
    this.index = options.index ?? this.index;
    this.margin = options.margin ?? this.margin;
    this.borderRadius = options.borderRadius ?? this.borderRadius;
    this.headStyle = options.headStyle;
    this.bodyStyle = options.bodyStyle;
    this.footStyle = options.footStyle;
    this.headBorderBottom = options.headBorderBottom ?? this.headBorderBottom;
    this.footBorderTop = options.footBorderTop ?? this.footBorderTop;
    this.thumb = options.thumb ?? this.thumb;
    this.thumbWidth = options.thumbWidth ?? this.thumbWidth;
    this.thumbCircle = options.thumbCircle ?? this.thumbCircle;
    this.padding = options.padding ?? this.padding;
    this.paddingHead = options.paddingHead ?? this.paddingHead;
    this.paddingBody = options.paddingBody ?? this.paddingBody;
    this.paddingFoot = options.paddingFoot ?? this.paddingFoot;
    this.showHead = options.showHead ?? this.showHead;
    this.showFoot = options.showFoot ?? this.showFoot;
    this.boxShadow = options.boxShadow ?? this.boxShadow;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.headBuilder = options.headBuilder;
    this.footBuilder = options.footBuilder;
    this.onClick = options.onClick;
    this.onHeadClick = options.onHeadClick;
    this.onBodyClick = options.onBodyClick;
    this.onFootClick = options.onFootClick;
  }
}

@Component
struct UPCardBuilderRegion {
  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  build() {
    Column() {
      this.contentBuilder()
    }
    .width('100%')
  }
}

@Component
export struct UPCard {
  @Prop props: UPCardProps = new UPCardProps();

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private textValue(value: UPRawValue): string {
    return value === null || value === undefined ? '' : String(value);
  }

  private titleText(): string {
    return this.textValue(this.props.title);
  }

  private subTitleText(): string {
    return this.textValue(this.props.subTitle);
  }

  private thumbText(): string {
    return this.textValue(this.props.thumb);
  }

  private thumbLocal(): boolean {
    const source: string = this.thumbText();
    return source.startsWith('resource://') || source.startsWith('file://') ||
      source.startsWith('/') || source.startsWith('$rawfile:');
  }

  private cardFull(): boolean {
    return upBoolean(this.props.full, false);
  }

  private cardBorder(): boolean {
    return upBoolean(this.props.border, true);
  }

  private cardShowHead(): boolean {
    return upBoolean(this.props.showHead, true);
  }

  private cardShowFoot(): boolean {
    return upBoolean(this.props.showFoot, true);
  }

  private cardHeadBorderBottom(): boolean {
    return upBoolean(this.props.headBorderBottom, true);
  }

  private cardFootBorderTop(): boolean {
    return upBoolean(this.props.footBorderTop, true);
  }

  private cardThumbCircle(): boolean {
    return upBoolean(this.props.thumbCircle, false);
  }

  private cardRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderRadius !== undefined) {
      return Math.max(0, style.borderRadius);
    }
    return Math.max(0, UPUnit.parse(this.props.borderRadius, 375, 8));
  }

  private cardMargin(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.margin !== undefined) {
      return style.margin;
    }
    if (this.cardFull()) {
      return { top: 0, right: 0, bottom: 0, left: 0 };
    }
    const margin: number = Math.max(0, UPUnit.parse(this.props.margin, 375, 15));
    return { top: margin, right: margin, bottom: margin, left: margin };
  }

  private cardPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.padding !== undefined) {
      return style.padding;
    }
    const padding: number = Math.max(0, UPUnit.parse(this.props.padding, 375, 15));
    return { top: padding, right: padding, bottom: padding, left: padding };
  }

  private sectionPadding(sectionStyle: UPStyleInput, sectionPadding: UPRawValue): UPEdgeValues {
    const style = UPStyle.parse(sectionStyle);
    if (style.padding !== undefined) {
      return style.padding;
    }
    const base: UPEdgeValues = this.cardPadding();
    const value: number = Math.max(0, UPUnit.parse(sectionPadding, 375, base.top));
    return { top: value, right: value, bottom: value, left: value };
  }

  private headPadding(): UPEdgeValues {
    return this.sectionPadding(this.props.headStyle, this.props.paddingHead);
  }

  private bodyPadding(): UPEdgeValues {
    return this.sectionPadding(this.props.bodyStyle, this.props.paddingBody);
  }

  private footPadding(): UPEdgeValues {
    return this.sectionPadding(this.props.footStyle, this.props.paddingFoot);
  }

  private titleColorValue(): string {
    const style = UPStyle.parse(this.props.headStyle);
    return style.color ?? UPColor.parse(this.props.titleColor, UP_DEFAULT_THEME, '#303133');
  }

  private subTitleColorValue(): string {
    const style = UPStyle.parse(this.props.headStyle);
    return style.color ?? UPColor.parse(this.props.subTitleColor, UP_DEFAULT_THEME, '#909399');
  }

  private titleSizeValue(): number {
    return Math.max(0, UPUnit.parse(this.props.titleSize, 375, 15));
  }

  private subTitleSizeValue(): number {
    return Math.max(0, UPUnit.parse(this.props.subTitleSize, 375, 13));
  }

  private thumbWidthValue(): number {
    return Math.max(0, UPUnit.parse(this.props.thumbWidth, 375, 30));
  }

  private cardBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.backgroundColor !== undefined) {
      return style.backgroundColor;
    }
    if (style.background !== undefined) {
      return style.background;
    }
    return '#ffffff';
  }

  private cardOpacity(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.opacity ?? 1;
  }

  private hasShadow(): boolean {
    const shadow: string = upString(this.props.boxShadow, 'none').trim().toLowerCase();
    return shadow.length > 0 && shadow !== 'none';
  }

  private hasCustomHead(): boolean {
    return this.props.headBuilder !== undefined;
  }

  private hasCustomFoot(): boolean {
    return this.props.footBuilder !== undefined;
  }

  private headVisible(): boolean {
    if (!this.cardShowHead()) {
      return false;
    }
    if (this.hasCustomHead()) {
      return true;
    }
    return this.titleText().length > 0 || this.subTitleText().length > 0 || this.thumbText().length > 0;
  }

  private footVisible(): boolean {
    return this.cardShowFoot() && this.hasCustomFoot();
  }

  private emitClick(area: UPCardArea): void {
    const event: UPCardClickEvent = { index: this.props.index, area: area };
    if (this.props.onClick !== undefined) {
      this.props.onClick(event);
    }
    if (area === 'head' && this.props.onHeadClick !== undefined) {
      this.props.onHeadClick(event);
    } else if (area === 'body' && this.props.onBodyClick !== undefined) {
      this.props.onBodyClick(event);
    } else if (area === 'foot' && this.props.onFootClick !== undefined) {
      this.props.onFootClick(event);
    }
  }

  @Builder
  private defaultHead() {
    Row({ space: 8 }) {
      if (this.thumbText().length > 0 && this.thumbLocal()) {
        UPImage({ props: new UPImageProps({
          src: this.props.thumb,
          width: this.thumbWidthValue(),
          height: this.thumbWidthValue(),
          shape: this.cardThumbCircle() ? 'circle' : 'square',
          showError: false,
          showLoading: false
        }) })
      }
      Column({ space: 2 }) {
        if (this.titleText().length > 0) {
          Text(this.titleText())
            .fontSize(this.titleSizeValue())
            .fontWeight(FontWeight.Medium)
            .fontColor(this.titleColorValue())
        }
        if (this.subTitleText().length > 0) {
          Text(this.subTitleText())
            .fontSize(this.subTitleSizeValue())
            .fontColor(this.subTitleColorValue())
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private headRegion() {
    if (this.headVisible()) {
      Column() {
        if (this.hasCustomHead()) {
          UPCardBuilderRegion({ contentBuilder: this.props.headBuilder })
        } else {
          this.defaultHead()
        }
      }
      .width('100%')
      .padding(this.headPadding())
      .onClick(() => this.emitClick('head'))
    }
  }

  @Builder
  private bodyRegion() {
    Column() {
      this.contentBuilder()
    }
    .width('100%')
    .padding(this.bodyPadding())
    .onClick(() => this.emitClick('body'))
  }

  @Builder
  private footRegion() {
    if (this.footVisible()) {
      Column() {
        UPCardBuilderRegion({ contentBuilder: this.props.footBuilder })
      }
      .width('100%')
      .padding(this.footPadding())
      .onClick(() => this.emitClick('foot'))
    }
  }

  @Builder
  private headDivider() {
    if (this.headVisible() && this.cardHeadBorderBottom()) {
      Divider()
        .strokeWidth(0.5)
        .color('#ebeef5')
    }
  }

  @Builder
  private footDivider() {
    if (this.footVisible() && this.cardFootBorderTop()) {
      Divider()
        .strokeWidth(0.5)
        .color('#ebeef5')
    }
  }

  build() {
    Column() {
      this.headRegion()
      this.headDivider()
      this.bodyRegion()
      this.footDivider()
      this.footRegion()
    }
    .width('100%')
    .backgroundColor(this.cardBackground())
    .borderWidth(this.cardBorder() ? 0.5 : 0)
    .borderColor('#ebeef5')
    .borderRadius(this.cardRadius())
    .margin(this.cardMargin())
    .opacity(this.cardOpacity())
    .shadow(this.hasShadow() ? { radius: 8, color: '#1a000000', offsetX: 0, offsetY: 2 } : { radius: 0, color: '#00000000', offsetX: 0, offsetY: 0 })
    .onClick(() => this.emitClick('card'))
  }
}
