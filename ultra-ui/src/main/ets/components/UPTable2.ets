import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upString, upValueKey } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { upTableAlign } from '../internal/UPTableContexts';
import { upTableColumnAlign, upTableTextAlign } from './UPTh';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPColor } from '../core/UPColor';

/** One addressable cell of a table row; ArkTS forbids index signatures. */
export interface UPTable2Cell {
  key: string;
  value: UPRawValue;
}

/** Row data model. Children make the row expandable in tree mode. */
export interface UPTable2Row {
  key?: UPRawValue;
  cells: Array<UPTable2Cell>;
  children?: Array<UPTable2Row>;
  hasChildren?: UPRawValue;
  disabled?: UPRawValue;
  selected?: UPRawValue;
}

/** Column model. `type` accepts `default`, `selection` and `expand`. */
/** row-dblclick 的双击判定窗口。/ Double-tap window used for row-dblclick. */
export const UP_TABLE2_DOUBLE_CLICK_INTERVAL: number = 300;

export interface UPTable2Column {
  key?: string;
  title?: string;
  width?: UPRawValue;
  align?: UPRawValue;
  headerAlign?: UPRawValue;
  type?: string;
  sortable?: UPRawValue;
  sortOrders?: Array<string>;
  fixed?: UPRawValue;
  sortBy?: UPRawValue;
  showOverflowTooltip?: UPRawValue;
  style?: UPStyleInput;
}

/** Upstream tree key mapping; the native row model uses typed fields instead. */
export interface UPTable2TreeProps {
  children?: string;
  hasChildren?: string;
}

/** Column filter applied as a case-insensitive substring match. */
export interface UPTable2Filter {
  key: string;
  value: UPRawValue;
}

/** One active sort condition; `order` is `ascending` or `descending`. */
export interface UPTable2SortCondition {
  key: string;
  order: string;
}

/** Flattened tree row produced for the current build pass. */
export interface UPTable2FlatRow {
  row: UPTable2Row;
  level: number;
  rowIndex: number;
  parentKey: string;
}

/** Single-parameter payload for the cell builders; ArkTS builders take one argument. */
export interface UPTable2CellSlot {
  flat: UPTable2FlatRow;
  columnIndex: number;
}

/** 上游 header 插槽作用域。/ Scope handed to the upstream header slot. */
export interface UPTable2HeaderSlot {
  column: UPTable2Column;
  columnIndex: number;
  level: number;
}

/** 上游 headerSort 插槽作用域。/ Scope handed to the upstream headerSort slot. */
export interface UPTable2HeaderSortSlot {
  column: UPTable2Column;
  columnIndex: number;
  level: number;
  sortStatus: string;
}

export interface UPTable2RowEvent {
  row: UPTable2Row;
  rowIndex: number;
}

export interface UPTable2CellEvent {
  row: UPTable2Row;
  column: UPTable2Column;
  columnIndex: number;
  rowIndex: number;
  value: UPRawValue;
}

export interface UPTable2HeaderEvent {
  column: UPTable2Column;
  columnIndex: number;
}

export interface UPTable2SortEvent {
  column: UPTable2Column;
  order: string;
  conditions: Array<UPTable2SortCondition>;
}

/** 上游 filter-change 事件。/ Upstream filter-change payload. */
export interface UPTable2FilterEvent {
  filters: Array<UPTable2Filter>;
}

export interface UPTable2SelectionEvent {
  selection: Array<UPTable2Row>;
  row: UPTable2Row;
  selected: boolean;
}

export interface UPTable2ExpandEvent {
  row: UPTable2Row;
  expanded: boolean;
  expandedKeys: Array<string>;
}

/** Compatibility placeholder for `load`; the native table never invokes it. */
export type UPTable2LoadCallback = (row: UPTable2Row) => void;

/** Compatibility placeholder for `spanMethod`; the native table never invokes it. */
export type UPTable2SpanCallback = (event: UPTable2CellEvent) => void;

