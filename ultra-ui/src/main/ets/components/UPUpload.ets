import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPColor } from '../core/UPColor';

/** 上游 videoPreviewObjectFit 的取值。/ Accepted videoPreviewObjectFit values. */
export const UP_UPLOAD_OBJECT_FIT_MODES: Array<string> = ['contain', 'fill', 'cover'];

/** 上游 extension 的后缀白名单判定：空数组表示不限制。/ Extension whitelist test. */
export function upUploadExtensionAllowed(name: string, extension: Array<string>): boolean {
  if (extension.length === 0) {
    return true;
  }
  const lower: string = name.toLowerCase();
  for (const suffix of extension) {
    const normalized: string = suffix.trim().toLowerCase();
    if (normalized.length > 0 && lower.endsWith(normalized)) {
      return true;
    }
  }
  return false;
}

export interface UPUploadFile { name: string; uri: string; status?: string; message?: string; }
export interface UPUploadChooseEvent { file: UPUploadFile; files: Array<UPUploadFile>; }
/** 上游 beforeRead / afterRead / oversize / clickPreview 的共享载荷。/ Shared read payload. */
export interface UPUploadReadEvent { file: UPUploadFile; index: number; files: Array<UPUploadFile>; }
/** 上游 error 事件。/ Upstream error payload. */
export interface UPUploadErrorEvent { file: UPUploadFile; reason: UPUploadFailureReason; message: string; }
/** 上传失败原因。/ Reason an entry was rejected. */
export type UPUploadFailureReason = 'extension' | 'oversize' | 'before-read' | 'max-count';
export interface UPUploadDeleteEvent { file: UPUploadFile; index: number; files: Array<UPUploadFile>; }
export interface UPUploadRetryEvent { file: UPUploadFile; index: number; }
export interface UPUploadOptions {
  files?: Array<UPUploadFile>; maxCount?: UPRawValue; disabled?: UPRawValue; multiple?: boolean; localOnly?: boolean;
  extension?: Array<string>; videoPreviewObjectFit?: UPRawValue; diagnostics?: UPCompatibilityDiagnostics; customStyle?: UPStyleInput;
  onChoose?: (event: UPUploadChooseEvent) => void; onDelete?: (event: UPUploadDeleteEvent) => void; onRetry?: (event: UPUploadRetryEvent) => void;
  onBeforeRead?: (event: UPUploadReadEvent) => boolean; onAfterRead?: (event: UPUploadReadEvent) => void;
  onOversize?: (event: UPUploadReadEvent) => void; onError?: (event: UPUploadErrorEvent) => void;
  onClickPreview?: (event: UPUploadReadEvent) => void; onAfterAutoUpload?: (event: UPUploadReadEvent) => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
  playIconBuilder?: UPBuilder;
  successBuilder?: UPBuilder;
}
export class UPUploadProps {
  files: Array<UPUploadFile> = []; maxCount: UPRawValue = 9; disabled: UPRawValue = false; multiple: boolean = true; localOnly: boolean = true;
  extension: Array<string> = []; videoPreviewObjectFit: UPRawValue = 'contain'; diagnostics?: UPCompatibilityDiagnostics;
  customStyle: UPStyleInput = undefined; onChoose?: (event: UPUploadChooseEvent) => void;
  onDelete?: (event: UPUploadDeleteEvent) => void; onRetry?: (event: UPUploadRetryEvent) => void;
  onBeforeRead?: (event: UPUploadReadEvent) => boolean; onAfterRead?: (event: UPUploadReadEvent) => void;
  onOversize?: (event: UPUploadReadEvent) => void; onError?: (event: UPUploadErrorEvent) => void;
  onClickPreview?: (event: UPUploadReadEvent) => void; onAfterAutoUpload?: (event: UPUploadReadEvent) => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
  playIconBuilder?: UPBuilder;
  successBuilder?: UPBuilder;
  constructor(options?: UPUploadOptions) {
    if (options === undefined) return;
    this.files = options.files ?? this.files; this.maxCount = options.maxCount ?? this.maxCount; this.disabled = options.disabled ?? this.disabled;
    this.multiple = options.multiple ?? this.multiple; this.localOnly = options.localOnly ?? this.localOnly;
    this.extension = options.extension ?? this.extension;
    this.videoPreviewObjectFit = options.videoPreviewObjectFit ?? this.videoPreviewObjectFit;
    this.diagnostics = options.diagnostics; this.customStyle = options.customStyle;
    this.onChoose = options.onChoose; this.onDelete = options.onDelete; this.onRetry = options.onRetry;
    this.onBeforeRead = options.onBeforeRead; this.onAfterRead = options.onAfterRead;
    this.onOversize = options.onOversize; this.onError = options.onError;
    this.onClickPreview = options.onClickPreview; this.onAfterAutoUpload = options.onAfterAutoUpload;
    this.contentBuilder = options.contentBuilder;
    this.triggerBuilder = options.triggerBuilder;
    this.playIconBuilder = options.playIconBuilder;
    this.successBuilder = options.successBuilder;
  }
}

