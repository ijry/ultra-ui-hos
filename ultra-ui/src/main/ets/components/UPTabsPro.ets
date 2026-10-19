import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPTabs, UPTabsProps } from './UPTabs';
import { UPTabsClickEvent, UPTabsItemData } from '../internal/UPNavigationContexts';
import { UPColor } from '../core/UPColor';

/** 默认插槽入参，对齐上游 current/index/item/value/list 作用域。/ Payload of the upstream default slot. */
export interface UPTabsProContentSlot {
  current: number;
  index: number;
  item?: UPTabsItemData;
  value: UPRawValue;
  list: Array<UPTabsItemData>;
}

/** 上游 normalizeCurrent()：把下标钳制到列表范围内。/ Upstream normalizeCurrent(). */
export function upTabsProNormalizeCurrent(value: UPRawValue, total: number): number {
  const parsed: number = upNumber(value, 0);
  const next: number = Number.isFinite(parsed) ? parsed : 0;
  const maxIndex: number = Math.max(total - 1, 0);
  return Math.min(Math.max(Math.floor(next), 0), maxIndex);
}

export interface UPTabsProOptions {
  list?: Array<UPTabsItemData>;
  keyName?: UPRawValue;
  current?: UPRawValue;
  contentMode?: UPRawValue;
  lineColor?: UPRawValue;
  activeStyle?: UPStyleInput;
  inactiveStyle?: UPStyleInput;
  lineWidth?: UPRawValue;
  lineHeight?: UPRawValue;
  lineBgSize?: UPRawValue;
  itemStyle?: UPStyleInput;
  scrollable?: UPRawValue;
  duration?: UPRawValue;
  iconStyle?: UPStyleInput;
  shapeMode?: UPRawValue;
  showContent?: UPRawValue;
  contentClass?: UPRawValue;
  contentStyle?: UPStyleInput;
  bindIndexRef?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: (event: UPTabsClickEvent) => void;
  onLongPress?: (event: UPTabsClickEvent) => void;
  onChange?: (event: UPTabsClickEvent) => void;
  onCurrentChange?: (index: number) => void;
}

export class UPTabsProProps {
  list: Array<UPTabsItemData> = [];
  keyName: UPRawValue = 'name';
  current: UPRawValue = 0;
  contentMode: UPRawValue = 'static';
  lineColor: UPRawValue = '';
  activeStyle: UPStyleInput = undefined;
  inactiveStyle: UPStyleInput = undefined;
  lineWidth: UPRawValue = 20;
  lineHeight: UPRawValue = 3;
  lineBgSize: UPRawValue = 'cover';
  itemStyle: UPStyleInput = undefined;
  scrollable: UPRawValue = true;
  duration: UPRawValue = 300;
  iconStyle: UPStyleInput = undefined;
  shapeMode: UPRawValue = '';
  showContent: UPRawValue = true;
  contentClass: UPRawValue = '';
  contentStyle: UPStyleInput = undefined;
  bindIndexRef: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onClick?: (event: UPTabsClickEvent) => void;
  onLongPress?: (event: UPTabsClickEvent) => void;
  onChange?: (event: UPTabsClickEvent) => void;
  onCurrentChange?: (index: number) => void;

  constructor(options?: UPTabsProOptions) {
    if (options === undefined) {
      return;
    }
    this.list = options.list ?? this.list;
    this.keyName = options.keyName ?? this.keyName;
    this.current = options.current ?? this.current;
    this.contentMode = options.contentMode ?? this.contentMode;
    this.lineColor = options.lineColor ?? this.lineColor;
    this.activeStyle = options.activeStyle;
    this.inactiveStyle = options.inactiveStyle;
    this.lineWidth = options.lineWidth ?? this.lineWidth;
    this.lineHeight = options.lineHeight ?? this.lineHeight;
    this.lineBgSize = options.lineBgSize ?? this.lineBgSize;
    this.itemStyle = options.itemStyle;
    this.scrollable = options.scrollable ?? this.scrollable;
    this.duration = options.duration ?? this.duration;
    this.iconStyle = options.iconStyle;
    this.shapeMode = options.shapeMode ?? this.shapeMode;
    this.showContent = options.showContent ?? this.showContent;
    this.contentClass = options.contentClass ?? this.contentClass;
    this.contentStyle = options.contentStyle;
    this.bindIndexRef = options.bindIndexRef ?? this.bindIndexRef;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
    this.onLongPress = options.onLongPress;
    this.onChange = options.onChange;
    this.onCurrentChange = options.onCurrentChange;
  }
}

@Component
export struct UPTabsPro {
  @Prop @Watch('applyCurrent') props: UPTabsProProps = new UPTabsProProps();
  @State private innerCurrent: number = 0;
  private appliedCurrent: number = -1;

  @Builder
  private emptyBuilder() {
    Row().width(0).height(0)
  }

