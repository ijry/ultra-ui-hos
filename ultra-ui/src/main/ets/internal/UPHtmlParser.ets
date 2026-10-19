/**
 * 上游 u-parse 的 mp-html v2.5.1 词法分析与节点树构建的 ArkTS 移植。
 * ArkTS port of the mp-html v2.5.1 lexer and node builder used by u-parse.
 */

/** 单条样式声明。/ One CSS declaration. */
export class UPHtmlDeclaration {
  key: string = '';
  value: string = '';

  constructor(key: string, value: string) {
    this.key = key;
    this.value = value;
  }
}

/** 上游 attrs 对象改成具名字段，避免索引签名。/ Named attribute model instead of an index signature. */
export class UPHtmlAttrs {
  id: string = '';
  src: string = '';
  href: string = '';
  style: string = '';
  className: string = '';
  alt: string = '';
  colspan: number = 0;
  rowspan: number = 0;
  align: string = '';
  dir: string = '';
  color: string = '';
  face: string = '';
  size: string = '';
  width: string = '';
  height: string = '';
  ignore: boolean = false;
  controls: boolean = false;
  autoplay: boolean = false;
  loop: boolean = false;
  poster: string = '';
  type: string = '';
  start: number = 0;
  border: string = '';
  cellpadding: string = '';
  cellspacing: string = '';
  bordercolor: string = '';
  dataSrc: string = '';
  originalSrc: string = '';
  /** img 与 a 标签保留的 data-* 属性。/ Retained data-* attributes for img and a. */
  extras: Array<UPHtmlDeclaration> = [];

  /** 上游 attrs[name] = value 的具名写入。/ Named replacement for attrs[name] = value. */
  setValue(name: string, value: string): void {
    switch (name) {
      case 'id': this.id = value; break;
      case 'src': this.src = value; break;
      case 'href': this.href = value; break;
      case 'style': this.style = value; break;
      case 'class': this.className = value; break;
      case 'alt': this.alt = value; break;
      case 'align': this.align = value; break;
      case 'dir': this.dir = value; break;
      case 'color': this.color = value; break;
      case 'face': this.face = value; break;
      case 'size': this.size = value; break;
      case 'width': this.width = value; break;
      case 'height': this.height = value; break;
      case 'poster': this.poster = value; break;
      case 'type': this.type = value; break;
      case 'border': this.border = value; break;
      case 'cellpadding': this.cellpadding = value; break;
      case 'cellspacing': this.cellspacing = value; break;
      case 'bordercolor': this.bordercolor = value; break;
      case 'data-src': this.dataSrc = value; break;
      case 'original-src': this.originalSrc = value; break;
      case 'colspan': this.colspan = upHtmlSpanValue(value); break;
      case 'rowspan': this.rowspan = upHtmlSpanValue(value); break;
      case 'start': this.start = upHtmlSpanValue(value); break;
      case 'ignore': this.ignore = value.length > 0; break;
      case 'controls': this.controls = value.length > 0; break;
      case 'autoplay': this.autoplay = value.length > 0; break;
      case 'loop': this.loop = value.length > 0; break;
      default: this.setExtra(name, value); break;
    }
  }

  /** 上游 attrs[name] 的具名读取，布尔属性回传 'T'。/ Named attribute read. */
  value(name: string): string {
    switch (name) {
      case 'id': return this.id;
      case 'src': return this.src;
      case 'href': return this.href;
      case 'style': return this.style;
      case 'class': return this.className;
      case 'alt': return this.alt;
      case 'align': return this.align;
      case 'dir': return this.dir;
      case 'color': return this.color;
      case 'face': return this.face;
      case 'size': return this.size;
      case 'width': return this.width;
      case 'height': return this.height;
      case 'poster': return this.poster;
      case 'type': return this.type;
      case 'border': return this.border;
      case 'cellpadding': return this.cellpadding;
      case 'cellspacing': return this.cellspacing;
      case 'bordercolor': return this.bordercolor;
      case 'data-src': return this.dataSrc;
      case 'original-src': return this.originalSrc;
      case 'colspan': return this.colspan > 0 ? String(this.colspan) : '';
      case 'rowspan': return this.rowspan > 0 ? String(this.rowspan) : '';
      case 'start': return this.start > 0 ? String(this.start) : '';
      case 'ignore': return this.ignore ? 'T' : '';
      case 'controls': return this.controls ? 'T' : '';
      case 'autoplay': return this.autoplay ? 'T' : '';
      case 'loop': return this.loop ? 'T' : '';
      default: return this.extra(name);
    }
  }

  private setExtra(name: string, value: string): void {
    for (const item of this.extras) {
      if (item.key === name) {
        item.value = value;
        return;
      }
    }
    this.extras.push(new UPHtmlDeclaration(name, value));
  }

  private extra(name: string): string {
    for (const item of this.extras) {
      if (item.key === name) {
        return item.value;
      }
    }
    return '';
  }
}

/** colspan/rowspan/start 的整数解析。/ Integer parsing for colspan, rowspan and start. */
export function upHtmlSpanValue(value: string): number {
  const amount: number = Number.parseInt(value);
  return isNaN(amount) || amount < 0 ? 0 : amount;
}

/** 节点类型。/ Node kinds produced by the parser. */
export type UPHtmlNodeType = 'element' | 'text';

/** 上游 node 对象的具名模型。/ Named node model. */
export class UPHtmlNode {
  type: UPHtmlNodeType = 'element';
  name: string = '';
  text: string = '';
  attrs: UPHtmlAttrs = new UPHtmlAttrs();
  children: Array<UPHtmlNode> = [];
  /** 上游 node.c：需要脱离 rich-text 单独渲染。/ Upstream node.c continue flag. */
  exposed: number = 0;
  /** 上游 node.pre：保留空白符。/ Upstream node.pre flag. */
  preserveWhitespace: boolean = false;
  /** 上游 node.flag：table 内含 colspan/rowspan。/ Upstream node.flag. */
  spanFlag: boolean = false;
  /** 上游 imgList 下标。/ Index inside the parsed image list. */
  imageIndex: number = -1;
  /** 上游 node.src：video/audio 的可用源列表。/ Upstream node.src list. */
  sources: Array<string> = [];
  /** 上游 node.w/node.h：是否显式设置了图片宽高。/ Upstream node.w and node.h flags. */
  widthSet: boolean = false;
  heightSet: boolean = false;
  /** 上游 node.m：object-fit 映射出的图片模式。/ Upstream node.m image mode. */
  imageMode: string = '';
  /** 上游 node.t：表格内图片的 display 覆盖值。/ Upstream node.t table display. */
  tableDisplay: string = '';
  /** 上游 node.a：图片所属链接的属性。/ Upstream node.a link attributes. */
  linkAttrs?: UPHtmlAttrs;
  /** 上游 node.webp：webp 图片标记。/ Upstream node.webp flag. */
  webpFlag: boolean = false;

