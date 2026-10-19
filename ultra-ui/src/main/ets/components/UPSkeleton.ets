import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPSkeletonOptions {
  loading?: UPRawValue;
  rows?: UPRawValue;
  title?: UPRawValue;
  avatar?: UPRawValue;
  avatarShape?: UPRawValue;
  avatarSize?: UPRawValue;
  titleWidth?: UPRawValue;
  rowWidth?: UPRawValue | Array<UPRawValue>;
  rowHeight?: UPRawValue;
  animate?: UPRawValue;
  bgColor?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

export class UPSkeletonProps {
  loading: UPRawValue = true;
  rows: UPRawValue = 3;
  title: UPRawValue = true;
  avatar: UPRawValue = false;
  avatarShape: UPRawValue = 'circle';
  avatarSize: UPRawValue = 32;
  titleWidth: UPRawValue = '40%';
  rowWidth: UPRawValue | Array<UPRawValue> = '100%';
  rowHeight: UPRawValue = 16;
  animate: UPRawValue = true;
  bgColor: UPRawValue = '#f2f3f5';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPSkeletonOptions) {
    if (options === undefined) {
      return;
    }
    this.loading = options.loading ?? this.loading;
    this.rows = options.rows ?? this.rows;
    this.title = options.title ?? this.title;
    this.avatar = options.avatar ?? this.avatar;
    this.avatarShape = options.avatarShape ?? this.avatarShape;
    this.avatarSize = options.avatarSize ?? this.avatarSize;
    this.titleWidth = options.titleWidth ?? this.titleWidth;
    this.rowWidth = options.rowWidth ?? this.rowWidth;
    this.rowHeight = options.rowHeight ?? this.rowHeight;
    this.animate = options.animate ?? this.animate;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPSkeleton {
  @Prop props: UPSkeletonProps = new UPSkeletonProps();

  private rows(): Array<number> {
    const count: number = Math.max(0, Math.min(12, Math.floor(upNumber(this.props.rows, 3))));
    const rows: Array<number> = [];
    for (let index = 0; index < count; index += 1) {
      rows.push(index);
    }
    return rows;
  }

  private fill(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background
      ?? UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, UPColor.adaptive('#f2f3f5', 'skeleton-bg-color'));
  }

  private widthValue(value: UPRawValue, fallback: number | string): number | string {
    if (typeof value === 'string' && value.trim().endsWith('%')) {
      return value.trim();
    }
    const parsed: number = UPUnit.parse(value, 375, Number.NaN);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  private rowWidth(index: number): number | string {
    if (Array.isArray(this.props.rowWidth)) {
      const value: UPRawValue = this.props.rowWidth[Math.min(index, this.props.rowWidth.length - 1)];
      return this.widthValue(value, '100%');
    }
    if (index === this.rows().length - 1 && this.props.rowWidth === '100%') {
      return '70%';
    }
    return this.widthValue(this.props.rowWidth as UPRawValue, '100%');
  }

  @Builder
  private bar(width: number | string, height: number, radius: number) {
    Column()
      .width(width)
      .height(height)
      .backgroundColor(this.fill())
      .borderRadius(radius)
      .opacity(upBoolean(this.props.animate, true) ? 0.92 : 1)
  }

  @Builder
  private skeletonContent() {
    Row({ space: 12 }) {
      if (upBoolean(this.props.avatar, false)) {
        this.bar(UPUnit.parse(this.props.avatarSize, 375, 32), UPUnit.parse(this.props.avatarSize, 375, 32),
          upString(this.props.avatarShape, 'circle') === 'square' ? 4 : 100)
      }
      Column({ space: 10 }) {
        if (upBoolean(this.props.title, true)) {
          this.bar(this.widthValue(this.props.titleWidth, '40%'), UPUnit.parse(this.props.rowHeight, 375, 16), 4)
        }
        ForEach(this.rows(), (row: number) => {
          this.bar(this.rowWidth(row), UPUnit.parse(this.props.rowHeight, 375, 16), 4)
        }, (row: number) => String(row))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }


  build() {
    if (!upBoolean(this.props.loading, true)) {
      this.slotRegion()
    } else {
      this.skeletonContent()
    }
  }
}
