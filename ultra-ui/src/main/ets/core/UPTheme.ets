export interface UPThemeValues {
  primary: string;
  warning: string;
  success: string;
  error: string;
  info: string;
  main: string;
  content: string;
  tips: string;
  light: string;
}

/** Immutable-ish theme value object used by the native components. */
export class UPTheme implements UPThemeValues {
  readonly primary: string;
  readonly warning: string;
  readonly success: string;
  readonly error: string;
  readonly info: string;
  readonly main: string;
  readonly content: string;
  readonly tips: string;
  readonly light: string;

  constructor(values?: Partial<UPThemeValues>) {
    this.primary = values?.primary ?? '#2979ff';
    this.warning = values?.warning ?? '#ff9900';
    this.success = values?.success ?? '#19be6b';
    this.error = values?.error ?? '#fa3534';
    this.info = values?.info ?? '#909399';
    this.main = values?.main ?? '#303133';
    this.content = values?.content ?? '#606266';
    this.tips = values?.tips ?? '#909399';
    this.light = values?.light ?? '#c0c4cc';
  }

  color(name: string, fallback: string = this.main): string {
    switch (name.toLowerCase()) {
      case 'primary': return this.primary;
      case 'warning': return this.warning;
      case 'success': return this.success;
      case 'error': return this.error;
      case 'info': return this.info;
      case 'main': return this.main;
      case 'content': return this.content;
      case 'tips': return this.tips;
      case 'light': return this.light;
      default: return fallback;
    }
  }
}

export const UP_DEFAULT_THEME: UPTheme = new UPTheme();