@Component
export struct UPUpload {
  @Prop props: UPUploadProps = new UPUploadProps();
  @State private currentFiles: Array<UPUploadFile> = [];
  aboutToAppear(): void {
    this.currentFiles = this.props.files.slice();
    this.reportCompatibility();
  }
  private diagnostics(): UPCompatibilityDiagnostics { return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS; }
  private reportCompatibility(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    if (this.props.extension.length > 0) {
      diagnostics.report('UPUpload', 'extension', this.props.extension.join(','),
        'the extension whitelist is only enforced on host-provided names because the component never opens a file picker');
    }
    if (!UP_UPLOAD_OBJECT_FIT_MODES.includes(upString(this.props.videoPreviewObjectFit, 'contain'))) {
      diagnostics.report('UPUpload', 'videoPreviewObjectFit', this.props.videoPreviewObjectFit,
        'videoPreviewObjectFit falls back to contain because only contain, fill and cover are modelled');
    }
    diagnostics.report('UPUpload', 'videoPreviewObjectFit', upString(this.props.videoPreviewObjectFit, 'contain'),
      'video previews are not rendered by this local placeholder, so the fit mode is only forwarded to the host');
  }
  private canChoose(): boolean { return !upBoolean(this.props.disabled, false) && this.currentFiles.length < Math.max(0, upNumber(this.props.maxCount, 9)); }
  /** 宿主传入文件名时按 extension 白名单过滤。/ Filters a host-provided name through the extension whitelist. */
  accept(name: string): boolean { return upUploadExtensionAllowed(name, this.props.extension); }
  /**
   * 上游读取流程：beforeRead 放行后走 afterRead，超限走 oversize，被拒走 error。
   * Upstream read pipeline: beforeRead gates afterRead, oversize and error handle rejections.
   */
  private choosePlaceholder(): void {
    const index: number = this.currentFiles.length;
    const name: string = '本地文件 ' + String(index + 1);
    const file: UPUploadFile = { name, uri: 'local://placeholder-' + String(index + 1), status: 'ready' };
    if (!this.canChoose()) {
      this.props.onOversize?.({ file, index, files: this.currentFiles.slice() });
      this.props.onError?.({ file, reason: 'max-count', message: '已达到 maxCount 上限' });
      return;
    }
    if (!this.accept(name)) {
      this.diagnostics().report('UPUpload', 'extension', name,
        'the placeholder name does not match the extension whitelist, so the entry is skipped');
      this.props.onError?.({ file, reason: 'extension', message: '文件后缀不在 extension 白名单内' });
      return;
    }
    const request: UPUploadReadEvent = { file, index, files: this.currentFiles.slice() };
    const gate: ((event: UPUploadReadEvent) => boolean) | undefined = this.props.onBeforeRead;
    if (gate !== undefined && !gate(request)) {
      this.props.onError?.({ file, reason: 'before-read', message: 'beforeRead 拒绝了该文件' });
      return;
    }
    this.currentFiles = [...this.currentFiles, file];
    const accepted: UPUploadReadEvent = { file, index, files: this.currentFiles.slice() };
    this.props.onChoose?.({ file, files: this.currentFiles.slice() });
    this.props.onAfterRead?.(accepted);
    this.props.onAfterAutoUpload?.(accepted);
  }

  /** 上游 clickPreview：点击已选文件时触发。/ Upstream clickPreview on tapping an entry. */
  private previewFile(index: number): void {
    if (index < 0 || index >= this.currentFiles.length) return;
    this.props.onClickPreview?.({
      file: this.currentFiles[index], index, files: this.currentFiles.slice()
    });
  }
  private remove(index: number): void {
    if (index < 0 || index >= this.currentFiles.length) return;
    const file: UPUploadFile = this.currentFiles[index]; this.currentFiles = this.currentFiles.filter((_item: UPUploadFile, itemIndex: number): boolean => itemIndex !== index);
    this.props.onDelete?.({ file, index, files: this.currentFiles.slice() });
  }
  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  @Builder
  private triggerRegion() {
    UPSlotRegion({ contentBuilder: this.props.triggerBuilder })
  }

  @Builder
  private playIconRegion() {
    UPSlotRegion({ contentBuilder: this.props.playIconBuilder })
  }

  @Builder
  private successRegion() {
    UPSlotRegion({ contentBuilder: this.props.successBuilder })
  }

  build() {
    Row({ space: 8 }) {
      ForEach(this.currentFiles, (file: UPUploadFile, index: number) => {
        Column({ space: 3 }) { this.playIconRegion(); if (file.status === 'success') { this.successRegion() } Text('文件').fontSize(18); Text(file.name).fontSize(10).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis });
          Text('删除').fontSize(10).fontColor('#fa3534').onClick((): void => this.remove(index)) }.width(72).height(72).justifyContent(FlexAlign.Center).backgroundColor('#f5f7fa').borderRadius(5)
          .onClick((): void => this.previewFile(index))
      })
      if (this.canChoose() && this.props.triggerBuilder !== undefined) {
        Column() { this.triggerRegion() }.onClick((): void => this.choosePlaceholder())
      } else if (this.canChoose() && this.props.contentBuilder !== undefined) {
        Column() { this.slotRegion() }.onClick((): void => this.choosePlaceholder())
      } else if (this.canChoose()) {
        Column() { Text('+').fontSize(26).fontColor(UPColor.adaptive('#909399', 'tips-color')); Text('本地选择').fontSize(10).fontColor(UPColor.adaptive('#909399', 'tips-color')) }.width(72).height(72).justifyContent(FlexAlign.Center).border({ width: 1, color: '#dcdfe6', style: BorderStyle.Dashed }).borderRadius(5).onClick((): void => this.choosePlaceholder())
      }
    }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
