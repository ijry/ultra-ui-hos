/**
 * 把 u-parse 的节点树摊平成 ArkUI 渲染块，替代上游 node.vue 的递归模板。
 * Layout pass that flattens the u-parse node tree into ArkUI render blocks.
 */
import { UPHtmlDeclaration, UPHtmlNode, upHtmlInlineTag, upHtmlSplitDeclarations } from './UPHtmlParser';

/** 上游 rich-text 的根字号。/ Root font size assumed by the upstream rich-text renderer. */
export const UP_HTML_BASE_FONT_SIZE: number = 16;
/** 上游 `._a` 的链接色。/ Link color from the upstream `._a` rule. */
export const UP_HTML_LINK_COLOR: string = '#366092';
/** 上游 `._ol/._ul` 的 padding-left。/ List indent from the upstream `._ol/._ul` rule. */
export const UP_HTML_LIST_INDENT: number = 40;
/** 上游 `._ul` 三级列表符号。/ Bullet glyphs for the three upstream `._ul` levels. */
export const UP_HTML_MARKER_DISC: string = '•';
export const UP_HTML_MARKER_CIRCLE: string = '◦';
export const UP_HTML_MARKER_SQUARE: string = '▪';
/** 标题字号倍数，对应上游 `._h1`–`._h6`。/ Heading scales from `._h1`–`._h6`. */
export const UP_HTML_HEADING_SCALES: Array<number> = [2, 1.5, 1.17, 1, 0.83, 0.67];
/** 浏览器默认标题外边距倍数。/ Browser default heading margins in em. */
export const UP_HTML_HEADING_MARGINS: Array<number> = [0.67, 0.83, 1, 1.33, 1.67, 2.33];
/** 命名字号到 em 的映射。/ Absolute keyword font sizes expressed in em. */
export const UP_HTML_NAMED_SIZES: Map<string, number> = new Map<string, number>([
  ['xx-small', 0.5625], ['x-small', 0.625], ['small', 0.8125], ['medium', 1],
  ['large', 1.125], ['x-large', 1.5], ['xx-large', 2], ['xxx-large', 3], ['smaller', 0.83], ['larger', 1.2]
]);

/** 渲染块类型。/ Render block kinds. */
export type UPHtmlBlockKind = 'text' | 'image' | 'divider' | 'media' | 'table';

/** 行内文本样式。/ Inline text style. */
export class UPHtmlTextStyle {
  color: string = '';
  fontSize: number = UP_HTML_BASE_FONT_SIZE;
  bold: boolean = false;
  italic: boolean = false;
  underline: boolean = false;
  lineThrough: boolean = false;
  mono: boolean = false;
  background: string = '';
  href: string = '';

  clone(): UPHtmlTextStyle {
    const copy: UPHtmlTextStyle = new UPHtmlTextStyle();
    copy.color = this.color;
    copy.fontSize = this.fontSize;
    copy.bold = this.bold;
    copy.italic = this.italic;
    copy.underline = this.underline;
    copy.lineThrough = this.lineThrough;
    copy.mono = this.mono;
    copy.background = this.background;
    copy.href = this.href;
    return copy;
  }
}

/** 块级样式，只保留 ArkUI 能落地的字段。/ Block style limited to values ArkUI can honour. */
export class UPHtmlBlockStyle {
  textAlign: string = '';
  background: string = '';
  marginTop: number = 0;
  marginBottom: number = 0;
  marginLeft: number = 0;
  marginRight: number = 0;
  paddingTop: number = 0;
  paddingRight: number = 0;
  paddingBottom: number = 0;
  paddingLeft: number = 0;
  borderWidth: number = 0;
  borderColor: string = '';
  borderRadius: number = 0;
  borderLeftWidth: number = 0;
  borderLeftColor: string = '';
  blockWidth: number = 0;
  blockHeight: number = 0;
  lineHeight: number = 0;
  listStyle: string = '';
  preserve: boolean = false;
  inline: boolean = false;

