import { UPRawValue } from './UPTypes';
import { UPTheme, UP_DEFAULT_THEME } from './UPTheme';
import { UPThemeManager } from './UPThemeManager';

/** Color parser accepting #RGB, #RGBA, #RRGGBB and #RRGGBBAA plus rgb()/rgba() with 0..1 alpha. */
export class UPColor {
  /**
   * 上游 `main`/`content`/`tips`/`light` 四个中性色在明暗两套里取值不同，
   * 而品牌色（`primary` 等）在上游是模式无关的。因此使用库默认主题时，
   * 中性色改走令牌表以跟随模式，品牌色仍用 `UPTheme` 的既有取值。
   * The four neutral colours differ per mode upstream; brand colours do not.
   */
  private static readonly NEUTRAL_TOKENS: Map<string, string> = new Map<string, string>([
    ['main', 'main-color'],
    ['content', 'content-color'],
    ['tips', 'tips-color'],
    ['light', 'light-color']
  ]);

  /**
   * 解析顺序：主题色名 → 主题令牌名 → 字面色值 → fallback。
   * 令牌分支让 `'bg-color'`、`'up-border-color'` 这类上游 CSS 变量名也能直接传入，
   * 并随 `UPThemeManager` 的明暗模式切换。
   * Resolution order: theme colour name, theme token, literal colour, fallback.
   */
  static parse(value: UPRawValue, theme: UPTheme = UP_DEFAULT_THEME, fallback: string = theme.main): string {
    if (typeof value !== 'string') {
      return fallback;
    }
    const source: string = value.trim();
    if (source.length === 0) {
      return fallback;
    }
    // 调用方沿用库默认主题时，中性色名在暗色模式下取令牌；
    // 浅色模式保持 UPTheme 的既有取值，避免改变已有观感。
    if (theme === UP_DEFAULT_THEME && UPThemeManager.isDark()) {
      const neutral: string | undefined = UPColor.NEUTRAL_TOKENS.get(source.toLowerCase());
      if (neutral !== undefined) {
        return UPThemeManager.token(neutral, theme.color(source, fallback));
      }
    }
    const themed: string = theme.color(source, '');
    if (themed.length > 0) {
      return themed;
    }
    if (UPColor.isHex(source) || UPColor.isRgb(source)) {
      return UPColor.normalize(source);
    }
    const token: string = UPThemeManager.token(source, '');
    if (token.length > 0) {
      return token;
    }
    return fallback;
  }

  /**
   * 库默认主题在当前模式下的中性色，供组件替换 `UP_DEFAULT_THEME.main` 这类直读。
   * 浅色模式返回传入的既有取值，只有暗色模式才查令牌表。
   * Mode-aware neutral; the light mode keeps the caller's existing value.
   */
  static neutral(name: string, light: string): string {
    if (!UPThemeManager.isDark()) {
      return light;
    }
    const token: string | undefined = UPColor.NEUTRAL_TOKENS.get(name.toLowerCase());
    if (token === undefined) {
      return light;
    }
    return UPThemeManager.token(token, light);
  }

  /**
   * 明暗自适应取色：浅色模式返回既有字面值，暗色模式查令牌表。
   *
   * 上游同一语义的颜色在 `config.js` 与 `theme.js` 里有时取值不同
   * （例如 `up-tips-color` 是 `#909399`，而 `theme.js` 的 `tips-color` 是 `#909193`），
   * 因此不能无条件改用令牌值——那会悄悄改变浅色观感。
   * 这里固定「浅色照旧、暗色走令牌」，让暗色可用且浅色零回归。
   * Light mode keeps the existing literal; only dark mode consults the token table.
   */
  static adaptive(light: string, token: string): string {
    if (!UPThemeManager.isDark()) {
      return light;
    }
    return UPThemeManager.token(token, light);
  }

  /**
   * 按当前主题模式解析令牌，未命中时回落字面色值。
   * 组件内的固定色值改用它以支持暗色模式。
   * Resolves a theme token for the active mode, falling back to a literal colour.
   */
  static token(name: string, fallback: string): string {
    const value: string = UPThemeManager.token(name, '');
    return value.length > 0 ? value : fallback;
  }

  static isValid(value: UPRawValue): boolean {
    if (typeof value !== 'string') {
      return false;
    }
    const source: string = value.trim();
    return UPColor.isHex(source) || UPColor.isRgb(source);
  }

  private static isHex(value: string): boolean {
    return /^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(value);
  }

  private static isRgb(value: string): boolean {
    return /^rgba?\(\s*[-+]?\d+(?:\.\d+)?\s*,\s*[-+]?\d+(?:\.\d+)?\s*,\s*[-+]?\d+(?:\.\d+)?(?:\s*,\s*(?:1(?:\.0+)?|0?\.\d+|0))?\s*\)$/i.test(value);
  }

  private static normalize(value: string): string {
    if (value.length === 4) {
      return '#' + value.slice(1).split('').map((part: string): string => part + part).join('');
    }
    if (value.length === 5) {
      const rgb: string = value.slice(1, 4).split('').map((part: string): string => part + part).join('');
      const alpha: string = value.slice(4) + value.slice(4);
      return '#' + rgb + alpha;
    }
    return value;
  }
}
