import { UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPStepStatus, UPStepsContext } from '../internal/UPNavigationContexts';
import { UPColor } from '../core/UPColor';

export interface UPStepsItemOptions {
  title?: UPRawValue; desc?: UPRawValue; iconSize?: UPRawValue; error?: UPRawValue; itemStyle?: UPStyleInput; customStyle?: UPStyleInput;
  onClick?: (index: number) => void; iconBuilder?: () => void; titleBuilder?: () => void; descBuilder?: () => void; contentBuilder?: () => void;
}
export class UPStepsItemProps {
  title: UPRawValue = ''; desc: UPRawValue = ''; iconSize: UPRawValue = 17; error: UPRawValue = false; itemStyle: UPStyleInput = undefined; customStyle: UPStyleInput = undefined;
  onClick?: (index: number) => void; iconBuilder?: () => void; titleBuilder?: () => void; descBuilder?: () => void; contentBuilder?: () => void;
  constructor(options?: UPStepsItemOptions) {
    if (options === undefined) return;
    this.title = options.title ?? this.title; this.desc = options.desc ?? this.desc; this.iconSize = options.iconSize ?? this.iconSize;
    this.error = options.error ?? this.error; this.itemStyle = options.itemStyle; this.customStyle = options.customStyle; this.onClick = options.onClick;
    this.iconBuilder = options.iconBuilder; this.titleBuilder = options.titleBuilder; this.descBuilder = options.descBuilder; this.contentBuilder = options.contentBuilder;
  }
}
@Component
export struct UPStepsItem {
  @Prop props: UPStepsItemProps = new UPStepsItemProps();
  @Consume('UPStepsContext') stepsContext: UPStepsContext = new UPStepsContext();
  private index: number = 0;
  @Builder private emptyBuilder() { Row().width(0).height(0) }
  @BuilderParam iconBuilder: () => void = this.emptyBuilder;
  @BuilderParam titleBuilder: () => void = this.emptyBuilder;
  @BuilderParam descBuilder: () => void = this.emptyBuilder;
  @BuilderParam contentBuilder: () => void = this.emptyBuilder;
  aboutToAppear(): void { this.index = this.stepsContext.itemIndex(); }
  private status(): UPStepStatus { return this.stepsContext.stateFor(this.index, this.props.error); }
  private color(): string { return this.status() === 'error' ? '#fa3534' : (this.status() === 'wait' ? this.stepsContext.inactiveColor : this.stepsContext.activeColor); }
  private icon(): string {
    if (this.stepsContext.activeIcon.length > 0 || this.stepsContext.inactiveIcon.length > 0) return this.index <= this.stepsContext.current ? this.stepsContext.activeIcon : this.stepsContext.inactiveIcon;
    if (this.status() === 'finish') return 'checkmark';
    if (this.status() === 'error') return 'close';
    return '';
  }
  @Builder private marker() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.stepsContext.dot) Column().width(8).height(8).borderRadius(4).backgroundColor(this.color())
      else if (this.icon().length > 0) UPIcon({ props: new UPIconProps({ name: this.icon(), size: this.props.iconSize, color: this.color() }) })
      else Text(String(this.index + 1)).fontSize(12).fontColor('#ffffff')
      this.iconBuilder()
    }.width(this.stepsContext.dot ? 14 : 26).height(this.stepsContext.dot ? 14 : 26).borderRadius(13).backgroundColor(this.stepsContext.dot ? 'transparent' : this.color())
  }
  @Builder private details() {
    Column({ space: 3 }) {
      this.titleBuilder(); if (String(this.props.title ?? '').length > 0) Text(String(this.props.title)).fontSize(14).fontColor(this.color())
      this.descBuilder(); if (String(this.props.desc ?? '').length > 0) Text(String(this.props.desc)).fontSize(12).fontColor(UPColor.adaptive('#909399', 'tips-color'))
      this.contentBuilder()
    }.alignItems(HorizontalAlign.Start).layoutWeight(1)
  }
  build() {
    if (this.stepsContext.direction === 'column') {
      Row({ space: 10 }) { Column() { this.marker(); Column().width(1).height(32).backgroundColor(this.stepsContext.connectorColor(this.index)) }; this.details() }
        .width('100%').padding(UPStyle.parse(this.props.itemStyle).padding ?? { bottom: 12 }).onClick(() => this.props.onClick?.(this.index))
    } else {
      Column({ space: 6 }) { Row() { Column().height(1).backgroundColor(this.stepsContext.connectorColor(this.index)).layoutWeight(1); this.marker(); Column().height(1).backgroundColor(this.stepsContext.connectorColor(this.index)).layoutWeight(1) }; this.details() }
        .layoutWeight(1).padding(UPStyle.parse(this.props.itemStyle).padding ?? 0).onClick(() => this.props.onClick?.(this.index))
    }
  }
}
