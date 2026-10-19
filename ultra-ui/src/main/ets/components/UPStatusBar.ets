import { UPBuilder, UPRawValue, UPStyleInput } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPUnit } from '../core/UPUnit';
import { UPSlotRegion } from '../internal/UPSlotRegion';

export interface UPStatusBarOptions {
  bgColor?: UPRawValue; height?: UPRawValue; customStyle?: UPStyleInput;
  onHeightChange?: (height: number) => void; contentBuilder?: UPBuilder;
}
export class UPStatusBarProps {
  bgColor: UPRawValue = 'transparent'; height: UPRawValue = 0; customStyle: UPStyleInput = undefined;
  onHeightChange?: (height: number) => void; contentBuilder?: UPBuilder;
  constructor(options?: UPStatusBarOptions) {
    if (options === undefined) return;
    this.bgColor = options.bgColor ?? this.bgColor; this.height = options.height ?? this.height;
    this.customStyle = options.customStyle; this.onHeightChange = options.onHeightChange;
    this.contentBuilder = options.contentBuilder;
  }
}

@Component
export struct UPStatusBar {
  @Prop props: UPStatusBarProps = new UPStatusBarProps();

  private resolvedHeight(): number {
    const style = UPStyle.parse(this.props.customStyle);
    const explicit: number = UPUnit.parse(this.props.height, 375, 0);
    return style.height ?? Math.max(0, explicit);
  }

  aboutToAppear(): void { this.props.onHeightChange?.(this.resolvedHeight()); }

  @Builder
  private slotRegion() {
    UPSlotRegion({ contentBuilder: this.props.contentBuilder })
  }

  build() {
    Column() {
      this.slotRegion()
    }
    .width('100%')
    .height(this.resolvedHeight())
    .backgroundColor(UPColor.parse(this.props.bgColor, UP_DEFAULT_THEME, 'transparent'))
  }
}
