import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';

export interface UPImageClickEvent {
  src: string;
  mode: string;
}

export interface UPImageOptions {
  src?: UPRawValue;
  mode?: UPRawValue;
  width?: UPRawValue;
  height?: UPRawValue;
  shape?: UPRawValue;
  radius?: UPRawValue;
  lazyLoad?: UPRawValue;
  showMenuByLongpress?: UPRawValue;
  loadingIcon?: UPRawValue;
  errorIcon?: UPRawValue;
  showLoading?: UPRawValue;
  showError?: UPRawValue;
  fade?: UPRawValue;
  webp?: UPRawValue;
  duration?: UPRawValue;
  bgColor?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (event: UPImageClickEvent) => void;
}

export class UPImageProps {
  src: UPRawValue = '';
  mode: UPRawValue = 'aspectFill';
  width: UPRawValue = 300;
  height: UPRawValue = 225;
  shape: UPRawValue = 'square';
  radius: UPRawValue = 0;
  lazyLoad: UPRawValue = true;
  showMenuByLongpress: UPRawValue = false;
  loadingIcon: UPRawValue = 'photo';
  errorIcon: UPRawValue = 'error-circle';
  showLoading: UPRawValue = true;
  showError: UPRawValue = true;
  fade: UPRawValue = true;
  webp: UPRawValue = false;
  duration: UPRawValue = 500;
  bgColor: UPRawValue = '#f3f4f6';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (event: UPImageClickEvent) => void;

  constructor(options?: UPImageOptions) {
    if (options === undefined) {
      return;
    }
    this.src = options.src ?? this.src;
    this.mode = options.mode ?? this.mode;
    this.width = options.width ?? this.width;
    this.height = options.height ?? this.height;
    this.shape = options.shape ?? this.shape;
    this.radius = options.radius ?? this.radius;
    this.lazyLoad = options.lazyLoad ?? this.lazyLoad;
    this.showMenuByLongpress = options.showMenuByLongpress ?? this.showMenuByLongpress;
    this.loadingIcon = options.loadingIcon ?? this.loadingIcon;
    this.errorIcon = options.errorIcon ?? this.errorIcon;
    this.showLoading = options.showLoading ?? this.showLoading;
    this.showError = options.showError ?? this.showError;
    this.fade = options.fade ?? this.fade;
    this.webp = options.webp ?? this.webp;
    this.duration = options.duration ?? this.duration;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
  }
}

function textValue(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

function isLocalImageSource(value: string): boolean {
  return value.startsWith('resource://') || value.startsWith('file://') || value.startsWith('/') || value.startsWith('$rawfile:');
}

function imageFit(value: string): ImageFit {
  switch (value.toLowerCase()) {
    case 'aspectfit': return ImageFit.Contain;
    case 'scaletofill': return ImageFit.Fill;
    case 'widthfix': return ImageFit.Contain;
    case 'heightfix': return ImageFit.Contain;
    case 'top': return ImageFit.Cover;
    case 'bottom': return ImageFit.Cover;
    case 'left': return ImageFit.Cover;
    case 'right': return ImageFit.Cover;
    case 'aspectfill': return ImageFit.Cover;
    default: return ImageFit.Cover;
  }
}

@Component
export struct UPImage {
  @Prop props: UPImageProps = new UPImageProps();

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private source(): string {
    return textValue(this.props.src);
  }

  private imageWidth(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.width ?? UPUnit.parse(this.props.width, 375, 300);
  }

  private imageHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? UPUnit.parse(this.props.height, 375, 225);
  }

  private imageBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#f3f4f6');
  }

  private radius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.borderRadius !== undefined) {
      return style.borderRadius;
    }
    const shape: string = upString(this.props.shape, 'square').toLowerCase();
    if (shape === 'circle') {
      return Math.min(this.imageWidth(), this.imageHeight()) / 2;
    }
    if (shape === 'round') {
      return 8;
    }
    return Math.max(0, UPUnit.parse(this.props.radius, 375, 0));
  }

  private iconName(): string {
    const requested: string = textValue(this.props.errorIcon);
    return requested.length > 0 ? requested : 'photo';
  }

  private click(): void {
    this.props.onClick?.({ src: this.source(), mode: textValue(this.props.mode) });
  }

  @Builder
  private fallback() {
    Stack() {
      if (upBoolean(this.props.showError, true) || upBoolean(this.props.showLoading, true)) {
        UPIcon({ props: new UPIconProps({ name: this.iconName(), size: Math.min(this.imageWidth(), this.imageHeight()) * 0.28, color: '#c0c4cc' }) })
      }
    }
    .width(this.imageWidth())
    .height(this.imageHeight())
    .backgroundColor(this.imageBackground())
    .alignContent(Alignment.Center)
  }

  @Builder
  private content() {
    Stack() {
      if (isLocalImageSource(this.source())) {
        Image(this.source())
          .width(this.imageWidth())
          .height(this.imageHeight())
          .objectFit(imageFit(textValue(this.props.mode)))
          .backgroundColor(this.imageBackground())
      } else {
        this.fallback()
      }
    }
    .width(this.imageWidth())
    .height(this.imageHeight())
    .borderRadius(this.radius())
    .clip(true)
    .onClick((): void => {
      this.click();
    })
    .id('up-image')
  }

  aboutToAppear(): void {
    if (this.source().length > 0 && !isLocalImageSource(this.source())) {
      this.diagnostics().report('UPImage', 'src', this.props.src, 'remote image loading is disabled; render deterministic local placeholder');
    }
    if (upBoolean(this.props.webp, false)) {
      this.diagnostics().report('UPImage', 'webp', this.props.webp, 'webp compatibility is delegated to local resource decoding');
    }
    if (upBoolean(this.props.showMenuByLongpress, false)) {
      this.diagnostics().report('UPImage', 'showMenuByLongpress', this.props.showMenuByLongpress, 'long-press image menu is not exposed by this native wrapper');
    }
  }

  build() {
    this.content()
  }
}
