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
}

/** Evenly divided grid cell that can also render safely outside a UPGrid. */
export class UPGridItemProps {
  name: UPRawValue = null;
  bgColor: UPRawValue = 'transparent';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;
  onClick?: (event: UPGridItemClickEvent) => void;

  constructor(options?: UPGridItemOptions) {
    if (options === undefined) {
      return;
    }
    this.name = options.name ?? this.name;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
    this.onClick = options.onClick;
  }
}

@Component
export struct UPGridItem {
  @Prop props: UPGridItemProps = new UPGridItemProps();
  @Consume('UPGridLayoutContext') gridContext: UPGridLayoutContext = new UPGridLayoutContext(1, false, 'left', 0);

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private itemIndex(): number {
    return this.gridContext.allocateIndex();
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
    if (this.props.onClick === undefined) {
      return;
    }
    const index: number = this.itemIndex();
    const name: UPRawValue = this.props.name === null || this.props.name === undefined ? index : this.props.name;
    this.props.onClick({ name: name, index: index });
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
    .borderColor('#dcdfe6')
    .padding(this.itemPadding())
    .margin(this.itemMargin())
    .opacity(this.itemOpacity())
    .onClick(() => this.emitClick())
  }
}
