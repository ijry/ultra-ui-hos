import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';

/** 单个过渡端点的动画量。/ Animated values of one transition endpoint. */
export interface UPTransitionFrame {
  opacity: number;
  translateX: string;
  translateY: string;
  scale: number;
}

/** 上游 nvue-ani-map 的 12 种模式白名单。/ Upstream mode whitelist. */
export function upTransitionModeSupported(mode: string): boolean {
  return mode === 'none' || mode === 'fade' || mode === 'fade-up' || mode === 'fade-down'
    || mode === 'fade-left' || mode === 'fade-right' || mode === 'slide-up' || mode === 'slide-down'
    || mode === 'slide-left' || mode === 'slide-right' || mode === 'zoom' || mode === 'fade-zoom';
}

/**
 * 取模式的「隐藏端」动画量，显示端恒为 opacity 1 / 无位移 / scale 1。
 * Resolves the hidden endpoint; the visible endpoint is always fully opaque and untransformed.
 */
export function upTransitionHiddenFrame(mode: string): UPTransitionFrame {
  if (mode === 'none') {
    return { opacity: 0, translateX: '0', translateY: '0', scale: 1 };
  }
  if (mode === 'fade-up') {
    return { opacity: 0, translateX: '0', translateY: '100%', scale: 1 };
  }
  if (mode === 'fade-down') {
    return { opacity: 0, translateX: '0', translateY: '-100%', scale: 1 };
  }
  if (mode === 'fade-left') {
    return { opacity: 0, translateX: '-100%', translateY: '0', scale: 1 };
  }
  if (mode === 'fade-right') {
    return { opacity: 0, translateX: '100%', translateY: '0', scale: 1 };
  }
  if (mode === 'slide-up') {
    return { opacity: 1, translateX: '0', translateY: '100%', scale: 1 };
  }
  if (mode === 'slide-down') {
    return { opacity: 1, translateX: '0', translateY: '-100%', scale: 1 };
  }
  if (mode === 'slide-left') {
    return { opacity: 1, translateX: '-100%', translateY: '0', scale: 1 };
  }
  if (mode === 'slide-right') {
    return { opacity: 1, translateX: '100%', translateY: '0', scale: 1 };
  }
  if (mode === 'zoom') {
    return { opacity: 1, translateX: '0', translateY: '0', scale: 0.95 };
  }
  if (mode === 'fade-zoom') {
    return { opacity: 0, translateX: '0', translateY: '0', scale: 0.95 };
  }
  return { opacity: 0, translateX: '0', translateY: '0', scale: 1 };
}

/** 上游 timingFunction 到 ArkUI Curve 的白名单映射。/ Timing function whitelist. */
export function upTransitionCurve(timingFunction: string): Curve | undefined {
  if (timingFunction === 'linear') {
    return Curve.Linear;
  }
  if (timingFunction === 'ease') {
    return Curve.Ease;
  }
  if (timingFunction === 'ease-in') {
    return Curve.EaseIn;
  }
  if (timingFunction === 'ease-out') {
    return Curve.EaseOut;
  }
  if (timingFunction === 'ease-in-out') {
    return Curve.EaseInOut;
  }
  return undefined;
}

export interface UPTransitionOptions {
  show?: UPRawValue;
  mode?: UPRawValue;
  duration?: UPRawValue;
  timingFunction?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: () => void;
  onBeforeEnter?: () => void;
  onEnter?: () => void;
  onAfterEnter?: () => void;
  onBeforeLeave?: () => void;
  onLeave?: () => void;
  onAfterLeave?: () => void;
  contentBuilder?: UPBuilder;
}

export class UPTransitionProps {
  show: UPRawValue = false;
  mode: UPRawValue = 'fade';
  duration: UPRawValue = '300';
  timingFunction: UPRawValue = 'ease-out';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onClick?: () => void;
  onBeforeEnter?: () => void;
  onEnter?: () => void;
  onAfterEnter?: () => void;
  onBeforeLeave?: () => void;
  onLeave?: () => void;
  onAfterLeave?: () => void;
  contentBuilder?: UPBuilder;

  constructor(options?: UPTransitionOptions) {
    if (options === undefined) {
      return;
    }
    this.show = options.show ?? this.show;
    this.mode = options.mode ?? this.mode;
    this.duration = options.duration ?? this.duration;
    this.timingFunction = options.timingFunction ?? this.timingFunction;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
    this.onBeforeEnter = options.onBeforeEnter;
    this.onEnter = options.onEnter;
    this.onAfterEnter = options.onAfterEnter;
    this.onBeforeLeave = options.onBeforeLeave;
    this.onLeave = options.onLeave;
    this.onAfterLeave = options.onAfterLeave;
    this.contentBuilder = options.contentBuilder;
  }
}

/** 上游 vue 路径里进入前的 20ms 等待。/ Upstream sleeps 20ms before the enter frame. */
const UP_TRANSITION_ENTER_DELAY: number = 20;

@Component
export struct UPTransition {
  @Prop @Watch('applyShow') props: UPTransitionProps = new UPTransitionProps();
  @State private inited: boolean = false;
  @State private display: boolean = false;
  @State private entered: boolean = false;
  private appliedShow: boolean = false;
  private enterTimerId: number = -1;
  private leaveTimerId: number = -1;
  private transitionEnded: boolean = false;

