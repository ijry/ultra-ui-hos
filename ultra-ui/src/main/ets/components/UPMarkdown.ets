import { UPRawValue, UPStyleInput, UPStyleObject, upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle, UPStyleResult } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPHtmlDeclaration } from '../internal/UPHtmlParser';
import {
  UP_MARKDOWN_BASE_FONT_SIZE,
  UP_MARKDOWN_ROOT_PADDING,
  UP_MARKDOWN_THEMES,
  upMarkdownApplyTheme,
  upMarkdownBackground,
  upMarkdownBaseColor,
  upMarkdownDarkTheme,
  upMarkdownLinkColor,
  upMarkdownTagStyle,
  upMarkdownThemeSupported,
  upMarkdownToHtml
} from '../internal/UPMarkdownSource';
import { UPParseController } from '../controllers/UPParseController';
import {
  UPParse,
  UPParseErrorEvent,
  UPParseImageTapEvent,
  UPParseLinkTapEvent,
  UPParseMediaEvent,
  UPParseProps,
  UPParseReadyEvent
} from './UPParse';

export interface UPMarkdownOptions {
  content?: UPRawValue;
  previewImg?: UPRawValue;
  copyLink?: UPRawValue;
  domain?: UPRawValue;
  showLineNumber?: UPRawValue;
  theme?: UPRawValue;
  selectable?: UPRawValue;
  baseFontSize?: UPRawValue;
  viewportWidth?: UPRawValue;
  scrollTable?: UPRawValue;
  useAnchor?: UPRawValue;
  customStyle?: UPStyleInput;
  controller?: UPParseController;
  diagnostics?: UPCompatibilityDiagnostics;
  openLink?: (href: string) => boolean;
  onLoad?: () => void;
  onReady?: (event: UPParseReadyEvent) => void;
  onImgTap?: (event: UPParseImageTapEvent) => void;
  onLinkTap?: (event: UPParseLinkTapEvent) => void;
  onPlay?: (event: UPParseMediaEvent) => void;
  onError?: (event: UPParseErrorEvent) => void;
}

export class UPMarkdownProps {
  content: UPRawValue = '';
  previewImg: UPRawValue = true;
  copyLink: UPRawValue = true;
  domain: UPRawValue = '';
  showLineNumber: UPRawValue = false;
  theme: UPRawValue = 'light';
  selectable: UPRawValue = false;
  baseFontSize: UPRawValue = UP_MARKDOWN_BASE_FONT_SIZE;
  viewportWidth: UPRawValue = 375;
  scrollTable: UPRawValue = false;
  useAnchor: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  controller?: UPParseController;
  diagnostics?: UPCompatibilityDiagnostics;
  openLink?: (href: string) => boolean;
  onLoad?: () => void;
  onReady?: (event: UPParseReadyEvent) => void;
  onImgTap?: (event: UPParseImageTapEvent) => void;
  onLinkTap?: (event: UPParseLinkTapEvent) => void;
  onPlay?: (event: UPParseMediaEvent) => void;
  onError?: (event: UPParseErrorEvent) => void;

  constructor(options?: UPMarkdownOptions) {
    if (options === undefined) {
      return;
    }
    this.content = options.content ?? this.content;
    this.previewImg = options.previewImg ?? this.previewImg;
    this.copyLink = options.copyLink ?? this.copyLink;
    this.domain = options.domain ?? this.domain;
    this.showLineNumber = options.showLineNumber ?? this.showLineNumber;
    this.theme = options.theme ?? this.theme;
    this.selectable = options.selectable ?? this.selectable;
    this.baseFontSize = options.baseFontSize ?? this.baseFontSize;
    this.viewportWidth = options.viewportWidth ?? this.viewportWidth;
    this.scrollTable = options.scrollTable ?? this.scrollTable;
    this.useAnchor = options.useAnchor ?? this.useAnchor;
    this.customStyle = options.customStyle;
    this.controller = options.controller;
    this.diagnostics = options.diagnostics;
    this.openLink = options.openLink;
    this.onLoad = options.onLoad;
    this.onReady = options.onReady;
    this.onImgTap = options.onImgTap;
    this.onLinkTap = options.onLinkTap;
    this.onPlay = options.onPlay;
    this.onError = options.onError;
  }
}

/**
 * u-markdown 的 HarmonyOS 原生实现：内置 markdown 词法转 html 后交给 UPParse 渲染。
 * Native u-markdown: converts markdown to html in ArkTS and renders it through UPParse.
 */
@Component
export struct UPMarkdown {
  @Prop @Watch('applyProps') props: UPMarkdownProps = new UPMarkdownProps();
  @State private html: string = '';
  private applied: string = '';

