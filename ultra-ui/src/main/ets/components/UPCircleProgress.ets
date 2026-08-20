import { UPRawValue, UPStyleInput, UPBuilder, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPCircleProgressOptions {
  percentage?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
  width?: UPRawValue;
  borderWidth?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

export class UPCircleProgressProps {
  percentage: UPRawValue = 30;
  activeColor: UPRawValue = 'success';
  inactiveColor: UPRawValue = '#e5e5e5';
  width: UPRawValue = 100;
  borderWidth: UPRawValue = 5;
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPCircleProgressOptions) {
    if (options === undefined) return;
    this.percentage = options.percentage ?? this.percentage;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.width = options.width ?? this.width;
    this.borderWidth = options.borderWidth ?? this.borderWidth;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPCircleProgress {
  @Prop props: UPCircleProgressProps = new UPCircleProgressProps();

  @Builder
  private defaultContent() {
    Text(String(Math.round(this.percent())) + '%')
      .fontSize(16)
      .fontColor('#303133')
  }

  @BuilderParam contentBuilder: () => void = this.defaultContent;

  private percent(): number {
    return Math.max(0, Math.min(100, upNumber(this.props.percentage, 30)));
  }

  private ringSize(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(1, style.width ?? UPUnit.parse(this.props.width, 375, 100));
  }

  private stroke(): number {
    return Math.max(1, upNumber(this.props.borderWidth, 5));
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Progress({ value: this.percent(), total: 100, type: ProgressType.Ring })
        .color(UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, UP_DEFAULT_THEME.success))
        .backgroundColor(UPColor.parse(this.props.inactiveColor, UP_DEFAULT_THEME, '#e5e5e5'))
        .style({ strokeWidth: this.stroke() })
        .width(this.ringSize())
        .height(this.ringSize())
      this.contentBuilder()
    }
    .width(this.ringSize())
    .height(this.ringSize())
    .opacity(UPStyle.parse(this.props.customStyle).opacity ?? 1)
  }
}
