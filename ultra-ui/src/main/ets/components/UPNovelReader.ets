import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPStyle } from '../core/UPStyle';
import {
  UPNovelAnchor,
  UPNovelBookmark,
  UPNovelChapter,
  UPNovelChapterRequest,
  UPNovelContent,
  UPNovelLayoutOptions,
  UPNovelLayoutResult,
  UPNovelPage,
  UPNovelParagraph,
  UPNovelPersistedState,
  UPNovelProgress,
  UPNovelProgressPatch,
  UPNovelSettings,
  UPNovelSettingsPatch,
  UPNovelStorage,
  UPNovelTheme,
  UP_NOVEL_ARTICLE_PADDING,
  UP_NOVEL_BOLD_WEIGHT,
  UP_NOVEL_BOOKMARK_FALLBACK,
  UP_NOVEL_BOOKMARK_TITLE,
  UP_NOVEL_CATALOG_EMPTY,
  UP_NOVEL_CATALOG_TITLE,
  UP_NOVEL_EMPTY_TEXT,
  UP_NOVEL_ERROR_TEXT,
  UP_NOVEL_LOADING_TEXT,
  UP_NOVEL_MODES,
  UP_NOVEL_PERSIST_DELAY,
  UP_NOVEL_RETRY_TEXT,
  UP_NOVEL_SETTINGS_TITLE,
  UP_NOVEL_SETTING_FONT_MAX,
  UP_NOVEL_SETTING_FONT_MIN,
  UP_NOVEL_SETTING_LINE_MAX,
  UP_NOVEL_SETTING_LINE_MIN,
  UP_NOVEL_SETTING_SPACING_MAX,
  UP_NOVEL_SETTING_WIDTH_MIN,
  UP_NOVEL_STORAGE_VERSION,
  UP_NOVEL_THEMES,
  UP_NOVEL_TITLE_FALLBACK,
  UP_NOVEL_VIEWPORT_INSET,
  upNovelCreateBookmark,
  upNovelExcerpt,
  upNovelLineHeight,
  upNovelMergeSettings,
  upNovelMode,
  upNovelNormalizeContent,
  upNovelNormalizePersisted,
  upNovelNormalizeProgress,
  upNovelPaginate,
  upNovelProgressLabel,
  upNovelProgressPercent,
  upNovelResolveAnchor,
  upNovelResolveContentWidth,
  upNovelTapZone,
  upNovelTheme,
  upNovelThemeLabel,
  upNovelThemeSupported,
  upNovelToggleBookmark
} from '../internal/UPNovelLayout';
import { UPNovelReaderCommand, UPNovelReaderController } from '../controllers/UPNovelReaderController';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPSlider, UPSliderChangeEvent, UPSliderProps } from './UPSlider';
import { UPSlotRegion } from '../internal/UPSlotRegion';

/** 上游 error 对象的具名模型。/ Named model of the upstream error object. */
export interface UPNovelReaderError {
  message?: string;
  code?: UPRawValue;
}

/** 上游 layout-ready 事件。/ Upstream layout-ready payload. */
export interface UPNovelLayoutEvent {
  mode: string;
  width: number;
  height: number;
  pageCount: number;
}

/** 上游 toolbar-change 事件。/ Upstream toolbar-change payload. */
export interface UPNovelToolbarEvent {
  visible: boolean;
  reason: string;
}

/** 上游 reading-time-change 事件。/ Upstream reading-time-change payload. */
export interface UPNovelReadingTimeEvent {
  readingTime: number;
  delta: number;
  updatedAt: number;
}

export interface UPNovelReaderOptions {
  chapters?: Array<UPNovelChapter>;
  currentChapter?: UPNovelChapter;
  loading?: UPRawValue;
  error?: UPNovelReaderError;
  bookId?: UPRawValue;
  storageKey?: UPRawValue;
  persist?: UPRawValue;
  initialProgress?: UPNovelProgressPatch;
  progress?: UPNovelProgressPatch;
  initialBookmarks?: Array<UPNovelBookmark>;
  bookmarks?: Array<UPNovelBookmark>;
  defaultSettings?: UPNovelSettingsPatch;
  settings?: UPNovelSettingsPatch;
  mode?: UPRawValue;
  showBack?: UPRawValue;
  autoBack?: UPRawValue;
  backIcon?: UPRawValue;
  safeAreaInsetTop?: UPRawValue;
  safeAreaInsetBottom?: UPRawValue;
  preloadThreshold?: UPRawValue;
  pageAnimation?: UPRawValue;
  controlsAutoHide?: UPRawValue;
  viewportWidth?: UPRawValue;
  viewportHeight?: UPRawValue;
  customStyle?: UPStyleInput;
  storage?: UPNovelStorage;
  diagnostics?: UPCompatibilityDiagnostics;
  controller?: UPNovelReaderController;
  onChapterRequest?: (event: UPNovelChapterRequest) => void;
  onChapterPrefetch?: (event: UPNovelChapterRequest) => void;
  onProgressChange?: (progress: UPNovelProgress) => void;
  onSettingsChange?: (settings: UPNovelSettings) => void;
  onBookmarkChange?: (bookmarks: Array<UPNovelBookmark>) => void;
  onReadingTimeChange?: (event: UPNovelReadingTimeEvent) => void;
  onModeChange?: (mode: string) => void;
  onToolbarChange?: (event: UPNovelToolbarEvent) => void;
  onLayoutReady?: (event: UPNovelLayoutEvent) => void;
  onBack?: () => void;
  onRetry?: () => void;
  loadingBuilder?: UPBuilder;
  errorBuilder?: UPBuilder;
  emptyBuilder?: UPBuilder;
  topBuilder?: UPBuilder;
  toolbarExtraBuilder?: UPBuilder;
  bottomBuilder?: UPBuilder;
  catalogBuilder?: UPBuilder;
  settingsBuilder?: UPBuilder;
}

