import { UPStyleInput, UPStyleObject, UPRawValue, UPEdgeInput } from './UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from './UPDiagnostics';
import { UPUnit, UPEdgeValues } from './UPUnit';
import { UPColor } from './UPColor';
import { UP_DEFAULT_THEME, UPTheme } from './UPTheme';

export interface UPStyleResult {
  width?: number;
  height?: number;
  margin?: UPEdgeValues;
  padding?: UPEdgeValues;
  color?: string;
  background?: string;
  backgroundColor?: string;
  border?: string;
  borderColor?: string;
  borderWidth?: number;
  borderRadius?: number;
  fontSize?: number;
  fontWeight?: string;
  textAlign?: string;
  alignItems?: string;
  justifyContent?: string;
  opacity?: number;
}

/** Converts the supported subset of customStyle to ArkUI-friendly values. */
export class UPStyle {
  static parse(input: UPStyleInput, diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS,
    component: string = 'UPStyle', viewportWidth: number = 375, theme: UPTheme = UP_DEFAULT_THEME): UPStyleResult {
    const result: UPStyleResult = {};
    if (input === null || input === undefined) {
      return result;
    }
    if (typeof input === 'string') {
      const object: UPStyleObject = UPStyle.parseText(input);
      return UPStyle.parseObject(object, diagnostics, component, viewportWidth, theme);
    }
    return UPStyle.parseObject(input, diagnostics, component, viewportWidth, theme);
  }

  static parseText(input: string): UPStyleObject {
    const output: UPStyleObject = {};
    const unknownKeys: Array<string> = [];
    const declarations: Array<string> = input.split(';');
    declarations.forEach((declaration: string): void => {
      const separator: number = declaration.indexOf(':');
      if (separator <= 0) {
        return;
      }
      const key: string = declaration.slice(0, separator).trim();
      const value: string = declaration.slice(separator + 1).trim();
      if (key.length === 0 || value.length === 0) {
        return;
      }
      switch (key) {
        case 'width': output.width = value; break;
        case 'height': output.height = value; break;
        case 'margin': output.margin = value; break;
        case 'padding': output.padding = value; break;
        case 'color': output.color = value; break;
        case 'background': output.background = value; break;
        case 'backgroundColor': output.backgroundColor = value; break;
        case 'border': output.border = value; break;
        case 'borderColor': output.borderColor = value; break;
        case 'borderWidth': output.borderWidth = value; break;
        case 'borderRadius': output.borderRadius = value; break;
        case 'fontSize': output.fontSize = value; break;
        case 'fontWeight': output.fontWeight = value; break;
        case 'textAlign': output.textAlign = value; break;
        case 'alignItems': output.alignItems = value; break;
        case 'justifyContent': output.justifyContent = value; break;
        case 'opacity': output.opacity = value; break;
        default: unknownKeys.push(key);
      }
    });
    if (unknownKeys.length > 0) {
      output.unknownKeys = unknownKeys;
    }
    return output;
  }

  private static parseObject(input: UPStyleObject, diagnostics: UPCompatibilityDiagnostics,
    component: string, viewportWidth: number, theme: UPTheme): UPStyleResult {
    const result: UPStyleResult = {};
    if (input.width !== undefined) result.width = UPStyle.dimension(input.width, viewportWidth);
    if (input.height !== undefined) result.height = UPStyle.dimension(input.height, viewportWidth);
    if (input.margin !== undefined) result.margin = UPUnit.parseEdges(input.margin, viewportWidth);
    if (input.padding !== undefined) result.padding = UPUnit.parseEdges(input.padding, viewportWidth);
    if (input.color !== undefined) result.color = UPColor.parse(input.color, theme);
    if (input.background !== undefined) result.background = UPColor.parse(input.background, theme);
    if (input.backgroundColor !== undefined) result.backgroundColor = UPColor.parse(input.backgroundColor, theme);
    if (input.border !== undefined) result.border = typeof input.border === 'string' ? input.border : undefined;
    if (input.borderColor !== undefined) result.borderColor = UPColor.parse(input.borderColor, theme);
    if (input.borderWidth !== undefined) result.borderWidth = UPStyle.dimension(input.borderWidth, viewportWidth);
    if (input.borderRadius !== undefined) result.borderRadius = UPStyle.dimension(input.borderRadius, viewportWidth);
    if (input.fontSize !== undefined) result.fontSize = UPStyle.dimension(input.fontSize, viewportWidth);
    if (input.fontWeight !== undefined) result.fontWeight = typeof input.fontWeight === 'string' ? input.fontWeight : undefined;
    if (input.textAlign !== undefined) result.textAlign = typeof input.textAlign === 'string' ? input.textAlign : undefined;
    if (input.alignItems !== undefined) result.alignItems = typeof input.alignItems === 'string' ? input.alignItems : undefined;
    if (input.justifyContent !== undefined) result.justifyContent = typeof input.justifyContent === 'string' ? input.justifyContent : undefined;
    if (input.opacity !== undefined) {
      const opacity: number = UPStyle.number(input.opacity, Number.NaN);
      if (Number.isFinite(opacity) && opacity >= 0 && opacity <= 1) {
        result.opacity = opacity;
      }
    }
    input.unknownKeys?.forEach((key: string): void => {
      diagnostics.report(component, key, undefined, 'unsupported customStyle key');
    });
    return result;
  }

  private static dimension(value: UPRawValue | UPEdgeInput | undefined, viewportWidth: number): number | undefined {
    if (value !== null && value !== undefined && typeof value !== 'object') {
      const parsed: number = UPUnit.parse(value as UPRawValue, viewportWidth, Number.NaN);
      return Number.isFinite(parsed) ? parsed : undefined;
    }
    return undefined;
  }

  private static number(value: UPRawValue | UPEdgeInput | undefined, fallback: number): number {
    return typeof value === 'number' && Number.isFinite(value) ? value :
      (typeof value === 'string' && Number.isFinite(Number(value.trim())) ? Number(value.trim()) : fallback);
  }
}
