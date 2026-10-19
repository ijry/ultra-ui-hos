import {
  UPButton,
  UPButtonProps,
  UPCell,
  UPCellGroup,
  UPCellGroupProps,
  UPCellProps,
  UPColor,
  UPSection,
  UPSectionProps,
  UPTag,
  UPTagProps,
  UPThemeManager,
  UPThemeOverride,
  UPThemeSnapshot,
  upModeValue
} from '@lingyun/ultra-ui-hos';

/** 一行令牌对照。/ One token rendered across both modes. */
interface ThemeRow {
  token: string;
  light: string;
  dark: string;
  active: string;
}

@Component
export struct ThemeDemo {
  @State private mode: string = UPThemeManager.mode();
  @State private preference: string = UPThemeManager.preference();
  @State private version: number = UPThemeManager.snapshot().version;
  @State private overridden: boolean = false;
  private readonly sampleTokens: Array<string> = [
    'primary',
    'main-color',
    'content-color',
    'tips-color',
    'border-color',
    'bg-color',
    'card-bg-color',
    'table2-header-bg-color',
    'skeleton-bg-color'
  ];

  aboutToAppear(): void {
    UPThemeManager.addListener((snapshot: UPThemeSnapshot): void => {
      this.mode = snapshot.mode;
      this.preference = snapshot.preference;
      this.version = snapshot.version;
    });
  }

  aboutToDisappear(): void {
    UPThemeManager.clearListeners();
  }

  private rows(): Array<ThemeRow> {
    const list: Array<ThemeRow> = [];
    for (let index: number = 0; index < this.sampleTokens.length; index++) {
      const token: string = this.sampleTokens[index];
      list.push({
        token,
        light: UPThemeManager.tokenFor('light', token),
        dark: UPThemeManager.tokenFor('dark', token),
        active: UPThemeManager.token(token)
      });
    }
    return list;
  }

  private pageBackground(): string {
    return UPColor.token('bg-color', '#f3f4f6');
  }

  private cardBackground(): string {
    return UPColor.token('card-bg-color', '#ffffff');
  }

  private mainColor(): string {
    return UPColor.token('main-color', '#303133');
  }

  private tipsColor(): string {
    return UPColor.token('tips-color', '#909193');
  }

  private hairline(): string {
    return UPColor.token('border-color', '#dadbde');
  }

  /** 演示令牌覆盖：把主色换成品牌紫。/ Overrides the primary token. */
  private toggleOverride(): void {
    if (this.overridden) {
      UPThemeManager.clearOverrides();
      this.overridden = false;
      return;
    }
    const overrides: Array<UPThemeOverride> = [
      { token: 'primary', value: '#7d5fff' },
      { token: 'up-border-color', value: '#7d5fff' }
    ];
    UPThemeManager.setOverrides(overrides);
    this.overridden = true;
  }

  @Builder
  private sectionTitle(text: string) {
    Text(text)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.mainColor())
      .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      this.sectionTitle('模式与偏好')
      Row({ space: 8 }) {
        UPButton({ props: new UPButtonProps({
          text: '浅色',
          type: this.mode === 'light' ? 'primary' : 'info',
          plain: this.mode !== 'light',
          onClick: (): void => {
            UPThemeManager.setMode('light');
          }
        }) })
        UPButton({ props: new UPButtonProps({
          text: '深色',
          type: this.mode === 'dark' ? 'primary' : 'info',
          plain: this.mode !== 'dark',
          onClick: (): void => {
            UPThemeManager.setMode('dark');
          }
        }) })
        UPButton({ props: new UPButtonProps({
          text: '跟随系统',
          type: this.preference === 'system' ? 'primary' : 'info',
          plain: this.preference !== 'system',
          onClick: (): void => {
            UPThemeManager.setPreference('system', 'dark');
          }
        }) })
      }
      .width('100%')
      Text('mode=' + this.mode + ' preference=' + this.preference + ' version=' + String(this.version))
        .fontSize(12)
        .fontColor(this.tipsColor())
        .width('100%')
      Text('跟随系统时由宿主把系统模式传进 setPreference() 或 systemModeChanged()，组件库不探测平台主题。')
        .fontSize(12)
        .fontColor(this.tipsColor())
        .width('100%')

      this.sectionTitle('令牌对照')
      Row() {
        Text('令牌').fontSize(11).fontColor(this.tipsColor()).layoutWeight(4)
        Text('light').fontSize(11).fontColor(this.tipsColor()).layoutWeight(3)
        Text('dark').fontSize(11).fontColor(this.tipsColor()).layoutWeight(3)
        Text('当前').fontSize(11).fontColor(this.tipsColor()).layoutWeight(2)
      }
      .width('100%')
      .padding({ bottom: 4 })
      .border({ width: { bottom: 1 }, color: this.hairline() })
      ForEach(this.rows(), (row: ThemeRow) => {
        Row() {
          Text(row.token).fontSize(11).fontColor(this.tipsColor()).layoutWeight(4)
          Text(row.light).fontSize(11).fontColor(this.mainColor()).layoutWeight(3)
          Text(row.dark).fontSize(11).fontColor(this.mainColor()).layoutWeight(3)
          Row() {
            Column()
              .width(16)
              .height(16)
              .backgroundColor(row.active)
              .borderRadius(3)
              .borderWidth(1)
              .borderColor(this.hairline())
          }
          .layoutWeight(2)
        }
        .width('100%')
        .padding({ top: 4, bottom: 4 })
      }, (row: ThemeRow): string => row.token)
      Text('共 ' + String(UPThemeManager.tokens().length) + ' 个令牌，取值与上游 theme.js 的 CSS 变量逐值一致。')
        .fontSize(12)
        .fontColor(this.tipsColor())
        .width('100%')

      this.sectionTitle('组件随模式切换')
      UPCellGroup({ props: new UPCellGroupProps({ title: '账号', inset: true }) }) {
        UPCell({ props: new UPCellProps({ title: '昵称', value: 'UltraUI', arrow: true }) })
        UPCell({ props: new UPCellProps({ title: '主题', value: this.mode === 'dark' ? '深色' : '浅色', arrow: true }) })
      }
      UPSection({ props: new UPSectionProps({ title: '区块标题' }) })
      Row({ space: 8 }) {
        UPTag({ props: new UPTagProps({ text: '主要', type: 'primary' }) })
        UPTag({ props: new UPTagProps({ text: '成功', type: 'success' }) })
        UPTag({ props: new UPTagProps({ text: '警告', type: 'warning' }) })
      }
      .width('100%')
      Text('容器背景 ' + this.cardBackground() + ' / 页面背景 ' + this.pageBackground())
        .fontSize(12)
        .fontColor(this.tipsColor())
        .width('100%')

      this.sectionTitle('令牌覆盖')
      UPButton({ props: new UPButtonProps({
        text: this.overridden ? '撤销覆盖' : '把主色换成 #7d5fff',
        type: 'primary',
        onClick: (): void => {
          this.toggleOverride();
        }
      }) })
      Text('覆盖等价于上游 config.color，跨明暗模式生效；' + upModeValue('当前浅色', '当前深色'))
        .fontSize(12)
        .fontColor(this.tipsColor())
        .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.pageBackground())
    .alignItems(HorizontalAlign.Start)
  }
}