export class UPNovelReaderProps {
  chapters: Array<UPNovelChapter> = [];
  currentChapter?: UPNovelChapter;
  loading: UPRawValue = false;
  error?: UPNovelReaderError;
  bookId: UPRawValue = '';
  storageKey: UPRawValue = '';
  persist: UPRawValue = true;
  initialProgress?: UPNovelProgressPatch;
  progress?: UPNovelProgressPatch;
  initialBookmarks: Array<UPNovelBookmark> = [];
  bookmarks?: Array<UPNovelBookmark>;
  defaultSettings?: UPNovelSettingsPatch;
  settings?: UPNovelSettingsPatch;
  mode: UPRawValue = 'scroll';
  showBack: UPRawValue = true;
  autoBack: UPRawValue = false;
  backIcon: UPRawValue = 'arrow-left';
  safeAreaInsetTop: UPRawValue = true;
  safeAreaInsetBottom: UPRawValue = true;
  preloadThreshold: UPRawValue = 2;
  pageAnimation: UPRawValue = true;
  controlsAutoHide: UPRawValue = 0;
  viewportWidth: UPRawValue = 375;
  viewportHeight: UPRawValue = 600;
  customStyle: UPStyleInput = undefined;
  storage?: UPNovelStorage;
  diagnostics?: UPCompatibilityDiagnostics;
  controller?: UPNovelReaderController;
  onChapterRequest?: (event: UPNovelChapterRequest) => void;
  onChapterPrefetch?: (event: UPNovelChapterRequest) => void;
  onProgressChange?: (progress: UPNovelProgress) => void;
  onSettingsChange?: (settings: UPNovelSettings) => void;
  onBookmarkChange?: (bookmarks: Array<UPNovelBookmark>) => void;
  onReadingTimeChange?: (event: UPNovelReadingTimeEvent) => void;
  onModeChange?: (mode: string) => void;
  onToolbarChange?: (event: UPNovelToolbarEvent) => void;
  onLayoutReady?: (event: UPNovelLayoutEvent) => void;
  onBack?: () => void;
  onRetry?: () => void;
  loadingBuilder?: UPBuilder;
  errorBuilder?: UPBuilder;
  emptyBuilder?: UPBuilder;
  topBuilder?: UPBuilder;
  toolbarExtraBuilder?: UPBuilder;
  bottomBuilder?: UPBuilder;
  catalogBuilder?: UPBuilder;
  settingsBuilder?: UPBuilder;

  constructor(options?: UPNovelReaderOptions) {
    if (options === undefined) {
      return;
    }
    this.chapters = options.chapters ?? this.chapters;
    this.currentChapter = options.currentChapter;
    this.loading = options.loading ?? this.loading;
    this.error = options.error;
    this.bookId = options.bookId ?? this.bookId;
    this.storageKey = options.storageKey ?? this.storageKey;
    this.persist = options.persist ?? this.persist;
    this.initialProgress = options.initialProgress;
    this.progress = options.progress;
    this.initialBookmarks = options.initialBookmarks ?? this.initialBookmarks;
    this.bookmarks = options.bookmarks;
    this.defaultSettings = options.defaultSettings;
    this.settings = options.settings;
    this.mode = options.mode ?? this.mode;
    this.showBack = options.showBack ?? this.showBack;
    this.autoBack = options.autoBack ?? this.autoBack;
    this.backIcon = options.backIcon ?? this.backIcon;
    this.safeAreaInsetTop = options.safeAreaInsetTop ?? this.safeAreaInsetTop;
    this.safeAreaInsetBottom = options.safeAreaInsetBottom ?? this.safeAreaInsetBottom;
    this.preloadThreshold = options.preloadThreshold ?? this.preloadThreshold;
    this.pageAnimation = options.pageAnimation ?? this.pageAnimation;
    this.controlsAutoHide = options.controlsAutoHide ?? this.controlsAutoHide;
    this.viewportWidth = options.viewportWidth ?? this.viewportWidth;
    this.viewportHeight = options.viewportHeight ?? this.viewportHeight;
    this.customStyle = options.customStyle;
    this.storage = options.storage;
    this.diagnostics = options.diagnostics;
    this.controller = options.controller;
    this.onChapterRequest = options.onChapterRequest;
    this.onChapterPrefetch = options.onChapterPrefetch;
    this.onProgressChange = options.onProgressChange;
    this.onSettingsChange = options.onSettingsChange;
    this.onBookmarkChange = options.onBookmarkChange;
    this.onReadingTimeChange = options.onReadingTimeChange;
    this.onModeChange = options.onModeChange;
    this.onToolbarChange = options.onToolbarChange;
    this.onLayoutReady = options.onLayoutReady;
    this.onBack = options.onBack;
    this.onRetry = options.onRetry;
    this.loadingBuilder = options.loadingBuilder;
    this.errorBuilder = options.errorBuilder;
    this.emptyBuilder = options.emptyBuilder;
    this.topBuilder = options.topBuilder;
    this.toolbarExtraBuilder = options.toolbarExtraBuilder;
    this.bottomBuilder = options.bottomBuilder;
    this.catalogBuilder = options.catalogBuilder;
    this.settingsBuilder = options.settingsBuilder;
  }
}

/**
 * u-novel-reader 的 HarmonyOS 原生实现：滚动与翻页双模式、五套主题、书签与进度持久化。
 * Native u-novel-reader with scroll and page modes, five themes, bookmarks and persisted progress.
 */
