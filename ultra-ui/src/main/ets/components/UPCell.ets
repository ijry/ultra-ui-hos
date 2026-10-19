import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPEdgeValues, UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPCellClickEvent {
  name: UPRawValue;
  url: UPRawValue;
  linkType: UPRawValue;
}

export interface UPCellOptions {
  title?: UPRawValue;
  label?: UPRawValue;
  value?: UPRawValue;
  icon?: UPRawValue;
  iconColor?: UPRawValue;
  arrow?: UPRawValue;
  arrowDirection?: UPRawValue;
  required?: UPRawValue;
  disabled?: UPRawValue;
  clickable?: UPRawValue;
  center?: UPRawValue;
  border?: UPRawValue;
  name?: UPRawValue;
  url?: UPRawValue;
  linkType?: UPRawValue;
  rightIcon?: UPRawValue;
  rightIconColor?: UPRawValue;
  customStyle?: UPStyleInput;
  titleStyle?: UPStyleInput;
  labelStyle?: UPStyleInput;
  valueStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (event: UPCellClickEvent) => void;
  rightBuilder?: UPBuilder;
  iconBuilder?: UPBuilder;
  titleBuilder?: UPBuilder;
  labelBuilder?: UPBuilder;
  valueBuilder?: UPBuilder;
  rightIconBuilder?: UPBuilder;
  righticonBuilder?: UPBuilder;
}

export class UPCellProps {
  title: UPRawValue = '';
  label: UPRawValue = '';
  value: UPRawValue = '';
  icon: UPRawValue = '';
  iconColor: UPRawValue = 'content';
  arrow: UPRawValue = false;
  arrowDirection: UPRawValue = 'right';
  required: UPRawValue = false;
  disabled: UPRawValue = false;
  clickable: UPRawValue = false;
  center: UPRawValue = false;
  border: UPRawValue = true;
  name: UPRawValue = '';
  url: UPRawValue = '';
  linkType: UPRawValue = '';
  rightIcon: UPRawValue = '';
  rightIconColor: UPRawValue = 'tips';
  customStyle: UPStyleInput = undefined;
  titleStyle: UPStyleInput = undefined;
  labelStyle: UPStyleInput = undefined;
  valueStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (event: UPCellClickEvent) => void;
  rightBuilder?: UPBuilder;
  iconBuilder?: UPBuilder;
  titleBuilder?: UPBuilder;
  labelBuilder?: UPBuilder;
  valueBuilder?: UPBuilder;
  rightIconBuilder?: UPBuilder;
  righticonBuilder?: UPBuilder;

  constructor(options?: UPCellOptions) {
    if (options === undefined) {
      return;
    }
    this.title = options.title ?? this.title;
    this.label = options.label ?? this.label;
    this.value = options.value ?? this.value;
    this.icon = options.icon ?? this.icon;
    this.iconColor = options.iconColor ?? this.iconColor;
    this.arrow = options.arrow ?? this.arrow;
    this.arrowDirection = options.arrowDirection ?? this.arrowDirection;
    this.required = options.required ?? this.required;
    this.disabled = options.disabled ?? this.disabled;
    this.clickable = options.clickable ?? this.clickable;
    this.center = options.center ?? this.center;
    this.border = options.border ?? this.border;
    this.name = options.name ?? this.name;
    this.url = options.url ?? this.url;
    this.linkType = options.linkType ?? this.linkType;
    this.rightIcon = options.rightIcon ?? this.rightIcon;
    this.rightIconColor = options.rightIconColor ?? this.rightIconColor;
    this.customStyle = options.customStyle;
    this.titleStyle = options.titleStyle;
    this.labelStyle = options.labelStyle;
    this.valueStyle = options.valueStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
    this.rightBuilder = options.rightBuilder;
    this.iconBuilder = options.iconBuilder;
    this.titleBuilder = options.titleBuilder;
    this.labelBuilder = options.labelBuilder;
    this.valueBuilder = options.valueBuilder;
    this.rightIconBuilder = options.rightIconBuilder;
    this.righticonBuilder = options.righticonBuilder;
  }
}

@Component
export struct UPCell {
  @Prop props: UPCellProps = new UPCellProps();

  @Builder
  private defaultRight() {
    Row().width(0).height(0)
  }

  @BuilderParam rightBuilder: () => void = this.defaultRight;

  aboutToAppear(): void {
    this.reportPlatformNoOp();
  }

  private display(value: UPRawValue): string {
    if (value === null || value === undefined) {
      return '';
    }
    return String(value);
  }

  private reportPlatformNoOp(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (this.display(this.props.url).length > 0) {
      diagnostics.report('UPCell', 'url', this.props.url, 'HarmonyOS navigation is caller-owned; url is a no-op');
    }
    if (this.display(this.props.linkType).length > 0) {
      diagnostics.report('UPCell', 'linkType', this.props.linkType, 'HarmonyOS navigation is caller-owned; linkType is a no-op');
    }
  }

  private click(): void {
    if (upBoolean(this.props.disabled, false) || !upBoolean(this.props.clickable, false)) {
      return;
    }
    this.props.onClick?.({
      name: this.props.name,
      url: this.props.url,
      linkType: this.props.linkType
    });
  }