  clone(): UPHtmlBlockStyle {
    const copy: UPHtmlBlockStyle = new UPHtmlBlockStyle();
    copy.textAlign = this.textAlign;
    copy.background = this.background;
    copy.marginTop = this.marginTop;
    copy.marginBottom = this.marginBottom;
    copy.marginLeft = this.marginLeft;
    copy.marginRight = this.marginRight;
    copy.paddingTop = this.paddingTop;
    copy.paddingRight = this.paddingRight;
    copy.paddingBottom = this.paddingBottom;
    copy.paddingLeft = this.paddingLeft;
    copy.borderWidth = this.borderWidth;
    copy.borderColor = this.borderColor;
    copy.borderRadius = this.borderRadius;
    copy.borderLeftWidth = this.borderLeftWidth;
    copy.borderLeftColor = this.borderLeftColor;
    copy.blockWidth = this.blockWidth;
    copy.blockHeight = this.blockHeight;
    copy.lineHeight = this.lineHeight;
    copy.listStyle = this.listStyle;
    copy.preserve = this.preserve;
    copy.inline = this.inline;
    return copy;
  }

  /** 只继承可继承字段，外边距与边框不下传。/ Inherit only the inheritable declarations. */
  inherit(): UPHtmlBlockStyle {
    const copy: UPHtmlBlockStyle = new UPHtmlBlockStyle();
    copy.textAlign = this.textAlign;
    copy.lineHeight = this.lineHeight;
    copy.listStyle = this.listStyle;
    copy.preserve = this.preserve;
    return copy;
  }
}

/** 一段同样式文本。/ One styled text run. */
export class UPHtmlTextRun {
  text: string = '';
  style: UPHtmlTextStyle = new UPHtmlTextStyle();

  constructor(text: string, style: UPHtmlTextStyle) {
    this.text = text;
    this.style = style;
  }
}

/** 表格单元格。/ One table cell. */
export class UPHtmlTableCell {
  runs: Array<UPHtmlTextRun> = [];
  header: boolean = false;
  colspan: number = 1;
  rowspan: number = 1;
  style: UPHtmlBlockStyle = new UPHtmlBlockStyle();
}

/** 表格行。/ One table row. */
export class UPHtmlTableRow {
  cells: Array<UPHtmlTableCell> = [];
}

/** 摊平后的渲染块。/ A flattened render block. */
export class UPHtmlBlock {
  kind: UPHtmlBlockKind = 'text';
  key: string = '';
  depth: number = 0;
  marker: string = '';
  runs: Array<UPHtmlTextRun> = [];
  style: UPHtmlBlockStyle = new UPHtmlBlockStyle();
  anchor: string = '';
  source: string = '';
  alt: string = '';
  imageIndex: number = -1;
  imageWidth: number = 0;
  imageHeight: number = 0;
  imageMode: string = '';
  href: string = '';
  poster: string = '';
  mediaName: string = '';
  rows: Array<UPHtmlTableRow> = [];
}

/** 摊平选项。/ Layout options. */
export class UPHtmlLayoutOptions {
  baseFontSize: number = UP_HTML_BASE_FONT_SIZE;
  baseColor: string = '';
  linkColor: string = UP_HTML_LINK_COLOR;
  viewportWidth: number = 375;
}

/** 摊平结果。/ Layout result. */
export class UPHtmlLayoutResult {
  blocks: Array<UPHtmlBlock> = [];
  /** 未能原样渲染的标签名。/ Tags that could not be rendered as-is. */
  unsupported: Array<string> = [];
}

/** 长度解析：px / rpx / em / 数字，其余回落 0。/ Length parsing for px, rpx, em and bare numbers. */
export function upHtmlLength(value: string, fontSize: number, viewportWidth: number): number {
  const text: string = value.trim().toLowerCase();
  if (text.length === 0 || text === 'auto' || text === 'inherit') {
    return 0;
  }
  const amount: number = parseFloat(text);
  if (isNaN(amount)) {
    return 0;
  }
  if (text.includes('rpx') || text.includes('upx')) {
    return amount * (viewportWidth > 0 ? viewportWidth : 375) / 750;
  }
  if (text.includes('em')) {
    return amount * fontSize;
  }
  if (text.includes('%')) {
    return 0;
  }
  return amount;
}

