import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';

/** 转发给已挂载 UPPoster 的命令。/ Imperative command relayed to the mounted UPPoster. */
export interface UPPosterCommand {
  action: string;
}

/** 上游 exportImage() 的返回结构。/ Result shape of the upstream exportImage(). */
export interface UPPosterImage {
  path: string;
  width: number;
  height: number;
}

export type UPPosterControllerListener = (command: UPPosterCommand) => void;

/**
 * 把上游 exportImage() 这个实例方法搬到 ArkTS，因为 struct 无法通过模板 ref 调用方法。
 * Bridges the upstream exportImage() instance method into ArkTS, where struct methods
 * cannot be invoked through a template ref.
 */
export class UPPosterController {
  private listener?: UPPosterControllerListener;
  private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  private image: UPPosterImage = { path: '', width: 0, height: 0 };

  constructor(diagnostics?: UPCompatibilityDiagnostics) {
    this.diagnostics = diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  mount(listener: UPPosterControllerListener): void {
    this.listener = listener;
  }

  unmount(): void {
    this.listener = undefined;
  }

  /** 上游 exportImage()：绘制后导出图片。/ Upstream exportImage(). */
  exportImage(): void {
    this.dispatch({ action: 'exportImage' });
  }

  /** 重绘海报，对应上游 `showCanvas` 打开后的重绘。/ Repaints the poster. */
  redraw(): void {
    this.dispatch({ action: 'redraw' });
  }

  /** 最近一次导出的结果。/ The latest export result. */
  lastImage(): UPPosterImage {
    return { path: this.image.path, width: this.image.width, height: this.image.height };
  }

  /** 组件导出后回填快照。/ Snapshot pushed back by the component after each export. */
  updateSnapshot(image: UPPosterImage): void {
    this.image = { path: image.path, width: image.width, height: image.height };
  }

  private dispatch(command: UPPosterCommand): void {
    if (this.listener === undefined) {
      this.diagnostics.report('UPPosterController', command.action, '',
        'controller command dropped because no poster is mounted');
      return;
    }
    this.listener(command);
  }
}
