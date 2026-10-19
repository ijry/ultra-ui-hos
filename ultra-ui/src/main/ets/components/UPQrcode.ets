import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPLoadingIcon, UPLoadingIconProps } from './UPLoadingIcon';
import { upCanvasParseSize, upCanvasUnitSupported, isLocalCanvasSource } from './UPCanvas';

/** 上游 PAD0 填充码字。/ Upstream PAD0 padding codeword. */
const UP_QRCODE_PAD0: number = 0xEC;

/** 上游 PAD1 填充码字。/ Upstream PAD1 padding codeword. */
const UP_QRCODE_PAD1: number = 0x11;

/** 上游 QRErrorCorrectLevel：lv 0..3 映射到 L/M/Q/H 的位模式。/ Upstream QRErrorCorrectLevel. */
const UP_QRCODE_ERROR_CORRECT_LEVEL: Array<number> = [1, 0, 3, 2];

/** 上游 G15 生成多项式。/ Upstream G15 generator polynomial. */
const UP_QRCODE_G15: number = (1 << 10) | (1 << 8) | (1 << 5) | (1 << 4) | (1 << 2) | (1 << 1) | (1 << 0);

/** 上游 G18 生成多项式。/ Upstream G18 generator polynomial. */
const UP_QRCODE_G18: number = (1 << 12) | (1 << 11) | (1 << 10) | (1 << 9) | (1 << 8) | (1 << 5) | (1 << 2) | (1 << 0);

/** 上游 G15_MASK 掩码。/ Upstream G15_MASK. */
const UP_QRCODE_G15_MASK: number = (1 << 14) | (1 << 12) | (1 << 10) | (1 << 4) | (1 << 1);

/** 版本 1..40 的校正图形中心坐标，与上游 PATTERN_POSITION_TABLE 完全一致。/ Upstream PATTERN_POSITION_TABLE. */
const UP_QRCODE_PATTERN_POSITION_TABLE: Array<Array<number>> = [
  [], [6, 18], [6, 22], [6, 26], [6, 30], [6, 34], [6, 22, 38], [6, 24, 42], [6, 26, 46], [6, 28, 50],
  [6, 30, 54], [6, 32, 58], [6, 34, 62], [6, 26, 46, 66], [6, 26, 48, 70], [6, 26, 50, 74], [6, 30, 54, 78],
  [6, 30, 56, 82], [6, 30, 58, 86], [6, 34, 62, 90], [6, 28, 50, 72, 94], [6, 26, 50, 74, 98],
  [6, 30, 54, 78, 102], [6, 28, 54, 80, 106], [6, 32, 58, 84, 110], [6, 30, 58, 86, 114], [6, 34, 62, 90, 118],
  [6, 26, 50, 74, 98, 122], [6, 30, 54, 78, 102, 126], [6, 26, 52, 78, 104, 130], [6, 30, 56, 82, 108, 134],
  [6, 34, 60, 86, 112, 138], [6, 30, 58, 86, 114, 142], [6, 34, 62, 90, 118, 146], [6, 30, 54, 78, 102, 126, 150],
  [6, 24, 50, 76, 102, 128, 154], [6, 28, 54, 80, 106, 132, 158], [6, 32, 58, 84, 110, 136, 162],
  [6, 26, 54, 82, 110, 138, 166], [6, 30, 58, 86, 114, 142, 170]
];

/**
 * RS 分块表，索引 `(版本 - 1) * 4 + 容错级别`，三元组含义为 `[块数, 每块总码字, 每块数据码字]`，多段拼接表示混合块。
 * Upstream RS_BLOCK_TABLE indexed by `(typeNumber - 1) * 4 + errorCorrectLevel`.
 */