  aboutToAppear(): void {
    this.applied = this.signature();
    this.html = this.convert();
    this.reportBoundaries();
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.html = this.convert();
    this.reportBoundaries();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    return upString(this.props.content) + '|' + String(upBoolean(this.props.showLineNumber, false))
      + '|' + this.themeName();
  }

  private themeName(): string {
    const theme: string = upString(this.props.theme, 'light');
    return theme.length > 0 ? theme : 'light';
  }

  private darkTheme(): boolean {
    return upMarkdownDarkTheme(this.themeName());
  }

  /** 上游 parseMarkdown()：marked 解析 + handleCodeBlock + applyTheme。/ Upstream parseMarkdown(). */
  private convert(): string {
    const content: string = upString(this.props.content);
    if (content.length === 0) {
      return '';
    }
    return upMarkdownApplyTheme(upMarkdownToHtml(content, upBoolean(this.props.showLineNumber, false)));
  }

  /** 转换后的 html，便于宿主复用同一份结果。/ Converted html for host reuse. */
  markup(): string {
    return this.html;
  }

  private reportBoundaries(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    if (!upMarkdownThemeSupported(this.themeName())) {
      diagnostics.report('UPMarkdown', 'theme', this.props.theme,
        'only the upstream light and dark themes are modelled: ' + UP_MARKDOWN_THEMES.join(', '));
    }
    diagnostics.report('UPMarkdown', 'content', '',
      'markdown is converted by a built-in ArkTS lexer instead of the upstream marked bundle');
    diagnostics.report('UPMarkdown', 'applyTheme', '',
      'upstream applyTheme returns the html unchanged, so the theme only switches injected tag styles');
    if (upBoolean(this.props.showLineNumber, false)) {
      diagnostics.report('UPMarkdown', 'showLineNumber', this.props.showLineNumber,
        'line numbers are rendered as an inline gutter because a separate flex column is not available inside a text block');
    }
  }

  private baseFontSizeValue(): number {
    return UPUnit.parse(this.props.baseFontSize, 375, UP_MARKDOWN_BASE_FONT_SIZE);
  }

  private rootPadding(): Padding {
    const style: UPStyleResult = UPStyle.parse(this.props.customStyle);
    if (style.padding !== undefined) {
      return {
        top: style.padding.top,
        right: style.padding.right,
        bottom: style.padding.bottom,
        left: style.padding.left
      };
    }
    const edge: number = UP_MARKDOWN_ROOT_PADDING;
    return { top: edge, right: edge, bottom: edge, left: edge };
  }

  private rootBackground(): string {
    const parsed: string | undefined = UPStyle.parse(this.props.customStyle).backgroundColor;
    return parsed ?? upMarkdownBackground(this.darkTheme());
  }

  private baseColorValue(): string {
    const parsed: string | undefined = UPStyle.parse(this.props.customStyle).color;
    return parsed ?? UPColor.parse(upMarkdownBaseColor(this.darkTheme()), UP_DEFAULT_THEME,
      upMarkdownBaseColor(this.darkTheme()));
  }

  private tagStyleList(): Array<UPHtmlDeclaration> {
    return upMarkdownTagStyle(this.darkTheme());
  }

  /** customStyle 的高度下推给内嵌 UPParse，用于滚动与锚点。/ Forwards the height to the embedded UPParse. */
  private parseContainerStyle(): UPStyleObject | undefined {
    const height: number | undefined = UPStyle.parse(this.props.customStyle).height;
    if (height === undefined || height <= 0) {
      return undefined;
    }
    return { height: height };
  }

  private parseProps(): UPParseProps {
    return new UPParseProps({
      content: this.html,
      containerStyle: this.parseContainerStyle(),
      previewImg: this.props.previewImg,
      copyLink: this.props.copyLink,
      domain: this.props.domain,
      selectable: this.props.selectable,
      scrollTable: this.props.scrollTable,
      useAnchor: this.props.useAnchor,
      setTitle: false,
      tagStyle: this.tagStyleList(),
      baseColor: this.baseColorValue(),
      linkColor: upMarkdownLinkColor(this.darkTheme()),
      baseFontSize: this.baseFontSizeValue(),
      viewportWidth: this.props.viewportWidth,
      controller: this.props.controller,
      diagnostics: this.props.diagnostics,
      openLink: this.props.openLink,
      onLoad: this.props.onLoad,
      onReady: this.props.onReady,
      onImgTap: this.props.onImgTap,
      onLinkTap: this.props.onLinkTap,
      onPlay: this.props.onPlay,
      onError: this.props.onError
    });
  }

  build() {
    Column() {
      UPParse({ props: this.parseProps() })
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .padding(this.rootPadding())
    .backgroundColor(this.rootBackground())
    .alignItems(HorizontalAlign.Start)
  }
}