export interface UPTable2Options {
  data?: Array<UPTable2Row>;
  columns?: Array<UPTable2Column>;
  stripe?: UPRawValue;
  border?: UPRawValue;
  height?: UPRawValue;
  maxHeight?: UPRawValue;
  showHeader?: UPRawValue;
  fixedHeader?: UPRawValue;
  highlightCurrentRow?: UPRawValue;
  rowKey?: UPRawValue;
  currentRowKey?: UPRawValue;
  rowHeight?: UPRawValue;
  expandWidth?: UPRawValue;
  mainCol?: UPRawValue;
  emptyText?: UPRawValue;
  treeProps?: UPTable2TreeProps;
  defaultExpandAll?: UPRawValue;
  expandRowKeys?: Array<UPRawValue>;
  sortable?: UPRawValue;
  multiSort?: UPRawValue;
  sortOrders?: Array<string>;
  sortBy?: Array<string>;
  sortMethod?: (left: UPTable2Row, right: UPTable2Row, key: string, context: UPRawValue) => number;
  context?: UPRawValue;
  filters?: Array<UPTable2Filter>;
  lazy?: UPRawValue;
  showOverflowTooltip?: UPRawValue;
  rowStyle?: UPStyleInput;
  cellStyle?: UPStyleInput;
  cellClassName?: UPRawValue;
  rowClassName?: UPRawValue;
  headerCellClassName?: UPRawValue;
  spanMethod?: UPTable2SpanCallback;
  load?: UPTable2LoadCallback;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onRowClick?: (event: UPTable2RowEvent) => void;
  onRowDblclick?: (event: UPTable2RowEvent) => void;
  onSelect?: (event: UPTable2SelectionEvent) => void;
  onSelectAll?: (event: UPTable2SelectionEvent) => void;
  onFilterChange?: (event: UPTable2FilterEvent) => void;
  onCellClick?: (event: UPTable2CellEvent) => void;
  onHeaderClick?: (event: UPTable2HeaderEvent) => void;
  onSortChange?: (event: UPTable2SortEvent) => void;
  onSelectionChange?: (event: UPTable2SelectionEvent) => void;
  onExpandChange?: (event: UPTable2ExpandEvent) => void;
  onCurrentChange?: (event: UPTable2RowEvent) => void;
  emptyBuilder?: UPBuilder;
}

/** Data-driven table, source-compatible with the core of uview-plus `u-table2`. */
export class UPTable2Props {
  data: Array<UPTable2Row> = [];
  columns: Array<UPTable2Column> = [];
  stripe: UPRawValue = false;
  border: UPRawValue = false;
  height: UPRawValue = null;
  maxHeight: UPRawValue = null;
  showHeader: UPRawValue = true;
  fixedHeader: UPRawValue = true;
  highlightCurrentRow: UPRawValue = false;
  rowKey: UPRawValue = 'id';
  currentRowKey: UPRawValue = null;
  rowHeight: UPRawValue = '36px';
  expandWidth: UPRawValue = '25px';
  mainCol: UPRawValue = '';
  emptyText: UPRawValue = '暂无数据';
  treeProps: UPTable2TreeProps = { children: 'children', hasChildren: 'hasChildren' };
  defaultExpandAll: UPRawValue = false;
  expandRowKeys: Array<UPRawValue> = [];
  sortable: UPRawValue = false;
  multiSort: UPRawValue = false;
  sortOrders: Array<string> = ['ascending', 'descending'];
  sortBy: Array<string> = [];
  sortMethod?: (left: UPTable2Row, right: UPTable2Row, key: string, context: UPRawValue) => number;
  context: UPRawValue = undefined;
  filters: Array<UPTable2Filter> = [];
  lazy: UPRawValue = false;
  showOverflowTooltip: UPRawValue = false;
  rowStyle: UPStyleInput = undefined;
  cellStyle: UPStyleInput = undefined;
  cellClassName: UPRawValue = null;
  rowClassName: UPRawValue = null;
  headerCellClassName: UPRawValue = null;
  spanMethod?: UPTable2SpanCallback;
  load?: UPTable2LoadCallback;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onRowClick?: (event: UPTable2RowEvent) => void;
  onRowDblclick?: (event: UPTable2RowEvent) => void;
  onSelect?: (event: UPTable2SelectionEvent) => void;
  onSelectAll?: (event: UPTable2SelectionEvent) => void;
  onFilterChange?: (event: UPTable2FilterEvent) => void;
  onCellClick?: (event: UPTable2CellEvent) => void;
  onHeaderClick?: (event: UPTable2HeaderEvent) => void;
  onSortChange?: (event: UPTable2SortEvent) => void;
  onSelectionChange?: (event: UPTable2SelectionEvent) => void;
  onExpandChange?: (event: UPTable2ExpandEvent) => void;
  onCurrentChange?: (event: UPTable2RowEvent) => void;
  emptyBuilder?: UPBuilder;

