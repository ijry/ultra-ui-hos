/**
 * 轻量 markdown → html 转换，替代上游 marked.esm.mjs 打包产物。
 * Lightweight markdown-to-html conversion that replaces the upstream marked bundle.
 */
import { UPHtmlDeclaration } from './UPHtmlParser';

/** 上游 .up-markdown 根节点的内边距与字号。/ Root padding and font size of the upstream root rule. */
export const UP_MARKDOWN_ROOT_PADDING: number = 16;
export const UP_MARKDOWN_BASE_FONT_SIZE: number = 16;
/** 上游 line-height:1.6，按 em 注入避免被当成像素。/ Upstream line-height injected as em. */
export const UP_MARKDOWN_LINE_HEIGHT: string = '1.6em';
/** handleCodeBlock() 注入的两个类名。/ Class names injected by handleCodeBlock(). */
export const UP_MARKDOWN_CODE_CLASS: string = 'up-markdown-code';
export const UP_MARKDOWN_LANG_CLASS: string = 'code-lang';
/** 行号列的类名，原生侧改成行内号码槽。/ Gutter class name replaced by an inline gutter. */
export const UP_MARKDOWN_LINE_NUMBERS_CLASS: string = 'up-markdown-line-numbers';
/** 上游 scss 的浅色取值。/ Light palette from the upstream scss. */
export const UP_MARKDOWN_LIGHT_COLOR: string = '#333';
export const UP_MARKDOWN_LIGHT_LINK: string = '#007AFF';
export const UP_MARKDOWN_LIGHT_CODE: string = '#f6f8fa';
export const UP_MARKDOWN_LIGHT_QUOTE: string = '#666';
/** 上游 scss 的深色取值。/ Dark palette from the upstream scss. */
export const UP_MARKDOWN_DARK_COLOR: string = '#ccc';
export const UP_MARKDOWN_DARK_BACKGROUND: string = '#1e1e1e';
export const UP_MARKDOWN_DARK_LINK: string = '#4da6ff';
export const UP_MARKDOWN_DARK_CODE: string = '#2d2d2d';
export const UP_MARKDOWN_DARK_CODE_COLOR: string = '#dcdcdc';
export const UP_MARKDOWN_DARK_QUOTE: string = '#bbb';
/** 透明背景与固定描边色。/ Transparent background and fixed stroke colors. */
export const UP_MARKDOWN_TRANSPARENT: string = '#00000000';
export const UP_MARKDOWN_QUOTE_BORDER: string = '#ccc';
export const UP_MARKDOWN_TABLE_BORDER: string = '#dfe2e5';
export const UP_MARKDOWN_RULE_COLOR: string = '#e1e4e8';
export const UP_MARKDOWN_IMAGE_BACKGROUND: string = '#fff';
/** 上游 h1~h6 的字号与上下外边距。/ Upstream heading sizes and vertical margins. */
export const UP_MARKDOWN_HEADING_SIZES: Array<number> = [32, 24, 18, 16, 13, 10];
export const UP_MARKDOWN_HEADING_MARGINS: Array<number> = [8, 8, 7, 7, 6, 5];
/** 上游 theme 的两个取值。/ The two upstream theme values. */
export const UP_MARKDOWN_THEMES: Array<string> = ['light', 'dark'];

/** 块级解析的一段结果与下一行游标。/ One parsed block plus the next line cursor. */
class UPMarkdownSlice {
  html: string = '';
  next: number = 0;

  constructor(html: string, next: number) {
    this.html = html;
    this.next = next;
  }
}

/** 行内定界符解析结果。/ Result of reading a delimited inline span. */
class UPMarkdownSpan {
  text: string = '';
  next: number = 0;

  constructor(text: string, next: number) {
    this.text = text;
    this.next = next;
  }
}

/** 链接与图片解析结果。/ Result of reading a link or image. */
class UPMarkdownLink {
  label: string = '';
  target: string = '';
  next: number = 0;

  constructor(label: string, target: string, next: number) {
    this.label = label;
    this.target = target;
    this.next = next;
  }
}

/** 是否数字字符。/ Whether the character is a digit. */
function upMarkdownDigit(value: string): boolean {
  if (value.length === 0) {
    return false;
  }
  const code: number = value.charCodeAt(0);
  return code >= 48 && code <= 57;
}

