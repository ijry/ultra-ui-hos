import { UPRawValue, UPStyleInput, upBoolean } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';

export interface UPSafeBottomOptions { safeAreaInsetBottom?: UPRawValue; customStyle?: UPStyleInput; contentBuilder?: () => void; }
export class UPSafeBottomProps {
  safeAreaInsetBottom: UPRawValue = true; customStyle: UPStyleInput = undefined; contentBuilder?: () => void;
  constructor(options?: UPSafeBottomOptions) {
    if (options === undefined) return;
    this.safeAreaInsetBottom = options.safeAreaInsetBottom ?? this.safeAreaInsetBottom;
    this.customStyle = options.customStyle; this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPSafeBottom {
  @Prop props: UPSafeBottomProps = new UPSafeBottomProps();
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;

  private bottomPadding(): number {
    const style = UPStyle.parse(this.props.customStyle);
    if (style.padding?.bottom !== undefined) return style.padding.bottom;
    return upBoolean(this.props.safeAreaInsetBottom, true) ? 0 : 0;
  }

  build() {
    Column() { this.contentBuilder() }
      .width('100%').padding({ bottom: this.bottomPadding() })
  }
}
