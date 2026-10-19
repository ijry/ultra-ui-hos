import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';

/** 相册单元的具名模型，替代上游任意对象。/ Named album entry instead of an arbitrary object. */
export interface UPAlbumItem {
  src?: string;
  url?: string;
  thumb?: string;
  path?: string;
  image?: string;
}

/** 预览事件载荷。/ Payload of the preview event. */
export interface UPAlbumPreviewEvent {
  urls: Array<string>;
  currentIndex: number;
}

/** keyName 白名单读取，替代上游 item[keyName]。/ Named lookup instead of a dynamic key. */
export function upAlbumSource(item: UPAlbumItem, keyName: string): string {
  if (keyName === 'url' && item.url !== undefined) {
    return item.url;
  }
  if (keyName === 'thumb' && item.thumb !== undefined) {
    return item.thumb;
  }
  if (keyName === 'path' && item.path !== undefined) {
    return item.path;
  }
  if (keyName === 'image' && item.image !== undefined) {
    return item.image;
  }
  if (keyName === 'src' && item.src !== undefined) {
    return item.src;
  }
  return item.src ?? item.url ?? item.thumb ?? item.path ?? item.image ?? '';
}

/** 字符串数组转具名模型，便于宿主沿用上游写法。/ Lifts plain URL strings into named entries. */
export function upAlbumItems(values: Array<string>): Array<UPAlbumItem> {
  return values.map((value: string): UPAlbumItem => {
    return { src: value };
  });
}

/** keyName 是否落在具名模型字段内。/ Whether keyName targets a modelled field. */
export function upAlbumKeySupported(keyName: string): boolean {
  return keyName.length === 0 || keyName === 'src' || keyName === 'url'
    || keyName === 'thumb' || keyName === 'path' || keyName === 'image';
}

/**
 * 按上游 showUrls 规则切二维数组：autoWrap 时单行，否则按 rowCount 分行且总数受 maxCount 限制。
 * Mirrors the upstream showUrls computation.
 */
export function upAlbumRows(total: number, rowCount: number, maxCount: number, autoWrap: boolean): Array<Array<number>> {
  const limit: number = Math.max(0, Math.min(total, maxCount));
  if (limit === 0) {
    return [];
  }
  const indexes: Array<number> = [];
  for (let index: number = 0; index < limit; index++) {
    indexes.push(index);
  }
  if (autoWrap) {
    return [indexes];
  }
  const columns: number = Math.max(1, rowCount);
  const rows: Array<Array<number>> = [];
  indexes.forEach((index: number): void => {
    const rowIndex: number = Math.floor(index / columns);
    if (rows[rowIndex] === undefined) {
      rows.push([]);
    }
    rows[rowIndex].push(index);
  });
  return rows;
}

export interface UPAlbumOptions {
  urls?: Array<UPAlbumItem>;
  keyName?: UPRawValue;
  singleSize?: UPRawValue;
  multipleSize?: UPRawValue;
  space?: UPRawValue;
  singleMode?: UPRawValue;
  multipleMode?: UPRawValue;
  maxCount?: UPRawValue;
  previewFullImage?: UPRawValue;
  rowCount?: UPRawValue;
  showMore?: UPRawValue;
  shape?: UPRawValue;
  radius?: UPRawValue;
  autoWrap?: UPRawValue;
  unit?: UPRawValue;
  stop?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onPreview?: (event: UPAlbumPreviewEvent) => void;
  onAlbumWidth?: (value: number) => void;
}

export class UPAlbumProps {
  urls: Array<UPAlbumItem> = [];
  keyName: UPRawValue = '';
  singleSize: UPRawValue = 180;
  multipleSize: UPRawValue = 70;
  space: UPRawValue = 6;
  singleMode: UPRawValue = 'scaleToFill';
  multipleMode: UPRawValue = 'aspectFill';
  maxCount: UPRawValue = 9;
  previewFullImage: UPRawValue = true;
  rowCount: UPRawValue = 3;
  showMore: UPRawValue = true;
  shape: UPRawValue = 'square';
  radius: UPRawValue = 0;
  autoWrap: UPRawValue = false;
  unit: UPRawValue = 'px';
  stop: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onPreview?: (event: UPAlbumPreviewEvent) => void;
  onAlbumWidth?: (value: number) => void;