const UP_QRCODE_RS_BLOCK_TABLE: Array<Array<number>> = [
  [1, 26, 19], [1, 26, 16], [1, 26, 13], [1, 26, 9],
  [1, 44, 34], [1, 44, 28], [1, 44, 22], [1, 44, 16],
  [1, 70, 55], [1, 70, 44], [2, 35, 17], [2, 35, 13],
  [1, 100, 80], [2, 50, 32], [2, 50, 24], [4, 25, 9],
  [1, 134, 108], [2, 67, 43], [2, 33, 15, 2, 34, 16], [2, 33, 11, 2, 34, 12],
  [2, 86, 68], [4, 43, 27], [4, 43, 19], [4, 43, 15],
  [2, 98, 78], [4, 49, 31], [2, 32, 14, 4, 33, 15], [4, 39, 13, 1, 40, 14],
  [2, 121, 97], [2, 60, 38, 2, 61, 39], [4, 40, 18, 2, 41, 19], [4, 40, 14, 2, 41, 15],
  [2, 146, 116], [3, 58, 36, 2, 59, 37], [4, 36, 16, 4, 37, 17], [4, 36, 12, 4, 37, 13],
  [2, 86, 68, 2, 87, 69], [4, 69, 43, 1, 70, 44], [6, 43, 19, 2, 44, 20], [6, 43, 15, 2, 44, 16],
  [4, 101, 81], [1, 80, 50, 4, 81, 51], [4, 50, 22, 4, 51, 23], [3, 36, 12, 8, 37, 13],
  [2, 116, 92, 2, 117, 93], [6, 58, 36, 2, 59, 37], [4, 46, 20, 6, 47, 21], [7, 42, 14, 4, 43, 15],
  [4, 133, 107], [8, 59, 37, 1, 60, 38], [8, 44, 20, 4, 45, 21], [12, 33, 11, 4, 34, 12],
  [3, 145, 115, 1, 146, 116], [4, 64, 40, 5, 65, 41], [11, 36, 16, 5, 37, 17], [11, 36, 12, 5, 37, 13],
  [5, 109, 87, 1, 110, 88], [5, 65, 41, 5, 66, 42], [5, 54, 24, 7, 55, 25], [11, 36, 12],
  [5, 122, 98, 1, 123, 99], [7, 73, 45, 3, 74, 46], [15, 43, 19, 2, 44, 20], [3, 45, 15, 13, 46, 16],
  [1, 135, 107, 5, 136, 108], [10, 74, 46, 1, 75, 47], [1, 50, 22, 15, 51, 23], [2, 42, 14, 17, 43, 15],
  [5, 150, 120, 1, 151, 121], [9, 69, 43, 4, 70, 44], [17, 50, 22, 1, 51, 23], [2, 42, 14, 19, 43, 15],
  [3, 141, 113, 4, 142, 114], [3, 70, 44, 11, 71, 45], [17, 47, 21, 4, 48, 22], [9, 39, 13, 16, 40, 14],
  [3, 135, 107, 5, 136, 108], [3, 67, 41, 13, 68, 42], [15, 54, 24, 5, 55, 25], [15, 43, 15, 10, 44, 16],
  [4, 144, 116, 4, 145, 117], [17, 68, 42], [17, 50, 22, 6, 51, 23], [19, 46, 16, 6, 47, 17],
  [2, 139, 111, 7, 140, 112], [17, 74, 46], [7, 54, 24, 16, 55, 25], [34, 37, 13],
  [4, 151, 121, 5, 152, 122], [4, 75, 47, 14, 76, 48], [11, 54, 24, 14, 55, 25], [16, 45, 15, 14, 46, 16],
  [6, 147, 117, 4, 148, 118], [6, 73, 45, 14, 74, 46], [11, 54, 24, 16, 55, 25], [30, 46, 16, 2, 47, 17],
  [8, 132, 106, 4, 133, 107], [8, 75, 47, 13, 76, 48], [7, 54, 24, 22, 55, 25], [22, 45, 15, 13, 46, 16],
  [10, 142, 114, 2, 143, 115], [19, 74, 46, 4, 75, 47], [28, 50, 22, 6, 51, 23], [33, 46, 16, 4, 47, 17],
  [8, 152, 122, 4, 153, 123], [22, 73, 45, 3, 74, 46], [8, 53, 23, 26, 54, 24], [12, 45, 15, 28, 46, 16],
  [3, 147, 117, 10, 148, 118], [3, 73, 45, 23, 74, 46], [4, 54, 24, 31, 55, 25], [11, 45, 15, 31, 46, 16],
  [7, 146, 116, 7, 147, 117], [21, 73, 45, 7, 74, 46], [1, 53, 23, 37, 54, 24], [19, 45, 15, 26, 46, 16],
  [5, 145, 115, 10, 146, 116], [19, 75, 47, 10, 76, 48], [15, 54, 24, 25, 55, 25], [23, 45, 15, 25, 46, 16],
  [13, 145, 115, 3, 146, 116], [2, 74, 46, 29, 75, 47], [42, 54, 24, 1, 55, 25], [23, 45, 15, 28, 46, 16],
  [17, 145, 115], [10, 74, 46, 23, 75, 47], [10, 54, 24, 35, 55, 25], [19, 45, 15, 35, 46, 16],
  [17, 145, 115, 1, 146, 116], [14, 74, 46, 21, 75, 47], [29, 54, 24, 19, 55, 25], [11, 45, 15, 46, 46, 16],
  [13, 145, 115, 6, 146, 116], [14, 74, 46, 23, 75, 47], [44, 54, 24, 7, 55, 25], [59, 46, 16, 1, 47, 17],
  [12, 151, 121, 7, 152, 122], [12, 75, 47, 26, 76, 48], [39, 54, 24, 14, 55, 25], [22, 45, 15, 41, 46, 16],
  [6, 151, 121, 14, 152, 122], [6, 75, 47, 34, 76, 48], [46, 54, 24, 10, 55, 25], [2, 45, 15, 64, 46, 16],
  [17, 152, 122, 4, 153, 123], [29, 74, 46, 14, 75, 47], [49, 54, 24, 10, 55, 25], [24, 45, 15, 46, 46, 16],
  [4, 152, 122, 18, 153, 123], [13, 74, 46, 32, 75, 47], [48, 54, 24, 14, 55, 25], [42, 45, 15, 32, 46, 16],
  [20, 147, 117, 4, 148, 118], [40, 75, 47, 7, 76, 48], [43, 54, 24, 22, 55, 25], [10, 45, 15, 67, 46, 16],
  [19, 148, 118, 6, 149, 119], [18, 75, 47, 31, 76, 48], [34, 54, 24, 34, 55, 25], [20, 45, 15, 61, 46, 16]
];

/** 上游 QRMath：GF(256) 的指数与对数表。/ Upstream QRMath over GF(256). */
class UPQrcodeGaloisField {
  private readonly expTable: Array<number> = [];
  private readonly logTable: Array<number> = [];

  constructor() {
    for (let index: number = 0; index < 256; index += 1) {
      this.expTable.push(0);
      this.logTable.push(0);
    }
    for (let index: number = 0; index < 8; index += 1) {
      this.expTable[index] = 1 << index;
    }
    for (let index: number = 8; index < 256; index += 1) {
      this.expTable[index] = this.expTable[index - 4] ^ this.expTable[index - 5]
        ^ this.expTable[index - 6] ^ this.expTable[index - 8];
    }
    for (let index: number = 0; index < 255; index += 1) {
      this.logTable[this.expTable[index]] = index;
    }
  }

  /** 上游 gexp()：把指数折回 0..255 后查表。/ Upstream gexp(). */
  gexp(value: number): number {
    let numeric: number = value;
    while (numeric < 0) {
      numeric += 255;
    }
    while (numeric >= 256) {
      numeric -= 255;
    }
    return this.expTable[numeric];
  }

  /** 上游 glog() 在 n < 1 时抛错，本端返回 0：上游调用链从未触达该分支。/ Upstream glog() throws below 1; this port returns 0. */
  glog(value: number): number {
    if (value < 1) {
      return 0;
    }
    return this.logTable[value];
  }
}

const UP_QRCODE_FIELD: UPQrcodeGaloisField = new UPQrcodeGaloisField();

/** 上游 QRPolynomial：GF(256) 上的多项式。/ Upstream QRPolynomial. */
class UPQrcodePolynomial {
  private readonly num: Array<number> = [];

  constructor(source: Array<number>, shift: number) {
    let offset: number = 0;
    while (offset < source.length && source[offset] === 0) {
      offset += 1;
    }
    const total: number = source.length - offset + shift;
    for (let index: number = 0; index < total; index += 1) {
      this.num.push(0);
    }
    for (let index: number = 0; index < source.length - offset; index += 1) {
      this.num[index] = source[index + offset];
    }
  }

  get(index: number): number {
    return this.num[index];
  }

  getLength(): number {
    return this.num.length;
  }

  /** 上游 multiply()：多项式相乘。/ Upstream multiply(). */
  multiply(other: UPQrcodePolynomial): UPQrcodePolynomial {
    const total: number = this.getLength() + other.getLength() - 1;
    const product: Array<number> = [];
    for (let index: number = 0; index < total; index += 1) {
      product.push(0);
    }
    for (let left: number = 0; left < this.getLength(); left += 1) {
      for (let right: number = 0; right < other.getLength(); right += 1) {
        product[left + right] = product[left + right]
          ^ UP_QRCODE_FIELD.gexp(UP_QRCODE_FIELD.glog(this.get(left)) + UP_QRCODE_FIELD.glog(other.get(right)));
      }
    }
    return new UPQrcodePolynomial(product, 0);
  }