/** 字号解析，支持 em、%、命名字号。/ Font size parsing with em, percentage and keywords. */
export function upHtmlResolveFontSize(value: string, inherited: number, viewportWidth: number): number {
  const text: string = value.trim().toLowerCase();
  if (text.length === 0) {
    return inherited;
  }
  const named: number | undefined = UP_HTML_NAMED_SIZES.get(text);
  if (named !== undefined) {
    return inherited * named;
  }
  if (text.includes('%')) {
    const percent: number = parseFloat(text);
    return isNaN(percent) ? inherited : inherited * percent / 100;
  }
  if (text.includes('em')) {
    const scale: number = parseFloat(text);
    return isNaN(scale) ? inherited : inherited * scale;
  }
  const resolved: number = upHtmlLength(text, inherited, viewportWidth);
  return resolved > 0 ? resolved : inherited;
}

/** 简写边距拆分成四个值。/ Expand a margin or padding shorthand. */
export function upHtmlEdges(value: string, fontSize: number, viewportWidth: number): Array<number> {
  const parts: Array<string> = value.trim().split(/\s+/);
  const values: Array<number> = [];
  for (const part of parts) {
    values.push(upHtmlLength(part, fontSize, viewportWidth));
  }
  if (values.length === 0) {
    return [0, 0, 0, 0];
  }
  if (values.length === 1) {
    return [values[0], values[0], values[0], values[0]];
  }
  if (values.length === 2) {
    return [values[0], values[1], values[0], values[1]];
  }
  if (values.length === 3) {
    return [values[0], values[1], values[2], values[1]];
  }
  return [values[0], values[1], values[2], values[3]];
}

/** 边框简写取宽度与颜色。/ Read width and color out of a border shorthand. */
export function upHtmlBorderParts(value: string, fontSize: number, viewportWidth: number): UPHtmlDeclaration {
  const parts: Array<string> = value.trim().split(/\s+/);
  let width: number = 0;
  let color: string = '';
  for (const part of parts) {
    const lower: string = part.toLowerCase();
    if (lower === 'solid' || lower === 'dashed' || lower === 'dotted' || lower === 'double' || lower === 'none') {
      continue;
    }
    const size: number = upHtmlLength(part, fontSize, viewportWidth);
    if (size > 0) {
      width = size;
      continue;
    }
    if (lower !== '0' && lower.length > 0) {
      color = part;
    }
  }
  return new UPHtmlDeclaration(String(width), color);
}

/** 罗马数字，用于 lower-roman/upper-roman。/ Roman numerals for the roman list styles. */
export function upHtmlRoman(value: number): string {
  if (value <= 0 || value >= 4000) {
    return String(value);
  }
  const numbers: Array<number> = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const glyphs: Array<string> = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
  let rest: number = value;
  let result: string = '';
  for (let index: number = 0; index < numbers.length; index++) {
    while (rest >= numbers[index]) {
      result += glyphs[index];
      rest -= numbers[index];
    }
  }
  return result;
}

/** 字母序号，用于 lower-alpha/upper-alpha。/ Alphabetic ordinals for the alpha list styles. */
export function upHtmlAlpha(value: number): string {
  if (value <= 0) {
    return String(value);
  }
  let rest: number = value;
  let result: string = '';
  while (rest > 0) {
    const remainder: number = (rest - 1) % 26;
    result = String.fromCharCode(97 + remainder) + result;
    rest = Math.floor((rest - 1) / 26);
  }
  return result;
}

/** 生成列表符号。/ Build the marker text for a list item. */
export function upHtmlListMarker(listStyle: string, ordered: boolean, ordinal: number, depth: number): string {
  const style: string = listStyle.length > 0 ? listStyle : (ordered ? 'decimal' : '');
  if (style === 'none') {
    return '';
  }
  if (style === 'decimal' || style === 'decimal-leading-zero') {
    return String(ordinal) + '.';
  }
  if (style === 'lower-alpha' || style === 'lower-latin') {
    return upHtmlAlpha(ordinal) + '.';
  }
  if (style === 'upper-alpha' || style === 'upper-latin') {
    return upHtmlAlpha(ordinal).toUpperCase() + '.';
  }
  if (style === 'lower-roman') {
    return upHtmlRoman(ordinal).toLowerCase() + '.';
  }
  if (style === 'upper-roman') {
    return upHtmlRoman(ordinal) + '.';
  }
  if (style === 'circle') {
    return UP_HTML_MARKER_CIRCLE;
  }
  if (style === 'square') {
    return UP_HTML_MARKER_SQUARE;
  }
  if (style === 'disc') {
    return UP_HTML_MARKER_DISC;
  }
  if (depth <= 1) {
    return UP_HTML_MARKER_DISC;
  }
  return depth === 2 ? UP_HTML_MARKER_CIRCLE : UP_HTML_MARKER_SQUARE;
}

