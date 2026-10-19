import { UPBuilder, UPRawValue, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import {
  UPTriggerInputProps,
  UPTriggerInputStyle,
  UP_TRIGGER_BORDER_COLOR,
  UP_TRIGGER_DEFAULT_BORDER,
  UP_TRIGGER_HEIGHT,
  UP_TRIGGER_PADDING,
  UP_TRIGGER_PLACEHOLDER,
  UP_TRIGGER_PLACEHOLDER_COLOR,
  upTriggerBorderSupported,
  upTriggerBorderWidth,
  upTriggerBottomOnly,
  upTriggerInputStyle,
  upTriggerRadius,
  upTriggerTextAlign
} from '../internal/UPTriggerInput';
import { UPColor } from '../core/UPColor';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPPickerController } from '../controllers/UPPickerController';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPI18n } from '../core/UPI18n';

export interface UPPickerOption {
  text?: UPRawValue;
  value?: UPRawValue;
  name?: UPRawValue;
  id?: UPRawValue;
  label?: UPRawValue;
}
export type UPPickerItem = UPRawValue | UPPickerOption;
export interface UPPickerChangeEvent {
  value: Array<UPPickerItem>;
  index: number;
  indexs: Array<number>;
  values: Array<Array<UPPickerItem>>;
  columnIndex: number;
}
export interface UPPickerConfirmEvent {
  indexs: Array<number>;
  value: Array<UPPickerItem>;
  values: Array<Array<UPPickerItem>>;
}
export interface UPPickerOptions {
  show?: UPRawValue; columns?: Array<Array<UPPickerItem>>; modelValue?: Array<UPRawValue>;
  hasInput?: UPRawValue; inputBorder?: UPRawValue; inputProps?: UPTriggerInputProps;
  placeholder?: UPRawValue; disabled?: UPRawValue; disabledColor?: UPRawValue;
  keyName?: UPRawValue; valueName?: UPRawValue; defaultIndex?: Array<number>;
  visibleItemCount?: UPRawValue; itemHeight?: UPRawValue; loading?: UPRawValue;
  showToolbar?: UPRawValue; title?: UPRawValue; cancelText?: UPRawValue; confirmText?: UPRawValue;
  cancelColor?: UPRawValue; confirmColor?: UPRawValue; closeOnClickOverlay?: UPRawValue;
  immediateChange?: UPRawValue; popupMode?: UPRawValue; round?: UPRawValue; zIndex?: UPRawValue;
  overlayOpacity?: UPRawValue; controller?: UPPickerController; diagnostics?: UPCompatibilityDiagnostics;
  onChange?: (event: UPPickerChangeEvent) => void; onConfirm?: (event: UPPickerConfirmEvent) => void;
  onCancel?: () => void; onClose?: () => void; onShowChange?: (show: boolean) => void;
  onModelValueChange?: (values: Array<UPRawValue>) => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
  toolbarRightBuilder?: UPBuilder;
  toolbarBottomBuilder?: UPBuilder;
}

