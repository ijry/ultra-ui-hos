import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import {
  UPHtmlDeclaration,
  UPHtmlParseOptions,
  UPHtmlParseResult,
  upHtmlNodesText,
  upHtmlParse
} from '../internal/UPHtmlParser';
import {
  UPHtmlBlock,
  UPHtmlLayout,
  UPHtmlLayoutOptions,
  UPHtmlLayoutResult,
  UPHtmlTableCell,
  UPHtmlTableRow,
  UPHtmlTextRun,
  UP_HTML_BASE_FONT_SIZE,
  UP_HTML_LINK_COLOR,
  UP_HTML_LIST_INDENT
} from '../internal/UPHtmlLayout';
import { UPParseCommand, UPParseController } from '../controllers/UPParseController';
import { UPImage, UPImageProps } from './UPImage';
import { UPIcon, UPIconProps } from './UPIcon';

/** 上游 `._root` 的上下内边距。/ Vertical padding of the upstream `._root` rule. */
const UP_PARSE_ROOT_PADDING: number = 1;
/** 正文字族与等宽字族。/ Body and monospace font families. */
const UP_PARSE_TEXT_FAMILY: string = 'HarmonyOS Sans';
const UP_PARSE_MONO_FAMILY: string = 'monospace';
/** 透明背景占位色。/ Transparent placeholder color. */
const UP_PARSE_TRANSPARENT: string = '#00000000';
/** 无显式宽高时的图片回退尺寸，对应上游 `._video` 的 300x225。/ Fallback media box. */
const UP_PARSE_MEDIA_WIDTH: number = 300;
const UP_PARSE_MEDIA_HEIGHT: number = 225;
/** 列表符号列宽。/ Width reserved for the list marker column. */
const UP_PARSE_MARKER_WIDTH: number = 22;

/** 锚点位置记录，替代上游 createSelectorQuery。/ Anchor offset captured through onAreaChange. */
class UPParseAnchor {
  id: string = '';
  top: number = 0;

  constructor(id: string, top: number) {
    this.id = id;
    this.top = top;
  }
}

/** 上游 imgtap 事件。/ Upstream imgtap payload. */
export interface UPParseImageTapEvent {
  src: string;
  index: number;
  alt: string;
  ignore: boolean;
}

/** 上游 linktap 事件。/ Upstream linktap payload. */
export interface UPParseLinkTapEvent {
  href: string;
  innerText: string;
  external: boolean;
}

/** 上游 ready 事件，携带根节点尺寸。/ Upstream ready payload carrying the root rect. */
export interface UPParseReadyEvent {
  width: number;
  height: number;
}

/** 上游 play 事件。/ Upstream play payload. */
export interface UPParseMediaEvent {
  source: string;
  src: string;
  poster: string;
}

/** 上游 error 事件。/ Upstream error payload. */
export interface UPParseErrorEvent {
  source: string;
  src: string;
  message: string;
}

export interface UPParseOptions {
  content?: UPRawValue;
  containerStyle?: UPStyleInput;
  copyLink?: UPRawValue;
  domain?: UPRawValue;
  errorImg?: UPRawValue;
  lazyLoad?: UPRawValue;
  loadingImg?: UPRawValue;
  pauseVideo?: UPRawValue;
  previewImg?: UPRawValue;
  scrollTable?: UPRawValue;
  selectable?: UPRawValue;
  setTitle?: UPRawValue;
  showImgMenu?: UPRawValue;
  useAnchor?: UPRawValue;
  tagStyle?: Array<UPHtmlDeclaration>;
  baseColor?: UPRawValue;
  linkColor?: UPRawValue;
  baseFontSize?: UPRawValue;
  viewportWidth?: UPRawValue;
  controller?: UPParseController;
  diagnostics?: UPCompatibilityDiagnostics;
  openLink?: (href: string) => boolean;
  onLoad?: () => void;
  onReady?: (event: UPParseReadyEvent) => void;
  onImgTap?: (event: UPParseImageTapEvent) => void;
  onLinkTap?: (event: UPParseLinkTapEvent) => void;
  onPlay?: (event: UPParseMediaEvent) => void;
  onError?: (event: UPParseErrorEvent) => void;
  onClick?: () => void;
  onTap?: () => void;
}