/** 标题层级，非标题返回 0。/ Heading level, or zero when the tag is not a heading. */
export function upHtmlHeadingLevel(name: string): number {
  if (name.length !== 2 || name.charAt(0) !== 'h') {
    return 0;
  }
  const level: number = Number.parseInt(name.charAt(1));
  return isNaN(level) || level < 1 || level > 6 ? 0 : level;
}

/** 是否按行内渲染，对应上游 isInline()。/ Upstream isInline(). */
export function upHtmlRenderInline(name: string, style: string): boolean {
  if (name === 'a' || name === 'font' || name === 'ruby' || name === 'rt') {
    return true;
  }
  return upHtmlInlineTag(name) || style.includes('display:inline');
}

/**
 * 节点树到渲染块的转换器。
 * Converts a parsed node tree into flat render blocks.
 */
export class UPHtmlLayout {
  private options: UPHtmlLayoutOptions = new UPHtmlLayoutOptions();
  private blocks: Array<UPHtmlBlock> = [];
  private runs: Array<UPHtmlTextRun> = [];
  private pendingStyle: UPHtmlBlockStyle = new UPHtmlBlockStyle();
  private pendingDepth: number = 0;
  private pendingMarker: string = '';
  private pendingAnchor: string = '';
  private carryMarker: string = '';
  private open: boolean = false;
  private counter: number = 0;
  private unsupported: Array<string> = [];

  constructor(options?: UPHtmlLayoutOptions) {
    if (options !== undefined) {
      this.options = options;
    }
  }

  /** 执行转换。/ Run the layout pass. */
  build(nodes: Array<UPHtmlNode>): UPHtmlLayoutResult {
    this.blocks = [];
    this.runs = [];
    this.pendingStyle = new UPHtmlBlockStyle();
    this.pendingDepth = 0;
    this.pendingMarker = '';
    this.pendingAnchor = '';
    this.carryMarker = '';
    this.open = false;
    this.counter = 0;
    this.unsupported = [];
    const text: UPHtmlTextStyle = new UPHtmlTextStyle();
    text.fontSize = this.options.baseFontSize;
    text.color = this.options.baseColor;
    this.walk(nodes, text, new UPHtmlBlockStyle(), 0);
    this.flush();
    const result: UPHtmlLayoutResult = new UPHtmlLayoutResult();
    result.blocks = this.blocks;
    result.unsupported = this.unsupported;
    return result;
  }

  private record(name: string): void {
    if (name.length > 0 && !this.unsupported.includes(name)) {
      this.unsupported.push(name);
    }
  }

  private nextKey(): string {
    this.counter += 1;
    return 'up-parse-' + String(this.counter);
  }

  private ensureOpen(style: UPHtmlBlockStyle, depth: number): void {
    if (this.open) {
      return;
    }
    this.pendingStyle = style;
    this.pendingDepth = depth;
    this.pendingMarker = this.carryMarker;
    this.pendingAnchor = '';
    this.carryMarker = '';
    this.open = true;
  }

  private openBlock(style: UPHtmlBlockStyle, depth: number, marker: string, anchor: string): void {
    this.flush();
    this.pendingStyle = style;
    this.pendingDepth = depth;
    this.pendingMarker = marker.length > 0 ? marker : this.carryMarker;
    this.pendingAnchor = anchor;
    this.carryMarker = '';
    this.open = true;
  }