  @Builder
  private defaultContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.defaultContent;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    const mode: string = upString(this.props.mode, 'fade');
    if (!upTransitionModeSupported(mode)) {
      diagnostics.report('UPTransition', 'mode', this.props.mode, 'unsupported mode; fallback to fade');
    }
    const timingFunction: string = upString(this.props.timingFunction, 'ease-out');
    if (upTransitionCurve(timingFunction) === undefined) {
      diagnostics.report('UPTransition', 'timingFunction', this.props.timingFunction, 'unsupported timing function; fallback to ease-out');
    }
    this.appliedShow = upBoolean(this.props.show, false);
    if (this.appliedShow) {
      this.beginEnter();
    }
  }

  aboutToDisappear(): void {
    this.clearTimers();
  }

  private clearTimers(): void {
    if (this.enterTimerId >= 0) {
      clearTimeout(this.enterTimerId);
      this.enterTimerId = -1;
    }
    if (this.leaveTimerId >= 0) {
      clearTimeout(this.leaveTimerId);
      this.leaveTimerId = -1;
    }
  }

  /** show 变化时按上游 watch 分派进入或离开。/ Mirrors the upstream show watcher. */
  private applyShow(): void {
    const next: boolean = upBoolean(this.props.show, false);
    if (next === this.appliedShow) {
      return;
    }
    this.appliedShow = next;
    if (next) {
      this.beginEnter();
    } else {
      this.beginLeave();
    }
  }

  /** 进入序列：beforeEnter → 挂载 → 20ms → enter → afterEnter。/ Enter sequence. */
  private beginEnter(): void {
    this.clearTimers();
    this.transitionEnded = false;
    const beforeEnter: (() => void) | undefined = this.props.onBeforeEnter;
    if (beforeEnter !== undefined) {
      beforeEnter();
    }
    this.inited = true;
    this.display = true;
    this.entered = false;
    this.enterTimerId = setTimeout((): void => {
      this.enterTimerId = -1;
      this.entered = true;
      const enter: (() => void) | undefined = this.props.onEnter;
      if (enter !== undefined) {
        enter();
      }
      this.leaveTimerId = setTimeout((): void => {
        this.leaveTimerId = -1;
        this.finishTransition('enter');
      }, this.durationValue());
    }, UP_TRANSITION_ENTER_DELAY);
  }

  /** 离开序列：display 为假时直接返回，对应上游 vueLeave 的守卫。/ Leave sequence. */
  private beginLeave(): void {
    if (!this.display) {
      return;
    }
    this.clearTimers();
    this.transitionEnded = false;
    const beforeLeave: (() => void) | undefined = this.props.onBeforeLeave;
    if (beforeLeave !== undefined) {
      beforeLeave();
    }
    this.entered = false;
    const leave: (() => void) | undefined = this.props.onLeave;
    if (leave !== undefined) {
      leave();
    }
    this.leaveTimerId = setTimeout((): void => {
      this.leaveTimerId = -1;
      this.finishTransition('leave');
    }, this.durationValue());
  }

  /** 对应上游 onTransitionEnd 的一次性收口。/ Mirrors the upstream onTransitionEnd guard. */
  private finishTransition(status: string): void {
    if (this.transitionEnded) {
      return;
    }
    this.transitionEnded = true;
    if (status === 'leave') {
      const afterLeave: (() => void) | undefined = this.props.onAfterLeave;
      if (afterLeave !== undefined) {
        afterLeave();
      }
    } else {
      const afterEnter: (() => void) | undefined = this.props.onAfterEnter;
      if (afterEnter !== undefined) {
        afterEnter();
      }
    }
    if (!upBoolean(this.props.show, false) && this.display) {
      this.display = false;
      this.inited = false;
    }
  }

  /** 上游 duration 允许字符串数字，统一按毫秒解析。/ Duration accepts numeric strings. */
  private durationValue(): number {
    const parsed: number = UPUnit.parse(this.props.duration, 375, 300);
    return parsed > 0 ? Math.floor(parsed) : 300;
  }

  private modeName(): string {
    const mode: string = upString(this.props.mode, 'fade');
    return upTransitionModeSupported(mode) ? mode : 'fade';
  }

  private curveValue(): Curve {
    return upTransitionCurve(upString(this.props.timingFunction, 'ease-out')) ?? Curve.EaseOut;
  }

  private frame(): UPTransitionFrame {
    return this.entered
      ? { opacity: 1, translateX: '0', translateY: '0', scale: 1 }
      : upTransitionHiddenFrame(this.modeName());
  }

  private handleClick(): void {
    const click: (() => void) | undefined = this.props.onClick;
    if (click !== undefined) {
      click();
    }
  }

  build() {
    Column() {
      if (this.inited) {
        Column() {
          this.contentBuilder()
        }
        .opacity(this.frame().opacity)
        .translate({ x: this.frame().translateX, y: this.frame().translateY })
        .scale({ x: this.frame().scale, y: this.frame().scale })
        .animation({ duration: this.durationValue(), curve: this.curveValue() })
        .onClick((): void => this.handleClick())
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .visibility(this.inited ? Visibility.Visible : Visibility.None)
  }
}
