import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';

/** Imperative command relayed to the mounted UPRefreshVirtualList. */
export interface UPRefreshVirtualListCommand {
  action: string;
  scrollTop: number;
}

export type UPRefreshVirtualListControllerListener = (command: UPRefreshVirtualListCommand) => void;

/**
 * Bridges the upstream instance methods finishRefresh() / scrollTo() / scrollToTop()
 * into ArkTS, where struct methods cannot be invoked through a template ref.
 */
export class UPRefreshVirtualListController {
  private listener?: UPRefreshVirtualListControllerListener;
  private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;

  constructor(diagnostics?: UPCompatibilityDiagnostics) {
    this.diagnostics = diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  mount(listener: UPRefreshVirtualListControllerListener): void {
    this.listener = listener;
  }

  unmount(): void {
    this.listener = undefined;
  }

  finishRefresh(): void {
    this.dispatch({ action: 'finishRefresh', scrollTop: 0 });
  }

  scrollTo(top: number): void {
    const target: number = Number.isFinite(top) ? Math.max(0, top) : 0;
    this.dispatch({ action: 'scrollTo', scrollTop: target });
  }

  scrollToTop(): void {
    this.scrollTo(0);
  }

  private dispatch(command: UPRefreshVirtualListCommand): void {
    if (this.listener === undefined) {
      this.diagnostics.report('UPRefreshVirtualListController', command.action, command.scrollTop,
        'controller command dropped because no list is mounted');
      return;
    }
    this.listener(command);
  }
}