export class UPPickerProps {
  show: UPRawValue = false; columns: Array<Array<UPPickerItem>> = []; modelValue: Array<UPRawValue> = [];
  hasInput: UPRawValue = false; inputBorder: UPRawValue = UP_TRIGGER_DEFAULT_BORDER; inputProps?: UPTriggerInputProps;
  placeholder: UPRawValue = UP_TRIGGER_PLACEHOLDER; disabled: UPRawValue = false; disabledColor: UPRawValue = '';
  keyName: UPRawValue = 'text'; valueName: UPRawValue = 'value'; defaultIndex: Array<number> = [];
  visibleItemCount: UPRawValue = 5; itemHeight: UPRawValue = 44; loading: UPRawValue = false;
  showToolbar: UPRawValue = true; title: UPRawValue = ''; cancelText: UPRawValue = UPI18n.t('up.common.cancel'); confirmText: UPRawValue = UPI18n.t('up.common.confirm');
  cancelColor: UPRawValue = '#909193'; confirmColor: UPRawValue = ''; closeOnClickOverlay: UPRawValue = false;
  immediateChange: UPRawValue = true; popupMode: UPRawValue = 'bottom'; round: UPRawValue = 0; zIndex: UPRawValue = 10076;
  overlayOpacity: UPRawValue = 0.5; controller?: UPPickerController; diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  onChange?: (event: UPPickerChangeEvent) => void; onConfirm?: (event: UPPickerConfirmEvent) => void;
  onCancel?: () => void; onClose?: () => void; onShowChange?: (show: boolean) => void;
  onModelValueChange?: (values: Array<UPRawValue>) => void;
  contentBuilder?: UPBuilder;
  triggerBuilder?: UPBuilder;
  toolbarRightBuilder?: UPBuilder;
  toolbarBottomBuilder?: UPBuilder;
  constructor(options?: UPPickerOptions) {
    if (options === undefined) return;
    this.show = options.show ?? this.show; this.columns = options.columns?.map((column: Array<UPPickerItem>): Array<UPPickerItem> => column.slice()) ?? this.columns;
    this.hasInput = options.hasInput ?? this.hasInput; this.inputBorder = options.inputBorder ?? this.inputBorder;
    this.inputProps = options.inputProps; this.placeholder = options.placeholder ?? this.placeholder;
    this.disabled = options.disabled ?? this.disabled; this.disabledColor = options.disabledColor ?? this.disabledColor;
    this.modelValue = options.modelValue?.slice() ?? this.modelValue; this.keyName = options.keyName ?? this.keyName; this.valueName = options.valueName ?? this.valueName;
    this.defaultIndex = options.defaultIndex?.slice() ?? this.defaultIndex; this.visibleItemCount = options.visibleItemCount ?? this.visibleItemCount;
    this.itemHeight = options.itemHeight ?? this.itemHeight; this.loading = options.loading ?? this.loading; this.showToolbar = options.showToolbar ?? this.showToolbar;
    this.title = options.title ?? this.title; this.cancelText = options.cancelText ?? this.cancelText; this.confirmText = options.confirmText ?? this.confirmText;
    this.cancelColor = options.cancelColor ?? this.cancelColor; this.confirmColor = options.confirmColor ?? this.confirmColor;
    this.closeOnClickOverlay = options.closeOnClickOverlay ?? this.closeOnClickOverlay; this.immediateChange = options.immediateChange ?? this.immediateChange;
    this.popupMode = options.popupMode ?? this.popupMode; this.round = options.round ?? this.round; this.zIndex = options.zIndex ?? this.zIndex;
    this.overlayOpacity = options.overlayOpacity ?? this.overlayOpacity; this.controller = options.controller; this.diagnostics = options.diagnostics ?? this.diagnostics;
    this.onChange = options.onChange; this.onConfirm = options.onConfirm; this.onCancel = options.onCancel; this.onClose = options.onClose;
    this.onShowChange = options.onShowChange; this.onModelValueChange = options.onModelValueChange;
    this.contentBuilder = options.contentBuilder;
    this.triggerBuilder = options.triggerBuilder;
    this.toolbarRightBuilder = options.toolbarRightBuilder;
    this.toolbarBottomBuilder = options.toolbarBottomBuilder;
  }
}

function pickerField(item: UPPickerItem, field: string): UPRawValue {
  if (typeof item === 'string') return item;
  if (typeof item === 'number') return item;
  if (typeof item === 'boolean') return item;
  if (item === null || item === undefined) return undefined;
  if (field === 'id') return item.id;
  if (field === 'name') return item.name;
  if (field === 'label') return item.label;
  if (field === 'text') return item.text;
  return item.value;
}

@Component
export struct UPPicker {
  @Prop props: UPPickerProps = new UPPickerProps();
  @State private liveColumns: Array<Array<UPPickerItem>> = [];
  @State private liveIndexs: Array<number> = [];
  private confirmedIndexs: Array<number> = [];

  aboutToAppear(): void {
    this.reportCompatibility();
    this.liveColumns = this.props.columns.map((column: Array<UPPickerItem>): Array<UPPickerItem> => column.slice());
    this.liveIndexs = this.initialIndexs();
    this.confirmedIndexs = this.liveIndexs.slice();
    if (this.props.controller !== undefined) {
      const primitiveColumns: Array<Array<UPRawValue>> = this.liveColumns.map((column: Array<UPPickerItem>): Array<UPRawValue> =>
        column.map((item: UPPickerItem): UPRawValue => this.pickerValue(item)));
      this.props.controller.setColumns(primitiveColumns);
      this.props.controller.setIndexs(this.liveIndexs);
      this.props.controller.mount((columns: Array<Array<UPRawValue>>, indexs: Array<number>): void => {
        this.liveColumns = columns.map((column: Array<UPRawValue>): Array<UPPickerItem> => column.slice());
        this.liveIndexs = indexs.slice();
      });
    }
  }

  aboutToDisappear(): void { this.props.controller?.unmount(); }