  /** 上游 mod()：多项式取余，上游递归实现在此改为等价循环。/ Upstream recursive mod(), flattened into a loop. */
  mod(other: UPQrcodePolynomial): UPQrcodePolynomial {
    const otherLength: number = other.getLength();
    if (this.getLength() - otherLength < 0) {
      return this;
    }
    const remainder: Array<number> = [];
    for (let index: number = 0; index < this.getLength(); index += 1) {
      remainder.push(this.get(index));
    }
    while (remainder.length >= otherLength) {
      const ratio: number = UP_QRCODE_FIELD.glog(remainder[0]) - UP_QRCODE_FIELD.glog(other.get(0));
      for (let index: number = 0; index < otherLength; index += 1) {
        remainder[index] = remainder[index] ^ UP_QRCODE_FIELD.gexp(UP_QRCODE_FIELD.glog(other.get(index)) + ratio);
      }
      while (remainder.length > 0 && remainder[0] === 0) {
        remainder.shift();
      }
    }
    return new UPQrcodePolynomial(remainder, 0);
  }
}

/** 上游 QRBitBuffer：按位写入的数据缓冲。/ Upstream QRBitBuffer. */
class UPQrcodeBitBuffer {
  readonly buffer: Array<number> = [];
  length: number = 0;

  get(index: number): number {
    return (this.buffer[Math.floor(index / 8)] >>> (7 - index % 8)) & 1;
  }

  /** 上游 put()：高位在前写入 length 个比特。/ Upstream put(). */
  put(num: number, length: number): void {
    for (let index: number = 0; index < length; index += 1) {
      this.putBit(((num >>> (length - index - 1)) & 1) === 1);
    }
  }

  /** 上游 putBit()。/ Upstream putBit(). */
  putBit(bit: boolean): void {
    const bufferIndex: number = Math.floor(this.length / 8);
    if (this.buffer.length <= bufferIndex) {
      this.buffer.push(0);
    }
    if (bit) {
      this.buffer[bufferIndex] = this.buffer[bufferIndex] | (0x80 >>> (this.length % 8));
    }
    this.length += 1;
  }
}

/** 上游 unicodeFormat8()：单个码点转 UTF-8 字节。/ Upstream unicodeFormat8(). */
export function upQrcodeUnicodeFormat8(code: number): Array<number> {
  if (code < 128) {
    return [code];
  }
  if (code < 2048) {
    return [192 + (code >> 6), 128 + (code & 63)];
  }
  return [224 + (code >> 12), 128 + ((code >> 6) & 63), 128 + (code & 63)];
}

/** 上游 utf8Bytes()：整串转 UTF-8 字节序列。/ Upstream utf8Bytes(). */
export function upQrcodeUtf8Bytes(text: string): Array<number> {
  const bytes: Array<number> = [];
  for (let index: number = 0; index < text.length; index += 1) {
    const parts: Array<number> = upQrcodeUnicodeFormat8(text.charCodeAt(index));
    for (let cursor: number = 0; cursor < parts.length; cursor += 1) {
      bytes.push(parts[cursor]);
    }
  }
  return bytes;
}

/** 上游 QRUtil.getBCHDigit()。/ Upstream getBCHDigit(). */
function upQrcodeBchDigit(value: number): number {
  let digit: number = 0;
  let data: number = value;
  while (data !== 0) {
    digit += 1;
    data >>>= 1;
  }
  return digit;
}

/** 上游 getBCHTypeInfo()：格式信息的 BCH 编码。/ Upstream getBCHTypeInfo(). */
export function upQrcodeBchTypeInfo(data: number): number {
  let value: number = data << 10;
  while (upQrcodeBchDigit(value) - upQrcodeBchDigit(UP_QRCODE_G15) >= 0) {
    value ^= UP_QRCODE_G15 << (upQrcodeBchDigit(value) - upQrcodeBchDigit(UP_QRCODE_G15));
  }
  return ((data << 10) | value) ^ UP_QRCODE_G15_MASK;
}

/** 上游 getBCHTypeNumber()：版本信息的 BCH 编码。/ Upstream getBCHTypeNumber(). */
export function upQrcodeBchTypeNumber(data: number): number {
  let value: number = data << 12;
  while (upQrcodeBchDigit(value) - upQrcodeBchDigit(UP_QRCODE_G18) >= 0) {
    value ^= UP_QRCODE_G18 << (upQrcodeBchDigit(value) - upQrcodeBchDigit(UP_QRCODE_G18));
  }
  return (data << 12) | value;
}

/** 上游 getMask()：8 种掩码图形。/ Upstream getMask(). */
export function upQrcodeMaskAt(pattern: number, row: number, col: number): boolean {
  if (pattern === 0) {
    return (row + col) % 2 === 0;
  }
  if (pattern === 1) {
    return row % 2 === 0;
  }
  if (pattern === 2) {
    return col % 3 === 0;
  }
  if (pattern === 3) {
    return (row + col) % 3 === 0;
  }
  if (pattern === 4) {
    return (Math.floor(row / 2) + Math.floor(col / 3)) % 2 === 0;
  }
  if (pattern === 5) {
    return ((row * col) % 2 + (row * col) % 3) === 0;
  }
  if (pattern === 6) {
    return ((row * col) % 2 + (row * col) % 3) % 2 === 0;
  }
  return (((row * col) % 3 + (row + col) % 2) % 2) === 0;
}

/** 上游 getErrorCorrectPolynomial()。/ Upstream getErrorCorrectPolynomial(). */
function upQrcodeErrorCorrectPolynomial(length: number): UPQrcodePolynomial {
  let poly: UPQrcodePolynomial = new UPQrcodePolynomial([1], 0);
  for (let index: number = 0; index < length; index += 1) {
    poly = poly.multiply(new UPQrcodePolynomial([1, UP_QRCODE_FIELD.gexp(index)], 0));
  }
  return poly;
}

/**
 * 上游 QRCodeAlg：把文本编码成布尔矩阵。上游用 `null` 表示未填充格，ArkTS 不支持稀疏矩阵，
 * 因此本端用平行的 filled 表记录填充状态，语义与上游 `modules[r][c] != null` 完全等价。
 * Upstream QRCodeAlg; the nullable matrix is replaced by a boolean matrix plus a parallel filled matrix.
 */
