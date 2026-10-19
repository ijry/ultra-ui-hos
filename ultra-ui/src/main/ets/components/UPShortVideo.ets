import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPStyle } from '../core/UPStyle';
import { UPActionSheet, UPActionSheetAction, UPActionSheetProps, UPActionSheetSelectEvent } from './UPActionSheet';
import { UPAvatar, UPAvatarProps } from './UPAvatar';
import { UPButton, UPButtonProps } from './UPButton';
import { UPIcon, UPIconProps } from './UPIcon';
import { UPSlider, UPSliderChangeEvent, UPSliderProps } from './UPSlider';
import { UPTabs, UPTabsItemData, UPTabsProps } from './UPTabs';
import { UPTabbar, UPTabbarChangeEvent, UPTabbarItemData, UPTabbarProps } from './UPTabbar';

/** 上游默认 tabsList。/ Default tabsList upstream. */
export const UP_SHORT_VIDEO_TABS: Array<string> = ['推荐', '关注', '朋友', '本地'];
/** 上游 speedOptions。/ The upstream speedOptions list. */
export const UP_SHORT_VIDEO_SPEEDS: Array<number> = [0.5, 0.75, 1, 1.25, 1.5, 2];
/** 上游底部导航的四项。/ The four upstream tabbar entries. */
export const UP_SHORT_VIDEO_TABBAR_TEXTS: Array<string> = ['首页', '放映厅', '直播', '我的'];
export const UP_SHORT_VIDEO_TABBAR_ICONS: Array<string> = ['home', 'photo', 'play-right', 'account'];
/** 上游 tabs 的取色。/ Tab colors from the upstream template. */
export const UP_SHORT_VIDEO_TAB_ACTIVE_COLOR: string = '#ddd';
export const UP_SHORT_VIDEO_TAB_INACTIVE_COLOR: string = '#bbb';
/** 上游作者区与操作区的取色。/ Author and action colors from the upstream scss. */
export const UP_SHORT_VIDEO_TEXT_COLOR: string = '#eee';
export const UP_SHORT_VIDEO_DESC_COLOR: string = 'rgba(255, 255, 255, 0.8)';
/** 上游进度条的取色。/ Progress colors from the upstream slider. */
export const UP_SHORT_VIDEO_PROGRESS_ACTIVE: string = 'rgba(255,255,255,0.32)';
export const UP_SHORT_VIDEO_PROGRESS_INACTIVE: string = 'rgba(255,255,255,0.3)';
export const UP_SHORT_VIDEO_PROGRESS_BLOCK: string = 'rgba(255,255,255,0.5)';
/** 上游头部与底部的背景。/ Header and tabbar backdrops. */
export const UP_SHORT_VIDEO_HEADER_BACKGROUND: string = 'rgba(255, 255, 255, 0.05)';
export const UP_SHORT_VIDEO_TABBAR_BORDER: string = 'rgba(255,255,255,0.25)';
/** 上游作者区与操作区距底部的偏移。/ Bottom offset of the author and action rails. */
export const UP_SHORT_VIDEO_RAIL_BOTTOM: number = 100;
/** 上游 action 图标尺寸与头像尺寸。/ Action icon size and avatar size. */
export const UP_SHORT_VIDEO_ACTION_ICON_SIZE: number = 32;
export const UP_SHORT_VIDEO_AVATAR_SIZE: number = 50;
/** 倍速弹窗标题。/ Title of the speed sheet. */
export const UP_SHORT_VIDEO_SPEED_TITLE: string = '播放速度';

/** 作者信息，替代上游 item.author。/ Author info replacing upstream item.author. */
export interface UPShortVideoAuthor {
  name?: string;
  desc?: string;
  avatar?: string;
}

/** 单条视频，替代上游 videoList 的任意对象。/ One video entry replacing the upstream object. */
export interface UPShortVideoItem {
  videoUrl?: string;
  poster?: string;
  author?: UPShortVideoAuthor;
  likeCount?: UPRawValue;
  commentCount?: UPRawValue;
  shareCount?: UPRawValue;
  collectCount?: UPRawValue;
  isLiked?: boolean;
  isCollected?: boolean;
  playbackRate?: number;
  progress?: number;
}

