import { UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

/** 上游 picker-view-column 的默认行高与列宽。/ Default item height and column width. */
export const UP_PICKER_COLUMN_ITEM_HEIGHT: number = 44;
export const UP_PICKER_COLUMN_WIDTH: string = '100%';

export interface UPPickerColumnOptions {
  itemHeight?: UPRawValue;
  align?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  contentBuilder?: () => void;
}

export class UPPickerColumnProps {
  itemHeight: UPRawValue = UP_PICKER_COLUMN_ITEM_HEIGHT;
  align: UPRawValue = 'center';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  contentBuilder?: () => void;

  constructor(options?: UPPickerColumnOptions) {
    if (options === undefined) {
      return;
    }
    this.itemHeight = options.itemHeight ?? this.itemHeight;
    this.align = options.align ?? this.align;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.contentBuilder = options.contentBuilder;
  }
}

/** align 是否落在支持范围内。/ Whether align is one of the modelled values. */
export function upPickerColumnAlignSupported(align: string): boolean {
  return align.length === 0 || align === 'center' || align === 'left' || align === 'start'
    || align === 'right' || align === 'end';
}

/** align 转 ArkUI 主轴对齐。/ Maps align onto the ArkUI main-axis alignment. */
export function upPickerColumnAlign(align: string): FlexAlign {
  if (align === 'left' || align === 'start') {
    return FlexAlign.Start;
  }
  if (align === 'right' || align === 'end') {
    return FlexAlign.End;
  }
  return FlexAlign.Center;
}

/**
 * u-picker-column 的 HarmonyOS 原生实现：上游是一个空壳插槽容器，这里保持同样的职责。
 * Native u-picker-column: the upstream component is an empty slot container, mirrored here.
 */
@Component
export struct UPPickerColumn {
  @Prop props: UPPickerColumnProps = new UPPickerColumnProps();

  @Builder
  private emptyBuilder() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    const align: string = this.alignName();
    if (!upPickerColumnAlignSupported(align)) {
      diagnostics.report('UPPickerColumn', 'align', this.props.align,
        'align falls back to center because only start, center and end are modelled');
    }
    diagnostics.report('UPPickerColumn', 'picker-view-column', '',
      'the upstream component only wraps a picker-view-column slot, so scrolling stays with the parent picker');
  }

  private alignName(): string {
    return typeof this.props.align === 'string' ? this.props.align : 'center';
  }

  private itemHeightValue(): number {
    return Math.max(1, UPUnit.parse(this.props.itemHeight, 375, UP_PICKER_COLUMN_ITEM_HEIGHT));
  }

  private columnWidth(): number | string {
    return UPStyle.parse(this.props.customStyle).width ?? UP_PICKER_COLUMN_WIDTH;
  }

  private columnBackground(): string {
    const parsed: string | undefined = UPStyle.parse(this.props.customStyle).backgroundColor;
    return parsed ?? UPColor.parse('#00000000', UP_DEFAULT_THEME, '#00000000');
  }

  build() {
    Column() {
      this.contentBuilder()
    }
    .width(this.columnWidth())
    .height(UPStyle.parse(this.props.customStyle).height ?? this.itemHeightValue())
    .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
    .backgroundColor(this.columnBackground())
    .justifyContent(upPickerColumnAlign(this.alignName()))
    .alignItems(HorizontalAlign.Center)
  }
}
