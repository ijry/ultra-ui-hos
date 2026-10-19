import {
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UPShortVideo,
  UPShortVideoActionEvent,
  UPShortVideoItem,
  UPShortVideoProgressEvent,
  UPShortVideoProps,
  UPShortVideoSpeedEvent,
  UPShortVideoTimeEvent,
  UP_SHORT_VIDEO_SPEEDS,
  UP_SHORT_VIDEO_TABS,
  upShortVideoAuthorName,
  upShortVideoCount,
  upShortVideoProgress,
  upShortVideoRate,
  upShortVideoSpeedLabel,
  upShortVideoSpeedSupported
} from '@lingyun/ultra-ui-hos';

@Component
export struct ShortVideoDemo {
  @State private status: string = '纵向滑动切换视频，播放控制走原生 VideoController';
  @State private boundary: string = '';
  @State private tab: number = 0;
  @State private current: number = 0;
  @State private videos: Array<UPShortVideoItem> = [
    {
      videoUrl: '/data/storage/el2/base/files/clip-one.mp4',
      poster: '/data/storage/el2/base/files/poster-one.png',
      author: { name: '示例作者甲', desc: '第一条视频的描述文案' },
      likeCount: 128,
      commentCount: 32,
      shareCount: 8,
      collectCount: 16,
      progress: 0
    },
    {
      videoUrl: '/data/storage/el2/base/files/clip-two.mp4',
      author: { name: '示例作者乙', desc: '第二条视频没有封面图' },
      likeCount: '2.3w',
      commentCount: 640,
      shareCount: 96,
      collectCount: 220,
      isLiked: true,
      progress: 0
    },
    {
      videoUrl: 'remote-clip.mp4',
      author: { name: '示例作者丙', desc: '非本地地址会渲染封面占位' },
      likeCount: 12,
      commentCount: 3,
      shareCount: 1,
      collectCount: 0,
      isCollected: true,
      progress: 0
    }
  ];
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private probeRates: Array<number> = [0.5, 1, 1.75, 2];

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private handleAction(name: string, event: UPShortVideoActionEvent): void {
    this.status = name + '：index=' + String(event.index) + '，作者=' + upShortVideoAuthorName(event.item);
  }

  private handleProgress(event: UPShortVideoProgressEvent): void {
    this.status = '进度拖动到 ' + String(Math.round(event.progress)) + '%，index=' + String(event.index);
  }

  private handleTime(event: UPShortVideoTimeEvent): void {
    this.status = 'timeUpdate：' + String(Math.round(event.currentTime)) + 's，进度 '
      + String(Math.round(event.progress)) + '%';
  }

  private handleSpeed(event: UPShortVideoSpeedEvent): void {
    this.status = '倍速切换为 ' + upShortVideoSpeedLabel(event.rate);
  }

  private progressText(): string {
    return '30s / 120s 换算为 ' + String(Math.round(upShortVideoProgress(30, 120))) + '%，除零保护为 '
      + String(upShortVideoProgress(30, 0)) + '%';
  }

  private rateText(): string {
    return '未设置 playbackRate 时回落 ' + String(upShortVideoRate({})) + '，设置 1.5 时为 '
      + String(upShortVideoRate({ playbackRate: 1.5 }));
  }

  private countText(): string {
    return '数量文案：undefined → ' + upShortVideoCount(undefined) + '，2.3w → ' + upShortVideoCount('2.3w');
  }

  private probeText(rate: number): string {
    return '倍速 ' + upShortVideoSpeedLabel(rate) + (upShortVideoSpeedSupported(rate)
      ? '：在上游 speedOptions 内'
      : '：不在 ' + UP_SHORT_VIDEO_SPEEDS.length.toString() + ' 个上游选项内，会记录诊断');
  }

  build() {
    Column({ space: 16 }) {
      Text('短视频信息流')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPShortVideo({
        props: new UPShortVideoProps({
          tabsList: UP_SHORT_VIDEO_TABS,
          videoList: this.videos,
          currentTab: this.tab,
          currentVideo: this.current,
          autoPlay: false,
          showSpeedEntry: true,
          height: 480,
          diagnostics: this.diagnostics,
          onTabChange: (index: number): void => {
            this.tab = index;
            this.status = '切换到标签：' + String(UP_SHORT_VIDEO_TABS[index]);
          },
          onVideoChange: (index: number): void => {
            this.current = index;
            this.status = '切换到第 ' + String(index + 1) + ' 条视频';
          },
          onLike: (event: UPShortVideoActionEvent): void => {
            this.handleAction('点赞', event);
          },
          onComment: (event: UPShortVideoActionEvent): void => {
            this.handleAction('评论', event);
          },
          onShare: (event: UPShortVideoActionEvent): void => {
            this.handleAction('分享', event);
          },
          onCollect: (event: UPShortVideoActionEvent): void => {
            this.handleAction('收藏', event);
          },
          onFollow: (event: UPShortVideoActionEvent): void => {
            this.handleAction('关注', event);
          },
          onProgressChange: (event: UPShortVideoProgressEvent): void => {
            this.handleProgress(event);
          },
          onTimeUpdate: (event: UPShortVideoTimeEvent): void => {
            this.handleTime(event);
          },
          onSpeedChange: (event: UPShortVideoSpeedEvent): void => {
            this.handleSpeed(event);
          }
        })
      })
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('取值自检')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.progressText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.rateText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.countText()).fontSize(12).fontColor('#909399').width('100%')
      ForEach(this.probeRates, (rate: number): void => {
        Text(this.probeText(rate)).fontSize(12).fontColor('#909399').width('100%')
      }, (rate: number): string => String(rate))
      Text('上游按 index 创建多个 videoContext，本端改用单个 VideoController 绑定当前页。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('enable-progress-gesture 在 ArkUI 无对应开关，进度调整交给底部滑块。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
