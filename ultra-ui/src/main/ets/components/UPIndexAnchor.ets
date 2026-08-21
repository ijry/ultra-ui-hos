import { UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPIndexAnchorOptions {
  text?: UPRawValue;
  color?: UPRawValue;
  size?: UPRawValue;
  bgColor?: UPRawValue;
  height?: UPRawValue;
  customStyle?: UPStyleInput;
}

export class UPIndexAnchorProps {
  text: UPRawValue = '';
  color: UPRawValue = '#606266';
  size: UPRawValue = 14;
  bgColor: UPRawValue = '#f1f1f1';
  height: UPRawValue = 32;
  customStyle: UPStyleInput = undefined;

  constructor(options?: UPIndexAnchorOptions) {
    if (options === undefined) return;
    this.text = options.text ?? this.text;
    this.color = options.color ?? this.color;
    this.size = options.size ?? this.size;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.height = options.height ?? this.height;
    this.customStyle = options.customStyle;
  }
}

@Component
export struct UPIndexAnchor {
  @Prop props: UPIndexAnchorProps = new UPIndexAnchorProps();

  build() {
    Row() {
      Text(String(this.props.text ?? ''))
        .fontSize(UPUnit.parse(this.props.size, 375, 14))
        .fontColor(UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#606266'))
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(Math.max(1, UPUnit.parse(this.props.height, 375, 32)))
    .padding(UPStyle.parse(this.props.customStyle).padding ?? { left: 12, right: 12 })
    .backgroundColor(UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#f1f1f1'))
    .borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 0)
    .justifyContent(FlexAlign.Start)
  }
}
