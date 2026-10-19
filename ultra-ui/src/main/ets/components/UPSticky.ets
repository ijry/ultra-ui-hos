import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upNumber } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UPCompatibilityDiagnostics } from '../core/UPDiagnostics';

export interface UPStickyOptions {
  offsetTop?: UPRawValue; customNavHeight?: UPRawValue; disabled?: boolean; bgColor?: UPRawValue;
  zIndex?: UPRawValue; index?: UPRawValue; customStyle?: UPStyleInput; contentBuilder?: UPBuilder;
}
export class UPStickyProps {
  offsetTop: UPRawValue = 0; customNavHeight: UPRawValue = 0; disabled: boolean = false;
  bgColor: string = 'transparent'; zIndex: UPRawValue = ''; index: UPRawValue = '';
  customStyle: UPStyleInput = undefined; contentBuilder?: UPBuilder;
  constructor(options?: UPStickyOptions) {
    if (options === undefined) return;
    this.offsetTop = options.offsetTop ?? this.offsetTop; this.customNavHeight = options.customNavHeight ?? this.customNavHeight;
    this.disabled = options.disabled ?? this.disabled; this.bgColor = typeof options.bgColor === 'string' ? options.bgColor : this.bgColor;
    this.zIndex = options.zIndex ?? this.zIndex; this.index = options.index ?? this.index;
    this.customStyle = options.customStyle; this.contentBuilder = options.contentBuilder;
  }
}
@Component
export struct UPSticky {
  @Prop props: UPStickyProps = new UPStickyProps();
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  @Builder private emptyContent() { Row().width(0).height(0) }
  aboutToAppear(): void {
    if (!upBoolean(this.props.disabled, false)) {
      new UPCompatibilityDiagnostics().report('UPSticky', 'offsetTop', this.props.offsetTop,
        'dynamic sticky positioning is host-scroll driven outside native ListItem');
    }
  }
  build() {
    Column() { this.contentBuilder() }
      .backgroundColor(typeof this.props.bgColor === 'string' ? this.props.bgColor : 'transparent')
      .padding({ top: upNumber(this.props.offsetTop, 0) + upNumber(this.props.customNavHeight, 0) })
      .zIndex(upNumber(this.props.zIndex, 0))
      .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