  constructor(options?: UPTable2Options) {
    if (options === undefined) return;
    this.data = options.data ?? this.data;
    this.columns = options.columns ?? this.columns;
    this.stripe = options.stripe ?? this.stripe;
    this.border = options.border ?? this.border;
    this.height = options.height ?? this.height;
    this.maxHeight = options.maxHeight ?? this.maxHeight;
    this.showHeader = options.showHeader ?? this.showHeader;
    this.fixedHeader = options.fixedHeader ?? this.fixedHeader;
    this.highlightCurrentRow = options.highlightCurrentRow ?? this.highlightCurrentRow;
    this.rowKey = options.rowKey ?? this.rowKey;
    this.currentRowKey = options.currentRowKey ?? this.currentRowKey;
    this.rowHeight = options.rowHeight ?? this.rowHeight;
    this.expandWidth = options.expandWidth ?? this.expandWidth;
    this.mainCol = options.mainCol ?? this.mainCol;
    this.emptyText = options.emptyText ?? this.emptyText;
    this.treeProps = options.treeProps ?? this.treeProps;
    this.defaultExpandAll = options.defaultExpandAll ?? this.defaultExpandAll;
    this.expandRowKeys = options.expandRowKeys ?? this.expandRowKeys;
    this.sortable = options.sortable ?? this.sortable;
    this.multiSort = options.multiSort ?? this.multiSort;
    this.sortOrders = options.sortOrders ?? this.sortOrders;
    this.sortBy = options.sortBy ?? this.sortBy;
    this.sortMethod = options.sortMethod;
    this.context = options.context ?? this.context;
    this.filters = options.filters ?? this.filters;
    this.lazy = options.lazy ?? this.lazy;
    this.showOverflowTooltip = options.showOverflowTooltip ?? this.showOverflowTooltip;
    this.rowStyle = options.rowStyle;
    this.cellStyle = options.cellStyle;
    this.cellClassName = options.cellClassName ?? this.cellClassName;
    this.rowClassName = options.rowClassName ?? this.rowClassName;
    this.headerCellClassName = options.headerCellClassName ?? this.headerCellClassName;
    this.spanMethod = options.spanMethod;
    this.load = options.load;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onRowClick = options.onRowClick;
    this.onRowDblclick = options.onRowDblclick;
    this.onSelect = options.onSelect;
    this.onSelectAll = options.onSelectAll;
    this.onFilterChange = options.onFilterChange;
    this.onCellClick = options.onCellClick;
    this.onHeaderClick = options.onHeaderClick;
    this.onSortChange = options.onSortChange;
    this.onSelectionChange = options.onSelectionChange;
    this.onExpandChange = options.onExpandChange;
    this.onCurrentChange = options.onCurrentChange;
    this.emptyBuilder = options.emptyBuilder;
  }
}

/** Read a cell value by column key; missing keys resolve to undefined. */
export function upTable2Value(row: UPTable2Row, key: string): UPRawValue {
  if (key.length === 0) return undefined;
  const found: UPTable2Cell | undefined = row.cells.find((cell: UPTable2Cell): boolean => cell.key === key);
  return found === undefined ? undefined : found.value;
}

/**
 * 上游 getSortValueBy()：`sortBy` 为数组时按顺序拼接多列，为单键时取该列，否则回退列自身键。
 * Mirrors upstream getSortValueBy(): an array joins several columns, a single key overrides the field.
 */
export function upTable2SortValue(row: UPTable2Row, key: string, sortBy: Array<string>): UPRawValue {
  if (sortBy.length === 0) {
    return upTable2Value(row, key);
  }
  if (sortBy.length === 1) {
    return upTable2Value(row, sortBy[0]);
  }
  const parts: Array<string> = [];
  for (const field of sortBy) {
    const value: UPRawValue = upTable2Value(row, field);
    parts.push(value === null || value === undefined ? '' : String(value));
  }
  return parts.join('');
}

/** 上游 getColumnSortBy()：列级 `sortBy` 优先于表级。/ Mirrors upstream getColumnSortBy(). */
export function upTable2ColumnSortBy(column: UPTable2Column, fallback: Array<string>): Array<string> {
  const value: UPRawValue = column.sortBy;
  if (typeof value === 'string' && value.length > 0) {
    return [value];
  }
  return fallback;
}

function table2Text(value: UPRawValue): string {
  return value === null || value === undefined ? '' : String(value);
}

function table2Compare(left: UPRawValue, right: UPRawValue): number {
  if (typeof left === 'number' && typeof right === 'number') {
    return left === right ? 0 : (left < right ? -1 : 1);
  }
  const a: string = table2Text(left);
  const b: string = table2Text(right);
  return a === b ? 0 : (a < b ? -1 : 1);
}

@Component
export struct UPTable2 {
  @Prop @Watch('resetState') props: UPTable2Props = new UPTable2Props();
  @State private selectedKeys: Array<string> = [];
  @State private expandedKeys: Array<string> = [];
  @State private sortConditions: Array<UPTable2SortCondition> = [];
  @State private currentKey: string = '';
  private lastClickKey: string = '';
  private lastClickAt: number = 0;

  aboutToAppear(): void {
    this.resetState();
    this.reportCompatibility();
  }

  resetState(): void {
    this.selectedKeys = this.collectSelected(this.props.data);
    this.expandedKeys = upBoolean(this.props.defaultExpandAll, false) ?
      this.collectExpandable(this.props.data) :
      this.props.expandRowKeys.map((value: UPRawValue): string => upValueKey(value));
    this.sortConditions = [];
    this.currentKey = this.props.currentRowKey === null || this.props.currentRowKey === undefined ?
      '' : upValueKey(this.props.currentRowKey);
  }

