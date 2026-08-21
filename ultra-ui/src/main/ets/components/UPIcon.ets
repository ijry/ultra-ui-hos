import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPUnit } from '../core/UPUnit';
import { UPIconGlyphs } from '../internal/UPIconGlyphs';

const UP_ICON_FONT_FAMILY: string = 'uicon-iconfont';

class UPIconFont {
  static registered: boolean = false;
}

export interface UPIconOptions {
  name?: UPRawValue;
  color?: UPRawValue;
  size?: UPRawValue;
  bold?: UPRawValue;
  index?: UPRawValue;
  hoverClass?: UPRawValue;
  customPrefix?: UPRawValue;
  label?: UPRawValue;
  labelPos?: UPRawValue;
  labelSize?: UPRawValue;
  labelColor?: UPRawValue;
  space?: UPRawValue;
  imgMode?: UPRawValue;
  width?: UPRawValue;
  height?: UPRawValue;
  top?: UPRawValue;
  stop?: UPRawValue;
  customStyle?: UPStyleInput;
  onClick?: (index: UPRawValue) => void;
}

export class UPIconProps {
  name: UPRawValue = '';
  color: UPRawValue = 'content';
  size: UPRawValue = '16px';
  bold: UPRawValue = false;
  index: UPRawValue = '';
  hoverClass: UPRawValue = '';
  customPrefix: UPRawValue = 'uicon';
  label: UPRawValue = '';
  labelPos: UPRawValue = 'right';
  labelSize: UPRawValue = '15px';
  labelColor: UPRawValue = 'content';
  space: UPRawValue = '3px';
  imgMode: UPRawValue = '';
  width: UPRawValue = '';
  height: UPRawValue = '';
  top: UPRawValue = 0;
  stop: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  onClick?: (index: UPRawValue) => void;

  constructor(options?: UPIconOptions) {
    if (options === undefined) {
      return;
    }
    this.name = options.name ?? this.name;
    this.color = options.color ?? this.color;
    this.size = options.size ?? this.size;
    this.bold = options.bold ?? this.bold;
    this.index = options.index ?? this.index;
    this.hoverClass = options.hoverClass ?? this.hoverClass;
    this.customPrefix = options.customPrefix ?? this.customPrefix;
    this.label = options.label ?? this.label;
    this.labelPos = options.labelPos ?? this.labelPos;
    this.labelSize = options.labelSize ?? this.labelSize;
    this.labelColor = options.labelColor ?? this.labelColor;
    this.space = options.space ?? this.space;
    this.imgMode = options.imgMode ?? this.imgMode;
    this.width = options.width ?? this.width;
    this.height = options.height ?? this.height;
    this.top = options.top ?? this.top;
    this.stop = options.stop ?? this.stop;
    this.customStyle = options.customStyle;
    this.onClick = options.onClick;
  }
}

function displayValue(value: UPRawValue): string {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value);
}

function isImageSource(value: string): boolean {
  return value.includes('/') || value.startsWith('resource://');
}

function iconGlyph(name: string, customPrefix: string): string {
  if (customPrefix !== 'uicon') {
    return '';
  }
  return UPIconGlyphs.codePoint(name) ?? '';
}

@Component
export struct UPIcon {
  @Prop props: UPIconProps = new UPIconProps();

  aboutToAppear(): void {
    if (UPIconFont.registered) {
      return;
    }
    try {
      this.getUIContext().getFont().registerFont({
        familyName: UP_ICON_FONT_FAMILY,
        familySrc: $rawfile('upicon.ttf')
      });
    } catch (_) {
      // A malformed/missing optional resource must leave an empty safe fallback,
      // not prevent the rest of the component library from rendering.
    }
    UPIconFont.registered = true;
  }

  private iconName(): string {
    return upString(this.props.name, '');
  }

  private iconPrefix(): string {
    return upString(this.props.customPrefix, 'uicon');
  }

  private iconSize(): number {
    return UPUnit.parse(this.props.size, 375, 16);
  }

  private labelText(): string {
    return displayValue(this.props.label);
  }

  private labelPosition(): string {
    const position: string = upString(this.props.labelPos, 'right').toLowerCase();
    return position === 'left' || position === 'top' || position === 'bottom' ? position : 'right';
  }

  private labelSize(): number {
    return UPUnit.parse(this.props.labelSize, 375, 15);
  }

  private labelColor(): string {
    return UPColor.parse(this.props.labelColor, UP_DEFAULT_THEME);
  }

  private styleWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? 'auto';
  }

  private styleHeight(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? 'auto';
  }

  private click(): void {
    this.props.onClick?.(this.props.index);
  }

  @Builder
  private iconContent() {
    Stack() {
      if (isImageSource(this.iconName())) {
        Image(this.iconName())
          .width(UPUnit.parse(this.props.width, 375, this.iconSize()))
          .height(UPUnit.parse(this.props.height, 375, this.iconSize()))
          .objectFit(ImageFit.Contain)
      } else {
        Text(iconGlyph(this.iconName(), this.iconPrefix()))
          .fontSize(this.iconSize())
          .fontColor(UPColor.parse(this.props.color, UP_DEFAULT_THEME))
          .fontWeight(upBoolean(this.props.bold, false) ? FontWeight.Bold : FontWeight.Normal)
          .fontFamily(UP_ICON_FONT_FAMILY)
          .offset({ y: UPUnit.parse(this.props.top, 375, 0, true) })
          .id(this.iconName().length > 0 ? 'up-icon-' + this.iconName() : 'up-icon-empty')
      }
    }
  }

  @Builder
  private layout() {
    if (this.labelPosition() === 'top') {
      Column({ space: UPUnit.parse(this.props.space, 375, 3) }) {
        if (this.labelText().length > 0) {
          Text(this.labelText()).fontSize(this.labelSize()).fontColor(this.labelColor())
        }
        this.iconContent()
      }
      .onClick(() => this.click())
      .width(this.styleWidth())
      .height(this.styleHeight())
    } else if (this.labelPosition() === 'bottom') {
      Column({ space: UPUnit.parse(this.props.space, 375, 3) }) {
        this.iconContent()
        if (this.labelText().length > 0) {
          Text(this.labelText()).fontSize(this.labelSize()).fontColor(this.labelColor())
        }
      }
      .onClick(() => this.click())
      .width(this.styleWidth())
      .height(this.styleHeight())
    } else if (this.labelPosition() === 'left') {
      Row({ space: UPUnit.parse(this.props.space, 375, 3) }) {
        if (this.labelText().length > 0) {
          Text(this.labelText()).fontSize(this.labelSize()).fontColor(this.labelColor())
        }
        this.iconContent()
      }
      .onClick(() => this.click())
      .width(this.styleWidth())
      .height(this.styleHeight())
    } else {
      Row({ space: UPUnit.parse(this.props.space, 375, 3) }) {
        this.iconContent()
        if (this.labelText().length > 0) {
          Text(this.labelText()).fontSize(this.labelSize()).fontColor(this.labelColor())
        }
      }
      .onClick(() => this.click())
      .width(this.styleWidth())
      .height(this.styleHeight())
    }
  }

  build() {
    this.layout()
  }
}