/** 上游 like/comment/share/collect 事件。/ Upstream like, comment, share and collect payload. */
export interface UPShortVideoActionEvent {
  item: UPShortVideoItem;
  index: number;
}

/** 上游 progressChanging/progressChange 事件。/ Upstream progress payload. */
export interface UPShortVideoProgressEvent {
  progress: number;
  index: number;
}

/** 上游 videoPlay/videoPause/videoEnded 事件。/ Upstream playback payload. */
export interface UPShortVideoPlaybackEvent {
  index: number;
  src: string;
}

/** 上游 timeUpdate 事件。/ Upstream timeUpdate payload. */
export interface UPShortVideoTimeEvent {
  index: number;
  currentTime: number;
  duration: number;
  progress: number;
}

/** 倍速变更事件，对应上游 selectSpeed。/ Playback rate payload mirroring selectSpeed. */
export interface UPShortVideoSpeedEvent {
  index: number;
  rate: number;
}

/** 上游 item.author 的具名读取。/ Named author lookup. */
export function upShortVideoAuthorName(item: UPShortVideoItem): string {
  const author: UPShortVideoAuthor | undefined = item.author;
  return author === undefined ? '' : (author.name ?? '');
}

export function upShortVideoAuthorDesc(item: UPShortVideoItem): string {
  const author: UPShortVideoAuthor | undefined = item.author;
  return author === undefined ? '' : (author.desc ?? '');
}

export function upShortVideoAuthorAvatar(item: UPShortVideoItem): string {
  const author: UPShortVideoAuthor | undefined = item.author;
  return author === undefined ? '' : (author.avatar ?? '');
}

/** 上游 `item.playbackRate || 1.0`。/ Mirrors the upstream playbackRate fallback. */
export function upShortVideoRate(item: UPShortVideoItem): number {
  const rate: number | undefined = item.playbackRate;
  return rate === undefined || !Number.isFinite(rate) || rate <= 0 ? 1 : rate;
}

/** 上游 onTimeUpdate 的百分比换算。/ Mirrors the upstream progress computation. */
export function upShortVideoProgress(currentTime: number, duration: number): number {
  if (!Number.isFinite(duration) || duration <= 0) {
    return 0;
  }
  const percent: number = currentTime / duration * 100;
  return Math.min(100, Math.max(0, percent));
}

/** 倍速是否落在上游列表内。/ Whether the rate is one of the upstream options. */
export function upShortVideoSpeedSupported(rate: number): boolean {
  return UP_SHORT_VIDEO_SPEEDS.includes(rate);
}

/** 上游 speedOptions 的展示文案。/ Label of one upstream speed option. */
export function upShortVideoSpeedLabel(rate: number): string {
  return (rate === 1 ? '1.0' : String(rate)) + 'x';
}

/** 上游默认 tabsList 转组件模型。/ Lifts the default tabsList into the tabs model. */
export function upShortVideoTabs(names: Array<string>): Array<UPTabsItemData> {
  return names.map((name: string): UPTabsItemData => {
    return { name: name };
  });
}

/** 上游底部导航的四项。/ Builds the four upstream tabbar entries. */
export function upShortVideoTabbarItems(): Array<UPTabbarItemData> {
  const items: Array<UPTabbarItemData> = [];
  for (let index: number = 0; index < UP_SHORT_VIDEO_TABBAR_TEXTS.length; index++) {
    items.push({ name: UP_SHORT_VIDEO_TABBAR_TEXTS[index], icon: UP_SHORT_VIDEO_TABBAR_ICONS[index] });
  }
  return items;
}

/** 数量文案。/ Renders one counter value. */
export function upShortVideoCount(value: UPRawValue): string {
  if (value === null || value === undefined) {
    return '0';
  }
  return String(value);
}

