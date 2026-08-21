import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPLineOptions {
  color?: UPRawValue;
  length?: UPRawValue;
  direction?: UPRawValue;
  hairline?: UPRawValue;
  margin?: UPRawValue;
  dashed?: UPRawValue;
  customStyle?: UPStyleInput;
}

export class UPLineProps {
  color: UPRawValue = '#d6d7d9';
  length: UPRawValue = '100%';
  direction: UPRawValue = 'row';
  hairline: UPRawValue = true;
  margin: UPRawValue = 0;
  dashed: UPRawValue = false;
  customStyle: UPStyleInput = undefined;

  constructor(options?: UPLineOptions) {
    if (options === undefined) {
      return;
    }
    this.color = options.color ?? this.color;
    this.length = options.length ?? this.length;
    this.direction = options.direction ?? this.direction;
    this.hairline = options.hairline ?? this.hairline;
    this.margin = options.margin ?? this.margin;
    this.dashed = options.dashed ?? this.dashed;
    this.customStyle = options.customStyle;
  }
}

@Component
export struct UPLine {
  @Prop props: UPLineProps = new UPLineProps();

  private isHorizontal(): boolean {
    return upString(this.props.direction, 'row').toLowerCase() === 'row';
  }

  private lineThickness(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? (upBoolean(this.props.hairline, true) ? 0.5 : 1);
  }

  private lineLength(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    if (this.isHorizontal() && style.width !== undefined) {
      return style.width;
    }
    if (!this.isHorizontal() && style.height !== undefined) {
      return style.height;
    }
    if (typeof this.props.length === 'string') {
      const value: string = this.props.length.trim();
      if (value.endsWith('%')) {
        return value;
      }
    }
    return UPUnit.parse(this.props.length, 375, this.isHorizontal() ? 375 : 40);
  }

  private lineColor(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#d6d7d9');
  }

  private marginValue(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.margin?.top ?? UPUnit.parse(this.props.margin, 375, 0, true);
  }

  @Builder
  private solidLine() {
    Column()
      .width(this.isHorizontal() ? this.lineLength() : this.lineThickness())
      .height(this.isHorizontal() ? this.lineThickness() : this.lineLength())
      .backgroundColor(this.lineColor())
      .opacity(upBoolean(this.props.dashed, false) ? 0.72 : 1)
  }

  build() {
    Column() {
      this.solidLine()
    }
    .margin(this.marginValue())
  }
}
