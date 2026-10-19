import { UPBuilder, UPRawValue, UPStyleInput, upBoolean, upString, upValueKey } from '../core/UPTypes';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UPUnit } from '../core/UPUnit';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPTag, UPTagProps } from './UPTag';
import { UPSlotRegion } from '../internal/UPSlotRegion';

/** 左侧金额区插槽入参。/ Payload of the amount slot. */
export interface UPCouponAmountSlot {
  amount: UPRawValue;
  unit: string;
  unitPosition: string;
  limit: string;
}

/** 中部信息区插槽入参。/ Payload of the info slot. */
export interface UPCouponInfoSlot {
  title: string;
  desc: string;
  time: string;
}

/** 右侧操作区插槽入参。/ Payload of the action slot. */
export interface UPCouponActionSlot {
  actionText: string;
  circle: boolean;
}

/** 主题渐变的两个端点色。/ Gradient endpoints of one built-in theme. */
export interface UPCouponGradient {
  from: string;
  to: string;
}

/** 上游内置主题的渐变映射，具名函数替代对象索引。/ Named lookup instead of a keyed map. */
export function upCouponGradient(type: string): UPCouponGradient | undefined {
  if (type === 'primary') {
    return { from: '#43afff', to: '#3b8cff' };
  }
  if (type === 'success') {
    return { from: '#67dda9', to: '#19be6b' };
  }
  if (type === 'warning') {
    return { from: '#ff9739', to: '#ff6a39' };
  }
  if (type === 'error') {
    return { from: '#ff7070', to: '#ff4747' };
  }
  return undefined;
}

export interface UPCouponOptions {
  amount?: UPRawValue;
  unit?: UPRawValue;
  unitPosition?: UPRawValue;
  limit?: UPRawValue;
  title?: UPRawValue;
  desc?: UPRawValue;
  time?: UPRawValue;
  actionText?: UPRawValue;
  shape?: UPRawValue;
  size?: UPRawValue;
  circle?: UPRawValue;
  disabled?: UPRawValue;
  bgColor?: UPRawValue;
  color?: UPRawValue;
  type?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onClick?: () => void;
  unitBuilder?: UPBuilder;
  limitBuilder?: UPBuilder;
  titleBuilder?: UPBuilder;
  descBuilder?: UPBuilder;
  timeBuilder?: UPBuilder;
}

export class UPCouponProps {
  amount: UPRawValue = '';
  unit: UPRawValue = '￥';
  unitPosition: UPRawValue = 'left';
  limit: UPRawValue = '';
  title: UPRawValue = '优惠券';
  desc: UPRawValue = '';
  time: UPRawValue = '';
  actionText: UPRawValue = '使用';
  shape: UPRawValue = 'coupon';
  size: UPRawValue = 'medium';
  circle: UPRawValue = false;
  disabled: UPRawValue = false;
  bgColor: UPRawValue = '';
  color: UPRawValue = '';
  type: UPRawValue = '';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics = undefined;
  onClick?: () => void;
  unitBuilder?: UPBuilder;
  limitBuilder?: UPBuilder;
  titleBuilder?: UPBuilder;
  descBuilder?: UPBuilder;
  timeBuilder?: UPBuilder;

  constructor(options?: UPCouponOptions) {
    if (options === undefined) {
      return;
    }
    this.amount = options.amount ?? this.amount;
    this.unit = options.unit ?? this.unit;
    this.unitPosition = options.unitPosition ?? this.unitPosition;
    this.limit = options.limit ?? this.limit;
    this.title = options.title ?? this.title;
    this.desc = options.desc ?? this.desc;
    this.time = options.time ?? this.time;
    this.actionText = options.actionText ?? this.actionText;
    this.shape = options.shape ?? this.shape;
    this.size = options.size ?? this.size;
    this.circle = options.circle ?? this.circle;
    this.disabled = options.disabled ?? this.disabled;
    this.bgColor = options.bgColor ?? this.bgColor;
    this.color = options.color ?? this.color;
    this.type = options.type ?? this.type;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onClick = options.onClick;
    this.unitBuilder = options.unitBuilder;
    this.limitBuilder = options.limitBuilder;
    this.titleBuilder = options.titleBuilder;
    this.descBuilder = options.descBuilder;
    this.timeBuilder = options.timeBuilder;
  }
}

@Component
export struct UPCoupon {
  @Prop props: UPCouponProps = new UPCouponProps();

