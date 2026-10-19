import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPBoxClickEvent {
  title: string;
}

export interface UPBoxOptions {
  title?: UPRawValue;
  subTitle?: UPRawValue;
  bgColor?: UPRawValue;
  height?: UPRawValue;
  width?: UPRawValue;
  padding?: UPRawValue;
  borderRadius?: UPRawValue;
  border?: UPRawValue;
  borderColor?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  onClick?: (event: UPBoxClickEvent) => void;
  leftBuilder?: UPBuilder;
  rightTopBuilder?: UPBuilder;
  rightBottomBuilder?: UPBuilder;
}

export class UPBoxProps {
  title: UPRawValue = '';
  subTitle: UPRawValue = '';
  bgColor: UPRawValue = '#ffffff';
  height: UPRawValue = 120;
  width: UPRawValue = '100%';
  padding: UPRawValue = 16;
  borderRadius: UPRawValue = 10;
  border: UPRawValue = false;
  borderColor: UPRawValue = '#ebeef5';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  onClick?: (event: UPBoxClickEvent) => void;
  leftBuilder?: UPBuilder;
  rightTopBuilder?: UPBuilder;
  rightBottomBuilder?: UPBuilder;

  constructor(options?: UPBoxOptions) {
    if (options === undefined) return;
    this.title = options.title ?? this.title;
    this.subTitle = options.subTitle ?? this.subTitle;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.height = options.height ?? this.height;
    this.width = options.width ?? this.width;
    this.padding = options.padding ?? this.padding;
    this.borderRadius = options.borderRadius ?? this.borderRadius;
    this.border = options.border ?? this.border;
    this.borderColor = options.borderColor ?? this.borderColor;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.onClick = options.onClick;
    this.leftBuilder = options.leftBuilder;
    this.rightTopBuilder = options.rightTopBuilder;
    this.rightBottomBuilder = options.rightBottomBuilder;
  }
}

@Component
export struct UPBox {
  @Prop props: UPBoxProps = new UPBoxProps();

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private textValue(value: UPRawValue): string {
    return value === null || value === undefined ? '' : String(value);
  }

  private boxWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.width !== undefined) return style.width;
    if (typeof this.props.width === 'string' && this.props.width.trim().endsWith('%')) return this.props.width.trim();
    const parsed: number = UPUnit.parse(this.props.width, 375, Number.NaN);
    return Number.isFinite(parsed) ? parsed : '100%';
  }

  private boxHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(0, style.height ?? UPUnit.parse(this.props.height, 375, 120));
  }

  private boxPadding(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding?.top ?? Math.max(0, UPUnit.parse(this.props.padding, 375, 16));
  }

  private boxColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color'));
  }

  private boxRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(0, style.borderRadius ?? UPUnit.parse(this.props.borderRadius, 375, 10));
  }

  private boxBorderWidth(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderWidth !== undefined) return Math.max(0, style.borderWidth);
    return upBoolean(this.props.border, false) ? 1 : 0;
  }

  private boxBorderColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderColor ?? UPColor.parse(this.props.borderColor, UP_DEFAULT_THEME, '#ebeef5');
  }

  private handleClick(): void {
    this.props.onClick?.({ title: this.textValue(this.props.title) });
  }

  @Builder
  private leftRegion() {
    UPSlotRegion({ contentBuilder: this.props.leftBuilder })
  }

  @Builder
  private rightTopRegion() {
    UPSlotRegion({ contentBuilder: this.props.rightTopBuilder })
  }

  @Builder
  private rightBottomRegion() {
    UPSlotRegion({ contentBuilder: this.props.rightBottomBuilder })
  }

  build() {
    Column({ space: 8 }) {
      if (this.textValue(this.props.title).length > 0) {
        Text(this.textValue(this.props.title))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(UPColor.adaptive('#303133', 'main-color'))
          .width('100%')
      }
      if (this.textValue(this.props.subTitle).length > 0) {
        Text(this.textValue(this.props.subTitle))
          .fontSize(12)
          .fontColor(UPColor.adaptive('#909399', 'tips-color'))
          .width('100%')
      }
      Column() {
        this.leftRegion()
        this.rightTopRegion()
        this.rightBottomRegion()
        this.contentBuilder()
      }.width('100%').layoutWeight(1)
    }
    .width(this.boxWidth())
    .height(this.boxHeight())
    .padding(this.boxPadding())
    .backgroundColor(this.boxColor())
    .borderRadius(this.boxRadius())
    .borderWidth(this.boxBorderWidth())
    .borderColor(this.boxBorderColor())
    .shadow({ radius: 8, color: '#12000000', offsetY: 2 })
    .onClick(() => this.handleClick())
  }
}
