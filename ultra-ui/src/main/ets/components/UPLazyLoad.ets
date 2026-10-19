import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';

/** 上游 mounted 后延时 30ms 建立观察器并起动画。/ Upstream waits 30ms before observing. */
export const UP_LAZY_LOAD_EFFECT_DELAY: number = 30;

/** 上游 loadStatus 初始态。/ Upstream initial loadStatus. */
export const UP_LAZY_LOAD_STATUS_INITIAL: string = '';

/** 上游 loadStatus 已进入懒加载区。/ Upstream lazyed loadStatus. */
export const UP_LAZY_LOAD_STATUS_LAZYED: string = 'lazyed';

/** 上游 loadStatus 真实图片已加载。/ Upstream loaded loadStatus. */
export const UP_LAZY_LOAD_STATUS_LOADED: string = 'loaded';

/** 懒加载事件载荷，index 与上游一致原样回传。/ Payload carrying the upstream index. */
export interface UPLazyLoadEvent {
  index: UPRawValue;
}

/**
 * 上游 getThreshold()：先取绝对值按 rpx 换算再还原符号。
 * Mirrors upstream getThreshold(): convert the absolute rpx value, then restore the sign.
 */
export function upLazyLoadThreshold(value: UPRawValue, viewportWidth: number = 375): number {
  const raw: number = typeof value === 'number' ? value : Number(upString(value, '0'));
  const numeric: number = Number.isFinite(raw) ? raw : 0;
  const magnitude: number = Math.abs(numeric);
  const converted: number = UPUnit.parse(`${magnitude}rpx`, viewportWidth, magnitude / 2);
  return numeric < 0 ? -converted : converted;
}

/** effect 白名单，覆盖上游可用的 CSS 时间函数。/ Whitelist of upstream timing functions. */
export function upLazyLoadEffectSupported(effect: string): boolean {
  return effect === 'linear' || effect === 'ease' || effect === 'ease-in'
    || effect === 'ease-out' || effect === 'ease-in-out';
}

/** effect 到 ArkUI Curve 的映射，白名单外回落 EaseInOut。/ Maps effect to Curve. */
export function upLazyLoadEffectCurve(effect: string): Curve {
  if (effect === 'linear') {
    return Curve.Linear;
  }
  if (effect === 'ease') {
    return Curve.Ease;
  }
  if (effect === 'ease-in') {
    return Curve.EaseIn;
  }
  if (effect === 'ease-out') {
    return Curve.EaseOut;
  }
  return Curve.EaseInOut;
}

/** imgMode 到 ImageFit 的映射。/ Maps the upstream imgMode to ImageFit. */
export function upLazyLoadFit(mode: string): ImageFit {
  const value: string = mode.toLowerCase();
  if (value === 'widthfix' || value === 'heightfix' || value === 'aspectfit') {
    return ImageFit.Contain;
  }
  if (value === 'scaletofill') {
    return ImageFit.Fill;
  }
  return ImageFit.Cover;
}

/** 上游 loadStatus 状态机：'' → lazyed → loaded。/ Upstream loadStatus machine. */
export function upLazyLoadNextStatus(status: string): string {
  if (status === UP_LAZY_LOAD_STATUS_INITIAL) {
    return UP_LAZY_LOAD_STATUS_LAZYED;
  }
  if (status === UP_LAZY_LOAD_STATUS_LAZYED) {
    return UP_LAZY_LOAD_STATUS_LOADED;
  }
  return status;
}

/** 只渲染本地图片，网络地址一律占位。/ Only local sources are rendered. */
export function isLocalLazyLoadSource(value: string): boolean {
  return value.startsWith('resource://') || value.startsWith('file://')
    || value.startsWith('/') || value.startsWith('$rawfile:');
}

export interface UPLazyLoadOptions {
  index?: UPRawValue;
  image?: UPRawValue;
  imgMode?: UPRawValue;
  loadingImg?: UPRawValue;
  errorImg?: UPRawValue;
  threshold?: UPRawValue;
  duration?: UPRawValue;
  effect?: UPRawValue;
  isEffect?: UPRawValue;
  borderRadius?: UPRawValue;
  height?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (event: UPLazyLoadEvent) => void;
  onLoad?: (event: UPLazyLoadEvent) => void;
  onError?: (event: UPLazyLoadEvent) => void;
}