  constructor(type: UPHtmlNodeType = 'element', name: string = '') {
    this.type = type;
    this.name = name;
  }
}

/** 解析选项，对应上游 Parser 读取的组件字段。/ Parser options mirroring the upstream component fields. */
export class UPHtmlParseOptions {
  domain: string = '';
  containerStyle: string = '';
  useAnchor: boolean = false;
  lazyLoad: boolean = false;
  previewImg: boolean = true;
  scrollTable: boolean = false;
  viewportWidth: number = 375;
  tagStyle: Map<string, string> = new Map<string, string>();
}

/** 解析结果：节点树 + 图片列表 + 标题。/ Parse result with node tree, image list and title. */
export class UPHtmlParseResult {
  nodes: Array<UPHtmlNode> = [];
  images: Array<string> = [];
  title: string = '';
  /** 被丢弃的标签名，供组件上报兼容性诊断。/ Dropped tag names for compatibility diagnostics. */
  dropped: Array<string> = [];
}

const UP_HTML_TRUST_TAGS: Set<string> = upHtmlMakeSet('a,abbr,ad,audio,b,blockquote,br,code,col,colgroup,dd,del,dl,dt,div,em,fieldset,h1,h2,h3,h4,h5,h6,hr,i,img,ins,label,legend,li,ol,p,q,ruby,rt,source,span,strong,sub,sup,table,tbody,td,tfoot,th,thead,tr,title,ul,video');
const UP_HTML_BLOCK_TAGS: Set<string> = upHtmlMakeSet('address,article,aside,body,caption,center,cite,footer,header,html,nav,pre,section');
const UP_HTML_INLINE_TAGS: Set<string> = upHtmlMakeSet('abbr,b,big,code,del,em,i,ins,label,q,small,span,strong,sub,sup');
const UP_HTML_IGNORE_TAGS: Set<string> = upHtmlMakeSet('area,base,canvas,embed,frame,head,iframe,input,link,map,meta,param,rp,script,source,style,textarea,title,track,wbr');
const UP_HTML_VOID_TAGS: Set<string> = upHtmlMakeSet('area,base,br,col,circle,ellipse,embed,frame,hr,img,input,line,link,meta,param,path,polygon,rect,source,track,use,wbr');
const UP_HTML_BLANK_CHARS: Set<string> = new Set<string>([' ', '\r', '\n', '\t', '\f']);

const UP_HTML_ENTITIES: Map<string, string> = new Map<string, string>([
  ['lt', '<'], ['gt', '>'], ['quot', '"'], ['apos', "'"], ['ensp', '\u2002'], ['emsp', '\u2003'],
  ['nbsp', '\xA0'], ['semi', ';'], ['ndash', '–'], ['mdash', '—'], ['middot', '·'], ['lsquo', '‘'],
  ['rsquo', '’'], ['ldquo', '“'], ['rdquo', '”'], ['bull', '•'], ['hellip', '…'], ['larr', '←'],
  ['uarr', '↑'], ['rarr', '→'], ['darr', '↓']
]);

const UP_HTML_TAG_STYLE: Map<string, string> = new Map<string, string>([
  ['address', 'font-style:italic'],
  ['big', 'display:inline;font-size:1.2em'],
  ['caption', 'display:table-caption;text-align:center'],
  ['center', 'text-align:center'],
  ['cite', 'font-style:italic'],
  ['dd', 'margin-left:40px'],
  ['mark', 'background-color:yellow'],
  ['pre', 'font-family:monospace;white-space:pre'],
  ['s', 'text-decoration:line-through'],
  ['small', 'display:inline;font-size:0.8em'],
  ['strike', 'text-decoration:line-through'],
  ['u', 'text-decoration:underline']
]);

const UP_HTML_SVG_DICT: Map<string, string> = new Map<string, string>([
  ['animatetransform', 'animateTransform'],
  ['lineargradient', 'linearGradient'],
  ['viewbox', 'viewBox'],
  ['attributename', 'attributeName'],
  ['repeatcount', 'repeatCount'],
  ['repeatdur', 'repeatDur'],
  ['foreignobject', 'foreignObject']
]);

const UP_HTML_FONT_SIZES: Array<string> = ['x-small', 'small', 'medium', 'large', 'x-large', 'xx-large', 'xxx-large'];
const UP_HTML_LIST_TYPES: Map<string, string> = new Map<string, string>([
  ['a', 'lower-alpha'], ['A', 'upper-alpha'], ['i', 'lower-roman'], ['I', 'upper-roman']
]);
const UP_HTML_MERGE_THRESHOLD: number = 50;
const UP_HTML_MERGE_RUN: number = 5;

/** 上游 makeMap()：逗号分隔串转集合。/ Upstream makeMap(). */
export function upHtmlMakeSet(source: string): Set<string> {
  const result: Set<string> = new Set<string>();
  const list: Array<string> = source.split(',');
  for (const item of list) {
    result.add(item);
  }
  return result;
}

export function upHtmlTrustTag(name: string): boolean {
  return UP_HTML_TRUST_TAGS.has(name);
}

export function upHtmlBlockTag(name: string): boolean {
  return UP_HTML_BLOCK_TAGS.has(name);
}

export function upHtmlInlineTag(name: string): boolean {
  return UP_HTML_INLINE_TAGS.has(name);
}

export function upHtmlIgnoreTag(name: string): boolean {
  return UP_HTML_IGNORE_TAGS.has(name);
}

export function upHtmlVoidTag(name: string): boolean {
  return UP_HTML_VOID_TAGS.has(name);
}

export function upHtmlBlankChar(value: string): boolean {
  return UP_HTML_BLANK_CHARS.has(value);
}

export function upHtmlDefaultTagStyle(name: string): string {
  const value: string | undefined = UP_HTML_TAG_STYLE.get(name);
  return value === undefined ? '' : value;
}

export function upHtmlSvgName(name: string): string {
  const value: string | undefined = UP_HTML_SVG_DICT.get(name);
  return value === undefined ? name : value;
}

export function upHtmlEntity(name: string): string {
  const value: string | undefined = UP_HTML_ENTITIES.get(name);
  return value === undefined ? '' : value;
}