  constructor(options?: UPAlbumOptions) {
    if (options === undefined) {
      return;
    }
    this.urls = options.urls ?? this.urls;
    this.keyName = options.keyName ?? this.keyName;
    this.singleSize = options.singleSize ?? this.singleSize;
    this.multipleSize = options.multipleSize ?? this.multipleSize;
    this.space = options.space ?? this.space;
    this.singleMode = options.singleMode ?? this.singleMode;
    this.multipleMode = options.multipleMode ?? this.multipleMode;
    this.maxCount = options.maxCount ?? this.maxCount;
    this.previewFullImage = options.previewFullImage ?? this.previewFullImage;
    this.rowCount = options.rowCount ?? this.rowCount;
    this.showMore = options.showMore ?? this.showMore;
    this.shape = options.shape ?? this.shape;
    this.radius = options.radius ?? this.radius;
    this.autoWrap = options.autoWrap ?? this.autoWrap;
    this.unit = options.unit ?? this.unit;
    this.stop = options.stop ?? this.stop;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onPreview = options.onPreview;
    this.onAlbumWidth = options.onAlbumWidth;
  }
}

function isLocalAlbumSource(value: string): boolean {
  return value.startsWith('resource://') || value.startsWith('file://') || value.startsWith('/') || value.startsWith('$rawfile:');
}

function albumFit(value: string): ImageFit {
  const mode: string = value.toLowerCase();
  if (mode === 'aspectfit' || mode === 'widthfix' || mode === 'heightfix') {
    return ImageFit.Contain;
  }
  if (mode === 'scaletofill') {
    return ImageFit.Fill;
  }
  return ImageFit.Cover;
}

