import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPModal, UPModalAction, UPModalProps } from './UPModal';

export type UPAgreementLinkType = 'protocol' | 'privacy';

export interface UPAgreementConfirmEvent { accepted: boolean; }
export interface UPAgreementLinkEvent { type: UPAgreementLinkType; url: string; }

export interface UPAgreementOptions {
  show?: UPRawValue;
  title?: UPRawValue;
  content?: UPRawValue;
  urlProtocol?: UPRawValue;
  urlPrivacy?: UPRawValue;
  confirmText?: UPRawValue;
  cancelText?: UPRawValue;
  showCancelButton?: UPRawValue;
  confirmColor?: UPRawValue;
  cancelColor?: UPRawValue;
  contentStyle?: UPStyleInput;
  customStyle?: UPStyleInput;
  onConfirm?: (event: UPAgreementConfirmEvent) => void;
  onCancel?: () => void;
  onProtocolClick?: (event: UPAgreementLinkEvent) => void;
  onPrivacyClick?: (event: UPAgreementLinkEvent) => void;
  onShowChange?: (show: boolean) => void;
  contentBuilder?: UPBuilder;
}

export class UPAgreementProps {
  show: UPRawValue = false;
  title: UPRawValue = '';
  content: UPRawValue = '我们非常重视您的个人信息和隐私保护，请阅读并同意用户协议和隐私政策。';
  urlProtocol: UPRawValue = '/pages/user_agreement/agreement/info?title=用户协议';
  urlPrivacy: UPRawValue = '/pages/user_agreement/agreement/info?title=隐私政策';
  confirmText: UPRawValue = '阅读并同意';
  cancelText: UPRawValue = '取消';
  showCancelButton: UPRawValue = true;
  confirmColor: UPRawValue = 'primary';
  cancelColor: UPRawValue = 'content';
  contentStyle: UPStyleInput = undefined;
  customStyle: UPStyleInput = undefined;
  onConfirm?: (event: UPAgreementConfirmEvent) => void;
  onCancel?: () => void;
  onProtocolClick?: (event: UPAgreementLinkEvent) => void;
  onPrivacyClick?: (event: UPAgreementLinkEvent) => void;
  onShowChange?: (show: boolean) => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPAgreementOptions) {
    if (options === undefined) return;
    this.show = options.show ?? this.show;
    this.title = options.title ?? this.title;
    this.content = options.content ?? this.content;
    this.urlProtocol = options.urlProtocol ?? this.urlProtocol;
    this.urlPrivacy = options.urlPrivacy ?? this.urlPrivacy;
    this.confirmText = options.confirmText ?? this.confirmText;
    this.cancelText = options.cancelText ?? this.cancelText;
    this.showCancelButton = options.showCancelButton ?? this.showCancelButton;
    this.confirmColor = options.confirmColor ?? this.confirmColor;
    this.cancelColor = options.cancelColor ?? this.cancelColor;
    this.contentStyle = options.contentStyle;
    this.customStyle = options.customStyle;
    this.onConfirm = options.onConfirm;
    this.onCancel = options.onCancel;
    this.onProtocolClick = options.onProtocolClick;
    this.onPrivacyClick = options.onPrivacyClick;
    this.onShowChange = options.onShowChange;
    this.contentBuilder = options.contentBuilder;
  }
}

function agreementText(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

@Component
export struct UPAgreement {
  @Prop props: UPAgreementProps = new UPAgreementProps();

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private linkColor(): string {
    return UPColor.parse('primary', UP_DEFAULT_THEME, UP_DEFAULT_THEME.primary);
  }

  private bodyStyleFontSize(): number {
    return UPStyle.parse(this.props.contentStyle).fontSize ?? 14;
  }

  private bodyStyleColor(): string {
    return UPStyle.parse(this.props.contentStyle).color ?? UPColor.neutral('content', '#606266');
  }

  private link(type: UPAgreementLinkType): void {
    const url: string = type === 'protocol' ? agreementText(this.props.urlProtocol) : agreementText(this.props.urlPrivacy);
    const event: UPAgreementLinkEvent = { type, url };
    if (type === 'protocol') {
      this.props.onProtocolClick?.(event);
    } else {
      this.props.onPrivacyClick?.(event);
    }
  }

  private action(event: UPModalAction): void {
    if (event.action === 'confirm') {
      this.props.onConfirm?.({ accepted: true });
    } else if (event.action === 'cancel') {
      this.props.onCancel?.();
    }
    event.done();
  }

  @Builder
  private agreementContent() {
    Column({ space: 10 }) {
      if (agreementText(this.props.content).length > 0) {
        Text(agreementText(this.props.content))
          .width('100%')
          .fontSize(this.bodyStyleFontSize())
          .fontColor(this.bodyStyleColor())
          .lineHeight(22)
          .textAlign(TextAlign.Start)
      }
      Row({ space: 2 }) {
        Text('《')
          .fontSize(this.bodyStyleFontSize())
          .fontColor(this.bodyStyleColor())
        Text('用户协议')
          .fontSize(this.bodyStyleFontSize())
          .fontColor(this.linkColor())
          .onClick(() => this.link('protocol'))
        Text('》和《')
          .fontSize(this.bodyStyleFontSize())
          .fontColor(this.bodyStyleColor())
        Text('隐私政策')
          .fontSize(this.bodyStyleFontSize())
          .fontColor(this.linkColor())
          .onClick(() => this.link('privacy'))
        Text('》')
          .fontSize(this.bodyStyleFontSize())
          .fontColor(this.bodyStyleColor())
      }
      this.contentBuilder()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    UPModal({
      props: new UPModalProps({
        show: this.props.show,
        title: this.props.title,
        confirmText: this.props.confirmText,
        cancelText: this.props.cancelText,
        showCancelButton: upBoolean(this.props.showCancelButton, true),
        confirmColor: this.props.confirmColor,
        cancelColor: this.props.cancelColor,
        contentStyle: this.props.contentStyle,
        customStyle: this.props.customStyle,
        onAction: (event: UPModalAction): void => {
          this.action(event);
        },
        onShowChange: (show: boolean): void => {
          this.props.onShowChange?.(show);
        }
      })
    }) {
      this.agreementContent()
    }
  }
}