export function upHtmlFontSize(value: number): string {
  const clamped: number = value < 1 ? 1 : (value > 7 ? 7 : value);
  return UP_HTML_FONT_SIZES[clamped - 1];
}

export function upHtmlListType(value: string): string {
  const style: string | undefined = UP_HTML_LIST_TYPES.get(value);
  return style === undefined ? '' : style;
}

/** 上游 decodeEntity()。/ Upstream decodeEntity(). */
export function upHtmlDecodeEntity(source: string, decodeAmp: boolean = false): string {
  let text: string = source;
  let cursor: number = text.indexOf('&');
  while (cursor !== -1) {
    const semi: number = text.indexOf(';', cursor + 3);
    if (semi === -1) {
      break;
    }
    if (text.charAt(cursor + 1) === '#') {
      const prefix: string = text.charAt(cursor + 2) === 'x' ? '0' : '';
      const code: number = Number.parseInt(prefix + text.substring(cursor + 2, semi));
      if (!isNaN(code)) {
        text = text.substring(0, cursor) + String.fromCharCode(code) + text.substring(semi + 1);
      }
    } else {
      const name: string = text.substring(cursor + 1, semi);
      const mapped: string = upHtmlEntity(name);
      if (mapped.length > 0 || (name === 'amp' && decodeAmp)) {
        text = text.substring(0, cursor) + (mapped.length > 0 ? mapped : '&') + text.substring(semi + 1);
      }
    }
    cursor = text.indexOf('&', cursor + 1);
  }
  return text;
}

/** 上游 mergeNodes()：连续块级节点合并成一个 div。/ Upstream mergeNodes(). */
export function upHtmlMergeNodes(nodes: Array<UPHtmlNode>): void {
  let tail: number = nodes.length - 1;
  for (let head: number = tail; head >= -1; head--) {
    if (head === -1 || upHtmlMergeBoundary(nodes[head])) {
      if (tail - head >= UP_HTML_MERGE_RUN) {
        const merged: UPHtmlNode = new UPHtmlNode('element', 'div');
        merged.children = nodes.slice(head + 1, tail + 1);
        nodes.splice(head + 1, tail - head, merged);
      }
      tail = head - 1;
    }
  }
}

function upHtmlMergeBoundary(node: UPHtmlNode): boolean {
  if (node.exposed > 0 || node.name.length === 0) {
    return true;
  }
  if (node.name !== 'div' && node.name !== 'p' && node.name.charAt(0) !== 'h') {
    return true;
  }
  return node.attrs.style.includes('inline');
}

/** 上游 getUrl()：按 domain 补全相对链接。/ Upstream getUrl(). */
export function upHtmlResolveUrl(url: string, domain: string): string {
  const protocolMark: string = ':' + '//';
  if (url.charAt(0) === '/') {
    if (url.charAt(1) === '/') {
      const scheme: string = domain.length > 0 ? domain.split(protocolMark)[0] : 'http';
      return scheme + ':' + url;
    }
    return domain.length > 0 ? domain + url : url;
  }
  if (!url.includes('data:') && !url.includes(protocolMark)) {
    return domain.length > 0 ? domain + '/' + url : url;
  }
  return url;
}

/** 有序样式集合，替代上游的 styleObj 字面量。/ Ordered style bag replacing the upstream styleObj. */
export class UPHtmlStyleBag {
  private readonly entries: Array<UPHtmlDeclaration> = [];

  has(key: string): boolean {
    return this.indexOf(key) !== -1;
  }

  get(key: string): string {
    const index: number = this.indexOf(key);
    return index === -1 ? '' : this.entries[index].value;
  }

  set(key: string, value: string): void {
    const index: number = this.indexOf(key);
    if (index === -1) {
      this.entries.push(new UPHtmlDeclaration(key, value));
      return;
    }
    this.entries[index].value = value;
  }

  remove(key: string): void {
    const index: number = this.indexOf(key);
    if (index !== -1) {
      this.entries.splice(index, 1);
    }
  }

  keys(): Array<string> {
    return this.entries.map((entry: UPHtmlDeclaration): string => entry.key);
  }

  list(): Array<UPHtmlDeclaration> {
    return this.entries.slice();
  }

  merge(other: UPHtmlStyleBag): void {
    for (const entry of other.list()) {
      this.set(entry.key, entry.value);
    }
  }

  text(): string {
    let result: string = '';
    for (const entry of this.entries) {
      result += ';' + entry.key + ':' + entry.value;
    }
    return result.length > 0 ? result.substring(1) : '';
  }

  private indexOf(key: string): number {
    for (let index: number = 0; index < this.entries.length; index++) {
      if (this.entries[index].key === key) {
        return index;
      }
    }
    return -1;
  }
}

/** 上游 parseStyle() 的声明拆分。/ Declaration splitting used by parseStyle(). */
export function upHtmlSplitDeclarations(source: string): Array<UPHtmlDeclaration> {
  const result: Array<UPHtmlDeclaration> = [];
  const parts: Array<string> = source.split(';');
  for (const part of parts) {
    const separator: number = part.indexOf(':');
    if (separator <= 0) {
      continue;
    }
    const key: string = part.substring(0, separator).trim().toLowerCase();
    const value: string = part.substring(separator + 1).trim();
    if (key.length === 0 || value.length === 0) {
      continue;
    }
    result.push(new UPHtmlDeclaration(key, value));
  }
  return result;
}

/** 上游 parseStyle() 的 rpx→px 换算。/ The rpx to px conversion from parseStyle(). */
export function upHtmlConvertRpx(value: string, viewportWidth: number): string {
  const width: number = viewportWidth > 0 ? viewportWidth : 375;
  return value.replace(/[0-9.]+\s*rpx/g, (matched: string): string => {
    return String(parseFloat(matched) * width / 750) + 'px';
  });
}

/** 上游 parseStyle() 中 width/height 属性转样式的规则。/ Attribute size to style rule. */
export function upHtmlAttributeSize(value: string): string {
  const amount: number = parseFloat(value);
  if (isNaN(amount)) {
    return '';
  }
  return String(amount) + (value.includes('%') ? '%' : 'px');
}

/** 词法分析状态常量。/ Lexer state constants. */
const UP_HTML_STATE_TEXT: number = 0;
const UP_HTML_STATE_TAG_NAME: number = 1;
const UP_HTML_STATE_ATTR_NAME: number = 2;
const UP_HTML_STATE_ATTR_VALUE: number = 3;
const UP_HTML_STATE_END_TAG: number = 4;

