import { UPI18n, upWeekText } from '../core/UPI18n';
/**
 * 上游 u-novel-reader 的内容归一、分页排版与阅读状态核心。
 * Content normalizer, pagination engine and reader core of the upstream u-novel-reader.
 */

/** 上游 DEFAULT_READER_SETTINGS。/ Upstream DEFAULT_READER_SETTINGS. */
export const UP_NOVEL_DEFAULT_THEME: string = 'day';
export const UP_NOVEL_DEFAULT_FONT_SIZE: number = 18;
export const UP_NOVEL_DEFAULT_LINE_HEIGHT: number = 1.8;
export const UP_NOVEL_DEFAULT_PARAGRAPH_SPACING: number = 16;
export const UP_NOVEL_DEFAULT_CONTENT_WIDTH: string = '92%';
export const UP_NOVEL_DEFAULT_FONT_FAMILY: string = 'system';
export const UP_NOVEL_DEFAULT_FONT_WEIGHT: number = 400;
/** 上游 mergeReaderSettings 的钳制区间。/ Clamp ranges from upstream mergeReaderSettings. */
export const UP_NOVEL_FONT_SIZE_MIN: number = 12;
export const UP_NOVEL_FONT_SIZE_MAX: number = 48;
export const UP_NOVEL_LINE_HEIGHT_MIN: number = 1;
export const UP_NOVEL_LINE_HEIGHT_MAX: number = 3;
export const UP_NOVEL_SPACING_MIN: number = 0;
export const UP_NOVEL_SPACING_MAX: number = 80;
export const UP_NOVEL_CONTENT_WIDTH_MIN: number = 40;
export const UP_NOVEL_CONTENT_WIDTH_MAX: number = 100;
export const UP_NOVEL_BOLD_WEIGHT: number = 600;
/** 上游 ALLOWED_MODES 与主题名。/ Upstream ALLOWED_MODES and theme names. */
export const UP_NOVEL_MODES: Array<string> = ['scroll', 'page'];
export const UP_NOVEL_THEMES: Array<string> = ['day', 'paper', 'green', 'night', 'dark'];
/** 上游 persistence.js 的存储版本与键前缀。/ Storage version and key prefix from persistence.js. */
export const UP_NOVEL_STORAGE_VERSION: number = 1;
export const UP_NOVEL_STORAGE_PREFIX: string = 'uview-plus:novel-reader:';
/** 上游 refreshLayout 的视口留白与 queuePersist 的节流。/ Viewport inset and persist debounce. */
export const UP_NOVEL_VIEWPORT_INSET: number = 64;
export const UP_NOVEL_PERSIST_DELAY: number = 180;
/** 上游 getBookmarkExcerpt 的截取窗口。/ Excerpt window of upstream getBookmarkExcerpt. */
export const UP_NOVEL_EXCERPT_BEFORE: number = 12;
export const UP_NOVEL_EXCERPT_AFTER: number = 28;
/** 上游 reader-content 的正文上下内边距。/ Article padding of the upstream reader-content. */
export const UP_NOVEL_ARTICLE_PADDING: number = 32;
/** 上游 measure-adapter 的字宽系数。/ Character width factors from measure-adapter. */
export const UP_NOVEL_BLANK_FACTOR: number = 0.28;
export const UP_NOVEL_LATIN_FACTOR: number = 0.56;
/** 上游 reader-settings 的滑块区间。/ Slider ranges from the upstream reader-settings. */
export const UP_NOVEL_SETTING_FONT_MIN: number = 12;
export const UP_NOVEL_SETTING_FONT_MAX: number = 32;
export const UP_NOVEL_SETTING_LINE_MIN: number = 1.2;
export const UP_NOVEL_SETTING_LINE_MAX: number = 2.6;
export const UP_NOVEL_SETTING_SPACING_MAX: number = 36;
export const UP_NOVEL_SETTING_WIDTH_MIN: number = 60;
/** 上游 reader-content 与 reader-catalog 的默认文案。/ Default copy of the upstream sub components. */
export const UP_NOVEL_LOADING_TEXT: string = '章节加载中';
export const UP_NOVEL_ERROR_TEXT: string = '章节加载失败';
export const UP_NOVEL_RETRY_TEXT: string = UPI18n.t('up.common.retry');
export const UP_NOVEL_EMPTY_TEXT: string = '暂无正文';
export const UP_NOVEL_TITLE_FALLBACK: string = '小说阅读';
export const UP_NOVEL_CATALOG_TITLE: string = '目录';
export const UP_NOVEL_CATALOG_EMPTY: string = '暂无目录';
export const UP_NOVEL_BOOKMARK_TITLE: string = '书签';
export const UP_NOVEL_BOOKMARK_FALLBACK: string = '书签位置';
export const UP_NOVEL_SETTINGS_TITLE: string = '阅读设置';
export const UP_NOVEL_PROGRESS_FALLBACK: string = '阅读进度';

