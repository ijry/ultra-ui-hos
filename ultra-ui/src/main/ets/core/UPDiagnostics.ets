import { UPCompatibilityEvent, UPCompatibilityListener, UPRawValue, upValueKey } from './UPTypes';

/** Optional compatibility diagnostics sink. Silent by default. */
export class UPCompatibilityDiagnostics {
  private readonly listener?: UPCompatibilityListener;
  private readonly reported: Set<string> = new Set<string>();

  constructor(listener?: UPCompatibilityListener) {
    this.listener = listener;
  }

  report(component: string, property: string, value: UPRawValue, reason: string): void {
    const key: string = component + '|' + property + '|' + upValueKey(value) + '|' + reason;
    if (this.reported.has(key)) {
      return;
    }
    this.reported.add(key);
    if (this.listener !== undefined) {
      this.listener({ component, property, value, reason });
    }
  }

  reportEvent(event: UPCompatibilityEvent): void {
    this.report(event.component, event.property, event.value, event.reason);
  }

  reset(): void {
    this.reported.clear();
  }

  get size(): number {
    return this.reported.size;
  }
}

export const UP_SILENT_DIAGNOSTICS: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
