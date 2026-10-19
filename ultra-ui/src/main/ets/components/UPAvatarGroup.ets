import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPAvatar, UPAvatarProps } from './UPAvatar';
import { UPColor } from '../core/UPColor';

export interface UPAvatarGroupSource {
  src?: UPRawValue;
  url?: UPRawValue;
  avatar?: UPRawValue;
  text?: UPRawValue;
  name?: UPRawValue;
}

/** 上游 showMore 事件：点击「+N」提示时触发。/ Upstream showMore payload. */
export interface UPAvatarGroupShowMoreEvent {
  hiddenCount: number;
  total: number;
}

export interface UPAvatarGroupOptions {
  urls?: Array<UPRawValue | UPAvatarGroupSource>;
  maxCount?: UPRawValue;
  shape?: UPRawValue;
  mode?: UPRawValue;
  showMore?: UPRawValue;
  size?: UPRawValue;
  keyName?: UPRawValue;
  gap?: UPRawValue;
  extraValue?: UPRawValue;
  customStyle?: UPStyleInput;
  onShowMore?: (event: UPAvatarGroupShowMoreEvent) => void;
}

export class UPAvatarGroupProps {
  urls: Array<UPRawValue | UPAvatarGroupSource> = [];
  maxCount: UPRawValue = 5;
  shape: UPRawValue = 'circle';
  mode: UPRawValue = 'scaleToFill';
  showMore: UPRawValue = true;
  size: UPRawValue = 40;
  keyName: UPRawValue = 'url';
  gap: UPRawValue = 4;
  extraValue: UPRawValue = '';
  onShowMore?: (event: UPAvatarGroupShowMoreEvent) => void;
  customStyle: UPStyleInput = undefined;

  constructor(options?: UPAvatarGroupOptions) {
    if (options === undefined) {
      return;
    }
    this.urls = options.urls ?? this.urls;
    this.maxCount = options.maxCount ?? this.maxCount;
    this.shape = options.shape ?? this.shape;
    this.mode = options.mode ?? this.mode;
    this.showMore = options.showMore ?? this.showMore;
    this.size = options.size ?? this.size;
    this.keyName = options.keyName ?? this.keyName;
    this.gap = options.gap ?? this.gap;
    this.extraValue = options.extraValue ?? this.extraValue;
    this.onShowMore = options.onShowMore;
    this.customStyle = options.customStyle;
  }
}

class UPAvatarGroupItem {
  readonly index: number;
  readonly src: UPRawValue;
  readonly text: UPRawValue;
  readonly name: UPRawValue;

  constructor(index: number, src: UPRawValue, text: UPRawValue, name: UPRawValue) {
    this.index = index;
    this.src = src;
    this.text = text;
    this.name = name;
  }
}

function rawText(value: UPRawValue): string {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value);
}

function rawNumber(value: UPRawValue, fallback: number): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string' && Number.isFinite(Number(value.trim()))) {
    return Number(value.trim());
  }
  return fallback;
}

@Component
export struct UPAvatarGroup {
  @Prop props: UPAvatarGroupProps = new UPAvatarGroupProps();

  private maxCount(): number {
    return Math.max(0, Math.floor(rawNumber(this.props.maxCount, 5)));
  }

  private sizeValue(): number {
    return UPUnit.parse(this.props.size, 375, 40);
  }

  private items(): Array<UPAvatarGroupItem> {
    const result: Array<UPAvatarGroupItem> = [];
    const key: string = rawText(this.props.keyName).length > 0 ? rawText(this.props.keyName) : 'url';
    for (let index = 0; index < Math.min(this.props.urls.length, this.maxCount()); index += 1) {
      const item = this.props.urls[index];
      if (item !== null && item !== undefined && typeof item === 'object') {
        const source = item as UPAvatarGroupSource;
        let src: UPRawValue = source.url ?? source.src ?? source.avatar ?? '';
        if (key === 'src') {
          src = source.src ?? src;
        } else if (key === 'avatar') {
          src = source.avatar ?? src;
        }
        result.push(new UPAvatarGroupItem(index, src, source.text ?? '', source.name ?? source.text ?? ''));
      } else {
        result.push(new UPAvatarGroupItem(index, item as UPRawValue, '', item as UPRawValue));
      }
    }
    return result;
  }

  private hiddenCount(): number {
    return Math.max(0, this.props.urls.length - this.maxCount());
  }

  private groupWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? 'auto';
  }

  private groupHeight(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? 'auto';
  }

  build() {
    Row({ space: UPUnit.parse(this.props.gap, 375, 4, true) }) {
      ForEach(this.items(), (item: UPAvatarGroupItem) => {
        UPAvatar({ props: new UPAvatarProps({
          src: item.src,
          text: item.text,
          name: item.name,
          shape: this.props.shape,
          size: this.props.size,
          mode: this.props.mode,
          randomBgColor: true,
          colorIndex: item.index
        }) })
      }, (item: UPAvatarGroupItem) => String(item.index))
      if (upBoolean(this.props.showMore, true) && this.hiddenCount() > 0) {
        Stack() {
          Text('+' + String(this.hiddenCount()) + rawText(this.props.extraValue))
            .fontSize(12)
            .fontColor(UPColor.adaptive('#606266', 'content-color'))
        }
        .width(this.sizeValue())
        .height(this.sizeValue())
        .backgroundColor(UPColor.adaptive('#f3f4f6', 'bg-color'))
        .borderRadius(upString(this.props.shape, 'circle') === 'square' ? 4 : this.sizeValue() / 2)
        .onClick((): void => {
          this.props.onShowMore?.({ hiddenCount: this.hiddenCount(), total: this.props.urls.length });
        })
      }
    }
    .width(this.groupWidth())
    .height(this.groupHeight())
  }
}
