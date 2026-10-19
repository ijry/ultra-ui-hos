import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPImage, UPImageProps } from './UPImage';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPSwiperItem {
  name?: UPRawValue;
  title?: UPRawValue;
  text?: UPRawValue;
  image?: UPRawValue;
  src?: UPRawValue;
  value?: UPRawValue;
  url?: UPRawValue;
  linkType?: UPRawValue;
  bgColor?: UPRawValue;
  color?: UPRawValue;
  disabled?: UPRawValue;
}

export interface UPSwiperChangeEvent {
  index: number;
  item: UPSwiperItem;
  source: string;
}

export interface UPSwiperClickEvent {
  index: number;
  item: UPSwiperItem;
  url: UPRawValue;
  linkType: UPRawValue;
}

export interface UPSwiperOptions {
  list?: Array<UPSwiperItem>;
  current?: UPRawValue;
  indicator?: UPRawValue;
  autoplay?: UPRawValue;
  autoPlay?: UPRawValue;
  interval?: UPRawValue;
  circular?: UPRawValue;
  loop?: UPRawValue;
  vertical?: UPRawValue;
  height?: UPRawValue;
  width?: UPRawValue;
  backgroundColor?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  onChange?: (event: UPSwiperChangeEvent) => void;
  onClick?: (event: UPSwiperClickEvent) => void;
  onCurrentChange?: (current: number) => void;
  indicatorBuilder?: UPBuilder;
}

export class UPSwiperProps {
  list: Array<UPSwiperItem> = [];
  current: UPRawValue = 0;
  indicator: UPRawValue = false;
  autoplay: UPRawValue = true;
  autoPlay: UPRawValue = true;
  interval: UPRawValue = 3000;
  circular: UPRawValue = true;
  loop: UPRawValue = true;
  vertical: UPRawValue = false;
  height: UPRawValue = 180;
  width: UPRawValue = '100%';
  backgroundColor: UPRawValue = '#f3f4f6';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  onChange?: (event: UPSwiperChangeEvent) => void;
  onClick?: (event: UPSwiperClickEvent) => void;
  onCurrentChange?: (current: number) => void;
  indicatorBuilder?: UPBuilder;

  constructor(options?: UPSwiperOptions) {
    if (options === undefined) return;
    this.list = options.list ?? this.list;
    this.current = options.current ?? this.current;
    this.indicator = options.indicator ?? this.indicator;
    this.autoplay = options.autoplay ?? this.autoplay;
    this.autoPlay = options.autoPlay ?? this.autoPlay;
    this.interval = options.interval ?? this.interval;
    this.circular = options.circular ?? this.circular;
    this.loop = options.loop ?? this.loop;
    this.vertical = options.vertical ?? this.vertical;
    this.height = options.height ?? this.height;
    this.width = options.width ?? this.width;
    this.backgroundColor = options.backgroundColor ?? this.backgroundColor;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.onChange = options.onChange;
    this.onCurrentChange = options.onCurrentChange;
    this.onClick = options.onClick;
    this.indicatorBuilder = options.indicatorBuilder;
  }
}

@Component
export struct UPSwiper {
  @Prop props: UPSwiperProps = new UPSwiperProps();

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private textValue(value: UPRawValue): string {
    return value === null || value === undefined ? '' : String(value);
  }

  private numberValue(value: UPRawValue, fallback: number): number {
    if (typeof value === 'number' && Number.isFinite(value)) return value;
    if (typeof value === 'string' && Number.isFinite(Number(value.trim()))) return Number(value.trim());
    return fallback;
  }

  private itemIndexes(): Array<number> {
    return this.props.list.map((_item: UPSwiperItem, index: number): number => index);
  }

  private currentIndex(): number {
    if (this.props.list.length === 0) return 0;
    const requested: number = Math.floor(this.numberValue(this.props.current, 0));
    return Math.max(0, Math.min(this.props.list.length - 1, requested));
  }

