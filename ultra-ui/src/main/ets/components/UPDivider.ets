import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPDividerClickEvent {
  text: string;
}

export interface UPDividerOptions {
  dashed?: UPRawValue;
  hairline?: UPRawValue;
  dot?: UPRawValue;
  textPosition?: UPRawValue;
  text?: UPRawValue;
  textSize?: UPRawValue;
  textColor?: UPRawValue;
  lineColor?: UPRawValue;
  customClass?: UPRawValue;
  customStyle?: UPStyleInput;
  onTap?: (event: UPDividerClickEvent) => void;
  onClick?: (event: UPDividerClickEvent) => void;
  contentBuilder?: UPBuilder;
}

export class UPDividerProps {
  dashed: UPRawValue = false;
  hairline: UPRawValue = true;
  dot: UPRawValue = false;
  textPosition: UPRawValue = 'center';
  text: UPRawValue = '';
  textSize: UPRawValue = 14;
  textColor: UPRawValue = 'tips';
  lineColor: UPRawValue = '#dcdfe6';
  customClass: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  onTap?: (event: UPDividerClickEvent) => void;
  onClick?: (event: UPDividerClickEvent) => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPDividerOptions) {
    if (options === undefined) {
      return;
    }
    this.dashed = options.dashed ?? this.dashed;
    this.hairline = options.hairline ?? this.hairline;
    this.dot = options.dot ?? this.dot;
    this.textPosition = options.textPosition ?? this.textPosition;
    this.text = options.text ?? this.text;
    this.textSize = options.textSize ?? this.textSize;
    this.textColor = options.textColor ?? this.textColor;
    this.lineColor = options.lineColor ?? this.lineColor;
    this.customClass = options.customClass ?? this.customClass;
    this.customStyle = options.customStyle;
    this.onTap = options.onTap;
    this.onClick = options.onClick;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPDivider {
  @Prop props: UPDividerProps = new UPDividerProps();

  private label(): string {
    return this.props.text === null || this.props.text === undefined ? '' : String(this.props.text);
  }

  private lineHeight(): number {
    return upBoolean(this.props.hairline, true) ? 0.5 : 1;
  }

  private lineColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderColor ?? UPColor.parse(this.props.lineColor, UP_DEFAULT_THEME, '#dcdfe6');
  }

  private click(): void {
    const event: UPDividerClickEvent = { text: this.label() };
    this.props.onTap?.(event);
    this.props.onClick?.(event);
  }

  @Builder
  private line(weight: number) {
    Column()
      .layoutWeight(weight)
      .height(this.lineHeight())
      .backgroundColor(this.lineColor())
      .opacity(upBoolean(this.props.dashed, false) ? 0.68 : 1)
  }

  @Builder
  private middle() {
    if (upBoolean(this.props.dot, false)) {
      Column()
        .width(4)
        .height(4)
        .backgroundColor(UPColor.parse(this.props.textColor, UP_DEFAULT_THEME, UPColor.neutral('tips', '#909399')))
        .borderRadius(2)
    } else if (this.props.contentBuilder !== undefined) {
      this.slotRegion()
    } else if (this.label().length > 0) {
      Text(this.label())
        .fontSize(UPUnit.parse(this.props.textSize, 375, 14))
        .fontColor(UPColor.parse(this.props.textColor, UP_DEFAULT_THEME, UPColor.neutral('tips', '#909399')))
        .padding({ left: 12, right: 12 })
    }
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }


  build() {
    Row() {
      this.line(upString(this.props.textPosition, 'center') === 'left' ? 1 : 4)
      this.middle()
      this.line(upString(this.props.textPosition, 'center') === 'right' ? 1 : 4)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.click())
  }
}
