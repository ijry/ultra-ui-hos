import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPI18n } from '../core/UPI18n';

export interface UPReadMoreToggleEvent { open: boolean; name: UPRawValue; }
export interface UPReadMoreOptions {
  showHeight?: UPRawValue; toggle?: boolean; closeText?: string; openText?: string; color?: string;
  fontSize?: UPRawValue; shadowStyle?: UPStyleInput; textIndent?: UPRawValue; name?: UPRawValue;
  modelValue?: boolean; value?: boolean; customStyle?: UPStyleInput;
  onToggle?: (event: UPReadMoreToggleEvent) => void; onOpenChange?: (open: boolean) => void;
  onOpen?: (name: UPRawValue) => void; onClose?: (name: UPRawValue) => void; contentBuilder?: UPBuilder;
  toggleBuilder?: UPBuilder;
}
export class UPReadMoreProps {
  showHeight: UPRawValue = 400; toggle: boolean = false; closeText: string = UPI18n.t('up.readMore.expand'); openText: string = UPI18n.t('up.readMore.fold');
  color: string = '#2979ff'; fontSize: UPRawValue = 14; shadowStyle: UPStyleInput = undefined;
  textIndent: UPRawValue = '2em'; name: UPRawValue = ''; modelValue: UPRawValue = undefined; value: boolean = false;
  customStyle: UPStyleInput = undefined; onToggle?: (event: UPReadMoreToggleEvent) => void;
  onOpenChange?: (open: boolean) => void;
  onOpen?: (name: UPRawValue) => void; onClose?: (name: UPRawValue) => void; contentBuilder?: UPBuilder;
  toggleBuilder?: UPBuilder;
  constructor(options?: UPReadMoreOptions) {
    if (options === undefined) return;
    this.showHeight = options.showHeight ?? this.showHeight; this.toggle = options.toggle ?? this.toggle;
    this.closeText = options.closeText ?? this.closeText; this.openText = options.openText ?? this.openText;
    this.color = typeof options.color === 'string' ? options.color : this.color; this.fontSize = options.fontSize ?? this.fontSize;
    this.shadowStyle = options.shadowStyle; this.textIndent = options.textIndent ?? this.textIndent;
    this.name = options.name ?? this.name; this.modelValue = options.modelValue ?? this.modelValue;
    this.value = options.value ?? this.value; this.customStyle = options.customStyle;
    this.onToggle = options.onToggle; this.onOpenChange = options.onOpenChange;
    this.onOpen = options.onOpen; this.onClose = options.onClose; this.contentBuilder = options.contentBuilder;
    this.toggleBuilder = options.toggleBuilder;
  }
}
@Component
export struct UPReadMore {
  @Prop props: UPReadMoreProps = new UPReadMoreProps();
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  private open(): boolean {
    return this.props.modelValue !== null && this.props.modelValue !== undefined ?
      upBoolean(this.props.modelValue, false) : this.props.value;
  }
  private toggle(): void {
    const next: boolean = !this.open(); const event: UPReadMoreToggleEvent = { open: next, name: this.props.name };
    this.props.onOpenChange?.(next); this.props.onToggle?.(event);
    /** 上游按状态分派 open / close。/ Upstream dispatches open or close per state. */
    if (next) {
      this.props.onOpen?.(this.props.name);
      return;
    }
    this.props.onClose?.(this.props.name);
  }
  @Builder
  private toggleRegion() {
    UPSlotRegion({ contentBuilder: this.props.toggleBuilder })
  }

  build() {
    Column({ space: 8 }) {
      Column() { this.contentBuilder() }
        .constraintSize({ maxHeight: this.open() ? Infinity : Math.max(0, upNumber(this.props.showHeight, 400)) })
        .clip(upBoolean(this.props.toggle, false))
      if (this.props.toggleBuilder !== undefined) {
        Column() {
          this.toggleRegion()
        }.onClick((): void => this.toggle())
      } else {
        Text(this.open() ? this.props.openText : this.props.closeText).fontSize(UPUnit.parse(this.props.fontSize, 375, 14))
          .fontColor(this.props.color).onClick((): void => this.toggle())
      }
    }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
