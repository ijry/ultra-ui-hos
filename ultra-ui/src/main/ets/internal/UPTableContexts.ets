import { UPRawValue, UPStyleInput, upString } from '../core/UPTypes';

/** Normalize an upstream table alignment token to left/center/right. */
export function upTableAlign(value: UPRawValue, fallback: string = 'center'): string {
  if (typeof value !== 'string') {
    return fallback;
  }
  const candidate: string = value.trim().toLowerCase();
  if (candidate === 'left' || candidate === 'start') {
    return 'left';
  }
  if (candidate === 'right' || candidate === 'end') {
    return 'right';
  }
  if (candidate === 'center' || candidate === 'middle') {
    return 'center';
  }
  return fallback;
}

/** Values pushed from UPTable into the shared style context on every build pass. */
export interface UPTableStyleValues {
  borderColor?: UPRawValue;
  align?: UPRawValue;
  padding?: UPRawValue;
  fontSize?: UPRawValue;
  color?: UPRawValue;
  bgColor?: UPRawValue;
  thStyle?: UPStyleInput;
}

/** Read-only style context provided by UPTable to nested UPTr/UPTh/UPTd children. */
export class UPTableStyleContext {
  grouped: boolean = false;
  borderColor: string = '#e4e7ed';
  align: string = 'center';
  padding: string = '5px 3px';
  fontSize: string = '14px';
  color: string = '#606266';
  bgColor: string = '#ffffff';
  thStyle: UPStyleInput = undefined;
  private nextRow: number = 0;

  /** Reset the render-local row counter and adopt the current table styles. */
  beginComposition(values?: UPTableStyleValues): void {
    this.grouped = true;
    this.nextRow = 0;
    if (values === undefined) {
      return;
    }
    this.borderColor = upString(values.borderColor, this.borderColor);
    this.align = upTableAlign(values.align, this.align);
    this.padding = upString(values.padding, this.padding);
    this.fontSize = upString(values.fontSize, this.fontSize);
    this.color = upString(values.color, this.color);
    this.bgColor = upString(values.bgColor, this.bgColor);
    this.thStyle = values.thStyle;
  }

  /** Allocate the next visual row index; never persisted outside a build pass. */
  rowIndex(): number {
    const index: number = this.nextRow;
    this.nextRow = this.nextRow + 1;
    return index;
  }

  /** Number of UPTr children allocated during the current composition. */
  rowCount(): number {
    return this.nextRow;
  }
}
