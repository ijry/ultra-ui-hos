import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPColor } from '../core/UPColor';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPEmptyOptions {
  icon?: UPRawValue;
  text?: UPRawValue;
  textColor?: UPRawValue;
  textSize?: UPRawValue;
  iconColor?: UPRawValue;
  iconSize?: UPRawValue;
  mode?: UPRawValue;
  width?: UPRawValue;
  height?: UPRawValue;
  show?: UPRawValue;
  marginTop?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

export class UPEmptyProps {
  icon: UPRawValue = '';
  text: UPRawValue = '';
  textColor: UPRawValue = '#c0c4cc';
  textSize: UPRawValue = 14;
  iconColor: UPRawValue = '#c0c4cc';
  iconSize: UPRawValue = 90;
  mode: UPRawValue = 'data';
  width: UPRawValue = 160;
  height: UPRawValue = 160;
  show: UPRawValue = true;
  marginTop: UPRawValue = 0;
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPEmptyOptions) {
    if (options === undefined) {
      return;
    }
    this.icon = options.icon ?? this.icon;
    this.text = options.text ?? this.text;
    this.textColor = options.textColor ?? this.textColor;
    this.textSize = options.textSize ?? this.textSize;
    this.iconColor = options.iconColor ?? this.iconColor;
    this.iconSize = options.iconSize ?? this.iconSize;
    this.mode = options.mode ?? this.mode;
    this.width = options.width ?? this.width;
    this.height = options.height ?? this.height;
    this.show = options.show ?? this.show;
    this.marginTop = options.marginTop ?? this.marginTop;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

function textValue(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

function modeIcon(mode: string): string {
  switch (mode.toLowerCase()) {
    case 'search': return 'empty-search';
    case 'network': return 'empty-wifi';
    case 'permission': return 'empty-permission';
    case 'coupon': return 'empty-coupon';
    case 'favor': return 'empty-favor';
    case 'history': return 'empty-history';
    case 'news': return 'empty-news';
    case 'order': return 'empty-order';
    case 'address': return 'empty-address';
    case 'car': return 'empty-car';
    case 'list': return 'empty-list';
    case 'page': return 'empty-page';
    default: return 'empty-data';
  }
}

@Component
export struct UPEmpty {
  @Prop props: UPEmptyProps = new UPEmptyProps();

  private iconName(): string {
    const custom: string = textValue(this.props.icon);
    return custom.length > 0 ? custom : modeIcon(textValue(this.props.mode));
  }

  private emptyWidth(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? UPUnit.parse(this.props.width, 375, 160);
  }

  private emptyHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? UPUnit.parse(this.props.height, 375, 160);
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }


  build() {
    if (!upBoolean(this.props.show, true)) {
      Row().width(0).height(0)
    } else {
      Column({ space: 10 }) {
        UPIcon({ props: new UPIconProps({
          name: this.iconName(),
          size: UPUnit.parse(this.props.iconSize, 375, 90),
          color: UPColor.parse(this.props.iconColor, UP_DEFAULT_THEME, UPColor.neutral('light', '#c0c4cc'))
        }) })
        if (textValue(this.props.text).length > 0) {
          Text(textValue(this.props.text))
            .fontSize(UPUnit.parse(this.props.textSize, 375, 14))
            .fontColor(UPColor.parse(this.props.textColor, UP_DEFAULT_THEME, UPColor.neutral('light', '#c0c4cc')))
            .textAlign(TextAlign.Center)
            .maxLines(2)
        }
        this.slotRegion()
      }
      .width(this.emptyWidth())
      .height(this.emptyHeight())
      .margin({ top: UPUnit.parse(this.props.marginTop, 375, 0) })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .id('up-empty')
    }
  }
}