/** 一段正文。/ One normalized paragraph. */
export class UPNovelParagraph {
  index: number = 0;
  text: string = '';
  startOffset: number = 0;
  endOffset: number = 0;

  constructor(index: number, text: string, startOffset: number, endOffset: number) {
    this.index = index;
    this.text = text;
    this.startOffset = startOffset;
    this.endOffset = endOffset;
  }
}

/** 上游 normalizeContent 的返回值。/ Result of upstream normalizeContent(). */
export class UPNovelContent {
  paragraphs: Array<UPNovelParagraph> = [];
  text: string = '';
  length: number = 0;
}

/** 一行排版结果。/ One laid-out line. */
export class UPNovelLine {
  text: string = '';
  startOffset: number = 0;
  endOffset: number = 0;
  paragraphIndex: number = 0;

  constructor(text: string, startOffset: number, endOffset: number, paragraphIndex: number = 0) {
    this.text = text;
    this.startOffset = startOffset;
    this.endOffset = endOffset;
    this.paragraphIndex = paragraphIndex;
  }
}

/** 一页排版结果。/ One paginated page. */
export class UPNovelPage {
  index: number = 0;
  text: string = '';
  lines: Array<UPNovelLine> = [];
  startOffset: number = 0;
  endOffset: number = 0;
}

/** 上游 paginateParagraphs 的返回值。/ Result of upstream paginateParagraphs(). */
export class UPNovelLayoutResult {
  pages: Array<UPNovelPage> = [];
  pageCount: number = 0;
}

/** 排版入参。/ Layout options. */
export class UPNovelLayoutOptions {
  width: number = 320;
  height: number = 500;
  fontSize: number = UP_NOVEL_DEFAULT_FONT_SIZE;
  lineHeight: number = UP_NOVEL_DEFAULT_LINE_HEIGHT;
  paragraphSpacing: number = UP_NOVEL_DEFAULT_PARAGRAPH_SPACING;
}

/** 上游 resolveAnchor 的返回值。/ Result of upstream resolveAnchor(). */
export class UPNovelAnchor {
  pageIndex: number = 0;
  localOffset: number = 0;

  constructor(pageIndex: number, localOffset: number) {
    this.pageIndex = pageIndex;
    this.localOffset = localOffset;
  }
}

/** 阅读设置，对应上游 DEFAULT_READER_SETTINGS。/ Reader settings mirroring the upstream defaults. */
export class UPNovelSettings {
  theme: string = UP_NOVEL_DEFAULT_THEME;
  fontSize: number = UP_NOVEL_DEFAULT_FONT_SIZE;
  lineHeight: number = UP_NOVEL_DEFAULT_LINE_HEIGHT;
  paragraphSpacing: number = UP_NOVEL_DEFAULT_PARAGRAPH_SPACING;
  contentWidth: string = UP_NOVEL_DEFAULT_CONTENT_WIDTH;
  fontFamily: string = UP_NOVEL_DEFAULT_FONT_FAMILY;
  fontWeight: number = UP_NOVEL_DEFAULT_FONT_WEIGHT;
  animation: boolean = true;

  clone(): UPNovelSettings {
    const copy: UPNovelSettings = new UPNovelSettings();
    copy.theme = this.theme;
    copy.fontSize = this.fontSize;
    copy.lineHeight = this.lineHeight;
    copy.paragraphSpacing = this.paragraphSpacing;
    copy.contentWidth = this.contentWidth;
    copy.fontFamily = this.fontFamily;
    copy.fontWeight = this.fontWeight;
    copy.animation = this.animation;
    return copy;
  }
}