export class UPParseProps {
  content: UPRawValue = '';
  containerStyle: UPStyleInput = undefined;
  copyLink: UPRawValue = true;
  domain: UPRawValue = '';
  errorImg: UPRawValue = '';
  lazyLoad: UPRawValue = false;
  loadingImg: UPRawValue = '';
  pauseVideo: UPRawValue = true;
  previewImg: UPRawValue = true;
  scrollTable: UPRawValue = false;
  selectable: UPRawValue = false;
  setTitle: UPRawValue = true;
  showImgMenu: UPRawValue = true;
  useAnchor: UPRawValue = false;
  tagStyle: Array<UPHtmlDeclaration> = [];
  baseColor: UPRawValue = '#303133';
  linkColor: UPRawValue = UP_HTML_LINK_COLOR;
  baseFontSize: UPRawValue = UP_HTML_BASE_FONT_SIZE;
  viewportWidth: UPRawValue = 375;
  controller?: UPParseController;
  diagnostics?: UPCompatibilityDiagnostics;
  openLink?: (href: string) => boolean;
  onLoad?: () => void;
  onReady?: (event: UPParseReadyEvent) => void;
  onImgTap?: (event: UPParseImageTapEvent) => void;
  onLinkTap?: (event: UPParseLinkTapEvent) => void;
  onPlay?: (event: UPParseMediaEvent) => void;
  onError?: (event: UPParseErrorEvent) => void;
  onClick?: () => void;
  onTap?: () => void;

  constructor(options?: UPParseOptions) {
    if (options === undefined) {
      return;
    }
    this.content = options.content ?? this.content;
    this.containerStyle = options.containerStyle;
    this.copyLink = options.copyLink ?? this.copyLink;
    this.domain = options.domain ?? this.domain;
    this.errorImg = options.errorImg ?? this.errorImg;
    this.lazyLoad = options.lazyLoad ?? this.lazyLoad;
    this.loadingImg = options.loadingImg ?? this.loadingImg;
    this.pauseVideo = options.pauseVideo ?? this.pauseVideo;
    this.previewImg = options.previewImg ?? this.previewImg;
    this.scrollTable = options.scrollTable ?? this.scrollTable;
    this.selectable = options.selectable ?? this.selectable;
    this.setTitle = options.setTitle ?? this.setTitle;
    this.showImgMenu = options.showImgMenu ?? this.showImgMenu;
    this.useAnchor = options.useAnchor ?? this.useAnchor;
    this.tagStyle = options.tagStyle ?? this.tagStyle;
    this.baseColor = options.baseColor ?? this.baseColor;
    this.linkColor = options.linkColor ?? this.linkColor;
    this.baseFontSize = options.baseFontSize ?? this.baseFontSize;
    this.viewportWidth = options.viewportWidth ?? this.viewportWidth;
    this.controller = options.controller;
    this.diagnostics = options.diagnostics;
    this.openLink = options.openLink;
    this.onLoad = options.onLoad;
    this.onReady = options.onReady;
    this.onImgTap = options.onImgTap;
    this.onLinkTap = options.onLinkTap;
    this.onPlay = options.onPlay;
    this.onError = options.onError;
    this.onClick = options.onClick;
    this.onTap = options.onTap;
  }
}

/** 上游 isExternalLink()。/ Upstream isExternalLink(). */
function upParseExternalLink(href: string): boolean {
  return href.split('?')[0].includes(':' + '//');
}

/** 取块内首个带 href 的文本片段。/ First run carrying an href. */
function upParseBlockHref(block: UPHtmlBlock): string {
  if (block.href.length > 0) {
    return block.href;
  }
  for (const run of block.runs) {
    if (run.style.href.length > 0) {
      return run.style.href;
    }
  }
  return '';
}

