import { UPStyleInput } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';

export interface UPTabsItemOptions { customStyle?: UPStyleInput; contentBuilder?: () => void; }
export class UPTabsItemProps {
  customStyle: UPStyleInput = undefined; contentBuilder?: () => void;
  constructor(options?: UPTabsItemOptions) { if (options !== undefined) { this.customStyle = options.customStyle; this.contentBuilder = options.contentBuilder; } }
}
@Component
export struct UPTabsItem {
  @Prop props: UPTabsItemProps = new UPTabsItemProps();
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  build() { Column() { this.contentBuilder() }.width(UPStyle.parse(this.props.customStyle).width ?? '100%').padding(UPStyle.parse(this.props.customStyle).padding ?? 0) }
}
