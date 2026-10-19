/**
 * 上游 `libs/config/zIndex.js` 与 `libs/config/color.js` 的 ArkTS 复刻。
 * ArkTS port of the upstream layering table and the legacy colour palette that
 * uview-plus keeps for backward compatibility.
 */

/** 上游 `zIndex.js` 的层级表，字段名与取值逐项对齐。/ Upstream stacking levels. */
export class UPZIndex {
  static readonly TOAST: number = 10090;
  static readonly NO_NETWORK: number = 10080;
  /** 上游把 popup、actionSheet、keyboard、picker 归到同一层。/ Shared by all popup-like panels. */
  static readonly POPUP: number = 10075;
  static readonly MASK: number = 10070;
  static readonly NAVBAR: number = 980;
  static readonly TOP_TIPS: number = 975;
  static readonly STICKY: number = 970;
  static readonly INDEX_LIST_STICKY: number = 965;

  /** 按上游键名取值，未知键回落 `MASK`。/ Looks a level up by its upstream key. */
  static of(name: string): number {
    switch (name.toLowerCase()) {
      case 'toast': return UPZIndex.TOAST;
      case 'nonetwork': return UPZIndex.NO_NETWORK;
      case 'popup': return UPZIndex.POPUP;
      case 'actionsheet': return UPZIndex.POPUP;
      case 'keyboard': return UPZIndex.POPUP;
      case 'picker': return UPZIndex.POPUP;
      case 'mask': return UPZIndex.MASK;
      case 'navbar': return UPZIndex.NAVBAR;
      case 'toptips': return UPZIndex.TOP_TIPS;
      case 'sticky': return UPZIndex.STICKY;
      case 'indexliststicky': return UPZIndex.INDEX_LIST_STICKY;
      default: return UPZIndex.MASK;
    }
  }
}

/**
 * 上游 `libs/config/color.js` 的兼容调色板。注意它与 `config.js` 的主色不同：
 * 这里 `primary` 是 `#3c9cff`，而组件默认主题（`UPTheme`）用的是 `#2979ff`。
 * The legacy palette; its primary differs from the component theme on purpose.
 */
export class UPLegacyColor {
  static readonly PRIMARY: string = '#3c9cff';
  static readonly INFO: string = '#909399';
  static readonly DEFAULT: string = '#909399';
  static readonly WARNING: string = '#f9ae3d';
  static readonly ERROR: string = '#f56c6c';
  static readonly SUCCESS: string = '#5ac725';
  static readonly MAIN: string = '#303133';
  static readonly CONTENT: string = '#606266';
  static readonly TIPS: string = '#909399';
  static readonly LIGHT: string = '#c0c4cc';
  static readonly BORDER: string = '#e4e7ed';

  /** 按上游键名取值，未知键回落 `MAIN`。/ Looks a legacy colour up by key. */
  static of(name: string): string {
    switch (name.toLowerCase()) {
      case 'primary': return UPLegacyColor.PRIMARY;
      case 'info': return UPLegacyColor.INFO;
      case 'default': return UPLegacyColor.DEFAULT;
      case 'warning': return UPLegacyColor.WARNING;
      case 'error': return UPLegacyColor.ERROR;
      case 'success': return UPLegacyColor.SUCCESS;
      case 'maincolor': return UPLegacyColor.MAIN;
      case 'contentcolor': return UPLegacyColor.CONTENT;
      case 'tipscolor': return UPLegacyColor.TIPS;
      case 'lightcolor': return UPLegacyColor.LIGHT;
      case 'bordercolor': return UPLegacyColor.BORDER;
      default: return UPLegacyColor.MAIN;
    }
  }
}

/** 上游 `config.js` 的 `type` 白名单。/ Upstream theme type whitelist. */
export const UP_THEME_TYPES: Array<string> = ['primary', 'success', 'info', 'error', 'warning'];

/** 上游 `config.js` 的版本号主段。/ Upstream config version marker. */
export const UP_UPSTREAM_CONFIG_VERSION: string = '3';
