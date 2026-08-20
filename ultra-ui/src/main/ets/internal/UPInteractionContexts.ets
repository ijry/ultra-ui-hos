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

export class UPDropdownContext {
  private currentOpenIndex: number = -1;
  private nextIndex: number = 0;
  private onOpenChange?: (index: number) => void;
  private onOpen?: (index: number) => void;
  private onClose?: () => void;

  beginComposition(openIndex: number = -1, onOpenChange?: (index: number) => void,
    onOpen?: (index: number) => void, onClose?: () => void): void {
    this.currentOpenIndex = Number.isFinite(openIndex) ? openIndex : -1;
    this.nextIndex = 0;
    this.onOpenChange = onOpenChange;
    this.onOpen = onOpen;
    this.onClose = onClose;
  }

  itemIndex(): number {
    return this.nextIndex++;
  }

  openIndex(): number {
    return this.currentOpenIndex;
  }

  isOpen(index: number): boolean {
    return this.currentOpenIndex === index;
  }

  requestOpen(index: number): void {
    const nextIndex: number = this.currentOpenIndex === index ? -1 : index;
    this.currentOpenIndex = nextIndex;
    this.onOpenChange?.(nextIndex);
    if (nextIndex >= 0) this.onOpen?.(nextIndex);
    else this.onClose?.();
  }

  close(): void {
    if (this.currentOpenIndex < 0) return;
    this.requestOpen(-1);
  }
}
