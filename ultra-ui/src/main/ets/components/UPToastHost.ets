import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPEdgeValues } from '../core/UPUnit';
import { upString } from '../core/UPTypes';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPLoadingIcon, UPLoadingIconProps } from './UPLoadingIcon';
import { UPToastController, UPToastState } from '../controllers/UPToastController';

/** The one root-level visual host for command-style Toast messages. */
@Component
export struct UPToastHost {
  @State private hasToast: boolean = false;
  @State private toast: UPToastState = new UPToastState(0);
  private mounted: boolean = false;

  aboutToAppear(): void {
    this.mounted = true;
    UPToastController.shared().mount((state: UPToastState | undefined): void => this.receive(state));
  }

  aboutToDisappear(): void {
    this.mounted = false;
    UPToastController.shared().unmount();
  }

  private receive(state: UPToastState | undefined): void {
    if (!this.mounted) {
      return;
    }
    if (state === undefined) {
      this.hasToast = false;
      return;
    }
    this.toast = state;
    this.hasToast = true;
  }

  private toastColor(): string {
    const type: string = this.toast.type.toLowerCase();
    if (type === 'primary' || type === 'info') {
      return UP_DEFAULT_THEME.primary;
    }
    if (type === 'success') {
      return UP_DEFAULT_THEME.success;
    }
    if (type === 'warning') {
      return UP_DEFAULT_THEME.warning;
    }
    if (type === 'error') {
      return UP_DEFAULT_THEME.error;
    }
    return '#303133';
  }

  private panelColor(): string {
    const style = UPStyle.parse(this.toast.customStyle);
    return style.backgroundColor ?? '#303133';
  }

  private panelWidth(): number | string {
    const style = UPStyle.parse(this.toast.customStyle);
    return style.width ?? 'auto';
  }

  private panelPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.toast.customStyle);
    return style.padding ?? { top: 12, right: 18, bottom: 12, left: 18 };
  }

  private panelRadius(): number {
    const style = UPStyle.parse(this.toast.customStyle);
    return style.borderRadius ?? 8;
  }

  private textColor(): string {
    const style = UPStyle.parse(this.toast.customStyle);
    return style.color ?? '#ffffff';
  }

  private message(): string {
    return this.toast.message.length > 0 ? this.toast.message : this.toast.title;
  }

  private hasIcon(): boolean {
    return this.toast.icon.length > 0;
  }

  @Builder
  private toastContent() {
    Row({ space: 8 }) {
      if (this.toast.loading) {
        UPLoadingIcon({ props: new UPLoadingIconProps({
          show: true,
          color: '#ffffff',
          size: 20,
          text: ''
        }) })
      } else if (this.hasIcon()) {
        UPIcon({ props: new UPIconProps({
          name: this.toast.icon,
          color: '#ffffff',
          size: 20
        }) })
      }
      if (this.message().length > 0) {
        Text(this.message())
          .fontSize(14)
          .fontColor(this.textColor())
          .maxLines(3)
      }
    }
    .width(this.panelWidth())
    .padding(this.panelPadding())
    .backgroundColor(this.panelColor())
    .borderRadius(this.panelRadius())
  }

  @Builder
  private positionedToast() {
    if (this.toast.position === 'top') {
      Column() {
        this.toastContent()
      }
      .width('100%')
      .padding({ top: 42 })
      .align(Alignment.Top)
    } else if (this.toast.position === 'bottom') {
      Column() {
        this.toastContent()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 54 })
      .align(Alignment.Bottom)
    } else {
      Column() {
        this.toastContent()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .align(Alignment.Center)
    }
  }

  @Builder
  private content() {
    if (!this.hasToast) {
      Row().width(0).height(0)
    } else {
      Stack() {
        if (this.toast.mask || this.toast.overlay || this.toast.forbidClick) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.01)
            .onClick(() => {
              // The mask intentionally consumes input and never dismisses Toast implicitly.
            })
        }
        this.positionedToast()
      }
      .width('100%')
      .height('100%')
      .zIndex(this.toast.zIndex)
    }
  }

  build() {
    this.content()
  }
}
