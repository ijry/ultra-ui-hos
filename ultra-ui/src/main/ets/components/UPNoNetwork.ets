import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPButton, UPButtonProps } from './UPButton';
import { UPI18n } from '../core/UPI18n';
import { UPColor } from '../core/UPColor';

export interface UPNoNetworkStatusEvent {
  isConnected: boolean;
  networkType: string;
}

export interface UPNoNetworkRetryEvent {
  isConnected: boolean;
  networkType: string;
}

export interface UPNoNetworkOptions {
  tips?: UPRawValue;
  zIndex?: UPRawValue;
  image?: UPRawValue;
  isConnected?: UPRawValue;
  networkType?: UPRawValue;
  retryText?: UPRawValue;
  customStyle?: UPStyleInput;
  onRetry?: (event: UPNoNetworkRetryEvent) => void;
  onConnected?: (event: UPNoNetworkStatusEvent) => void;
  onDisconnected?: (event: UPNoNetworkStatusEvent) => void;
}

export class UPNoNetworkProps {
  tips: UPRawValue = UPI18n.t('up.noNetwork.text');
  zIndex: UPRawValue = 1000;
  image: UPRawValue = 'empty-wifi';
  isConnected: UPRawValue = true;
  networkType: UPRawValue = 'none';
  retryText: UPRawValue = UPI18n.t('up.common.retry');
  customStyle: UPStyleInput = undefined;
  onRetry?: (event: UPNoNetworkRetryEvent) => void;
  onConnected?: (event: UPNoNetworkStatusEvent) => void;
  onDisconnected?: (event: UPNoNetworkStatusEvent) => void;

  constructor(options?: UPNoNetworkOptions) {
    if (options === undefined) return;
    this.tips = options.tips ?? this.tips;
    this.zIndex = options.zIndex ?? this.zIndex;
    this.image = options.image ?? this.image;
    this.isConnected = options.isConnected ?? this.isConnected;
    this.networkType = options.networkType ?? this.networkType;
    this.retryText = options.retryText ?? this.retryText;
    this.customStyle = options.customStyle;
    this.onRetry = options.onRetry;
    this.onConnected = options.onConnected;
    this.onDisconnected = options.onDisconnected;
  }
}

function noNetworkText(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

@Component
export struct UPNoNetwork {
  @Prop @Watch('refreshStatus') props: UPNoNetworkProps = new UPNoNetworkProps();
  @State private connected: boolean = true;
  @State private currentNetworkType: string = 'none';

  aboutToAppear(): void {
    this.refreshStatus();
  }

  refreshStatus(): void {
    this.connected = upBoolean(this.props.isConnected, true);
    this.currentNetworkType = noNetworkText(this.props.networkType).length > 0 ?
      noNetworkText(this.props.networkType) : (this.connected ? 'unknown' : 'none');
  }

  private statusEvent(): UPNoNetworkStatusEvent {
    return { isConnected: this.connected, networkType: this.currentNetworkType };
  }

  setConnected(isConnected: boolean, networkType?: string): void {
    this.connected = isConnected;
    this.currentNetworkType = networkType !== undefined && networkType.length > 0 ?
      networkType : (isConnected ? 'unknown' : 'none');
    const event: UPNoNetworkStatusEvent = this.statusEvent();
    if (isConnected) {
      this.props.onConnected?.(event);
    } else {
      this.props.onDisconnected?.(event);
    }
  }

  retry(): void {
    this.props.onRetry?.({ isConnected: this.connected, networkType: this.currentNetworkType });
  }

  private isVisible(): boolean {
    return !this.connected;
  }

  private overlayZIndex(): number {
    return Math.max(0, upNumber(this.props.zIndex, 1000));
  }

  private imageName(): string {
    const value: string = noNetworkText(this.props.image);
    if (value.startsWith('http' + '://') || value.startsWith('https' + '://') || value.startsWith('data:')) {
      return 'empty-wifi';
    }
    return value.length > 0 ? value : 'empty-wifi';
  }

  private imageSize(): number {
    return UPUnit.parse(150, 375, 150);
  }

  private textColor(): string {
    return UPStyle.parse(this.props.customStyle).color ?? UPColor.neutral('tips', '#909399');
  }

  @Builder
  private content() {
    if (!this.isVisible()) {
      Row().width(0).height(0)
    } else {
      Stack() {
        Column({ space: 14 }) {
          UPIcon({
            props: new UPIconProps({
              name: this.imageName(),
              size: this.imageSize(),
              color: '#c0c4cc'
            })
          })
          Text(noNetworkText(this.props.tips))
            .fontSize(14)
            .fontColor(this.textColor())
            .textAlign(TextAlign.Center)
          UPButton({
            props: new UPButtonProps({
              text: noNetworkText(this.props.retryText),
              size: 'mini',
              type: 'primary',
              plain: true,
              onClick: (): void => {
                this.retry();
              }
            })
          })
        }
        .width('100%')
        .height('100%')
        .padding({ left: 20, right: 20 })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
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
