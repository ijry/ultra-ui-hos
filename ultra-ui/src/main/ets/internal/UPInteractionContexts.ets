import { UPRawValue, upBoolean, upValueKey } from '../core/UPTypes';

export type UPCollapseValue = UPRawValue | Array<UPRawValue>;
export interface UPCollapseContextChange { value: UPCollapseValue; name: UPRawValue; open: boolean; }

export class UPCollapseContext {
  grouped: boolean = false;
  accordion: boolean = false;
  disabled: boolean = false;
  clickable: boolean = true;
  private currentValue: UPCollapseValue = [];
  private nextIndex: number = 0;
  private onValueChange?: (value: UPCollapseValue) => void;
  private onChange?: (event: UPCollapseContextChange) => void;

  beginComposition(value: UPCollapseValue = [], accordion: boolean = false, disabled: boolean = false,
    clickable: boolean = true, onValueChange?: (value: UPCollapseValue) => void,
    onChange?: (event: UPCollapseContextChange) => void): void {
    this.grouped = true; this.currentValue = value; this.accordion = accordion;
    this.disabled = disabled; this.clickable = clickable; this.nextIndex = 0;
    this.onValueChange = onValueChange; this.onChange = onChange;
  }

  itemName(name: UPRawValue): UPRawValue {
    const index: number = this.nextIndex++;
    return name === null || name === undefined || String(name).length === 0 ? index : name;
  }
  itemCount(): number { return this.nextIndex; }
  isOpen(name: UPRawValue): boolean {
    if (this.accordion) return upValueKey(this.currentValue as UPRawValue) === upValueKey(name);
    if (!Array.isArray(this.currentValue)) return false;
    return this.currentValue.some((item: UPRawValue): boolean => upValueKey(item) === upValueKey(name));
  }
  requestToggle(name: UPRawValue, itemDisabled: UPRawValue = false, itemClickable: UPRawValue = true): void {
    if (this.disabled || !this.clickable || upBoolean(itemDisabled, false) || !upBoolean(itemClickable, true)) return;
    const wasOpen: boolean = this.isOpen(name);
    let next: UPCollapseValue;
    if (this.accordion) {
      next = wasOpen ? '' : name;
    } else {
      const values: Array<UPRawValue> = Array.isArray(this.currentValue) ? this.currentValue : [];
      next = wasOpen ? values.filter((item: UPRawValue): boolean => upValueKey(item) !== upValueKey(name)) : values.concat([name]);
    }
    this.onValueChange?.(next);
    this.onChange?.({ value: next, name, open: !wasOpen });
  }
}
