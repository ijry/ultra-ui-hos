import { UPRawValue, UPStyleInput, UPBuilder, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPTableStyleContext, UPTableStyleValues } from '../internal/UPTableContexts';
import { UPTr, UPTrProps } from './UPTr';
import { UPTh, UPThProps } from './UPTh';
import { UPTd, UPTdProps } from './UPTd';

/** One data-driven body row; each cell is rendered as a UPTd text cell. */
export interface UPTableRow {
  cells: Array<string>;
}

export interface UPTableOptions {
  borderColor?: UPRawValue;
  align?: UPRawValue;
  padding?: UPRawValue;
  fontSize?: UPRawValue;
  color?: UPRawValue;
  bgColor?: UPRawValue;
  thStyle?: UPStyleInput;
  headers?: Array<string>;
  rows?: Array<UPTableRow>;
  widths?: Array<string>;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

/** Table container, source-compatible with uview-plus `u-table`. */
export class UPTableProps {
  borderColor: UPRawValue = '#e4e7ed';
  align: UPRawValue = 'center';
  padding: UPRawValue = '5px 3px';
  fontSize: UPRawValue = '14px';
  color: UPRawValue = '#606266';
  bgColor: UPRawValue = '#ffffff';
  thStyle: UPStyleInput = undefined;
  headers: Array<string> = [];
  rows: Array<UPTableRow> = [];
  widths: Array<string> = [];
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPTableOptions) {
    if (options === undefined) return;
    this.borderColor = options.borderColor ?? this.borderColor;
    this.align = options.align ?? this.align;
    this.padding = options.padding ?? this.padding;
    this.fontSize = options.fontSize ?? this.fontSize;
    this.color = options.color ?? this.color;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.thStyle = options.thStyle;
    this.headers = options.headers ?? this.headers;
    this.rows = options.rows ?? this.rows;
    this.widths = options.widths ?? this.widths;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPTable {
  @Prop @Watch('refreshContext') props: UPTableProps = new UPTableProps();
  @Provide('UPTableStyleContext') tableContext: UPTableStyleContext = new UPTableStyleContext();
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void {
    this.refreshContext();
  }

  refreshContext(): void {
    const values: UPTableStyleValues = {
      borderColor: this.props.borderColor,
      align: this.props.align,
      padding: this.props.padding,
      fontSize: this.props.fontSize,
      color: this.props.color,
      bgColor: this.props.bgColor,
      thStyle: this.props.thStyle
    };
    this.tableContext = new UPTableStyleContext();
    this.tableContext.beginComposition(values);
  }

  private tableBorderColor(): string {
    return UPStyle.parse(this.props.customStyle).borderColor ?? upString(this.props.borderColor, '#e4e7ed');
  }

  private tableBackground(): string {
    const style: UPStyleInput = this.props.customStyle;
    return UPStyle.parse(style).backgroundColor ?? UPStyle.parse(style).background ?? upString(this.props.bgColor, '#ffffff');
  }

  private dataDriven(): boolean {
    return this.props.headers.length > 0 || this.props.rows.length > 0;
  }

  private columnIndexes(count: number): Array<number> {
    const indexes: Array<number> = [];
    for (let index = 0; index < count; index++) indexes.push(index);
    return indexes;
  }

  private columnWidth(index: number): string {
    return index >= 0 && index < this.props.widths.length ? this.props.widths[index] : '';
  }

  @Builder
  private dataContent() {
    if (this.props.headers.length > 0) {
      UPTr({ props: new UPTrProps() }) {
        ForEach(this.columnIndexes(this.props.headers.length), (index: number) => {
          UPTh({ props: new UPThProps({ width: this.columnWidth(index), text: this.props.headers[index] }) })
        })
      }
    }
    ForEach(this.props.rows, (row: UPTableRow, rowIndex: number) => {
      UPTr({ props: new UPTrProps() }) {
        ForEach(this.columnIndexes(row.cells.length), (index: number) => {
          UPTd({ props: new UPTdProps({ width: this.columnWidth(index), text: row.cells[index] }) })
        })
      }
    }, (row: UPTableRow, rowIndex: number): string => String(rowIndex) + '-' + row.cells.join('|'))
  }

  build() {
    Column() {
      if (this.dataDriven()) {
        this.dataContent()
      } else {
        this.contentBuilder()
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .backgroundColor(this.tableBackground())
    .border({ width: { left: 1, top: 1 }, color: this.tableBorderColor() })
  }
}