/** 设置补丁，宿主只需给出要改的字段。/ Partial settings patch supplied by the host. */
export interface UPNovelSettingsPatch {
  theme?: string;
  fontSize?: number;
  lineHeight?: number;
  paragraphSpacing?: number;
  contentWidth?: string;
  fontFamily?: string;
  fontWeight?: number;
  animation?: boolean;
}

/** 一章内容。/ One chapter. */
export interface UPNovelChapter {
  id?: string;
  index?: number;
  title?: string;
  content?: string;
  isLocked?: boolean;
}

/** 阅读进度，对应上游 normalizeProgress 的输出。/ Reading progress mirroring normalizeProgress(). */
export class UPNovelProgress {
  chapterId: string = '';
  chapterIndex: number = 0;
  pageIndex: number = 0;
  pageCount: number = 0;
  charOffset: number = 0;
  chapterProgress: number = 0;
  totalProgress: number = 0;
  scrollTop: number = 0;
  updatedAt: number = 0;

  clone(): UPNovelProgress {
    const copy: UPNovelProgress = new UPNovelProgress();
    copy.chapterId = this.chapterId;
    copy.chapterIndex = this.chapterIndex;
    copy.pageIndex = this.pageIndex;
    copy.pageCount = this.pageCount;
    copy.charOffset = this.charOffset;
    copy.chapterProgress = this.chapterProgress;
    copy.totalProgress = this.totalProgress;
    copy.scrollTop = this.scrollTop;
    copy.updatedAt = this.updatedAt;
    return copy;
  }
}

/** 进度补丁，供宿主回传部分字段。/ Partial progress patch from the host. */
export interface UPNovelProgressPatch {
  chapterId?: string;
  chapterIndex?: number;
  pageIndex?: number;
  pageCount?: number;
  charOffset?: number;
  chapterProgress?: number;
  totalProgress?: number;
  scrollTop?: number;
  updatedAt?: number;
}

/** 书签，对应上游 createBookmark。/ One bookmark mirroring createBookmark(). */
export class UPNovelBookmark {
  id: string = '';
  chapterId: string = '';
  chapterIndex: number = 0;
  charOffset: number = 0;
  pageIndex: number = 0;
  scrollTop: number = 0;
  excerpt: string = '';
  createdAt: number = 0;
}

/** 章节请求，对应上游 chapter-request。/ Chapter request payload. */
export interface UPNovelChapterRequest {
  targetIndex: number;
  targetId: string;
  direction: string;
  requestId: string;
}

/** 持久化快照，对应上游 writePersistedState 的载荷。/ Persisted snapshot payload. */
export class UPNovelPersistedState {
  version: number = UP_NOVEL_STORAGE_VERSION;
  progress?: UPNovelProgress;
  settings?: UPNovelSettings;
  bookmarks: Array<UPNovelBookmark> = [];
  readingTime: number = 0;
  updatedAt: number = 0;
}

/** 宿主注入的持久化适配器，替代 uni.getStorageSync。/ Host storage adapter replacing uni storage. */
export interface UPNovelStorage {
  get(key: string): UPNovelPersistedState | undefined;
  set(key: string, value: UPNovelPersistedState): void;
  remove(key: string): void;
}

/** 上游 clamp()。/ Mirrors upstream clamp(). */
export function upNovelClamp(value: number, min: number, max: number, fallback: number): number {
  if (!Number.isFinite(value)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, value));
}

/** 上游 normalizeMode()。/ Mirrors upstream normalizeMode(). */
export function upNovelMode(mode: string): string {
  return UP_NOVEL_MODES.includes(mode) ? mode : 'scroll';
}

/** theme 是否落在上游取值内。/ Whether the theme is modelled upstream. */
export function upNovelThemeSupported(theme: string): boolean {
  return UP_NOVEL_THEMES.includes(theme);
}

/** 上游 normalizeContentWidth()。/ Mirrors upstream normalizeContentWidth(). */
export function upNovelContentWidth(value: string): string {
  const text: string = value.trim();
  if (text.length === 0) {
    return UP_NOVEL_DEFAULT_CONTENT_WIDTH;
  }
  if (!text.endsWith('%')) {
    const amount: number = parseFloat(text);
    if (isNaN(amount)) {
      return UP_NOVEL_DEFAULT_CONTENT_WIDTH;
    }
    return String(upNovelClamp(amount, UP_NOVEL_CONTENT_WIDTH_MIN, UP_NOVEL_CONTENT_WIDTH_MAX, 92)) + '%';
  }
  return text;
}