export class UPQrcodeEncoder {
  private typeNumber: number = -1;
  private errorCorrectLevel: number = 0;
  private moduleCount: number = 0;
  private totalDataCount: number = -1;
  private rsBlock: Array<number> = [];
  private modules: Array<Array<boolean>> = [];
  private filled: Array<Array<boolean>> = [];
  private dataCache: Array<number> = [];
  private readonly bytes: Array<number> = [];

  constructor(text: string, level: number) {
    this.errorCorrectLevel = level;
    this.bytes = upQrcodeUtf8Bytes(text);
    this.make();
  }

  /** 矩阵边长，等于 `版本 * 4 + 17`。/ Matrix side length. */
  getModuleCount(): number {
    return this.moduleCount;
  }

  /** 选中的版本号 1..40。/ The resolved QR version. */
  getTypeNumber(): number {
    return this.typeNumber;
  }

  /** 该版本下的数据码字总数。/ Total data codewords for the resolved version. */
  getTotalDataCount(): number {
    return this.totalDataCount;
  }

  /** 单格是否为深色。/ Whether the module is dark. */
  isDark(row: number, col: number): boolean {
    if (row < 0 || col < 0 || row >= this.moduleCount || col >= this.moduleCount) {
      return false;
    }
    return this.modules[row][col];
  }

  private make(): void {
    this.resolveType();
    this.dataCache = this.createData();
    this.createQrcode();
  }

  /** 上游 getRightType()：选出容得下内容的最小版本。/ Upstream getRightType(). */
  private resolveType(): void {
    for (let typeNumber: number = 1; typeNumber < 41; typeNumber += 1) {
      const rsBlock: Array<number> = UP_QRCODE_RS_BLOCK_TABLE[(typeNumber - 1) * 4 + this.errorCorrectLevel];
      const groups: number = rsBlock.length / 3;
      let totalDataCount: number = 0;
      for (let index: number = 0; index < groups; index += 1) {
        totalDataCount += rsBlock[index * 3 + 2] * rsBlock[index * 3 + 0];
      }
      const lengthBytes: number = typeNumber > 9 ? 2 : 1;
      if (this.bytes.length + lengthBytes < totalDataCount || typeNumber === 40) {
        this.typeNumber = typeNumber;
        this.rsBlock = rsBlock;
        this.totalDataCount = totalDataCount;
        break;
      }
    }
  }

  /** 上游 createData()：写模式指示符、长度、字节流与 PAD 填充。/ Upstream createData(). */
  private createData(): Array<number> {
    const buffer: UPQrcodeBitBuffer = new UPQrcodeBitBuffer();
    const lengthBits: number = this.typeNumber > 9 ? 16 : 8;
    buffer.put(4, 4);
    buffer.put(this.bytes.length, lengthBits);
    for (let index: number = 0; index < this.bytes.length; index += 1) {
      buffer.put(this.bytes[index], 8);
    }
    if (buffer.length + 4 <= this.totalDataCount * 8) {
      buffer.put(0, 4);
    }
    while (buffer.length % 8 !== 0) {
      buffer.putBit(false);
    }
    let usePad0: boolean = true;
    while (buffer.length < this.totalDataCount * 8) {
      buffer.put(usePad0 ? UP_QRCODE_PAD0 : UP_QRCODE_PAD1, 8);
      usePad0 = !usePad0;
    }
    return this.createBytes(buffer);
  }

  /** 上游 createBytes()：分块计算 RS 纠错码并交错输出。/ Upstream createBytes(). */
  private createBytes(buffer: UPQrcodeBitBuffer): Array<number> {
    let offset: number = 0;
    let maxDataCount: number = 0;
    let maxErrorCount: number = 0;
    const groups: number = this.rsBlock.length / 3;
    const dataCounts: Array<number> = [];
    const totalCounts: Array<number> = [];
    for (let index: number = 0; index < groups; index += 1) {
      const count: number = this.rsBlock[index * 3 + 0];
      const totalCount: number = this.rsBlock[index * 3 + 1];
      const dataCount: number = this.rsBlock[index * 3 + 2];
      for (let cursor: number = 0; cursor < count; cursor += 1) {
        dataCounts.push(dataCount);
        totalCounts.push(totalCount);
      }
    }
    const dataBlocks: Array<Array<number>> = [];
    const errorBlocks: Array<Array<number>> = [];
    for (let block: number = 0; block < dataCounts.length; block += 1) {
      const dataCount: number = dataCounts[block];
      const errorCount: number = totalCounts[block] - dataCount;
      maxDataCount = Math.max(maxDataCount, dataCount);
      maxErrorCount = Math.max(maxErrorCount, errorCount);
      const dataBlock: Array<number> = [];
      for (let index: number = 0; index < dataCount; index += 1) {
        dataBlock.push(0xff & buffer.buffer[index + offset]);
      }
      dataBlocks.push(dataBlock);
      offset += dataCount;
      const rsPoly: UPQrcodePolynomial = upQrcodeErrorCorrectPolynomial(errorCount);
      const rawPoly: UPQrcodePolynomial = new UPQrcodePolynomial(dataBlock, rsPoly.getLength() - 1);
      const modPoly: UPQrcodePolynomial = rawPoly.mod(rsPoly);
      const errorBlock: Array<number> = [];
      const errorLength: number = rsPoly.getLength() - 1;
      for (let index: number = 0; index < errorLength; index += 1) {
        const modIndex: number = index + modPoly.getLength() - errorLength;
        errorBlock.push(modIndex >= 0 ? modPoly.get(modIndex) : 0);
      }
      errorBlocks.push(errorBlock);
    }
    const data: Array<number> = [];
    for (let index: number = 0; index < this.totalDataCount; index += 1) {
      data.push(0);
    }
    let cursor: number = 0;
    for (let index: number = 0; index < maxDataCount; index += 1) {
      for (let block: number = 0; block < dataBlocks.length; block += 1) {
        if (index < dataBlocks[block].length) {
          data[cursor] = dataBlocks[block][index];
          cursor += 1;
        }
      }
    }
    for (let index: number = 0; index < maxErrorCount; index += 1) {
      for (let block: number = 0; block < errorBlocks.length; block += 1) {
        if (index < errorBlocks[block].length) {
          data[cursor] = errorBlocks[block][index];
          cursor += 1;
        }
      }
    }
    return data;
  }

  private resetMatrix(): void {
    this.moduleCount = this.typeNumber * 4 + 17;
    this.modules = [];
    this.filled = [];
    for (let row: number = 0; row < this.moduleCount; row += 1) {
      const cells: Array<boolean> = [];
      const flags: Array<boolean> = [];
      for (let col: number = 0; col < this.moduleCount; col += 1) {
        cells.push(false);
        flags.push(false);
      }
      this.modules.push(cells);
      this.filled.push(flags);
    }
  }