  private flush(): void {
    if (!this.open) {
      return;
    }
    this.open = false;
    const runs: Array<UPHtmlTextRun> = this.runs;
    this.runs = [];
    let printable: boolean = this.pendingStyle.preserve;
    for (const run of runs) {
      if (run.text.trim().length > 0) {
        printable = true;
      }
    }
    if (!printable) {
      if (this.pendingMarker.length > 0) {
        this.carryMarker = this.pendingMarker;
      }
      this.pendingMarker = '';
      return;
    }
    const block: UPHtmlBlock = new UPHtmlBlock();
    block.kind = 'text';
    block.key = this.nextKey();
    block.depth = this.pendingDepth;
    block.marker = this.pendingMarker;
    block.runs = runs;
    block.style = this.pendingStyle;
    block.anchor = this.pendingAnchor;
    this.blocks.push(block);
    this.pendingMarker = '';
    this.pendingAnchor = '';
  }

  private pushRun(text: string, style: UPHtmlTextStyle, blockStyle: UPHtmlBlockStyle, depth: number): void {
    if (text.length === 0) {
      return;
    }
    this.ensureOpen(blockStyle, depth);
    this.runs.push(new UPHtmlTextRun(text, style));
  }

  private walk(nodes: Array<UPHtmlNode>, text: UPHtmlTextStyle, block: UPHtmlBlockStyle, depth: number): void {
    for (const node of nodes) {
      if (node.type === 'text') {
        this.pushRun(node.text, text, block, depth);
        continue;
      }
      this.visitElement(node, text, block, depth);
    }
  }

  private visitElement(node: UPHtmlNode, text: UPHtmlTextStyle, block: UPHtmlBlockStyle, depth: number): void {
    const name: string = node.name;
    if (name === 'br') {
      this.pushRun('\n', text, block, depth);
      return;
    }
    if (name === 'img') {
      this.emitImage(node, block, depth);
      return;
    }
    if (name === 'hr') {
      this.emitDivider(node, block, depth);
      return;
    }
    if (name === 'video' || name === 'audio') {
      this.emitMedia(node, block, depth);
      return;
    }
    if (name === 'table') {
      this.emitTable(node, text, block, depth);
      return;
    }
    if (name === 'ul' || name === 'ol') {
      this.emitList(node, text, block, depth);
      return;
    }
    const childText: UPHtmlTextStyle = text.clone();
    const childBlock: UPHtmlBlockStyle = block.inherit();
    this.decorate(node, childText, childBlock);
    if (name === 'li') {
      const marker: string = upHtmlListMarker(childBlock.listStyle, false, 1, depth + 1);
      this.openBlock(childBlock, depth + 1, marker, node.attrs.id);
      this.walk(node.children, childText, childBlock, depth + 1);
      this.flush();
      return;
    }
    if (upHtmlRenderInline(name, node.attrs.style)) {
      if (name === 'q') {
        this.pushRun('"', childText, block, depth);
      }
      this.walk(node.children, childText, block, depth);
      if (name === 'q') {
        this.pushRun('"', childText, block, depth);
      }
      return;
    }
    this.openBlock(childBlock, depth, '', node.attrs.id);
    this.walk(node.children, childText, childBlock, depth);
    this.flush();
  }

  private emitList(node: UPHtmlNode, text: UPHtmlTextStyle, block: UPHtmlBlockStyle, depth: number): void {
    const childText: UPHtmlTextStyle = text.clone();
    const childBlock: UPHtmlBlockStyle = block.inherit();
    this.decorate(node, childText, childBlock);
    const ordered: boolean = node.name === 'ol';
    let ordinal: number = node.attrs.start > 0 ? node.attrs.start : 1;
    this.flush();
    for (const child of node.children) {
      if (child.type === 'text') {
        this.pushRun(child.text, childText, childBlock, depth + 1);
        continue;
      }
      if (child.name !== 'li') {
        this.visitElement(child, childText, childBlock, depth + 1);
        continue;
      }
      const itemText: UPHtmlTextStyle = childText.clone();
      const itemBlock: UPHtmlBlockStyle = childBlock.inherit();
      this.decorate(child, itemText, itemBlock);
      const marker: string = upHtmlListMarker(itemBlock.listStyle, ordered, ordinal, depth + 1);
      ordinal += 1;
      this.openBlock(itemBlock, depth + 1, marker, child.attrs.id);
      this.walk(child.children, itemText, itemBlock, depth + 1);
      this.flush();
    }
  }