/** 上游 mergeReaderSettings()：逐字段覆盖后统一钳制。/ Mirrors upstream mergeReaderSettings(). */
export function upNovelMergeSettings(base: UPNovelSettings, patch?: UPNovelSettingsPatch): UPNovelSettings {
  const result: UPNovelSettings = base.clone();
  if (patch !== undefined) {
    result.theme = patch.theme ?? result.theme;
    result.fontSize = patch.fontSize ?? result.fontSize;
    result.lineHeight = patch.lineHeight ?? result.lineHeight;
    result.paragraphSpacing = patch.paragraphSpacing ?? result.paragraphSpacing;
    result.contentWidth = patch.contentWidth ?? result.contentWidth;
    result.fontFamily = patch.fontFamily ?? result.fontFamily;
    result.fontWeight = patch.fontWeight ?? result.fontWeight;
    result.animation = patch.animation ?? result.animation;
  }
  result.fontSize = upNovelClamp(result.fontSize, UP_NOVEL_FONT_SIZE_MIN, UP_NOVEL_FONT_SIZE_MAX,
    UP_NOVEL_DEFAULT_FONT_SIZE);
  result.lineHeight = upNovelClamp(result.lineHeight, UP_NOVEL_LINE_HEIGHT_MIN, UP_NOVEL_LINE_HEIGHT_MAX,
    UP_NOVEL_DEFAULT_LINE_HEIGHT);
  result.paragraphSpacing = upNovelClamp(result.paragraphSpacing, UP_NOVEL_SPACING_MIN, UP_NOVEL_SPACING_MAX,
    UP_NOVEL_DEFAULT_PARAGRAPH_SPACING);
  result.contentWidth = upNovelContentWidth(result.contentWidth);
  result.fontWeight = result.fontWeight >= UP_NOVEL_BOLD_WEIGHT ? UP_NOVEL_BOLD_WEIGHT : UP_NOVEL_DEFAULT_FONT_WEIGHT;
  return result;
}

/** 上游 normalizeContent()：按换行拆段并累计字符偏移。/ Mirrors upstream normalizeContent(). */
export function upNovelNormalizeContent(content: string): UPNovelContent {
  const result: UPNovelContent = new UPNovelContent();
  const source: Array<string> = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n');
  let printable: boolean = false;
  for (const line of source) {
    if (line.length > 0) {
      printable = true;
    }
  }
  if (!printable) {
    return result;
  }
  let offset: number = 0;
  for (let index: number = 0; index < source.length; index++) {
    const text: string = source[index];
    const start: number = offset;
    const end: number = start + text.length;
    offset = end + 1;
    result.paragraphs.push(new UPNovelParagraph(index, text, start, end));
  }
  const texts: Array<string> = [];
  for (const paragraph of result.paragraphs) {
    texts.push(paragraph.text);
  }
  result.text = texts.join('\n');
  result.length = result.text.length;
  return result;
}

/** 上游 measure-adapter 的 getCharacterWidth()。/ Mirrors getCharacterWidth() from measure-adapter. */
export function upNovelCharacterWidth(character: string, fontSize: number): number {
  const cjk: RegExp = /[\u3400-\u9fff\u3040-\u30ff\uff00-\uffef]/;
  if (cjk.test(character)) {
    return fontSize;
  }
  const blank: RegExp = /\s/;
  return blank.test(character) ? fontSize * UP_NOVEL_BLANK_FACTOR : fontSize * UP_NOVEL_LATIN_FACTOR;
}

/** 上游 measureTextWidth()。/ Mirrors upstream measureTextWidth(). */
export function upNovelMeasureText(text: string, fontSize: number): number {
  let width: number = 0;
  let index: number = 0;
  while (index < text.length) {
    const code: number = text.charCodeAt(index);
    if (code >= 0xd800 && code <= 0xdbff && index + 1 < text.length) {
      width += fontSize;
      index += 2;
      continue;
    }
    width += upNovelCharacterWidth(text.charAt(index), fontSize);
    index += 1;
  }
  return width;
}

