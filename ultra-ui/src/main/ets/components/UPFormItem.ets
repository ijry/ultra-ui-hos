import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { upBoolean, upString } from '../core/UPTypes';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPFormContext } from '../internal/UPFormContexts';
import { UPColor } from '../core/UPColor';

export interface UPFormItemOptions {
  label?: UPRawValue; prop?: UPRawValue; required?: UPRawValue; borderBottom?: UPRawValue; labelPosition?: UPRawValue; labelWidth?: UPRawValue; labelAlign?: UPRawValue; error?: UPRawValue; rightIcon?: UPRawValue; leftIcon?: UPRawValue; leftIconStyle?: UPStyleInput; customStyle?: UPStyleInput; onClick?: () => void; contentBuilder?: UPBuilder; rightBuilder?: UPBuilder;
  labelBuilder?: UPBuilder;
  errorBuilder?: UPBuilder;
}
export class UPFormItemProps {
  label: UPRawValue = ''; prop: UPRawValue = ''; required: UPRawValue = false; borderBottom: UPRawValue = true; labelPosition: UPRawValue = 'left'; labelWidth: UPRawValue = 80; labelAlign: UPRawValue = 'left'; error: UPRawValue = ''; rightIcon: UPRawValue = ''; leftIcon: UPRawValue = ''; leftIconStyle: UPStyleInput = undefined; customStyle: UPStyleInput = undefined; onClick?: () => void; contentBuilder?: UPBuilder; rightBuilder?: UPBuilder;
  labelBuilder?: UPBuilder;
  errorBuilder?: UPBuilder;
  constructor(options?: UPFormItemOptions) {
    if (options === undefined) return;
    this.label = options.label ?? this.label; this.prop = options.prop ?? this.prop; this.required = options.required ?? this.required; this.borderBottom = options.borderBottom ?? this.borderBottom; this.labelPosition = options.labelPosition ?? this.labelPosition; this.labelWidth = options.labelWidth ?? this.labelWidth; this.labelAlign = options.labelAlign ?? this.labelAlign; this.error = options.error ?? this.error; this.rightIcon = options.rightIcon ?? this.rightIcon; this.leftIcon = options.leftIcon ?? this.leftIcon; this.leftIconStyle = options.leftIconStyle; this.customStyle = options.customStyle; this.onClick = options.onClick; this.contentBuilder = options.contentBuilder; this.rightBuilder = options.rightBuilder;
    this.labelBuilder = options.labelBuilder;
    this.errorBuilder = options.errorBuilder;
  }
}

@Component
export struct UPFormItem {
  @Prop props: UPFormItemProps = new UPFormItemProps();
  @Consume('UPFormContext') formContext: UPFormContext = new UPFormContext();
  @Builder private emptyContent() { Row().width(0).height(0); }
  @BuilderParam contentBuilder: () => void = this.emptyContent;

  /** 未被 UPForm 包裹时回落自身 props。/ Falls back to own props outside a form. */
  private labelWidth(): number {
    const inherited: UPRawValue = this.formContext.managed ? this.formContext.labelWidth : this.props.labelWidth;
    return UPUnit.parse(inherited, 375, 80);
  }

  /** 上游 labelPosition 为 top 时标签独占一行。/ Upstream top label position. */
  private labelOnTop(): boolean {
    const position: string = this.formContext.managed
      ? this.formContext.labelPosition
      : upString(this.props.labelPosition, 'left');
    return position.toLowerCase() === 'top';
  }

  private labelTextAlign(): TextAlign {
    const align: string = (this.formContext.managed
      ? this.formContext.labelAlign
      : upString(this.props.labelAlign, 'left')).toLowerCase();
    if (align === 'center') {
      return TextAlign.Center;
    }
    if (align === 'right') {
      return TextAlign.End;
    }
    return TextAlign.Start;
  }

  private underlineVisible(): boolean {
    if (this.props.borderBottom !== undefined && this.props.borderBottom !== '') {
      return upBoolean(this.props.borderBottom, true);
    }
    return this.formContext.managed ? this.formContext.borderBottom : true;
  }

  /**
   * 校验文案优先取 UPForm 下发的错误，其次回落 props.error。
   * Prefers the form-level error, then the locally supplied one.
   */
  private errorText(): string {
    const managed: string = this.formContext.errorOf(this.props.prop);
    return managed.length > 0 ? managed : upString(this.props.error, '');
  }

  /** 上游 errorType 决定错误呈现方式。/ Upstream errorType drives the presentation. */
  private showsMessage(): boolean {
    if (!this.formContext.managed) {
      return true;
    }
    return this.formContext.errorType === 'message';
  }

  private showsErrorBorder(): boolean {
    return this.formContext.managed && this.formContext.errorType === 'border-bottom'
      && this.errorText().length > 0;
  }

  private hasError(): boolean { return this.errorText().length > 0; }

  @Builder
  private labelRegion() {
    UPSlotRegion({ contentBuilder: this.props.labelBuilder })
  }

  @Builder
  private errorRegion() {
    UPSlotRegion({ contentBuilder: this.props.errorBuilder })
  }

  @Builder
  private labelText() {
    if (this.props.labelBuilder !== undefined) {
      this.labelRegion()
    } else if (upString(this.props.label, '').length > 0) {
      Text((upBoolean(this.props.required) ? '* ' : '') + upString(this.props.label, ''))
        .width(this.labelOnTop() ? '100%' : this.labelWidth())
        .fontSize(14)
        .fontColor(UPColor.adaptive('#303133', 'main-color'))
        .textAlign(this.labelTextAlign())
    }
  }

  @Builder
  private fieldRow() {
    Row({ space: 8 }) {
      if (upString(this.props.leftIcon, '').length > 0) {
        Text(upString(this.props.leftIcon, ''))
          .fontSize(UPStyle.parse(this.props.leftIconStyle).fontSize ?? 14)
          .fontColor(UPStyle.parse(this.props.leftIconStyle).color ?? '#909399')
      }
      if (!this.labelOnTop()) {
        this.labelText()
      }
      Row() { this.contentBuilder() }.layoutWeight(1)
      if (upString(this.props.rightIcon, '').length > 0) Text(upString(this.props.rightIcon, '')).fontSize(14).fontColor(UPColor.adaptive('#909399', 'tips-color'))
    }
    .width('100%')
    .height(48)
    .padding(UPStyle.parse(this.props.customStyle).padding ?? { top: 8, right: 0, bottom: 8, left: 0 })
    .onClick((): void => { this.props.onClick?.(); })
  }

  build() {
    Column({ space: 5 }) {
      if (this.labelOnTop()) {
        this.labelText()
      }
      this.fieldRow()
      if (this.props.errorBuilder !== undefined) {
        this.errorRegion()
      } else if (this.hasError() && this.showsMessage()) {
        Text(this.errorText()).fontSize(12).fontColor('#fa3534').width('100%')
          .margin({ bottom: 6, left: this.labelOnTop() ? 0 : this.labelWidth() + 8 })
      }
      Divider()
        .visibility(this.underlineVisible() ? Visibility.Visible : Visibility.None)
        .color(this.showsErrorBorder() ? '#fa3534' : '#eeeeee')
        .strokeWidth(1)
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
