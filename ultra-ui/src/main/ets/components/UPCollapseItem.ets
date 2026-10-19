import { UPRawValue, UPStyleInput, UPBuilder, upBoolean, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCollapseContext } from '../internal/UPInteractionContexts';
import { UPSlotRegion } from '../internal/UPSlotRegion';
import { UPColor } from '../core/UPColor';

export interface UPCollapseItemClickEvent { name: UPRawValue; open: boolean; }
export interface UPCollapseItemOptions {
  title?: UPRawValue; titleStyle?: UPStyleInput; value?: UPRawValue; label?: UPRawValue;
  disabled?: UPRawValue; isLink?: UPRawValue; clickable?: UPRawValue; border?: UPRawValue;
  align?: UPRawValue; name?: UPRawValue; icon?: UPRawValue; duration?: UPRawValue;
  showRight?: UPRawValue; iconStyle?: UPStyleInput; rightIconStyle?: UPStyleInput;
  cellCustomStyle?: UPStyleInput; cellCustomClass?: UPRawValue; customStyle?: UPStyleInput;
  isOpen?: UPRawValue; open?: UPRawValue; onClick?: (event: UPCollapseItemClickEvent) => void;
  contentBuilder?: UPBuilder;
  iconBuilder?: UPBuilder;
  titleBuilder?: UPBuilder;
  valueBuilder?: UPBuilder;
  rightIconBuilder?: UPBuilder;
}
export class UPCollapseItemProps {
  title: UPRawValue = ''; titleStyle: UPStyleInput = undefined; value: UPRawValue = '';
  label: UPRawValue = ''; disabled: UPRawValue = false; isLink: UPRawValue = false;
  clickable: UPRawValue = true; border: UPRawValue = true; align: UPRawValue = 'left';
  name: UPRawValue = undefined; icon: UPRawValue = ''; duration: UPRawValue = 300;
  showRight: UPRawValue = true; iconStyle: UPStyleInput = undefined; rightIconStyle: UPStyleInput = undefined;
  cellCustomStyle: UPStyleInput = undefined; cellCustomClass: UPRawValue = '';
  customStyle: UPStyleInput = undefined; isOpen: UPRawValue = false; open: UPRawValue = undefined;
  onClick?: (event: UPCollapseItemClickEvent) => void; contentBuilder?: UPBuilder;
  iconBuilder?: UPBuilder;
  titleBuilder?: UPBuilder;
  valueBuilder?: UPBuilder;
  rightIconBuilder?: UPBuilder;
  constructor(options?: UPCollapseItemOptions) {
    if (options === undefined) return;
    this.title = options.title ?? this.title; this.titleStyle = options.titleStyle; this.value = options.value ?? this.value;
    this.label = options.label ?? this.label; this.disabled = options.disabled ?? this.disabled; this.isLink = options.isLink ?? this.isLink;
    this.clickable = options.clickable ?? this.clickable; this.border = options.border ?? this.border; this.align = options.align ?? this.align;
    this.name = options.name ?? this.name; this.icon = options.icon ?? this.icon; this.duration = options.duration ?? this.duration;
    this.showRight = options.showRight ?? this.showRight; this.iconStyle = options.iconStyle; this.rightIconStyle = options.rightIconStyle;
    this.cellCustomStyle = options.cellCustomStyle; this.cellCustomClass = options.cellCustomClass ?? this.cellCustomClass;
    this.customStyle = options.customStyle; this.isOpen = options.isOpen ?? this.isOpen; this.open = options.open ?? this.open;
    this.onClick = options.onClick; this.contentBuilder = options.contentBuilder;
    this.iconBuilder = options.iconBuilder;
    this.titleBuilder = options.titleBuilder;
    this.valueBuilder = options.valueBuilder;
    this.rightIconBuilder = options.rightIconBuilder;
  }
}
@Component
export struct UPCollapseItem {
  @Prop props: UPCollapseItemProps = new UPCollapseItemProps();
  @Consume('UPCollapseContext') collapseContext: UPCollapseContext = new UPCollapseContext();
  private resolvedName: UPRawValue = '';
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  aboutToAppear(): void { this.resolvedName = this.collapseContext.itemName(this.props.name); }
  private text(value: UPRawValue): string { return value === null || value === undefined ? '' : String(value); }
  private opened(): boolean {
    if (this.collapseContext.grouped) return this.collapseContext.isOpen(this.resolvedName);
    return this.props.open !== null && this.props.open !== undefined ? upBoolean(this.props.open, false) : upBoolean(this.props.isOpen, false);
  }
  private click(): void {
    if (upBoolean(this.props.disabled, false) || !upBoolean(this.props.clickable, true)) return;
    this.collapseContext.requestToggle(this.resolvedName, this.props.disabled, this.props.clickable);
    this.props.onClick?.({ name: this.resolvedName, open: !this.opened() });
  }
  @Builder
  private iconRegion() {
    UPSlotRegion({ contentBuilder: this.props.iconBuilder })
  }

  @Builder
  private titleRegion() {
    UPSlotRegion({ contentBuilder: this.props.titleBuilder })
  }

  @Builder
  private valueRegion() {
    UPSlotRegion({ contentBuilder: this.props.valueBuilder })
  }

  @Builder
  private rightIconRegion() {
    UPSlotRegion({ contentBuilder: this.props.rightIconBuilder })
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        if (this.props.iconBuilder !== undefined) {
          this.iconRegion()
        } else if (this.text(this.props.icon).length > 0) {
          Text(this.text(this.props.icon)).fontSize(14).fontColor(UPColor.adaptive('#606266', 'content-color'))
        }
        Column({ space: 2 }) {
          if (this.props.titleBuilder !== undefined) {
            this.titleRegion()
          } else {
            Text(this.text(this.props.title)).fontSize(UPStyle.parse(this.props.titleStyle).fontSize ?? 15).fontColor(UPStyle.parse(this.props.titleStyle).color ?? '#303133')
          }
          if (this.text(this.props.label).length > 0) Text(this.text(this.props.label)).fontSize(12).fontColor(UPColor.adaptive('#909399', 'tips-color'))
        }.layoutWeight(1).alignItems(upString(this.props.align, 'left') === 'center' ? HorizontalAlign.Center : HorizontalAlign.Start)
        if (this.props.valueBuilder !== undefined) {
          this.valueRegion()
        } else if (this.text(this.props.value).length > 0) {
          Text(this.text(this.props.value)).fontSize(14).fontColor(UPColor.adaptive('#909399', 'tips-color'))
        }
        if (upBoolean(this.props.showRight, true)) {
          if (this.props.rightIconBuilder !== undefined) {
            this.rightIconRegion()
          } else {
            Text(this.opened() ? '⌃' : '⌄').fontSize(18).fontColor(UPColor.adaptive('#909399', 'tips-color'))
          }
        }
      }.width('100%').padding({ top: 14, right: 12, bottom: 14, left: 12 }).opacity(upBoolean(this.props.disabled, false) ? 0.5 : 1).onClick(() => this.click())
      if (this.opened()) Column() { this.contentBuilder() }.width('100%').padding(UPStyle.parse(this.props.customStyle).padding ?? { top: 8, right: 12, bottom: 14, left: 12 })
    }.width('100%').border({ width: { bottom: upBoolean(this.props.border, true) ? 1 : 0 }, color: '#ebeef5' })
  }
}
