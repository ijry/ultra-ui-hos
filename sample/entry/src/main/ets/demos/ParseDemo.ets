import {
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UPHtmlDeclaration,
  UPParse,
  UPParseController,
  UPParseErrorEvent,
  UPParseImageTapEvent,
  UPParseLinkTapEvent,
  UPParseMediaEvent,
  UPParseProps,
  UPParseReadyEvent,
  upHtmlNodesText,
  upHtmlParse
} from '@lingyun/ultra-ui-hos';

@Component
export struct ParseDemo {
  @State private status: string = '富文本已解析为原生块，不使用 rich-text 或浏览器内核';
  @State private boundary: string = '';
  @State private selectable: boolean = false;
  private controller: UPParseController = new UPParseController();
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private tagStyle: Array<UPHtmlDeclaration> = [
    new UPHtmlDeclaration('p', 'margin:6px 0;line-height:1.6em'),
    new UPHtmlDeclaration('h3', 'font-size:18px;margin:8px 0;font-weight:bold')
  ];
  private content: string = '<h3 id="top">标题与段落</h3>'
    + '<p>支持 <strong>加粗</strong>、<em>斜体</em>、<del>删除线</del>、<code>行内代码</code> 与 '
    + '<a href="#list">锚点链接</a>。</p>'
    + '<blockquote>引用块沿用左侧竖线与灰色文字。</blockquote>'
    + '<h3 id="list">列表与表格</h3>'
    + '<ul><li>无序项一</li><li>无序项二<ul><li>二级嵌套</li></ul></li></ul>'
    + '<ol start="3"><li>有序从 3 开始</li><li>下一项</li></ol>'
    + '<table border="1"><thead><tr><th>组件</th><th>状态</th></tr></thead>'
    + '<tbody><tr><td>u-parse</td><td>原生块渲染</td></tr>'
    + '<tr><td>video</td><td>占位块</td></tr></tbody></table>'
    + '<hr>'
    + '<p>被过滤的标签会记录诊断：<script>ignored()</script><iframe></iframe></p>'
    + '<video src="local.mp4" poster="poster.png"></video>';
  private appended: string = '<p id="tail">这一段通过 controller.setContent(content, true) 追加。</p>';

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private handleImage(event: UPParseImageTapEvent): void {
    this.status = 'imgtap：index=' + String(event.index) + '，src=' + event.src;
  }

  private handleLink(event: UPParseLinkTapEvent): void {
    this.status = 'linktap：' + event.href + (event.external ? '（外链）' : '（站内或锚点）');
  }

  private handlePlay(event: UPParseMediaEvent): void {
    this.status = 'play：' + event.source + ' 占位块被点击，src=' + event.src;
  }

  private handleError(event: UPParseErrorEvent): void {
    this.status = 'error：' + event.source + ' ' + event.message;
  }

  private handleReady(event: UPParseReadyEvent): void {
    this.status = 'ready：根节点宽 ' + String(Math.round(event.width)) + '，高 ' + String(Math.round(event.height));
  }

  private openExternal(href: string): boolean {
    this.status = 'openLink 已交给宿主处理：' + href;
    return true;
  }

  private appendContent(): void {
    this.controller.setContent(this.appended, true);
    this.status = '已追加一段内容，图片索引在原有基础上继续累加';
  }

  private resetContent(): void {
    this.controller.setContent(this.content, false);
    this.status = '已整段替换回初始内容';
  }

  private jumpToTail(): void {
    this.controller.scrollToAnchor('tail', 0);
    this.status = 'scrollToAnchor(tail) 需要 containerStyle 指定高度才会滚动';
  }

  private plainText(): string {
    return upHtmlNodesText(upHtmlParse(this.content).nodes).trim();
  }

  private droppedText(): string {
    const dropped: Array<string> = upHtmlParse(this.content).dropped;
    return dropped.length > 0 ? '被解析器丢弃的标签：' + dropped.join('、') : '没有标签被丢弃';
  }

  private textPreview(): string {
    const text: string = this.plainText().replace(/\n+/g, ' ');
    return text.length > 60 ? text.substring(0, 60) + '…' : text;
  }

  build() {
    Column({ space: 16 }) {
      Text('富文本解析')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPParse({
        props: new UPParseProps({
          content: this.content,
          domain: 'assets',
          selectable: this.selectable,
          scrollTable: true,
          useAnchor: 8,
          tagStyle: this.tagStyle,
          containerStyle: { height: 320, backgroundColor: '#ffffff' },
          controller: this.controller,
          diagnostics: this.diagnostics,
          openLink: (href: string): boolean => {
            return this.openExternal(href);
          },
          onReady: (event: UPParseReadyEvent): void => {
            this.handleReady(event);
          },
          onImgTap: (event: UPParseImageTapEvent): void => {
            this.handleImage(event);
          },
          onLinkTap: (event: UPParseLinkTapEvent): void => {
            this.handleLink(event);
          },
          onPlay: (event: UPParseMediaEvent): void => {
            this.handlePlay(event);
          },
          onError: (event: UPParseErrorEvent): void => {
            this.handleError(event);
          }
        })
      })
      Row({ space: 10 }) {
        Button('追加内容')
          .fontSize(14)
          .height(36)
          .backgroundColor('#ecf5ff')
          .fontColor('#2979ff')
          .onClick((): void => {
            this.appendContent();
          })
        Button('整段替换')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.resetContent();
          })
        Button('滚到锚点')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.jumpToTail();
          })
      }
      .width('100%')
      Row({ space: 10 }) {
        Button(this.selectable ? '关闭文本选择' : '开启文本选择')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.selectable = !this.selectable;
            this.status = this.selectable ? 'selectable=true：文本可长按选择复制' : 'selectable=false：文本不可选择';
          })
        Button('读取纯文本')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.status = 'getText 长度 ' + String(this.controller.getText().trim().length)
              + '，图片 ' + String(this.controller.imageList().length) + ' 张';
          })
      }
      .width('100%')
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('解析结果自检')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text('纯文本预览：' + this.textPreview()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.droppedText()).fontSize(12).fontColor('#909399').width('100%')
      Text('video 与 audio 渲染为占位块，播放、图片预览与长按菜单都通过事件交给宿主。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('lazyLoad、loadingImg、errorImg、showImgMenu、pauseVideo 与 setTitle 保留为兼容字段，仅通过 diagnostics 记录。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
