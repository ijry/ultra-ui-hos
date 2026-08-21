import { UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPGapOptions {
  bgColor?: UPRawValue;
  height?: UPRawValue;
  marginTop?: UPRawValue;
  marginBottom?: UPRawValue;
  customStyle?: UPStyleInput;
}

export class UPGapProps {
  bgColor: UPRawValue = 'transparent';
  height: UPRawValue = 20;
  marginTop: UPRawValue = 0;
  marginBottom: UPRawValue = 0;
  customStyle: UPStyleInput = undefined;

  constructor(options?: UPGapOptions) {
    if (options === undefined) {
      return;
    }
    this.bgColor = options.bgColor ?? this.bgColor;
    this.height = options.height ?? this.height;
    this.marginTop = options.marginTop ?? this.marginTop;
    this.marginBottom = options.marginBottom ?? this.marginBottom;
    this.customStyle = options.customStyle;
  }
}

@Component
export struct UPGap {
  @Prop props: UPGapProps = new UPGapProps();

  private gapHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? UPUnit.parse(this.props.height, 375, 20);
  }

  private gapColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.backgroundColor !== undefined) {
      return style.backgroundColor;
    }
    if (style.background !== undefined) {
      return style.background;
    }
    if (this.props.bgColor === 'transparent') {
      return '#00000000';
    }
    return UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#00000000');
  }

  build() {
    Column()
      .width('100%')
      .height(this.gapHeight())
      .backgroundColor(this.gapColor())
      .margin({
        top: UPUnit.parse(this.props.marginTop, 375, 0, true),
        bottom: UPUnit.parse(this.props.marginBottom, 375, 0, true)
      })
  }
}