  @Builder
  private defaultAmount(slot: UPCouponAmountSlot) {
    Column() {
      if (slot.unitPosition === 'left' && this.props.unitBuilder !== undefined) {
        this.unitRegion()
      } else if (slot.unitPosition === 'left' && slot.unit.length > 0) {
        Text(slot.unit).fontSize(this.unitFontSize()).fontColor(this.textColor())
      }
      Text(upValueKey(slot.amount))
        .fontSize(this.amountFontSize())
        .fontColor(this.amountColor())
        .fontWeight(FontWeight.Bold)
        .margin({ top: this.tightGap(), bottom: this.tightGap() })
      if (slot.unitPosition === 'right' && this.props.unitBuilder !== undefined) {
        this.unitRegion()
      } else if (slot.unitPosition === 'right' && slot.unit.length > 0) {
        Text(slot.unit).fontSize(this.unitFontSize()).fontColor(this.textColor())
      }
      if (this.props.limitBuilder !== undefined) {
        this.limitRegion()
      } else if (slot.limit.length > 0) {
        Text(slot.limit).fontSize(this.unitFontSize()).fontColor(this.textColor()).opacity(0.9)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private defaultInfo(slot: UPCouponInfoSlot) {
    Column() {
      if (this.props.titleBuilder !== undefined) {
        this.titleRegion()
      } else {
        Text(slot.title)
          .fontSize(this.titleFontSize())
          .fontColor(this.textColor())
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: this.tightGap() })
      }
      if (this.props.descBuilder !== undefined) {
        this.descRegion()
      } else if (slot.desc.length > 0) {
        Text(slot.desc)
          .fontSize(this.unitFontSize())
          .fontColor(this.textColor())
          .opacity(0.9)
          .margin({ bottom: this.tightGap() })
      }
      if (this.props.timeBuilder !== undefined) {
        this.timeRegion()
      } else if (slot.time.length > 0) {
        Text(slot.time).fontSize(this.timeFontSize()).fontColor(this.textColor()).opacity(0.8)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private defaultAction(slot: UPCouponActionSlot) {
    UPTag({ props: new UPTagProps({
      type: 'error',
      text: slot.actionText,
      bgColor: this.themeName().length > 0 ? 'transparent' : '#eb433d',
      borderColor: this.themeName().length > 0 ? '#eee' : '#eb433d',
      borderRadius: '6px',
      size: 'medium',
      shape: 'circle'
    }) })
  }

  @Builder
  private defaultContent() {
    Row().width(0).height(0)
  }

  @BuilderParam amountBuilder: (slot: UPCouponAmountSlot) => void = this.defaultAmount;
  @BuilderParam infoBuilder: (slot: UPCouponInfoSlot) => void = this.defaultInfo;
  @BuilderParam actionBuilder: (slot: UPCouponActionSlot) => void = this.defaultAction;
  @BuilderParam contentBuilder: () => void = this.defaultContent;

  aboutToAppear(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
    if (this.shapeName() !== upString(this.props.shape, 'coupon')) {
      diagnostics.report('UPCoupon', 'shape', this.props.shape, 'unsupported shape; fallback to coupon');
    }
    if (this.sizeName() !== upString(this.props.size, 'medium')) {
      diagnostics.report('UPCoupon', 'size', this.props.size, 'unsupported size; fallback to medium');
    }
    if (upBoolean(this.props.circle, false)) {
      diagnostics.report('UPCoupon', 'circle', this.props.circle, 'the upstream action tag is always circle shaped; the flag has no visual effect');
    }
  }

  /** 上游 shape 仅 coupon / envelope / card。/ Upstream shape whitelist. */
  private shapeName(): string {
    const shape: string = upString(this.props.shape, 'coupon');
    if (shape === 'envelope' || shape === 'card') {
      return shape;
    }
    return 'coupon';
  }

  /** 上游 size 仅 small / medium / large。/ Upstream size whitelist. */
  private sizeName(): string {
    const size: string = upString(this.props.size, 'medium');
    if (size === 'small' || size === 'large') {
      return size;
    }
    return 'medium';
  }

  /** type 为空时不启用内置渐变主题。/ Empty type keeps the plain pink surface. */
  private themeName(): string {
    const type: string = upString(this.props.type, '');
    return upCouponGradient(type) === undefined ? '' : type;
  }

  private couponHeight(): number {
    const style: UPRawValue = UPStyle.parse(this.props.customStyle).height;
    if (typeof style === 'number' && style > 0) {
      return style;
    }
    if (this.sizeName() === 'small') {
      return UPUnit.parse('160rpx', 375, 80);
    }
    if (this.sizeName() === 'large') {
      return UPUnit.parse('220rpx', 375, 110);
    }
    return UPUnit.parse('180rpx', 375, 90);
  }

  private surfaceColor(): string {
    const requested: string = upString(this.props.bgColor, '');
    if (requested.length > 0) {
      return UPColor.parse(requested, UP_DEFAULT_THEME, '#ffebf0');
    }
    return UPStyle.parse(this.props.customStyle).backgroundColor ?? '#ffebf0';
  }

  private textColor(): string {
    const requested: string = upString(this.props.color, '');
    if (requested.length > 0) {
      return UPColor.parse(requested, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133'));
    }
    return this.themeName().length > 0 ? '#ffffff' : '#303133';
  }

  private amountColor(): string {
    const requested: string = upString(this.props.color, '');
    if (requested.length > 0) {
      return UPColor.parse(requested, UP_DEFAULT_THEME, UPColor.neutral('main', '#303133'));
    }
    return this.themeName().length > 0 ? '#ffffff' : '#ff0000';
  }

  private gradientFrom(): string {
    const gradient: UPCouponGradient | undefined = upCouponGradient(this.themeName());
    return gradient === undefined ? '#43afff' : gradient.from;
  }

  private gradientTo(): string {
    const gradient: UPCouponGradient | undefined = upCouponGradient(this.themeName());
    return gradient === undefined ? '#3b8cff' : gradient.to;
  }

  private dividerColor(): string {
    return this.themeName().length > 0 ? '#eeeeee' : '#cccccc';
  }

  private cornerRadius(): number {
    return UPStyle.parse(this.props.customStyle).borderRadius ?? UPUnit.parse('16rpx', 375, 8);
  }

  private notchSize(): number {
    return UPUnit.parse('48rpx', 375, 24);
  }

  private stripeHeight(): number {
    return UPUnit.parse('20rpx', 375, 10);
  }

  private unitFontSize(): number {
    return UPUnit.parse('24rpx', 375, 12);
  }

  private amountFontSize(): number {
    return UPUnit.parse('56rpx', 375, 28);
  }

  private titleFontSize(): number {
    return UPUnit.parse('32rpx', 375, 16);
  }

  private timeFontSize(): number {
    return UPUnit.parse('20rpx', 375, 10);
  }

  private tightGap(): number {
    return UPUnit.parse('10rpx', 375, 5);
  }

  private sideGap(): number {
    return UPUnit.parse('30rpx', 375, 15);
  }

  private amountSlot(): UPCouponAmountSlot {
    return {
      amount: this.props.amount,
      unit: upString(this.props.unit, '￥'),
      unitPosition: upString(this.props.unitPosition, 'left') === 'right' ? 'right' : 'left',
      limit: upString(this.props.limit, '')
    };
  }

  private infoSlot(): UPCouponInfoSlot {
    return {
      title: upString(this.props.title, '优惠券'),
      desc: upString(this.props.desc, ''),
      time: upString(this.props.time, '')
    };
  }

  private actionSlot(): UPCouponActionSlot {
    return { actionText: upString(this.props.actionText, '使用'), circle: upBoolean(this.props.circle, false) };
  }

  /** 上游 handleClick()：禁用时直接返回。/ Upstream handleClick(). */
  private press(): void {
    if (upBoolean(this.props.disabled, false)) {
      return;
    }
    this.props.onClick?.();
  }

  @Builder
  private notches() {
    Row() {
      Column()
        .width(this.notchSize())
        .height(this.notchSize())
        .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
        .borderRadius(this.notchSize() / 2)
        .offset({ x: -this.notchSize() / 2, y: 0 })
      Column()
        .width(this.notchSize())
        .height(this.notchSize())
        .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
        .borderRadius(this.notchSize() / 2)
        .offset({ x: this.notchSize() / 2, y: 0 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private envelopeStripe() {
    Column()
      .width('100%')
      .height(this.stripeHeight())
      .linearGradient({
        angle: 135,
        repeating: true,
        colors: [['#ffd000', 0.0], ['#ffd000', 0.04], ['#ffa000', 0.04], ['#ffa000', 0.08]]
      })
  }

  @Builder
  private surface() {
    Row() {
      Column() {
        this.amountBuilder(this.amountSlot())
      }
      .height('100%')
      .padding({ left: this.tightGap(), right: this.sideGap() })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .border({ width: { right: 1 }, color: this.dividerColor(), style: BorderStyle.Dashed })

      Column() {
        this.infoBuilder(this.infoSlot())
        this.contentBuilder()
      }
      .layoutWeight(1)
      .height('100%')
      .padding({ left: this.sideGap() })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Row() {
        this.actionBuilder(this.actionSlot())
      }
      .padding({ right: this.tightGap() })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ left: this.sideGap(), right: this.sideGap() })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private unitRegion() {
    UPSlotRegion({ contentBuilder: this.props.unitBuilder })
  }

  @Builder
  private limitRegion() {
    UPSlotRegion({ contentBuilder: this.props.limitBuilder })
  }

  @Builder
  private titleRegion() {
    UPSlotRegion({ contentBuilder: this.props.titleBuilder })
  }

  @Builder
  private descRegion() {
    UPSlotRegion({ contentBuilder: this.props.descBuilder })
  }

  @Builder
  private timeRegion() {
    UPSlotRegion({ contentBuilder: this.props.timeBuilder })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.themeName().length > 0) {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({ angle: 90, colors: [[this.gradientFrom(), 0.0], [this.gradientTo(), 1.0]] })
      }
      this.surface()
      if (this.shapeName() === 'coupon') {
        this.notches()
      }
      if (this.shapeName() === 'envelope') {
        Column() {
          this.envelopeStripe()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(this.couponHeight())
    .backgroundColor(this.surfaceColor())
    .borderRadius(this.cornerRadius())
    .opacity(upBoolean(this.props.disabled, false) ? 0.5 : 1)
    .clip(true)
    .onClick((): void => {
      this.press();
    })
    .id('up-coupon')
  }
}
