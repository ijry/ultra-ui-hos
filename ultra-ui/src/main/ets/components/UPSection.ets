import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit, UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPI18n } from '../core/UPI18n';

export interface UPSectionClickEvent {
  title: string;
  subTitle: string;
}

export interface UPSectionOptions {
  title?: UPRawValue;
  subTitle?: UPRawValue;
  right?: UPRawValue;
  showLine?: UPRawValue;
  arrow?: UPRawValue;
  lineColor?: UPRawValue;
  titleColor?: UPRawValue;
  subTitleColor?: UPRawValue;
  fontSize?: UPRawValue;
  customStyle?: UPStyleInput;
  onClick?: (event: UPSectionClickEvent) => void;
}

export class UPSectionProps {
  title: UPRawValue = '';
  subTitle: UPRawValue = UPI18n.t('up.common.more');
  right: UPRawValue = true;
  showLine: UPRawValue = true;
  arrow: UPRawValue = true;
  lineColor: UPRawValue = '#2979ff';
  titleColor: UPRawValue = '#303133';
  subTitleColor: UPRawValue = '#909399';
  fontSize: UPRawValue = 16;
  customStyle: UPStyleInput = undefined;
  onClick?: (event: UPSectionClickEvent) => void;

  constructor(options?: UPSectionOptions) {
    if (options === undefined) return;
    this.title = options.title ?? this.title;
    this.subTitle = options.subTitle ?? this.subTitle;
    this.right = options.right ?? this.right;
    this.showLine = options.showLine ?? this.showLine;
    this.arrow = options.arrow ?? this.arrow;
    this.lineColor = options.lineColor ?? this.lineColor;
    this.titleColor = options.titleColor ?? this.titleColor;
    this.subTitleColor = options.subTitleColor ?? this.subTitleColor;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.customStyle = options.customStyle;
    this.onClick = options.onClick;
  }
}

@Component
export struct UPSection {
  @Prop props: UPSectionProps = new UPSectionProps();

  private textValue(value: UPRawValue): string {
    return value === null || value === undefined ? '' : String(value);
  }

  private sectionWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? '100%';
  }

  private sectionPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? { top: 12, right: 16, bottom: 12, left: 16 };
  }

  private sectionBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? '#ffffff';
  }

  private titleSize(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.fontSize ?? Math.max(10, UPUnit.parse(this.props.fontSize, 375, 16));
  }

  private titleColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.color ?? UPColor.parse(this.props.titleColor, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133'));
  }

  private subtitleColor(): string {
    return UPColor.parse(this.props.subTitleColor, UP_DEFAULT_THEME, '#909399');
  }

  private lineColor(): string {
    return UPColor.parse(this.props.lineColor, UP_DEFAULT_THEME, '#2979ff');
  }

  private hasRight(): boolean {
    return upBoolean(this.props.right, true);
  }

  private handleClick(): void {
    this.props.onClick?.({ title: this.textValue(this.props.title), subTitle: this.textValue(this.props.subTitle) });
  }

  build() {
    Row({ space: 8 }) {
      if (upBoolean(this.props.showLine, true)) {
        Column().width(3).height(18).borderRadius(2).backgroundColor(this.lineColor())
      }
      Text(this.textValue(this.props.title))
        .fontSize(this.titleSize())
        .fontWeight(FontWeight.Bold)
        .fontColor(this.titleColor())
        .layoutWeight(1)
      if (this.hasRight()) {
        Row({ space: 3 }) {
          Text(this.textValue(this.props.subTitle)).fontSize(13).fontColor(this.subtitleColor())
          if (upBoolean(this.props.arrow, true)) Text('›').fontSize(20).fontColor(UPColor.adaptive('#c0c4cc', 'light-color'))
        }.onClick(() => this.handleClick())
      }
    }
    .width(this.sectionWidth())
    .padding(this.sectionPadding())
    .backgroundColor(this.sectionBackground())
    .onClick(() => this.handleClick())
  }
}