  private emitImage(node: UPHtmlNode, block: UPHtmlBlockStyle, depth: number): void {
    this.flush();
    const style: UPHtmlBlockStyle = block.inherit();
    const text: UPHtmlTextStyle = new UPHtmlTextStyle();
    text.fontSize = this.options.baseFontSize;
    this.decorate(node, text, style);
    const item: UPHtmlBlock = new UPHtmlBlock();
    item.kind = 'image';
    item.key = this.nextKey();
    item.depth = depth;
    item.style = style;
    item.anchor = node.attrs.id;
    item.source = node.attrs.src.length > 0 ? node.attrs.src : node.attrs.dataSrc;
    item.alt = node.attrs.alt;
    item.imageIndex = node.imageIndex;
    item.imageWidth = style.blockWidth;
    item.imageHeight = style.blockHeight;
    item.imageMode = node.imageMode;
    item.href = node.linkAttrs === undefined ? '' : node.linkAttrs.href;
    this.blocks.push(item);
  }

  private emitDivider(node: UPHtmlNode, block: UPHtmlBlockStyle, depth: number): void {
    this.flush();
    const style: UPHtmlBlockStyle = block.inherit();
    const text: UPHtmlTextStyle = new UPHtmlTextStyle();
    text.fontSize = this.options.baseFontSize;
    this.decorate(node, text, style);
    const item: UPHtmlBlock = new UPHtmlBlock();
    item.kind = 'divider';
    item.key = this.nextKey();
    item.depth = depth;
    item.style = style;
    item.anchor = node.attrs.id;
    this.blocks.push(item);
  }

  private emitMedia(node: UPHtmlNode, block: UPHtmlBlockStyle, depth: number): void {
    this.flush();
    this.record(node.name);
    const style: UPHtmlBlockStyle = block.inherit();
    const text: UPHtmlTextStyle = new UPHtmlTextStyle();
    text.fontSize = this.options.baseFontSize;
    this.decorate(node, text, style);
    const item: UPHtmlBlock = new UPHtmlBlock();
    item.kind = 'media';
    item.key = this.nextKey();
    item.depth = depth;
    item.style = style;
    item.anchor = node.attrs.id;
    item.mediaName = node.name;
    item.poster = node.attrs.poster;
    item.source = node.sources.length > 0 ? node.sources[0] : '';
    this.blocks.push(item);
  }

  private emitTable(node: UPHtmlNode, text: UPHtmlTextStyle, block: UPHtmlBlockStyle, depth: number): void {
    this.flush();
    const style: UPHtmlBlockStyle = block.inherit();
    const tableText: UPHtmlTextStyle = text.clone();
    this.decorate(node, tableText, style);
    const item: UPHtmlBlock = new UPHtmlBlock();
    item.kind = 'table';
    item.key = this.nextKey();
    item.depth = depth;
    item.style = style;
    item.anchor = node.attrs.id;
    item.rows = [];
    this.collectRows(node.children, tableText, style, item.rows);
    this.blocks.push(item);
  }

  private collectRows(nodes: Array<UPHtmlNode>, text: UPHtmlTextStyle, style: UPHtmlBlockStyle,
    rows: Array<UPHtmlTableRow>): void {
    for (const node of nodes) {
      if (node.type === 'text') {
        continue;
      }
      if (node.name === 'tr') {
        const rowText: UPHtmlTextStyle = text.clone();
        const rowStyle: UPHtmlBlockStyle = style.inherit();
        this.decorate(node, rowText, rowStyle);
        const row: UPHtmlTableRow = new UPHtmlTableRow();
        for (const child of node.children) {
          if (child.type === 'text' || (child.name !== 'td' && child.name !== 'th')) {
            continue;
          }
          row.cells.push(this.buildCell(child, rowText, rowStyle));
        }
        if (row.cells.length > 0) {
          rows.push(row);
        }
        continue;
      }
      if (node.children.length > 0) {
        this.collectRows(node.children, text, style, rows);
      }
    }
  }

