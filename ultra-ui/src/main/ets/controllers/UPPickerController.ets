import { UPRawValue } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';

export type UPPickerControllerListener = (columns: Array<Array<UPRawValue>>, indexs: Array<number>) => void;

export class UPPickerController {
  private columns: Array<Array<UPRawValue>> = [];
  private indexs: Array<number> = [];
  private listener?: UPPickerControllerListener;
  private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;

  constructor(diagnostics?: UPCompatibilityDiagnostics) {
    this.diagnostics = diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  mount(listener: UPPickerControllerListener): void {
    this.listener = listener;
    this.notify();
  }

  unmount(): void {
    this.listener = undefined;
  }

  setColumns(columns: Array<Array<UPRawValue>>): void {
    this.columns = columns.map((column: Array<UPRawValue>): Array<UPRawValue> => column.slice());
    this.indexs = this.columns.map((_column: Array<UPRawValue>, index: number): number => this.indexs[index] ?? 0);
    this.normalizeIndexes();
    this.notify();
  }

  setColumnValues(columnIndex: number, values: Array<UPRawValue>): void {
    if (columnIndex < 0 || columnIndex >= this.columns.length) {
      this.diagnostics.report('UPPickerController', 'columnIndex', columnIndex, 'out-of-range column index ignored');
      return;
    }
    this.columns[columnIndex] = values.slice();
    for (let index = columnIndex + 1; index < this.indexs.length; index += 1) {
      this.indexs[index] = 0;
    }
    this.normalizeIndexes();
    this.notify();
  }

  setIndexs(indexs: Array<number>): void {
    this.indexs = indexs.slice();
    this.normalizeIndexes();
    this.notify();
  }

  getIndexs(): Array<number> {
    return this.indexs.slice();
  }

  getValues(): Array<UPRawValue> {
    return this.columns.map((column: Array<UPRawValue>, index: number): UPRawValue => column[this.indexs[index] ?? 0]);
  }

  getColumnValues(columnIndex: number): Array<UPRawValue> {
    if (columnIndex < 0 || columnIndex >= this.columns.length) {
      this.diagnostics.report('UPPickerController', 'columnIndex', columnIndex, 'out-of-range column index ignored');
      return [];
    }
    return this.columns[columnIndex].slice();
  }

  columnsSnapshot(): Array<Array<UPRawValue>> {
    return this.columns.map((column: Array<UPRawValue>): Array<UPRawValue> => column.slice());
  }

  private normalizeIndexes(): void {
    while (this.indexs.length < this.columns.length) this.indexs.push(0);
    if (this.indexs.length > this.columns.length) this.indexs = this.indexs.slice(0, this.columns.length);
    this.indexs = this.indexs.map((value: number, index: number): number => {
      const max: number = this.columns[index].length - 1;
      if (!Number.isFinite(value)) return 0;
      return max < 0 ? 0 : Math.max(0, Math.min(max, Math.floor(value)));
    });
  }

  private notify(): void {
    this.listener?.(this.columnsSnapshot(), this.getIndexs());
  }
}