/** 拼接块内文本，用于 linktap 的 innerText。/ Concatenated block text for linktap. */
function upParseBlockText(block: UPHtmlBlock): string {
  let text: string = '';
  for (const run of block.runs) {
    text += run.text;
  }
  return text;
}

/** 拼接单元格文本。/ Concatenated cell text. */
function upParseCellText(cell: UPHtmlTableCell): string {
  let text: string = '';
  for (const run of cell.runs) {
    text += run.text;
  }
  return text;
}

/**
 * u-parse 的 HarmonyOS 原生实现：解析 html 后摊平成 ArkUI 块，不使用 rich-text 或 web 内核。
 * Native u-parse renderer: parses html into flattened ArkUI blocks without rich-text or a web core.
 */
@Component
export struct UPParse {
  @Prop @Watch('applyProps') props: UPParseProps = new UPParseProps();
  @State private blocks: Array<UPHtmlBlock> = [];
  @State private measuredWidth: number = 0;
  private images: Array<string> = [];
  private plainText: string = '';
  private headTitle: string = '';
  private applied: string = '';
  private generation: number = 0;
  private anchors: Array<UPParseAnchor> = [];
  private readyReported: boolean = false;
  private scroller: Scroller = new Scroller();

  @Builder
  private emptyBuilder() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void {
    this.props.controller?.mount((command: UPParseCommand): void => this.execute(command));
    this.applied = this.signature();
    this.render(upString(this.props.content), false);
    this.reportBoundaries();
  }

  aboutToDisappear(): void {
    this.props.controller?.unmount();
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.render(upString(this.props.content), false);
    this.reportBoundaries();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    const styles: Array<string> = this.props.tagStyle.map((item: UPHtmlDeclaration): string => item.key + ':' + item.value);
    return upString(this.props.content) + '|' + upString(this.props.domain) + '|' +
      String(upBoolean(this.props.lazyLoad, false)) + '|' + String(upBoolean(this.props.previewImg, true)) + '|' +
      String(upBoolean(this.props.scrollTable, false)) + '|' + String(this.anchorEnabled()) + '|' +
      String(this.baseFontSize()) + '|' + String(this.viewport()) + '|' + styles.join(';');
  }

  private viewport(): number {
    return UPUnit.parse(this.props.viewportWidth, 375, 375);
  }

  private baseFontSize(): number {
    return UPUnit.parse(this.props.baseFontSize, 375, UP_HTML_BASE_FONT_SIZE);
  }

  private anchorOffset(): number {
    return UPUnit.parse(this.props.useAnchor, 375, 0);
  }

  private anchorEnabled(): boolean {
    if (typeof this.props.useAnchor === 'boolean') {
      return this.props.useAnchor;
    }
    return this.anchorOffset() > 0;
  }

  private parseOptions(): UPHtmlParseOptions {
    const options: UPHtmlParseOptions = new UPHtmlParseOptions();
    options.domain = upString(this.props.domain);
    options.useAnchor = this.anchorEnabled();
    options.lazyLoad = upBoolean(this.props.lazyLoad, false);
    options.previewImg = upBoolean(this.props.previewImg, true);
    options.scrollTable = upBoolean(this.props.scrollTable, false);
    options.viewportWidth = this.viewport();
    for (const item of this.props.tagStyle) {
      options.tagStyle.set(item.key, item.value);
    }
    return options;
  }

  private layoutOptions(): UPHtmlLayoutOptions {
    const options: UPHtmlLayoutOptions = new UPHtmlLayoutOptions();
    options.baseFontSize = this.baseFontSize();
    options.baseColor = upString(this.props.baseColor, '#303133');
    options.linkColor = upString(this.props.linkColor, UP_HTML_LINK_COLOR);
    options.viewportWidth = this.viewport();
    return options;
  }