  private buildCell(node: UPHtmlNode, text: UPHtmlTextStyle, style: UPHtmlBlockStyle): UPHtmlTableCell {
    const cell: UPHtmlTableCell = new UPHtmlTableCell();
    cell.header = node.name === 'th';
    cell.colspan = node.attrs.colspan > 0 ? node.attrs.colspan : 1;
    cell.rowspan = node.attrs.rowspan > 0 ? node.attrs.rowspan : 1;
    const cellText: UPHtmlTextStyle = text.clone();
    const cellStyle: UPHtmlBlockStyle = style.inherit();
    this.decorate(node, cellText, cellStyle);
    cell.style = cellStyle;
    const nested: UPHtmlLayout = new UPHtmlLayout(this.options);
    const inner: UPHtmlLayoutResult = nested.build(node.children);
    for (const name of inner.unsupported) {
      this.record(name);
    }
    for (const inside of inner.blocks) {
      if (inside.kind !== 'text') {
        this.record(inside.kind === 'image' ? 'img' : inside.kind);
        continue;
      }
      if (cell.runs.length > 0) {
        cell.runs.push(new UPHtmlTextRun('\n', cellText));
      }
      for (const run of inside.runs) {
        const merged: UPHtmlTextStyle = run.style.clone();
        merged.bold = merged.bold || cellText.bold;
        merged.color = merged.color.length > 0 ? merged.color : cellText.color;
        cell.runs.push(new UPHtmlTextRun(run.text, merged));
      }
    }
    return cell;
  }

  /** 标签内建表现 + 内联样式。/ Built-in tag presentation followed by inline declarations. */
  private decorate(node: UPHtmlNode, text: UPHtmlTextStyle, block: UPHtmlBlockStyle): void {
    this.applyTag(node, text, block);
    this.applyDeclarations(node.attrs.style, text, block);
  }

  private applyTag(node: UPHtmlNode, text: UPHtmlTextStyle, block: UPHtmlBlockStyle): void {
    const name: string = node.name;
    const heading: number = upHtmlHeadingLevel(name);
    if (heading > 0) {
      text.bold = true;
      text.fontSize = this.options.baseFontSize * UP_HTML_HEADING_SCALES[heading - 1];
      const spacing: number = text.fontSize * UP_HTML_HEADING_MARGINS[heading - 1];
      block.marginTop = spacing;
      block.marginBottom = spacing;
      return;
    }
    switch (name) {
      case 'b':
      case 'strong':
        text.bold = true;
        break;
      case 'i':
      case 'em':
        text.italic = true;
        break;
      case 'code':
      case 'kbd':
      case 'samp':
        text.mono = true;
        break;
      case 'del':
        text.lineThrough = true;
        break;
      case 'ins':
        text.underline = true;
        break;
      case 'sub':
      case 'sup':
        text.fontSize = text.fontSize * 0.83;
        break;
      case 'a':
        text.href = node.attrs.href;
        if (node.attrs.href.length > 0) {
          text.color = this.options.linkColor;
        }
        break;
      case 'p':
        block.marginTop = text.fontSize;
        block.marginBottom = text.fontSize;
        break;
      case 'blockquote':
        block.marginTop = text.fontSize;
        block.marginBottom = text.fontSize;
        block.marginLeft = UP_HTML_LIST_INDENT;
        block.marginRight = UP_HTML_LIST_INDENT;
        break;
      case 'ul':
      case 'ol':
        block.marginTop = text.fontSize;
        block.marginBottom = text.fontSize;
        break;
      case 'th':
        text.bold = true;
        block.textAlign = 'center';
        break;
      default:
        break;
    }
  }