  private setModule(row: number, col: number, dark: boolean): void {
    this.modules[row][col] = dark;
    this.filled[row][col] = true;
  }

  /** 上游 makeImpl()：按指定掩码铺满整张矩阵。/ Upstream makeImpl(). */
  private makeImpl(mask: number): void {
    this.resetMatrix();
    this.setupProbe(0, 0);
    this.setupProbe(this.moduleCount - 7, 0);
    this.setupProbe(0, this.moduleCount - 7);
    this.setupAdjust();
    this.setupTiming();
    this.setupTypeInfo(true, mask);
    if (this.typeNumber >= 7) {
      this.setupTypeNumber(true);
    }
    this.mapData(this.dataCache, mask);
  }

  /** 上游 setupPositionProbePattern()：三个定位角点。/ Upstream position probe pattern. */
  private setupProbe(row: number, col: number): void {
    for (let deltaRow: number = -1; deltaRow <= 7; deltaRow += 1) {
      if (row + deltaRow <= -1 || this.moduleCount <= row + deltaRow) {
        continue;
      }
      for (let deltaCol: number = -1; deltaCol <= 7; deltaCol += 1) {
        if (col + deltaCol <= -1 || this.moduleCount <= col + deltaCol) {
          continue;
        }
        const dark: boolean = (0 <= deltaRow && deltaRow <= 6 && (deltaCol === 0 || deltaCol === 6))
          || (0 <= deltaCol && deltaCol <= 6 && (deltaRow === 0 || deltaRow === 6))
          || (2 <= deltaRow && deltaRow <= 4 && 2 <= deltaCol && deltaCol <= 4);
        this.setModule(row + deltaRow, col + deltaCol, dark);
      }
    }
  }

  /** 上游 setupPositionAdjustPattern()：校正图形。/ Upstream position adjust pattern. */
  private setupAdjust(): void {
    const positions: Array<number> = UP_QRCODE_PATTERN_POSITION_TABLE[this.typeNumber - 1];
    for (let outer: number = 0; outer < positions.length; outer += 1) {
      for (let inner: number = 0; inner < positions.length; inner += 1) {
        const row: number = positions[outer];
        const col: number = positions[inner];
        if (this.filled[row][col]) {
          continue;
        }
        for (let deltaRow: number = -2; deltaRow <= 2; deltaRow += 1) {
          for (let deltaCol: number = -2; deltaCol <= 2; deltaCol += 1) {
            const dark: boolean = deltaRow === -2 || deltaRow === 2 || deltaCol === -2 || deltaCol === 2
              || (deltaRow === 0 && deltaCol === 0);
            this.setModule(row + deltaRow, col + deltaCol, dark);
          }
        }
      }
    }
  }

  /** 上游 setupTimingPattern()：横竖两条定位线。/ Upstream timing pattern. */
  private setupTiming(): void {
    for (let index: number = 8; index < this.moduleCount - 8; index += 1) {
      if (this.filled[index][6]) {
        continue;
      }
      this.setModule(index, 6, index % 2 === 0);
      if (this.filled[6][index]) {
        continue;
      }
      this.setModule(6, index, index % 2 === 0);
    }
  }

  /** 上游 setupTypeNumber()：版本 7 起写入版本信息。/ Upstream setupTypeNumber(). */
  private setupTypeNumber(test: boolean): void {
    const bits: number = upQrcodeBchTypeNumber(this.typeNumber);
    for (let index: number = 0; index < 18; index += 1) {
      const dark: boolean = !test && ((bits >> index) & 1) === 1;
      this.setModule(Math.floor(index / 3), index % 3 + this.moduleCount - 8 - 3, dark);
      this.setModule(index % 3 + this.moduleCount - 8 - 3, Math.floor(index / 3), dark);
    }
  }

  /** 上游 setupTypeInfo()：写入格式信息。/ Upstream setupTypeInfo(). */
  private setupTypeInfo(test: boolean, mask: number): void {
    const data: number = (UP_QRCODE_ERROR_CORRECT_LEVEL[this.errorCorrectLevel] << 3) | mask;
    const bits: number = upQrcodeBchTypeInfo(data);
    for (let index: number = 0; index < 15; index += 1) {
      const dark: boolean = !test && ((bits >> index) & 1) === 1;
      if (index < 6) {
        this.setModule(index, 8, dark);
      } else if (index < 8) {
        this.setModule(index + 1, 8, dark);
      } else {
        this.setModule(this.moduleCount - 15 + index, 8, dark);
      }
    }
    for (let index: number = 0; index < 15; index += 1) {
      const dark: boolean = !test && ((bits >> index) & 1) === 1;
      if (index < 8) {
        this.setModule(8, this.moduleCount - index - 1, dark);
      } else if (index < 9) {
        this.setModule(8, 15 - index - 1 + 1, dark);
      } else {
        this.setModule(8, 15 - index - 1, dark);
      }
    }
    this.setModule(this.moduleCount - 8, 8, !test);
  }

  /** 上游 mapData()：蛇形填充数据区并施加掩码。/ Upstream mapData(). */
  private mapData(data: Array<number>, mask: number): void {
    let increment: number = -1;
    let row: number = this.moduleCount - 1;
    let bitIndex: number = 7;
    let byteIndex: number = 0;
    for (let col: number = this.moduleCount - 1; col > 0; col -= 2) {
      if (col === 6) {
        col -= 1;
      }
      let running: boolean = true;
      while (running) {
        for (let side: number = 0; side < 2; side += 1) {
          if (!this.filled[row][col - side]) {
            let dark: boolean = false;
            if (byteIndex < data.length) {
              dark = ((data[byteIndex] >>> bitIndex) & 1) === 1;
            }
            if (upQrcodeMaskAt(mask, row, col - side)) {
              dark = !dark;
            }
            this.setModule(row, col - side, dark);
            bitIndex -= 1;
            if (bitIndex === -1) {
              byteIndex += 1;
              bitIndex = 7;
            }
          }
        }
        row += increment;
        if (row < 0 || this.moduleCount <= row) {
          row -= increment;
          increment = -increment;
          running = false;
        }
      }
    }
  }