  /** 解析并摊平内容，append 对应上游 setContent(content, true)。/ Parse and flatten content. */
  private render(content: string, append: boolean): void {
    const parsed: UPHtmlParseResult = upHtmlParse(content, this.parseOptions());
    const layout: UPHtmlLayoutResult = new UPHtmlLayout(this.layoutOptions()).build(parsed.nodes);
    this.generation += 1;
    const prefix: string = 'g' + String(this.generation) + '-';
    const offset: number = append ? this.images.length : 0;
    for (const block of layout.blocks) {
      block.key = prefix + block.key;
      if (block.imageIndex >= 0) {
        block.imageIndex = block.imageIndex + offset;
      }
    }
    const text: string = upHtmlNodesText(parsed.nodes);
    if (append) {
      this.blocks = this.blocks.concat(layout.blocks);
      this.images = this.images.concat(parsed.images);
      this.plainText = this.plainText + text;
      this.headTitle = parsed.title.length > 0 ? parsed.title : this.headTitle;
    } else {
      this.blocks = layout.blocks;
      this.images = parsed.images;
      this.plainText = text;
      this.headTitle = parsed.title;
      this.anchors = [];
    }
    for (const name of parsed.dropped) {
      this.diagnostics().report('UPParse', 'content', name, 'tag dropped by the html parser');
    }
    for (const name of layout.unsupported) {
      this.diagnostics().report('UPParse', 'content', name, 'tag has no native renderer and falls back to a placeholder block');
    }
    this.props.controller?.updateSnapshot(this.plainText, this.images, this.headTitle);
    this.props.onLoad?.();
  }

  private reportBoundaries(): void {
    if (upBoolean(this.props.lazyLoad, false)) {
      this.diagnostics().report('UPParse', 'lazyLoad', this.props.lazyLoad, 'images render eagerly because lazy decoding is not exposed');
    }
    if (upString(this.props.loadingImg).length > 0) {
      this.diagnostics().report('UPParse', 'loadingImg', this.props.loadingImg, 'loading placeholder is replaced by the deterministic image placeholder');
    }
    if (upString(this.props.errorImg).length > 0) {
      this.diagnostics().report('UPParse', 'errorImg', this.props.errorImg, 'error placeholder is replaced by the deterministic image placeholder');
    }
    if (upBoolean(this.props.previewImg, true)) {
      this.diagnostics().report('UPParse', 'previewImg', this.props.previewImg, 'image preview must be presented by the host through onImgTap');
    }
    if (upBoolean(this.props.showImgMenu, true)) {
      this.diagnostics().report('UPParse', 'showImgMenu', this.props.showImgMenu, 'long-press image menu is not exposed by this native wrapper');
    }
    if (upBoolean(this.props.pauseVideo, true)) {
      this.diagnostics().report('UPParse', 'pauseVideo', this.props.pauseVideo, 'media tags render as placeholders, so autoplay pausing is a no-op');
    }
    if (upBoolean(this.props.setTitle, true)) {
      this.diagnostics().report('UPParse', 'setTitle', this.props.setTitle, 'document title is returned through the controller instead of the navigation bar');
    }
  }

  /** 处理控制器命令。/ Execute a controller command. */
  private execute(command: UPParseCommand): void {
    if (command.action === 'setContent') {
      this.render(command.content, command.append);
      return;
    }
    if (command.action === 'scrollToAnchor') {
      this.scrollToAnchor(command.anchor, command.offset);
      return;
    }
    if (command.action === 'pauseMedia') {
      this.diagnostics().report('UPParse', 'pauseMedia', '', 'media tags render as placeholders, so pauseMedia is a no-op');
      return;
    }
    this.diagnostics().report('UPParse', 'setPlaybackRate', command.rate, 'media tags render as placeholders, so setPlaybackRate is a no-op');
  }