  @Builder
  private defaultContent(slot: UPTabsProContentSlot) {
    Text(String(slot.value ?? ''))
      .fontSize(14)
      .fontColor(UPColor.adaptive('#606266', 'content-color'))
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 14, right: 14 })
  }

  @BuilderParam leftBuilder: () => void = this.emptyBuilder;
  @BuilderParam rightBuilder: () => void = this.emptyBuilder;
  @BuilderParam iconBuilder: () => void = this.emptyBuilder;
  @BuilderParam tabBuilder: () => void = this.emptyBuilder;
  @BuilderParam contentBuilder: (slot: UPTabsProContentSlot) => void = this.defaultContent;

  @Builder
  private leftRegion() {
    this.leftBuilder()
  }

  @Builder
  private rightRegion() {
    this.rightBuilder()
  }

  @Builder
  private iconRegion() {
    this.iconBuilder()
  }

  @Builder
  private tabRegion() {
    this.tabBuilder()
  }

  aboutToAppear(): void {
    this.reportCompatibility();
    this.applyCurrent();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private reportCompatibility(): void {
    if (upString(this.props.contentMode, 'static') !== 'static') {
      this.diagnostics().report('UPTabsPro', 'contentMode', this.props.contentMode, 'only the static content mode is rendered; swipeable content is a no-op');
    }
    if (upString(this.props.contentClass, '').length > 0) {
      this.diagnostics().report('UPTabsPro', 'contentClass', this.props.contentClass, 'css class names are not applicable; use contentStyle instead');
    }
    if (upString(this.props.bindIndexRef, '').length > 0) {
      this.diagnostics().report('UPTabsPro', 'bindIndexRef', this.props.bindIndexRef, 'template refs are not applicable; use onCurrentChange instead');
    }
    if (upString(this.props.lineBgSize, 'cover') !== 'cover') {
      this.diagnostics().report('UPTabsPro', 'lineBgSize', this.props.lineBgSize, 'the underline is drawn as a solid bar; background sizing is a no-op');
    }
  }

  /** current 变化时同步内部下标，对齐上游 immediate watcher。/ Upstream immediate current watcher. */
  private applyCurrent(): void {
    const next: number = upTabsProNormalizeCurrent(this.props.current, this.props.list.length);
    if (next === this.appliedCurrent) {
      return;
    }
    this.appliedCurrent = next;
    this.innerCurrent = next;
  }

  /** 上游 updateCurrent()：钳制后回传 update:current。/ Upstream updateCurrent(). */
  private updateCurrent(index: number): void {
    const next: number = upTabsProNormalizeCurrent(index, this.props.list.length);
    this.appliedCurrent = next;
    this.innerCurrent = next;
    this.props.onCurrentChange?.(next);
  }

  /** 上游 changeHandler()：先同步下标再回传 change。/ Upstream changeHandler(). */
  private handleChange(event: UPTabsClickEvent): void {
    this.updateCurrent(event.index);
    this.props.onChange?.(event);
  }

  private currentItem(): UPTabsItemData | undefined {
    if (this.innerCurrent < 0 || this.innerCurrent >= this.props.list.length) {
      return undefined;
    }
    return this.props.list[this.innerCurrent];
  }

  /** 上游 currentValue：按 keyName 取当前项的值，字段仅 name 可寻址。/ Upstream currentValue. */
  private currentValue(): UPRawValue {
    const item: UPTabsItemData | undefined = this.currentItem();
    if (item === undefined) {
      return undefined;
    }
    const key: string = upString(this.props.keyName, 'name');
    if (key !== 'name') {
      this.diagnostics().report('UPTabsPro', 'keyName', this.props.keyName, 'only the named field name is addressable; name is used instead');
    }
    return item.name;
  }

  private contentSlot(): UPTabsProContentSlot {
    return {
      current: this.innerCurrent,
      index: this.innerCurrent,
      item: this.currentItem(),
      value: this.currentValue(),
      list: this.props.list
    };
  }

  /** 上游 resolvedLineColor：空串时回落到 up-tabs 默认色。/ Upstream resolvedLineColor. */
  private resolvedLineColor(): UPRawValue {
    const requested: string = upString(this.props.lineColor, '');
    return requested.length > 0 ? requested : '#3c9cff';
  }

  build() {
    Column() {
      UPTabs({
        props: new UPTabsProps({
          list: this.props.list,
          keyName: this.props.keyName,
          current: this.innerCurrent,
          lineColor: this.resolvedLineColor(),
          activeStyle: this.props.activeStyle,
          inactiveStyle: this.props.inactiveStyle,
          lineWidth: this.props.lineWidth,
          lineHeight: this.props.lineHeight,
          lineBgSize: this.props.lineBgSize,
          itemStyle: this.props.itemStyle,
          scrollable: this.props.scrollable,
          duration: upNumber(this.props.duration, 300),
          iconStyle: this.props.iconStyle,
          shapeMode: this.props.shapeMode,
          onCurrentChange: (index: number): void => this.updateCurrent(index),
          onClick: (event: UPTabsClickEvent): void => {
            this.props.onClick?.(event);
          },
          onLongPress: (event: UPTabsClickEvent): void => {
            this.props.onLongPress?.(event);
          },
          onChange: (event: UPTabsClickEvent): void => this.handleChange(event)
        }),
        leftBuilder: this.leftRegion,
        rightBuilder: this.rightRegion,
        iconBuilder: this.iconRegion,
        contentBuilder: this.tabRegion
      })
      if (upBoolean(this.props.showContent, true)) {
        Column() {
          this.contentBuilder(this.contentSlot())
        }
        .width(UPStyle.parse(this.props.contentStyle).width ?? '100%')
        .padding(UPStyle.parse(this.props.contentStyle).padding ?? 0)
        .backgroundColor(UPStyle.parse(this.props.contentStyle).backgroundColor ?? 'transparent')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .alignItems(HorizontalAlign.Start)
    .id('up-tabs-pro')
  }
}
