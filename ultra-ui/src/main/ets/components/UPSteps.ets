import { UPRawValue, UPStyleInput, upNumber, upString } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPStepsContext } from '../internal/UPNavigationContexts';

export interface UPStepsOptions {
  direction?: UPRawValue; current?: UPRawValue; activeColor?: UPRawValue; inactiveColor?: UPRawValue; activeIcon?: UPRawValue;
  inactiveIcon?: UPRawValue; dot?: UPRawValue; customStyle?: UPStyleInput; contentBuilder?: () => void;
}
export class UPStepsProps {
  direction: UPRawValue = 'row'; current: UPRawValue = 0; activeColor: UPRawValue = '#3c9cff'; inactiveColor: UPRawValue = '#969799';
  activeIcon: UPRawValue = ''; inactiveIcon: UPRawValue = ''; dot: UPRawValue = false; customStyle: UPStyleInput = undefined; contentBuilder?: () => void;
  constructor(options?: UPStepsOptions) {
    if (options === undefined) return;
    this.direction = options.direction ?? this.direction; this.current = options.current ?? this.current; this.activeColor = options.activeColor ?? this.activeColor;
    this.inactiveColor = options.inactiveColor ?? this.inactiveColor; this.activeIcon = options.activeIcon ?? this.activeIcon;
    this.inactiveIcon = options.inactiveIcon ?? this.inactiveIcon; this.dot = options.dot ?? this.dot; this.customStyle = options.customStyle; this.contentBuilder = options.contentBuilder;
  }
}
@Component
export struct UPSteps {
  @Prop @Watch('refreshContext') props: UPStepsProps = new UPStepsProps();
  @Provide('UPStepsContext') stepsContext: UPStepsContext = new UPStepsContext();
  @Builder private emptyContent() { Row().width(0).height(0) }
  @BuilderParam contentBuilder: () => void = this.emptyContent;
  aboutToAppear(): void { this.refreshContext(); }
  refreshContext(): void {
    this.stepsContext = new UPStepsContext();
    this.stepsContext.beginComposition(Math.max(0, upNumber(this.props.current, 0)), this.props.direction, this.props.activeColor, this.props.inactiveColor, this.props.activeIcon, this.props.inactiveIcon, this.props.dot);
  }
  private resolvedDirection(): string { return upString(this.props.direction, 'row').toLowerCase() === 'column' ? 'column' : 'row'; }
  build() {
    if (this.resolvedDirection() === 'column') Column() { this.contentBuilder() }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    else Row() { this.contentBuilder() }.width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