  private swiperWidth(): number | string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.width !== undefined) return style.width;
    if (typeof this.props.width === 'string' && this.props.width.trim().endsWith('%')) return this.props.width.trim();
    const parsed: number = UPUnit.parse(this.props.width, 375, Number.NaN);
    return Number.isFinite(parsed) ? parsed : '100%';
  }

  private swiperHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return Math.max(1, style.height ?? UPUnit.parse(this.props.height, 375, 180));
  }

  private swiperBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background
      ?? UPColor.parse(this.props.backgroundColor, UP_DEFAULT_THEME, UPColor.adaptive('#f3f4f6', 'bg-color'));
  }

  private slideColor(item: UPSwiperItem): string {
    return UPColor.parse(item.color, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color'));
  }

  private slideBackground(item: UPSwiperItem): string {
    return UPColor.parse(item.bgColor, UP_DEFAULT_THEME, this.swiperBackground());
  }

  private imageSource(item: UPSwiperItem): string {
    const value: UPRawValue = item.image ?? item.src;
    return this.textValue(value);
  }

  private slideTitle(item: UPSwiperItem): string {
    return this.textValue(item.title ?? item.name ?? item.text);
  }

  private slideText(item: UPSwiperItem): string {
    return this.textValue(item.text);
  }

  private handleChange(index: number): void {
    if (index < 0 || index >= this.props.list.length) return;
    this.props.onChange?.({ index, item: this.props.list[index], source: 'native' });
    /** 上游 `update:current` 只回传下标。/ Upstream update:current carries the index only. */
    this.props.onCurrentChange?.(index);
  }

  private handleClick(index: number): void {
    if (index < 0 || index >= this.props.list.length) return;
    const item: UPSwiperItem = this.props.list[index];
    if (upBoolean(item.disabled, false)) return;
    this.props.onClick?.({ index, item, url: item.url, linkType: item.linkType });
  }

  @Builder
  private slide(index: number) {
    Stack() {
      if (this.imageSource(this.props.list[index]).length > 0) {
        UPImage({ props: new UPImageProps({
          src: this.imageSource(this.props.list[index]),
          width: this.swiperWidth(),
          height: this.swiperHeight(),
          showLoading: false,
          showError: true,
          bgColor: this.slideBackground(this.props.list[index])
        }) })
      } else {
        Column({ space: 8 }) {
          Text(this.slideTitle(this.props.list[index]))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.slideColor(this.props.list[index]))
          if (this.slideText(this.props.list[index]).length > 0) {
            Text(this.slideText(this.props.list[index]))
              .fontSize(14)
              .fontColor(this.slideColor(this.props.list[index]))
              .textAlign(TextAlign.Center)
          }
          this.contentBuilder()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .padding(20)
      }
      if (this.slideTitle(this.props.list[index]).length > 0 && this.imageSource(this.props.list[index]).length > 0) {
        Text(this.slideTitle(this.props.list[index]))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#66000000')
          .borderRadius(6)
          .alignSelf(ItemAlign.End)
          .margin({ bottom: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.slideBackground(this.props.list[index]))
    .borderRadius(8)
    .clip(true)
    .opacity(upBoolean(this.props.list[index].disabled, false) ? 0.5 : 1)
    .onClick(() => this.handleClick(index))
  }

  @Builder
  private swiperContent() {
    if (this.props.list.length === 0) {
      Column() {
        Text('暂无轮播内容').fontSize(14).fontColor(UPColor.adaptive('#909399', 'tips-color'))
      }.width(this.swiperWidth()).height(this.swiperHeight()).justifyContent(FlexAlign.Center).backgroundColor(this.swiperBackground())
    } else {
      Swiper() {
        ForEach(this.itemIndexes(), (index: number) => {
          this.slide(index)
        }, (index: number) => String(index))
      }
      .index(this.currentIndex())
      .autoPlay(upBoolean(this.props.autoplay, upBoolean(this.props.autoPlay, true)))
      .interval(Math.max(100, Math.floor(this.numberValue(this.props.interval, 3000))))
      .indicator(upBoolean(this.props.indicator, false))
      .loop(upBoolean(this.props.circular, upBoolean(this.props.loop, true)))
      .vertical(upBoolean(this.props.vertical, false))
      .width(this.swiperWidth())
      .height(this.swiperHeight())
      .backgroundColor(this.swiperBackground())
      .onChange((index: number): void => this.handleChange(index))
      this.indicatorRegion()
    }
  }

  @Builder
  private indicatorRegion() {
    UPSlotRegion({ contentBuilder: this.props.indicatorBuilder })
  }

  build() {
    this.swiperContent()
  }
}
