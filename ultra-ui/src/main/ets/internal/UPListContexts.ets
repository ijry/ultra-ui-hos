import { UPRawValue, upBoolean, upNumber, upString, upValueKey } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';

export interface UPIndexListSelectEvent {
  value: UPRawValue;
  index: number;
}

export type UPScrollListEdge = 'left' | 'right';

export interface UPScrollListEdgeEvent {
  edge: UPScrollListEdge;
  offset: number;
  maxOffset: number;
}

export interface UPScrollListScrollEvent {
  offset: number;
  maxOffset: number;
}

export class UPListContext {
  grouped: boolean = false;
  private nextIndex: number = 0;
  private anchors: Map<string, number> = new Map<string, number>();
  private scrollRequest?: (index: number) => void;
  private pendingAnchor: string = '';
  private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;

  beginComposition(scrollRequest?: (index: number) => void,
    diagnostics?: UPCompatibilityDiagnostics): void {
    this.grouped = true;
    this.nextIndex = 0;
    this.anchors.clear();
    this.scrollRequest = scrollRequest;
    this.diagnostics = diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  itemIndex(): number {
    const index: number = this.nextIndex;
    this.nextIndex += 1;
    return index;
  }

  registerAnchor(anchor: UPRawValue, index: number): void {
    const key: string = this.anchorKey(anchor);
    if (key.length === 0) {
      return;
    }
    if (this.anchors.has(key)) {
      this.diagnostics.report('UPList', 'anchor', anchor, 'duplicate anchor ignored; the first item remains the scroll target');
      return;
    }
    const safeIndex: number = Math.max(0, upNumber(index, 0));
    this.anchors.set(key, safeIndex);
    if (this.pendingAnchor === key) {
      this.scrollRequest?.(safeIndex);
      this.pendingAnchor = '';
    }
  }

  anchorIndex(anchor: UPRawValue): number {
    const key: string = this.anchorKey(anchor);
    if (key.length === 0) {
      return -1;
    }
    return this.anchors.get(key) ?? -1;
  }

  requestScrollIntoView(anchor: UPRawValue): void {
    const key: string = this.anchorKey(anchor);
    if (key.length === 0) {
      this.pendingAnchor = '';
      return;
    }
    const index: number = this.anchorIndex(key);
    if (index < 0) {
      this.pendingAnchor = key;
      return;
    }
    this.pendingAnchor = '';
    this.scrollRequest?.(index);
  }

  private anchorKey(anchor: UPRawValue): string {
    if (anchor === null || anchor === undefined) {
      return '';
    }
    if (typeof anchor === 'string') {
      return upString(anchor, '');
    }
    return upValueKey(anchor);
  }
}

export class UPIndexListContext {
  grouped: boolean = false;
  private nextIndex: number = 0;
  private values: Array<UPRawValue> = [];
  private keys: Array<string> = [];
  private groupIndices: Map<string, number> = new Map<string, number>();
  private activeKey: string = '';
  private onSelect?: (event: UPIndexListSelectEvent) => void;
  private onChange?: (event: UPIndexListSelectEvent) => void;
  private onCurrentChange?: (value: UPRawValue) => void;
  private scrollRequest?: (index: number) => void;
  private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;

  beginComposition(values: Array<UPRawValue>, current: UPRawValue,
    onSelect?: (event: UPIndexListSelectEvent) => void,
    onChange?: (event: UPIndexListSelectEvent) => void,
    onCurrentChange?: (value: UPRawValue) => void,
    scrollRequest?: (index: number) => void,
    diagnostics?: UPCompatibilityDiagnostics): void {
    this.grouped = true;
    this.nextIndex = 0;
    this.values = [];
    this.keys = [];
    this.groupIndices.clear();
    this.onSelect = onSelect;
    this.onChange = onChange;
    this.onCurrentChange = onCurrentChange;
    this.scrollRequest = scrollRequest;
    this.diagnostics = diagnostics ?? UP_SILENT_DIAGNOSTICS;

    values.forEach((value: UPRawValue): void => {
      const key: string = this.indexKey(value);
      if (key.length === 0) {
        return;
      }
      if (this.keys.includes(key)) {
        this.diagnostics.report('UPIndexList', 'indexList', value, 'duplicate index ignored; the first item remains the scroll target');
        return;
      }
      this.values.push(value);
      this.keys.push(key);
    });

    const currentKey: string = this.indexKey(current);
    this.activeKey = currentKey.length > 0 && this.keys.includes(currentKey) ? currentKey : '';
  }

  itemIndex(value: UPRawValue): number {
    const index: number = this.nextIndex;
    this.nextIndex += 1;
    const key: string = this.indexKey(value);
    if (key.length > 0 && this.keys.includes(key) && !this.groupIndices.has(key)) {
      this.groupIndices.set(key, index);
    }
    return index;
  }

  normalizedItems(): Array<UPRawValue> {
    return this.values.slice();
  }

  isActive(value: UPRawValue): boolean {
    const key: string = this.indexKey(value);
    if (this.activeKey.length > 0) {
      return key === this.activeKey;
    }
    return upBoolean(key.length > 0 && this.keys.length > 0 && key === this.keys[0], false);
  }

  requestSelect(index: number): void {
    const safeIndex: number = upNumber(index, -1);
    if (safeIndex < 0 || safeIndex >= this.values.length || !Number.isInteger(safeIndex)) {
      return;
    }
    const value: UPRawValue = this.values[safeIndex];
    const event: UPIndexListSelectEvent = { value, index: safeIndex };
    const changed: boolean = this.keys[safeIndex] !== this.activeKey;
    this.onSelect?.(event);
    if (changed) {
      this.onChange?.(event);
    }
    this.onCurrentChange?.(value);
    this.scrollRequest?.(this.groupIndices.get(this.keys[safeIndex]) ?? safeIndex);
  }

  requestScrollToIndex(value: UPRawValue): void {
    const key: string = this.indexKey(value);
    const normalizedIndex: number = this.keys.indexOf(key);
    if (normalizedIndex >= 0) {
      this.scrollRequest?.(this.groupIndices.get(key) ?? normalizedIndex);
    }
  }

  private indexKey(value: UPRawValue): string {
    if (value === null || value === undefined) {
      return '';
    }
    if (typeof value === 'string') {
      return upString(value, '');
    }
    return upValueKey(value);
  }
}