/** 判断是否为英文字母。/ Whether the character is an ASCII letter. */
export function upHtmlLetter(value: string): boolean {
  if (value.length === 0) {
    return false;
  }
  const code: number = value.charCodeAt(0);
  return (code >= 97 && code <= 122) || (code >= 65 && code <= 90);
}

/** 上游 getText()：从节点树取纯文本。/ Upstream getText(). */
export function upHtmlNodesText(nodes: Array<UPHtmlNode>): string {
  let text: string = '';
  for (const node of nodes) {
    if (node.type === 'text') {
      text += node.text.replace(/&amp;/g, '&');
      continue;
    }
    if (node.name === 'br') {
      text += '\n';
      continue;
    }
    const second: string = node.name.length > 1 ? node.name.charAt(1) : '';
    const heading: boolean = node.name.charAt(0) === 'h' && second >= '1' && second <= '6';
    const block: boolean = node.name === 'p' || node.name === 'div' || node.name === 'tr' || node.name === 'li' || heading;
    if (block && text.length > 0 && text.charAt(text.length - 1) !== '\n') {
      text += '\n';
    }
    if (node.children.length > 0) {
      text += upHtmlNodesText(node.children);
    }
    if (block && text.charAt(text.length - 1) !== '\n') {
      text += '\n';
    } else if (node.name === 'td' || node.name === 'th') {
      text += '\t';
    }
  }
  return text;
}

/** 上游 popNode() 中给子树打 c=2 的递归。/ Upstream exposure propagation. */
function upHtmlMarkExposed(node: UPHtmlNode): void {
  node.exposed = 2;
  for (let index: number = node.children.length - 1; index >= 0; index--) {
    const child: UPHtmlNode = node.children[index];
    if (child.exposed === 0 || child.name === 'table') {
      node.exposed = 1;
    }
  }
}

/**
 * 上游 Parser 的 ArkTS 版本，负责把 html 文本变成节点树。
 * ArkTS port of the upstream Parser that turns html text into a node tree.
 */
export class UPHtmlParser {
  private options: UPHtmlParseOptions = new UPHtmlParseOptions();
  private tagStyle: Map<string, string> = new Map<string, string>();
  private attrs: UPHtmlAttrs = new UPHtmlAttrs();
  private stack: Array<UPHtmlNode> = [];
  private nodes: Array<UPHtmlNode> = [];
  private images: Array<string> = [];
  private dropped: Array<string> = [];
  private title: string = '';
  private tagName: string = '';
  private attrName: string = '';
  private pre: number = 0;
  private xml: number = 0;
  private idIndex: number = 0;

  constructor(options?: UPHtmlParseOptions) {
    if (options !== undefined) {
      this.options = options;
    }
    this.tagStyle = this.options.tagStyle;
  }

  /** 执行解析。/ Run the parse. */
  parse(content: string): UPHtmlParseResult {
    this.attrs = new UPHtmlAttrs();
    this.stack = [];
    this.nodes = [];
    this.images = [];
    this.dropped = [];
    this.title = '';
    this.tagName = '';
    this.attrName = '';
    this.xml = 0;
    this.idIndex = 0;
    const container: string = this.options.containerStyle;
    this.pre = container.includes('white-space') && container.includes('pre') ? 2 : 0;
    new UPHtmlLexer(this).parse(content);
    while (this.stack.length > 0) {
      this.popNode();
    }
    if (this.nodes.length > UP_HTML_MERGE_THRESHOLD) {
      upHtmlMergeNodes(this.nodes);
    }
    const result: UPHtmlParseResult = new UPHtmlParseResult();
    result.nodes = this.nodes;
    result.images = this.images;
    result.title = this.title;
    result.dropped = this.dropped;
    return result;
  }

  /** 词法分析器读取当前标签名，用于 script 特判。/ Current tag name for the script special case. */
  currentTagName(): string {
    return this.tagName;
  }

  /** 上游 onTagName()。/ Upstream onTagName(). */
  onTagName(rawName: string): void {
    this.tagName = this.xml > 0 ? rawName : rawName.toLowerCase();
    if (this.tagName === 'svg') {
      this.xml += 1;
    }
  }

  /** 上游 onAttrName()。/ Upstream onAttrName(). */
  onAttrName(rawName: string): void {
    const name: string = this.xml > 0 ? rawName : rawName.toLowerCase();
    if (name.includes('?') || name.includes(';')) {
      this.attrName = '';
      return;
    }
    if (name.substring(0, 5) === 'data-') {
      if (name === 'data-src' && this.attrs.src.length === 0) {
        this.attrName = 'src';
      } else if (this.tagName === 'img' || this.tagName === 'a') {
        this.attrName = name;
      } else {
        this.attrName = '';
      }
      return;
    }
    this.attrName = name;
    this.attrs.setValue(name, 'T');
  }

  /** 上游 onAttrVal()。/ Upstream onAttrVal(). */
  onAttrVal(value: string): void {
    const name: string = this.attrName;
    if (name.length === 0) {
      return;
    }
    if (name === 'style' || name === 'href') {
      this.attrs.setValue(name, upHtmlDecodeEntity(value, true));
      return;
    }
    if (name.includes('src')) {
      this.attrs.setValue(name, upHtmlResolveUrl(upHtmlDecodeEntity(value, true), this.options.domain));
      return;
    }
    this.attrs.setValue(name, value);
  }

