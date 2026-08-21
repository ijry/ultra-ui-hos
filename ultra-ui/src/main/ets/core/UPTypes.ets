/** Values accepted from generated uview-plus properties. */
export type UPRawValue = string | number | boolean | null | undefined;

/** A small, serializable edge object used by style and padding props. */
export interface UPEdgeInput {
  top?: UPRawValue;
  right?: UPRawValue;
  bottom?: UPRawValue;
  left?: UPRawValue;
  start?: UPRawValue;
  end?: UPRawValue;
}

/** Supported style keys. Unknown keys remain source-compatible through the index signature. */
export interface UPStyleObject {
  width?: UPRawValue;
  height?: UPRawValue;
  margin?: UPRawValue | UPEdgeInput;
  padding?: UPRawValue | UPEdgeInput;
  color?: UPRawValue;
  background?: UPRawValue;
  backgroundColor?: UPRawValue;
  border?: UPRawValue;
  borderColor?: UPRawValue;
  borderWidth?: UPRawValue;
  borderRadius?: UPRawValue;
  fontSize?: UPRawValue;
  fontWeight?: UPRawValue;
  textAlign?: UPRawValue;
  alignItems?: UPRawValue;
  justifyContent?: UPRawValue;
  opacity?: UPRawValue;
  /** Unknown textual declarations are retained for one-time diagnostics. */
  unknownKeys?: Array<string>;
}

/** Text or object form accepted by customStyle. */
export type UPStyleInput = UPStyleObject | string | null | undefined;

export interface UPCompatibilityEvent {
  component: string;
  property: string;
  value: UPRawValue;
  reason: string;
}

export type UPCompatibilityListener = (event: UPCompatibilityEvent) => void;

/** Builder callback used by slot-like component extensions. */
export type UPBuilder = () => void;

export function upString(value: UPRawValue, fallback: string = ''): string {
  return typeof value === 'string' ? value : fallback;
}

export function upNumber(value: UPRawValue, fallback: number = 0): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : fallback;
}

export function upBoolean(value: UPRawValue, fallback: boolean = false): boolean {
  return typeof value === 'boolean' ? value : fallback;
}

export function upValueKey(value: UPRawValue): string {
  if (value === null) {
    return 'null';
  }
  if (value === undefined) {
    return 'undefined';
  }
  return String(value);
}