  /** 上游 navigate-to(id, offset) 的原生等价实现。/ Native equivalent of the upstream navigate-to(id, offset). */
  private scrollToAnchor(id: string, offset: number): void {
    if (!this.anchorEnabled()) {
      this.diagnostics().report('UPParse', 'useAnchor', id, 'anchor scrolling is disabled because useAnchor is false');
      return;
    }
    if (this.viewportHeight() <= 0) {
      this.diagnostics().report('UPParse', 'containerStyle', id, 'anchor scrolling requires a bounded height on containerStyle');
      return;
    }
    const distance: number = offset > 0 ? offset : this.anchorOffset();
    if (id.length === 0) {
      this.scroller.scrollTo({ xOffset: 0, yOffset: 0, animation: true });
      return;
    }
    for (const anchor of this.anchors) {
      if (anchor.id === id) {
        this.scroller.scrollTo({ xOffset: 0, yOffset: Math.max(0, anchor.top - distance), animation: true });
        return;
      }
    }
    this.diagnostics().report('UPParse', 'useAnchor', id, 'anchor label not found in the parsed content');
  }

  private recordAnchor(id: string, top: number): void {
    if (id.length === 0) {
      return;
    }
    for (const anchor of this.anchors) {
      if (anchor.id === id) {
        anchor.top = top;
        return;
      }
    }
    this.anchors.push(new UPParseAnchor(id, top));
  }

  private measure(value: Length): number {
    if (typeof value === 'number') {
      return Math.max(0, value);
    }
    if (typeof value === 'string') {
      return Math.max(0, UPUnit.parse(value, this.viewport(), 0));
    }
    return 0;
  }

  private viewportHeight(): number {
    return UPStyle.parse(this.props.containerStyle).height ?? 0;
  }

  private contentWidth(): number {
    const fixed: number = UPStyle.parse(this.props.containerStyle).width ?? 0;
    if (fixed > 0) {
      return fixed;
    }
    return this.measuredWidth > 0 ? this.measuredWidth : this.viewport();
  }

  private copyOptionValue(): CopyOptions {
    return upBoolean(this.props.selectable, false) ? CopyOptions.LocalDevice : CopyOptions.None;
  }