  /** 上游 onOpenTag()。/ Upstream onOpenTag(). */
  onOpenTag(selfClose: boolean): void {
    const node: UPHtmlNode = new UPHtmlNode('element', this.tagName);
    node.attrs = this.attrs;
    this.attrs = new UPHtmlAttrs();
    const attrs: UPHtmlAttrs = node.attrs;
    const parent: UPHtmlNode | undefined = this.stack.length > 0 ? this.stack[this.stack.length - 1] : undefined;
    const siblings: Array<UPHtmlNode> = parent === undefined ? this.nodes : parent.children;
    const close: boolean = this.xml > 0 ? selfClose : upHtmlVoidTag(node.name);

    if (node.name === 'embed') {
      const source: string = attrs.src;
      const kind: string = attrs.type;
      if (source.includes('.mp4') || source.includes('.3gp') || source.includes('.m3u8') || kind.includes('video')) {
        node.name = 'video';
      } else if (source.includes('.mp3') || source.includes('.wav') || source.includes('.aac') || source.includes('.m4a') || kind.includes('audio')) {
        node.name = 'audio';
      }
      if (attrs.value('autostart').length > 0) {
        attrs.autoplay = true;
      }
      attrs.controls = true;
    }

    if (node.name === 'video' || node.name === 'audio') {
      if (node.name === 'video' && attrs.id.length === 0) {
        attrs.id = 'v' + String(this.idIndex);
        this.idIndex += 1;
      }
      if (!attrs.controls && !attrs.autoplay) {
        attrs.controls = true;
      }
      node.sources = [];
      if (attrs.src.length > 0) {
        node.sources.push(attrs.src);
        attrs.src = '';
      }
      this.expose();
    }

    if (close) {
      if (upHtmlIgnoreTag(node.name)) {
        if (node.name === 'base' && this.options.domain.length === 0) {
          this.options.domain = attrs.href;
        } else if (node.name === 'source' && parent !== undefined && (parent.name === 'video' || parent.name === 'audio') && attrs.src.length > 0) {
          parent.sources.push(attrs.src);
        } else {
          this.recordDropped(node.name);
        }
        return;
      }
      const styleObj: UPHtmlStyleBag = this.parseStyle(node);
      if (node.name === 'img') {
        this.prepareImage(node, styleObj, parent);
      } else if (node.name === 'svg') {
        this.recordDropped('svg');
        this.xml = 0;
        return;
      }
      this.applyStyle(node, styleObj);
    } else {
      const style: string = attrs.style;
      if ((node.name === 'pre' || (style.includes('white-space') && style.includes('pre'))) && this.pre !== 2) {
        this.pre = 1;
        node.preserveWhitespace = true;
      }
      node.children = [];
      this.stack.push(node);
    }
    siblings.push(node);
  }

  /** 上游 onCloseTag()。/ Upstream onCloseTag(). */
  onCloseTag(rawName: string): void {
    const name: string = this.xml > 0 ? rawName : rawName.toLowerCase();
    let matched: number = -1;
    for (let index: number = this.stack.length - 1; index >= 0; index--) {
      if (this.stack[index].name === name) {
        matched = index;
        break;
      }
    }
    if (matched !== -1) {
      while (this.stack.length > matched) {
        this.popNode();
      }
      return;
    }
    if (name === 'p' || name === 'br') {
      const siblings: Array<UPHtmlNode> = this.stack.length > 0 ? this.stack[this.stack.length - 1].children : this.nodes;
      const node: UPHtmlNode = new UPHtmlNode('element', name);
      node.attrs.style = this.styleForTag(name);
      siblings.push(node);
    }
  }

  /** 上游 onText()。/ Upstream onText(). */
  onText(raw: string): void {
    let text: string = raw;
    if (this.pre === 0) {
      let trimmed: string = '';
      let newline: boolean = false;
      for (let index: number = 0; index < text.length; index++) {
        const character: string = text.charAt(index);
        if (!upHtmlBlankChar(character)) {
          trimmed += character;
          continue;
        }
        if (trimmed.charAt(trimmed.length - 1) !== ' ') {
          trimmed += ' ';
        }
        if (character === '\n' && !newline) {
          newline = true;
        }
      }
      if (trimmed === ' ') {
        if (newline) {
          return;
        }
        const parent: UPHtmlNode | undefined = this.stack.length > 0 ? this.stack[this.stack.length - 1] : undefined;
        if (parent !== undefined && parent.name.charAt(0) === 't') {
          return;
        }
      }
      text = trimmed;
    }
    const node: UPHtmlNode = new UPHtmlNode('text', '');
    node.text = upHtmlDecodeEntity(text);
    const siblings: Array<UPHtmlNode> = this.stack.length > 0 ? this.stack[this.stack.length - 1].children : this.nodes;
    siblings.push(node);
  }

  /** 上游 expose()：把标签标记为需要独立渲染。/ Upstream expose(). */
  private expose(): void {
    for (let index: number = this.stack.length - 1; index >= 0; index--) {
      const item: UPHtmlNode = this.stack[index];
      if (item.exposed > 0 || item.name === 'a' || item.name === 'video' || item.name === 'audio') {
        return;
      }
      item.exposed = 1;
    }
  }

  /** 标签默认样式，options.tagStyle 优先。/ Tag default style with option override. */
  private styleForTag(name: string): string {
    const custom: string | undefined = this.tagStyle.get(name);
    return custom === undefined ? upHtmlDefaultTagStyle(name) : custom;
  }

  /** 记录被丢弃的标签名。/ Record a dropped tag name. */
  private recordDropped(name: string): void {
    if (name.length > 0 && !this.dropped.includes(name)) {
      this.dropped.push(name);
    }
  }

  /** 上游 parseStyle()。/ Upstream parseStyle(). */
  private parseStyle(node: UPHtmlNode): UPHtmlStyleBag {
    const attrs: UPHtmlAttrs = node.attrs;
    const styleObj: UPHtmlStyleBag = new UPHtmlStyleBag();
    let compat: string = '';
    const list: Array<string> = this.styleForTag(node.name).split(';').concat(attrs.style.split(';'));

    if (attrs.id.length > 0 && this.xml === 0) {
      if (this.options.useAnchor) {
        this.expose();
      } else if (node.name !== 'img' && node.name !== 'a' && node.name !== 'video' && node.name !== 'audio') {
        attrs.id = '';
      }
    }
    if (attrs.width.length > 0) {
      const width: string = upHtmlAttributeSize(attrs.width);
      if (width.length > 0) {
        styleObj.set('width', width);
      }
      attrs.width = '';
    }
    if (attrs.height.length > 0) {
      const height: string = upHtmlAttributeSize(attrs.height);
      if (height.length > 0) {
        styleObj.set('height', height);
      }
      attrs.height = '';
    }

    for (const item of list) {
      const separator: number = item.indexOf(':');
      if (separator === -1) {
        continue;
      }
      const key: string = item.substring(0, separator).trim().toLowerCase();
      let value: string = item.substring(separator + 1).trim();
      if (key.length === 0) {
        continue;
      }
      if ((value.charAt(0) === '-' && value.lastIndexOf('-') > 0) || value.includes('safe')) {
        compat += ';' + key + ':' + value;
        continue;
      }
      const existing: string = styleObj.get(key);
      if (existing.length === 0 || value.includes('import') || !existing.includes('import')) {
        if (value.includes('url')) {
          let cursor: number = value.indexOf('(') + 1;
          if (cursor > 0) {
            while (value.charAt(cursor) === '"' || value.charAt(cursor) === "'" || upHtmlBlankChar(value.charAt(cursor))) {
              cursor += 1;
            }
            value = value.substring(0, cursor) + upHtmlResolveUrl(value.substring(cursor), this.options.domain);
          }
        } else if (value.includes('rpx')) {
          value = upHtmlConvertRpx(value, this.options.viewportWidth);
        }
        styleObj.set(key, value);
      }
    }
    attrs.style = compat;
    return styleObj;
  }