  /** 上游 getLostPoint()：掩码罚分。上游 `head ^ current` 在布尔矩阵下等价于 `head !== current`。/ Upstream getLostPoint(). */
  private lostPoint(): number {
    const count: number = this.moduleCount;
    let lost: number = 0;
    let darkCount: number = 0;
    for (let row: number = 0; row < count; row += 1) {
      let sameCount: number = 0;
      let head: boolean = this.modules[row][0];
      for (let col: number = 0; col < count; col += 1) {
        const current: boolean = this.modules[row][col];
        if (col < count - 6) {
          if (current && !this.modules[row][col + 1] && this.modules[row][col + 2] && this.modules[row][col + 3]
            && this.modules[row][col + 4] && !this.modules[row][col + 5] && this.modules[row][col + 6]) {
            if (col < count - 10) {
              if (this.modules[row][col + 7] && this.modules[row][col + 8]
                && this.modules[row][col + 9] && this.modules[row][col + 10]) {
                lost += 40;
              }
            } else if (col > 3) {
              if (this.modules[row][col - 1] && this.modules[row][col - 2]
                && this.modules[row][col - 3] && this.modules[row][col - 4]) {
                lost += 40;
              }
            }
          }
        }
        if (row < count - 1 && col < count - 1) {
          let block: number = 0;
          if (current) {
            block += 1;
          }
          if (this.modules[row + 1][col]) {
            block += 1;
          }
          if (this.modules[row][col + 1]) {
            block += 1;
          }
          if (this.modules[row + 1][col + 1]) {
            block += 1;
          }
          if (block === 0 || block === 4) {
            lost += 3;
          }
        }
        if (head !== current) {
          sameCount += 1;
        } else {
          head = current;
          if (sameCount >= 5) {
            lost += 3 + sameCount - 5;
          }
          sameCount = 1;
        }
        if (current) {
          darkCount += 1;
        }
      }
    }
    for (let col: number = 0; col < count; col += 1) {
      let sameCount: number = 0;
      let head: boolean = this.modules[0][col];
      for (let row: number = 0; row < count; row += 1) {
        const current: boolean = this.modules[row][col];
        if (row < count - 6) {
          if (current && !this.modules[row + 1][col] && this.modules[row + 2][col] && this.modules[row + 3][col]
            && this.modules[row + 4][col] && !this.modules[row + 5][col] && this.modules[row + 6][col]) {
            if (row < count - 10) {
              if (this.modules[row + 7][col] && this.modules[row + 8][col]
                && this.modules[row + 9][col] && this.modules[row + 10][col]) {
                lost += 40;
              }
            } else if (row > 3) {
              if (this.modules[row - 1][col] && this.modules[row - 2][col]
                && this.modules[row - 3][col] && this.modules[row - 4][col]) {
                lost += 40;
              }
            }
          }
        }
        if (head !== current) {
          sameCount += 1;
        } else {
          head = current;
          if (sameCount >= 5) {
            lost += 3 + sameCount - 5;
          }
          sameCount = 1;
        }
      }
    }
    const ratio: number = Math.abs(100 * darkCount / count / count - 50) / 5;
    return lost + ratio * 10;
  }

  /** 上游 createQrcode()：八种掩码取罚分最小者。/ Upstream createQrcode(). */
  private createQrcode(): void {
    let minLostPoint: number = 0;
    let pattern: number = 0;
    let bestModules: Array<Array<boolean>> = [];
    let bestFilled: Array<Array<boolean>> = [];
    for (let index: number = 0; index < 8; index += 1) {
      this.makeImpl(index);
      const lost: number = this.lostPoint();
      if (index === 0 || minLostPoint > lost) {
        minLostPoint = lost;
        pattern = index;
        bestModules = this.modules;
        bestFilled = this.filled;
      }
    }
    this.modules = bestModules;
    this.filled = bestFilled;
    this.setupTypeInfo(false, pattern);
    if (this.typeNumber >= 7) {
      this.setupTypeNumber(false);
    }
  }
}

/** 上游随机 cid 的等价实现。/ Mirrors the upstream random canvasId default. */
export function upQrcodeId(): string {
  return `u-qrcode-canvas${Math.floor(Math.random() * 1000000)}`;
}

/** 上游 lv 到内部容错级别索引的钳制，越界回落 3（H）。/ Clamps lv into 0..3, falling back to 3. */
export function upQrcodeLevel(value: UPRawValue): number {
  const level: number = Math.floor(upNumber(value, 3));
  if (!Number.isFinite(level) || level < 0 || level > 3) {
    return 3;
  }
  return level;
}

/**
 * 上游 getForeGround()：三个定位角周围的格子使用 pdground，其余使用 foreground。
 * Mirrors upstream getForeGround(); the three finder-pattern cores use pdground.
 */
export function upQrcodeForeground(row: number, col: number, count: number,
  foreground: string, pdground: string): string {
  if (pdground.length === 0) {
    return foreground;
  }
  const topLeft: boolean = row > 1 && row < 5 && col > 1 && col < 5;
  const bottomLeft: boolean = row > count - 6 && row < count - 2 && col > 1 && col < 5;
  const topRight: boolean = row > 1 && row < 5 && col > count - 6 && col < count - 2;
  return topLeft || bottomLeft || topRight ? pdground : foreground;
}

export interface UPQrcodeOptions {
  cid?: UPRawValue;
  size?: UPRawValue;
  unit?: UPRawValue;
  show?: UPRawValue;
  val?: UPRawValue;
  background?: UPRawValue;
  foreground?: UPRawValue;
  pdground?: UPRawValue;
  icon?: UPRawValue;
  iconSize?: UPRawValue;
  lv?: UPRawValue;
  quietZone?: UPRawValue;
  onval?: UPRawValue;
  loadMake?: UPRawValue;
  usingComponents?: UPRawValue;
  showLoading?: UPRawValue;
  loadingText?: UPRawValue;
  allowPreview?: UPRawValue;
  useRootHeightAndWidth?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onPreview?: (url: string) => void;
  onResult?: (result: string) => void;
  onLongpress?: (result: string) => void;
  onLongpressCallback?: (result: string) => void;
  onError?: (message: string) => void;
}

export class UPQrcodeProps {
  cid: UPRawValue = '';
  size: UPRawValue = 200;
  unit: UPRawValue = 'px';
  show: UPRawValue = true;
  val: UPRawValue = '';
  background: UPRawValue = '#ffffff';
  foreground: UPRawValue = '#000000';
  pdground: UPRawValue = '#000000';
  icon: UPRawValue = '';
  iconSize: UPRawValue = 40;
  lv: UPRawValue = 3;
  quietZone: UPRawValue = 0;
  onval: UPRawValue = true;
  loadMake: UPRawValue = true;
  usingComponents: UPRawValue = true;
  showLoading: UPRawValue = true;
  loadingText: UPRawValue = '生成中';
  allowPreview: UPRawValue = false;
  useRootHeightAndWidth: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onPreview?: (url: string) => void;
  onResult?: (result: string) => void;
  onLongpress?: (result: string) => void;
  onLongpressCallback?: (result: string) => void;
  onError?: (message: string) => void;