  private diagnosticsSink(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private reportCompatibility(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnosticsSink();
    if (upBoolean(this.props.lazy, false) || this.props.load !== undefined) {
      diagnostics.report('UPTable2', 'lazy', this.props.lazy, 'lazy loading and load() are no-op compatibility fields');
    }
    if (this.props.spanMethod !== undefined) {
      diagnostics.report('UPTable2', 'spanMethod', null, 'cell spanning is a no-op compatibility field');
    }
    if (upBoolean(this.props.showOverflowTooltip, false)) {
      diagnostics.report('UPTable2', 'showOverflowTooltip', this.props.showOverflowTooltip, 'overflow tooltip is a no-op compatibility field');
    }
    if (this.props.cellClassName !== null || this.props.rowClassName !== null || this.props.headerCellClassName !== null) {
      diagnostics.report('UPTable2', 'cellClassName', this.props.cellClassName, 'CSS class names are no-op compatibility fields; use rowStyle or column style');
    }
    if (this.props.cellStyle !== undefined) {
      diagnostics.report('UPTable2', 'cellStyle', null, 'global cellStyle is a no-op compatibility field; use column style');
    }
    const children: string = upString(this.props.treeProps.children, 'children');
    const hasChildren: string = upString(this.props.treeProps.hasChildren, 'hasChildren');
    if (children !== 'children' || hasChildren !== 'hasChildren') {
      diagnostics.report('UPTable2', 'treeProps', children, 'the native row model uses typed children/hasChildren fields');
    }
    this.props.columns.forEach((column: UPTable2Column): void => {
      if (column.fixed !== undefined && column.fixed !== null && column.fixed !== false) {
        diagnostics.report('UPTable2', 'fixed', column.fixed, 'fixed columns are a no-op compatibility field');
      }
    });
  }

  private rowIdentity(row: UPTable2Row): string {
    const byKey: UPRawValue = upTable2Value(row, upString(this.props.rowKey, 'id'));
    if (byKey !== null && byKey !== undefined) return upValueKey(byKey);
    if (row.key !== null && row.key !== undefined) return upValueKey(row.key);
    return row.cells.map((cell: UPTable2Cell): string => cell.key + ':' + table2Text(cell.value)).join('|');
  }

  private hasChildRows(row: UPTable2Row): boolean {
    if (row.children !== undefined && row.children.length > 0) return true;
    return row.hasChildren !== undefined && row.hasChildren !== null && row.hasChildren !== false;
  }

  private collectSelected(rows: Array<UPTable2Row>): Array<string> {
    const keys: Array<string> = [];
    rows.forEach((row: UPTable2Row): void => {
      if (upBoolean(row.selected, false)) keys.push(this.rowIdentity(row));
      if (row.children !== undefined) keys.push(...this.collectSelected(row.children));
    });
    return keys;
  }

  private collectExpandable(rows: Array<UPTable2Row>): Array<string> {
    const keys: Array<string> = [];
    rows.forEach((row: UPTable2Row): void => {
      if (this.hasChildRows(row)) keys.push(this.rowIdentity(row));
      if (row.children !== undefined) keys.push(...this.collectExpandable(row.children));
    });
    return keys;
  }

  private collectRows(rows: Array<UPTable2Row>): Array<UPTable2Row> {
    const flat: Array<UPTable2Row> = [];
    rows.forEach((row: UPTable2Row): void => {
      flat.push(row);
      if (row.children !== undefined) flat.push(...this.collectRows(row.children));
    });
    return flat;
  }

  private mainColumnKey(): string {
    const declared: string = upString(this.props.mainCol, '').trim();
    if (declared.length > 0) return declared;
    const plain: UPTable2Column | undefined = this.props.columns.find((column: UPTable2Column): boolean =>
      column.type === undefined || column.type === 'default');
    return plain === undefined ? '' : upString(plain.key, '');
  }

  private columnSortable(column: UPTable2Column): boolean {
    if (column.sortable !== undefined && column.sortable !== null) return upBoolean(column.sortable, false);
    return upBoolean(this.props.sortable, false);
  }

  private columnSortOrders(column: UPTable2Column): Array<string> {
    const orders: Array<string> = column.sortOrders ?? this.props.sortOrders;
    return orders.length > 0 ? orders : ['ascending', 'descending'];
  }

  private sortOrderOf(key: string): string {
    const found: UPTable2SortCondition | undefined = this.sortConditions.find((item: UPTable2SortCondition): boolean => item.key === key);
    return found === undefined ? '' : found.order;
  }

  private sortIcon(column: UPTable2Column): string {
    const order: string = this.sortOrderOf(upString(column.key, ''));
    if (order === 'ascending') return '↑';
    if (order === 'descending') return '↓';
    return '';
  }

  private filteredRows(rows: Array<UPTable2Row>): Array<UPTable2Row> {
    if (this.props.filters.length === 0) return rows.slice();
    return rows.filter((row: UPTable2Row): boolean => this.props.filters.every((filter: UPTable2Filter): boolean => {
      const keyword: string = table2Text(filter.value).toLowerCase();
      if (keyword.length === 0) return true;
      return table2Text(upTable2Value(row, filter.key)).toLowerCase().includes(keyword);
    }));
  }

  /** 列级 `sortBy` 优先于表级。/ Column-level sortBy overrides the table-level list. */
  private sortKeys(key: string): Array<string> {
    const column: UPTable2Column | undefined = this.props.columns.find((item: UPTable2Column): boolean => item.key === key);
    return column === undefined ? this.props.sortBy : upTable2ColumnSortBy(column, this.props.sortBy);
  }

  private sortedRows(rows: Array<UPTable2Row>): Array<UPTable2Row> {
    const output: Array<UPTable2Row> = this.filteredRows(rows);
    if (this.sortConditions.length === 0) return output;
    return output.sort((left: UPTable2Row, right: UPTable2Row): number => {
      for (let index = 0; index < this.sortConditions.length; index++) {
        const condition: UPTable2SortCondition = this.sortConditions[index];
        const custom: ((left: UPTable2Row, right: UPTable2Row, key: string, context: UPRawValue) => number) | undefined = this.props.sortMethod;
        const keys: Array<string> = this.sortKeys(condition.key);
        const result: number = custom !== undefined
          ? custom(left, right, condition.key, this.props.context)
          : table2Compare(upTable2SortValue(left, condition.key, keys),
            upTable2SortValue(right, condition.key, keys));
        if (result !== 0) return condition.order === 'ascending' ? result : -result;
      }
      return 0;
    });
  }

  /** Depth-first visible rows for the current sort, filter and expand state. */
  flattenedRows(): Array<UPTable2FlatRow> {
    return this.flatten(this.props.data, 1, '');
  }

  private flatten(rows: Array<UPTable2Row>, level: number, parentKey: string): Array<UPTable2FlatRow> {
    const output: Array<UPTable2FlatRow> = [];
    this.sortedRows(rows).forEach((row: UPTable2Row): void => {
      output.push({ row, level, rowIndex: output.length, parentKey });
      if (row.children !== undefined && row.children.length > 0 && this.isExpanded(row)) {
        output.push(...this.flatten(row.children, level + 1, this.rowIdentity(row)));
      }
    });
    return output.map((item: UPTable2FlatRow, index: number): UPTable2FlatRow => {
      return { row: item.row, level: item.level, rowIndex: index, parentKey: item.parentKey };
    });
  }

  private isExpanded(row: UPTable2Row): boolean {
    return this.expandedKeys.includes(this.rowIdentity(row));
  }

  private isSelected(row: UPTable2Row): boolean {
    return this.selectedKeys.includes(this.rowIdentity(row));
  }

  private selectionRows(): Array<UPTable2Row> {
    return this.collectRows(this.props.data).filter((row: UPTable2Row): boolean => this.isSelected(row));
  }

  private toggleSelect(row: UPTable2Row): void {
    if (upBoolean(row.disabled, false)) return;
    const selected: boolean = !this.isSelected(row);
    const affected: Array<string> = [this.rowIdentity(row)];
    if (row.children !== undefined) {
      affected.push(...this.collectRows(row.children).map((child: UPTable2Row): string => this.rowIdentity(child)));
    }
    let keys: Array<string> = this.selectedKeys.filter((key: string): boolean => !affected.includes(key));
    if (selected) keys = [...keys, ...affected];
    this.selectedKeys = keys;
    /** 上游先抛 select，再抛 selection-change。/ Upstream emits select before selection-change. */
    const event: UPTable2SelectionEvent = { selection: this.selectionRows(), row, selected };
    this.props.onSelect?.(event);
    this.props.onSelectionChange?.(event);
  }

  /** 上游 select-all：表头勾选框全选或全不选。/ Upstream select-all from the header checkbox. */
  toggleSelectAll(): void {
    const rows: Array<UPTable2Row> = this.collectRows(this.props.data)
      .filter((row: UPTable2Row): boolean => !upBoolean(row.disabled, false));
    const selected: boolean = this.selectedKeys.length < rows.length;
    this.selectedKeys = selected ? rows.map((row: UPTable2Row): string => this.rowIdentity(row)) : [];
    const first: UPTable2Row = rows.length > 0 ? rows[0] : { cells: [] };
    const event: UPTable2SelectionEvent = { selection: this.selectionRows(), row: first, selected };
    this.props.onSelectAll?.(event);
    this.props.onSelectionChange?.(event);
  }

  /** 上游 filter-change：过滤条件变化时回传当前条件。/ Upstream filter-change payload. */
  notifyFilterChange(): void {
    this.props.onFilterChange?.({ filters: this.props.filters.slice() });
  }

  private toggleExpand(row: UPTable2Row): void {
    const key: string = this.rowIdentity(row);
    const expanded: boolean = !this.expandedKeys.includes(key);
    this.expandedKeys = expanded ?
      [...this.expandedKeys, key] :
      this.expandedKeys.filter((item: string): boolean => item !== key);
    this.props.onExpandChange?.({ row, expanded, expandedKeys: this.expandedKeys.slice() });
  }

  private handleHeaderClick(column: UPTable2Column, columnIndex: number): void {
    this.props.onHeaderClick?.({ column, columnIndex });
    if (!this.columnSortable(column)) return;
    const key: string = upString(column.key, '');
    if (key.length === 0) return;
    const orders: Array<string> = this.columnSortOrders(column);
    const current: string = this.sortOrderOf(key);
    const position: number = current.length === 0 ? -1 : orders.indexOf(current);
    const next: string = position + 1 < orders.length ? orders[position + 1] : '';
    let conditions: Array<UPTable2SortCondition> = this.sortConditions.filter((item: UPTable2SortCondition): boolean => item.key !== key);
    if (!upBoolean(this.props.multiSort, false)) conditions = [];
    if (next.length > 0) conditions = [...conditions, { key, order: next }];
    this.sortConditions = conditions;
    this.props.onSortChange?.({ column, order: next, conditions: this.sortConditions.slice() });
  }

  private handleRowClick(flat: UPTable2FlatRow): void {
    const changed: boolean = this.currentKey !== this.rowIdentity(flat.row);
    this.currentKey = this.rowIdentity(flat.row);
    this.props.onRowClick?.({ row: flat.row, rowIndex: flat.rowIndex });
    if (changed) this.props.onCurrentChange?.({ row: flat.row, rowIndex: flat.rowIndex });
    this.detectDoubleClick(flat);
  }

  /** 上游 row-dblclick：ArkUI 无原生双击，按 300ms 内两次单击判定。/ 300ms double-tap window. */
  private detectDoubleClick(flat: UPTable2FlatRow): void {
    const now: number = Date.now();
    const key: string = this.rowIdentity(flat.row);
    if (key === this.lastClickKey && now - this.lastClickAt <= UP_TABLE2_DOUBLE_CLICK_INTERVAL) {
      this.lastClickKey = '';
      this.lastClickAt = 0;
      this.props.onRowDblclick?.({ row: flat.row, rowIndex: flat.rowIndex });
      return;
    }
    this.lastClickKey = key;
    this.lastClickAt = now;
  }

  private handleCellClick(flat: UPTable2FlatRow, columnIndex: number): void {
    const column: UPTable2Column = this.props.columns[columnIndex];
    this.props.onCellClick?.({
      row: flat.row,
      column,
      columnIndex,
      rowIndex: flat.rowIndex,
      value: upTable2Value(flat.row, upString(column.key, ''))
    });
    this.handleRowClick(flat);
  }

  private columnIndexes(): Array<number> {
    const indexes: Array<number> = [];
    for (let index = 0; index < this.props.columns.length; index++) indexes.push(index);
    return indexes;
  }

  private columnWidth(column: UPTable2Column): number {
    if (column.type === 'selection' || column.type === 'expand') return this.expandColumnWidth();
    const declared: string = table2Text(column.width).trim();
    if (declared.length === 0) return 0;
    const parsed: number = UPUnit.parse(declared, 375, 0);
    return parsed > 0 ? parsed : 0;
  }

  private expandColumnWidth(): number {
    return Math.max(16, UPUnit.parse(this.props.expandWidth, 375, 25));
  }

  private bodyRowHeight(): number {
    return Math.max(20, UPUnit.parse(this.props.rowHeight, 375, 36));
  }

  private hasExpandColumn(): boolean {
    return this.props.columns.some((column: UPTable2Column): boolean => column.type === 'expand');
  }

  /** Glyph of the dedicated expand column; leaf rows keep the cell empty. */
  private expandIcon(row: UPTable2Row): string {
    if (!this.hasChildRows(row)) return '';
    return this.isExpanded(row) ? '▼' : '▶';
  }

  /** 没有独立展开列时，树形箭头回落到主列首部。 */
  private showsInlineExpand(slot: UPTable2CellSlot): boolean {
    if (this.hasExpandColumn() || !this.hasChildRows(slot.flat.row)) return false;
    return this.isMainColumn(this.props.columns[slot.columnIndex]);
  }

  /** 主列承载树形缩进与内联箭头；无 key 的列永不视为主列。 */
  private isMainColumn(column: UPTable2Column): boolean {
    const key: string = upString(column.key, '');
    return key.length > 0 && key === this.mainColumnKey();
  }

  private indentOf(flat: UPTable2FlatRow, column: UPTable2Column): number {
    return this.isMainColumn(column) ? 16 * (flat.level - 1) + 2 : 0;
  }

  private headerAlignOf(column: UPTable2Column): string {
    return upTableAlign(column.headerAlign ?? column.align, 'center');
  }

  private bodyAlignOf(column: UPTable2Column): string {
    return upTableAlign(column.align, 'left');
  }

  private borderRight(columnIndex: number): number {
    if (!upBoolean(this.props.border, false)) return 0;
    return columnIndex + 1 < this.props.columns.length ? 1 : 0;
  }

  private rowBackground(flat: UPTable2FlatRow): string {
    if (upBoolean(this.props.highlightCurrentRow, false) && this.currentKey === this.rowIdentity(flat.row)) return UPColor.adaptive('#f5f7fa', 'table2-highlight-bg-color');
    if (upBoolean(this.props.stripe, false) && flat.rowIndex % 2 === 1) return UPColor.adaptive('#fafafa', 'table2-zebra-bg-color');
    return UPStyle.parse(this.props.rowStyle).backgroundColor ?? '#ffffff';
  }

  private viewportHeight(): number {
    const fixed: number = UPUnit.parse(this.props.height, 375, 0);
    if (fixed > 0) return fixed;
    return UPUnit.parse(this.props.maxHeight, 375, 0);
  }

  @Builder
  private headerRow() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
      ForEach(this.columnIndexes(), (columnIndex: number) => {
        this.headerCell(columnIndex)
      })
    }
    .width('100%')
    .backgroundColor(UPColor.adaptive('#f5f7fa', 'table2-header-bg-color'))
  }

  @Builder
  private headerCell(columnIndex: number) {
    if (this.columnWidth(this.props.columns[columnIndex]) > 0) {
      Column() {
        this.headerCellBody(columnIndex)
      }
      .width(this.columnWidth(this.props.columns[columnIndex]))
    } else {
      Column() {
        this.headerCellBody(columnIndex)
      }
      .layoutWeight(1)
    }
  }

  @Builder
  private defaultHeaderCell(slot: UPTable2HeaderSlot) {
    Text(upString(slot.column.title, ''))
      .fontSize(14)
      .fontColor(UPColor.adaptive('#303133', 'main-color'))
      .fontWeight(FontWeight.Bold)
      .textAlign(upTableTextAlign(this.headerAlignOf(slot.column)))
      .layoutWeight(1)
  }

  @BuilderParam headerBuilder: (slot: UPTable2HeaderSlot) => void = this.defaultHeaderCell;

  @Builder
  private defaultHeaderSort(slot: UPTable2HeaderSortSlot) {
    if (slot.sortStatus.length > 0) {
      Text(slot.sortStatus === 'ascending' ? '↑' : '↓').fontSize(12).fontColor('#2979ff')
    }
  }

  @BuilderParam headerSortBuilder: (slot: UPTable2HeaderSortSlot) => void = this.defaultHeaderSort;

  private headerSlot(columnIndex: number): UPTable2HeaderSlot {
    return { column: this.props.columns[columnIndex], columnIndex, level: 1 };
  }

  private headerSortSlot(columnIndex: number): UPTable2HeaderSortSlot {
    return {
      column: this.props.columns[columnIndex],
      columnIndex,
      level: 1,
      sortStatus: this.sortOrderOf(upString(this.props.columns[columnIndex].key, ''))
    };
  }

  @Builder
  private headerCellBody(columnIndex: number) {
    Column() {
      Row({ space: 2 }) {
        this.headerBuilder(this.headerSlot(columnIndex))
        if (this.columnSortable(this.props.columns[columnIndex])) {
          this.headerSortBuilder(this.headerSortSlot(columnIndex))
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(upTableColumnAlign(this.headerAlignOf(this.props.columns[columnIndex])))
    .padding({ top: 10, bottom: 10, left: 2, right: 2 })
    .border({ width: { bottom: 1, right: this.borderRight(columnIndex) }, color: '#ebeef5' })
    .onClick((): void => this.handleHeaderClick(this.props.columns[columnIndex], columnIndex))
  }

  @Builder
  private bodyRows() {
    ForEach(this.flattenedRows(), (flat: UPTable2FlatRow) => {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
        ForEach(this.columnIndexes(), (columnIndex: number) => {
          this.bodyCell({ flat: flat, columnIndex: columnIndex })
        })
      }
      .width('100%')
      .constraintSize({ minHeight: this.bodyRowHeight() })
      .backgroundColor(this.rowBackground(flat))
    }, (flat: UPTable2FlatRow): string => String(flat.rowIndex) + '-' + this.rowIdentity(flat.row))
  }

  @Builder
  private bodyCell(slot: UPTable2CellSlot) {
    if (this.columnWidth(this.props.columns[slot.columnIndex]) > 0) {
      Column() {
        this.bodyCellBody(slot)
      }
      .width(this.columnWidth(this.props.columns[slot.columnIndex]))
    } else {
      Column() {
        this.bodyCellBody(slot)
      }
      .layoutWeight(1)
    }
  }

  @Builder
  private defaultCell(slot: UPTable2CellSlot) {
    Text(table2Text(upTable2Value(slot.flat.row, upString(this.props.columns[slot.columnIndex].key, ''))))
      .fontSize(UPStyle.parse(this.props.columns[slot.columnIndex].style).fontSize ?? 14)
      .fontColor(UPStyle.parse(this.props.columns[slot.columnIndex].style).color ?? '#606266')
      .textAlign(upTableTextAlign(this.bodyAlignOf(this.props.columns[slot.columnIndex])))
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .layoutWeight(1)
  }

  @BuilderParam cellBuilder: (slot: UPTable2CellSlot) => void = this.defaultCell;

  @Builder
  private bodyCellBody(slot: UPTable2CellSlot) {
    Column() {
      Row({ space: 4 }) {
        if (this.props.columns[slot.columnIndex].type === 'selection') {
          Stack() {
            Text(this.isSelected(slot.flat.row) ? '✓' : '').fontSize(12).fontColor('#ffffff').fontWeight(FontWeight.Bold)
          }
          .width(16)
          .height(16)
          .backgroundColor(this.isSelected(slot.flat.row) ? '#2979ff' : 'transparent')
          .borderWidth(1)
          .borderColor(this.isSelected(slot.flat.row) ? '#2979ff' : '#c8c9cc')
          .borderRadius(3)
          .opacity(upBoolean(slot.flat.row.disabled, false) ? 0.5 : 1)
          .onClick((): void => this.toggleSelect(slot.flat.row))
        } else if (this.props.columns[slot.columnIndex].type === 'expand') {
          Text(this.expandIcon(slot.flat.row))
            .fontSize(11)
            .fontColor(UPColor.adaptive('#909399', 'tips-color'))
            .onClick((): void => this.toggleExpand(slot.flat.row))
        } else {
          if (this.showsInlineExpand(slot)) {
            Text(this.isExpanded(slot.flat.row) ? '▼' : '▶')
              .fontSize(11)
              .fontColor(UPColor.adaptive('#909399', 'tips-color'))
              .onClick((): void => this.toggleExpand(slot.flat.row))
          }
          this.cellBuilder(slot)
        }
      }
      .width('100%')
      .padding({ left: this.indentOf(slot.flat, this.props.columns[slot.columnIndex]) })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(upTableColumnAlign(this.bodyAlignOf(this.props.columns[slot.columnIndex])))
    .padding({ top: 8, bottom: 8, left: 2, right: 2 })
    .border({ width: { bottom: 1, right: this.borderRight(slot.columnIndex) }, color: '#ebeef5' })
    .onClick((): void => this.handleCellClick(slot.flat, slot.columnIndex))
  }

  @Builder
  private bodyContent() {
    Column() {
      if (this.flattenedRows().length === 0 && this.props.emptyBuilder !== undefined) {
        this.emptyRegion()
      } else if (this.flattenedRows().length === 0) {
        Text(table2Text(this.props.emptyText))
          .fontSize(14)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding(20)
      } else {
        this.bodyRows()
      }
    }
    .width('100%')
  }

  @Builder
  private emptyRegion() {
    UPSlotRegion({ contentBuilder: this.props.emptyBuilder })
  }

  build() {
    Column() {
      if (upBoolean(this.props.showHeader, true) && upBoolean(this.props.fixedHeader, true)) {
        this.headerRow()
      }
      if (this.viewportHeight() > 0) {
        Scroll() {
          Column() {
            if (upBoolean(this.props.showHeader, true) && !upBoolean(this.props.fixedHeader, true)) {
              this.headerRow()
            }
            this.bodyContent()
          }
          .width('100%')
        }
        .width('100%')
        .height(this.viewportHeight())
        .scrollBar(BarState.Auto)
        .align(Alignment.Top)
      } else {
        Column() {
          if (upBoolean(this.props.showHeader, true) && !upBoolean(this.props.fixedHeader, true)) {
            this.headerRow()
          }
          this.bodyContent()
        }
        .width('100%')
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffffff')
    .borderWidth(upBoolean(this.props.border, false) ? { top: 1, left: 1, right: 1 } : { top: 0, left: 0, right: 0 })
    .borderColor(UPColor.adaptive('#ebeef5', 'border-color'))
  }
}