  /** 上游 onOpenTag() 中的图片处理。/ Image handling from onOpenTag(). */
  private prepareImage(node: UPHtmlNode, styleObj: UPHtmlStyleBag, parent?: UPHtmlNode): void {
    const attrs: UPHtmlAttrs = node.attrs;
    if (attrs.src.length > 0) {
      if (attrs.src.includes('webp')) {
        node.webpFlag = true;
      }
      if (attrs.src.includes('data:') && attrs.originalSrc.length === 0) {
        attrs.ignore = true;
      }
      if (!attrs.ignore || node.webpFlag) {
        for (let index: number = this.stack.length - 1; index >= 0; index--) {
          const item: UPHtmlNode = this.stack[index];
          if (item.name === 'a') {
            node.linkAttrs = item.attrs;
          }
          if (item.name === 'table' && !node.webpFlag) {
            const display: string = styleObj.get('display');
            node.tableDisplay = display.length === 0 || display.includes('inline') ? 'inline-block' : display;
            styleObj.remove('display');
          }
          item.exposed = 1;
        }
        node.imageIndex = this.images.length;
        this.images.push(attrs.originalSrc.length > 0 ? attrs.originalSrc : attrs.src);
        if (this.options.lazyLoad && attrs.dataSrc.length === 0) {
          attrs.dataSrc = attrs.src;
        }
      }
    }
    if (styleObj.get('display') === 'inline') {
      styleObj.remove('display');
    }
    if (attrs.ignore && styleObj.get('max-width').length === 0) {
      styleObj.set('max-width', '100%');
    }
    const width: number = Number.parseInt(styleObj.get('width'));
    if (!isNaN(width) && width > this.options.viewportWidth) {
      styleObj.remove('height');
    }
    if (!isNaN(width)) {
      node.widthSet = true;
    }
    const heightValue: string = styleObj.get('height');
    const height: number = Number.parseInt(heightValue);
    const parentHeight: boolean = parent !== undefined && parent.attrs.style.includes('height');
    if (!isNaN(height) && (!heightValue.includes('%') || parentHeight)) {
      node.heightSet = true;
    }
    if (node.widthSet && node.heightSet) {
      const fit: string = styleObj.get('object-fit');
      if (fit === 'contain') {
        node.imageMode = 'aspectFit';
      } else if (fit === 'cover') {
        node.imageMode = 'aspectFill';
      }
    }
  }

  /** 上游 popNode() 中的 table 属性转换。/ Table attribute conversion from popNode(). */
  private decorateTable(node: UPHtmlNode, styleObj: UPHtmlStyleBag): void {
    const attrs: UPHtmlAttrs = node.attrs;
    let padding: number = parseFloat(attrs.cellpadding);
    let spacing: number = parseFloat(attrs.cellspacing);
    const border: number = parseFloat(attrs.border);
    const borderColor: string = styleObj.get('border-color');
    const borderStyle: string = styleObj.get('border-style');
    if (node.exposed > 0) {
      if (isNaN(padding)) {
        padding = 2;
      }
      if (isNaN(spacing)) {
        spacing = 2;
      }
    }
    const resolvedStyle: string = borderStyle.length > 0 ? borderStyle : 'solid';
    const resolvedColor: string = borderColor.length > 0 ? borderColor : 'gray';
    const hasBorder: boolean = !isNaN(border) && border > 0;
    const hasPadding: boolean = !isNaN(padding) && padding > 0;
    if (hasBorder) {
      attrs.style += ';border:' + String(border) + 'px ' + resolvedStyle + ' ' + resolvedColor;
    }
    if (node.exposed > 0) {
      styleObj.set('display', 'table');
    }
    if (!isNaN(spacing)) {
      styleObj.set('border-spacing', String(spacing) + 'px');
    }
    if (hasBorder || hasPadding) {
      this.decorateCells(node.children, hasBorder ? border : 0, hasPadding ? padding : 0, resolvedStyle, resolvedColor);
    }
  }

  /** 给 td/th 前置边框与内边距。/ Prepend border and padding to cells. */
  private decorateCells(nodes: Array<UPHtmlNode>, border: number, padding: number, borderStyle: string, borderColor: string): void {
    for (const item of nodes) {
      if (item.name === 'th' || item.name === 'td') {
        if (border > 0) {
          item.attrs.style = 'border:' + String(border) + 'px ' + borderStyle + ' ' + borderColor + ';' + item.attrs.style;
        }
        if (padding > 0) {
          item.attrs.style = 'padding:' + String(padding) + 'px;' + item.attrs.style;
        }
      } else if (item.children.length > 0) {
        this.decorateCells(item.children, border, padding, borderStyle, borderColor);
      }
    }
  }

  /** tbody/tr 的颜色样式下推到单元格。/ Push row colors down to cells. */
  private pushCellStyles(nodes: Array<UPHtmlNode>, styleObj: UPHtmlStyleBag): void {
    for (const item of nodes) {
      if (item.name === 'td') {
        if (styleObj.get('color').length > 0) {
          item.attrs.style = 'color:' + styleObj.get('color') + ';' + item.attrs.style;
        }
        if (styleObj.get('background').length > 0) {
          item.attrs.style = 'background:' + styleObj.get('background') + ';' + item.attrs.style;
        }
        if (styleObj.get('background-color').length > 0) {
          item.attrs.style = 'background-color:' + styleObj.get('background-color') + ';' + item.attrs.style;
        }
      } else if (item.children.length > 0) {
        this.pushCellStyles(item.children, styleObj);
      }
    }
  }

  /** 上游 ruby 转换。/ Upstream ruby conversion. */
  private convertRuby(children: Array<UPHtmlNode>): void {
    for (let index: number = 0; index < children.length - 1; index++) {
      if (children[index].type !== 'text' || children[index + 1].name !== 'rt') {
        continue;
      }
      const annotation: UPHtmlNode = new UPHtmlNode('element', 'div');
      annotation.attrs.style = 'font-size:50%;' + children[index + 1].attrs.style;
      annotation.children = children[index + 1].children;
      const wrapper: UPHtmlNode = new UPHtmlNode('element', 'div');
      wrapper.attrs.style = 'display:inline-block;text-align:center';
      wrapper.children = [annotation, children[index]];
      children[index] = wrapper;
      children.splice(index + 1, 1);
    }
  }

