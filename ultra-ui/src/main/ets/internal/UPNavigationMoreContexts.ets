import { UPRawValue, upValueKey } from '../core/UPTypes';

export class UPSwipeActionContext {
  private currentName: UPRawValue = '';
  private autoClose: boolean = true;
  private nextIndex: number = 0;
  private onOpenChange?: (name: UPRawValue) => void;
  private onClose?: () => void;

  beginComposition(name: UPRawValue = '', autoClose: boolean = true,
    onOpenChange?: (name: UPRawValue) => void, onClose?: () => void): void {
    this.currentName = name; this.autoClose = autoClose; this.nextIndex = 0;
    this.onOpenChange = onOpenChange; this.onClose = onClose;
  }

  itemName(name: UPRawValue): UPRawValue {
    const index: number = this.nextIndex++;
    return name === null || name === undefined || String(name).length === 0 ? index : name;
  }

  openName(): UPRawValue { return this.currentName; }
  isOpen(name: UPRawValue): boolean { return upValueKey(this.currentName) === upValueKey(name); }
  requestOpen(name: UPRawValue): void {
    if (upValueKey(this.currentName) === upValueKey(name)) return;
    this.currentName = name; this.onOpenChange?.(name);
  }
  closeAll(): void {
    if (this.currentName === '' || this.currentName === null || this.currentName === undefined) return;
    this.currentName = ''; this.onClose?.();
  }
}
