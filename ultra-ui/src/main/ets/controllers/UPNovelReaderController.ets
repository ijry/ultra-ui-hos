import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPNovelBookmark, UPNovelProgress, UPNovelSettingsPatch } from '../internal/UPNovelLayout';

/** 转发给已挂载 UPNovelReader 的命令。/ Imperative command relayed to the mounted reader. */
export interface UPNovelReaderCommand {
  action: string;
  target: number;
  direction: string;
  settings?: UPNovelSettingsPatch;
}

export type UPNovelReaderControllerListener = (command: UPNovelReaderCommand) => void;

/**
 * 把上游模板 ref 上的阅读器操作搬到 ArkTS：翻页、跳章、切模式、改设置与开合工具条。
 * Bridges the upstream reader interactions into ArkTS: paging, chapter jumps, mode and settings.
 */
export class UPNovelReaderController {
  private listener?: UPNovelReaderControllerListener;
  private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  private progress: UPNovelProgress = new UPNovelProgress();
  private bookmarks: Array<UPNovelBookmark> = [];
  private readingTime: number = 0;

  constructor(diagnostics?: UPCompatibilityDiagnostics) {
    this.diagnostics = diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  mount(listener: UPNovelReaderControllerListener): void {
    this.listener = listener;
  }

  unmount(): void {
    this.listener = undefined;
  }

  /** 上游 movePage(offset)。/ Upstream movePage(offset). */
  movePage(offset: number): void {
    this.dispatch({ action: 'movePage', target: offset, direction: offset < 0 ? 'previous' : 'next' });
  }

  /** 上游 requestChapter(direction, targetIndex)。/ Upstream requestChapter(). */
  requestChapter(direction: string, targetIndex: number = -1): void {
    this.dispatch({ action: 'requestChapter', target: targetIndex, direction: direction });
  }

  /** 上游 toggleControls()。/ Upstream toggleControls(). */
  toggleControls(): void {
    this.dispatch({ action: 'toggleControls', target: 0, direction: '' });
  }

  /** 上游 toggleBookmark()。/ Upstream toggleBookmark(). */
  toggleBookmark(): void {
    this.dispatch({ action: 'toggleBookmark', target: 0, direction: '' });
  }

  /** 上游 handleSettingsUpdate(settings)。/ Upstream handleSettingsUpdate(). */
  updateSettings(settings: UPNovelSettingsPatch): void {
    this.dispatch({ action: 'updateSettings', target: 0, direction: '', settings: settings });
  }

  /** 上游 setMode(mode)。/ Upstream setMode(). */
  setMode(mode: string): void {
    this.dispatch({ action: 'setMode', target: 0, direction: mode });
  }

  /** 上游 handleRetry()。/ Upstream handleRetry(). */
  retry(): void {
    this.dispatch({ action: 'retry', target: 0, direction: '' });
  }

  /** 最近一次进度。/ The latest progress snapshot. */
  currentProgress(): UPNovelProgress {
    return this.progress.clone();
  }

  /** 最近一次书签列表。/ The latest bookmark list. */
  currentBookmarks(): Array<UPNovelBookmark> {
    return this.bookmarks.slice();
  }

  /** 累计阅读时长（毫秒）。/ Accumulated reading time in milliseconds. */
  currentReadingTime(): number {
    return this.readingTime;
  }

  /** 组件每次变更后回填快照。/ Snapshot pushed back by the component. */
  updateSnapshot(progress: UPNovelProgress, bookmarks: Array<UPNovelBookmark>, readingTime: number): void {
    this.progress = progress.clone();
    this.bookmarks = bookmarks.slice();
    this.readingTime = readingTime;
  }

  private dispatch(command: UPNovelReaderCommand): void {
    if (this.listener === undefined) {
      this.diagnostics.report('UPNovelReaderController', command.action, command.direction,
        'controller command dropped because no reader is mounted');
      return;
    }
    this.listener(command);
  }
}