  /** 样式集合写回 attrs.style。/ Flush the style bag into attrs.style. */
  private applyStyle(node: UPHtmlNode, styleObj: UPHtmlStyleBag): void {
    let style: string = node.attrs.style;
    for (const entry of styleObj.list()) {
      if (entry.value.length > 0) {
        style += ';' + entry.key + ':' + entry.value.replace(' !important', '');
      }
    }
    node.attrs.style = style.charAt(0) === ';' ? style.substring(1) : style;
  }

  /** 上游 popNode()。/ Upstream popNode(). */
  private popNode(): void {
    const node: UPHtmlNode | undefined = this.stack.pop();
    if (node === undefined) {
      return;
    }
    const attrs: UPHtmlAttrs = node.attrs;
    const children: Array<UPHtmlNode> = node.children;
    const parent: UPHtmlNode | undefined = this.stack.length > 0 ? this.stack[this.stack.length - 1] : undefined;
    const siblings: Array<UPHtmlNode> = parent === undefined ? this.nodes : parent.children;

    if (upHtmlIgnoreTag(node.name)) {
      if (node.name === 'title' && children.length > 0 && children[0].type === 'text') {
        this.title = children[0].text;
      }
      this.recordDropped(node.name);
      siblings.pop();
      return;
    }

    if (node.preserveWhitespace && this.pre !== 2) {
      this.pre = 0;
      for (let index: number = this.stack.length - 1; index >= 0; index--) {
        if (this.stack[index].preserveWhitespace) {
          this.pre = 1;
        }
      }
    }

    if (node.name === 'svg') {
      if (this.xml > 1) {
        this.xml -= 1;
        return;
      }
      this.xml = 0;
      this.recordDropped('svg');
      siblings.pop();
      return;
    }

    const styleObj: UPHtmlStyleBag = new UPHtmlStyleBag();
    if (attrs.align.length > 0) {
      if (node.name === 'table') {
        if (attrs.align === 'center') {
          styleObj.set('margin-inline-start', 'auto');
          styleObj.set('margin-inline-end', 'auto');
        } else {
          styleObj.set('float', attrs.align);
        }
      } else {
        styleObj.set('text-align', attrs.align);
      }
      attrs.align = '';
    }
    if (attrs.dir.length > 0) {
      styleObj.set('direction', attrs.dir);
      attrs.dir = '';
    }
    if (node.name === 'font') {
      if (attrs.color.length > 0) {
        styleObj.set('color', attrs.color);
        attrs.color = '';
      }
      if (attrs.face.length > 0) {
        styleObj.set('font-family', attrs.face);
        attrs.face = '';
      }
      if (attrs.size.length > 0) {
        const size: number = Number.parseInt(attrs.size);
        if (!isNaN(size)) {
          styleObj.set('font-size', upHtmlFontSize(size));
        }
        attrs.size = '';
      }
    }
    if (attrs.className.includes('align-center')) {
      styleObj.set('text-align', 'center');
    }
    styleObj.merge(this.parseStyle(node));
    const width: number = Number.parseInt(styleObj.get('width'));
    if (node.name !== 'table' && !isNaN(width) && width > this.options.viewportWidth) {
      styleObj.set('max-width', '100%');
      styleObj.set('box-sizing', 'border-box');
    }
    if (upHtmlBlockTag(node.name)) {
      node.name = 'div';
    } else if (!upHtmlTrustTag(node.name) && this.xml === 0) {
      this.recordDropped(node.name);
      node.name = 'span';
    }

    if (node.name === 'a' || node.name === 'ad') {
      this.expose();
    } else if (node.name === 'video') {
      if (styleObj.get('height').includes('auto')) {
        styleObj.remove('height');
      }
    } else if (node.name === 'ul' || node.name === 'ol') {
      const listStyle: string = upHtmlListType(attrs.type);
      if (listStyle.length > 0) {
        attrs.style += ';list-style-type:' + listStyle;
        attrs.type = '';
      }
      for (let index: number = children.length - 1; index >= 0; index--) {
        if (children[index].name === 'li') {
          children[index].exposed = 1;
        }
      }
    } else if (node.name === 'table') {
      this.decorateTable(node, styleObj);
    } else if ((node.name === 'tbody' || node.name === 'tr') && node.spanFlag && node.exposed > 0) {
      node.spanFlag = false;
      this.pushCellStyles(children, styleObj);
    } else if ((node.name === 'td' || node.name === 'th') && (attrs.colspan > 0 || attrs.rowspan > 0)) {
      for (let index: number = this.stack.length - 1; index >= 0; index--) {
        const item: UPHtmlNode = this.stack[index];
        if (item.name === 'table' || item.name === 'tbody' || item.name === 'tr') {
          item.spanFlag = true;
        }
      }
    } else if (node.name === 'ruby') {
      node.name = 'span';
      this.convertRuby(children);
    } else if (node.exposed > 0) {
      upHtmlMarkExposed(node);
    }

    if (children.length >= UP_HTML_MERGE_THRESHOLD && node.exposed > 0 && !styleObj.get('display').includes('flex')) {
      upHtmlMergeNodes(children);
    }
    this.applyStyle(node, styleObj);
  }
}

/**
 * 上游 Lexer 的 ArkTS 版本，状态机用常量编号代替函数指针。
 * ArkTS port of the upstream Lexer with numeric states instead of function pointers.
 */
export class UPHtmlLexer {
  private readonly handler: UPHtmlParser;
  private content: string = '';
  private cursor: number = 0;
  private start: number = 0;
  private state: number = UP_HTML_STATE_TEXT;

  constructor(handler: UPHtmlParser) {
    this.handler = handler;
  }

  /** 执行词法分析。/ Run the lexer. */
  parse(content: string): void {
    this.content = content;
    this.cursor = 0;
    this.start = 0;
    this.state = UP_HTML_STATE_TEXT;
    const length: number = this.content.length;
    while (this.cursor !== -1 && this.cursor < length) {
      if (this.state === UP_HTML_STATE_TEXT) {
        this.readText();
      } else if (this.state === UP_HTML_STATE_TAG_NAME) {
        this.readTagName();
      } else if (this.state === UP_HTML_STATE_ATTR_NAME) {
        this.readAttrName();
      } else if (this.state === UP_HTML_STATE_ATTR_VALUE) {
        this.readAttrValue();
      } else {
        this.readEndTag();
      }
    }
  }

