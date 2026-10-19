/**
 * 上游 `libs/theme/theme.js` 的 ArkTS 复刻：明暗模式状态与令牌查表。
 * ArkTS port of the upstream theme runtime. Upstream ships the tokens as CSS custom
 * properties and lets the cascade apply them; ArkTS has no stylesheet layer, so
 * components read tokens explicitly through `UPThemeManager.token()`.
 */
import { UPRawValue } from './UPTypes';
import { UPTheme, UPThemeValues } from './UPTheme';
import { UPThemeTokens } from '../internal/UPThemeTokens';

/** 上游 `themeState.mode` 的取值。/ Upstream theme modes. */
export type UPThemeMode = 'light' | 'dark';

/** 上游 `themeState.preference` 的取值。/ Upstream preference values. */
export type UPThemePreference = 'system' | 'light' | 'dark';

/** 上游默认模式。/ The upstream default mode. */
export const UP_DEFAULT_THEME_MODE: UPThemeMode = 'light';

/** 一条令牌覆盖，取代上游 `config.color` 的对象入参。/ One token override. */
export interface UPThemeOverride {
  token: string;
  value: string;
}

/** 上游 `themeState` 的只读快照。/ A read-only snapshot of the theme state. */
export interface UPThemeSnapshot {
  mode: UPThemeMode;
  preference: UPThemePreference;
  version: number;
}

/** 主题变更监听器。/ Listener invoked after every applied change. */
export type UPThemeListener = (snapshot: UPThemeSnapshot) => void;

function normalizeMode(value: string): UPThemeMode {
  return value === 'dark' ? 'dark' : 'light';
}

function normalizePreference(value: string): UPThemePreference {
  if (value === 'light' || value === 'dark') {
    return value;
  }
  return 'system';
}

/**
 * 全局主题状态。上游用模块级 `themeState` 单例，本端同样用静态单例，
 * 以便组件默认值与渲染分支都能读到当前模式。
 * Module-level theme state, mirroring the upstream `themeState` singleton.
 */
export class UPThemeManager {
  private static currentMode: UPThemeMode = UP_DEFAULT_THEME_MODE;
  private static currentPreference: UPThemePreference = 'system';
  private static currentVersion: number = 0;
  private static overrides: Map<string, string> = new Map<string, string>();
  private static listeners: Array<UPThemeListener> = [];

  /** 当前模式。/ The active mode. */
  static mode(): UPThemeMode {
    return UPThemeManager.currentMode;
  }

  /** 是否暗色。/ Whether the active mode is dark. */
  static isDark(): boolean {
    return UPThemeManager.currentMode === 'dark';
  }

  /** 上游 `getThemePreference()`。/ Upstream getThemePreference(). */
  static preference(): UPThemePreference {
    return UPThemeManager.currentPreference;
  }

  /** 状态快照，等价于上游 `themeState`。/ Snapshot of the upstream themeState. */
  static snapshot(): UPThemeSnapshot {
    return {
      mode: UPThemeManager.currentMode,
      preference: UPThemeManager.currentPreference,
      version: UPThemeManager.currentVersion
    };
  }

  /** 上游 `setTheme(mode)`：显式切换并把偏好锁定到该模式。/ Upstream setTheme(mode). */
  static setMode(mode: string): UPThemeMode {
    const next: UPThemeMode = normalizeMode(mode);
    UPThemeManager.currentPreference = next;
    UPThemeManager.apply(next);
    return UPThemeManager.currentMode;
  }

  /**
   * 上游 `setThemePreference(mode)`：`system` 时按宿主给出的系统模式生效。
   * 上游读 `uni.getAppBaseInfo().theme`，本端不探测平台，改由 `systemMode` 传入。
   * Upstream setThemePreference(mode); the host supplies the system mode.
   */
  static setPreference(preference: string, systemMode: string = UP_DEFAULT_THEME_MODE): UPThemePreference {
    UPThemeManager.currentPreference = normalizePreference(preference);
    if (UPThemeManager.currentPreference === 'system') {
      UPThemeManager.apply(normalizeMode(systemMode));
    } else {
      UPThemeManager.apply(UPThemeManager.currentPreference === 'dark' ? 'dark' : 'light');
    }
    return UPThemeManager.currentPreference;
  }

  /**
   * 宿主把系统模式变化转发进来，仅在偏好为 `system` 时生效。
   * Mirrors the upstream `uni.onThemeChange` handler; the host forwards the event.
   */
  static systemModeChanged(mode: string): UPThemeMode {
    if (UPThemeManager.currentPreference === 'system') {
      UPThemeManager.apply(normalizeMode(mode));
    }
    return UPThemeManager.currentMode;
  }

