import { UPRawValue, UPStyleInput, UPBuilder, upBoolean } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPEdgeValues } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';

export interface UPCellGroupOptions {
  title?: UPRawValue;
  border?: UPRawValue;
  inset?: UPRawValue;
  customStyle?: UPStyleInput;
  contentBuilder?: UPBuilder;
}

export class UPCellGroupProps {
  title: UPRawValue = '';
  border: UPRawValue = true;
  inset: UPRawValue = false;
  customStyle: UPStyleInput = undefined;
  contentBuilder?: UPBuilder;

  constructor(options?: UPCellGroupOptions) {
    if (options === undefined) {
      return;
    }
    this.title = options.title ?? this.title;
    this.border = options.border ?? this.border;
    this.inset = options.inset ?? this.inset;
    this.customStyle = options.customStyle;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPCellGroup {
  @Prop props: UPCellGroupProps = new UPCellGroupProps();

  @Builder
  private defaultContent() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.defaultContent;

  private title(): string {
    if (this.props.title === null || this.props.title === undefined) {
      return '';
    }
    return String(this.props.title);
  }

  private groupPadding(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.padding ?? { top: 0, right: 0, bottom: 0, left: 0 };
  }

  private groupRadius(): number {
    const style = UPStyle.parse(this.props.customStyle);
    return style.borderRadius ?? (upBoolean(this.props.inset, false) ? 8 : 0);
  }

  private groupMargin(): UPEdgeValues {
    const style = UPStyle.parse(this.props.customStyle);
    return style.margin ?? (upBoolean(this.props.inset, false) ?
      { top: 8, right: 12, bottom: 8, left: 12 } :
      { top: 0, right: 0, bottom: 0, left: 0 });
  }

  @Builder
  private content() {
    Column() {
      if (this.title().length > 0) {
        Text(this.title())
          .width('100%')
          .fontSize(14)
          .fontColor(UP_DEFAULT_THEME.tips)
          .margin({ bottom: 8 })
      }
      Column() {
        this.contentBuilder()
      }
      .width('100%')
      .backgroundColor('#ffffff')
      .borderWidth(upBoolean(this.props.border, true) ? 1 : 0)
      .borderColor('#eeeeee')
      .borderRadius(this.groupRadius())
      .clip(true)
    }
    .width('100%')
    .padding(this.groupPadding())
    .margin(this.groupMargin())
  }

  build() {
    this.content()
  }
}
