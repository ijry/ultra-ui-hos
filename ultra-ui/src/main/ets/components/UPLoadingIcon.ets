import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPLoadingIconOptions {
  show?: UPRawValue;
  color?: UPRawValue;
  textColor?: UPRawValue;
  vertical?: UPRawValue;
  mode?: UPRawValue;
  size?: UPRawValue;
  textSize?: UPRawValue;
  text?: UPRawValue;
  timingFunction?: UPRawValue;
  duration?: UPRawValue;
  inactiveColor?: UPRawValue;
  customStyle?: UPStyleInput;
}

export class UPLoadingIconProps {
  show: UPRawValue = true;
  color: UPRawValue = 'tips';
  textColor: UPRawValue = 'tips';
  vertical: UPRawValue = false;
  mode: UPRawValue = 'spinner';
  size: UPRawValue = 24;
  textSize: UPRawValue = 15;
  text: UPRawValue = '';
  timingFunction: UPRawValue = 'ease-in-out';
  duration: UPRawValue = 1200;
  inactiveColor: UPRawValue = '';
  customStyle: UPStyleInput = undefined;

  constructor(options?: UPLoadingIconOptions) {
    if (options === undefined) {
      return;
    }
    this.show = options.show ?? this.show;
    this.color = options.color ?? this.color;
    this.textColor = options.textColor ?? this.textColor;
    this.vertical = options.vertical ?? this.vertical;
    this.mode = options.mode ?? this.mode;
    this.size = options.size ?? this.size;
    this.textSize = options.textSize ?? this.textSize;
    this.text = options.text ?? this.text;
    this.timingFunction = options.timingFunction ?? this.timingFunction;
    this.duration = options.duration ?? this.duration;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.customStyle = options.customStyle;
  }
}

@Component
export struct UPLoadingIcon {
  @Prop props: UPLoadingIconProps = new UPLoadingIconProps();

  private mode(): string {
    return upString(this.props.mode, 'spinner').toLowerCase();
  }

  private text(): string {
    return this.props.text === null || this.props.text === undefined ? '' : String(this.props.text);
  }

  @Builder
  private progress() {
    if (this.mode() === 'circle') {
      Progress({ value: 65, total: 100, type: ProgressType.Ring })
        .color(UPColor.parse(this.props.color, UP_DEFAULT_THEME))
        .backgroundColor(UPColor.parse(this.props.inactiveColor, UP_DEFAULT_THEME, '#e5e5e5'))
        .width(UPUnit.parse(this.props.size, 375, 24))
        .height(UPUnit.parse(this.props.size, 375, 24))
    } else {
      LoadingProgress()
        .color(UPColor.parse(this.props.color, UP_DEFAULT_THEME))
        .width(UPUnit.parse(this.props.size, 375, 24))
        .height(UPUnit.parse(this.props.size, 375, 24))
        .id('up-loading-' + this.mode())
        .opacity(this.mode() === 'semicircle' ? 0.88 : 1)
    }
  }

  @Builder
  private content() {
    if (!upBoolean(this.props.show, true)) {
      Row().width(0).height(0)
    } else if (upBoolean(this.props.vertical, false)) {
      Column({ space: 8 }) {
        this.progress()
        if (this.text().length > 0) {
          Text(this.text())
            .fontSize(UPUnit.parse(this.props.textSize, 375, 15))
            .fontColor(UPColor.parse(this.props.textColor, UP_DEFAULT_THEME))
        }
      }
    } else {
      Row({ space: 8 }) {
        this.progress()
        if (this.text().length > 0) {
          Text(this.text())
            .fontSize(UPUnit.parse(this.props.textSize, 375, 15))
            .fontColor(UPColor.parse(this.props.textColor, UP_DEFAULT_THEME))
        }
      }
    }
  }

  build() {
    this.content()
  }
}