export interface UPShortVideoOptions {
  tabsList?: Array<UPRawValue>;
  videoList?: Array<UPShortVideoItem>;
  currentTab?: UPRawValue;
  currentVideo?: UPRawValue;
  autoPlay?: UPRawValue;
  loop?: UPRawValue;
  muted?: UPRawValue;
  showTabbar?: UPRawValue;
  showProgress?: UPRawValue;
  showSpeedEntry?: UPRawValue;
  followText?: UPRawValue;
  height?: UPRawValue;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onTabChange?: (index: number) => void;
  onVideoChange?: (index: number) => void;
  onLike?: (event: UPShortVideoActionEvent) => void;
  onComment?: (event: UPShortVideoActionEvent) => void;
  onShare?: (event: UPShortVideoActionEvent) => void;
  onCollect?: (event: UPShortVideoActionEvent) => void;
  onFollow?: (event: UPShortVideoActionEvent) => void;
  onProgressChanging?: (event: UPShortVideoProgressEvent) => void;
  onProgressChange?: (event: UPShortVideoProgressEvent) => void;
  onVideoPlay?: (event: UPShortVideoPlaybackEvent) => void;
  onVideoPause?: (event: UPShortVideoPlaybackEvent) => void;
  onVideoEnded?: (event: UPShortVideoPlaybackEvent) => void;
  onTimeUpdate?: (event: UPShortVideoTimeEvent) => void;
  onLoadedMetadata?: (event: UPShortVideoTimeEvent) => void;
  onSpeedChange?: (event: UPShortVideoSpeedEvent) => void;
  onTabbarChange?: (event: UPTabbarChangeEvent) => void;
  menuBuilder?: () => void;
  searchBuilder?: () => void;
  actionsBuilder?: () => void;
  tabbarBuilder?: () => void;
}

export class UPShortVideoProps {
  tabsList: Array<UPRawValue> = UP_SHORT_VIDEO_TABS.slice();
  videoList: Array<UPShortVideoItem> = [];
  currentTab: UPRawValue = 0;
  currentVideo: UPRawValue = 0;
  autoPlay: UPRawValue = true;
  loop: UPRawValue = true;
  muted: UPRawValue = false;
  showTabbar: UPRawValue = true;
  showProgress: UPRawValue = true;
  showSpeedEntry: UPRawValue = false;
  followText: UPRawValue = '关注';
  height: UPRawValue = 560;
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  onTabChange?: (index: number) => void;
  onVideoChange?: (index: number) => void;
  onLike?: (event: UPShortVideoActionEvent) => void;
  onComment?: (event: UPShortVideoActionEvent) => void;
  onShare?: (event: UPShortVideoActionEvent) => void;
  onCollect?: (event: UPShortVideoActionEvent) => void;
  onFollow?: (event: UPShortVideoActionEvent) => void;
  onProgressChanging?: (event: UPShortVideoProgressEvent) => void;
  onProgressChange?: (event: UPShortVideoProgressEvent) => void;
  onVideoPlay?: (event: UPShortVideoPlaybackEvent) => void;
  onVideoPause?: (event: UPShortVideoPlaybackEvent) => void;
  onVideoEnded?: (event: UPShortVideoPlaybackEvent) => void;
  onTimeUpdate?: (event: UPShortVideoTimeEvent) => void;
  onLoadedMetadata?: (event: UPShortVideoTimeEvent) => void;
  onSpeedChange?: (event: UPShortVideoSpeedEvent) => void;
  onTabbarChange?: (event: UPTabbarChangeEvent) => void;
  menuBuilder?: () => void;
  searchBuilder?: () => void;
  actionsBuilder?: () => void;
  tabbarBuilder?: () => void;

  constructor(options?: UPShortVideoOptions) {
    if (options === undefined) {
      return;
    }
    this.tabsList = options.tabsList ?? this.tabsList;
    this.videoList = options.videoList ?? this.videoList;
    this.currentTab = options.currentTab ?? this.currentTab;
    this.currentVideo = options.currentVideo ?? this.currentVideo;
    this.autoPlay = options.autoPlay ?? this.autoPlay;
    this.loop = options.loop ?? this.loop;
    this.muted = options.muted ?? this.muted;
    this.showTabbar = options.showTabbar ?? this.showTabbar;
    this.showProgress = options.showProgress ?? this.showProgress;
    this.showSpeedEntry = options.showSpeedEntry ?? this.showSpeedEntry;
    this.followText = options.followText ?? this.followText;
    this.height = options.height ?? this.height;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onTabChange = options.onTabChange;
    this.onVideoChange = options.onVideoChange;
    this.onLike = options.onLike;
    this.onComment = options.onComment;
    this.onShare = options.onShare;
    this.onCollect = options.onCollect;
    this.onFollow = options.onFollow;
    this.onProgressChanging = options.onProgressChanging;
    this.onProgressChange = options.onProgressChange;
    this.onVideoPlay = options.onVideoPlay;
    this.onVideoPause = options.onVideoPause;
    this.onVideoEnded = options.onVideoEnded;
    this.onTimeUpdate = options.onTimeUpdate;
    this.onLoadedMetadata = options.onLoadedMetadata;
    this.onSpeedChange = options.onSpeedChange;
    this.onTabbarChange = options.onTabbarChange;
    this.menuBuilder = options.menuBuilder;
    this.searchBuilder = options.searchBuilder;
    this.actionsBuilder = options.actionsBuilder;
    this.tabbarBuilder = options.tabbarBuilder;
  }
}

