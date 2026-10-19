import { UPStyleInput } from '../core/UPTypes';
import { UPStyle } from '../core/UPStyle';
import { UPColor } from '../core/UPColor';

export interface UPTimelineItemData {
  title: string; content?: string; time?: string; color?: string; disabled?: boolean;
}
export type UPTimelineItem = UPTimelineItemData;
export interface UPTimelineOptions {
  items?: Array<UPTimelineItem>; direction?: string; color?: string; customStyle?: UPStyleInput;
  onItemClick?: (item: UPTimelineItem, index: number) => void;
}
export class UPTimelineProps {
  items: Array<UPTimelineItem> = []; direction: string = 'column'; color: string = '#2979ff';
  customStyle: UPStyleInput = undefined; onItemClick?: (item: UPTimelineItem, index: number) => void;
  constructor(options?: UPTimelineOptions) {
    if (options === undefined) return;
    this.items = options.items ?? this.items; this.direction = options.direction ?? this.direction;
    this.color = options.color ?? this.color; this.customStyle = options.customStyle;
    this.onItemClick = options.onItemClick;
  }
}

@Component
export struct UPTimeline {
  @Prop props: UPTimelineProps = new UPTimelineProps();
  build() {
    Column({ space: 14 }) {
      ForEach(this.props.items, (item: UPTimelineItem, index: number) => {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Circle().width(11).height(11).fill(item.disabled ? '#c0c4cc' : (item.color ?? this.props.color))
            if (index < this.props.items.length - 1) Line().width(2).height(52).backgroundColor('#e4e7ed')
          }.alignItems(HorizontalAlign.Center)
          Column({ space: 4 }) {
            Text(item.title).fontSize(15).fontWeight(FontWeight.Medium)
              .fontColor(item.disabled ? '#c0c4cc' : '#303133')
            if (item.content !== undefined && item.content.length > 0) Text(item.content).fontSize(13).fontColor(UPColor.adaptive('#606266', 'content-color'))
            if (item.time !== undefined && item.time.length > 0) Text(item.time).fontSize(12).fontColor(UPColor.adaptive('#909399', 'tips-color'))
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        }.alignItems(VerticalAlign.Top).width('100%')
         .onClick((): void => { if (!item.disabled) this.props.onItemClick?.(item, index); })
      })
    }.alignItems(HorizontalAlign.Start)
     .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
