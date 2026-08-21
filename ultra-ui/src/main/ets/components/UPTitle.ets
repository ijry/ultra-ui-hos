import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPTitleOptions {
  title?: UPRawValue;
  subTitle?: UPRawValue;
  type?: UPRawValue;
  color?: UPRawValue;
  size?: UPRawValue;
  bold?: UPRawValue;
  align?: UPRawValue;
  prefix?: UPRawValue;
  prefixColor?: UPRawValue;
  prefixWidth?: UPRawValue;
  prefixHeight?: UPRawValue;
  customStyle?: UPStyleInput;
}

export class UPTitleProps {
  title: UPRawValue = '';
  subTitle: UPRawValue = '';
  type: UPRawValue = 'primary';
  color: UPRawValue = 'main';
  size: UPRawValue = 16;
  bold: UPRawValue = true;
  align: UPRawValue = 'left';
  prefix: UPRawValue = true;
  prefixColor: UPRawValue = '';
  prefixWidth: UPRawValue = 4;
  prefixHeight: UPRawValue = 18;
  customStyle: UPStyleInput = undefined;

  constructor(options?: UPTitleOptions) {
    if (options === undefined) {
      return;
    }
    this.title = options.title ?? this.title;
    this.subTitle = options.subTitle ?? this.subTitle;
    this.type = options.type ?? this.type;
    this.color = options.color ?? this.color;
    this.size = options.size ?? this.size;
    this.bold = options.bold ?? this.bold;
    this.align = options.align ?? this.align;
    this.prefix = options.prefix ?? this.prefix;
    this.prefixColor = options.prefixColor ?? this.prefixColor;
    this.prefixWidth = options.prefixWidth ?? this.prefixWidth;
    this.prefixHeight = options.prefixHeight ?? this.prefixHeight;
    this.customStyle = options.customStyle;
  }
}

function titleTypeColor(type: string): string {
  switch (type) {
    case 'success': return UP_DEFAULT_THEME.success;
    case 'warning': return UP_DEFAULT_THEME.warning;
    case 'error': return UP_DEFAULT_THEME.error;
    case 'info': return UP_DEFAULT_THEME.info;
    default: return UP_DEFAULT_THEME.primary;
  }
}

@Component
export struct UPTitle {
  @Prop props: UPTitleProps = new UPTitleProps();

  private mainText(): string {
    return this.props.title === null || this.props.title === undefined ? '' : String(this.props.title);
  }

  private subText(): string {
    return this.props.subTitle === null || this.props.subTitle === undefined ? '' : String(this.props.subTitle);
  }

  private textColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.color ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, UP_DEFAULT_THEME.main);
  }

  private prefixFill(): string {
    const fallback: string = titleTypeColor(upString(this.props.type, 'primary').toLowerCase());
    return UPColor.parse(this.props.prefixColor, UP_DEFAULT_THEME, fallback);
  }

  private titleAlign(): HorizontalAlign {
    const align: string = upString(this.props.align, 'left').toLowerCase();
    if (align === 'center') {
      return HorizontalAlign.Center;
    }
    if (align === 'right') {
      return HorizontalAlign.End;
    }
    return HorizontalAlign.Start;
  }

  build() {
    Row({ space: 10 }) {
      if (upBoolean(this.props.prefix, true)) {
        Column()
          .width(UPUnit.parse(this.props.prefixWidth, 375, 4))
          .height(UPUnit.parse(this.props.prefixHeight, 375, 18))
          .backgroundColor(this.prefixFill())
          .borderRadius(2)
      }
      Column({ space: 4 }) {
        if (this.mainText().length > 0) {
          Text(this.mainText())
            .fontSize(UPUnit.parse(this.props.size, 375, 16))
            .fontWeight(upBoolean(this.props.bold, true) ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.textColor())
        }
        if (this.subText().length > 0) {
          Text(this.subText())
            .fontSize(13)
            .fontColor(UP_DEFAULT_THEME.tips)
        }
      }
      .layoutWeight(1)
      .alignItems(this.titleAlign())
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}