/** 右侧操作项模型。/ One entry of the right-hand action rail. */
class UPShortVideoAction {
  action: string = '';
  icon: string = '';
  label: string = '';

  constructor(action: string, icon: string, label: string) {
    this.action = action;
    this.icon = icon;
    this.label = label;
  }
}

/**
 * u-short-video 的 HarmonyOS 原生实现：纵向 Swiper 加原生 Video，播放控制走 VideoController。
 * Native u-short-video: a vertical Swiper of ArkUI Video elements driven by VideoController.
 */
@Component
export struct UPShortVideo {
  @Prop @Watch('applyProps') props: UPShortVideoProps = new UPShortVideoProps();
  @State private activeTab: number = 0;
  @State private videoIndex: number = 0;
  @State private progress: number = 0;
  @State private speedVisible: boolean = false;
  @State private rate: number = 1;
  private applied: string = '';
  private controller: VideoController = new VideoController();

  @Builder
  private emptyBuilder() {
    Row().width(0).height(0)
  }

  @Builder
  private defaultMenu() {
    UPIcon({ props: new UPIconProps({ name: 'grid', size: 24, color: UP_SHORT_VIDEO_TEXT_COLOR }) })
  }

  @Builder
  private defaultSearch() {
    UPIcon({ props: new UPIconProps({ name: 'search', size: 24, color: UP_SHORT_VIDEO_TEXT_COLOR }) })
  }

  @BuilderParam menuBuilder: () => void = this.defaultMenu;
  @BuilderParam searchBuilder: () => void = this.defaultSearch;
  @BuilderParam actionsBuilder: () => void = this.emptyBuilder;
  @BuilderParam tabbarBuilder: () => void = this.emptyBuilder;

  aboutToAppear(): void {
    this.applied = this.signature();
    this.activeTab = this.tabValue();
    this.videoIndex = this.videoValue();
    this.rate = upShortVideoRate(this.currentItem());
    this.progress = this.currentProgress();
    this.reportBoundaries();
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.activeTab = this.tabValue();
    if (this.videoIndex !== this.videoValue()) {
      this.videoIndex = this.videoValue();
      this.progress = this.currentProgress();
      this.rate = upShortVideoRate(this.currentItem());
    }
    this.reportBoundaries();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    return String(this.tabValue()) + '|' + String(this.videoValue()) + '|'
      + String(this.props.videoList.length) + '|' + String(this.props.tabsList.length);
  }

  private reportBoundaries(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    diagnostics.report('UPShortVideo', 'videoUrl', '',
      'only local sources play; remote addresses render the poster placeholder instead');
    diagnostics.report('UPShortVideo', 'enableProgressGesture', '',
      'the upstream progress gesture is replaced by the bottom slider because ArkUI Video has no equivalent flag');
    diagnostics.report('UPShortVideo', 'createVideoContext', '',
      'playback control uses a single VideoController bound to the active page instead of per-index contexts');
  }

  private tabValue(): number {
    const index: number = Math.floor(upNumber(this.props.currentTab, 0));
    const total: number = this.props.tabsList.length;
    if (total === 0) {
      return 0;
    }
    return Math.min(Math.max(0, index), total - 1);
  }

  private videoValue(): number {
    const index: number = Math.floor(upNumber(this.props.currentVideo, 0));
    const total: number = this.props.videoList.length;
    if (total === 0) {
      return 0;
    }
    return Math.min(Math.max(0, index), total - 1);
  }

  private currentItem(): UPShortVideoItem {
    if (this.videoIndex < this.props.videoList.length) {
      return this.props.videoList[this.videoIndex];
    }
    return {};
  }