  private display(item: UPPickerItem): string { const value: UPRawValue = pickerField(item, upString(this.props.keyName, 'text')); return value === null || value === undefined ? '' : String(value); }
  private pickerValue(item: UPPickerItem): UPRawValue { return pickerField(item, upString(this.props.valueName, 'value')); }
  private range(): Array<Array<string>> { return this.liveColumns.map((column: Array<UPPickerItem>): Array<string> => column.map((item: UPPickerItem): string => this.display(item))); }
  private selectedValues(): Array<UPPickerItem> { return this.liveColumns.map((column: Array<UPPickerItem>, index: number): UPPickerItem => column[this.liveIndexs[index] ?? 0]); }
  private modelValues(): Array<UPRawValue> { return this.selectedValues().map((item: UPPickerItem): UPRawValue => this.pickerValue(item)); }
  private initialIndexs(): Array<number> {
    return this.props.columns.map((column: Array<UPPickerItem>, columnIndex: number): number => {
      const model: UPRawValue = this.props.modelValue[columnIndex];
      if (model !== undefined) {
        const found: number = column.findIndex((item: UPPickerItem): boolean => String(this.pickerValue(item)) === String(model));
        if (found >= 0) return found;
      }
      const fallback: number = this.props.defaultIndex[columnIndex] ?? 0;
      return column.length === 0 ? 0 : Math.max(0, Math.min(column.length - 1, Math.floor(fallback)));
    });
  }
  private handlePicker(index: number | Array<number>): void {
    const next: Array<number> = typeof index === 'number' ? [index] : index.slice();
    let changedColumn: number = 0;
    for (let columnIndex = 0; columnIndex < next.length; columnIndex += 1) if (next[columnIndex] !== this.liveIndexs[columnIndex]) { changedColumn = columnIndex; break; }
    this.liveIndexs = next;
    this.props.controller?.setIndexs(next);
    this.props.onChange?.({ value: this.selectedValues(), index: next[changedColumn] ?? 0, indexs: next.slice(), values: this.liveColumns, columnIndex: changedColumn });
  }
  private cancel(): void { this.liveIndexs = this.confirmedIndexs.slice(); this.props.controller?.setIndexs(this.liveIndexs); this.props.onCancel?.(); this.props.onShowChange?.(false); }
  private confirm(): void {
    this.confirmedIndexs = this.liveIndexs.slice();
    this.props.onConfirm?.({ indexs: this.liveIndexs.slice(), value: this.selectedValues(), values: this.liveColumns });
    this.props.onModelValueChange?.(this.modelValues()); this.props.onShowChange?.(false);
  }
  private overlayClick(): void { if (upBoolean(this.props.closeOnClickOverlay, false)) { this.props.onClose?.(); this.props.onShowChange?.(false); } }
  private reportCompatibility(): void {
    if (upString(this.props.popupMode, 'bottom') !== 'bottom') this.props.diagnostics.report('UPPicker', 'popupMode', this.props.popupMode, 'only bottom popup mode is supported');
    if (!upBoolean(this.props.immediateChange, true)) this.props.diagnostics.report('UPPicker', 'immediateChange', this.props.immediateChange, 'API 12 fallback uses onChange timing');
    if (!upTriggerBorderSupported(upString(this.props.inputBorder, UP_TRIGGER_DEFAULT_BORDER))) {
      this.props.diagnostics.report('UPPicker', 'inputBorder', this.props.inputBorder,
        'inputBorder falls back to surround because only surround, bottom and none are modelled');
    }
    if (this.props.inputProps !== undefined) {
      this.props.diagnostics.report('UPPicker', 'inputProps', '',
        'inputProps only forwards the modelled trigger fields: border, placeholder, disabled, disabledColor, fontSize, color, inputAlign and shape');
    }
  }

  /** 上游 inputPropsInner。/ Mirrors the upstream inputPropsInner. */
  private triggerStyle(): UPTriggerInputStyle {
    return upTriggerInputStyle(this.props.inputBorder, this.props.placeholder,
      upBoolean(this.props.disabled, false), this.props.disabledColor, this.props.inputProps);
  }

  /** 上游 inputLabel：已确认的值以 `/` 连接。/ Mirrors the upstream inputLabel. */
  private triggerLabel(): string {
    const parts: Array<string> = [];
    for (let columnIndex = 0; columnIndex < this.liveColumns.length; columnIndex += 1) {
      const item: UPPickerItem | undefined = this.liveColumns[columnIndex][this.confirmedIndexs[columnIndex] ?? 0];
      if (item !== undefined) parts.push(this.display(item));
    }
    return parts.join('/');
  }

  /** 上游 onShowByClickInput()。/ Mirrors the upstream onShowByClickInput(). */
  private openByTrigger(): void {
    if (upBoolean(this.props.disabled, false)) return;
    this.props.onShowChange?.(true);
  }