  private title(): string {
    return this.display(this.props.title);
  }

  private label(): string {
    return this.display(this.props.label);
  }

  private value(): string {
    return this.display(this.props.value);
  }

  private hasIcon(): boolean {
    return this.display(this.props.icon).length > 0;
  }

  private hasRightIcon(): boolean {
    return this.display(this.props.rightIcon).length > 0;
  }

  private cellPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? { top: 14, right: 16, bottom: 14, left: 16 };
  }

  private cellMinHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.height ?? 52;
  }

  private titleColor(): string {
    const style = UPStyle.parse(this.props.titleStyle);
    return style.color ?? UPColor.neutral('main', '#303133');
  }

  private labelColor(): string {
    const style = UPStyle.parse(this.props.labelStyle);
    return style.color ?? UPColor.neutral('tips', '#909399');
  }

  private valueColor(): string {
    const style = UPStyle.parse(this.props.valueStyle);
    return style.color ?? UPColor.neutral('content', '#606266');
  }

  private valueSize(): number {
    const style = UPStyle.parse(this.props.valueStyle);
    return style.fontSize ?? 14;
  }

  private titleSize(): number {
    const style = UPStyle.parse(this.props.titleStyle);
    return style.fontSize ?? 16;
  }

  private labelSize(): number {
    const style = UPStyle.parse(this.props.labelStyle);
    return style.fontSize ?? 12;
  }

  private arrowText(): string {
    const direction: string = upString(this.props.arrowDirection, 'right').toLowerCase();
    if (direction === 'left') {
      return '‹';
    }
    if (direction === 'up') {
      return '↑';
    }
    if (direction === 'down') {
      return '↓';
    }
    return '›';
  }

  @Builder
  private leftContent() {
    Row({ space: 10 }) {
      if (this.props.iconBuilder !== undefined) {
        this.iconRegion()
      } else if (this.hasIcon()) {
        UPIcon({ props: new UPIconProps({
          name: this.display(this.props.icon),
          color: this.props.iconColor,
          size: 20
        }) })
      }
      if (upBoolean(this.props.required, false)) {
        Text('*')
          .fontSize(16)
          .fontColor(UP_DEFAULT_THEME.error)
      }
      Column({ space: 4 }) {
        if (this.props.titleBuilder !== undefined) {
          this.titleRegion()
        } else if (this.title().length > 0) {
          Text(this.title())
            .fontSize(this.titleSize())
            .fontColor(this.titleColor())
        }
        if (this.props.labelBuilder !== undefined) {
          this.labelRegion()
        } else if (this.label().length > 0) {
          Text(this.label())
            .fontSize(this.labelSize())
            .fontColor(this.labelColor())
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
  }

  @Builder
  private rightContent() {
    Row({ space: 8 }) {
      if (this.props.valueBuilder !== undefined) {
        this.valueRegion()
      } else if (this.value().length > 0) {
        Text(this.value())
          .fontSize(this.valueSize())
          .fontColor(this.valueColor())
          .textAlign(TextAlign.End)
      }
      if (this.hasRightIcon()) {
        UPIcon({ props: new UPIconProps({
          name: this.display(this.props.rightIcon),
          color: this.props.rightIconColor,
          size: 18
        }) })
      } else if (this.props.rightIconBuilder !== undefined) {
        this.rightIconRegion()
      }
      if (this.props.righticonBuilder !== undefined) {
        this.righticonRegion()
      }
      this.rightBuilder()
      if (upBoolean(this.props.arrow, false)) {
        Text(this.arrowText())
          .fontSize(22)
          .fontColor(UPColor.neutral('light', '#c0c4cc'))
      }
    }
  }

  @Builder
  private content() {
    Row() {
      this.leftContent()
      this.rightContent()
    }
    .width('100%')
    .height(this.cellMinHeight())
    .padding(this.cellPadding())
    .alignItems(upBoolean(this.props.center, false) ? VerticalAlign.Center : VerticalAlign.Top)
    .borderWidth({ bottom: upBoolean(this.props.border, true) ? 1 : 0 })
    .borderColor(UPColor.adaptive('#eeeeee', 'border-color'))
    .opacity(upBoolean(this.props.disabled, false) ? 0.5 : 1)
    .onClick(() => this.click())
  }

  @Builder
  private iconRegion() {
    UPSlotRegion({ contentBuilder: this.props.iconBuilder })
  }

  @Builder
  private titleRegion() {
    UPSlotRegion({ contentBuilder: this.props.titleBuilder })
  }

  @Builder
  private labelRegion() {
    UPSlotRegion({ contentBuilder: this.props.labelBuilder })
  }

  @Builder
  private valueRegion() {
    UPSlotRegion({ contentBuilder: this.props.valueBuilder })
  }

  @Builder
  private rightIconRegion() {
    UPSlotRegion({ contentBuilder: this.props.rightIconBuilder })
  }

  @Builder
  private righticonRegion() {
    UPSlotRegion({ contentBuilder: this.props.righticonBuilder })
  }

  build() {
    this.content()
  }
}