  constructor(options?: UPQrcodeOptions) {
    if (options === undefined) {
      return;
    }
    this.cid = options.cid ?? this.cid;
    this.size = options.size ?? this.size;
    this.unit = options.unit ?? this.unit;
    this.show = options.show ?? this.show;
    this.val = options.val ?? this.val;
    this.background = options.background ?? this.background;
    this.foreground = options.foreground ?? this.foreground;
    this.pdground = options.pdground ?? this.pdground;
    this.icon = options.icon ?? this.icon;
    this.iconSize = options.iconSize ?? this.iconSize;
    this.lv = options.lv ?? this.lv;
    this.quietZone = options.quietZone ?? this.quietZone;
    this.onval = options.onval ?? this.onval;
    this.loadMake = options.loadMake ?? this.loadMake;
    this.usingComponents = options.usingComponents ?? this.usingComponents;
    this.showLoading = options.showLoading ?? this.showLoading;
    this.loadingText = options.loadingText ?? this.loadingText;
    this.allowPreview = options.allowPreview ?? this.allowPreview;
    this.useRootHeightAndWidth = options.useRootHeightAndWidth ?? this.useRootHeightAndWidth;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onPreview = options.onPreview;
    this.onResult = options.onResult;
    this.onLongpress = options.onLongpress;
    this.onLongpressCallback = options.onLongpressCallback;
    this.onError = options.onError;
  }
}

