import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPColor } from '../core/UPColor';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPUnit } from '../core/UPUnit';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPSelectOption { id?: UPRawValue; name?: UPRawValue; label?: UPRawValue; value?: UPRawValue; disabled?: UPRawValue; }
export interface UPSelectSelectEvent { option: UPSelectOption; current: UPRawValue; }
/** 上游 optionItem 插槽作用域。/ Scope handed to the upstream optionItem slot. */
export interface UPSelectOptionSlot { item: UPSelectOption; index: number; }
export interface UPSelectOptions {
  options?: Array<UPSelectOption>; current?: UPRawValue; keyName?: UPRawValue; labelName?: UPRawValue; label?: UPRawValue;
  showOptionsLabel?: UPRawValue; disabled?: UPRawValue; border?: UPRawValue; optionsWidth?: UPRawValue; maxHeight?: UPRawValue;
  overlay?: UPRawValue; overlayOpacity?: UPRawValue; overlayStyle?: UPStyleInput; duration?: UPRawValue; zIndex?: UPRawValue; itemColor?: UPRawValue;
  iconColor?: UPRawValue; iconSize?: UPRawValue; diagnostics?: UPCompatibilityDiagnostics;
  onSelect?: (event: UPSelectSelectEvent) => void; onCurrentChange?: (current: UPRawValue) => void;
  textBuilder?: UPBuilder;
  iconBuilder?: UPBuilder;
  optionsBuilder?: UPBuilder;
}

export class UPSelectProps {
  options: Array<UPSelectOption> = []; current: UPRawValue = ''; keyName: UPRawValue = 'id'; labelName: UPRawValue = 'name'; label: UPRawValue = '选项';
  showOptionsLabel: UPRawValue = false; disabled: UPRawValue = false; border: UPRawValue = false; optionsWidth: UPRawValue = ''; maxHeight: UPRawValue = '90vh';
  overlay: UPRawValue = true; overlayOpacity: UPRawValue = 0.01; overlayStyle: UPStyleInput = undefined; duration: UPRawValue = 300; zIndex: UPRawValue = 11000;
  itemColor: UPRawValue = ''; iconColor: UPRawValue = ''; iconSize: UPRawValue = '13px'; diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;
  onSelect?: (event: UPSelectSelectEvent) => void; onCurrentChange?: (current: UPRawValue) => void;
  textBuilder?: UPBuilder;
  iconBuilder?: UPBuilder;
  optionsBuilder?: UPBuilder;
  constructor(options?: UPSelectOptions) {
    if (options === undefined) return;
    this.options = options.options?.slice() ?? this.options; this.current = options.current ?? this.current; this.keyName = options.keyName ?? this.keyName;
    this.labelName = options.labelName ?? this.labelName; this.label = options.label ?? this.label; this.showOptionsLabel = options.showOptionsLabel ?? this.showOptionsLabel;
    this.disabled = options.disabled ?? this.disabled; this.border = options.border ?? this.border; this.optionsWidth = options.optionsWidth ?? this.optionsWidth;
    this.maxHeight = options.maxHeight ?? this.maxHeight; this.overlay = options.overlay ?? this.overlay; this.overlayOpacity = options.overlayOpacity ?? this.overlayOpacity;
    this.overlayStyle = options.overlayStyle;
    this.duration = options.duration ?? this.duration; this.zIndex = options.zIndex ?? this.zIndex; this.itemColor = options.itemColor ?? this.itemColor;
    this.iconColor = options.iconColor ?? this.iconColor; this.iconSize = options.iconSize ?? this.iconSize; this.diagnostics = options.diagnostics ?? this.diagnostics;
    this.onSelect = options.onSelect; this.onCurrentChange = options.onCurrentChange;
    this.textBuilder = options.textBuilder;
    this.iconBuilder = options.iconBuilder;
    this.optionsBuilder = options.optionsBuilder;
  }
}

function selectField(option: UPSelectOption, field: string): UPRawValue {
  if (field === 'value') return option.value;
  if (field === 'label') return option.label;
  if (field === 'name') return option.name;
  return option.id;
}

@Component
export struct UPSelect {
  @Prop props: UPSelectProps = new UPSelectProps();
  @State private open: boolean = false;