  private applyDeclarations(source: string, text: UPHtmlTextStyle, block: UPHtmlBlockStyle): void {
    if (source.length === 0) {
      return;
    }
    const viewport: number = this.options.viewportWidth;
    const declarations: Array<UPHtmlDeclaration> = upHtmlSplitDeclarations(source);
    for (const declaration of declarations) {
      const key: string = declaration.key;
      const value: string = declaration.value;
      if (key === 'font-size') {
        text.fontSize = upHtmlResolveFontSize(value, text.fontSize, viewport);
        continue;
      }
      if (key === 'color') {
        text.color = value;
        continue;
      }
      if (key === 'font-weight') {
        const weight: number = Number.parseInt(value);
        text.bold = value === 'bold' || value === 'bolder' || (!isNaN(weight) && weight >= 600);
        continue;
      }
      if (key === 'font-style') {
        text.italic = value === 'italic' || value === 'oblique';
        continue;
      }
      if (key === 'font-family') {
        text.mono = value.includes('monospace') || value.includes('Courier');
        continue;
      }
      if (key === 'text-decoration' || key === 'text-decoration-line') {
        text.underline = value.includes('underline');
        text.lineThrough = value.includes('line-through');
        continue;
      }
      if (key === 'background' || key === 'background-color') {
        block.background = value;
        text.background = value;
        continue;
      }
      if (key === 'text-align') {
        block.textAlign = value;
        continue;
      }
      if (key === 'line-height') {
        block.lineHeight = upHtmlResolveFontSize(value, text.fontSize, viewport);
        continue;
      }
      if (key === 'list-style-type') {
        block.listStyle = value;
        continue;
      }
      if (key === 'white-space') {
        block.preserve = value.includes('pre');
        continue;
      }
      if (key === 'display') {
        block.inline = value.includes('inline');
        continue;
      }
      if (key === 'width') {
        block.blockWidth = upHtmlLength(value, text.fontSize, viewport);
        continue;
      }
      if (key === 'height') {
        block.blockHeight = upHtmlLength(value, text.fontSize, viewport);
        continue;
      }
      if (key === 'border-radius') {
        block.borderRadius = upHtmlLength(value, text.fontSize, viewport);
        continue;
      }
      if (key === 'border' || key === 'border-top' || key === 'border-right' || key === 'border-bottom') {
        const parts: UPHtmlDeclaration = upHtmlBorderParts(value, text.fontSize, viewport);
        block.borderWidth = parseFloat(parts.key);
        block.borderColor = parts.value;
        continue;
      }
      if (key === 'border-left') {
        const parts: UPHtmlDeclaration = upHtmlBorderParts(value, text.fontSize, viewport);
        block.borderLeftWidth = parseFloat(parts.key);
        block.borderLeftColor = parts.value;
        continue;
      }
      if (key === 'border-color') {
        block.borderColor = value;
        continue;
      }
      if (key === 'border-width') {
        block.borderWidth = upHtmlLength(value, text.fontSize, viewport);
        continue;
      }
      if (key === 'margin') {
        const edges: Array<number> = upHtmlEdges(value, text.fontSize, viewport);
        block.marginTop = edges[0];
        block.marginRight = edges[1];
        block.marginBottom = edges[2];
        block.marginLeft = edges[3];
        continue;
      }
      if (key === 'padding') {
        const edges: Array<number> = upHtmlEdges(value, text.fontSize, viewport);
        block.paddingTop = edges[0];
        block.paddingRight = edges[1];
        block.paddingBottom = edges[2];
        block.paddingLeft = edges[3];
        continue;
      }
      this.applySideDeclaration(key, value, text.fontSize, block);
    }
  }

  private applySideDeclaration(key: string, value: string, fontSize: number, block: UPHtmlBlockStyle): void {
    const viewport: number = this.options.viewportWidth;
    switch (key) {
      case 'margin-top': block.marginTop = upHtmlLength(value, fontSize, viewport); break;
      case 'margin-right': block.marginRight = upHtmlLength(value, fontSize, viewport); break;
      case 'margin-bottom': block.marginBottom = upHtmlLength(value, fontSize, viewport); break;
      case 'margin-left': block.marginLeft = upHtmlLength(value, fontSize, viewport); break;
      case 'padding-top': block.paddingTop = upHtmlLength(value, fontSize, viewport); break;
      case 'padding-right': block.paddingRight = upHtmlLength(value, fontSize, viewport); break;
      case 'padding-bottom': block.paddingBottom = upHtmlLength(value, fontSize, viewport); break;
      case 'padding-left': block.paddingLeft = upHtmlLength(value, fontSize, viewport); break;
      default: break;
    }
  }
}