  private currentProgress(): number {
    const value: number | undefined = this.currentItem().progress;
    return value === undefined || !Number.isFinite(value) ? 0 : Math.min(100, Math.max(0, value));
  }

  private currentSource(): string {
    return this.currentItem().videoUrl ?? '';
  }

  private videoIndexes(): Array<number> {
    const indexes: Array<number> = [];
    for (let index: number = 0; index < this.props.videoList.length; index++) {
      indexes.push(index);
    }
    return indexes;
  }

  private tabItems(): Array<UPTabsItemData> {
    const names: Array<string> = [];
    for (const value of this.props.tabsList) {
      names.push(value === null || value === undefined ? '' : String(value));
    }
    return upShortVideoTabs(names);
  }

  private speedActions(): Array<UPActionSheetAction> {
    const actions: Array<UPActionSheetAction> = [];
    for (const rate of UP_SHORT_VIDEO_SPEEDS) {
      actions.push({ name: upShortVideoSpeedLabel(rate) });
    }
    return actions;
  }

  private actionRail(item: UPShortVideoItem): Array<UPShortVideoAction> {
    return [
      new UPShortVideoAction('like', item.isLiked === true ? 'thumb-up-fill' : 'thumb-up',
        upShortVideoCount(item.likeCount)),
      new UPShortVideoAction('comment', 'chat', upShortVideoCount(item.commentCount)),
      new UPShortVideoAction('share', 'share', upShortVideoCount(item.shareCount)),
      new UPShortVideoAction('collect', item.isCollected === true ? 'bookmark-fill' : 'bookmark',
        upShortVideoCount(item.collectCount))
    ];
  }

  /** 上游 handleTabChange()。/ Mirrors upstream handleTabChange(). */
  private changeTab(index: number): void {
    this.activeTab = index;
    this.props.onTabChange?.(index);
  }

  /** 上游 handleSwiperChange()：先暂停旧视频再播放新视频。/ Mirrors upstream handleSwiperChange(). */
  private changeVideo(index: number): void {
    this.controller.pause();
    this.videoIndex = index;
    this.progress = this.currentProgress();
    this.rate = upShortVideoRate(this.currentItem());
    if (upBoolean(this.props.autoPlay, true)) {
      this.controller.start();
    }
    this.props.onVideoChange?.(index);
  }

  private dispatchAction(action: string, item: UPShortVideoItem, index: number): void {
    const event: UPShortVideoActionEvent = { item: item, index: index };
    if (action === 'like') {
      this.props.onLike?.(event);
      return;
    }
    if (action === 'comment') {
      this.props.onComment?.(event);
      return;
    }
    if (action === 'share') {
      this.props.onShare?.(event);
      return;
    }
    this.props.onCollect?.(event);
  }

  /** 上游 onProgressChanging()。/ Mirrors upstream onProgressChanging(). */
  private progressChanging(value: number): void {
    this.progress = value;
    this.props.onProgressChanging?.({ progress: value, index: this.videoIndex });
  }

  /** 上游 onProgressChange()：拖动结束后 seek。/ Mirrors upstream onProgressChange() and seeks. */
  private progressChanged(value: number): void {
    this.progress = value;
    this.props.onProgressChange?.({ progress: value, index: this.videoIndex });
  }

  /** 上游 selectSpeed()。/ Mirrors upstream selectSpeed(). */
  private selectSpeed(event: UPActionSheetSelectEvent): void {
    const rate: number = UP_SHORT_VIDEO_SPEEDS[event.index] ?? 1;
    this.rate = rate;
    this.speedVisible = false;
    if (!upShortVideoSpeedSupported(rate)) {
      this.diagnostics().report('UPShortVideo', 'playbackRate', rate,
        'only the upstream speed options are offered: 0.5, 0.75, 1.0, 1.25, 1.5 and 2.0');
    }
    this.props.onSpeedChange?.({ index: this.videoIndex, rate: rate });
  }

  /** 上游 onTimeUpdate()。/ Mirrors upstream onTimeUpdate(). */
  private timeUpdate(currentTime: number, duration: number): void {
    const percent: number = upShortVideoProgress(currentTime, duration);
    this.progress = percent;
    this.props.onTimeUpdate?.({
      index: this.videoIndex,
      currentTime: currentTime,
      duration: duration,
      progress: percent
    });
  }

