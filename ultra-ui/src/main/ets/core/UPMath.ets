/**
 * 上游 `libs/function/digit.js` 与 `libs/function/calc.js` 的 ArkTS 复刻。
 * ArkTS port of the upstream high-precision arithmetic helpers: every operation
 * scales the operands to integers first so binary floating point drift is removed.
 */

/** 越界检查开关，对应上游 `_boundaryCheckingState`。/ Mirrors the upstream boundary flag. */
let boundaryChecking: boolean = true;

/** 最近一次越界的操作数，替代上游的 `console.warn`。/ Last operand that exceeded the safe range. */
let lastBoundaryOverflow: number = 0;

export class UPMath {
  /** 上游 `strip()`：按有效位修正浮点误差。/ Removes floating point noise. */
  static strip(value: number, precision: number = 15): number {
    if (!Number.isFinite(value)) {
      return value;
    }
    const digits: number = Math.max(1, Math.min(21, Math.floor(precision)));
    return Number(Number(value).toPrecision(digits));
  }

  /** 上游 `digitLength()`：小数位数，含科学计数法。/ Decimal digit count. */
  static digitLength(value: number): number {
    if (!Number.isFinite(value)) {
      return 0;
    }
    const parts: Array<string> = String(value).split(/[eE]/);
    const fraction: string = parts[0].split('.')[1] ?? '';
    const exponent: number = parts.length > 1 ? Number(parts[1]) : 0;
    const length: number = fraction.length - exponent;
    return length > 0 ? length : 0;
  }

  /** 上游 `float2Fixed()`：把小数放大为整数。/ Scales a decimal up to an integer. */
  static float2Fixed(value: number): number {
    const source: string = String(value);
    if (source.indexOf('e') === -1 && source.indexOf('E') === -1) {
      return Number(source.replace('.', ''));
    }
    const length: number = UPMath.digitLength(value);
    return length > 0 ? UPMath.strip(value * Math.pow(10, length)) : value;
  }

  /** 上游 `checkBoundary()`：越界时只记录，不打印。/ Records instead of warning. */
  static checkBoundary(value: number): boolean {
    if (!boundaryChecking) {
      return true;
    }
    if (value > Number.MAX_SAFE_INTEGER || value < Number.MIN_SAFE_INTEGER) {
      lastBoundaryOverflow = value;
      return false;
    }
    return true;
  }

  /** 上游 `enableBoundaryChecking()`。/ Toggles boundary checking. */
  static enableBoundaryChecking(flag: boolean = true): void {
    boundaryChecking = flag;
  }

  /** 最近一次越界的值，`0` 表示未发生。/ Last recorded overflow, `0` when none. */
  static lastOverflow(): number {
    return lastBoundaryOverflow;
  }

  /** 上游 `times()` 的两数形态。/ High-precision multiplication. */
  static times(left: number, right: number): number {
    const leftFixed: number = UPMath.float2Fixed(left);
    const rightFixed: number = UPMath.float2Fixed(right);
    const scale: number = UPMath.digitLength(left) + UPMath.digitLength(right);
    const product: number = leftFixed * rightFixed;
    UPMath.checkBoundary(product);
    return product / Math.pow(10, scale);
  }

  /** 上游 `plus()` 的两数形态。/ High-precision addition. */
  static plus(left: number, right: number): number {
    const scale: number = Math.pow(10, Math.max(UPMath.digitLength(left), UPMath.digitLength(right)));
    return (UPMath.times(left, scale) + UPMath.times(right, scale)) / scale;
  }

  /** 上游 `minus()` 的两数形态。/ High-precision subtraction. */
  static minus(left: number, right: number): number {
    const scale: number = Math.pow(10, Math.max(UPMath.digitLength(left), UPMath.digitLength(right)));
    return (UPMath.times(left, scale) - UPMath.times(right, scale)) / scale;
  }

  /** 上游 `divide()` 的两数形态。/ High-precision division. */
  static divide(left: number, right: number): number {
    const leftFixed: number = UPMath.float2Fixed(left);
    const rightFixed: number = UPMath.float2Fixed(right);
    UPMath.checkBoundary(leftFixed);
    UPMath.checkBoundary(rightFixed);
    const scale: number = UPMath.strip(Math.pow(10, UPMath.digitLength(right) - UPMath.digitLength(left)));
    return UPMath.times(leftFixed / rightFixed, scale);
  }

  /** 上游 `round()`：按位四舍五入，负数保留符号。/ Rounds to the given decimals. */
  static round(value: number, decimals: number): number {
    const base: number = Math.pow(10, Math.max(0, Math.floor(decimals)));
    let result: number = UPMath.divide(Math.round(Math.abs(UPMath.times(value, base))), base);
    if (value < 0 && result !== 0) {
      result = UPMath.times(result, -1);
    }
    return result;
  }

  /** 上游 `iteratorOperation()` 的加法折叠。/ Folds a list with `plus`. */
  static plusAll(values: Array<number>): number {
    return UPMath.fold(values, 0, 'plus');
  }

  /** 上游 `iteratorOperation()` 的减法折叠。/ Folds a list with `minus`. */
  static minusAll(values: Array<number>): number {
    return UPMath.fold(values, 0, 'minus');
  }

  /** 上游 `iteratorOperation()` 的乘法折叠。/ Folds a list with `times`. */
  static timesAll(values: Array<number>): number {
    return UPMath.fold(values, 1, 'times');
  }

  /** 上游 `iteratorOperation()` 的除法折叠。/ Folds a list with `divide`. */
  static divideAll(values: Array<number>): number {
    return UPMath.fold(values, 1, 'divide');
  }

  /** 上游 `range()`：把数值夹在闭区间内。/ Clamps a number into a closed range. */
  static clamp(minimum: number, maximum: number, value: number): number {
    if (!Number.isFinite(value)) {
      return minimum;
    }
    return Math.max(minimum, Math.min(maximum, value));
  }

  private static fold(values: Array<number>, fallback: number, operation: string): number {
    if (values.length === 0) {
      return fallback;
    }
    let result: number = values[0];
    for (let index: number = 1; index < values.length; index++) {
      result = UPMath.apply(result, values[index], operation);
    }
    return result;
  }

  private static apply(left: number, right: number, operation: string): number {
    if (operation === 'plus') {
      return UPMath.plus(left, right);
    }
    if (operation === 'minus') {
      return UPMath.minus(left, right);
    }
    if (operation === 'divide') {
      return UPMath.divide(left, right);
    }
    return UPMath.times(left, right);
  }
}