@Component
export struct UPQrcode {
  @Prop @Watch('applyProps') props: UPQrcodeProps = new UPQrcodeProps();
  /** 上游 sizeLocal：useRootHeightAndWidth 时被根节点短边覆盖。/ Upstream sizeLocal. */
  @State private sizeLocal: number = 200;
  @State private loading: boolean = false;
  private result: string = '';
  private ready: boolean = false;
  private applied: string = '';
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    this.sizeLocal = this.edge();
    this.applied = this.signature();
    const unit: string = upString(this.props.unit, 'px');
    if (!upCanvasUnitSupported(unit)) {
      diagnostics.report('UPQrcode', 'unit', unit, 'only px/rpx/upx are supported; other CSS units fall back to px');
    }
    if (upBoolean(this.props.show, true) === false) {
      diagnostics.report('UPQrcode', 'show', this.props.show, 'upstream declares show but never consumes it, so the canvas always renders');
    }
    if (upBoolean(this.props.allowPreview, false)) {
      diagnostics.report('UPQrcode', 'allowPreview', this.props.allowPreview, 'uni.previewImage is unavailable; the preview callback receives the data URL instead');
    }
    diagnostics.report('UPQrcode', 'result', 'data-url', 'toTempFilePath is replaced by a base64 data URL');
  }

  /** 上游 size/val/icon/background/foreground/iconSize/quietZone/lv 八个 watch 的合并实现。/ Merges the eight upstream watchers. */
  private applyProps(): void {
    const edge: number = this.edge();
    if (edge !== this.sizeLocal && upBoolean(this.props.useRootHeightAndWidth, false) === false) {
      this.sizeLocal = edge;
    }
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    if (!upBoolean(this.props.onval, true)) {
      return;
    }
    this.draw();
  }

  /** 所有影响像素的入参拼成一个签名，用于替代上游的多个 watch。/ One signature standing in for the upstream watchers. */
  private signature(): string {
    const parts: Array<string> = [
      String(this.sizeLocal),
      upString(this.props.val, ''),
      upString(this.props.background, '#ffffff'),
      upString(this.props.foreground, '#000000'),
      upString(this.props.pdground, '#000000'),
      upString(this.props.icon, ''),
      String(upNumber(this.props.iconSize, 40)),
      String(upQrcodeLevel(this.props.lv)),
      String(this.quiet())
    ];
    return parts.join('|');
  }

  /** size + unit 换算成 ArkUI 的像素边长。/ Resolves size and unit into device-independent pixels. */
  private edge(): number {
    const resolved: number = upCanvasParseSize(this.props.size, upString(this.props.unit, 'px'), 375);
    return resolved > 0 ? resolved : 200;
  }

  /** 上游 `Math.max(0, Math.floor(quietZone || 0))`。/ Mirrors the upstream quietZone clamp. */
  private quiet(): number {
    const zone: number = Math.floor(upNumber(this.props.quietZone, 0));
    return Number.isFinite(zone) && zone > 0 ? zone : 0;
  }

  private backdrop(): string {
    const value: string = upString(this.props.background, '#ffffff').trim();
    return value.length === 0 ? '#ffffff' : value;
  }

  private cid(): string {
    const value: string = upString(this.props.cid, '').trim();
    return value.length === 0 ? upQrcodeId() : value;
  }

  private handleReady(): void {
    this.ready = true;
    if (upBoolean(this.props.loadMake, true)) {
      this.draw();
    }
  }

  /** 上游 _result()：结束 loading、缓存结果并抛出 result。/ Mirrors upstream _result(). */
  private publish(result: string): void {
    this.loading = false;
    this.result = result;
    const callback: ((result: string) => void) | undefined = this.props.onResult;
    if (callback !== undefined) {
      callback(result);
    }
  }

  private fail(message: string): void {
    this.loading = false;
    const callback: ((message: string) => void) | undefined = this.props.onError;
    if (callback !== undefined) {
      callback(message);
    }
  }

  /** 上游 QRCode.prototype.clear()：清屏并重新铺底。/ Mirrors upstream clear(). */
  clear(): void {
    if (!this.ready) {
      return;
    }
    this.renderContext.clearRect(0, 0, this.sizeLocal, this.sizeLocal);
    this.publish('');
  }

  /** 上游 _makeCode()：编码后逐格铺色，最后叠绘中心图标。/ Mirrors upstream _makeCode(). */
  private draw(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    const text: string = upString(this.props.val, '');
    if (text.length === 0) {
      diagnostics.report('UPQrcode', 'val', text, 'uni.showToast is unavailable; the empty content is reported through onError');
      this.fail('二维码内容不能为空');
      return;
    }
    if (!this.ready) {
      return;
    }
    this.loading = true;
    const encoder: UPQrcodeEncoder = new UPQrcodeEncoder(text, upQrcodeLevel(this.props.lv));
    const count: number = encoder.getModuleCount();
    const zone: number = this.quiet();
    const renderCount: number = count + zone * 2;
    const edge: number = this.sizeLocal;
    const tile: number = Number(Number(edge / renderCount).toPrecision(4));
    const background: string = this.backdrop();
    const foreground: string = upString(this.props.foreground, '#000000');
    const pdground: string = upString(this.props.pdground, '#000000');
    for (let row: number = 0; row < renderCount; row += 1) {
      for (let col: number = 0; col < renderCount; col += 1) {
        const cellWidth: number = Math.ceil((col + 1) * tile) - Math.floor(col * tile);
        const cellHeight: number = Math.ceil((row + 1) * tile) - Math.floor(row * tile);
        const qrRow: number = row - zone;
        const qrCol: number = col - zone;
        const dark: boolean = qrRow >= 0 && qrCol >= 0 && qrRow < count && qrCol < count
          && encoder.isDark(qrRow, qrCol);
        this.renderContext.fillStyle = dark
          ? upQrcodeForeground(qrRow, qrCol, count, foreground, pdground)
          : background;
        this.renderContext.fillRect(Math.round(col * tile), Math.round(row * tile), cellWidth, cellHeight);
      }
    }
    this.drawIcon(background);
    this.emitResult();
  }

  /** 上游 image 分支：先画圆角底衬再叠绘图标。/ Mirrors the upstream image branch. */
  private drawIcon(background: string): void {
    const icon: string = upString(this.props.icon, '').trim();
    if (icon.length === 0) {
      return;
    }
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (!isLocalCanvasSource(icon)) {
      diagnostics.report('UPQrcode', 'icon', icon, 'only local sources are drawn; remote icons are skipped');
      return;
    }
    const iconSize: number = Math.max(0, upNumber(this.props.iconSize, 40));
    const origin: number = Number(((this.sizeLocal - iconSize) / 2).toFixed(2));
    this.drawRoundedRect(origin, origin, iconSize, iconSize, 2, 6, background);
    this.renderContext.drawImage(new ImageBitmap(icon), origin, origin, iconSize, iconSize);
  }

  /** 上游 drawRoundedRect()：以 background 同时填充与描边，形成图标留白。/ Mirrors upstream drawRoundedRect(). */
  private drawRoundedRect(originX: number, originY: number, boxWidth: number, boxHeight: number,
    radius: number, stroke: number, color: string): void {
    this.renderContext.lineWidth = stroke;
    this.renderContext.fillStyle = color;
    this.renderContext.strokeStyle = color;
    this.renderContext.beginPath();
    this.renderContext.moveTo(originX + radius, originY);
    this.renderContext.lineTo(originX + boxWidth, originY);
    this.renderContext.arc(originX + boxWidth - radius, originY + radius, radius, -Math.PI / 2, 0);
    this.renderContext.lineTo(originX + boxWidth, originY + boxHeight - radius);
    this.renderContext.arc(originX + boxWidth - radius, originY + boxHeight - radius, radius, 0, Math.PI / 2);
    this.renderContext.lineTo(originX + radius, originY + boxHeight);
    this.renderContext.arc(originX + radius, originY + boxHeight - radius, radius, Math.PI / 2, Math.PI);
    this.renderContext.lineTo(originX, originY + radius);
    this.renderContext.arc(originX + radius, originY + radius, radius, Math.PI, Math.PI * 3 / 2);
    this.renderContext.closePath();
    this.renderContext.fill();
    this.renderContext.stroke();
  }

  /** 上游 cbResult：APP 端回传临时文件路径，本端回传 data URL。/ Upstream cbResult, returning a data URL. */
  private emitResult(): void {
    let dataUrl: string = '';
    try {
      dataUrl = this.renderContext.toDataURL('image/png', 1);
    } catch (_) {
      dataUrl = '';
    }
    if (dataUrl.length === 0) {
      this.fail('二维码导出失败');
      return;
    }
    this.publish(dataUrl);
  }

  /** 上游 preview()：uni.previewImage 不可用，只抛回调。/ Mirrors upstream preview() without uni.previewImage. */
  private preview(): void {
    const callback: ((url: string) => void) | undefined = this.props.onPreview;
    if (callback !== undefined) {
      callback(this.result);
    }
  }

  /** 上游 longpress()：导出后抛 longpressCallback；`onLongpress` 是本端别名。/ Mirrors upstream longpress(). */
  private longpress(): void {
    const callback: ((result: string) => void) | undefined = this.props.onLongpress;
    if (callback !== undefined) {
      callback(this.result);
    }
    const upstream: ((result: string) => void) | undefined = this.props.onLongpressCallback;
    if (upstream !== undefined) {
      upstream(this.result);
    }
  }

  /** 上游 setNewSize()：取根节点短边作为二维码边长。/ Mirrors upstream setNewSize(). */
  private captureRoot(area: Area): void {
    if (!upBoolean(this.props.useRootHeightAndWidth, false)) {
      return;
    }
    const rootWidth: number = this.measure(area.width);
    const rootHeight: number = this.measure(area.height);
    const shortest: number = rootWidth > rootHeight ? rootHeight : rootWidth;
    if (shortest <= 0 || shortest === this.sizeLocal) {
      return;
    }
    this.sizeLocal = shortest;
    this.applied = this.signature();
    this.draw();
  }

  private measure(value: Length): number {
    if (typeof value === 'number') {
      return Math.max(0, value);
    }
    if (typeof value === 'string') {
      const numeric: number = Number.parseFloat(value);
      return Number.isFinite(numeric) ? Math.max(0, numeric) : 0;
    }
    return 0;
  }

  @Builder
  private loadingMask() {
    Column() {
      UPLoadingIcon({
        props: new UPLoadingIconProps({
          vertical: true,
          text: upString(this.props.loadingText, '生成中'),
          textSize: '14px'
        })
      })
    }
    .width(this.sizeLocal)
    .height(this.sizeLocal)
    .backgroundColor('#f7f7f7')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.renderContext)
        .width(this.sizeLocal)
        .height(this.sizeLocal)
        .backgroundColor('transparent')
        .onReady((): void => this.handleReady())
      if (upBoolean(this.props.showLoading, true) && this.loading) {
        this.loadingMask()
      }
    }
    .id(this.cid())
    .width(UPStyle.parse(this.props.customStyle).width
      ?? (upBoolean(this.props.useRootHeightAndWidth, false) ? '100%' : this.sizeLocal))
    .height(UPStyle.parse(this.props.customStyle).height
      ?? (upBoolean(this.props.useRootHeightAndWidth, false) ? '100%' : this.sizeLocal))
    .onAreaChange((_oldValue: Area, newValue: Area): void => this.captureRoot(newValue))
    .onClick((): void => this.preview())
    .gesture(LongPressGesture().onAction((): void => this.longpress()))
  }
}