/** 上游 getLineHeight()：小于等于 4 视作倍数。/ Mirrors upstream getLineHeight(). */
export function upNovelLineHeight(fontSize: number, lineHeight: number): number {
  if (!Number.isFinite(lineHeight)) {
    return fontSize * UP_NOVEL_DEFAULT_LINE_HEIGHT;
  }
  return lineHeight <= 4 ? fontSize * lineHeight : lineHeight;
}

/** 上游 tokenizeText()：CJK 与空白单独成词，其余按连续片段。/ Mirrors upstream tokenizeText(). */
export function upNovelTokenize(text: string): Array<UPNovelLine> {
  const units: Array<UPNovelLine> = [];
  const cjk: RegExp = /[\u3400-\u9fff\u3040-\u30ff\uff00-\uffef]/;
  const blank: RegExp = /\s/;
  let token: string = '';
  let tokenStart: number = 0;
  let offset: number = 0;
  let index: number = 0;
  while (index < text.length) {
    const code: number = text.charCodeAt(index);
    const surrogate: boolean = code >= 0xd800 && code <= 0xdbff && index + 1 < text.length;
    const character: string = surrogate ? text.substring(index, index + 2) : text.charAt(index);
    const start: number = offset;
    offset += character.length;
    index += character.length;
    if (cjk.test(character) || blank.test(character) || surrogate) {
      if (token.length > 0) {
        units.push(new UPNovelLine(token, tokenStart, start));
        token = '';
      }
      units.push(new UPNovelLine(character, start, offset));
      tokenStart = offset;
      continue;
    }
    if (token.length === 0) {
      tokenStart = start;
    }
    token += character;
  }
  if (token.length > 0) {
    units.push(new UPNovelLine(token, tokenStart, offset));
  }
  return units;
}

/** 上游 splitUnit()：超宽词拆成单字。/ Mirrors upstream splitUnit(). */
function upNovelSplitUnit(unit: UPNovelLine): Array<UPNovelLine> {
  if (unit.text.length <= 1) {
    return [unit];
  }
  const result: Array<UPNovelLine> = [];
  let offset: number = unit.startOffset;
  for (let index: number = 0; index < unit.text.length; index++) {
    const character: string = unit.text.charAt(index);
    result.push(new UPNovelLine(character, offset, offset + character.length));
    offset += character.length;
  }
  return result;
}

/** 上游 wrapText()。/ Mirrors upstream wrapText(). */
export function upNovelWrapText(text: string, width: number, fontSize: number): Array<UPNovelLine> {
  if (text.length === 0) {
    return [new UPNovelLine('', 0, 0)];
  }
  const limit: number = width > 0 ? width : 1;
  const units: Array<UPNovelLine> = [];
  for (const unit of upNovelTokenize(text)) {
    if (upNovelMeasureText(unit.text, fontSize) > limit && unit.text.length > 1) {
      for (const piece of upNovelSplitUnit(unit)) {
        units.push(piece);
      }
      continue;
    }
    units.push(unit);
  }
  const lines: Array<UPNovelLine> = [];
  let current: Array<UPNovelLine> = [];
  let currentText: string = '';
  for (const unit of units) {
    const candidate: string = currentText + unit.text;
    if (current.length > 0 && upNovelMeasureText(candidate, fontSize) > limit) {
      lines.push(new UPNovelLine(currentText, current[0].startOffset, current[current.length - 1].endOffset));
      current = [unit];
      currentText = unit.text;
      continue;
    }
    current.push(unit);
    currentText = candidate;
  }
  if (current.length > 0) {
    lines.push(new UPNovelLine(currentText, current[0].startOffset, current[current.length - 1].endOffset));
  }
  return lines;
}

