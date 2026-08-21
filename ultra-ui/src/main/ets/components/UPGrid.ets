import { UPRawValue, UPStyleInput, UPBuilder, upBoolean } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { upLayoutEnum, upLayoutInt, UPGridLayoutContext } from '../internal/UPLayoutContexts';

export interface UPGridOptions {
  col?: UPRawValue;
  border?: UPRawValue;
  align?: UPRawValue;
  gap?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

/** Evenly divided wrap-capable grid container, source-compatible with uview-plus `u-grid`. */
export class UPGridProps {
  col: UPRawValue = 3;
  border: UPRawValue = false;
  align: UPRawValue = 'left';
  gap: UPRawValue = '0px';
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPGridOptions) {
    if (options === undefined) {
      return;
    }
    this.col = options.col ?? this.col;
    this.border = options.border ?? this.border;
    this.align = options.align ?? this.align;
    this.gap = options.gap ?? this.gap;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPGrid {
  @Prop @Watch('onPropsChange') props: UPGridProps = new UPGridProps();
  @Provide('UPGridLayoutContext') gridContext: UPGridLayoutContext = new UPGridLayoutContext(3, false, 'left', 0);

  @Builder
  private emptyContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptyContent;

  aboutToAppear(): void {
    this.refreshContext();
  }

  onPropsChange(): void {
    this.refreshContext();
  }

  private refreshContext(): void {
    this.gridContext = new UPGridLayoutContext(
      this.gridColumns(),
      this.gridBorder(),
      this.gridAlign(),
      this.gridGap()
    );
    this.gridContext.beginComposition();
  }

  private gridColumns(): number {
    return upLayoutInt(this.props.col, 3, 1, 12);
  }

  private gridGap(): number {
    return UPUnit.parse(this.props.gap, 375, 0);
  }

  private gridAlign(): string {
    return upLayoutEnum(this.props.align, ['left', 'center', 'right'], 'left');
  }

  private gridBorder(): boolean {
    return upBoolean(this.props.border, false);
  }

  private columnsTemplate(): string {
    const columns: number = this.gridColumns() * 2;
    const cells: Array<string> = [];
    for (let i = 0; i < columns; i++) {
      cells.push('1fr');
    }
    return cells.join(' ');
  }

  private layoutOptions(): GridLayoutOptions {
    return {
      regularSize: [1, 2],
      irregularIndexes: [],
      onGetRectByIndex: (index: number): [number, number, number, number] => {
        const columns: number = this.gridColumns();
        const count: number = this.gridContext.itemCount();
        const lastRowStart: number = Math.floor(Math.max(0, count - 1) / columns) * columns;
        const lastRowCount: number = count - lastRowStart;
        let leadingTracks: number = 0;
        if (index >= lastRowStart && lastRowCount > 0 && lastRowCount < columns) {
          const freeTracks: number = (columns - lastRowCount) * 2;
          if (this.gridAlign() === 'center') {
            leadingTracks = Math.floor(freeTracks / 2);
          } else if (this.gridAlign() === 'right') {
            leadingTracks = freeTracks;
          }
        }
        return [Math.floor(index / columns), leadingTracks + index % columns * 2, 1, 2];
      }
    };
  }

  private gridPadding(): Padding {
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

  private gridMargin(): Margin {
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

  private gridOpacity(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.opacity ?? 1;
  }

  build() {
    Grid(undefined, this.layoutOptions()) {
      this.contentBuilder()
    }
    .columnsTemplate(this.columnsTemplate())
    .columnsGap(this.gridGap())
    .rowsGap(this.gridGap())
    .width('100%')
    .padding(this.gridPadding())
    .margin(this.gridMargin())
    .opacity(this.gridOpacity())
  }
}
