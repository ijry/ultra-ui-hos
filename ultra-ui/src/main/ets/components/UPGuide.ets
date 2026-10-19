import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';

/** 单页引导内容。/ One guide page. */
export interface UPGuideItem {
  image?: string;
  title?: string;
  desc?: string;
  backgroundColor?: string;
}

/** 「不再提示」记忆读写交由宿主实现。/ Host-provided persistence for the once flag. */
export interface UPGuideStorage {
  get(key: string): number | undefined;
  set(key: string, value: number): void;
  remove(key: string): void;
}

/** 翻页事件载荷。/ Payload of the page change event. */
export interface UPGuideChangeEvent {
  current: number;
}

/** 上游 readRemembered 的真值判定。/ Mirrors the upstream remembered check. */
export function upGuideRemembered(value: number | undefined): boolean {
  return value === 1;
}

export interface UPGuideOptions {
  show?: UPRawValue;
  list?: Array<UPGuideItem>;
  storageKey?: UPRawValue;
  once?: UPRawValue;
  showSkip?: UPRawValue;
  skipText?: UPRawValue;
  nextText?: UPRawValue;
  finishText?: UPRawValue;
  indicator?: UPRawValue;
  bgColor?: UPRawValue;
  stackLevel?: UPRawValue;
  zIndex?: UPRawValue;
  storage?: UPGuideStorage;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onShowChange?: (value: boolean) => void;
  onChange?: (event: UPGuideChangeEvent) => void;
  onSkip?: () => void;
  onFinish?: () => void;
  onClose?: () => void;
}

export class UPGuideProps {
  show: UPRawValue = false;
  list: Array<UPGuideItem> = [];
  storageKey: UPRawValue = 'up-guide-default';
  once: UPRawValue = true;
  showSkip: UPRawValue = true;
  skipText: UPRawValue = '跳过';
  nextText: UPRawValue = '下一步';
  finishText: UPRawValue = '立即体验';
  indicator: UPRawValue = true;
  bgColor: UPRawValue = '#111111';
  stackLevel: UPRawValue = 10075;
  zIndex: UPRawValue = 10075;
  storage?: UPGuideStorage;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onShowChange?: (value: boolean) => void;
  onChange?: (event: UPGuideChangeEvent) => void;
  onSkip?: () => void;
  onFinish?: () => void;
  onClose?: () => void;

  constructor(options?: UPGuideOptions) {
    if (options === undefined) {
      return;
    }
    this.show = options.show ?? this.show;
    this.list = options.list ?? this.list;
    this.storageKey = options.storageKey ?? this.storageKey;
    this.once = options.once ?? this.once;
    this.showSkip = options.showSkip ?? this.showSkip;
    this.skipText = options.skipText ?? this.skipText;
    this.nextText = options.nextText ?? this.nextText;
    this.finishText = options.finishText ?? this.finishText;
    this.indicator = options.indicator ?? this.indicator;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.stackLevel = options.stackLevel ?? this.stackLevel;
    this.zIndex = options.zIndex ?? this.zIndex;
    this.storage = options.storage;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onShowChange = options.onShowChange;
    this.onChange = options.onChange;
    this.onSkip = options.onSkip;
    this.onFinish = options.onFinish;
    this.onClose = options.onClose;
  }
}

function isLocalGuideImage(value: string): boolean {
  return value.startsWith('resource://') || value.startsWith('file://') || value.startsWith('/') || value.startsWith('$rawfile:');
}