  @Builder
  private triggerRow() {
    Row() {
      Text(this.triggerLabel().length > 0 ? this.triggerLabel() : this.triggerStyle().placeholder)
        .fontSize(this.triggerStyle().fontSize)
        .fontColor(this.triggerLabel().length > 0
          ? UPColor.parse(this.triggerStyle().color, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133'))
          : UP_TRIGGER_PLACEHOLDER_COLOR)
        .textAlign(upTriggerTextAlign(this.triggerStyle().inputAlign))
        .layoutWeight(1)
    }
    .width('100%')
    .height(UP_TRIGGER_HEIGHT)
    .padding({ left: UP_TRIGGER_PADDING, right: UP_TRIGGER_PADDING })
    .backgroundColor(this.triggerStyle().disabled ? this.triggerStyle().disabledColor : '#ffffff')
    .borderRadius(upTriggerRadius(this.triggerStyle().shape, UP_TRIGGER_HEIGHT))
    .border(upTriggerBottomOnly(this.triggerStyle().border)
      ? { width: { bottom: upTriggerBorderWidth(this.triggerStyle().border) }, color: UP_TRIGGER_BORDER_COLOR }
      : { width: upTriggerBorderWidth(this.triggerStyle().border), color: UP_TRIGGER_BORDER_COLOR })
    .onClick((): void => this.openByTrigger())
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
  private toolbarRightRegion() {
    UPSlotRegion({ contentBuilder: this.props.toolbarRightBuilder })
  }

  @Builder
  private toolbarBottomRegion() {
    UPSlotRegion({ contentBuilder: this.props.toolbarBottomBuilder })
  }

  build() {
    Column() {
      if (upBoolean(this.props.hasInput, false) && this.props.triggerBuilder !== undefined) {
        this.triggerRegion()
      } else if (upBoolean(this.props.hasInput, false) && this.props.contentBuilder !== undefined) {
        this.slotRegion()
      } else if (upBoolean(this.props.hasInput, false)) {
        this.triggerRow()
      }
      if (!upBoolean(this.props.show, false)) {
        Row().width(0).height(0)
      } else {
        Stack({ alignContent: Alignment.Bottom }) {
          Column().width('100%').height('100%').backgroundColor('#000000').opacity(Math.max(0, Math.min(1, upNumber(this.props.overlayOpacity, 0.5)))).onClick((): void => this.overlayClick())
          Column() {
            if (upBoolean(this.props.showToolbar, true)) {
              Row() {
                Text(String(this.props.cancelText)).fontColor(UPColor.parse(this.props.cancelColor, UP_DEFAULT_THEME, '#909193')).onClick((): void => this.cancel())
                Text(String(this.props.title)).fontSize(16).fontWeight(FontWeight.Medium).layoutWeight(1).textAlign(TextAlign.Center)
                if (this.props.toolbarRightBuilder !== undefined) {
                  this.toolbarRightRegion()
                } else {
                  Text(String(this.props.confirmText)).fontColor(UPColor.parse(this.props.confirmColor, UP_DEFAULT_THEME, '#2979ff')).onClick((): void => this.confirm())
                }
              }.width('100%').height(52).padding({ left: 16, right: 16 })
            }
            this.toolbarBottomRegion()
            if (upBoolean(this.props.loading, false)) {
              Row() { LoadingProgress().width(24).height(24) }.height(upNumber(this.props.itemHeight, 44) * upNumber(this.props.visibleItemCount, 5)).justifyContent(FlexAlign.Center)
            } else if (upBoolean(this.props.immediateChange, true)) {
              TextPicker({ range: this.range(), selected: this.liveIndexs }).defaultPickerItemHeight(upNumber(this.props.itemHeight, 44)).onChange((_value: string | Array<string>, index: number | Array<number>): void => this.handlePicker(index))
            } else {
              TextPicker({ range: this.range(), selected: this.liveIndexs }).defaultPickerItemHeight(upNumber(this.props.itemHeight, 44)).onChange((_value: string | Array<string>, index: number | Array<number>): void => this.handlePicker(index))
            }
          }.width('100%').backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color')).borderRadius({ topLeft: Math.max(0, upNumber(this.props.round, 0)), topRight: Math.max(0, upNumber(this.props.round, 0)) })
        }.width('100%').height('100%').zIndex(Math.max(0, upNumber(this.props.zIndex, 10076)))
      }
    }.width('100%').height(upBoolean(this.props.hasInput, false) ? 'auto' : '100%')
  }
}
