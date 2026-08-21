import { UPTheme, UP_DEFAULT_THEME } from './UPTheme';

export interface UPConfigOptions {
  theme?: UPTheme;
  viewportWidth?: number;
  diagnosticsEnabled?: boolean;
}

/** Shared defaults. Instances are copied so rendering never mutates global configuration. */
export class UPConfig {
  readonly theme: UPTheme;
  readonly viewportWidth: number;
  readonly diagnosticsEnabled: boolean;

  constructor(options?: UPConfigOptions) {
    this.theme = options?.theme ?? UP_DEFAULT_THEME;
    this.viewportWidth = options?.viewportWidth ?? 375;
    this.diagnosticsEnabled = options?.diagnosticsEnabled ?? false;
  }

  copy(options?: UPConfigOptions): UPConfig {
    return new UPConfig({
      theme: options?.theme ?? this.theme,
      viewportWidth: options?.viewportWidth ?? this.viewportWidth,
      diagnosticsEnabled: options?.diagnosticsEnabled ?? this.diagnosticsEnabled
    });
  }
}

export const UP_DEFAULT_CONFIG: UPConfig = new UPConfig();