/** 是否字母或数字，用于 `_` 的词边界判断。/ Alphanumeric test used by the underscore word boundary. */
function upMarkdownLetter(value: string): boolean {
  if (value.length === 0) {
    return false;
  }
  const code: number = value.charCodeAt(0);
  return (code >= 48 && code <= 57) || (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
}

/**
 * 文本转义：只处理 `<` 与 `>`，`&` 交给 html 解析器原样处理。
 * Escapes angle brackets only; ampersands are left to the html parser.
 */
export function upMarkdownEscape(value: string): string {
  return value.replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/** 属性值转义，额外处理双引号。/ Attribute escaping that also handles double quotes. */
export function upMarkdownAttribute(value: string): string {
  return upMarkdownEscape(value).replace(/"/g, '&quot;');
}

/** 空行判断。/ Blank line test. */
function upMarkdownBlank(line: string): boolean {
  return line.trim().length === 0;
}

/** 前导空格数量。/ Number of leading spaces. */
export function upMarkdownIndent(line: string): number {
  let count: number = 0;
  while (count < line.length && line.charAt(count) === ' ') {
    count += 1;
  }
  return count;
}

/** 去掉至多 amount 个前导空格。/ Removes up to amount leading spaces. */
function upMarkdownDedent(line: string, amount: number): string {
  let removed: number = 0;
  let index: number = 0;
  while (index < line.length && removed < amount && line.charAt(index) === ' ') {
    index += 1;
    removed += 1;
  }
  return line.substring(index);
}

/** 代码围栏标记，非围栏返回空串。/ Fence marker, or an empty string. */
export function upMarkdownFenceMark(line: string): string {
  const trimmed: string = line.trim();
  if (trimmed.substring(0, 3) === '```') {
    return '```';
  }
  return trimmed.substring(0, 3) === '~~~' ? '~~~' : '';
}

/** ATX 标题层级，非标题返回 0。/ ATX heading level, or zero. */
export function upMarkdownHeadingLevel(line: string): number {
  const trimmed: string = line.trim();
  let level: number = 0;
  while (level < trimmed.length && trimmed.charAt(level) === '#') {
    level += 1;
  }
  if (level === 0 || level > 6) {
    return 0;
  }
  const next: string = trimmed.charAt(level);
  return next.length === 0 || next === ' ' ? level : 0;
}

/** 去掉标题两侧的 `#` 与空格。/ Strips the ATX markers around a heading. */
function upMarkdownHeadingText(line: string, level: number): string {
  let text: string = line.trim().substring(level).trim();
  while (text.length > 0 && text.charAt(text.length - 1) === '#') {
    text = text.substring(0, text.length - 1);
  }
  return text.trim();
}

/** Setext 下划线层级，非下划线返回 0。/ Setext underline level, or zero. */
export function upMarkdownSetextLevel(line: string): number {
  const trimmed: string = line.trim();
  if (trimmed.length === 0) {
    return 0;
  }
  const first: string = trimmed.charAt(0);
  if (first !== '=' && first !== '-') {
    return 0;
  }
  for (let index: number = 0; index < trimmed.length; index++) {
    if (trimmed.charAt(index) !== first) {
      return 0;
    }
  }
  return first === '=' ? 1 : 2;
}

/** 分隔线判断。/ Thematic break test. */
export function upMarkdownRuleLine(line: string): boolean {
  const trimmed: string = line.trim();
  if (trimmed.length < 3) {
    return false;
  }
  const first: string = trimmed.charAt(0);
  if (first !== '-' && first !== '*' && first !== '_') {
    return false;
  }
  let count: number = 0;
  for (let index: number = 0; index < trimmed.length; index++) {
    const character: string = trimmed.charAt(index);
    if (character === first) {
      count += 1;
      continue;
    }
    if (character !== ' ') {
      return false;
    }
  }
  return count >= 3;
}

/** 无序列表标记宽度，非列表返回 0。/ Bullet marker width, or zero. */
export function upMarkdownBulletWidth(body: string): number {
  const first: string = body.charAt(0);
  if (first !== '-' && first !== '*' && first !== '+') {
    return 0;
  }
  if (body.charAt(1) !== ' ') {
    return 0;
  }
  let width: number = 2;
  while (width < body.length && body.charAt(width) === ' ') {
    width += 1;
  }
  return width;
}

/** 有序列表标记宽度，非列表返回 0。/ Ordered marker width, or zero. */
export function upMarkdownOrderedWidth(body: string): number {
  let digits: number = 0;
  while (digits < body.length && upMarkdownDigit(body.charAt(digits))) {
    digits += 1;
  }
  if (digits === 0) {
    return 0;
  }
  const delimiter: string = body.charAt(digits);
  if (delimiter !== '.' && delimiter !== ')') {
    return 0;
  }
  if (body.charAt(digits + 1) !== ' ') {
    return 0;
  }
  let width: number = digits + 2;
  while (width < body.length && body.charAt(width) === ' ') {
    width += 1;
  }
  return width;
}

/** 有序列表起始序号。/ Ordinal that starts an ordered list. */
export function upMarkdownOrderedStart(body: string): number {
  let digits: string = '';
  let index: number = 0;
  while (index < body.length && upMarkdownDigit(body.charAt(index))) {
    digits += body.charAt(index);
    index += 1;
  }
  const value: number = Number.parseInt(digits);
  return isNaN(value) || value < 1 ? 1 : value;
}

/** 表格对齐行判断。/ Table delimiter row test. */
export function upMarkdownTableDelimiter(line: string): boolean {
  const trimmed: string = line.trim();
  if (!trimmed.includes('-') || !trimmed.includes('|')) {
    return false;
  }
  for (let index: number = 0; index < trimmed.length; index++) {
    const character: string = trimmed.charAt(index);
    if (character !== '|' && character !== '-' && character !== ':' && character !== ' ') {
      return false;
    }
  }
  return true;
}

/** 拆分表格行。/ Splits one table row into cells. */
export function upMarkdownCells(line: string): Array<string> {
  let text: string = line.trim();
  if (text.charAt(0) === '|') {
    text = text.substring(1);
  }
  if (text.charAt(text.length - 1) === '|') {
    text = text.substring(0, text.length - 1);
  }
  const cells: Array<string> = [];
  for (const part of text.split('|')) {
    cells.push(part.trim());
  }
  return cells;
}

/** 对齐行单元格转 text-align。/ Maps a delimiter cell to a text-align value. */
export function upMarkdownAlignment(spec: string): string {
  const text: string = spec.trim();
  const left: boolean = text.charAt(0) === ':';
  const right: boolean = text.length > 0 && text.charAt(text.length - 1) === ':';
  if (left && right) {
    return 'center';
  }
  if (right) {
    return 'right';
  }
  return left ? 'left' : '';
}

/** 单元格的行内样式。/ Inline style of one table cell. */
function upMarkdownCellStyle(alignments: Array<string>, index: number): string {
  const align: string = index < alignments.length ? alignments[index] : '';
  return align.length > 0 ? ' style="text-align:' + align + '"' : '';
}

/** 硬换行判断：行尾两个空格或一个反斜杠。/ Hard break test. */
function upMarkdownHardBreak(line: string): boolean {
  return line.endsWith('  ') || line.endsWith('\\');
}

/** 连续相同字符的长度。/ Length of a run of identical characters. */
function upMarkdownRunLength(source: string, index: number, character: string): number {
  let length: number = 0;
  while (index + length < source.length && source.charAt(index + length) === character) {
    length += 1;
  }
  return length;
}

/** 读取 `[label](target)` 结构。/ Reads a `[label](target)` structure. */
function upMarkdownReadLink(source: string, start: number): UPMarkdownLink | undefined {
  if (source.charAt(start) !== '[') {
    return undefined;
  }
  let depth: number = 0;
  let index: number = start;
  let close: number = -1;
  while (index < source.length) {
    const character: string = source.charAt(index);
    if (character === '\\') {
      index += 2;
      continue;
    }
    if (character === '[') {
      depth += 1;
    } else if (character === ']') {
      depth -= 1;
      if (depth === 0) {
        close = index;
        break;
      }
    }
    index += 1;
  }
  if (close === -1 || source.charAt(close + 1) !== '(') {
    return undefined;
  }
  let parens: number = 0;
  let end: number = -1;
  index = close + 1;
  while (index < source.length) {
    const character: string = source.charAt(index);
    if (character === '\\') {
      index += 2;
      continue;
    }
    if (character === '(') {
      parens += 1;
    } else if (character === ')') {
      parens -= 1;
      if (parens === 0) {
        end = index;
        break;
      }
    }
    index += 1;
  }
  if (end === -1) {
    return undefined;
  }
  const inside: string = source.substring(close + 2, end).trim();
  let target: string = inside.length > 0 ? inside.split(/\s+/)[0] : '';
  if (target.charAt(0) === '<' && target.charAt(target.length - 1) === '>') {
    target = target.substring(1, target.length - 1);
  }
  return new UPMarkdownLink(source.substring(start + 1, close), target, end + 1);
}

/** 读取以 marker 包裹的行内片段。/ Reads a span wrapped by marker. */
function upMarkdownReadDelimited(source: string, index: number, marker: string): UPMarkdownSpan | undefined {
  const from: number = index + marker.length;
  if (from >= source.length || source.charAt(from) === ' ') {
    return undefined;
  }
  let cursor: number = from;
  while (cursor < source.length) {
    if (source.charAt(cursor) === '\\') {
      cursor += 2;
      continue;
    }
    if (source.substring(cursor, cursor + marker.length) === marker) {
      const inner: string = source.substring(from, cursor);
      return inner.trim().length === 0 ? undefined : new UPMarkdownSpan(inner, cursor + marker.length);
    }
    cursor += 1;
  }
  return undefined;
}

/**
 * 行内语法转 html：代码、图片、链接、加粗、斜体与删除线。
 * Inline markdown to html: code, images, links, strong, emphasis and strikethrough.
 */
export function upMarkdownInline(source: string): string {
  let html: string = '';
  let index: number = 0;
  while (index < source.length) {
    const character: string = source.charAt(index);
    if (character === '\\' && index + 1 < source.length) {
      html += upMarkdownEscape(source.charAt(index + 1));
      index += 2;
      continue;
    }
    if (character === '`') {
      const fence: number = upMarkdownRunLength(source, index, '`');
      const marker: string = source.substring(index, index + fence);
      const close: number = source.indexOf(marker, index + fence);
      if (close !== -1) {
        html += '<code>' + upMarkdownEscape(source.substring(index + fence, close)) + '</code>';
        index = close + fence;
        continue;
      }
      html += upMarkdownEscape(character);
      index += 1;
      continue;
    }
    if (character === '!' && source.charAt(index + 1) === '[') {
      const image: UPMarkdownLink | undefined = upMarkdownReadLink(source, index + 1);
      if (image !== undefined) {
        html += '<img src="' + upMarkdownAttribute(image.target) + '" alt="' + upMarkdownAttribute(image.label) + '">';
        index = image.next;
        continue;
      }
    }
    if (character === '[') {
      const link: UPMarkdownLink | undefined = upMarkdownReadLink(source, index);
      if (link !== undefined) {
        html += '<a href="' + upMarkdownAttribute(link.target) + '">' + upMarkdownInline(link.label) + '</a>';
        index = link.next;
        continue;
      }
    }
    const pair: string = source.substring(index, index + 2);
    const boundary: boolean = index === 0 || !upMarkdownLetter(source.charAt(index - 1));
    if (pair === '**' || (pair === '__' && boundary)) {
      const strong: UPMarkdownSpan | undefined = upMarkdownReadDelimited(source, index, pair);
      if (strong !== undefined && (pair === '**' || !upMarkdownLetter(source.charAt(strong.next)))) {
        html += '<strong>' + upMarkdownInline(strong.text) + '</strong>';
        index = strong.next;
        continue;
      }
    }
    if (pair === '~~') {
      const struck: UPMarkdownSpan | undefined = upMarkdownReadDelimited(source, index, pair);
      if (struck !== undefined) {
        html += '<del>' + upMarkdownInline(struck.text) + '</del>';
        index = struck.next;
        continue;
      }
    }
    if (character === '*' || (character === '_' && boundary)) {
      const emphasis: UPMarkdownSpan | undefined = upMarkdownReadDelimited(source, index, character);
      if (emphasis !== undefined && (character === '*' || !upMarkdownLetter(source.charAt(emphasis.next)))) {
        html += '<em>' + upMarkdownInline(emphasis.text) + '</em>';
        index = emphasis.next;
        continue;
      }
    }
    html += upMarkdownEscape(character);
    index += 1;
  }
  return html;
}

/** 行号槽：号码右对齐后拼在每行前面。/ Inline gutter with right-aligned line numbers. */
export function upMarkdownGutter(code: string): string {
  const lines: Array<string> = code.split('\n');
  const width: number = String(lines.length).length;
  let text: string = '';
  for (let index: number = 0; index < lines.length; index++) {
    if (index > 0) {
      text += '\n';
    }
    text += String(index + 1).padStart(width, ' ') + '  ' + lines[index];
  }
  return text;
}

/** 上游 handleCodeBlock() 的输出结构。/ Output shape of the upstream handleCodeBlock(). */
export function upMarkdownCodeBlock(code: string, language: string, showLineNumber: boolean): string {
  const langClass: string = language.length > 0 ? 'language-' + language : '';
  const body: string = showLineNumber ? upMarkdownGutter(code) : code;
  return '<pre class="' + UP_MARKDOWN_CODE_CLASS + ' ' + langClass + '">'
    + '<code class="' + UP_MARKDOWN_LANG_CLASS + ' ' + langClass + '">'
    + upMarkdownEscape(body) + '</code></pre>';
}

/** 是否块级起始行。/ Whether the line opens a non-paragraph block. */
function upMarkdownBlockStart(line: string): boolean {
  if (upMarkdownBlank(line)) {
    return true;
  }
  if (upMarkdownFenceMark(line).length > 0 || upMarkdownRuleLine(line) || upMarkdownHeadingLevel(line) > 0) {
    return true;
  }
  if (line.trim().charAt(0) === '>') {
    return true;
  }
  const body: string = line.substring(upMarkdownIndent(line));
  return upMarkdownBulletWidth(body) > 0 || upMarkdownOrderedWidth(body) > 0;
}

/** 围栏代码块。/ Fenced code block. */
function upMarkdownFenced(lines: Array<string>, start: number, fence: string, showLineNumber: boolean): UPMarkdownSlice {
  const info: string = lines[start].trim().substring(fence.length).trim();
  const language: string = info.length > 0 ? info.split(/\s+/)[0] : '';
  const body: Array<string> = [];
  let index: number = start + 1;
  while (index < lines.length) {
    if (lines[index].trim().substring(0, fence.length) === fence) {
      index += 1;
      break;
    }
    body.push(lines[index]);
    index += 1;
  }
  return new UPMarkdownSlice(upMarkdownCodeBlock(body.join('\n'), language, showLineNumber), index);
}

/**
 * 合并连续文本行：行尾硬换行拆成多段，逐段做行内转换后用 `<br>` 相连。
 * Joins consecutive text lines, splitting on hard breaks so `<br>` stays unescaped.
 */
function upMarkdownJoinLines(lines: Array<string>): string {
  let html: string = '';
  let segment: string = '';
  for (const line of lines) {
    let text: string = line.trim();
    const hardBreak: boolean = upMarkdownHardBreak(line);
    if (hardBreak && text.charAt(text.length - 1) === '\\') {
      text = text.substring(0, text.length - 1);
    }
    segment += segment.length > 0 ? ' ' + text : text;
    if (hardBreak) {
      html += upMarkdownInline(segment) + '<br>';
      segment = '';
    }
  }
  return segment.length > 0 ? html + upMarkdownInline(segment) : html;
}

/** 段落。/ Paragraph. */
function upMarkdownParagraph(lines: Array<string>, start: number): UPMarkdownSlice {
  const collected: Array<string> = [];
  let index: number = start;
  while (index < lines.length) {
    const line: string = lines[index];
    if (upMarkdownBlank(line)) {
      break;
    }
    if (index > start && upMarkdownBlockStart(line)) {
      break;
    }
    if (index > start && index + 1 < lines.length && line.includes('|') && upMarkdownTableDelimiter(lines[index + 1])) {
      break;
    }
    if (index > start && upMarkdownSetextLevel(line) > 0) {
      break;
    }
    collected.push(line);
    index += 1;
  }
  return new UPMarkdownSlice('<p>' + upMarkdownJoinLines(collected) + '</p>', index);
}

/** 表格。/ Table. */
function upMarkdownTable(lines: Array<string>, start: number): UPMarkdownSlice {
  const headers: Array<string> = upMarkdownCells(lines[start]);
  const alignments: Array<string> = [];
  for (const spec of upMarkdownCells(lines[start + 1])) {
    alignments.push(upMarkdownAlignment(spec));
  }
  let html: string = '<table><thead><tr>';
  for (let index: number = 0; index < headers.length; index++) {
    html += '<th' + upMarkdownCellStyle(alignments, index) + '>' + upMarkdownInline(headers[index]) + '</th>';
  }
  html += '</tr></thead><tbody>';
  let cursor: number = start + 2;
  while (cursor < lines.length) {
    const line: string = lines[cursor];
    if (upMarkdownBlank(line) || !line.includes('|')) {
      break;
    }
    const cells: Array<string> = upMarkdownCells(line);
    html += '<tr>';
    for (let index: number = 0; index < headers.length; index++) {
      const value: string = index < cells.length ? cells[index] : '';
      html += '<td' + upMarkdownCellStyle(alignments, index) + '>' + upMarkdownInline(value) + '</td>';
    }
    html += '</tr>';
    cursor += 1;
  }
  return new UPMarkdownSlice(html + '</tbody></table>', cursor);
}

/**
 * 紧凑内容：首段直接输出行内结果，避免 blockquote 与 li 的边框样式落到子块上；
 * 空行分隔的松散内容整体退回块级解析。
 * Tight content keeps the leading paragraph inline so quote and list decorations stay on the
 * block, while blank-line separated content falls back to the block pass.
 */
function upMarkdownTight(lines: Array<string>, showLineNumber: boolean): string {
  let lead: number = 0;
  while (lead < lines.length && !upMarkdownBlank(lines[lead])
    && (lead === 0 || !upMarkdownBlockStart(lines[lead]))) {
    lead += 1;
  }
  if (lead === lines.length) {
    return upMarkdownJoinLines(lines);
  }
  if (lead === 0 || upMarkdownBlank(lines[lead])) {
    return upMarkdownBlocks(lines, showLineNumber);
  }
  return upMarkdownJoinLines(lines.slice(0, lead)) + upMarkdownBlocks(lines.slice(lead), showLineNumber);
}

/** 引用块。/ Blockquote. */
function upMarkdownQuote(lines: Array<string>, start: number, showLineNumber: boolean): UPMarkdownSlice {
  const inner: Array<string> = [];
  let index: number = start;
  while (index < lines.length) {
    const line: string = lines[index];
    if (upMarkdownBlank(line)) {
      break;
    }
    const trimmed: string = line.trim();
    if (trimmed.charAt(0) !== '>') {
      inner.push(trimmed);
      index += 1;
      continue;
    }
    const body: string = trimmed.substring(1);
    inner.push(body.charAt(0) === ' ' ? body.substring(1) : body);
    index += 1;
  }
  return new UPMarkdownSlice('<blockquote>' + upMarkdownTight(inner, showLineNumber) + '</blockquote>', index);
}

/** 列表，含缩进嵌套。/ List with indentation-based nesting. */
function upMarkdownList(lines: Array<string>, start: number, showLineNumber: boolean): UPMarkdownSlice {
  const baseIndent: number = upMarkdownIndent(lines[start]);
  const first: string = lines[start].substring(baseIndent);
  const ordered: boolean = upMarkdownOrderedWidth(first) > 0;
  const startNumber: number = ordered ? upMarkdownOrderedStart(first) : 1;
  const items: Array<Array<string>> = [];
  let index: number = start;
  let pendingBlank: boolean = false;
  while (index < lines.length) {
    const line: string = lines[index];
    if (upMarkdownBlank(line)) {
      pendingBlank = true;
      index += 1;
      continue;
    }
    const indent: number = upMarkdownIndent(line);
    const body: string = line.substring(indent);
    const marker: number = ordered ? upMarkdownOrderedWidth(body) : upMarkdownBulletWidth(body);
    if (indent <= baseIndent && marker > 0 && !upMarkdownRuleLine(line)) {
      items.push([body.substring(marker)]);
      pendingBlank = false;
      index += 1;
      continue;
    }
    if (items.length === 0) {
      break;
    }
    if (indent > baseIndent) {
      if (pendingBlank) {
        items[items.length - 1].push('');
        pendingBlank = false;
      }
      items[items.length - 1].push(upMarkdownDedent(line, baseIndent + 2));
      index += 1;
      continue;
    }
    if (pendingBlank || upMarkdownBlockStart(line)) {
      break;
    }
    items[items.length - 1].push(body);
    index += 1;
  }
  let html: string = ordered
    ? (startNumber === 1 ? '<ol>' : '<ol start="' + String(startNumber) + '">')
    : '<ul>';
  for (const item of items) {
    html += '<li>' + upMarkdownTight(item, showLineNumber) + '</li>';
  }
  return new UPMarkdownSlice(html + (ordered ? '</ol>' : '</ul>'), index);
}

/** 逐块解析。/ Block-level pass. */
function upMarkdownBlocks(lines: Array<string>, showLineNumber: boolean): string {
  let html: string = '';
  let index: number = 0;
  while (index < lines.length) {
    const line: string = lines[index];
    if (upMarkdownBlank(line)) {
      index += 1;
      continue;
    }
    const fence: string = upMarkdownFenceMark(line);
    if (fence.length > 0) {
      const block: UPMarkdownSlice = upMarkdownFenced(lines, index, fence, showLineNumber);
      html += block.html;
      index = block.next;
      continue;
    }
    if (upMarkdownRuleLine(line)) {
      html += '<hr>';
      index += 1;
      continue;
    }
    const level: number = upMarkdownHeadingLevel(line);
    if (level > 0) {
      const heading: string = String(level);
      html += '<h' + heading + '>' + upMarkdownInline(upMarkdownHeadingText(line, level)) + '</h' + heading + '>';
      index += 1;
      continue;
    }
    if (line.trim().charAt(0) === '>') {
      const quote: UPMarkdownSlice = upMarkdownQuote(lines, index, showLineNumber);
      html += quote.html;
      index = quote.next;
      continue;
    }
    if (index + 1 < lines.length && line.includes('|') && upMarkdownTableDelimiter(lines[index + 1])) {
      const table: UPMarkdownSlice = upMarkdownTable(lines, index);
      html += table.html;
      index = table.next;
      continue;
    }
    const body: string = line.substring(upMarkdownIndent(line));
    if (upMarkdownBulletWidth(body) > 0 || upMarkdownOrderedWidth(body) > 0) {
      const list: UPMarkdownSlice = upMarkdownList(lines, index, showLineNumber);
      html += list.html;
      index = list.next;
      continue;
    }
    const paragraph: UPMarkdownSlice = upMarkdownParagraph(lines, index);
    const setext: number = paragraph.next < lines.length && paragraph.next > index
      ? upMarkdownSetextLevel(lines[paragraph.next])
      : 0;
    if (setext > 0) {
      const heading: string = String(setext);
      html += '<h' + heading + '>' + paragraph.html.substring(3, paragraph.html.length - 4) + '</h' + heading + '>';
      index = paragraph.next + 1;
      continue;
    }
    html += paragraph.html;
    index = paragraph.next;
  }
  return html;
}

/** 上游 parseMarkdown() 的解析步骤。/ The parsing step of the upstream parseMarkdown(). */
export function upMarkdownToHtml(content: string, showLineNumber: boolean): string {
  if (content.length === 0) {
    return '';
  }
  const normalized: string = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n').replace(/\t/g, '    ');
  return upMarkdownBlocks(normalized.split('\n'), showLineNumber);
}

/** 上游 applyTheme() 原样返回，主题只切换注入的标签样式。/ Upstream applyTheme() is a no-op. */
export function upMarkdownApplyTheme(html: string): string {
  return html;
}

/** theme 是否落在上游取值内。/ Whether theme is one of the upstream values. */
export function upMarkdownThemeSupported(theme: string): boolean {
  return UP_MARKDOWN_THEMES.includes(theme);
}

/** 是否深色主题。/ Whether the dark theme is selected. */
export function upMarkdownDarkTheme(theme: string): boolean {
  return theme === 'dark';
}

/** 根节点文字色。/ Root text color. */
export function upMarkdownBaseColor(dark: boolean): string {
  return dark ? UP_MARKDOWN_DARK_COLOR : UP_MARKDOWN_LIGHT_COLOR;
}

/** 根节点背景色。/ Root background color. */
export function upMarkdownBackground(dark: boolean): string {
  return dark ? UP_MARKDOWN_DARK_BACKGROUND : UP_MARKDOWN_TRANSPARENT;
}

/** 链接色。/ Link color. */
export function upMarkdownLinkColor(dark: boolean): string {
  return dark ? UP_MARKDOWN_DARK_LINK : UP_MARKDOWN_LIGHT_LINK;
}

/** 上游 scss 转成 up-parse 的 tagStyle 声明。/ Upstream scss lifted into up-parse tagStyle. */
export function upMarkdownTagStyle(dark: boolean): Array<UPHtmlDeclaration> {
  const list: Array<UPHtmlDeclaration> = [];
  const codeBackground: string = dark ? UP_MARKDOWN_DARK_CODE : UP_MARKDOWN_LIGHT_CODE;
  const codeColor: string = dark ? ';color:' + UP_MARKDOWN_DARK_CODE_COLOR : '';
  const quoteColor: string = dark ? UP_MARKDOWN_DARK_QUOTE : UP_MARKDOWN_LIGHT_QUOTE;
  for (let level: number = 1; level <= 6; level++) {
    list.push(new UPHtmlDeclaration('h' + String(level),
      'font-size:' + String(UP_MARKDOWN_HEADING_SIZES[level - 1]) + 'px;margin:'
      + String(UP_MARKDOWN_HEADING_MARGINS[level - 1]) + 'px 0;font-weight:bold'));
  }
  list.push(new UPHtmlDeclaration('p', 'margin:16px 0;line-height:' + UP_MARKDOWN_LINE_HEIGHT));
  list.push(new UPHtmlDeclaration('a', 'color:' + upMarkdownLinkColor(dark) + ';text-decoration:none'));
  list.push(new UPHtmlDeclaration('ul', 'margin:16px 0;padding-left:32px'));
  list.push(new UPHtmlDeclaration('ol', 'margin:16px 0;padding-left:32px'));
  list.push(new UPHtmlDeclaration('li', 'margin:8px 0;line-height:' + UP_MARKDOWN_LINE_HEIGHT));
  list.push(new UPHtmlDeclaration('blockquote', 'margin:8px 0;padding:0 10px;border-left:4px solid '
    + UP_MARKDOWN_QUOTE_BORDER + ';color:' + quoteColor));
  list.push(new UPHtmlDeclaration('pre', 'font-family:monospace;white-space:pre;font-size:14px;background-color:'
    + codeBackground + ';padding:16px;border-radius:6px;margin:16px 0;line-height:' + UP_MARKDOWN_LINE_HEIGHT + codeColor));
  list.push(new UPHtmlDeclaration('code', 'font-family:monospace;font-size:14px' + codeColor));
  list.push(new UPHtmlDeclaration('table', 'margin:16px 0'));
  list.push(new UPHtmlDeclaration('th', 'padding:6px 13px;border:1px solid ' + UP_MARKDOWN_TABLE_BORDER
    + ';font-weight:600;line-height:' + UP_MARKDOWN_LINE_HEIGHT));
  list.push(new UPHtmlDeclaration('td', 'padding:6px 13px;border:1px solid ' + UP_MARKDOWN_TABLE_BORDER
    + ';line-height:' + UP_MARKDOWN_LINE_HEIGHT));
  list.push(new UPHtmlDeclaration('img', 'margin:16px 0;background-color:' + UP_MARKDOWN_IMAGE_BACKGROUND));
  list.push(new UPHtmlDeclaration('hr', 'height:1px;margin:24px 0;background-color:' + UP_MARKDOWN_RULE_COLOR));
  return list;
}
