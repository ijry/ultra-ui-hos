import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPLoadingIcon, UPLoadingIconProps } from './UPLoadingIcon';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPI18n } from '../core/UPI18n';

export interface UPLoadingPageOptions {
  loadingText?: UPRawValue;
  image?: UPRawValue;
  loadingMode?: UPRawValue;
  loading?: UPRawValue;
  bgColor?: UPRawValue;
  color?: UPRawValue;
  fontSize?: UPRawValue;
  iconSize?: UPRawValue;
  loadingColor?: UPRawValue;
  zIndex?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  contentBuilder?: UPBuilder;
}

export class UPLoadingPageProps {
  loadingText: UPRawValue = UPI18n.t('up.common.loading2');
  image: UPRawValue = '';
  loadingMode: UPRawValue = 'circle';
  loading: UPRawValue = false;
  bgColor: UPRawValue = '';
  color: UPRawValue = '#C8C8C8';
  fontSize: UPRawValue = 19;
  iconSize: UPRawValue = 19;
  loadingColor: UPRawValue = '#C8C8C8';
  zIndex: UPRawValue = 10;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  contentBuilder?: UPBuilder;

  constructor(options?: UPLoadingPageOptions) {
    if (options === undefined) {
      return;
    }
    this.loadingText = options.loadingText ?? this.loadingText;
    this.image = options.image ?? this.image;
    this.loadingMode = options.loadingMode ?? this.loadingMode;
    this.loading = options.loading ?? this.loading;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.color = options.color ?? this.color;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.iconSize = options.iconSize ?? this.iconSize;
    this.loadingColor = options.loadingColor ?? this.loadingColor;
    this.zIndex = options.zIndex ?? this.zIndex;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.contentBuilder = options.contentBuilder;
  }
}

function textValue(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

function localSource(value: string): boolean {
  return value.startsWith('resource://') || value.startsWith('file://') || value.startsWith('/') || value.startsWith('$rawfile:');
}

function loadingMode(value: string): string {
  const mode: string = value.toLowerCase();
  return mode === 'spinner' || mode === 'circle' || mode === 'semicircle' ? mode : 'circle';
}

@Component
export struct UPLoadingPage {
  @Prop props: UPLoadingPageProps = new UPLoadingPageProps();

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private pageBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    return style.backgroundColor ?? style.background ?? UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, UPColor.adaptive('#ffffff', 'card-bg-color'));
  }

  @Builder
  private indicator() {
    if (localSource(textValue(this.props.image))) {
      Image(textValue(this.props.image))
        .width(UPUnit.parse(this.props.iconSize, 375, 19))
        .height(UPUnit.parse(this.props.iconSize, 375, 19))
        .objectFit(ImageFit.Contain)
    } else {
      UPLoadingIcon({ props: new UPLoadingIconProps({
        show: true,
        mode: loadingMode(textValue(this.props.loadingMode)),
        size: UPUnit.parse(this.props.iconSize, 375, 19),
        color: UPColor.parse(this.props.loadingColor, UP_DEFAULT_THEME, '#C8C8C8'),
        text: ''
      }) })
    }
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }


  build() {
    if (!upBoolean(this.props.loading, false)) {
      Row().width(0).height(0)
    } else {
      Stack({ alignContent: Alignment.Center }) {
        Column({ space: 12 }) {
          this.indicator()
          if (this.props.contentBuilder !== undefined) {
            this.slotRegion()
          } else {
            Text(textValue(this.props.loadingText))
              .fontSize(UPUnit.parse(this.props.fontSize, 375, 19))
              .fontColor(UPColor.parse(this.props.color, UP_DEFAULT_THEME, '#C8C8C8'))
              .maxLines(2)
          }
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.pageBackground())
      .zIndex(UPUnit.parse(this.props.zIndex, 375, 10))
      .id('up-loading-page')
    }
  }

  aboutToAppear(): void {
    const image: string = textValue(this.props.image);
    if (image.length > 0 && !localSource(image)) {
      this.diagnostics().report('UPLoadingPage', 'image', this.props.image, 'remote image loading is disabled; use a local resource or omit image');
    }
    const mode: string = textValue(this.props.loadingMode).toLowerCase();
    if (mode !== 'spinner' && mode !== 'circle' && mode !== 'semicircle') {
      this.diagnostics().report('UPLoadingPage', 'loadingMode', this.props.loadingMode, 'unsupported loading mode; fallback to circle');
    }
  }
}