/** 上游 paginateParagraphs()。/ Mirrors upstream paginateParagraphs(). */
export function upNovelPaginate(paragraphs: Array<UPNovelParagraph>,
  options: UPNovelLayoutOptions): UPNovelLayoutResult {
  const result: UPNovelLayoutResult = new UPNovelLayoutResult();
  const width: number = Math.max(1, options.width);
  const height: number = Math.max(1, options.height);
  const lineHeight: number = Math.max(1, upNovelLineHeight(options.fontSize, options.lineHeight));
  const spacing: number = Math.max(0, options.paragraphSpacing);
  let lines: Array<UPNovelLine> = [];
  let usedHeight: number = 0;
  for (let paragraphIndex: number = 0; paragraphIndex < paragraphs.length; paragraphIndex++) {
    const paragraph: UPNovelParagraph = paragraphs[paragraphIndex];
    const wrapped: Array<UPNovelLine> = upNovelWrapText(paragraph.text, width, options.fontSize);
    if (paragraphIndex > 0 && lines.length > 0 && usedHeight + spacing + lineHeight > height) {
      result.pages.push(upNovelCreatePage(lines, result.pages.length));
      lines = [];
      usedHeight = 0;
    } else if (paragraphIndex > 0 && lines.length > 0) {
      usedHeight += spacing;
    }
    for (const line of wrapped) {
      if (lines.length > 0 && usedHeight + lineHeight > height) {
        result.pages.push(upNovelCreatePage(lines, result.pages.length));
        lines = [];
        usedHeight = 0;
      }
      lines.push(new UPNovelLine(line.text, line.startOffset + paragraph.startOffset,
        line.endOffset + paragraph.startOffset, paragraphIndex));
      usedHeight += lineHeight;
    }
  }
  if (lines.length > 0) {
    result.pages.push(upNovelCreatePage(lines, result.pages.length));
  }
  result.pageCount = result.pages.length;
  return result;
}

/** 上游 createPage()。/ Mirrors upstream createPage(). */
function upNovelCreatePage(lines: Array<UPNovelLine>, index: number): UPNovelPage {
  const page: UPNovelPage = new UPNovelPage();
  page.index = index;
  page.lines = lines;
  const texts: Array<string> = [];
  for (const line of lines) {
    texts.push(line.text);
  }
  page.text = texts.join('\n');
  page.startOffset = lines[0].startOffset;
  page.endOffset = lines[lines.length - 1].endOffset;
  return page;
}

/** 上游 resolveAnchor()。/ Mirrors upstream resolveAnchor(). */
export function upNovelResolveAnchor(pages: Array<UPNovelPage>, charOffset: number): UPNovelAnchor {
  if (pages.length === 0) {
    return new UPNovelAnchor(0, 0);
  }
  const offset: number = Math.max(0, Number.isFinite(charOffset) ? charOffset : 0);
  let target: UPNovelPage = pages[pages.length - 1];
  for (const page of pages) {
    if (offset <= page.endOffset) {
      target = page;
      break;
    }
  }
  return new UPNovelAnchor(target.index,
    Math.max(0, Math.min(target.text.length, offset - target.startOffset)));
}

/** 上游 normalizeProgress()。/ Mirrors upstream normalizeProgress(). */
export function upNovelNormalizeProgress(progress: UPNovelProgressPatch | undefined,
  chapter: UPNovelChapter | undefined, contentLength: number): UPNovelProgress {
  const result: UPNovelProgress = new UPNovelProgress();
  const requestedOffset: number = progress === undefined ? 0 : (progress.charOffset ?? 0);
  result.charOffset = Math.min(contentLength,
    Math.max(0, Number.isFinite(requestedOffset) ? requestedOffset : 0));
  const chapterIndex: number = chapter === undefined ? Number.NaN : (chapter.index ?? Number.NaN);
  result.chapterId = progress !== undefined && progress.chapterId !== undefined
    ? progress.chapterId
    : (chapter === undefined ? '' : (chapter.id ?? ''));
  result.chapterIndex = Number.isFinite(chapterIndex)
    ? chapterIndex
    : (progress === undefined ? 0 : (progress.chapterIndex ?? 0));
  const requestedPage: number = progress === undefined ? 0 : (progress.pageIndex ?? 0);
  result.pageIndex = Math.max(0, Number.isFinite(requestedPage) ? requestedPage : 0);
  result.pageCount = Math.max(0, progress === undefined ? 0 : (progress.pageCount ?? 0));
  result.chapterProgress = contentLength > 0
    ? Math.min(1, Math.max(0, result.charOffset / contentLength))
    : 0;
  result.totalProgress = Math.min(1, Math.max(0, progress === undefined ? 0 : (progress.totalProgress ?? 0)));
  result.scrollTop = Math.max(0, progress === undefined ? 0 : (progress.scrollTop ?? 0));
  result.updatedAt = progress === undefined ? 0 : (progress.updatedAt ?? 0);
  return result;
}

