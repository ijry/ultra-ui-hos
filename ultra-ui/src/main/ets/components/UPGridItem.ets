import { UPRawValue, UPStyleInput, UPBuilder } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPGridLayoutContext } from '../internal/UPLayoutContexts';

export interface UPGridItemClickEvent {
  name: UPRawValue;
  index: number;
}

export interface UPGridItemOptions {
  name?: UPRawValue;
  bgColor?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
  onClick?: (event: UPGridItemClickEvent) => void;
  onGridItemBroadcast?: (index: number) => void;
}

/** Evenly divided grid cell that can also render safely outside a UPGrid. */
export class UPGridItemProps {
  name: UPRawValue = null;
  bgColor: UPRawValue = 'transparent';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  onClick?: (event: UPGridItemClickEvent) => void;
  onGridItemBroadcast?: (index: number) => void;

  constructor(options?: UPGridItemOptions) {
    if (options === undefined) {
      return;
    }
    this.name = options.name ?? this.name;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.onClick = options.onClick;
    this.onGridItemBroadcast = options.onGridItemBroadcast;
  }
}

@Component
export struct UPGridItem {
  @Prop props: UPGridItemProps = new UPGridItemProps();
  @Consume('UPGridLayoutContext') gridContext: UPGridLayoutContext = new UPGridLayoutContext(1, false, 'left', 0);
  private visualIndex: number = 0;

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  aboutToAppear(): void {
    this.visualIndex = this.gridContext.allocateIndex();
  }

  private itemIndex(): number {
    return this.visualIndex;
  }

  private itemBackground(): string {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.backgroundColor !== undefined) {
      return style.backgroundColor;
    }
    if (style.background !== undefined) {
      return style.background;
    }
    return UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, '#00000000');
  }

  private itemBorder(): boolean {
    return this.gridContext.border;
  }

  private itemPadding(): Padding {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.padding !== undefined) {
      return {
        top: style.padding.top,
        right: style.padding.right,
        bottom: style.padding.bottom,
        left: style.padding.left
      };
    }
    return { top: 0, right: 0, bottom: 0, left: 0 };
  }

  private itemMargin(): Margin {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.margin !== undefined) {
      return {
        top: style.margin.top,
        right: style.margin.right,
        bottom: style.margin.bottom,
        left: style.margin.left
      };
    }
    return { top: 0, right: 0, bottom: 0, left: 0 };
  }

  private itemOpacity(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.opacity ?? 1;
  }

  private emitClick(): void {
    const index: number = this.itemIndex();
    const name: UPRawValue = this.props.name === null || this.props.name === undefined ? index : this.props.name;
    /** 上游先由 grid-item 抛出，再冒泡到 grid 的 `click`。/ Item click bubbles up to the grid. */
    this.gridContext.onItemClick?.(name, index);
    /**
     * 上游用 `uni.$emit('$uGridItem')` 全局广播来清理兄弟项的按下态；
     * 这里改为把广播交给宿主，组件不引入全局事件总线。
     * Upstream broadcasts through the global uni event bus; here the notification
     * is handed to the host instead of introducing a global bus.
     */
    this.props.onGridItemBroadcast?.(index);
    this.props.onClick?.({ name: name, index: index });
  }

  build() {
    GridItem() {
      Column() {
        this.contentBuilder()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.itemBackground())
    .borderWidth(this.itemBorder() ? 0.5 : 0)
    .borderColor(UPColor.adaptive('#dcdfe6', 'border-color'))
    .padding(this.itemPadding())
    .margin(this.itemMargin())
    .opacity(this.itemOpacity())
    .onClick(() => this.emitClick())
  }
}