export class UPLazyLoadProps {
  index: UPRawValue = '';
  image: UPRawValue = '';
  imgMode: UPRawValue = 'widthFix';
  loadingImg: UPRawValue = '';
  errorImg: UPRawValue = '';
  threshold: UPRawValue = 100;
  duration: UPRawValue = 500;
  effect: UPRawValue = 'ease-in-out';
  isEffect: UPRawValue = true;
  borderRadius: UPRawValue = 0;
  height: UPRawValue = '200';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onClick?: (event: UPLazyLoadEvent) => void;
  onLoad?: (event: UPLazyLoadEvent) => void;
  onError?: (event: UPLazyLoadEvent) => void;

  constructor(options?: UPLazyLoadOptions) {
    if (options === undefined) {
      return;
    }
    this.index = options.index ?? this.index;
    this.image = options.image ?? this.image;
    this.imgMode = options.imgMode ?? this.imgMode;
    this.loadingImg = options.loadingImg ?? this.loadingImg;
    this.errorImg = options.errorImg ?? this.errorImg;
    this.threshold = options.threshold ?? this.threshold;
    this.duration = options.duration ?? this.duration;
    this.effect = options.effect ?? this.effect;
    this.isEffect = options.isEffect ?? this.isEffect;
    this.borderRadius = options.borderRadius ?? this.borderRadius;
    this.height = options.height ?? this.height;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
    this.onLoad = options.onLoad;
    this.onError = options.onError;
  }
}

