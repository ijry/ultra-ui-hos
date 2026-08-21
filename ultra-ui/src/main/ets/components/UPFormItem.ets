import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { upBoolean, upString } from '../core/UPTypes';

export interface UPFormItemOptions {
  label?: UPRawValue; prop?: UPRawValue; required?: UPRawValue; borderBottom?: UPRawValue; labelPosition?: UPRawValue; labelWidth?: UPRawValue; labelAlign?: UPRawValue; error?: UPRawValue; rightIcon?: UPRawValue; leftIcon?: UPRawValue; customStyle?: UPStyleInput; onClick?: () => void; contentBuilder?: UPBuilder; rightBuilder?: UPBuilder;
}
export class UPFormItemProps {
  label: UPRawValue = ''; prop: UPRawValue = ''; required: UPRawValue = false; borderBottom: UPRawValue = true; labelPosition: UPRawValue = 'left'; labelWidth: UPRawValue = 80; labelAlign: UPRawValue = 'left'; error: UPRawValue = ''; rightIcon: UPRawValue = ''; leftIcon: UPRawValue = ''; customStyle: UPStyleInput = undefined; onClick?: () => void; contentBuilder?: UPBuilder; rightBuilder?: UPBuilder;
  constructor(options?: UPFormItemOptions) {
    if (options === undefined) return;
    this.label = options.label ?? this.label; this.prop = options.prop ?? this.prop; this.required = options.required ?? this.required; this.borderBottom = options.borderBottom ?? this.borderBottom; this.labelPosition = options.labelPosition ?? this.labelPosition; this.labelWidth = options.labelWidth ?? this.labelWidth; this.labelAlign = options.labelAlign ?? this.labelAlign; this.error = options.error ?? this.error; this.rightIcon = options.rightIcon ?? this.rightIcon; this.leftIcon = options.leftIcon ?? this.leftIcon; this.customStyle = options.customStyle; this.onClick = options.onClick; this.contentBuilder = options.contentBuilder; this.rightBuilder = options.rightBuilder;
  }
}

@Component
export struct UPFormItem {
  @Prop props: UPFormItemProps = new UPFormItemProps();
  @Builder private emptyContent() { Row().width(0).height(0); }
  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private labelWidth(): number { return UPUnit.parse(this.props.labelWidth, 375, 80); }
  private hasError(): boolean { return upString(this.props.error, '').length > 0; }

  build() {
    Column({ space: 5 }) {
      Row({ space: 8 }) {
        if (upString(this.props.label, '').length > 0) {
          Text((upBoolean(this.props.required) ? '* ' : '') + upString(this.props.label, ''))
            .width(this.labelWidth()).fontSize(14).fontColor('#303133').textAlign(TextAlign.Start)
        }
        Row() { this.contentBuilder() }.layoutWeight(1)
        if (upString(this.props.rightIcon, '').length > 0) Text(upString(this.props.rightIcon, '')).fontSize(14).fontColor('#909399')
      }
      .width('100%')
      .height(48)
      .padding(UPStyle.parse(this.props.customStyle).padding ?? { top: 8, right: 0, bottom: 8, left: 0 })
      .onClick((): void => { this.props.onClick?.(); })
      if (this.hasError()) Text(upString(this.props.error, '')).fontSize(12).fontColor('#fa3534').width('100%').margin({ bottom: 6, left: this.labelWidth() + 8 })
      Divider().visibility(upBoolean(this.props.borderBottom, true) ? Visibility.Visible : Visibility.None).color('#eeeeee').strokeWidth(1)
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