/** 上游 createBookmark()。/ Mirrors upstream createBookmark(). */
export function upNovelCreateBookmark(chapterId: string, chapterIndex: number, charOffset: number,
  pageIndex: number, scrollTop: number, excerpt: string, createdAt: number): UPNovelBookmark {
  const bookmark: UPNovelBookmark = new UPNovelBookmark();
  const offset: number = Math.max(0, Number.isFinite(charOffset) ? charOffset : 0);
  bookmark.id = chapterId + ':' + String(offset);
  bookmark.chapterId = chapterId;
  bookmark.chapterIndex = Number.isFinite(chapterIndex) ? chapterIndex : 0;
  bookmark.charOffset = offset;
  bookmark.pageIndex = Math.max(0, Number.isFinite(pageIndex) ? pageIndex : 0);
  bookmark.scrollTop = Math.max(0, Number.isFinite(scrollTop) ? scrollTop : 0);
  bookmark.excerpt = excerpt;
  bookmark.createdAt = createdAt;
  return bookmark;
}

/** 上游 toggleBookmark()。/ Mirrors upstream toggleBookmark(). */
export function upNovelToggleBookmark(bookmarks: Array<UPNovelBookmark>,
  bookmark: UPNovelBookmark): Array<UPNovelBookmark> {
  if (bookmark.id.length === 0) {
    return bookmarks.slice();
  }
  const kept: Array<UPNovelBookmark> = [];
  let existed: boolean = false;
  for (const item of bookmarks) {
    if (item.id === bookmark.id) {
      existed = true;
      continue;
    }
    kept.push(item);
  }
  if (existed) {
    return kept;
  }
  const appended: Array<UPNovelBookmark> = bookmarks.slice();
  appended.push(bookmark);
  return appended;
}

/** 上游 createStorageKey()。/ Mirrors upstream createStorageKey(). */
export function upNovelStorageKey(storageKey: string, bookId: string): string {
  if (storageKey.length > 0) {
    return storageKey;
  }
  return bookId.length === 0 ? '' : UP_NOVEL_STORAGE_PREFIX + bookId;
}

/** 上游 normalizePersistedState()：版本或数值不合法时整体丢弃。/ Mirrors normalizePersistedState(). */
export function upNovelNormalizePersisted(state: UPNovelPersistedState | undefined): UPNovelPersistedState | undefined {
  if (state === undefined || state.version !== UP_NOVEL_STORAGE_VERSION) {
    return undefined;
  }
  if (!Number.isFinite(state.readingTime) || state.readingTime < 0) {
    return undefined;
  }
  if (!Number.isFinite(state.updatedAt) || state.updatedAt < 0) {
    return undefined;
  }
  const normalized: UPNovelPersistedState = new UPNovelPersistedState();
  normalized.readingTime = state.readingTime;
  normalized.updatedAt = state.updatedAt;
  normalized.settings = state.settings === undefined ? undefined : state.settings.clone();
  const progress: UPNovelProgress | undefined = state.progress;
  if (progress !== undefined) {
    if (progress.chapterProgress < 0 || progress.chapterProgress > 1
      || progress.totalProgress < 0 || progress.totalProgress > 1) {
      return undefined;
    }
    const copy: UPNovelProgress = progress.clone();
    copy.pageIndex = Math.max(0, copy.pageIndex);
    copy.pageCount = Math.max(0, copy.pageCount);
    copy.charOffset = Math.max(0, copy.charOffset);
    copy.scrollTop = Math.max(0, copy.scrollTop);
    normalized.progress = copy;
  }
  for (const bookmark of state.bookmarks) {
    if (bookmark.id.length === 0 || bookmark.charOffset < 0 || !Number.isFinite(bookmark.charOffset)) {
      continue;
    }
    normalized.bookmarks.push(bookmark);
  }
  return normalized;
}

/** 上游 getBookmarkExcerpt()。/ Mirrors upstream getBookmarkExcerpt(). */
export function upNovelExcerpt(text: string, charOffset: number): string {
  const offset: number = Math.max(0, Number.isFinite(charOffset) ? charOffset : 0);
  return text.slice(Math.max(0, offset - UP_NOVEL_EXCERPT_BEFORE), offset + UP_NOVEL_EXCERPT_AFTER).trim();
}

