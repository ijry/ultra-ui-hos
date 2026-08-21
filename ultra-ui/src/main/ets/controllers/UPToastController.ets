import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';

export type UPToastPosition = 'top' | 'center' | 'bottom';
export type UPToastCompleteReason = 'timeout' | 'manual' | 'replaced';

export interface UPToastCompleteEvent {
  id: number;
  reason: UPToastCompleteReason;
}

export interface UPToastOptions {
  message?: UPRawValue;
  title?: UPRawValue;
  type?: UPRawValue;
  icon?: UPRawValue;
  loading?: UPRawValue;
  position?: UPRawValue;
  duration?: UPRawValue;
  mask?: UPRawValue;
  overlay?: UPRawValue;
  forbidClick?: UPRawValue;
  zIndex?: UPRawValue;
  customStyle?: UPStyleInput;
  onComplete?: (event: UPToastCompleteEvent) => void;
}

/** Immutable snapshot delivered to the single UPToastHost. */
export class UPToastState {
  readonly id: number;
  readonly message: string;
  readonly title: string;
  readonly type: string;
  readonly icon: string;
  readonly loading: boolean;
  readonly position: UPToastPosition;
  readonly duration: number;
  readonly mask: boolean;
  readonly overlay: boolean;
  readonly forbidClick: boolean;
  readonly zIndex: number;
  readonly customStyle: UPStyleInput;
  readonly onComplete?: (event: UPToastCompleteEvent) => void;

  constructor(id: number, options?: UPToastOptions) {
    this.id = id;
    this.message = UPToastController.display(options?.message);
    this.title = UPToastController.display(options?.title);
    this.type = upString(options?.type, 'default');
    this.icon = UPToastController.display(options?.icon);
    this.loading = upBoolean(options?.loading, false);
    this.position = UPToastController.position(options?.position);
    this.duration = UPToastController.duration(options?.duration);
    this.mask = options?.mask !== undefined ? upBoolean(options.mask, false) :
      upBoolean(options?.overlay, false);
    this.overlay = this.mask;
    this.forbidClick = upBoolean(options?.forbidClick, this.mask);
    this.zIndex = UPToastController.nonNegative(options?.zIndex, 1100);
    this.customStyle = options?.customStyle;
    this.onComplete = options?.onComplete;
  }
}

export type UPToastListener = (state: UPToastState | undefined) => void;

/**
 * Lifecycle-safe imperative Toast state machine.
 * A new show() replaces the previous state, and every state completes once.
 */
export class UPToastController {
  private static singleton: UPToastController = new UPToastController();
  private currentState: UPToastState | undefined;
  private listener: UPToastListener | undefined;
  private timerId: number = -1;
  private nextId: number = 0;

  static shared(): UPToastController {
    return UPToastController.singleton;
  }

  static display(value: UPRawValue): string {
    if (value === null || value === undefined) {
      return '';
    }
    return String(value);
  }

  static position(value: UPRawValue): UPToastPosition {
    const source: string = upString(value, 'center').toLowerCase();
    if (source === 'top' || source === 'bottom') {
      return source as UPToastPosition;
    }
    return 'center';
  }

  static duration(value: UPRawValue): number {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value;
    }
    if (typeof value === 'string' && Number.isFinite(Number(value.trim()))) {
      return Number(value.trim());
    }
    return 2000;
  }

  static nonNegative(value: UPRawValue, fallback: number): number {
    const parsed: number = UPToastController.duration(value);
    return Number.isFinite(parsed) && parsed >= 0 ? parsed : fallback;
  }

  mount(listener: UPToastListener): void {
    this.listener = listener;
    listener(this.currentState);
  }

  unmount(): void {
    this.listener = undefined;
  }

  current(): UPToastState | undefined {
    return this.currentState;
  }

  show(options?: UPToastOptions): number {
    if (this.currentState !== undefined) {
      this.complete(this.currentState.id, 'replaced');
    }
    this.clearTimer();
    const id: number = this.nextId + 1;
    this.nextId = id;
    const state: UPToastState = new UPToastState(id, options);
    this.currentState = state;
    this.notify();
    if (state.duration > 0) {
      this.timerId = setTimeout(() => this.complete(id, 'timeout'), state.duration);
    }
    return id;
  }

  close(id?: number): void {
    if (this.currentState === undefined) {
      return;
    }
    if (id !== undefined && id !== this.currentState.id) {
      return;
    }
    this.complete(this.currentState.id, 'manual');
  }

  clear(): void {
    this.close();
  }

  private complete(id: number, reason: UPToastCompleteReason): void {
    const state: UPToastState | undefined = this.currentState;
    if (state === undefined || state.id !== id) {
      return;
    }
    this.clearTimer();
    this.currentState = undefined;
    this.notify();
    state.onComplete?.({ id, reason });
  }

  private notify(): void {
    this.listener?.(this.currentState);
  }

  private clearTimer(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
  }
}

export const UP_TOAST_CONTROLLER: UPToastController = UPToastController.shared();
