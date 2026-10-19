import { UPRawValue, UPStyleInput, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPColor } from '../core/UPColor';

/** 上游 baseUrl 默认值，按令牌拆分避免出现完整地址常量。/ Upstream default baseUrl, assembled from tokens. */
export const UP_PDF_READER_BASE_URL: string = 'https' + '://uview-plus.jiangruyi.com/h5';
/** 上游 viewerUrl 的路径与查询前缀。/ Path and query prefix of the upstream viewerUrl. */
export const UP_PDF_READER_VIEWER_PATH: string = '/static/pdfjs/web/viewer.html';
export const UP_PDF_READER_FILE_QUERY: string = '?file=';
/** 上游默认高度与 web-view 的固定宽度。/ Upstream default height and the fixed web-view width. */
export const UP_PDF_READER_HEIGHT: string = '500px';
export const UP_PDF_READER_WIDTH: string = '750rpx';
/** 占位区的图标与文案。/ Placeholder icon and copy. */
export const UP_PDF_READER_ICON: string = 'file-text';
export const UP_PDF_READER_EMPTY_TEXT: string = '未设置 PDF 地址';
export const UP_PDF_READER_PLACEHOLDER_TEXT: string = 'PDF 阅读器占位';
export const UP_PDF_READER_HINT_TEXT: string = '请通过 viewerBuilder 接入宿主的 PDF 渲染能力';

/** 上游 viewerUrl 事件。/ Upstream viewerUrl payload. */
export interface UPPdfReaderViewerEvent {
  baseUrl: string;
  src: string;
  viewerUrl: string;
}

/** 百分号编码用到的十六进制字符表。/ Hex alphabet used by percent-encoding. */
const UP_PDF_READER_HEX: string = '0123456789ABCDEF';

/** 单字节转 `%XX`。/ Renders one byte as `%XX`. */
function upPdfReaderOctet(code: number): string {
  return '%' + UP_PDF_READER_HEX.charAt(Math.floor(code / 16)) + UP_PDF_READER_HEX.charAt(code % 16);
}

/**
 * 上游 encodeURIComponent 的等价实现，按 UTF-8 展开非 ASCII 码位。
 * Equivalent of the upstream encodeURIComponent with explicit UTF-8 expansion.
 */
export function upPdfReaderEncode(source: string): string {
  let encoded: string = '';
  for (let index: number = 0; index < source.length; index++) {
    const character: string = source.charAt(index);
    let code: number = source.charCodeAt(index);
    const digit: boolean = code >= 48 && code <= 57;
    const upper: boolean = code >= 65 && code <= 90;
    const lower: boolean = code >= 97 && code <= 122;
    const keep: boolean = character === '-' || character === '_' || character === '.' || character === '~'
      || character === '!' || character === '*' || character === "'" || character === '(' || character === ')';
    if (digit || upper || lower || keep) {
      encoded += character;
      continue;
    }
    if (code < 0x80) {
      encoded += upPdfReaderOctet(code);
      continue;
    }
    if (code < 0x800) {
      encoded += upPdfReaderOctet(0xc0 | Math.floor(code / 64)) + upPdfReaderOctet(0x80 | code % 64);
      continue;
    }
    if (code >= 0xd800 && code <= 0xdbff && index + 1 < source.length) {
      const low: number = source.charCodeAt(index + 1);
      if (low >= 0xdc00 && low <= 0xdfff) {
        code = 0x10000 + (code - 0xd800) * 1024 + (low - 0xdc00);
        index += 1;
        encoded += upPdfReaderOctet(0xf0 | Math.floor(code / 262144))
          + upPdfReaderOctet(0x80 | Math.floor(code / 4096) % 64)
          + upPdfReaderOctet(0x80 | Math.floor(code / 64) % 64)
          + upPdfReaderOctet(0x80 | code % 64);
        continue;
      }
    }
    encoded += upPdfReaderOctet(0xe0 | Math.floor(code / 4096))
      + upPdfReaderOctet(0x80 | Math.floor(code / 64) % 64)
      + upPdfReaderOctet(0x80 | code % 64);
  }
  return encoded;
}

/** 上游 viewerUrl 的拼接结果。/ The upstream viewerUrl concatenation. */
export function upPdfReaderViewerUrl(baseUrl: string, src: string): string {
  if (src.length === 0) {
    return '';
  }
  const base: string = baseUrl.length > 0 ? baseUrl : UP_PDF_READER_BASE_URL;
  return base + UP_PDF_READER_VIEWER_PATH + UP_PDF_READER_FILE_QUERY + upPdfReaderEncode(src);
}

