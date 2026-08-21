import { UPRawValue, UPStyleInput, upBoolean, upNumber } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPOverlayClickEvent {
  source: 'overlay';
}

export interface UPOverlayOptions {
  show?: UPRawValue;
  zIndex?: UPRawValue;
  duration?: UPRawValue;
  opacity?: UPRawValue;
  closeOnClickOverlay?: UPRawValue;
  customStyle?: UPStyleInput;
  onShowChange?: (show: boolean) => void;
  onClickOverlay?: (event: UPOverlayClickEvent) => void;
}

/** Controlled full-screen dimming layer. Visibility is owned by the caller. */
export class UPOverlayProps {
  show: UPRawValue = false;
  zIndex: UPRawValue = 1000;
  duration: UPRawValue = 300;
  opacity: UPRawValue = 0.5;
  closeOnClickOverlay: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  onShowChange?: (show: boolean) => void;
  onClickOverlay?: (event: UPOverlayClickEvent) => void;

  constructor(options?: UPOverlayOptions) {
    if (options === undefined) {
      return;
    }
    this.show = options.show ?? this.show;
    this.zIndex = options.zIndex ?? this.zIndex;
    this.duration = options.duration ?? this.duration;
    this.opacity = options.opacity ?? this.opacity;
    this.closeOnClickOverlay = options.closeOnClickOverlay ?? this.closeOnClickOverlay;
    this.customStyle = options.customStyle;
    this.onShowChange = options.onShowChange;
    this.onClickOverlay = options.onClickOverlay;
  }
}

@Component
export struct UPOverlay {
  @Prop props: UPOverlayProps = new UPOverlayProps();

  private isVisible(): boolean {
    return upBoolean(this.props.show, false);
  }

  private overlayOpacity(): number {
    const style = UPStyle.parse(this.props.customStyle);
    const value: number = upNumber(this.props.opacity, 0.5);
    return style.opacity ?? Math.max(0, Math.min(1, value));
  }

  private overlayZIndex(): number {
    return Math.max(0, upNumber(this.props.zIndex, 1000));
  }

  private clickOverlay(): void {
    this.props.onClickOverlay?.({ source: 'overlay' });
    if (upBoolean(this.props.closeOnClickOverlay, true)) {
      this.props.onShowChange?.(false);
    }
  }

  @Builder
  private content() {
    if (!this.isVisible()) {
      Row().width(0).height(0)
    } else {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(UPColor.parse('#000000', UP_DEFAULT_THEME))
          .opacity(this.overlayOpacity())
          .onClick(() => this.clickOverlay())
      }
      .width('100%')
      .height('100%')
      .zIndex(this.overlayZIndex())
    }
  }

  build() {
    this.content()
  }
}