  private optionKey(option: UPSelectOption): UPRawValue { return selectField(option, upString(this.props.keyName, 'id')); }
  private text(option: UPSelectOption): string { const value: UPRawValue = selectField(option, upString(this.props.labelName, 'name')); return value === null || value === undefined ? '' : String(value); }
  private selectedText(): string { const option: UPSelectOption | undefined = this.props.options.find((item: UPSelectOption): boolean => String(this.optionKey(item)) === String(this.props.current)); return option === undefined ? String(this.props.label) : this.text(option); }
  private widthValue(): number | string { const width: number = UPUnit.parse(this.props.optionsWidth, 375, 0); return width > 0 ? width : '100%'; }
  private maxHeightValue(): number {
    const source: string = upString(this.props.maxHeight, '90vh').trim().toLowerCase();
    if (source.endsWith('vh')) { const ratio: number = Number(source.slice(0, -2)); return Number.isFinite(ratio) ? Math.max(80, 640 * ratio / 100) : 576; }
    return Math.max(80, UPUnit.parse(this.props.maxHeight, 375, 576));
  }
  @Builder
  private defaultOptionItem(slot: UPSelectOptionSlot) {
    Text(this.text(slot.item)).width('100%').height(44).padding({ left: 12, right: 12 }).fontSize(14)
      .fontColor(String(this.optionKey(slot.item)) === String(this.props.current) ? '#2979ff' : UPColor.parse(this.props.itemColor, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133')))
      .opacity(upBoolean(slot.item.disabled, false) ? 0.4 : 1)
  }

  @BuilderParam optionItemBuilder: (slot: UPSelectOptionSlot) => void = this.defaultOptionItem;

  private optionSlot(option: UPSelectOption, index: number): UPSelectOptionSlot {
    return { item: option, index };
  }

  private choose(option: UPSelectOption): void {
    if (upBoolean(option.disabled, false)) return;
    const current: UPRawValue = this.optionKey(option); this.props.onSelect?.({ option, current }); this.props.onCurrentChange?.(current); this.open = false;
  }

  @Builder
  private textRegion() {
    UPSlotRegion({ contentBuilder: this.props.textBuilder })
  }

  @Builder
  private iconRegion() {
    UPSlotRegion({ contentBuilder: this.props.iconBuilder })
  }

  @Builder
  private optionsRegion() {
    UPSlotRegion({ contentBuilder: this.props.optionsBuilder })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.open && upBoolean(this.props.overlay, true)) {
        Column().width('100%').height('100%')
          .backgroundColor(UPStyle.parse(this.props.overlayStyle).backgroundColor ?? '#000000')
          .opacity(UPStyle.parse(this.props.overlayStyle).opacity ?? Math.max(0, Math.min(1, upNumber(this.props.overlayOpacity, 0.01))))
          .zIndex(upNumber(this.props.zIndex, 11000)).onClick((): void => { this.open = false; })
      }
      Column() {
        Row({ space: 8 }) {
          if (upBoolean(this.props.showOptionsLabel, false)) Text(String(this.props.label)).fontSize(14).fontColor(UPColor.adaptive('#909399', 'tips-color'))
          if (this.props.textBuilder !== undefined) {
            this.textRegion()
          } else {
            Text(this.selectedText()).fontSize(15).fontColor(UPColor.parse(this.props.itemColor, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133'))).layoutWeight(1)
          }
          if (this.props.iconBuilder !== undefined) {
            this.iconRegion()
          } else {
            Text(this.open ? '⌃' : '⌄').fontSize(UPUnit.parse(this.props.iconSize, 375, 13)).fontColor(UPColor.parse(this.props.iconColor, UP_DEFAULT_THEME, UPColor.neutral('content', '#606266')))
          }
        }.width('100%').height(44).padding({ left: 12, right: 12 }).border(upBoolean(this.props.border, false) ? { width: 1, color: '#dcdfe6', radius: 4 } : { width: 0 })
          .opacity(upBoolean(this.props.disabled, false) ? 0.45 : 1).onClick((): void => { if (!upBoolean(this.props.disabled, false)) this.open = !this.open; })
        if (this.open) {
          Scroll() {
            Column() {
              if (this.props.optionsBuilder !== undefined) {
                this.optionsRegion()
              }
              ForEach(this.props.options, (option: UPSelectOption, index: number) => {
                Row() {
                  this.optionItemBuilder(this.optionSlot(option, index))
                }.width('100%').onClick((): void => this.choose(option))
              }, (option: UPSelectOption): string => String(this.optionKey(option)))
            }.width('100%')
          }.width(this.widthValue()).constraintSize({ maxHeight: this.maxHeightValue() }).backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color')).borderRadius(4).shadow({ radius: 8, color: '#22000000', offsetY: 3 })
        }
      }.width('100%').zIndex(upNumber(this.props.zIndex, 11000) + 1)
    }.width('100%')
  }
}