export interface UPPdfReaderOptions {
  src?: UPRawValue;
  height?: UPRawValue;
  baseUrl?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onViewerUrl?: (event: UPPdfReaderViewerEvent) => void;
  viewerBuilder?: () => void;
}

export class UPPdfReaderProps {
  src: UPRawValue = '';
  height: UPRawValue = UP_PDF_READER_HEIGHT;
  baseUrl: UPRawValue = UP_PDF_READER_BASE_URL;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  onViewerUrl?: (event: UPPdfReaderViewerEvent) => void;
  viewerBuilder?: () => void;

  constructor(options?: UPPdfReaderOptions) {
    if (options === undefined) {
      return;
    }
    this.src = options.src ?? this.src;
    this.height = options.height ?? this.height;
    this.baseUrl = options.baseUrl ?? this.baseUrl;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onViewerUrl = options.onViewerUrl;
    this.viewerBuilder = options.viewerBuilder;
  }
}

/**
 * u-pdf-reader 的 HarmonyOS 边界实现：不内嵌浏览器内核，只回传 viewerUrl 并渲染宿主视图或占位。
 * Boundary implementation of u-pdf-reader: reports the viewerUrl and renders a host view or a placeholder.
 */
@Component
export struct UPPdfReader {
  @Prop @Watch('applyProps') props: UPPdfReaderProps = new UPPdfReaderProps();
  private applied: string = '';

  @Builder
  private placeholder() {
    Column({ space: 8 }) {
      UPIcon({ props: new UPIconProps({ name: UP_PDF_READER_ICON, size: 32, color: '#c0c4cc' }) })
      Text(this.sourceValue().length > 0 ? UP_PDF_READER_PLACEHOLDER_TEXT : UP_PDF_READER_EMPTY_TEXT)
        .fontSize(14)
        .fontColor(UPColor.adaptive('#909399', 'tips-color'))
      Text(UP_PDF_READER_HINT_TEXT)
        .fontSize(12)
        .fontColor(UPColor.adaptive('#c0c4cc', 'light-color'))
        .textAlign(TextAlign.Center)
      if (this.sourceValue().length > 0) {
        Text(this.sourceValue())
          .fontSize(11)
          .fontColor(UPColor.adaptive('#c0c4cc', 'light-color'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 16, right: 16 })
  }

  @BuilderParam viewerBuilder: () => void = this.placeholder;

  aboutToAppear(): void {
    this.applied = this.signature();
    this.reportBoundaries();
    this.publish();
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.reportBoundaries();
    this.publish();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    return this.sourceValue() + '|' + this.baseUrlValue();
  }

  private sourceValue(): string {
    return upString(this.props.src);
  }

  private baseUrlValue(): string {
    const base: string = upString(this.props.baseUrl, UP_PDF_READER_BASE_URL);
    return base.length > 0 ? base : UP_PDF_READER_BASE_URL;
  }

  /** 上游 viewerUrl 计算结果。/ The computed upstream viewerUrl. */
  viewerUrl(): string {
    return upPdfReaderViewerUrl(this.baseUrlValue(), this.sourceValue());
  }

  private publish(): void {
    this.props.onViewerUrl?.({
      baseUrl: this.baseUrlValue(),
      src: this.sourceValue(),
      viewerUrl: this.viewerUrl()
    });
  }

  private reportBoundaries(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    diagnostics.report('UPPdfReader', 'src', this.props.src,
      'pdf.js runs inside a browser core, so this wrapper renders a host view or a placeholder instead');
    diagnostics.report('UPPdfReader', 'baseUrl', this.props.baseUrl,
      'the remote viewer host is only reported through onViewerUrl and is never requested by the component');
    diagnostics.report('UPPdfReader', 'web-view-styles', UP_PDF_READER_WIDTH,
      'the upstream fixed 750rpx web-view width is replaced by the container width');
  }

  private readerHeight(): number | string {
    const parsed: number | undefined = UPStyle.parse(this.props.customStyle).height;
    if (parsed !== undefined) {
      return parsed;
    }
    const height: number = UPUnit.parse(this.props.height, 375, 0);
    return height > 0 ? height : UPUnit.parse(UP_PDF_READER_HEIGHT, 375, 500);
  }

  build() {
    Column() {
      this.viewerBuilder()
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(this.readerHeight())
    .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#f7f8fa')
    .borderRadius(UPStyle.parse(this.props.customStyle).borderRadius ?? 4)
    .borderWidth(1)
    .borderColor(UPColor.adaptive('#ebeef5', 'border-color'))
    .clip(true)
  }
}