  /** 命令式播放，供宿主复用上游 playVideo()。/ Imperative start mirroring upstream playVideo(). */
  play(): void {
    this.controller.start();
  }

  /** 命令式暂停，供宿主复用上游 pauseCurrentVideo()。/ Imperative pause mirroring pauseCurrentVideo(). */
  pause(): void {
    this.controller.pause();
  }

  @Builder
  private header() {
    Row() {
      Column() {
        this.menuBuilder()
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      UPTabs({
        props: new UPTabsProps({
          list: this.tabItems(),
          current: this.activeTab,
          lineColor: UP_SHORT_VIDEO_TAB_ACTIVE_COLOR,
          activeStyle: { color: UP_SHORT_VIDEO_TAB_ACTIVE_COLOR, fontWeight: 400 },
          inactiveStyle: { color: UP_SHORT_VIDEO_TAB_INACTIVE_COLOR },
          onCurrentChange: (index: number): void => this.changeTab(index)
        })
      })
      Column() {
        this.searchBuilder()
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding({ top: 10, right: 15, bottom: 10, left: 15 })
    .backgroundColor(UP_SHORT_VIDEO_HEADER_BACKGROUND)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private authorRail(item: UPShortVideoItem, index: number) {
    Row({ space: 10 }) {
      UPAvatar({
        props: new UPAvatarProps({
          src: upShortVideoAuthorAvatar(item),
          size: UP_SHORT_VIDEO_AVATAR_SIZE,
          text: upShortVideoAuthorName(item)
        })
      })
      Column({ space: 5 }) {
        Text(upShortVideoAuthorName(item))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(UP_SHORT_VIDEO_TEXT_COLOR)
        Text(upShortVideoAuthorDesc(item))
          .fontSize(14)
          .fontColor(UP_SHORT_VIDEO_DESC_COLOR)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      UPButton({
        props: new UPButtonProps({
          type: 'primary',
          size: 'mini',
          text: upString(this.props.followText, '关注'),
          onClick: (): void => {
            this.props.onFollow?.({ item: item, index: index });
          }
        })
      })
    }
    .width('100%')
    .padding({ left: 15, right: 15 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private actionColumn(item: UPShortVideoItem, index: number) {
    Column({ space: 20 }) {
      ForEach(this.actionRail(item), (entry: UPShortVideoAction) => {
        Column({ space: 5 }) {
          UPIcon({
            props: new UPIconProps({
              name: entry.icon,
              size: UP_SHORT_VIDEO_ACTION_ICON_SIZE,
              color: UP_SHORT_VIDEO_TEXT_COLOR
            })
          })
          Text(entry.label)
            .fontSize(12)
            .fontColor('#ffffff')
        }
        .alignItems(HorizontalAlign.Center)
        .onClick((): void => this.dispatchAction(entry.action, item, index))
      }, (entry: UPShortVideoAction): string => entry.action)
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private videoPage(index: number) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Video({
        src: this.props.videoList[index].videoUrl ?? '',
        previewUri: this.props.videoList[index].poster ?? '',
        currentProgressRate: this.rate,
        controller: this.controller
      })
        .width('100%')
        .height('100%')
        .controls(false)
        .autoPlay(index === this.videoIndex && upBoolean(this.props.autoPlay, true))
        .loop(upBoolean(this.props.loop, true))
        .muted(upBoolean(this.props.muted, false))
        .objectFit(ImageFit.Cover)
        .onStart((): void => {
          this.props.onVideoPlay?.({ index: this.videoIndex, src: this.currentSource() });
        })
        .onPause((): void => {
          this.props.onVideoPause?.({ index: this.videoIndex, src: this.currentSource() });
        })
        .onFinish((): void => {
          this.props.onVideoEnded?.({ index: this.videoIndex, src: this.currentSource() });
        })
        .onPrepared((event: PreparedInfo): void => {
          this.props.onLoadedMetadata?.({
            index: this.videoIndex,
            currentTime: 0,
            duration: event.duration,
            progress: 0
          });
        })
        .onUpdate((event: PlaybackInfo): void => {
          this.timeUpdate(event.time, 0);
        })
      Row() {
        this.authorRail(this.props.videoList[index], index)
      }
      .width('100%')
      .padding({ bottom: UP_SHORT_VIDEO_RAIL_BOTTOM })
      Column() {
        if (this.props.actionsBuilder === undefined) {
          this.actionColumn(this.props.videoList[index], index)
        } else {
          this.actionsBuilder()
        }
      }
      .width('100%')
      .padding({ right: 15, bottom: UP_SHORT_VIDEO_RAIL_BOTTOM })
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private progressBar() {
    Column() {
      UPSlider({
        props: new UPSliderProps({
          value: this.progress,
          min: 0,
          max: 100,
          step: 1,
          showValue: false,
          activeColor: UP_SHORT_VIDEO_PROGRESS_ACTIVE,
          inactiveColor: UP_SHORT_VIDEO_PROGRESS_INACTIVE,
          blockColor: UP_SHORT_VIDEO_PROGRESS_BLOCK,
          blockSize: 6,
          size: '1px',
          innerStyle: { padding: 0 },
          onChanging: (event: UPSliderChangeEvent): void => this.progressChanging(event.value),
          onChange: (event: UPSliderChangeEvent): void => this.progressChanged(event.value)
        })
      })
    }
    .width('100%')
    .zIndex(999)
  }

  @Builder
  private footer() {
    Column() {
      if (upBoolean(this.props.showProgress, true)) {
        this.progressBar()
      }
      if (this.props.tabbarBuilder === undefined) {
        if (upBoolean(this.props.showTabbar, true)) {
          UPTabbar({
            props: new UPTabbarProps({
              list: upShortVideoTabbarItems(),
              current: 0,
              fixed: false,
              placeholder: false,
              safeAreaInsetBottom: true,
              backgroundColor: UP_SHORT_VIDEO_HEADER_BACKGROUND,
              activeColor: UP_SHORT_VIDEO_TEXT_COLOR,
              inactiveColor: UP_SHORT_VIDEO_TAB_INACTIVE_COLOR,
              onChange: (event: UPTabbarChangeEvent): void => {
                this.props.onTabbarChange?.(event);
              }
            })
          })
        }
      } else {
        this.tabbarBuilder()
      }
    }
    .width('100%')
  }

  @Builder
  private speedEntry() {
    Row({ space: 4 }) {
      Text(upShortVideoSpeedLabel(this.rate))
        .fontSize(12)
        .fontColor('#ffffff')
      UPIcon({ props: new UPIconProps({ name: 'arrow-down', size: 12, color: '#ffffff' }) })
    }
    .padding({ top: 5, right: 10, bottom: 5, left: 10 })
    .backgroundColor('rgba(0, 0, 0, 0.3)')
    .borderRadius(20)
    .onClick((): void => {
      this.speedVisible = true;
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Swiper() {
        ForEach(this.videoIndexes(), (index: number) => {
          Column() {
            this.videoPage(index)
          }
          .width('100%')
          .height('100%')
        }, (index: number): string => 'video-' + String(index))
      }
      .width('100%')
      .height('100%')
      .vertical(true)
      .autoPlay(false)
      .loop(false)
      .indicator(false)
      .index(this.videoIndex)
      .onChange((index: number): void => this.changeVideo(index))
      Column() {
        this.header()
      }
      .width('100%')
      Column() {
        this.footer()
      }
      .width('100%')
      .position({ x: 0, y: '100%' })
      .translate({ y: '-100%' })
      if (upBoolean(this.props.showSpeedEntry, false)) {
        Column() {
          this.speedEntry()
        }
        .width('100%')
        .padding({ top: 60, right: 15 })
        .alignItems(HorizontalAlign.End)
      }
      UPActionSheet({
        props: new UPActionSheetProps({
          show: this.speedVisible,
          title: UP_SHORT_VIDEO_SPEED_TITLE,
          actions: this.speedActions(),
          onSelect: (event: UPActionSheetSelectEvent): void => this.selectSpeed(event),
          onClose: (): void => {
            this.speedVisible = false;
          }
        })
      })
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .height(UPStyle.parse(this.props.customStyle).height ?? Math.max(1, upNumber(this.props.height, 560)))
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? '#000000')
    .clip(true)
  }
}