@Component
export struct UPAlbum {
  @Prop @Watch('applyUrls') props: UPAlbumProps = new UPAlbumProps();
  private reportedWidth: number = -1;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    const keyName: string = upString(this.props.keyName, '');
    if (!upAlbumKeySupported(keyName)) {
      diagnostics.report('UPAlbum', 'keyName', this.props.keyName, 'keyName must target src/url/thumb/path/image; fallback to the first available field');
    }
    if (upBoolean(this.props.previewFullImage, true)) {
      diagnostics.report('UPAlbum', 'previewFullImage', this.props.previewFullImage, 'uni.previewImage is unavailable; handle onPreview to open a host preview page');
    }
    if (this.singleCount() === 1) {
      diagnostics.report('UPAlbum', 'singleSize', this.props.singleSize, 'uni.getImageInfo is unavailable; the single image falls back to a square singleSize box');
    }
    if (!upBoolean(this.props.stop, true)) {
      diagnostics.report('UPAlbum', 'stop', this.props.stop, 'event bubbling control is a no-op on ArkUI');
    }
    this.emitAlbumWidth();
  }

  /** urls 变更后重新回传相册宽度。/ Re-emits the album width when urls change. */
  private applyUrls(): void {
    this.emitAlbumWidth();
  }

  private emitAlbumWidth(): void {
    const value: number = this.albumWidthValue();
    if (value === this.reportedWidth) {
      return;
    }
    this.reportedWidth = value;
    const callback: ((value: number) => void) | undefined = this.props.onAlbumWidth;
    if (callback !== undefined) {
      callback(value);
    }
  }

  private singleCount(): number {
    return this.props.urls.length;
  }

  /** unit 为 rpx 时把数值按 750 设计稿换算。/ Numeric sizes follow the unit prop. */
  private sizeValue(value: UPRawValue, fallback: number): number {
    if (typeof value === 'number') {
      return upString(this.props.unit, 'px') === 'rpx'
        ? UPUnit.parse(`${value}rpx`, 375, fallback)
        : upNumber(value, fallback);
    }
    return UPUnit.parse(value, 375, fallback);
  }

  private singleSizeValue(): number {
    return this.sizeValue(this.props.singleSize, 180);
  }

  private multipleSizeValue(): number {
    return this.sizeValue(this.props.multipleSize, 70);
  }

  private spaceValue(): number {
    return this.sizeValue(this.props.space, 6);
  }

  private rowCountValue(): number {
    return Math.max(1, Math.floor(upNumber(this.props.rowCount, 3)));
  }

  private maxCountValue(): number {
    return Math.max(0, Math.floor(upNumber(this.props.maxCount, 9)));
  }

  private rows(): Array<Array<number>> {
    return upAlbumRows(this.singleCount(), this.rowCountValue(), this.maxCountValue(), upBoolean(this.props.autoWrap, false));
  }

  private rowIndexes(): Array<number> {
    const values: Array<number> = [];
    const total: number = this.rows().length;
    for (let index: number = 0; index < total; index++) {
      values.push(index);
    }
    return values;
  }

  private columnIndexes(rowIndex: number): Array<number> {
    const rows: Array<Array<number>> = this.rows();
    return rowIndex < rows.length ? rows[rowIndex] : [];
  }

  private cellWidth(): number {
    return this.singleCount() === 1 ? this.singleSizeValue() : this.multipleSizeValue();
  }

  private cellHeight(): number {
    return this.singleCount() === 1 ? this.singleSizeValue() : this.multipleSizeValue();
  }

  private cellFit(): ImageFit {
    return this.singleCount() === 1
      ? albumFit(upString(this.props.singleMode, 'scaleToFill'))
      : albumFit(upString(this.props.multipleMode, 'aspectFill'));
  }

  private cellRadius(): number {
    if (upString(this.props.shape, 'square') === 'circle') {
      return this.cellWidth() / 2;
    }
    return this.sizeValue(this.props.radius, 0);
  }

  /** 上游 albumWidth 事件的宽度计算。/ Mirrors the upstream albumWidth computation. */
  private albumWidthValue(): number {
    if (this.singleCount() === 1) {
      return this.singleSizeValue();
    }
    const rows: Array<Array<number>> = this.rows();
    if (rows.length === 0) {
      return 0;
    }
    const columns: number = rows[0].length;
    return columns * this.multipleSizeValue() + this.spaceValue() * (columns - 1);
  }

  /** 末行不带下外边距，末列不带右外边距。/ Trailing gutters are trimmed like upstream. */
  private cellMarginRight(rowIndex: number, columnIndex: number): number {
    const rows: Array<Array<number>> = this.rows();
    if (upBoolean(this.props.autoWrap, false)) {
      return this.spaceValue();
    }
    const row: Array<number> = rows[rowIndex];
    const isLastColumn: boolean = columnIndex === row[row.length - 1];
    return isLastColumn ? 0 : this.spaceValue();
  }

  private cellMarginBottom(rowIndex: number): number {
    if (upBoolean(this.props.autoWrap, false)) {
      return 0;
    }
    return rowIndex === this.rows().length - 1 ? 0 : this.spaceValue();
  }

  private cellSource(index: number): string {
    const items: Array<UPAlbumItem> = this.props.urls;
    return index < items.length ? upAlbumSource(items[index], upString(this.props.keyName, '')) : '';
  }

  /** 超出 maxCount 的数量罩层只出现在最后一格。/ The +N mask sticks to the last visible cell. */
  private showOverflow(rowIndex: number, columnIndex: number): boolean {
    if (!upBoolean(this.props.showMore, true)) {
      return false;
    }
    if (this.singleCount() <= this.maxCountValue()) {
      return false;
    }
    const rows: Array<Array<number>> = this.rows();
    if (rowIndex !== rows.length - 1) {
      return false;
    }
    const row: Array<number> = rows[rowIndex];
    return columnIndex === row[row.length - 1];
  }

  private overflowText(): string {
    return `+${this.singleCount() - this.maxCountValue()}`;
  }

  private overflowFontSize(): number {
    return Math.max(10, this.multipleSizeValue() * 0.3);
  }

  private handlePreview(index: number): void {
    const sources: Array<string> = this.props.urls.map((item: UPAlbumItem): string =>
      upAlbumSource(item, upString(this.props.keyName, '')));
    const callback: ((event: UPAlbumPreviewEvent) => void) | undefined = this.props.onPreview;
    if (callback !== undefined) {
      callback({ urls: sources, currentIndex: index });
    }
  }

  @Builder
  private cellContent(index: number) {
    Stack() {
      if (isLocalAlbumSource(this.cellSource(index))) {
        Image(this.cellSource(index))
          .width(this.cellWidth())
          .height(this.cellHeight())
          .objectFit(this.cellFit())
          .borderRadius(this.cellRadius())
      } else {
        Column() {
          Text('图片占位').fontSize(this.overflowFontSize()).fontColor(UPColor.adaptive('#909399', 'tips-color'))
        }
        .width(this.cellWidth())
        .height(this.cellHeight())
        .borderRadius(this.cellRadius())
        .backgroundColor(UPColor.adaptive('#f3f4f6', 'bg-color'))
        .justifyContent(FlexAlign.Center)
      }
    }
  }

  @Builder
  private rowContent(rowIndex: number) {
    Row() {
      ForEach(this.columnIndexes(rowIndex), (index: number) => {
        Stack() {
          this.cellContent(index)
          if (this.showOverflow(rowIndex, index)) {
            Column() {
              Text(this.overflowText()).fontSize(this.overflowFontSize()).fontColor('#ffffff')
            }
            .width(this.cellWidth())
            .height(this.cellHeight())
            .borderRadius(this.cellRadius())
            .backgroundColor('rgba(0, 0, 0, 0.4)')
            .justifyContent(FlexAlign.Center)
          }
        }
        .margin({ right: this.cellMarginRight(rowIndex, index), bottom: this.cellMarginBottom(rowIndex) })
        .onClick((): void => this.handlePreview(index))
      }, (index: number) => `${rowIndex}-${index}`)
    }
  }

  build() {
    Column() {
      if (this.singleCount() === 0) {
        Text('暂无图片').fontSize(14).fontColor(UPColor.adaptive('#909399', 'tips-color'))
      } else {
        ForEach(this.rowIndexes(), (rowIndex: number) => {
          this.rowContent(rowIndex)
        }, (rowIndex: number) => `row-${rowIndex}`)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