  /**
   * 读取令牌：先看运行时覆盖，再查当前模式的内置表。
   * 令牌名接受 `main-color`、`up-main-color` 与 `--up-main-color` 三种写法。
   * Reads a token; overrides win over the bundled table.
   */
  static token(name: string, fallback: string = ''): string {
    const key: string = UPThemeManager.normalizeToken(name);
    if (key.length === 0) {
      return fallback;
    }
    const override: string | undefined = UPThemeManager.overrides.get(key);
    if (override !== undefined) {
      return override;
    }
    const value: string = UPThemeTokens.value(UPThemeManager.currentMode, key);
    return value.length > 0 ? value : fallback;
  }

  /** 指定模式读取令牌，便于宿主并列预览。/ Reads a token for an explicit mode. */
  static tokenFor(mode: string, name: string, fallback: string = ''): string {
    const key: string = UPThemeManager.normalizeToken(name);
    if (key.length === 0) {
      return fallback;
    }
    const value: string = UPThemeTokens.value(normalizeMode(mode), key);
    return value.length > 0 ? value : fallback;
  }

  /** 是否内置该令牌。/ Whether the token ships with the library. */
  static hasToken(name: string): boolean {
    return UPThemeTokens.has(UPThemeManager.normalizeToken(name));
  }

  /** 全部令牌名。/ Every bundled token name. */
  static tokens(): Array<string> {
    return UPThemeTokens.names();
  }

  /**
   * 上游 `syncThemeColorOverrideState({ color })`：注册令牌级覆盖。
   * 覆盖跨模式生效（上游的 `config.color` 同样只有一份）。
   * Registers token overrides; they apply to both modes, like upstream config.color.
   */
  static setOverrides(overrides: Array<UPThemeOverride>): void {
    UPThemeManager.overrides = new Map<string, string>();
    for (let index: number = 0; index < overrides.length; index++) {
      const entry: UPThemeOverride = overrides[index];
      const key: string = UPThemeManager.normalizeToken(entry.token);
      if (key.length > 0 && entry.value.length > 0) {
        UPThemeManager.overrides.set(key, entry.value);
      }
    }
    UPThemeManager.apply(UPThemeManager.currentMode);
  }

  /** 上游 `refreshThemeFromConfig()` 的清空分支。/ Drops every override. */
  static clearOverrides(): void {
    UPThemeManager.overrides = new Map<string, string>();
    UPThemeManager.apply(UPThemeManager.currentMode);
  }

  /** 当前模式下的主色系主题对象，供既有 `UPColor.parse()` 复用。/ Theme object for the active mode. */
  static theme(): UPTheme {
    const values: UPThemeValues = {
      primary: UPThemeManager.token('primary', '#3c9cff'),
      warning: UPThemeManager.token('warning', '#f9ae3d'),
      success: UPThemeManager.token('success', '#5ac725'),
      error: UPThemeManager.token('error', '#f56c6c'),
      info: UPThemeManager.token('info', '#909399'),
      main: UPThemeManager.token('main-color', '#303133'),
      content: UPThemeManager.token('content-color', '#606266'),
      tips: UPThemeManager.token('tips-color', '#909193'),
      light: UPThemeManager.token('light-color', '#c0c4cc')
    };
    return new UPTheme(values);
  }

  /** 注册监听器，返回注销函数无法在 ArkTS 里安全持有，故改为显式移除。/ Adds a listener. */
  static addListener(listener: UPThemeListener): void {
    UPThemeManager.listeners.push(listener);
  }

  /** 移除全部监听器。/ Removes every listener. */
  static clearListeners(): void {
    UPThemeManager.listeners = [];
  }

  private static normalizeToken(name: string): string {
    let key: string = name.trim();
    if (key.startsWith('--')) {
      key = key.slice(2);
    }
    if (key.startsWith('up-')) {
      key = key.slice(3);
    } else if (key.startsWith('u-')) {
      key = key.slice(2);
    }
    return key;
  }

  private static apply(mode: UPThemeMode): void {
    UPThemeManager.currentMode = mode;
    UPThemeManager.currentVersion += 1;
    const snapshot: UPThemeSnapshot = UPThemeManager.snapshot();
    for (let index: number = 0; index < UPThemeManager.listeners.length; index++) {
      UPThemeManager.listeners[index](snapshot);
    }
  }
}

/** `UPThemeManager.token()` 的短别名。/ Short alias for UPThemeManager.token(). */
export function upToken(name: string, fallback: string = ''): string {
  return UPThemeManager.token(name, fallback);
}

/** 按当前模式在两个取值间选择，用于没有对应令牌的场合。/ Picks a value by the active mode. */
export function upModeValue(light: UPRawValue, dark: UPRawValue): string {
  const chosen: UPRawValue = UPThemeManager.isDark() ? dark : light;
  return chosen === null || chosen === undefined ? '' : String(chosen);
}
