import {
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UPMarkdown,
  UPMarkdownProps,
  UPParseLinkTapEvent,
  UPSubsection,
  UPSubsectionItem,
  UPSubsectionProps,
  UPSwitch,
  UPSwitchChangeEvent,
  UPSwitchProps,
  UP_MARKDOWN_HEADING_SIZES,
  upMarkdownGutter,
  upMarkdownInline,
  upMarkdownSetextLevel,
  upMarkdownThemeSupported,
  upMarkdownToHtml
} from '@lingyun/ultra-ui-hos';

@Component
export struct MarkdownDemo {
  @State private status: string = 'markdown 由内置 ArkTS 词法解析后交给 UPParse 渲染';
  @State private boundary: string = '';
  @State private themeIndex: number = 0;
  @State private showLineNumber: boolean = false;
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private themes: Array<UPSubsectionItem> = [{ name: '浅色' }, { name: '深色' }];
  private themeNames: Array<string> = ['light', 'dark'];
  private probeThemes: Array<string> = ['light', 'dark', 'solarized'];
  private source: string = '# 一级标题\n\n'
    + '段落支持 **加粗**、*斜体*、~~删除线~~ 与 `行内代码`，还能写 [站内链接](#table)。\n\n'
    + '## 列表\n\n'
    + '- 无序项一\n'
    + '- 无序项二\n'
    + '  - 缩进两格构成二级列表\n\n'
    + '3. 有序列表从 3 开始\n'
    + '4. 下一项\n\n'
    + '## 引用与代码\n\n'
    + '> 引用块保留左侧竖线。\n\n'
    + '```ts\n'
    + 'const total: number = 1 + 2;\n'
    + 'console.info(String(total));\n'
    + '```\n\n'
    + '下划线标题\n'
    + '---\n\n'
    + '## table\n\n'
    + '| 组件 | 状态 |\n'
    + '| :--- | ---: |\n'
    + '| u-markdown | 内置词法 |\n'
    + '| marked | 未打包 |\n\n'
    + '---\n\n'
    + '![占位图](local.png)\n';

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private selectTheme(index: number): void {
    this.themeIndex = index;
    this.status = 'theme=' + this.themeNames[index] + '：切换注入的标签样式与链接色';
  }

  private toggleLineNumber(event: UPSwitchChangeEvent): void {
    this.showLineNumber = event.checked;
    this.status = event.checked
      ? 'showLineNumber=true：代码块前缀行号，右对齐后与代码同处一个文本块'
      : 'showLineNumber=false：代码块不带行号';
  }

  private handleLink(event: UPParseLinkTapEvent): void {
    this.status = 'linktap：' + event.href + (event.external ? '（外链）' : '（站内或锚点）');
  }

  private openExternal(href: string): boolean {
    this.status = 'openLink 已交给宿主处理：' + href;
    return true;
  }

  private htmlLength(): string {
    return '转换后的 html 长度 ' + String(upMarkdownToHtml(this.source, this.showLineNumber).length) + ' 字符';
  }

  private inlineSample(): string {
    return upMarkdownInline('行内示例：**bold** + `code`');
  }

  private gutterSample(): string {
    return upMarkdownGutter('第一行\n第二行').replace(/\n/g, ' ⏎ ');
  }

  private headingText(): string {
    const sizes: Array<string> = [];
    for (const size of UP_MARKDOWN_HEADING_SIZES) {
      sizes.push(String(size) + 'px');
    }
    return 'h1~h6 字号：' + sizes.join('、');
  }

  private setextText(): string {
    return '下划线标题层级：=== 对应 h' + String(upMarkdownSetextLevel('==='))
      + '，--- 对应 h' + String(upMarkdownSetextLevel('---'));
  }

  private probeText(theme: string): string {
    return 'theme=' + theme + (upMarkdownThemeSupported(theme)
      ? '：上游样式表有对应分支'
      : '：上游没有对应类名，本端回落浅色并报诊断');
  }

  build() {
    Column({ space: 16 }) {
      Text('Markdown 渲染')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPSubsection({
        props: new UPSubsectionProps({
          list: this.themes,
          current: this.themeIndex,
          onChange: (index: number): void => {
            this.selectTheme(index);
          }
        })
      })
      Row({ space: 10 }) {
        Text('代码块行号').fontSize(13).fontColor('#606266')
        UPSwitch({
          props: new UPSwitchProps({
            modelValue: this.showLineNumber,
            size: 22,
            onChange: (event: UPSwitchChangeEvent): void => {
              this.toggleLineNumber(event);
            }
          })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      UPMarkdown({
        props: new UPMarkdownProps({
          content: this.source,
          theme: this.themeNames[this.themeIndex],
          showLineNumber: this.showLineNumber,
          selectable: true,
          scrollTable: true,
          customStyle: { height: 360 },
          diagnostics: this.diagnostics,
          openLink: (href: string): boolean => {
            return this.openExternal(href);
          },
          onLinkTap: (event: UPParseLinkTapEvent): void => {
            this.handleLink(event);
          }
        })
      })
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('转换结果自检')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.htmlLength()).fontSize(12).fontColor('#909399').width('100%')
      Text('行内转换：' + this.inlineSample()).fontSize(12).fontColor('#909399').width('100%')
      Text('行号槽：' + this.gutterSample()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.headingText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.setextText()).fontSize(12).fontColor('#909399').width('100%')
      ForEach(this.probeThemes, (theme: string): void => {
        Text(this.probeText(theme)).fontSize(12).fontColor('#909399').width('100%')
      }, (theme: string): string => theme)
      Text('上游 applyTheme 原样返回 html，主题只影响注入到 UPParse 的标签样式。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('上游打包的 marked 未随组件移植，标题、列表、表格、代码块等语法由内置词法覆盖。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