@Component
export struct UPLazyLoad {
  @Prop @Watch('applyImage') props: UPLazyLoadProps = new UPLazyLoadProps();
  @State private revealed: boolean = false;
  @State private failed: boolean = false;
  @State private loadStatus: string = UP_LAZY_LOAD_STATUS_INITIAL;
  @State private frameOpacity: number = 1;
  @State private frameDuration: number = 0;
  private appliedImage: string = '';
  private effectTimer: number = -1;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    const effect: string = upString(this.props.effect, 'ease-in-out');
    if (!upLazyLoadEffectSupported(effect)) {
      diagnostics.report('UPLazyLoad', 'effect', this.props.effect, 'effect must be linear/ease/ease-in/ease-out/ease-in-out; fallback to ease-in-out');
    }
    if (upNumber(this.props.threshold, 100) !== 0) {
      diagnostics.report('UPLazyLoad', 'threshold', this.props.threshold, 'onVisibleAreaChange has no viewport offset; the preload distance is reported by upLazyLoadThreshold() but not applied');
    }
    const source: string = this.sourceValue();
    this.appliedImage = source;
    if (source.length === 0) {
      this.failed = true;
    } else if (!isLocalLazyLoadSource(source)) {
      diagnostics.report('UPLazyLoad', 'image', this.props.image, 'only local sources are rendered; remote images stay a placeholder');
    }
  }

  aboutToDisappear(): void {
    this.clearEffectTimer();
  }

  /** image 变更后重置状态，空值直接进入错误态。/ Resets on image change. */
  private applyImage(): void {
    const source: string = this.sourceValue();
    if (source === this.appliedImage) {
      return;
    }
    this.appliedImage = source;
    this.loadStatus = UP_LAZY_LOAD_STATUS_INITIAL;
    if (source.length === 0) {
      this.failed = true;
      return;
    }
    this.failed = false;
    if (this.revealed) {
      this.loadStatus = UP_LAZY_LOAD_STATUS_LAZYED;
      this.startEffect();
    }
  }

  private sourceValue(): string {
    return upString(this.props.image, '').trim();
  }

  private placeholderSource(): string {
    return upString(this.props.loadingImg, '').trim();
  }

  private errorSource(): string {
    return upString(this.props.errorImg, '').trim();
  }

  private boxHeight(): number {
    return Math.max(0, UPUnit.parse(this.props.height, 375, 200));
  }

  private cornerRadius(): number {
    const value: UPRawValue = this.props.borderRadius;
    const amount: number = typeof value === 'number' ? value : Number(upString(value, '0'));
    const numeric: number = Number.isFinite(amount) && amount > 0 ? amount : 0;
    return UPUnit.parse(`${numeric}rpx`, 375, numeric / 2);
  }

  private durationValue(): number {
    const value: UPRawValue = this.props.duration;
    const amount: number = typeof value === 'number' ? value : Number(upString(value, '500'));
    return Number.isFinite(amount) && amount >= 0 ? amount : 500;
  }

  private curveValue(): Curve {
    return upLazyLoadEffectCurve(upString(this.props.effect, 'ease-in-out'));
  }

  private fitValue(): ImageFit {
    return upLazyLoadFit(upString(this.props.imgMode, 'widthFix'));
  }

  /** 可视比例大于 0 时进入懒加载区，与上游 intersectionRatio > 0 一致。/ Mirrors intersectionRatio > 0. */
  private handleVisibleChange(ratio: number): void {
    if (this.revealed || ratio <= 0) {
      return;
    }
    this.reveal();
  }

  private reveal(): void {
    this.revealed = true;
    if (this.sourceValue().length === 0) {
      this.failed = true;
      return;
    }
    this.loadStatus = UP_LAZY_LOAD_STATUS_LAZYED;
    this.startEffect();
  }

  /** 上游 isShow watch：先归零再回到 1，形成淡入。/ Mirrors the upstream fade-in. */
  private startEffect(): void {
    if (!upBoolean(this.props.isEffect, true)) {
      this.frameDuration = 0;
      this.frameOpacity = 1;
      return;
    }
    this.clearEffectTimer();
    this.frameDuration = 0;
    this.frameOpacity = 0;
    this.effectTimer = setTimeout((): void => {
      this.effectTimer = -1;
      this.frameDuration = this.durationValue();
      this.frameOpacity = 1;
    }, UP_LAZY_LOAD_EFFECT_DELAY);
  }

  private clearEffectTimer(): void {
    if (this.effectTimer !== -1) {
      clearTimeout(this.effectTimer);
      this.effectTimer = -1;
    }
  }

  private handleComplete(): void {
    const next: string = upLazyLoadNextStatus(this.loadStatus);
    if (next === this.loadStatus) {
      return;
    }
    this.loadStatus = next;
    if (next !== UP_LAZY_LOAD_STATUS_LOADED) {
      return;
    }
    const load: ((event: UPLazyLoadEvent) => void) | undefined = this.props.onLoad;
    if (load !== undefined) {
      load({ index: this.props.index });
    }
  }

  private handleError(): void {
    this.failed = true;
    const error: ((event: UPLazyLoadEvent) => void) | undefined = this.props.onError;
    if (error !== undefined) {
      error({ index: this.props.index });
    }
  }

  private handleClick(): void {
    const click: ((event: UPLazyLoadEvent) => void) | undefined = this.props.onClick;
    if (click !== undefined) {
      click({ index: this.props.index });
    }
  }

  @Builder
  private placeholderText(text: string) {
    Text(text)
      .fontSize(12)
      .fontColor(UPColor.adaptive('#c0c4cc', 'light-color'))
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
  }

  @Builder
  private frame() {
    if (!this.revealed) {
      Column()
        .width('100%')
        .height('100%')
    } else if (this.failed) {
      if (isLocalLazyLoadSource(this.errorSource())) {
        Image(this.errorSource())
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
      } else {
        this.placeholderText('加载失败')
      }
    } else if (!isLocalLazyLoadSource(this.sourceValue())) {
      this.placeholderText('图片占位')
    } else {
      Image(this.sourceValue())
        .width('100%')
        .height('100%')
        .objectFit(this.fitValue())
        .alt(isLocalLazyLoadSource(this.placeholderSource()) ? this.placeholderSource() : '')
        .onComplete((): void => this.handleComplete())
        .onError((): void => this.handleError())
    }
  }

  build() {
    Column() {
      this.frame()
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(this.boxHeight())
    .clip(true)
    .borderRadius(this.cornerRadius())
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#eeeeee')
    .opacity(this.frameOpacity)
    .animation({ duration: this.frameDuration, curve: this.curveValue() })
    .onVisibleAreaChange([0.0, 0.01], (_isExpanding: boolean, currentRatio: number): void => this.handleVisibleChange(currentRatio))
    .onClick((): void => this.handleClick())
  }
}
