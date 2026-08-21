import { UPRawValue, upBoolean, upNumber, upString } from '../core/UPTypes';

export interface UPTabsItemData {
  name?: UPRawValue;
  disabled?: UPRawValue;
  icon?: UPRawValue;
  badge?: UPRawValue;
  activeColor?: UPRawValue;
  inactiveColor?: UPRawValue;
}

export interface UPTabsClickEvent {
  item: UPTabsItemData;
  index: number;
}

export class UPTabsContext {
  grouped: boolean = false;
  private items: Array<UPTabsItemData> = [];
  private current: number = 0;
  private onCurrentChange?: (index: number) => void;
  private onChange?: (event: UPTabsClickEvent) => void;
  private onClick?: (event: UPTabsClickEvent) => void;
  private onLongPress?: (event: UPTabsClickEvent) => void;

  beginComposition(items: Array<UPTabsItemData>, current: number = 0,
    onCurrentChange?: (index: number) => void, onChange?: (event: UPTabsClickEvent) => void,
    onClick?: (event: UPTabsClickEvent) => void, onLongPress?: (event: UPTabsClickEvent) => void): void {
    this.grouped = true;
    this.items = items;
    this.current = Number.isFinite(current) ? current : 0;
    this.onCurrentChange = onCurrentChange;
    this.onChange = onChange;
    this.onClick = onClick;
    this.onLongPress = onLongPress;
  }

  itemIndex(): number { return this.items.length; }
  itemAt(index: number): UPTabsItemData { return this.items[index] ?? {}; }
  isCurrent(index: number): boolean { return this.current === index; }

  requestSelect(index: number): void {
    const item: UPTabsItemData = this.itemAt(index);
    const event: UPTabsClickEvent = { item, index };
    this.onClick?.(event);
    if (upBoolean(item.disabled, false) || this.current === index) return;
    this.onCurrentChange?.(index);
    this.onChange?.(event);
  }

  requestLongPress(index: number): void {
    this.onLongPress?.({ item: this.itemAt(index), index });
  }
}

export type UPStepStatus = 'finish' | 'process' | 'wait' | 'error';

export class UPStepsContext {
  current: number = 0;
  direction: string = 'row';
  activeColor: string = '#3c9cff';
  inactiveColor: string = '#969799';
  activeIcon: string = '';
  inactiveIcon: string = '';
  dot: boolean = false;
  private nextIndex: number = 0;

  beginComposition(current: number = 0, direction: UPRawValue = 'row', activeColor: UPRawValue = '#3c9cff',
    inactiveColor: UPRawValue = '#969799', activeIcon: UPRawValue = '', inactiveIcon: UPRawValue = '', dot: UPRawValue = false): void {
    this.current = Math.max(0, upNumber(current, 0));
    const value: string = upString(direction, 'row').toLowerCase();
    this.direction = value === 'column' ? 'column' : 'row';
    this.activeColor = upString(activeColor, '#3c9cff');
    this.inactiveColor = upString(inactiveColor, '#969799');
    this.activeIcon = upString(activeIcon, '');
    this.inactiveIcon = upString(inactiveIcon, '');
    this.dot = upBoolean(dot, false);
    this.nextIndex = 0;
  }

  itemIndex(): number { return this.nextIndex++; }

  stateFor(index: number, error: UPRawValue = false): UPStepStatus {
    if (upBoolean(error, false)) return 'error';
    if (this.current > index) return 'finish';
    if (this.current === index) return 'process';
    return 'wait';
  }

  connectorColor(index: number, nextError: UPRawValue = false): string {
    if (upBoolean(nextError, false)) return '#fa3534';
    return index < this.current ? this.activeColor : this.inactiveColor;
  }
}