@Component
export struct UPGuide {
  @Prop @Watch('applyShow') props: UPGuideProps = new UPGuideProps();
  @State private innerShow: boolean = false;
  @State private current: number = 0;
  private appliedShow: boolean = false;
  private closing: boolean = false;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (this.props.list.length === 0) {
      diagnostics.report('UPGuide', 'list', null, 'the guide needs at least one page; nothing is rendered');
    }
    if (upBoolean(this.props.once, true) && this.props.storage === undefined) {
      diagnostics.report('UPGuide', 'storage', null, 'uni.getStorageSync is unavailable; supply a UPGuideStorage to persist the once flag');
    }
    this.bootstrap();
  }

  /** 对应上游 bootstrap：once 且已记忆时直接不展示。/ Mirrors the upstream bootstrap. */
  private bootstrap(): void {
    const requested: boolean = upBoolean(this.props.show, false);
    this.appliedShow = requested;
    if (this.props.list.length === 0) {
      this.innerShow = false;
      return;
    }
    if (upBoolean(this.props.once, true) && this.remembered()) {
      this.innerShow = false;
      if (requested) {
        this.emitShowChange(false);
      }
      return;
    }
    this.innerShow = requested;
  }

  private remembered(): boolean {
    const storage: UPGuideStorage | undefined = this.props.storage;
    if (storage === undefined) {
      return false;
    }
    return upGuideRemembered(storage.get(upString(this.props.storageKey, 'up-guide-default')));
  }

  private remember(): void {
    const storage: UPGuideStorage | undefined = this.props.storage;
    if (storage === undefined) {
      return;
    }
    storage.set(upString(this.props.storageKey, 'up-guide-default'), 1);
  }

  /** 清除记忆，便于宿主重新展示引导。/ Clears the remembered flag. */
  private forget(): void {
    const storage: UPGuideStorage | undefined = this.props.storage;
    if (storage === undefined) {
      return;
    }
    storage.remove(upString(this.props.storageKey, 'up-guide-default'));
  }

  private applyShow(): void {
    const next: boolean = upBoolean(this.props.show, false);
    if (next === this.appliedShow) {
      return;
    }
    this.appliedShow = next;
    if (next) {
      if (upBoolean(this.props.once, true) && this.remembered()) {
        this.innerShow = false;
        this.emitShowChange(false);
        return;
      }
      this.current = 0;
      this.closing = false;
      this.innerShow = this.props.list.length > 0;
      return;
    }
    this.innerShow = false;
  }

  private emitShowChange(value: boolean): void {
    const callback: ((value: boolean) => void) | undefined = this.props.onShowChange;
    if (callback !== undefined) {
      callback(value);
    }
  }

  private pageIndexes(): Array<number> {
    const values: Array<number> = [];
    const total: number = this.props.list.length;
    for (let index: number = 0; index < total; index++) {
      values.push(index);
    }
    return values;
  }

  private lastPage(): boolean {
    return this.current >= this.props.list.length - 1;
  }

  private handleSwiperChange(index: number): void {
    if (index === this.current) {
      return;
    }
    this.current = index;
    const change: ((event: UPGuideChangeEvent) => void) | undefined = this.props.onChange;
    if (change !== undefined) {
      change({ current: index });
    }
  }

  /** 末页发 finish 并关闭，否则前进一页。/ Advances or finishes the guide. */
  private handlePrimaryAction(): void {
    if (this.lastPage()) {
      const finish: (() => void) | undefined = this.props.onFinish;
      if (finish !== undefined) {
        finish();
      }
      this.closeGuide(true);
      return;
    }
    this.current = this.current + 1;
    const change: ((event: UPGuideChangeEvent) => void) | undefined = this.props.onChange;
    if (change !== undefined) {
      change({ current: this.current });
    }
  }

  private handleSkip(): void {
    const skip: (() => void) | undefined = this.props.onSkip;
    if (skip !== undefined) {
      skip();
    }
    this.closeGuide(true);
  }

  private closeGuide(remember: boolean): void {
    if (this.closing) {
      return;
    }
    this.closing = true;
    if (remember && upBoolean(this.props.once, true)) {
      this.remember();
    }
    this.innerShow = false;
    this.appliedShow = false;
    this.emitShowChange(false);
    const close: (() => void) | undefined = this.props.onClose;
    if (close !== undefined) {
      close();
    }
    this.closing = false;
  }

  private surfaceColor(index: number): string {
    const item: UPGuideItem = this.props.list[index];
    const requested: string = item.backgroundColor ?? '';
    if (requested.length > 0) {
      return UPColor.parse(requested, UP_DEFAULT_THEME, '#111111');
    }
    return UPColor.parse(upString(this.props.bgColor, '#111111'), UP_DEFAULT_THEME, '#111111');
  }

  /** `zIndex` 是上游名，`stackLevel` 为本端别名，两者取显式设置的那个。/ zIndex is upstream, stackLevel is the local alias. */
  private stackZIndex(): number {
    const level: number = Math.floor(upNumber(this.props.stackLevel, 10075));
    if (level !== 10075) {
      return level;
    }
    return Math.floor(upNumber(this.props.zIndex, 10075));
  }

  private rpx(value: number): number {
    return UPUnit.parse(`${value}rpx`, 375, value / 2);
  }

  @Builder
  private pageContent(index: number) {
    Column() {
      if (isLocalGuideImage(this.props.list[index].image ?? '')) {
        Image(this.props.list[index].image ?? '')
          .width(this.rpx(560))
          .height(this.rpx(560))
          .borderRadius(this.rpx(24))
          .objectFit(ImageFit.Contain)
      } else {
        Column() {
          Text('暂无引导图').fontSize(this.rpx(28)).fontColor('#ffffff').opacity(0.85)
        }
        .width(this.rpx(560))
        .height(this.rpx(560))
        .borderRadius(this.rpx(24))
        .backgroundColor('rgba(255, 255, 255, 0.12)')
        .justifyContent(FlexAlign.Center)
      }
      Text(this.props.list[index].title ?? '')
        .fontSize(this.rpx(40))
        .fontWeight(FontWeight.Medium)
        .fontColor('#ffffff')
        .margin({ top: this.rpx(48) })
      Text(this.props.list[index].desc ?? '')
        .fontSize(this.rpx(28))
        .fontColor('#ffffff')
        .opacity(0.85)
        .margin({ top: this.rpx(18) })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.rpx(120), left: this.rpx(40), right: this.rpx(40), bottom: this.rpx(40) })
    .backgroundColor(this.surfaceColor(index))
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private dots() {
    Row() {
      ForEach(this.pageIndexes(), (index: number) => {
        Row()
          .width(index === this.current ? this.rpx(34) : this.rpx(14))
          .height(this.rpx(14))
          .borderRadius(this.rpx(7))
          .margin({ left: this.rpx(6), right: this.rpx(6) })
          .backgroundColor(index === this.current ? '#ffffff' : 'rgba(255, 255, 255, 0.35)')
      }, (index: number) => `dot-${index}`)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }

  @Builder
  private footer() {
    Column() {
      if (upBoolean(this.props.indicator, true)) {
        this.dots()
      }
      Row() {
        if (upBoolean(this.props.showSkip, true) && !this.lastPage()) {
          Text(upString(this.props.skipText, '跳过'))
            .layoutWeight(1)
            .height(this.rpx(84))
            .borderRadius(this.rpx(42))
            .borderWidth(this.rpx(2))
            .borderColor('rgba(255, 255, 255, 0.42)')
            .fontSize(this.rpx(28))
            .fontColor('#ffffff')
            .textAlign(TextAlign.Center)
            .margin({ right: this.rpx(20) })
            .onClick((): void => this.handleSkip())
        }
        Text(this.lastPage() ? upString(this.props.finishText, '立即体验') : upString(this.props.nextText, '下一步'))
          .layoutWeight(1)
          .height(this.rpx(84))
          .borderRadius(this.rpx(42))
          .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
          .fontSize(this.rpx(28))
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
          .textAlign(TextAlign.Center)
          .onClick((): void => this.handlePrimaryAction())
      }
      .width('100%')
      .margin({ top: this.rpx(24) })
    }
    .width('100%')
    .padding({ top: this.rpx(24), left: this.rpx(32), right: this.rpx(32), bottom: this.rpx(24) })
    .backgroundColor(this.surfaceColor(Math.min(this.current, Math.max(0, this.props.list.length - 1))))
  }

  build() {
    Column() {
      if (this.innerShow && this.props.list.length > 0) {
        Swiper() {
          ForEach(this.pageIndexes(), (index: number) => {
            this.pageContent(index)
          }, (index: number) => `page-${index}`)
        }
        .index(this.current)
        .autoPlay(false)
        .loop(false)
        .indicator(false)
        .layoutWeight(1)
        .width('100%')
        .onChange((index: number): void => this.handleSwiperChange(index))
        this.footer()
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(this.innerShow && this.props.list.length > 0 ? (UPStyle.parse(this.props.customStyle).height ?? '100%') : 0)
    .zIndex(this.stackZIndex())
    .visibility(this.innerShow && this.props.list.length > 0 ? Visibility.Visible : Visibility.None)
  }
}
