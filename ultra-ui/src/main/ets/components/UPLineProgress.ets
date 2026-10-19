import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPLineProgressOptions {
  percentage?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
  height?: UPRawValue;
  showText?: UPRawValue;
  striped?: UPRawValue;
  stripedActive?: UPRawValue;
  duration?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

export class UPLineProgressProps {
  percentage: UPRawValue = 0;
  activeColor: UPRawValue = 'primary';
  inactiveColor: UPRawValue = '#ececec';
  height: UPRawValue = 12;
  showText: UPRawValue = true;
  striped: UPRawValue = false;
  stripedActive: UPRawValue = false;
  duration: UPRawValue = 30;
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPLineProgressOptions) {
    if (options === undefined) {
      return;
    }
    this.percentage = options.percentage ?? this.percentage;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.height = options.height ?? this.height;
    this.showText = options.showText ?? this.showText;
    this.striped = options.striped ?? this.striped;
    this.stripedActive = options.stripedActive ?? this.stripedActive;
    this.duration = options.duration ?? this.duration;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPLineProgress {
  @Prop props: UPLineProgressProps = new UPLineProgressProps();

  private percent(): number {
    return Math.max(0, Math.min(100, upNumber(this.props.percentage, 0)));
  }

  private barHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? UPUnit.parse(this.props.height, 375, 12);
  }

  private activeColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, UP_DEFAULT_THEME.primary);
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }


  build() {
    Row({ space: 8 }) {
      Stack({ alignContent: Alignment.Start }) {
        Column()
          .width('100%')
          .height(this.barHeight())
          .backgroundColor(UPColor.parse(this.props.inactiveColor, UP_DEFAULT_THEME, '#ececec'))
          .borderRadius(this.barHeight() / 2)
        Column()
          .width(String(this.percent()) + '%')
          .height(this.barHeight())
          .backgroundColor(this.activeColor())
          .borderRadius(this.barHeight() / 2)
          .opacity(upBoolean(this.props.striped, false) || upBoolean(this.props.stripedActive, false) ? 0.86 : 1)
      }
      .layoutWeight(1)
      .height(this.barHeight())
      if (this.props.contentBuilder !== undefined) {
        this.slotRegion()
      } else if (upBoolean(this.props.showText, true)) {
        Text(String(Math.round(this.percent())) + '%')
          .fontSize(12)
          .fontColor(UPColor.neutral('content', '#606266'))
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}
