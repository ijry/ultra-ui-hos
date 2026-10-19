import { UPRawValue, UPStyleInput, UPBuilder, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export type UPCopyFailureReason = 'empty-content' | 'clipboard-unavailable' | 'clipboard-failed';

export interface UPCopyRequest { content: string; }
export interface UPCopySuccessEvent { content: string; notice: string; }
export interface UPCopyFailureEvent { content: string; reason: UPCopyFailureReason; }

export interface UPCopyOptions {
  content?: UPRawValue;
  alertStyle?: UPRawValue;
  notice?: UPRawValue;
  customStyle?: UPStyleInput;
  clipboard?: (content: string) => boolean;
  onClick?: (event: UPCopyRequest) => void;
  onSuccess?: (event: UPCopySuccessEvent) => void;
  onFailure?: (event: UPCopyFailureEvent) => void;
  contentBuilder?: UPBuilder;
}

export class UPCopyProps {
  content: UPRawValue = '';
  alertStyle: UPRawValue = 'toast';
  notice: UPRawValue = '复制成功';
  customStyle: UPStyleInput = undefined;
  clipboard?: (content: string) => boolean;
  onClick?: (event: UPCopyRequest) => void;
  onSuccess?: (event: UPCopySuccessEvent) => void;
  onFailure?: (event: UPCopyFailureEvent) => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPCopyOptions) {
    if (options === undefined) return;
    this.content = options.content ?? this.content;
    this.alertStyle = options.alertStyle ?? this.alertStyle;
    this.notice = options.notice ?? this.notice;
    this.customStyle = options.customStyle;
    this.clipboard = options.clipboard;
    this.onClick = options.onClick;
    this.onSuccess = options.onSuccess;
    this.onFailure = options.onFailure;
    this.contentBuilder = options.contentBuilder;
  }
}

function copyText(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

@Component
export struct UPCopy {
  @Prop props: UPCopyProps = new UPCopyProps();

  @Builder
  private defaultContent() {
    Text('复制')
      .fontSize(UPStyle.parse(this.props.customStyle).fontSize ?? 14)
      .fontColor(UPStyle.parse(this.props.customStyle).color ?? UP_DEFAULT_THEME.primary)
  }

  @BuilderParam contentBuilder: () => void = this.defaultContent;

  private failure(content: string, reason: UPCopyFailureReason): boolean {
    this.props.onFailure?.({ content, reason });
    return false;
  }

  copy(): boolean {
    const content: string = copyText(this.props.content);
    this.props.onClick?.({ content });
    if (content.length === 0) {
      return this.failure(content, 'empty-content');
    }
    if (this.props.clipboard === undefined) {
      return this.failure(content, 'clipboard-unavailable');
    }
    let copied: boolean = false;
    try {
      copied = this.props.clipboard(content);
    } catch (_) {
      copied = false;
    }
    if (!copied) {
      return this.failure(content, 'clipboard-failed');
    }
    this.props.onSuccess?.({ content, notice: copyText(this.props.notice) });
    return true;
  }

  private customWidth(): number | string {
    return UPStyle.parse(this.props.customStyle).width ?? 'auto';
  }

  private customHeight(): number | string {
    return UPStyle.parse(this.props.customStyle).height ?? 'auto';
  }

  build() {
    Row() {
      this.contentBuilder()
    }
    .width(this.customWidth())
    .height(this.customHeight())
    .padding({ left: UPUnit.parse(8, 375, 8), right: UPUnit.parse(8, 375, 8) })
    .onClick(() => {
      this.copy();
    })
  }
}
