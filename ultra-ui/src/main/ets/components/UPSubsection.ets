import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPSubsectionItem { name?: UPRawValue; text?: UPRawValue; activeColor?: UPRawValue; inactiveColor?: UPRawValue; disabled?: UPRawValue; }
export interface UPSubsectionOptions {
  list?: Array<UPSubsectionItem>; current?: UPRawValue; activeColor?: UPRawValue; inactiveColor?: UPRawValue; mode?: UPRawValue;
  fontSize?: UPRawValue; bold?: UPRawValue; bgColor?: UPRawValue; keyName?: UPRawValue; activeColorKeyName?: UPRawValue;
  inactiveColorKeyName?: UPRawValue; disabled?: UPRawValue; customStyle?: UPStyleInput; onCurrentChange?: (index: number) => void; onChange?: (index: number) => void;
}
export class UPSubsectionProps {
  list: Array<UPSubsectionItem> = []; current: UPRawValue = 0; activeColor: UPRawValue = '#3c9cff'; inactiveColor: UPRawValue = '#303133';
  mode: UPRawValue = 'button'; fontSize: UPRawValue = 14; bold: UPRawValue = true; bgColor: UPRawValue = '#eeeeef'; keyName: UPRawValue = 'name';
  activeColorKeyName: UPRawValue = 'activeColor'; inactiveColorKeyName: UPRawValue = 'inactiveColor'; disabled: UPRawValue = false; customStyle: UPStyleInput = undefined;
  onCurrentChange?: (index: number) => void; onChange?: (index: number) => void;
  constructor(options?: UPSubsectionOptions) {
    if (options === undefined) return;
    this.list = options.list ?? this.list; this.current = options.current ?? this.current; this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor; this.mode = options.mode ?? this.mode; this.fontSize = options.fontSize ?? this.fontSize;
    this.bold = options.bold ?? this.bold; this.bgColor = options.bgColor ?? this.bgColor; this.keyName = options.keyName ?? this.keyName;
    this.activeColorKeyName = options.activeColorKeyName ?? this.activeColorKeyName; this.inactiveColorKeyName = options.inactiveColorKeyName ?? this.inactiveColorKeyName;
    this.disabled = options.disabled ?? this.disabled; this.customStyle = options.customStyle; this.onCurrentChange = options.onCurrentChange; this.onChange = options.onChange;
  }
}
@Component
export struct UPSubsection {
  @Prop props: UPSubsectionProps = new UPSubsectionProps();
  private current(): number { return Math.max(0, upNumber(this.props.current, 0)); }
  private mode(): string { return upString(this.props.mode, 'button').toLowerCase() === 'subsection' ? 'subsection' : 'button'; }
  private name(item: UPSubsectionItem): string { return String(item.name ?? item.text ?? ''); }
  private color(item: UPSubsectionItem, active: boolean): string {
    return UPColor.parse(active ? item.activeColor : item.inactiveColor, UP_DEFAULT_THEME,
      UPColor.parse(active ? this.props.activeColor : this.props.inactiveColor, UP_DEFAULT_THEME, active ? '#3c9cff' : '#303133'));
  }
  private itemIndexes(): Array<number> { return this.props.list.map((_item: UPSubsectionItem, index: number): number => index); }
  private click(index: number): void {
    if (upBoolean(this.props.disabled, false) || upBoolean(this.props.list[index].disabled, false)) return;
    this.props.onCurrentChange?.(index); this.props.onChange?.(index);
  }
  @Builder private item(index: number) {
    Row() { Text(this.name(this.props.list[index])).fontSize(UPUnit.parse(this.props.fontSize, 375, 14)).fontWeight(upBoolean(this.props.bold, true) && this.current() === index ? FontWeight.Bold : FontWeight.Normal).fontColor(this.color(this.props.list[index], this.current() === index)) }
      .layoutWeight(1).height(36).justifyContent(FlexAlign.Center).borderRadius(this.mode() === 'button' ? 5 : 0)
      .backgroundColor(this.current() === index ? '#ffffff' : 'transparent').opacity(upBoolean(this.props.list[index].disabled, false) ? 0.45 : 1).onClick(() => this.click(index))
  }
  build() {
    Row() { ForEach(this.itemIndexes(), (index: number) => { this.item(index) }) }
      .width(UPStyle.parse(this.props.customStyle).width ?? '100%').padding(this.mode() === 'button' ? 3 : 0)
      .backgroundColor(UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#eeeeef')).borderRadius(this.mode() === 'button' ? 7 : 0)
  }
}
