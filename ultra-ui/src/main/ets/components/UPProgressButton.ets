import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';

export interface UPProgressButtonState { state: string; progress: number; }
export interface UPProgressButtonClickEvent { state: string; progress: number; }
export interface UPProgressButtonOptions {
  text?: string; progress?: UPRawValue; state?: UPRawValue; disabled?: UPRawValue; activeColor?: string; customStyle?: UPStyleInput;
  onClick?: (event: UPProgressButtonClickEvent) => void; onStateChange?: (event: UPProgressButtonState) => void;
}
export class UPProgressButtonProps {
  text: string = '提交'; progress: UPRawValue = 0; state: UPRawValue = 'normal'; disabled: UPRawValue = false;
  activeColor: string = '#2979ff'; customStyle: UPStyleInput = undefined;
  onClick?: (event: UPProgressButtonClickEvent) => void; onStateChange?: (event: UPProgressButtonState) => void;
  constructor(options?: UPProgressButtonOptions) {
    if (options === undefined) return;
    this.text = options.text ?? this.text; this.progress = options.progress ?? this.progress; this.state = options.state ?? this.state;
    this.disabled = options.disabled ?? this.disabled; this.activeColor = options.activeColor ?? this.activeColor; this.customStyle = options.customStyle;
    this.onClick = options.onClick; this.onStateChange = options.onStateChange;
  }
}

@Component
export struct UPProgressButton {
  @Prop props: UPProgressButtonProps = new UPProgressButtonProps();
  private value(): number { return Math.max(0, Math.min(100, upNumber(this.props.progress, 0))); }
  private state(): string { const value: string = upString(this.props.state, 'normal').toLowerCase(); return value === 'loading' || value === 'success' || value === 'error' ? value : 'normal'; }
  private label(): string { const state: string = this.state(); return state === 'loading' ? `${this.props.text} ${String(this.value())}%` : state === 'success' ? '完成' : state === 'error' ? '失败' : this.props.text; }
  build() {
    Button(this.label()).fontSize(14).fontColor(Color.White).backgroundColor(this.state() === 'success' ? '#19be6b' : this.state() === 'error' ? '#fa3534' : this.props.activeColor)
      .opacity(upBoolean(this.props.disabled, false) ? 0.55 : 1).width('100%').onClick((): void => {
        if (upBoolean(this.props.disabled, false)) return;
        const state: string = this.state(); this.props.onClick?.({ state, progress: this.value() }); this.props.onStateChange?.({ state, progress: this.value() });
      })
  }
}