  private baseColorValue(): string {
    return UPColor.parse(this.props.baseColor, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133'));
  }

  private runColor(run: UPHtmlTextRun): string {
    if (run.style.href.length > 0 && run.style.color.length === 0) {
      return UPColor.parse(this.props.linkColor, UP_DEFAULT_THEME, UP_HTML_LINK_COLOR);
    }
    return UPColor.parse(run.style.color, UP_DEFAULT_THEME, this.baseColorValue());
  }

  private runBackground(run: UPHtmlTextRun): string {
    return run.style.background.length > 0
      ? UPColor.parse(run.style.background, UP_DEFAULT_THEME, UP_PARSE_TRANSPARENT)
      : UP_PARSE_TRANSPARENT;
  }

  private runDecoration(run: UPHtmlTextRun): TextDecorationType {
    if (run.style.lineThrough) {
      return TextDecorationType.LineThrough;
    }
    if (run.style.underline || run.style.href.length > 0) {
      return TextDecorationType.Underline;
    }
    return TextDecorationType.None;
  }

  private runFamily(run: UPHtmlTextRun): string {
    return run.style.mono ? UP_PARSE_MONO_FAMILY : UP_PARSE_TEXT_FAMILY;
  }

  private textAlignOf(value: string): TextAlign {
    switch (value) {
      case 'center': return TextAlign.Center;
      case 'right': return TextAlign.End;
      case 'end': return TextAlign.End;
      case 'justify': return TextAlign.JUSTIFY;
      default: return TextAlign.Start;
    }
  }

  private blockBackground(block: UPHtmlBlock): string {
    return block.style.background.length > 0
      ? UPColor.parse(block.style.background, UP_DEFAULT_THEME, UP_PARSE_TRANSPARENT)
      : UP_PARSE_TRANSPARENT;
  }

  private blockIndent(block: UPHtmlBlock): number {
    return block.style.marginLeft + Math.max(0, block.depth - 1) * UP_HTML_LIST_INDENT;
  }

  private imageBoxWidth(block: UPHtmlBlock): number {
    if (block.imageWidth > 0) {
      return block.imageWidth;
    }
    const available: number = this.contentWidth() - this.blockIndent(block);
    return available > 0 ? available : UP_PARSE_MEDIA_WIDTH;
  }

  private imageBoxHeight(block: UPHtmlBlock): number {
    if (block.imageHeight > 0) {
      return block.imageHeight;
    }
    return this.imageBoxWidth(block) * UP_PARSE_MEDIA_HEIGHT / UP_PARSE_MEDIA_WIDTH;
  }

  private imageMode(block: UPHtmlBlock): string {
    return block.imageMode.length > 0 ? block.imageMode : 'aspectFit';
  }

  private handleImageTap(block: UPHtmlBlock): void {
    const href: string = block.href;
    if (href.length > 0) {
      this.props.onLinkTap?.({ href: href, innerText: block.alt, external: upParseExternalLink(href) });
      this.dispatchLink(href);
      return;
    }
    this.props.onImgTap?.({ src: block.source, index: block.imageIndex, alt: block.alt, ignore: false });
    if (upBoolean(this.props.previewImg, true) && this.props.onImgTap === undefined) {
      this.diagnostics().report('UPParse', 'previewImg', block.source, 'image preview was skipped because no onImgTap handler is bound');
    }
  }

  private handleLinkTap(block: UPHtmlBlock): void {
    const href: string = upParseBlockHref(block);
    if (href.length === 0) {
      return;
    }
    this.props.onLinkTap?.({ href: href, innerText: upParseBlockText(block), external: upParseExternalLink(href) });
    this.dispatchLink(href);
  }

  /** 上游 linkTap 的分派逻辑：锚点 / 外链 / 应用内路由。/ Upstream linkTap dispatch. */
  private dispatchLink(href: string): void {
    if (href.startsWith('#')) {
      this.scrollToAnchor(href.substring(1), 0);
      return;
    }
    if (upParseExternalLink(href)) {
      if (!upBoolean(this.props.copyLink, true)) {
        this.diagnostics().report('UPParse', 'copyLink', href, 'external link handling is disabled by copyLink');
        return;
      }
      if (this.props.openLink === undefined) {
        this.diagnostics().report('UPParse', 'openLink', href, 'external links require an openLink host callback');
        return;
      }
      let opened: boolean = false;
      try {
        opened = this.props.openLink(href);
      } catch (_error) {
        opened = false;
      }
      if (!opened) {
        this.props.onError?.({ source: 'a', src: href, message: 'openLink rejected the external link' });
      }
      return;
    }
    this.diagnostics().report('UPParse', 'href', href, 'in-app navigation is delegated to the host application');
  }

  private handleMediaTap(block: UPHtmlBlock): void {
    if (block.source.length === 0) {
      this.props.onError?.({ source: block.mediaName, src: '', message: 'media source list is empty' });
      return;
    }
    this.props.onPlay?.({ source: block.mediaName, src: block.source, poster: block.poster });
    this.diagnostics().report('UPParse', block.mediaName, block.source, 'media playback is not available in this native wrapper');
  }

  @Builder
  private runSpans(block: UPHtmlBlock) {
    ForEach(block.runs, (run: UPHtmlTextRun, index: number) => {
      Span(run.text)
        .fontSize(run.style.fontSize)
        .fontColor(this.runColor(run))
        .fontWeight(run.style.bold ? FontWeight.Bold : FontWeight.Normal)
        .fontStyle(run.style.italic ? FontStyle.Italic : FontStyle.Normal)
        .fontFamily(this.runFamily(run))
        .decoration({ type: this.runDecoration(run), color: this.runColor(run) })
        .textBackgroundStyle({ color: this.runBackground(run) })
    }, (run: UPHtmlTextRun, index: number): string => block.key + '-' + String(index))
  }

  @Builder
  private textBlock(block: UPHtmlBlock) {
    Row() {
      if (block.marker.length > 0) {
        Text(block.marker)
          .fontSize(block.runs.length > 0 ? block.runs[0].style.fontSize : this.baseFontSize())
          .fontColor(this.baseColorValue())
          .width(UP_PARSE_MARKER_WIDTH)
          .textAlign(TextAlign.Start)
      }
      Text() {
        this.runSpans(block)
      }
      .layoutWeight(1)
      .textAlign(this.textAlignOf(block.style.textAlign))
      .lineHeight(block.style.lineHeight)
      .copyOption(this.copyOptionValue())
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .onClick((): void => {
      this.handleLinkTap(block);
    })
  }

  @Builder
  private imageBlock(block: UPHtmlBlock) {
    UPImage({
      props: new UPImageProps({
        src: block.source,
        mode: this.imageMode(block),
        width: this.imageBoxWidth(block),
        height: this.imageBoxHeight(block),
        radius: block.style.borderRadius,
        lazyLoad: upBoolean(this.props.lazyLoad, false),
        showMenuByLongpress: false,
        diagnostics: this.props.diagnostics,
        onClick: (): void => {
          this.handleImageTap(block);
        }
      })
    })
  }

  @Builder
  private mediaBlock(block: UPHtmlBlock) {
    Column({ space: 8 }) {
      UPIcon({
        props: new UPIconProps({
          name: block.mediaName === 'audio' ? 'volume-fill' : 'play-circle-fill',
          size: 30,
          color: '#c0c4cc'
        })
      })
      Text(block.mediaName === 'audio' ? '音频占位' : '视频占位')
        .fontSize(13)
        .fontColor(UPColor.adaptive('#909399', 'tips-color'))
      if (block.source.length > 0) {
        Text(block.source)
          .fontSize(11)
          .fontColor(UPColor.adaptive('#c0c4cc', 'light-color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width(block.style.blockWidth > 0 ? block.style.blockWidth : UP_PARSE_MEDIA_WIDTH)
    .height(block.style.blockHeight > 0 ? block.style.blockHeight : UP_PARSE_MEDIA_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#f7f8fa')
    .borderWidth(1)
    .borderColor(UPColor.adaptive('#ebeef5', 'border-color'))
    .borderRadius(4)
    .onClick((): void => {
      this.handleMediaTap(block);
    })
  }

  @Builder
  private tableCell(cell: UPHtmlTableCell) {
    Text(upParseCellText(cell))
      .fontSize(cell.runs.length > 0 ? cell.runs[0].style.fontSize : this.baseFontSize())
      .fontColor(cell.runs.length > 0 ? this.runColor(cell.runs[0]) : this.baseColorValue())
      .fontWeight(cell.header ? FontWeight.Bold : FontWeight.Normal)
      .textAlign(this.textAlignOf(cell.style.textAlign.length > 0 ? cell.style.textAlign : (cell.header ? 'center' : 'left')))
      .width('100%')
      .padding({
        top: cell.style.paddingTop > 0 ? cell.style.paddingTop : 6,
        right: cell.style.paddingRight > 0 ? cell.style.paddingRight : 8,
        bottom: cell.style.paddingBottom > 0 ? cell.style.paddingBottom : 6,
        left: cell.style.paddingLeft > 0 ? cell.style.paddingLeft : 8
      })
      .copyOption(this.copyOptionValue())
  }

  @Builder
  private tableRow(row: UPHtmlTableRow) {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
      ForEach(row.cells, (cell: UPHtmlTableCell, index: number) => {
        Column() {
          this.tableCell(cell)
        }
        .layoutWeight(cell.colspan > 0 ? cell.colspan : 1)
        .backgroundColor(cell.style.background.length > 0
          ? UPColor.parse(cell.style.background, UP_DEFAULT_THEME, UP_PARSE_TRANSPARENT)
          : (cell.header ? '#f6f8fa' : UP_PARSE_TRANSPARENT))
        .border({
          width: cell.style.borderWidth,
          color: cell.style.borderColor.length > 0
            ? UPColor.parse(cell.style.borderColor, UP_DEFAULT_THEME, '#dfe2e5')
            : '#dfe2e5'
        })
      }, (cell: UPHtmlTableCell, index: number): string => String(index) + '-' + String(cell.colspan))
    }
    .width('100%')
  }

  @Builder
  private tableBody(block: UPHtmlBlock) {
    Column() {
      ForEach(block.rows, (row: UPHtmlTableRow, index: number) => {
        this.tableRow(row)
      }, (row: UPHtmlTableRow, index: number): string => block.key + '-row-' + String(index))
    }
    .width('100%')
  }

  @Builder
  private tableBlock(block: UPHtmlBlock) {
    if (upBoolean(this.props.scrollTable, false)) {
      Scroll() {
        this.tableBody(block)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    } else {
      this.tableBody(block)
    }
  }

  @Builder
  private blockBody(block: UPHtmlBlock) {
    if (block.kind === 'text') {
      this.textBlock(block)
    } else if (block.kind === 'image') {
      this.imageBlock(block)
    } else if (block.kind === 'divider') {
      Divider().strokeWidth(0.5).color('#ebeef5')
    } else if (block.kind === 'media') {
      this.mediaBlock(block)
    } else {
      this.tableBlock(block)
    }
  }

  @Builder
  private blockView(block: UPHtmlBlock) {
    Column() {
      this.blockBody(block)
    }
    .width('100%')
    .alignItems(this.textAlignOf(block.style.textAlign) === TextAlign.Center
      ? HorizontalAlign.Center
      : HorizontalAlign.Start)
    .margin({
      top: block.style.marginTop,
      bottom: block.style.marginBottom,
      left: this.blockIndent(block),
      right: block.style.marginRight
    })
    .padding({
      top: block.style.paddingTop,
      right: block.style.paddingRight,
      bottom: block.style.paddingBottom,
      left: block.style.paddingLeft
    })
    .backgroundColor(this.blockBackground(block))
    .borderRadius(block.style.borderRadius)
    .border({
      width: { left: block.style.borderLeftWidth, top: 0, right: 0, bottom: 0 },
      color: {
        left: block.style.borderLeftColor.length > 0
          ? UPColor.parse(block.style.borderLeftColor, UP_DEFAULT_THEME, '#dcdfe6')
          : '#dcdfe6'
      }
    })
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.recordAnchor(block.anchor, this.measure(newValue.position.y ?? 0));
    })
  }

  /** 上游 onClick 消息同时抛出 tap 与 click。/ Upstream emits both tap and click. */
  private handleRootClick(): void {
    this.props.onTap?.();
    this.props.onClick?.();
  }

  @Builder
  private body() {
    Column() {
      if (this.blocks.length > 0) {
        ForEach(this.blocks, (block: UPHtmlBlock) => {
          this.blockView(block)
        }, (block: UPHtmlBlock): string => block.key)
      } else {
        this.contentBuilder()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      if (this.viewportHeight() > 0) {
        Scroll(this.scroller) {
          this.body()
        }
        .width('100%')
        .height(this.viewportHeight())
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
      } else {
        this.body()
      }
    }
    .width(UPStyle.parse(this.props.containerStyle).width ?? '100%')
    .padding(UPStyle.parse(this.props.containerStyle).padding ?? { top: UP_PARSE_ROOT_PADDING, bottom: UP_PARSE_ROOT_PADDING })
    .backgroundColor(UPStyle.parse(this.props.containerStyle).backgroundColor ?? UP_PARSE_TRANSPARENT)
    .onClick((): void => this.handleRootClick())
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      const width: number = this.measure(newValue.width);
      if (width > 0 && Math.abs(width - this.measuredWidth) >= 1) {
        this.measuredWidth = width;
      }
      if (!this.readyReported) {
        this.readyReported = true;
        this.props.onReady?.({ width: width, height: this.measure(newValue.height) });
      }
    })
  }
}