  /** 上游 checkClose()。/ Upstream checkClose(). */
  private checkClose(method: string): boolean {
    const current: string = this.content.charAt(this.cursor);
    const selfClose: boolean = current === '/';
    if (current !== '>' && !(selfClose && this.content.charAt(this.cursor + 1) === '>')) {
      return false;
    }
    if (method.length > 0) {
      this.dispatch(method, this.content.substring(this.start, this.cursor));
    }
    this.cursor += selfClose ? 2 : 1;
    this.start = this.cursor;
    this.handler.onOpenTag(selfClose);
    if (this.handler.currentTagName() === 'script') {
      this.cursor = this.content.indexOf('</', this.cursor);
      if (this.cursor !== -1) {
        this.cursor += 2;
        this.start = this.cursor;
      }
      this.state = UP_HTML_STATE_END_TAG;
    } else {
      this.state = UP_HTML_STATE_TEXT;
    }
    return true;
  }

  /** 按名字派发到解析器回调。/ Dispatch to a parser callback by name. */
  private dispatch(method: string, value: string): void {
    if (method === 'onTagName') {
      this.handler.onTagName(value);
      return;
    }
    if (method === 'onAttrName') {
      this.handler.onAttrName(value);
      return;
    }
    this.handler.onAttrVal(value);
  }

  /** 上游 text 状态。/ Upstream text state. */
  private readText(): void {
    this.cursor = this.content.indexOf('<', this.cursor);
    if (this.cursor === -1) {
      if (this.start < this.content.length) {
        this.handler.onText(this.content.substring(this.start, this.content.length));
      }
      return;
    }
    const next: string = this.content.charAt(this.cursor + 1);
    if (upHtmlLetter(next)) {
      if (this.start !== this.cursor) {
        this.handler.onText(this.content.substring(this.start, this.cursor));
      }
      this.cursor += 1;
      this.start = this.cursor;
      this.state = UP_HTML_STATE_TAG_NAME;
      return;
    }
    if (next === '/' || next === '!' || next === '?') {
      if (this.start !== this.cursor) {
        this.handler.onText(this.content.substring(this.start, this.cursor));
      }
      const following: string = this.content.charAt(this.cursor + 2);
      if (next === '/' && upHtmlLetter(following)) {
        this.cursor += 2;
        this.start = this.cursor;
        this.state = UP_HTML_STATE_END_TAG;
        return;
      }
      const comment: boolean = next === '!' && following === '-' && this.content.charAt(this.cursor + 3) === '-';
      const terminator: string = comment ? '-->' : '>';
      this.cursor = this.content.indexOf(terminator, this.cursor);
      if (this.cursor !== -1) {
        this.cursor += terminator.length;
        this.start = this.cursor;
      }
      return;
    }
    this.cursor += 1;
  }

  /** 上游 tagName 状态。/ Upstream tagName state. */
  private readTagName(): void {
    if (upHtmlBlankChar(this.content.charAt(this.cursor))) {
      this.handler.onTagName(this.content.substring(this.start, this.cursor));
      this.cursor += 1;
      while (upHtmlBlankChar(this.content.charAt(this.cursor))) {
        this.cursor += 1;
      }
      if (this.cursor < this.content.length && !this.checkClose('')) {
        this.start = this.cursor;
        this.state = UP_HTML_STATE_ATTR_NAME;
      }
      return;
    }
    if (!this.checkClose('onTagName')) {
      this.cursor += 1;
    }
  }

  /** 上游 attrName 状态。/ Upstream attrName state. */
  private readAttrName(): void {
    let current: string = this.content.charAt(this.cursor);
    if (!upHtmlBlankChar(current) && current !== '=') {
      if (!this.checkClose('onAttrName')) {
        this.cursor += 1;
      }
      return;
    }
    this.handler.onAttrName(this.content.substring(this.start, this.cursor));
    let needValue: boolean = current === '=';
    const length: number = this.content.length;
    this.cursor += 1;
    while (this.cursor < length) {
      current = this.content.charAt(this.cursor);
      if (!upHtmlBlankChar(current)) {
        if (this.checkClose('')) {
          return;
        }
        if (needValue) {
          this.start = this.cursor;
          this.state = UP_HTML_STATE_ATTR_VALUE;
          return;
        }
        if (this.content.charAt(this.cursor) === '=') {
          needValue = true;
        } else {
          this.start = this.cursor;
          this.state = UP_HTML_STATE_ATTR_NAME;
          return;
        }
      }
      this.cursor += 1;
    }
  }

  /** 上游 attrVal 状态。/ Upstream attrVal state. */
  private readAttrValue(): void {
    const quote: string = this.content.charAt(this.cursor);
    const length: number = this.content.length;
    if (quote === '"' || quote === "'") {
      this.cursor += 1;
      this.start = this.cursor;
      this.cursor = this.content.indexOf(quote, this.cursor);
      if (this.cursor === -1) {
        return;
      }
      this.handler.onAttrVal(this.content.substring(this.start, this.cursor));
    } else {
      while (this.cursor < length) {
        if (upHtmlBlankChar(this.content.charAt(this.cursor))) {
          this.handler.onAttrVal(this.content.substring(this.start, this.cursor));
          break;
        }
        if (this.checkClose('onAttrVal')) {
          return;
        }
        this.cursor += 1;
      }
    }
    this.cursor += 1;
    while (upHtmlBlankChar(this.content.charAt(this.cursor))) {
      this.cursor += 1;
    }
    if (this.cursor < length && !this.checkClose('')) {
      this.start = this.cursor;
      this.state = UP_HTML_STATE_ATTR_NAME;
    }
  }

  /** 上游 endTag 状态。/ Upstream endTag state. */
  private readEndTag(): void {
    const current: string = this.content.charAt(this.cursor);
    if (upHtmlBlankChar(current) || current === '>' || current === '/') {
      this.handler.onCloseTag(this.content.substring(this.start, this.cursor));
      if (current !== '>') {
        this.cursor = this.content.indexOf('>', this.cursor);
        if (this.cursor === -1) {
          return;
        }
      }
      this.cursor += 1;
      this.start = this.cursor;
      this.state = UP_HTML_STATE_TEXT;
      return;
    }
    this.cursor += 1;
  }
}

/** 便捷入口：解析 html 文本。/ Convenience entry point. */
export function upHtmlParse(content: string, options?: UPHtmlParseOptions): UPHtmlParseResult {
  return new UPHtmlParser(options).parse(content);
}
