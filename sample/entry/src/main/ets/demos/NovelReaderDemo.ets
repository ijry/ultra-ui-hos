import {
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UPNovelBookmark,
  UPNovelChapter,
  UPNovelChapterRequest,
  UPNovelLayoutEvent,
  UPNovelPersistedState,
  UPNovelProgress,
  UPNovelReader,
  UPNovelReaderController,
  UPNovelReaderProps,
  UPNovelSettings,
  UPNovelStorage,
  UPNovelToolbarEvent,
  UP_NOVEL_MODES,
  UP_NOVEL_THEMES,
  upNovelMeasureText,
  upNovelMode,
  upNovelProgressLabel,
  upNovelTapZone,
  upNovelThemeLabel,
  upNovelThemeSupported
} from '@lingyun/ultra-ui-hos';

/** 内存版存储适配器，示例中替代 uni.getStorageSync。/ In-memory storage adapter for the sample. */
class NovelMemoryStorage implements UPNovelStorage {
  private store: Map<string, UPNovelPersistedState> = new Map<string, UPNovelPersistedState>();

  get(key: string): UPNovelPersistedState | undefined {
    return this.store.get(key);
  }

  set(key: string, value: UPNovelPersistedState): void {
    this.store.set(key, value);
  }

  remove(key: string): void {
    this.store.delete(key);
  }

  size(): number {
    return this.store.size;
  }
}

@Component
export struct NovelReaderDemo {
  @State private status: string = '点击正文中间呼出工具条，两侧翻页或切换模式';
  @State private boundary: string = '';
  @State private modeIndex: number = 0;
  @State private chapterIndex: number = 0;
  @State private bookmarkCount: number = 0;
  @State private progressText: string = '';
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private controller: UPNovelReaderController = new UPNovelReaderController();
  private storage: NovelMemoryStorage = new NovelMemoryStorage();
  private probeThemes: Array<string> = ['day', 'night', 'sepia'];
  private chapters: Array<UPNovelChapter> = [
    {
      id: 'c1',
      index: 0,
      title: '第一章 起风了',
      content: '江南的雨季来得早，屋檐下的水珠连成一线。\n'
        + '他站在门口，看着院子里被打湿的青石板，忽然想起很多年前的一个傍晚。\n'
        + '那时候他还很小，母亲坐在灯下缝补衣服，针脚细密，光影摇晃。\n'
        + '风从巷口吹进来，带着潮气和远处炊烟的味道。\n'
        + '这一段刻意写得长一些，用来验证翻页模式下的分页与滚动模式下的段距表现，'
        + '同时混入 some English words 与标点，检查折行是否在合适的位置断开。'
    },
    {
      id: 'c2',
      index: 1,
      title: '第二章 旧信',
      content: '抽屉最底层压着一封没有寄出的信。\n信纸已经发黄，字迹却依旧清楚。\n他读了两行就停下来，把信重新折好放回原处。'
    },
    {
      id: 'c3',
      index: 2,
      title: '第三章 上锁的章节',
      content: '',
      isLocked: true
    }
  ];

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private currentChapter(): UPNovelChapter {
    return this.chapters[this.chapterIndex];
  }

  private handleChapterRequest(event: UPNovelChapterRequest): void {
    if (event.targetIndex < 0 || event.targetIndex >= this.chapters.length) {
      this.status = '目标章节不存在：' + String(event.targetIndex);
      return;
    }
    this.chapterIndex = event.targetIndex;
    this.status = 'chapter-request：' + event.direction + ' → ' + this.chapters[event.targetIndex].title;
  }

  private handleProgress(progress: UPNovelProgress): void {
    this.progressText = upNovelProgressLabel(progress.chapterIndex, this.chapters.length,
      progress.chapterProgress * 100) + '，字符偏移 ' + String(progress.charOffset);
  }

  private handleBookmarks(bookmarks: Array<UPNovelBookmark>): void {
    this.bookmarkCount = bookmarks.length;
    this.status = '书签数量：' + String(bookmarks.length);
  }

  private handleSettings(settings: UPNovelSettings): void {
    this.status = '设置变更：主题 ' + upNovelThemeLabel(settings.theme) + '，字号 ' + String(settings.fontSize);
  }

