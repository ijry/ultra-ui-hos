import { UPRawValue, UPStyleInput, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPSwiperIndicatorClickEvent {
  index: number;
}

export interface UPSwiperIndicatorOptions {
  current?: UPRawValue;
  count?: UPRawValue;
  mode?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
  size?: UPRawValue;
  space?: UPRawValue;
  customStyle?: UPStyleInput;
  onClick?: (event: UPSwiperIndicatorClickEvent) => void;
}

export class UPSwiperIndicatorProps {
  current: UPRawValue = 0;
  count: UPRawValue = 0;
  mode: UPRawValue = 'line';
  activeColor: UPRawValue = '#2979ff';
  inactiveColor: UPRawValue = '#c0c4cc';
  size: UPRawValue = 8;
  space: UPRawValue = 6;
  customStyle: UPStyleInput = undefined;
  onClick?: (event: UPSwiperIndicatorClickEvent) => void;

  constructor(options?: UPSwiperIndicatorOptions) {
    if (options === undefined) return;
    this.current = options.current ?? this.current;
    this.count = options.count ?? this.count;
    this.mode = options.mode ?? this.mode;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor;
    this.size = options.size ?? this.size;
    this.space = options.space ?? this.space;
    this.customStyle = options.customStyle;
    this.onClick = options.onClick;
  }
}

@Component
export struct UPSwiperIndicator {
  @Prop props: UPSwiperIndicatorProps = new UPSwiperIndicatorProps();

  private numberValue(value: UPRawValue, fallback: number): number {
    if (typeof value === 'number' && Number.isFinite(value)) return value;
    if (typeof value === 'string' && Number.isFinite(Number(value.trim()))) return Number(value.trim());
    return fallback;
  }

  private safeCount(): number {
    return Math.max(0, Math.floor(this.numberValue(this.props.count, 0)));
  }

  private safeCurrent(): number {
    return Math.max(0, Math.min(Math.max(0, this.safeCount() - 1), Math.floor(this.numberValue(this.props.current, 0))));
  }

  private itemIndexes(): Array<number> {
    const indexes: Array<number> = [];
    for (let index = 0; index < this.safeCount(); index += 1) indexes.push(index);
    return indexes;
  }

  private indicatorMode(): string {
    const mode: string = upString(this.props.mode, 'line').toLowerCase();
    return mode === 'dot' || mode === 'number' ? mode : 'line';
  }

  private activeColor(): string {
    return UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#2979ff');
  }

  private inactiveColor(): string {
    return UPColor.parse(this.props.inactiveColor, UP_DEFAULT_THEME, UPColor.neutral('light', '#c0c4cc'));
  }

  private baseSize(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(3, style.height ?? UPUnit.parse(this.props.size, 375, 8));
  }

  private gap(): number {
    return Math.max(0, UPUnit.parse(this.props.space, 375, 6));
  }

  private handleClick(index: number): void {
    this.props.onClick?.({ index });
  }

  @Builder
  private item(index: number) {
    if (this.indicatorMode() === 'dot') {
      Column()
        .width(index === this.safeCurrent() ? this.baseSize() * 2 : this.baseSize())
        .height(this.baseSize())
        .borderRadius(this.baseSize() / 2)
        .backgroundColor(index === this.safeCurrent() ? this.activeColor() : this.inactiveColor())
        .onClick(() => this.handleClick(index))
    } else {
      Column()
        .width(index === this.safeCurrent() ? this.baseSize() * 2.5 : this.baseSize())
        .height(Math.max(3, this.baseSize() / 2))
        .borderRadius(this.baseSize())
        .backgroundColor(index === this.safeCurrent() ? this.activeColor() : this.inactiveColor())
        .onClick(() => this.handleClick(index))
    }
  }

  build() {
    if (this.indicatorMode() === 'number') {
      Text(String(this.safeCurrent() + 1) + '/' + String(this.safeCount()))
        .fontSize(13)
        .fontColor(this.activeColor())
    } else {
      Row({ space: this.gap() }) {
        ForEach(this.itemIndexes(), (index: number) => {
          this.item(index)
        }, (index: number) => String(index))
      }
      .width('auto')
      .height(this.baseSize())
    }
  }
}