/** 上游 resolveContentWidth()。/ Mirrors upstream resolveContentWidth(). */
export function upNovelResolveContentWidth(width: number, contentWidth: string): number {
  const text: string = contentWidth.trim();
  if (text.endsWith('%')) {
    const percent: number = parseFloat(text);
    const clamped: number = upNovelClamp(percent, UP_NOVEL_CONTENT_WIDTH_MIN, UP_NOVEL_CONTENT_WIDTH_MAX, 92);
    return width * clamped / 100;
  }
  const amount: number = parseFloat(text);
  return Math.min(width, Math.max(1, isNaN(amount) ? width : amount));
}

/** 主题取色，对应上游 THEME_TOKENS。/ Theme tokens mirroring the upstream THEME_TOKENS. */
export class UPNovelTheme {
  theme: string = UP_NOVEL_DEFAULT_THEME;
  background: string = '#f7f8fa';
  text: string = '#303133';
  muted: string = '#909399';
  toolbar: string = '#ffffff';
  border: string = 'rgba(48, 49, 51, 0.12)';
  active: string = '#2979ff';
  disabled: string = '#c8c9cc';

  constructor(theme: string, background: string, text: string, muted: string, toolbar: string,
    border: string, active: string, disabled: string) {
    this.theme = theme;
    this.background = background;
    this.text = text;
    this.muted = muted;
    this.toolbar = toolbar;
    this.border = border;
    this.active = active;
    this.disabled = disabled;
  }
}

/** 上游 THEME_TOKENS 的五套取色。/ The five upstream theme palettes. */
export function upNovelTheme(theme: string): UPNovelTheme {
  if (theme === 'paper') {
    return new UPNovelTheme('paper', '#f3ead7', '#51483d', '#8f806d', '#f7efdf',
      'rgba(81, 72, 61, 0.16)', '#9b7653', '#c7b9a3');
  }
  if (theme === 'green') {
    return new UPNovelTheme('green', '#e7f1e4', '#3f5140', '#708371', '#eef6eb',
      'rgba(63, 81, 64, 0.16)', '#4d8b55', '#b6c7b4');
  }
  if (theme === 'night') {
    return new UPNovelTheme('night', '#202124', '#d6d7da', '#9ca0a8', '#292b30',
      'rgba(214, 215, 218, 0.16)', '#7da7ff', '#62656d');
  }
  if (theme === 'dark') {
    return new UPNovelTheme('dark', '#111214', '#e5e7eb', '#9ca3af', '#1b1d21',
      'rgba(229, 231, 235, 0.16)', '#8ab4ff', '#5f6368');
  }
  return new UPNovelTheme('day', '#f7f8fa', '#303133', '#909399', '#ffffff',
    'rgba(48, 49, 51, 0.12)', '#2979ff', '#c8c9cc');
}

/** 上游 reader-settings 的主题选项。/ Theme options of the upstream reader-settings. */
export function upNovelThemeLabel(theme: string): string {
  if (theme === 'paper') {
    return '护眼';
  }
  if (theme === 'green') {
    return '豆沙';
  }
  if (theme === 'night') {
    return '夜间';
  }
  return theme === 'dark' ? '深色' : '日间';
}

/** 上游 reader-toolbar 的 progressLabel。/ Mirrors the upstream progressLabel. */
export function upNovelProgressLabel(chapterIndex: number, chapterCount: number, percent: number): string {
  const current: number = chapterIndex >= 0 ? chapterIndex + 1 : 0;
  const chapterText: string = chapterCount > 0
    ? String(current) + '/' + String(chapterCount)
    : UP_NOVEL_PROGRESS_FALLBACK;
  return chapterText + ' · ' + String(Math.round(percent)) + '%';
}

/** 上游 progressPercent。/ Mirrors the upstream progressPercent. */
export function upNovelProgressPercent(chapterProgress: number, pageIndex: number, pageCount: number): number {
  if (Number.isFinite(chapterProgress) && chapterProgress > 0) {
    return Math.min(100, Math.max(0, chapterProgress * 100));
  }
  if (pageCount > 0) {
    return Math.min(100, Math.max(0, (pageIndex + 1) / pageCount * 100));
  }
  return 0;
}

/** 上游 handleTapZone 的三分区判定。/ Tap-zone split from upstream handleTapZone(). */
export function upNovelTapZone(x: number, width: number): string {
  const resolved: number = width > 0 ? width : 375;
  if (x < resolved / 3) {
    return 'left';
  }
  return x > resolved * 2 / 3 ? 'right' : 'center';
}
