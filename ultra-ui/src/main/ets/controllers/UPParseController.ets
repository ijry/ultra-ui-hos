import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';

/** 转发给已挂载 UPParse 的命令。/ Imperative command relayed to the mounted UPParse. */
export interface UPParseCommand {
  action: string;
  content: string;
  append: boolean;
  anchor: string;
  offset: number;
  rate: number;
}

export type UPParseControllerListener = (command: UPParseCommand) => void;

/**
 * 把上游 setContent()/getText()/navigate-to/pauseMedia()/setPlaybackRate() 这些实例方法
 * 搬到 ArkTS，因为 struct 无法通过模板 ref 调用方法。
 * Bridges the upstream u-parse instance methods into ArkTS, where struct methods
 * cannot be invoked through a template ref.
 */
export class UPParseController {
  private listener?: UPParseControllerListener;
  private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  private text: string = '';
  private images: Array<string> = [];
  private title: string = '';

  constructor(diagnostics?: UPCompatibilityDiagnostics) {
    this.diagnostics = diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  mount(listener: UPParseControllerListener): void {
    this.listener = listener;
  }

  unmount(): void {
    this.listener = undefined;
  }

  /** 上游 setContent(content, append)。/ Upstream setContent(content, append). */
  setContent(content: string, append: boolean = false): void {
    this.dispatch({ action: 'setContent', content: content, append: append, anchor: '', offset: 0, rate: 1 });
  }

  /**
   * 上游的 navigate-to(id, offset)，此处改名以避开业务路由 API。
   * Upstream navigate-to(id, offset), renamed to stay clear of router APIs.
   */
  scrollToAnchor(id: string, offset: number = 0): void {
    const distance: number = Number.isFinite(offset) ? offset : 0;
    this.dispatch({ action: 'scrollToAnchor', content: '', append: false, anchor: id, offset: distance, rate: 1 });
  }

  /** 上游 pauseMedia()。/ Upstream pauseMedia(). */
  pauseMedia(): void {
    this.dispatch({ action: 'pauseMedia', content: '', append: false, anchor: '', offset: 0, rate: 1 });
  }

  /** 上游 setPlaybackRate(rate)。/ Upstream setPlaybackRate(rate). */
  setPlaybackRate(rate: number): void {
    const speed: number = Number.isFinite(rate) && rate > 0 ? rate : 1;
    this.dispatch({ action: 'setPlaybackRate', content: '', append: false, anchor: '', offset: 0, rate: speed });
  }

  /** 上游 getText()：返回最近一次解析的纯文本。/ Upstream getText() over the latest parse. */
  getText(): string {
    return this.text;
  }

  /** 上游 imgList：最近一次解析收集到的图片地址。/ Upstream imgList snapshot. */
  imageList(): Array<string> {
    return this.images.slice();
  }

  /** 上游 setTitle 使用的 <title> 文本。/ The <title> text used by upstream setTitle. */
  documentTitle(): string {
    return this.title;
  }

  /** 组件每次解析后回填快照。/ Snapshot pushed back by the component after each parse. */
  updateSnapshot(text: string, images: Array<string>, title: string): void {
    this.text = text;
    this.images = images.slice();
    this.title = title;
  }

  private dispatch(command: UPParseCommand): void {
    if (this.listener === undefined) {
      this.diagnostics.report('UPParseController', command.action, command.anchor,
        'controller command dropped because no parser is mounted');
      return;
    }
    this.listener(command);
  }
}