@Component
export struct UPNovelReader {
  @Prop @Watch('applyProps') props: UPNovelReaderProps = new UPNovelReaderProps();
  @State private controlsVisible: boolean = false;
  @State private catalogVisible: boolean = false;
  @State private settingsVisible: boolean = false;
  @State private pageIndex: number = 0;
  @State private scrollTop: number = 0;
  @State private localSettings: UPNovelSettings = new UPNovelSettings();
  @State private pageCount: number = 0;
  private content: UPNovelContent = new UPNovelContent();
  private pages: Array<UPNovelPage> = [];
  private localProgress: UPNovelProgress = new UPNovelProgress();
  private localBookmarks: Array<UPNovelBookmark> = [];
  private readingTime: number = 0;
  private readingActive: boolean = false;
  private readingLastActiveAt: number = 0;
  private applied: string = '';
  private pendingChapterId: string = '';
  private prefetched: Array<string> = [];
  private persistTimer: number = -1;
  private hideTimer: number = -1;
  private measuredWidth: number = 0;
  private measuredHeight: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.props.controller?.mount((command: UPNovelReaderCommand): void => this.execute(command));
    this.localSettings = this.resolveSettings();
    this.initializeState();
    this.applied = this.signature();
    this.refreshContent();
    this.reportBoundaries();
  }

  aboutToDisappear(): void {
    this.pauseReading();
    this.flushPersistence();
    this.clearHideTimer();
    this.props.controller?.unmount();
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.localSettings = this.resolveSettings();
    const chapterId: string = this.chapterId();
    if (this.pendingChapterId.length > 0 && chapterId === this.pendingChapterId) {
      this.pendingChapterId = '';
    }
    this.prefetched = [];
    this.refreshContent();
    this.reportBoundaries();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    const settings: UPNovelSettings = this.resolveSettings();
    return this.chapterId() + '|' + String(this.props.chapters.length) + '|' + this.modeName()
      + '|' + String(settings.fontSize) + '|' + String(settings.lineHeight)
      + '|' + String(settings.paragraphSpacing) + '|' + settings.contentWidth
      + '|' + settings.theme + '|' + String(settings.fontWeight)
      + '|' + String(upBoolean(this.props.loading, false)) + '|' + this.errorMessage();
  }

  private execute(command: UPNovelReaderCommand): void {
    if (command.action === 'movePage') {
      this.movePage(command.target);
      return;
    }
    if (command.action === 'requestChapter') {
      this.requestChapter(command.direction, command.target);
      return;
    }
    if (command.action === 'toggleControls') {
      this.toggleControls('controller');
      return;
    }
    if (command.action === 'toggleBookmark') {
      this.toggleBookmark();
      return;
    }
    if (command.action === 'updateSettings') {
      if (command.settings !== undefined) {
        this.updateSettings(command.settings);
      }
      return;
    }
    if (command.action === 'setMode') {
      this.diagnostics().report('UPNovelReader', 'mode', command.direction,
        'mode is a controlled prop, so the host must apply the new value through props');
      this.props.onModeChange?.(upNovelMode(command.direction));
      return;
    }
    this.retry();
  }

  private reportBoundaries(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    if (!UP_NOVEL_MODES.includes(upString(this.props.mode, 'scroll'))) {
      diagnostics.report('UPNovelReader', 'mode', this.props.mode,
        'mode falls back to scroll because only scroll and page are modelled');
    }
    if (!upNovelThemeSupported(this.resolveSettings().theme)) {
      diagnostics.report('UPNovelReader', 'theme', this.resolveSettings().theme,
        'theme falls back to day because only these themes are modelled: ' + UP_NOVEL_THEMES.join(', '));
    }
    if (upBoolean(this.props.persist, true) && this.props.storage === undefined && this.storageKeyValue().length > 0) {
      diagnostics.report('UPNovelReader', 'persist', this.props.persist,
        'uni storage is unavailable, so persistence requires a host storage adapter');
    }
    if (upBoolean(this.props.autoBack, false)) {
      diagnostics.report('UPNovelReader', 'autoBack', this.props.autoBack,
        'uni.navigateBack is unavailable, so autoBack only reports through onBack');
    }
    diagnostics.report('UPNovelReader', 'createSelectorQuery', '',
      'the viewport is measured with onAreaChange instead of a selector query');
    diagnostics.report('UPNovelReader', 'fontFamily', this.resolveSettings().fontFamily,
      'custom font families must be registered by the host application');
  }

  private modeName(): string {
    return upNovelMode(upString(this.props.mode, 'scroll'));
  }

  private pageMode(): boolean {
    return this.modeName() === 'page';
  }

  private resolveSettings(): UPNovelSettings {
    let settings: UPNovelSettings = upNovelMergeSettings(new UPNovelSettings(), this.props.defaultSettings);
    settings = upNovelMergeSettings(settings, this.storedSettings());
    return upNovelMergeSettings(settings, this.props.settings);
  }

  private storedSettings(): UPNovelSettingsPatch | undefined {
    const stored: UPNovelSettings | undefined = this.persistedSettings;
    if (stored === undefined) {
      return undefined;
    }
    return {
      theme: stored.theme,
      fontSize: stored.fontSize,
      lineHeight: stored.lineHeight,
      paragraphSpacing: stored.paragraphSpacing,
      contentWidth: stored.contentWidth,
      fontFamily: stored.fontFamily,
      fontWeight: stored.fontWeight,
      animation: stored.animation
    };
  }

  private persistedSettings?: UPNovelSettings = undefined;

  private themeTokens(): UPNovelTheme {
    return upNovelTheme(this.localSettings.theme);
  }

  private animationEnabled(): boolean {
    return upBoolean(this.props.pageAnimation, true) && this.localSettings.animation;
  }

  private chapterId(): string {
    const chapter: UPNovelChapter | undefined = this.props.currentChapter;
    return chapter === undefined ? '' : (chapter.id ?? '');
  }

  private chapterIndex(): number {
    const chapter: UPNovelChapter | undefined = this.props.currentChapter;
    if (chapter === undefined) {
      return -1;
    }
    const index: number = chapter.index ?? Number.NaN;
    if (Number.isFinite(index)) {
      return index;
    }
    for (let position: number = 0; position < this.props.chapters.length; position++) {
      if (this.props.chapters[position].id === chapter.id) {
        return position;
      }
    }
    return -1;
  }

  private chapterTitle(): string {
    const chapter: UPNovelChapter | undefined = this.props.currentChapter;
    const title: string = chapter === undefined ? '' : (chapter.title ?? '');
    return title.length > 0 ? title : UP_NOVEL_TITLE_FALLBACK;
  }

  private errorMessage(): string {
    const error: UPNovelReaderError | undefined = this.props.error;
    if (error === undefined) {
      return '';
    }
    const message: string = error.message ?? '';
    return message.length > 0 ? message : UP_NOVEL_ERROR_TEXT;
  }

  private storageKeyValue(): string {
    const explicit: string = upString(this.props.storageKey, '');
    if (explicit.length > 0) {
      return explicit;
    }
    const bookId: string = upString(this.props.bookId, '');
    return bookId.length === 0 ? '' : 'uview-plus:novel-reader:' + bookId;
  }

  /** 上游 initializeReaderState()。/ Mirrors upstream initializeReaderState(). */
  private initializeState(): void {
    const key: string = this.storageKeyValue();
    let restored: UPNovelPersistedState | undefined = undefined;
    if (upBoolean(this.props.persist, true) && key.length > 0 && this.props.storage !== undefined) {
      try {
        restored = upNovelNormalizePersisted(this.props.storage.get(key));
      } catch (_error) {
        restored = undefined;
      }
      if (restored === undefined) {
        try {
          this.props.storage.remove(key);
        } catch (_error) {
          restored = undefined;
        }
      }
    }
    this.persistedSettings = restored === undefined ? undefined : restored.settings;
    this.localSettings = this.resolveSettings();
    if (this.props.progress === undefined) {
      const patch: UPNovelProgressPatch | undefined = this.props.initialProgress
        ?? (restored === undefined ? undefined : this.progressPatch(restored.progress));
      this.localProgress = upNovelNormalizeProgress(patch, this.props.currentChapter, 0);
    }
    if (this.props.bookmarks === undefined) {
      this.localBookmarks = this.props.initialBookmarks.length > 0
        ? this.props.initialBookmarks.slice()
        : (restored === undefined ? [] : restored.bookmarks.slice());
    }
    this.readingTime = restored === undefined ? 0 : restored.readingTime;
  }

  private progressPatch(progress?: UPNovelProgress): UPNovelProgressPatch | undefined {
    if (progress === undefined) {
      return undefined;
    }
    return {
      chapterId: progress.chapterId,
      chapterIndex: progress.chapterIndex,
      pageIndex: progress.pageIndex,
      pageCount: progress.pageCount,
      charOffset: progress.charOffset,
      chapterProgress: progress.chapterProgress,
      totalProgress: progress.totalProgress,
      scrollTop: progress.scrollTop,
      updatedAt: progress.updatedAt
    };
  }

  private currentProgress(): UPNovelProgress {
    const source: UPNovelProgressPatch | undefined = this.props.progress
      ?? this.progressPatch(this.localProgress)
      ?? this.props.initialProgress;
    return upNovelNormalizeProgress(source, this.props.currentChapter, this.content.length);
  }

  private currentBookmarks(): Array<UPNovelBookmark> {
    return this.props.bookmarks ?? this.localBookmarks;
  }

  private bookmarked(): boolean {
    const chapterId: string = this.chapterId();
    const offset: number = this.currentProgress().charOffset;
    for (const bookmark of this.currentBookmarks()) {
      if (bookmark.chapterId === chapterId && bookmark.charOffset === offset) {
        return true;
      }
    }
    return false;
  }

  /** 上游 refreshContent()。/ Mirrors upstream refreshContent(). */
  private refreshContent(): void {
    const chapter: UPNovelChapter | undefined = this.props.currentChapter;
    this.content = upNovelNormalizeContent(chapter === undefined ? '' : (chapter.content ?? ''));
    const progress: UPNovelProgress = this.currentProgress();
    this.pageIndex = progress.pageIndex;
    this.scrollTop = progress.scrollTop;
    this.refreshLayout();
  }

  /** 上游 refreshLayout()。/ Mirrors upstream refreshLayout(). */
  private refreshLayout(): void {
    const width: number = this.viewportWidthValue();
    const height: number = this.viewportHeightValue();
    if (!this.pageMode()) {
      this.pages = [];
      this.pageCount = 0;
      this.props.onLayoutReady?.({ mode: this.modeName(), width: width, height: height, pageCount: 0 });
      return;
    }
    const options: UPNovelLayoutOptions = new UPNovelLayoutOptions();
    options.width = upNovelResolveContentWidth(width, this.localSettings.contentWidth);
    options.height = Math.max(1, height - UP_NOVEL_VIEWPORT_INSET);
    options.fontSize = this.localSettings.fontSize;
    options.lineHeight = this.localSettings.lineHeight;
    options.paragraphSpacing = this.localSettings.paragraphSpacing;
    const layout: UPNovelLayoutResult = upNovelPaginate(this.content.paragraphs, options);
    this.pages = layout.pages;
    this.pageCount = layout.pageCount;
    const anchor: UPNovelAnchor = upNovelResolveAnchor(layout.pages, this.currentProgress().charOffset);
    this.pageIndex = anchor.pageIndex;
    this.props.onLayoutReady?.({
      mode: this.modeName(),
      width: width,
      height: height,
      pageCount: layout.pageCount
    });
  }

  private viewportWidthValue(): number {
    if (this.measuredWidth > 0) {
      return this.measuredWidth;
    }
    const width: number = upNumber(this.props.viewportWidth, 375);
    return width > 0 ? width : 375;
  }

  private viewportHeightValue(): number {
    if (this.measuredHeight > 0) {
      return this.measuredHeight;
    }
    const height: number = upNumber(this.props.viewportHeight, 600);
    return height > 0 ? height : 600;
  }

  private captureViewport(width: number, height: number): void {
    const changedWidth: boolean = Math.abs(width - this.measuredWidth) >= 1;
    const changedHeight: boolean = Math.abs(height - this.measuredHeight) >= 1;
    if (!changedWidth && !changedHeight) {
      return;
    }
    this.measuredWidth = width;
    this.measuredHeight = height;
    this.refreshLayout();
  }

  /** 上游 activateReading()。/ Mirrors upstream activateReading(). */
  private activateReading(): void {
    if (upBoolean(this.props.loading, false) || this.errorMessage().length > 0) {
      return;
    }
    if (this.props.currentChapter === undefined || this.readingActive) {
      return;
    }
    this.readingActive = true;
    this.readingLastActiveAt = Date.now();
  }

  /** 上游 pauseReading()。/ Mirrors upstream pauseReading(). */
  private pauseReading(): void {
    if (!this.readingActive) {
      return;
    }
    const now: number = Date.now();
    const delta: number = Math.max(0, now - this.readingLastActiveAt);
    this.readingTime += delta;
    this.readingActive = false;
    this.readingLastActiveAt = 0;
    this.props.onReadingTimeChange?.({ readingTime: this.readingTime, delta: delta, updatedAt: now });
    this.queuePersist();
  }

  /** 上游 toggleControls()。/ Mirrors upstream toggleControls(). */
  private toggleControls(reason: string): void {
    this.controlsVisible = !this.controlsVisible;
    this.props.onToolbarChange?.({ visible: this.controlsVisible, reason: reason });
    if (this.controlsVisible) {
      this.scheduleHide();
      return;
    }
    this.clearHideTimer();
  }

  /** 上游 hideControls()。/ Mirrors upstream hideControls(). */
  private hideControls(): void {
    if (!this.controlsVisible) {
      return;
    }
    this.controlsVisible = false;
    this.clearHideTimer();
    this.props.onToolbarChange?.({ visible: false, reason: 'toolbar-action' });
  }

  /** 上游 scheduleControlsHide()。/ Mirrors upstream scheduleControlsHide(). */
  private scheduleHide(): void {
    this.clearHideTimer();
    const delay: number = Math.max(0, upNumber(this.props.controlsAutoHide, 0));
    if (delay <= 0) {
      return;
    }
    this.hideTimer = setTimeout((): void => {
      this.hideControls();
    }, delay);
  }

  private clearHideTimer(): void {
    if (this.hideTimer !== -1) {
      clearTimeout(this.hideTimer);
      this.hideTimer = -1;
    }
  }

  /** 上游 handleTapZone()。/ Mirrors upstream handleTapZone(). */
  private handleTap(x: number): void {
    this.activateReading();
    const zone: string = upNovelTapZone(x, this.viewportWidthValue());
    if (zone === 'center') {
      this.toggleControls('tap-center');
      return;
    }
    if (!this.pageMode()) {
      return;
    }
    this.movePage(zone === 'left' ? -1 : 1);
  }

  /** 上游 movePage()。/ Mirrors upstream movePage(). */
  private movePage(offset: number): void {
    const next: number = this.pageIndex + offset;
    if (next >= 0 && next < this.pageCount) {
      this.pageIndex = next;
      this.emitProgress(this.pages[next].startOffset, next);
      return;
    }
    this.requestChapter(offset < 0 ? 'previous' : 'next', -1);
  }

  /** 上游 handlePageChange()。/ Mirrors upstream handlePageChange(). */
  private handlePageChange(index: number): void {
    this.activateReading();
    this.pageIndex = Math.max(0, index);
    const offset: number = this.pageIndex < this.pages.length ? this.pages[this.pageIndex].startOffset : 0;
    this.emitProgress(offset, this.pageIndex);
  }

  /** 上游 handleContentScroll()。/ Mirrors upstream handleContentScroll(). */
  private handleScroll(): void {
    this.activateReading();
    this.scrollTop = Math.max(0, this.scroller.currentOffset().yOffset);
    this.emitProgress(-1, this.pageIndex);
  }

  /** 上游 emitProgress()。/ Mirrors upstream emitProgress(). */
  private emitProgress(charOffset: number, pageIndex: number): void {
    const progress: UPNovelProgress = new UPNovelProgress();
    progress.chapterId = this.chapterId();
    progress.chapterIndex = this.chapterIndex();
    progress.pageIndex = pageIndex;
    progress.pageCount = this.pageCount;
    const scrollProgress: number = this.scrollProgress();
    const chapterProgress: number = this.pageCount > 0
      ? (pageIndex + 1) / this.pageCount
      : scrollProgress;
    progress.charOffset = charOffset >= 0
      ? charOffset
      : Math.round(this.content.length * scrollProgress);
    progress.chapterProgress = Math.min(1, Math.max(0, chapterProgress));
    progress.totalProgress = this.props.chapters.length > 0
      ? Math.min(1, Math.max(0, (this.chapterIndex() + chapterProgress) / this.props.chapters.length))
      : 0;
    progress.scrollTop = this.scrollTop;
    progress.updatedAt = Date.now();
    if (this.props.progress === undefined) {
      this.localProgress = progress;
    }
    this.props.onProgressChange?.(progress);
    this.props.controller?.updateSnapshot(progress, this.currentBookmarks(), this.readingTime);
    this.queuePersist();
    this.prefetchIfNeeded();
  }

  private scrollProgress(): number {
    const height: number = this.viewportHeightValue();
    const contentHeight: number = this.estimatedContentHeight();
    if (contentHeight <= height) {
      return 0;
    }
    return Math.min(1, Math.max(0, this.scrollTop / Math.max(1, contentHeight - height)));
  }

  private estimatedContentHeight(): number {
    const lineHeight: number = upNovelLineHeight(this.localSettings.fontSize, this.localSettings.lineHeight);
    const width: number = upNovelResolveContentWidth(this.viewportWidthValue(), this.localSettings.contentWidth);
    let height: number = UP_NOVEL_ARTICLE_PADDING * 2;
    for (const paragraph of this.content.paragraphs) {
      const estimated: number = Math.max(1, Math.ceil(paragraph.text.length
        * this.localSettings.fontSize * 0.6 / Math.max(1, width)));
      height += estimated * lineHeight + this.localSettings.paragraphSpacing;
    }
    return height;
  }

  /** 上游 emitPrefetchIfNeeded()。/ Mirrors upstream emitPrefetchIfNeeded(). */
  private prefetchIfNeeded(): void {
    if (!this.pageMode() || this.pageCount === 0) {
      return;
    }
    const threshold: number = Math.max(0, upNumber(this.props.preloadThreshold, 2));
    if (this.pageCount - this.pageIndex > threshold) {
      return;
    }
    const target: UPNovelChapter | undefined = this.nextChapter();
    if (target === undefined) {
      return;
    }
    const targetId: string = target.id ?? '';
    if (this.prefetched.includes(targetId)) {
      return;
    }
    this.prefetched.push(targetId);
    this.props.onChapterPrefetch?.({
      targetIndex: target.index ?? 0,
      targetId: targetId,
      direction: 'next',
      requestId: String(Date.now())
    });
  }

  private nextChapter(): UPNovelChapter | undefined {
    const current: number = this.chapterIndex();
    for (const chapter of this.props.chapters) {
      const index: number = chapter.index ?? -1;
      if (index > current && chapter.isLocked !== true) {
        return chapter;
      }
    }
    return undefined;
  }

  private previousAvailable(): boolean {
    const current: number = this.chapterIndex();
    for (const chapter of this.props.chapters) {
      const index: number = chapter.index ?? -1;
      if (index < current && chapter.isLocked !== true) {
        return true;
      }
    }
    return false;
  }

  private nextAvailable(): boolean {
    return this.nextChapter() !== undefined;
  }

  private resolveChapter(index: number): UPNovelChapter | undefined {
    for (const chapter of this.props.chapters) {
      if ((chapter.index ?? -1) === index) {
        return chapter;
      }
    }
    return index >= 0 && index < this.props.chapters.length ? this.props.chapters[index] : undefined;
  }

  /** 上游 requestChapter()。/ Mirrors upstream requestChapter(). */
  private requestChapter(direction: string, targetIndex: number): void {
    if (upBoolean(this.props.loading, false) || this.pendingChapterId.length > 0) {
      return;
    }
    const current: number = this.chapterIndex();
    const nextIndex: number = targetIndex >= 0
      ? targetIndex
      : current + (direction === 'previous' ? -1 : 1);
    const target: UPNovelChapter | undefined = this.resolveChapter(nextIndex);
    if (target === undefined || target.isLocked === true) {
      return;
    }
    this.pendingChapterId = target.id ?? '';
    this.flushPersistence();
    this.props.onChapterRequest?.({
      targetIndex: nextIndex,
      targetId: this.pendingChapterId,
      direction: direction,
      requestId: String(Date.now())
    });
  }

  /** 上游 handleRetry()。/ Mirrors upstream handleRetry(). */
  private retry(): void {
    this.pendingChapterId = '';
    this.props.onRetry?.();
  }

  /** 上游 toggleBookmark()。/ Mirrors upstream toggleBookmark(). */
  private toggleBookmark(): void {
    const chapterId: string = this.chapterId();
    if (chapterId.length === 0) {
      return;
    }
    const progress: UPNovelProgress = this.currentProgress();
    const bookmark: UPNovelBookmark = upNovelCreateBookmark(chapterId, this.chapterIndex(),
      progress.charOffset, this.pageIndex, this.scrollTop,
      upNovelExcerpt(this.content.text, progress.charOffset), Date.now());
    const list: Array<UPNovelBookmark> = upNovelToggleBookmark(this.currentBookmarks(), bookmark);
    if (this.props.bookmarks === undefined) {
      this.localBookmarks = list;
    }
    this.props.onBookmarkChange?.(list);
    this.props.controller?.updateSnapshot(progress, list, this.readingTime);
    this.queuePersist();
  }

  /** 上游 handleSettingsUpdate()。/ Mirrors upstream handleSettingsUpdate(). */
  private updateSettings(patch: UPNovelSettingsPatch): void {
    this.localSettings = upNovelMergeSettings(this.localSettings, patch);
    this.props.onSettingsChange?.(this.localSettings);
    this.queuePersist();
    this.refreshLayout();
  }

  /** 上游 handleChapterSelect()。/ Mirrors upstream handleChapterSelect(). */
  private selectChapter(chapter: UPNovelChapter): void {
    if (chapter.isLocked === true) {
      return;
    }
    this.catalogVisible = false;
    this.requestChapter('catalog', chapter.index ?? -1);
  }

  /** 上游 handleBookmarkSelect()。/ Mirrors upstream handleBookmarkSelect(). */
  private selectBookmark(bookmark: UPNovelBookmark): void {
    this.catalogVisible = false;
    if (bookmark.chapterId === this.chapterId()) {
      this.pageIndex = bookmark.pageIndex;
      this.scrollTop = bookmark.scrollTop;
      this.emitProgress(bookmark.charOffset, bookmark.pageIndex);
      return;
    }
    this.requestChapter('catalog', bookmark.chapterIndex);
  }

  /** 上游 queuePersist()。/ Mirrors upstream queuePersist(). */
  private queuePersist(): void {
    if (!upBoolean(this.props.persist, true) || this.storageKeyValue().length === 0) {
      return;
    }
    if (this.persistTimer !== -1) {
      return;
    }
    this.persistTimer = setTimeout((): void => {
      this.persistTimer = -1;
      this.flushPersistence();
    }, UP_NOVEL_PERSIST_DELAY);
  }

  /** 上游 flushPersistence()。/ Mirrors upstream flushPersistence(). */
  private flushPersistence(): void {
    if (this.persistTimer !== -1) {
      clearTimeout(this.persistTimer);
      this.persistTimer = -1;
    }
    const key: string = this.storageKeyValue();
    if (!upBoolean(this.props.persist, true) || key.length === 0 || this.props.storage === undefined) {
      return;
    }
    const state: UPNovelPersistedState = new UPNovelPersistedState();
    state.version = UP_NOVEL_STORAGE_VERSION;
    state.progress = this.currentProgress();
    state.settings = this.localSettings.clone();
    state.bookmarks = this.currentBookmarks().slice();
    state.readingTime = this.readingTime;
    state.updatedAt = Date.now();
    try {
      this.props.storage.set(key, state);
    } catch (_error) {
      this.diagnostics().report('UPNovelReader', 'storage', key,
        'the host storage adapter rejected the write, so the snapshot is dropped');
    }
  }

  private paragraphIndexes(): Array<number> {
    const indexes: Array<number> = [];
    for (let index: number = 0; index < this.content.paragraphs.length; index++) {
      indexes.push(index);
    }
    return indexes;
  }

  private pageIndexes(): Array<number> {
    const indexes: Array<number> = [];
    for (let index: number = 0; index < this.pages.length; index++) {
      indexes.push(index);
    }
    return indexes;
  }

  private chapterIndexes(): Array<number> {
    const indexes: Array<number> = [];
    for (let index: number = 0; index < this.props.chapters.length; index++) {
      indexes.push(index);
    }
    return indexes;
  }

  private bookmarkIndexes(): Array<number> {
    const indexes: Array<number> = [];
    const list: Array<UPNovelBookmark> = this.currentBookmarks();
    for (let index: number = 0; index < list.length; index++) {
      indexes.push(index);
    }
    return indexes;
  }

  private contentWidthValue(): number {
    return upNovelResolveContentWidth(this.viewportWidthValue(), this.localSettings.contentWidth);
  }

  private fontWeightValue(): FontWeight {
    return this.localSettings.fontWeight >= UP_NOVEL_BOLD_WEIGHT ? FontWeight.Bold : FontWeight.Normal;
  }

  private lineHeightValue(): number {
    return upNovelLineHeight(this.localSettings.fontSize, this.localSettings.lineHeight);
  }

  private displayIndex(chapter: UPNovelChapter): string {
    const index: number = chapter.index ?? Number.NaN;
    return Number.isFinite(index) ? String(index + 1) : '';
  }

  private chapterLabel(chapter: UPNovelChapter): string {
    const title: string = chapter.title ?? '';
    return title.length > 0 ? title : '第' + this.displayIndex(chapter) + '章';
  }

  @Builder
  private stateBlock(text: string, retry: boolean) {
    Column({ space: 16 }) {
      Text(text)
        .fontSize(14)
        .fontColor(this.themeTokens().muted)
      if (retry) {
        Text(UP_NOVEL_RETRY_TEXT)
          .fontSize(14)
          .fontColor(this.themeTokens().active)
          .padding({ top: 8, right: 18, bottom: 8, left: 18 })
          .onClick((): void => this.retry())
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private scrollBody() {
    Scroll(this.scroller) {
      Column() {
        ForEach(this.paragraphIndexes(), (index: number) => {
          Text(this.content.paragraphs[index].text)
            .fontSize(this.localSettings.fontSize)
            .fontColor(this.themeTokens().text)
            .fontWeight(this.fontWeightValue())
            .lineHeight(this.lineHeightValue())
            .width('100%')
            .margin({ bottom: this.localSettings.paragraphSpacing })
        }, (index: number): string => 'paragraph-' + String(index))
      }
      .width(this.contentWidthValue())
      .padding({ top: UP_NOVEL_ARTICLE_PADDING, bottom: UP_NOVEL_ARTICLE_PADDING })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .onDidScroll((_xOffset: number, _yOffset: number, _state: ScrollState): void => {
      this.handleScroll();
    })
  }

  @Builder
  private pageBody() {
    Swiper() {
      ForEach(this.pageIndexes(), (index: number) => {
        Column() {
          Text(this.pages[index].text)
            .fontSize(this.localSettings.fontSize)
            .fontColor(this.themeTokens().text)
            .fontWeight(this.fontWeightValue())
            .lineHeight(this.lineHeightValue())
            .width('100%')
        }
        .width(this.contentWidthValue())
        .padding({ top: UP_NOVEL_ARTICLE_PADDING, bottom: UP_NOVEL_ARTICLE_PADDING })
        .alignItems(HorizontalAlign.Start)
      }, (index: number): string => 'page-' + String(index))
    }
    .width('100%')
    .height('100%')
    .index(this.pageIndex)
    .autoPlay(false)
    .loop(false)
    .indicator(false)
    .duration(this.animationEnabled() ? 300 : 0)
    .onChange((index: number): void => this.handlePageChange(index))
  }

  @Builder
  private readerBody() {
    Column() {
      if (upBoolean(this.props.loading, false) && this.props.loadingBuilder !== undefined) {
        this.loadingRegion()
      } else if (upBoolean(this.props.loading, false)) {
        this.stateBlock(UP_NOVEL_LOADING_TEXT, false)
      } else if (this.errorMessage().length > 0 && this.props.errorBuilder !== undefined) {
        this.errorRegion()
      } else if (this.errorMessage().length > 0) {
        this.stateBlock(this.errorMessage(), true)
      } else if (this.content.paragraphs.length === 0 && this.props.emptyBuilder !== undefined) {
        this.emptyRegion()
      } else if (this.content.paragraphs.length === 0) {
        this.stateBlock(UP_NOVEL_EMPTY_TEXT, false)
      } else if (this.pageMode()) {
        this.pageBody()
      } else {
        this.scrollBody()
      }
    }
    .width('100%')
    .height('100%')
    .onClick((event: ClickEvent): void => this.handleTap(event.x))
  }

  @Builder
  private topToolbar() {
    Row() {
      Row({ space: 8 }) {
        if (upBoolean(this.props.showBack, true)) {
          UPIcon({
            props: new UPIconProps({
              name: upString(this.props.backIcon, 'arrow-left'),
              size: 21,
              color: this.themeTokens().text,
              onClick: (): void => {
                this.props.onBack?.();
              }
            })
          })
        }
        Text(this.chapterTitle())
          .fontSize(15)
          .fontColor(this.themeTokens().text)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      Row({ space: 14 }) {
        this.topRegion()
        UPIcon({
          props: new UPIconProps({
            name: 'list',
            size: 20,
            color: this.themeTokens().text,
            onClick: (): void => {
              this.catalogVisible = true;
            }
          })
        })
        UPIcon({
          props: new UPIconProps({
            name: 'bookmark',
            size: 20,
            color: this.bookmarked() ? this.themeTokens().active : this.themeTokens().text,
            bold: this.bookmarked(),
            onClick: (): void => this.toggleBookmark()
          })
        })
        this.toolbarExtraRegion()
        UPIcon({
          props: new UPIconProps({
            name: 'close',
            size: 19,
            color: this.themeTokens().text,
            onClick: (): void => this.hideControls()
          })
        })
      }
    }
    .width('100%')
    .padding({ top: upBoolean(this.props.safeAreaInsetTop, true) ? 24 : 10, right: 14, bottom: 10, left: 14 })
    .backgroundColor(this.themeTokens().toolbar)
    .border({ width: { bottom: 1 }, color: this.themeTokens().border })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private bottomToolbar() {
    Row() {
      Column({ space: 6 }) {
        Text(upNovelProgressLabel(this.chapterIndex(), this.props.chapters.length,
          upNovelProgressPercent(this.currentProgress().chapterProgress, this.pageIndex, this.pageCount)))
          .fontSize(12)
          .fontColor(this.themeTokens().muted)
        Row() {
          Row()
            .width(String(Math.round(upNovelProgressPercent(this.currentProgress().chapterProgress,
              this.pageIndex, this.pageCount))) + '%')
            .height(3)
            .backgroundColor(this.themeTokens().active)
            .borderRadius(2)
        }
        .width('100%')
        .height(3)
        .backgroundColor(this.themeTokens().border)
        .borderRadius(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Row({ space: 14 }) {
        this.bottomRegion()
        UPIcon({
          props: new UPIconProps({
            name: 'arrow-left',
            size: 18,
            color: this.previousAvailable() ? this.themeTokens().text : this.themeTokens().disabled,
            onClick: (): void => {
              if (this.previousAvailable()) {
                this.requestChapter('previous', -1);
              }
            }
          })
        })
        UPIcon({
          props: new UPIconProps({
            name: 'arrow-right',
            size: 18,
            color: this.nextAvailable() ? this.themeTokens().text : this.themeTokens().disabled,
            onClick: (): void => {
              if (this.nextAvailable()) {
                this.requestChapter('next', -1);
              }
            }
          })
        })
        UPIcon({
          props: new UPIconProps({
            name: 'setting',
            size: 20,
            color: this.themeTokens().text,
            onClick: (): void => {
              this.settingsVisible = true;
            }
          })
        })
      }
    }
    .width('100%')
    .padding({ top: 8, right: 14, bottom: upBoolean(this.props.safeAreaInsetBottom, true) ? 24 : 8, left: 14 })
    .backgroundColor(this.themeTokens().toolbar)
    .border({ width: { top: 1 }, color: this.themeTokens().border })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private catalogPanel() {
    Column() {
      Row() {
        Text(UP_NOVEL_CATALOG_TITLE)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeTokens().text)
          .layoutWeight(1)
        Text(String(this.props.chapters.length) + ' 章')
          .fontSize(12)
          .fontColor(this.themeTokens().muted)
      }
      .width('100%')
      .padding({ top: 20, right: 18, bottom: 14, left: 18 })
      .border({ width: { bottom: 1 }, color: this.themeTokens().border })
      if (this.props.catalogBuilder !== undefined) {
        this.catalogRegion()
      } else {
        Scroll() {
          Column() {
            if (this.props.chapters.length === 0) {
              Text(UP_NOVEL_CATALOG_EMPTY)
                .fontSize(13)
                .fontColor(this.themeTokens().muted)
                .padding(18)
            }
            ForEach(this.chapterIndexes(), (index: number) => {
              Row({ space: 10 }) {
                if (this.props.chapters[index].isLocked === true) {
                  UPIcon({ props: new UPIconProps({ name: 'lock', size: 14, color: this.themeTokens().muted }) })
                } else {
                  Text(this.displayIndex(this.props.chapters[index]))
                    .fontSize(12)
                    .fontColor(this.themeTokens().muted)
                    .width(28)
                }
                Text(this.chapterLabel(this.props.chapters[index]))
                  .fontSize(14)
                  .fontColor(this.props.chapters[index].isLocked === true
                    ? this.themeTokens().disabled
                    : this.themeTokens().text)
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                if (this.props.chapters[index].id === this.chapterId()) {
                  UPIcon({ props: new UPIconProps({ name: 'checkmark', size: 16, color: this.themeTokens().active }) })
                }
              }
              .width('100%')
              .padding({ top: 12, right: 18, bottom: 12, left: 18 })
              .alignItems(VerticalAlign.Center)
              .onClick((): void => this.selectChapter(this.props.chapters[index]))
            }, (index: number): string => 'chapter-' + String(index))
            if (this.currentBookmarks().length > 0) {
              Row({ space: 6 }) {
                UPIcon({ props: new UPIconProps({ name: 'bookmark', size: 15, color: this.themeTokens().active }) })
                Text(UP_NOVEL_BOOKMARK_TITLE)
                  .fontSize(13)
                  .fontColor(this.themeTokens().text)
              }
              .width('100%')
              .padding({ top: 16, right: 18, bottom: 8, left: 18 })
              ForEach(this.bookmarkIndexes(), (index: number) => {
                Row() {
                  Text(this.currentBookmarks()[index].excerpt.length > 0
                    ? this.currentBookmarks()[index].excerpt
                    : UP_NOVEL_BOOKMARK_FALLBACK)
                    .fontSize(13)
                    .fontColor(this.themeTokens().text)
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(String(this.currentBookmarks()[index].chapterIndex + 1) + ' 章')
                    .fontSize(12)
                    .fontColor(this.themeTokens().muted)
                }
                .width('100%')
                .padding({ top: 10, right: 18, bottom: 10, left: 18 })
                .onClick((): void => this.selectBookmark(this.currentBookmarks()[index]))
              }, (index: number): string => 'bookmark-' + String(index))
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('82%')
    .height('100%')
    .backgroundColor(this.themeTokens().background)
  }

  @Builder
  private settingsPanel() {
    Column({ space: 14 }) {
      Row() {
        Text(UP_NOVEL_SETTINGS_TITLE)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeTokens().text)
          .layoutWeight(1)
        UPIcon({
          props: new UPIconProps({
            name: 'close',
            size: 18,
            color: this.themeTokens().text,
            onClick: (): void => {
              this.settingsVisible = false;
            }
          })
        })
      }
      .width('100%')
      if (this.props.settingsBuilder !== undefined) {
        this.settingsRegion()
      } else {
        Row({ space: 8 }) {
          ForEach(UP_NOVEL_THEMES, (theme: string) => {
            Text(upNovelThemeLabel(theme))
              .fontSize(13)
              .fontColor(upNovelTheme(theme).text)
              .padding({ top: 8, right: 12, bottom: 8, left: 12 })
              .backgroundColor(upNovelTheme(theme).background)
              .borderRadius(6)
              .borderWidth(this.localSettings.theme === theme ? 2 : 1)
              .borderColor(this.localSettings.theme === theme
                ? this.themeTokens().active
                : this.themeTokens().border)
              .onClick((): void => this.updateSettings({ theme: theme }))
          }, (theme: string): string => theme)
        }
        .width('100%')
        this.settingRow('字号', String(this.localSettings.fontSize) + 'px')
        UPSlider({
          props: new UPSliderProps({
            value: this.localSettings.fontSize,
            min: UP_NOVEL_SETTING_FONT_MIN,
            max: UP_NOVEL_SETTING_FONT_MAX,
            step: 1,
            activeColor: this.themeTokens().active,
            onChange: (event: UPSliderChangeEvent): void => this.updateSettings({ fontSize: event.value })
          })
        })
        this.settingRow('行高', this.localSettings.lineHeight.toFixed(1))
        UPSlider({
          props: new UPSliderProps({
            value: this.localSettings.lineHeight,
            min: UP_NOVEL_SETTING_LINE_MIN,
            max: UP_NOVEL_SETTING_LINE_MAX,
            step: 0.1,
            activeColor: this.themeTokens().active,
            onChange: (event: UPSliderChangeEvent): void => this.updateSettings({ lineHeight: event.value })
          })
        })
        this.settingRow('段距', String(this.localSettings.paragraphSpacing) + 'px')
        UPSlider({
          props: new UPSliderProps({
            value: this.localSettings.paragraphSpacing,
            min: 0,
            max: UP_NOVEL_SETTING_SPACING_MAX,
            step: 2,
            activeColor: this.themeTokens().active,
            onChange: (event: UPSliderChangeEvent): void => this.updateSettings({ paragraphSpacing: event.value })
          })
        })
        this.settingRow('正文宽度', this.localSettings.contentWidth)
        UPSlider({
          props: new UPSliderProps({
            value: parseFloat(this.localSettings.contentWidth),
            min: UP_NOVEL_SETTING_WIDTH_MIN,
            max: 100,
            step: 2,
            activeColor: this.themeTokens().active,
            onChange: (event: UPSliderChangeEvent): void => {
              this.updateSettings({ contentWidth: String(event.value) + '%' });
            }
          })
        })
        Row() {
          Column({ space: 2 }) {
            Text('粗体正文').fontSize(14).fontColor(this.themeTokens().text)
            Text('增强低亮度主题下的可读性').fontSize(12).fontColor(this.themeTokens().muted)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          UPIcon({
            props: new UPIconProps({
              name: this.localSettings.fontWeight >= UP_NOVEL_BOLD_WEIGHT ? 'checkmark-circle-fill' : 'checkmark-circle',
              size: 22,
              color: this.localSettings.fontWeight >= UP_NOVEL_BOLD_WEIGHT
                ? this.themeTokens().active
                : this.themeTokens().muted,
              onClick: (): void => {
                this.updateSettings({
                  fontWeight: this.localSettings.fontWeight >= UP_NOVEL_BOLD_WEIGHT ? 400 : UP_NOVEL_BOLD_WEIGHT
                });
              }
            })
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        Row() {
          Column({ space: 2 }) {
            Text('翻页动画').fontSize(14).fontColor(this.themeTokens().text)
            Text('关闭后立即切换页面').fontSize(12).fontColor(this.themeTokens().muted)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          UPIcon({
            props: new UPIconProps({
              name: this.localSettings.animation ? 'checkmark-circle-fill' : 'checkmark-circle',
              size: 22,
              color: this.localSettings.animation ? this.themeTokens().active : this.themeTokens().muted,
              onClick: (): void => this.updateSettings({ animation: !this.localSettings.animation })
            })
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(this.themeTokens().background)
    .borderRadius({ topLeft: 18, topRight: 18 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private settingRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor(this.themeTokens().text).layoutWeight(1)
      Text(value).fontSize(13).fontColor(this.themeTokens().muted)
    }
    .width('100%')
  }

  @Builder
  private loadingRegion() {
    UPSlotRegion({ contentBuilder: this.props.loadingBuilder })
  }

  @Builder
  private errorRegion() {
    UPSlotRegion({ contentBuilder: this.props.errorBuilder })
  }

  @Builder
  private emptyRegion() {
    UPSlotRegion({ contentBuilder: this.props.emptyBuilder })
  }

  @Builder
  private topRegion() {
    UPSlotRegion({ contentBuilder: this.props.topBuilder })
  }

  @Builder
  private toolbarExtraRegion() {
    UPSlotRegion({ contentBuilder: this.props.toolbarExtraBuilder })
  }

  @Builder
  private bottomRegion() {
    UPSlotRegion({ contentBuilder: this.props.bottomBuilder })
  }

  @Builder
  private catalogRegion() {
    UPSlotRegion({ contentBuilder: this.props.catalogBuilder })
  }

  @Builder
  private settingsRegion() {
    UPSlotRegion({ contentBuilder: this.props.settingsBuilder })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        this.readerBody()
      }
      .width('100%')
      .height('100%')
      if (this.controlsVisible) {
        Column() {
          this.topToolbar()
        }
        .width('100%')
      }
      if (this.controlsVisible) {
        Column() {
          this.bottomToolbar()
        }
        .width('100%')
        .position({ x: 0, y: '100%' })
        .translate({ y: '-100%' })
      }
      if (this.catalogVisible) {
        Stack({ alignContent: Alignment.Start }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.5)
            .onClick((): void => {
              this.catalogVisible = false;
            })
          this.catalogPanel()
        }
        .width('100%')
        .height('100%')
      }
      if (this.settingsVisible) {
        Stack({ alignContent: Alignment.Bottom }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.5)
            .onClick((): void => {
              this.settingsVisible = false;
            })
          this.settingsPanel()
        }
        .width('100%')
        .height('100%')
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(UPStyle.parse(this.props.customStyle).height ?? Math.max(1, upNumber(this.props.viewportHeight, 600)))
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? this.themeTokens().background)
    .clip(true)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.captureViewport(this.measure(newValue.width), this.measure(newValue.height));
    })
  }

  private measure(value: Length): number {
    if (typeof value === 'number') {
      return Math.max(0, value);
    }
    if (typeof value === 'string') {
      const amount: number = parseFloat(value);
      return isNaN(amount) ? 0 : Math.max(0, amount);
    }
    return 0;
  }
}