  private handleLayout(event: UPNovelLayoutEvent): void {
    this.status = 'layout-ready：' + event.mode + ' 模式，共 ' + String(event.pageCount) + ' 页';
  }

  private handleToolbar(event: UPNovelToolbarEvent): void {
    this.status = '工具条' + (event.visible ? '展开' : '收起') + '（' + event.reason + '）';
  }

  private measureText(): string {
    return '「江南」估算宽度 ' + String(Math.round(upNovelMeasureText('江南', 18)))
      + '，「ab」估算宽度 ' + String(Math.round(upNovelMeasureText('ab', 18)));
  }

  private zoneText(): string {
    return '点击分区：60 → ' + upNovelTapZone(60, 375) + '，180 → ' + upNovelTapZone(180, 375)
      + '，320 → ' + upNovelTapZone(320, 375);
  }

  private modeText(): string {
    return 'mode 白名单 ' + UP_NOVEL_MODES.join('/') + '，未知值回落 ' + upNovelMode('flip');
  }

  private probeText(theme: string): string {
    return 'theme=' + theme + (upNovelThemeSupported(theme)
      ? '：命中 ' + upNovelThemeLabel(theme) + ' 主题'
      : '：不在 ' + UP_NOVEL_THEMES.join('/') + ' 内，回落日间并报诊断');
  }

  build() {
    Column({ space: 16 }) {
      Text('小说阅读器')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPNovelReader({
        props: new UPNovelReaderProps({
          chapters: this.chapters,
          currentChapter: this.currentChapter(),
          bookId: 'demo-book',
          mode: UP_NOVEL_MODES[this.modeIndex],
          viewportWidth: 340,
          viewportHeight: 420,
          controlsAutoHide: 4000,
          storage: this.storage,
          controller: this.controller,
          diagnostics: this.diagnostics,
          onChapterRequest: (event: UPNovelChapterRequest): void => {
            this.handleChapterRequest(event);
          },
          onChapterPrefetch: (event: UPNovelChapterRequest): void => {
            this.status = 'chapter-prefetch：预取 ' + String(event.targetIndex + 1) + ' 章';
          },
          onProgressChange: (progress: UPNovelProgress): void => {
            this.handleProgress(progress);
          },
          onBookmarkChange: (bookmarks: Array<UPNovelBookmark>): void => {
            this.handleBookmarks(bookmarks);
          },
          onSettingsChange: (settings: UPNovelSettings): void => {
            this.handleSettings(settings);
          },
          onLayoutReady: (event: UPNovelLayoutEvent): void => {
            this.handleLayout(event);
          },
          onToolbarChange: (event: UPNovelToolbarEvent): void => {
            this.handleToolbar(event);
          },
          onBack: (): void => {
            this.status = 'back：返回由宿主页面处理';
          },
          onRetry: (): void => {
            this.status = 'retry：重新请求当前章节';
          }
        })
      })
      Row({ space: 10 }) {
        Button(UP_NOVEL_MODES[this.modeIndex] === 'page' ? '切到滚动模式' : '切到翻页模式')
          .fontSize(14)
          .height(36)
          .backgroundColor('#ecf5ff')
          .fontColor('#2979ff')
          .onClick((): void => {
            this.modeIndex = this.modeIndex === 0 ? 1 : 0;
            this.status = '当前模式：' + UP_NOVEL_MODES[this.modeIndex];
          })
        Button('呼出工具条')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.controller.toggleControls();
          })
        Button('添加书签')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.controller.toggleBookmark();
          })
      }
      .width('100%')
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.progressText.length > 0 ? this.progressText : '尚未产生进度回调')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text('书签 ' + String(this.bookmarkCount) + ' 条，持久化条目 ' + String(this.storage.size()) + ' 个')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('排版自检')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.measureText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.zoneText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.modeText()).fontSize(12).fontColor('#909399').width('100%')
      ForEach(this.probeThemes, (theme: string): void => {
        Text(this.probeText(theme)).fontSize(12).fontColor('#909399').width('100%')
      }, (theme: string): string => theme)
      Text('翻页分页按字符宽度估算，与真实字体度量存在细微差异；上锁章节不参与翻章。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('进度、设置、书签与阅读时长通过宿主注入的存储适配器持久化，组件不直接调用系统存储。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
