#!/usr/bin/env python3
"""Static contracts for Phase 19 parse, markdown, picker column, city locate and pdf reader."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal"
CONTROLLERS = ROOT / "ultra-ui/src/main/ets/controllers"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS = ROOT / "sample/entry/src/main/ets/demos"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-19.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo", "RichText",
)

SOURCES = {
    "UPParse": (
        "UPParseOptions", "UPParseProps", "UPParseImageTapEvent", "UPParseLinkTapEvent",
        "UPParseReadyEvent", "UPParseMediaEvent", "UPParseErrorEvent",
        "UP_PARSE_ROOT_PADDING", "UP_PARSE_TEXT_FAMILY", "UP_PARSE_MONO_FAMILY",
        "UP_PARSE_MEDIA_WIDTH", "UP_PARSE_MEDIA_HEIGHT", "UP_PARSE_MARKER_WIDTH",
        "UPParseAnchor", "upParseExternalLink", "upParseBlockHref", "upParseBlockText",
        "upParseCellText", "upHtmlParse", "upHtmlNodesText", "UPHtmlLayout",
        "UPHtmlDeclaration", "UPParseController", "UPParseCommand", "signature",
        "parseOptions", "layoutOptions", "render", "reportBoundaries", "execute",
        "scrollToAnchor", "recordAnchor", "anchorEnabled", "anchorOffset", "viewport",
        "baseFontSize", "runSpans", "textBlock", "imageBlock", "mediaBlock", "tableCell",
        "tableRow", "tableBody", "tableBlock", "blockBody", "blockView", "body",
        "handleImageTap", "handleLinkTap", "dispatchLink", "handleMediaTap",
        "copyOptionValue", "runColor", "runBackground", "runDecoration", "runFamily",
        "textAlignOf", "blockBackground", "blockIndent", "imageBoxWidth", "imageBoxHeight",
        "imageMode", "viewportHeight", "contentWidth", "CopyOptions.LocalDevice",
        "TextAlign.JUSTIFY", "textBackgroundStyle", "ScrollDirection.Horizontal",
        "ItemAlign.Stretch", "onAreaChange", "UPImage", "UPIcon", "Span(",
    ),
    "UPMarkdown": (
        "UPMarkdownOptions", "UPMarkdownProps", "upMarkdownToHtml", "upMarkdownApplyTheme",
        "upMarkdownTagStyle", "upMarkdownThemeSupported", "upMarkdownDarkTheme",
        "upMarkdownBaseColor", "upMarkdownLinkColor", "upMarkdownBackground",
        "UP_MARKDOWN_BASE_FONT_SIZE", "UP_MARKDOWN_ROOT_PADDING", "UP_MARKDOWN_THEMES",
        "UPParse", "UPParseProps", "UPParseController", "UPHtmlDeclaration", "markup",
        "signature", "themeName", "darkTheme", "convert", "reportBoundaries",
        "baseFontSizeValue", "rootPadding", "rootBackground", "baseColorValue",
        "tagStyleList", "parseProps", "parseContainerStyle", "showLineNumber",
        "setTitle: false",
    ),
    "UPPickerColumn": (
        "UPPickerColumnOptions", "UPPickerColumnProps", "UP_PICKER_COLUMN_ITEM_HEIGHT",
        "UP_PICKER_COLUMN_WIDTH", "upPickerColumnAlign", "upPickerColumnAlignSupported",
        "FlexAlign.Start", "FlexAlign.Center", "FlexAlign.End", "alignName",
        "itemHeightValue", "columnWidth", "columnBackground", "contentBuilder",
        "picker-view-column",
    ),
    "UPCityLocate": (
        "UPCityLocateOptions", "UPCityLocateProps", "UPCityLocateItem",
        "UPCityLocateRequest", "UPCityLocateResult", "UPCityLocateSuccessEvent",
        "UPCityLocateSelectEvent", "UPCityLocateFailureEvent", "UPCityLocateFailureReason",
        "UP_CITY_LOCATE_TITLE", "UP_CITY_LOCATE_LOADING", "UP_CITY_LOCATE_FAIL",
        "UP_CITY_LOCATE_DOTS", "UP_CITY_LOCATE_HOT_INDEX", "UP_CITY_LOCATE_HEADER_HEIGHT",
        "UP_CITY_LOCATE_TITLE_COLOR", "UP_CITY_LOCATE_TEXT_COLOR",
        "UP_CITY_LOCATE_HOT_BORDER", "UP_CITY_LOCATE_HOT_BACKGROUND",
        "upCityLocateName", "upCityLocateKeySupported", "upCityLocateHotCities",
        "upCityLocateDefaultList", "UPCityLocateSectionModel", "UPIndexList",
        "UPIndexItem", "UPLine", "requestLocation", "pickCity", "sectionModel",
        "listProps", "locateHeader", "sections", "groupIndexes", "indexLabel",
        "nameKeyValue", "locationTypeValue", "reportBoundaries", "locate-unavailable",
        "locate-failed", "empty-city",
    ),
    "UPPdfReader": (
        "UPPdfReaderOptions", "UPPdfReaderProps", "UPPdfReaderViewerEvent",
        "UP_PDF_READER_BASE_URL", "UP_PDF_READER_VIEWER_PATH", "UP_PDF_READER_FILE_QUERY",
        "UP_PDF_READER_HEIGHT", "UP_PDF_READER_WIDTH", "UP_PDF_READER_ICON",
        "UP_PDF_READER_EMPTY_TEXT", "UP_PDF_READER_PLACEHOLDER_TEXT",
        "UP_PDF_READER_HINT_TEXT", "upPdfReaderEncode", "upPdfReaderViewerUrl",
        "upPdfReaderOctet", "UP_PDF_READER_HEX", "viewerBuilder", "placeholder",
        "viewerUrl", "publish", "reportBoundaries", "readerHeight", "sourceValue",
        "baseUrlValue", "UPIcon",
    ),
}

INTERNAL_SOURCES = {
    "UPHtmlParser": (
        "UPHtmlDeclaration", "UPHtmlAttrs", "UPHtmlNode", "UPHtmlParseOptions",
        "UPHtmlParseResult", "UPHtmlStyleBag", "UPHtmlParser", "UPHtmlLexer",
        "UP_HTML_MERGE_THRESHOLD", "upHtmlSpanValue", "upHtmlMakeSet", "upHtmlTrustTag",
        "upHtmlBlockTag", "upHtmlInlineTag", "upHtmlIgnoreTag", "upHtmlVoidTag",
        "upHtmlBlankChar", "upHtmlDefaultTagStyle", "upHtmlSvgName", "upHtmlEntity",
        "upHtmlFontSize", "upHtmlListType", "upHtmlDecodeEntity", "upHtmlMergeNodes",
        "upHtmlResolveUrl", "upHtmlSplitDeclarations", "upHtmlConvertRpx",
        "upHtmlAttributeSize", "upHtmlLetter", "upHtmlNodesText", "upHtmlParse",
        "onOpenTag", "onCloseTag", "onText", "onTagName", "onAttrName", "onAttrVal",
        "popNode", "parseStyle", "applyStyle", "decorateTable", "decorateCells",
        "pushCellStyles", "convertRuby", "prepareImage", "recordDropped", "styleForTag",
        "expose", "checkClose", "readText", "readTagName", "readAttrName",
        "readAttrValue", "readEndTag", "preserveWhitespace", "imageIndex", "tableDisplay",
    ),
    "UPHtmlLayout": (
        "UPHtmlTextStyle", "UPHtmlBlockStyle", "UPHtmlTextRun", "UPHtmlTableCell",
        "UPHtmlTableRow", "UPHtmlBlock", "UPHtmlLayoutOptions", "UPHtmlLayoutResult",
        "UPHtmlLayout", "UP_HTML_BASE_FONT_SIZE", "UP_HTML_LINK_COLOR",
        "UP_HTML_LIST_INDENT", "UP_HTML_MARKER_DISC", "UP_HTML_MARKER_CIRCLE",
        "UP_HTML_MARKER_SQUARE", "UP_HTML_HEADING_SCALES", "UP_HTML_HEADING_MARGINS",
        "UP_HTML_NAMED_SIZES", "upHtmlLength", "upHtmlResolveFontSize", "upHtmlEdges",
        "upHtmlBorderParts", "upHtmlRoman", "upHtmlAlpha", "upHtmlListMarker",
        "upHtmlHeadingLevel", "upHtmlRenderInline", "ensureOpen", "openBlock", "flush",
        "pushRun", "walk", "visitElement", "emitList", "emitImage", "emitDivider",
        "emitMedia", "emitTable", "collectRows", "buildCell", "decorate", "applyTag",
        "applyDeclarations", "applySideDeclaration", "carryMarker", "unsupported",
    ),
    "UPMarkdownSource": (
        "UP_MARKDOWN_ROOT_PADDING", "UP_MARKDOWN_BASE_FONT_SIZE", "UP_MARKDOWN_LINE_HEIGHT",
        "UP_MARKDOWN_CODE_CLASS", "UP_MARKDOWN_LANG_CLASS", "UP_MARKDOWN_LINE_NUMBERS_CLASS",
        "UP_MARKDOWN_LIGHT_COLOR", "UP_MARKDOWN_LIGHT_LINK", "UP_MARKDOWN_LIGHT_CODE",
        "UP_MARKDOWN_LIGHT_QUOTE", "UP_MARKDOWN_DARK_COLOR", "UP_MARKDOWN_DARK_BACKGROUND",
        "UP_MARKDOWN_DARK_LINK", "UP_MARKDOWN_DARK_CODE", "UP_MARKDOWN_DARK_CODE_COLOR",
        "UP_MARKDOWN_DARK_QUOTE", "UP_MARKDOWN_QUOTE_BORDER", "UP_MARKDOWN_TABLE_BORDER",
        "UP_MARKDOWN_RULE_COLOR", "UP_MARKDOWN_IMAGE_BACKGROUND",
        "UP_MARKDOWN_HEADING_SIZES", "UP_MARKDOWN_HEADING_MARGINS", "UP_MARKDOWN_THEMES",
        "UPMarkdownSlice", "UPMarkdownSpan", "UPMarkdownLink", "upMarkdownEscape",
        "upMarkdownAttribute", "upMarkdownIndent", "upMarkdownFenceMark",
        "upMarkdownHeadingLevel", "upMarkdownRuleLine", "upMarkdownBulletWidth",
        "upMarkdownOrderedWidth", "upMarkdownOrderedStart", "upMarkdownTableDelimiter",
        "upMarkdownCells", "upMarkdownAlignment", "upMarkdownInline", "upMarkdownGutter",
        "upMarkdownSetextLevel", "upMarkdownJoinLines", "upMarkdownHardBreak",
        "upMarkdownReadLink", "upMarkdownReadDelimited", "upMarkdownRunLength",
        "upMarkdownCodeBlock", "upMarkdownToHtml", "upMarkdownApplyTheme",
        "upMarkdownTagStyle", "upMarkdownThemeSupported", "upMarkdownDarkTheme",
        "upMarkdownBaseColor", "upMarkdownLinkColor", "upMarkdownBackground",
        "upMarkdownFenced", "upMarkdownParagraph", "upMarkdownTable", "upMarkdownTight",
        "upMarkdownQuote", "upMarkdownList", "upMarkdownBlocks",
    ),
}

CONTROLLER_TOKENS = {
    "UPParseController": (
        "UPParseCommand", "UPParseControllerListener", "mount", "unmount", "setContent",
        "scrollToAnchor", "pauseMedia", "setPlaybackRate", "getText", "imageList",
        "documentTitle", "updateSnapshot", "dispatch",
    ),
}

DEMOS_BY_ROUTE = {
    "parse": "ParseDemo.ets",
    "markdown": "MarkdownDemo.ets",
    "picker-column": "PickerColumnDemo.ets",
    "city-locate": "CityLocateDemo.ets",
    "pdf-reader": "PdfReaderDemo.ets",
}

DEFAULTS = {
    "UPParse": {
        "content": "''", "copyLink": "true", "domain": "''", "errorImg": "''",
        "lazyLoad": "false", "loadingImg": "''", "pauseVideo": "true",
        "previewImg": "true", "scrollTable": "false", "selectable": "false",
        "setTitle": "true", "showImgMenu": "true", "useAnchor": "false",
        "baseColor": "'#303133'", "linkColor": "UP_HTML_LINK_COLOR",
        "baseFontSize": "UP_HTML_BASE_FONT_SIZE", "viewportWidth": "375",
    },
    "UPMarkdown": {
        "content": "''", "previewImg": "true", "copyLink": "true", "domain": "''",
        "showLineNumber": "false", "theme": "'light'", "selectable": "false",
        "baseFontSize": "UP_MARKDOWN_BASE_FONT_SIZE", "viewportWidth": "375",
        "scrollTable": "false", "useAnchor": "false",
    },
    "UPPickerColumn": {
        "itemHeight": "UP_PICKER_COLUMN_ITEM_HEIGHT", "align": "'center'",
    },
    "UPCityLocate": {
        "locationType": "'wgs84'", "currentCity": "''", "nameKey": "'name'",
        "sticky": "true", "showSidebar": "true",
    },
    "UPPdfReader": {
        "src": "''", "height": "UP_PDF_READER_HEIGHT", "baseUrl": "UP_PDF_READER_BASE_URL",
    },
}

CONSTANTS = {
    "UPParse": {
        "UP_PARSE_ROOT_PADDING": "1", "UP_PARSE_MEDIA_WIDTH": "300",
        "UP_PARSE_MEDIA_HEIGHT": "225", "UP_PARSE_MARKER_WIDTH": "22",
    },
    "UPPickerColumn": {"UP_PICKER_COLUMN_ITEM_HEIGHT": "44"},
    "UPCityLocate": {"UP_CITY_LOCATE_HEADER_HEIGHT": "30"},
}

INTERNAL_CONSTANTS = {
    "UPHtmlParser": {"UP_HTML_MERGE_THRESHOLD": "50"},
    "UPHtmlLayout": {
        "UP_HTML_BASE_FONT_SIZE": "16", "UP_HTML_LIST_INDENT": "40",
    },
    "UPMarkdownSource": {
        "UP_MARKDOWN_ROOT_PADDING": "16", "UP_MARKDOWN_BASE_FONT_SIZE": "16",
    },
}

STRING_CONSTANTS = {
    "UPParse": {
        "UP_PARSE_TEXT_FAMILY": "'HarmonyOS Sans'", "UP_PARSE_MONO_FAMILY": "'monospace'",
        "UP_PARSE_TRANSPARENT": "'#00000000'",
    },
    "UPCityLocate": {
        "UP_CITY_LOCATE_TITLE": r"UPI18n\.t\('up\.cityLocate\.locateCity'\)",
        "UP_CITY_LOCATE_LOADING": r"UPI18n\.t\('up\.cityLocate\.locating'\)",
        "UP_CITY_LOCATE_FAIL": r"UPI18n\.t\('up\.cityLocate\.fail'\)",
        "UP_CITY_LOCATE_DOTS": "'\\.\\.\\.\\.'",
        "UP_CITY_LOCATE_TITLE_COLOR": "'#909399'",
        "UP_CITY_LOCATE_TEXT_COLOR": "'#303133'",
        "UP_CITY_LOCATE_HOT_BORDER": "'#ededed'",
    },
    "UPPdfReader": {
        "UP_PDF_READER_VIEWER_PATH": "'/static/pdfjs/web/viewer\\.html'",
        "UP_PDF_READER_FILE_QUERY": "'\\?file='",
        "UP_PDF_READER_HEIGHT": "'500px'", "UP_PDF_READER_WIDTH": "'750rpx'",
        "UP_PDF_READER_ICON": "'file-text'",
    },
}

INTERNAL_STRING_CONSTANTS = {
    "UPHtmlLayout": {"UP_HTML_LINK_COLOR": "'#366092'"},
    "UPMarkdownSource": {
        "UP_MARKDOWN_LINE_HEIGHT": "'1\\.6em'",
        "UP_MARKDOWN_LIGHT_COLOR": "'#333'", "UP_MARKDOWN_LIGHT_LINK": "'#007AFF'",
        "UP_MARKDOWN_LIGHT_CODE": "'#f6f8fa'", "UP_MARKDOWN_LIGHT_QUOTE": "'#666'",
        "UP_MARKDOWN_DARK_COLOR": "'#ccc'", "UP_MARKDOWN_DARK_BACKGROUND": "'#1e1e1e'",
        "UP_MARKDOWN_DARK_LINK": "'#4da6ff'", "UP_MARKDOWN_DARK_CODE": "'#2d2d2d'",
        "UP_MARKDOWN_DARK_CODE_COLOR": "'#dcdcdc'", "UP_MARKDOWN_DARK_QUOTE": "'#bbb'",
        "UP_MARKDOWN_TABLE_BORDER": "'#dfe2e5'", "UP_MARKDOWN_RULE_COLOR": "'#e1e4e8'",
        "UP_MARKDOWN_CODE_CLASS": "'up-markdown-code'",
        "UP_MARKDOWN_LANG_CLASS": "'code-lang'",
        "UP_MARKDOWN_LINE_NUMBERS_CLASS": "'up-markdown-line-numbers'",
    },
}

EXPORTS = (
    "UPParse", "UPParseProps", "UPParseOptions", "UPParseImageTapEvent",
    "UPParseLinkTapEvent", "UPParseReadyEvent", "UPParseMediaEvent",
    "UPParseErrorEvent", "UPParseController", "UPParseCommand",
    "UPParseControllerListener", "UPHtmlDeclaration", "UPHtmlParseOptions",
    "UPHtmlParseResult", "upHtmlParse", "upHtmlNodesText", "UP_HTML_BASE_FONT_SIZE",
    "UP_HTML_LINK_COLOR", "UP_HTML_LIST_INDENT", "upHtmlListMarker", "UPMarkdown",
    "UPMarkdownProps", "UPMarkdownOptions", "UP_MARKDOWN_HEADING_SIZES",
    "UP_MARKDOWN_HEADING_MARGINS", "UP_MARKDOWN_THEMES", "upMarkdownToHtml",
    "upMarkdownInline", "upMarkdownCodeBlock", "upMarkdownGutter",
    "upMarkdownApplyTheme", "upMarkdownTagStyle", "upMarkdownThemeSupported",
    "upMarkdownHeadingLevel", "upMarkdownSetextLevel", "upMarkdownRuleLine",
    "upMarkdownFenceMark", "upMarkdownTableDelimiter",
    "UPPickerColumn", "UPPickerColumnProps", "UPPickerColumnOptions",
    "UP_PICKER_COLUMN_ITEM_HEIGHT", "upPickerColumnAlign",
    "upPickerColumnAlignSupported", "UPCityLocate", "UPCityLocateProps",
    "UPCityLocateOptions", "UPCityLocateItem", "UPCityLocateRequest",
    "UPCityLocateResult", "UPCityLocateSuccessEvent", "UPCityLocateSelectEvent",
    "UPCityLocateFailureEvent", "UPCityLocateFailureReason", "UP_CITY_LOCATE_TITLE",
    "UP_CITY_LOCATE_LOADING", "UP_CITY_LOCATE_FAIL", "UP_CITY_LOCATE_HOT_INDEX",
    "upCityLocateName", "upCityLocateKeySupported", "upCityLocateHotCities",
    "upCityLocateDefaultList", "UPPdfReader", "UPPdfReaderProps", "UPPdfReaderOptions",
    "UPPdfReaderViewerEvent", "UP_PDF_READER_BASE_URL", "UP_PDF_READER_VIEWER_PATH",
    "UP_PDF_READER_FILE_QUERY", "UP_PDF_READER_HEIGHT", "upPdfReaderEncode",
    "upPdfReaderViewerUrl",
)

RESERVED_HELPER_NAMES = ("overlay", "position", "margin", "offset")


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)

    sources: dict[str, str] = {}
    for name, required in SOURCES.items():
        source = read(COMPONENTS / f"{name}.ets")
        sources[name] = source
        assert "@Component" in source and f"export struct {name}" in source
        assert f"export class {name}Props" in source and f"export interface {name}Options" in source
        for token in required:
            assert token in source, f"{name} missing {token}"
        assert name in index and f"{name}Props" in index, f"{name} is not publicly exported"
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"
        for helper in RESERVED_HELPER_NAMES:
            assert f"private {helper}(" not in source, (
                f"{name} helper {helper}() collides with a CommonAttribute method"
            )

    internals: dict[str, str] = {}
    for name, required in INTERNAL_SOURCES.items():
        source = read(INTERNAL / f"{name}.ets")
        internals[name] = source
        for token in required:
            assert token in source, f"{name} missing {token}"
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    controllers: dict[str, str] = {}
    for name, required in CONTROLLER_TOKENS.items():
        source = read(CONTROLLERS / f"{name}.ets")
        controllers[name] = source
        assert f"export class {name}" in source
        for token in required:
            assert token in source, f"{name} missing {token}"
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for symbol in EXPORTS:
        assert symbol in index, f"public entry missing {symbol}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{re.escape(value)}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    for component, constants in CONSTANTS.items():
        for constant, value in constants.items():
            assert re.search(rf"{constant}:\s*number\s*=\s*{value}\s*;", sources[component]), (
                f"{component} constant {constant}={value} missing"
            )

    for component, constants in STRING_CONSTANTS.items():
        for constant, value in constants.items():
            assert re.search(rf"{constant}:\s*string\s*=\s*{value}\s*;", sources[component]), (
                f"{component} constant {constant}={value} missing"
            )

    for module, constants in INTERNAL_CONSTANTS.items():
        for constant, value in constants.items():
            assert re.search(rf"{constant}:\s*number\s*=\s*{value}\s*;", internals[module]), (
                f"{module} constant {constant}={value} missing"
            )

    for module, constants in INTERNAL_STRING_CONSTANTS.items():
        for constant, value in constants.items():
            assert re.search(rf"{constant}:\s*string\s*=\s*{value}\s*;", internals[module]), (
                f"{module} constant {constant}={value} missing"
            )

    parser = internals["UPHtmlParser"]
    for tag in ("'a,abbr,ad,audio,b,blockquote", "'address,article,aside,body,caption",
                "'abbr,b,big,code,del,em,i,ins", "'area,base,canvas,embed,frame,head,iframe",
                "'area,base,br,col,circle,ellipse"):
        assert tag in parser, f"UPHtmlParser tag set missing {tag}"
    for entity in ("'nbsp'", "'mdash'", "'hellip'", "'rarr'"):
        assert entity in parser, f"UPHtmlParser entity table missing {entity}"
    for style in ("'font-family:monospace;white-space:pre'", "'text-decoration:line-through'",
                  "'display:table-caption;text-align:center'", "'margin-left:40px'"):
        assert style in parser, f"UPHtmlParser default tag style missing {style}"
    assert "node.name = 'div'" in parser and "node.name = 'span'" in parser, (
        "UPHtmlParser keeps the upstream block and untrusted tag rewrites"
    )
    assert "this.title = children[0].text" in parser, (
        "UPHtmlParser keeps the <title> capture used by setTitle"
    )

    layout = internals["UPHtmlLayout"]
    assert "[2, 1.5, 1.17, 1, 0.83, 0.67]" in layout, "UPHtmlLayout heading scales changed"
    assert "[0.67, 0.83, 1, 1.33, 1.67, 2.33]" in layout, "UPHtmlLayout heading margins changed"
    for kind in ("'text'", "'image'", "'divider'", "'media'", "'table'"):
        assert kind in layout, f"UPHtmlLayout block kind {kind} missing"
    for style in ("'lower-roman'", "'upper-alpha'", "'decimal-leading-zero'", "'square'"):
        assert style in layout, f"UPHtmlLayout list style {style} missing"
    for key in ("'font-size'", "'line-height'", "'list-style-type'", "'white-space'",
                "'border-left'", "'border-radius'", "'text-decoration-line'"):
        assert key in layout, f"UPHtmlLayout declaration {key} missing"
    for unsupported in ("box-sizing", "border-collapse", "overflow-x"):
        assert unsupported not in layout, (
            f"UPHtmlLayout must not silently accept {unsupported}"
        )

    markdown_source = internals["UPMarkdownSource"]
    assert "[32, 24, 18, 16, 13, 10]" in markdown_source, "UPMarkdownSource heading sizes changed"
    assert "[8, 8, 7, 7, 6, 5]" in markdown_source, "UPMarkdownSource heading margins changed"
    assert "'```'" in markdown_source and "'~~~'" in markdown_source, (
        "UPMarkdownSource keeps both fence markers"
    )
    for tag in ("'<blockquote>'", "'<table><thead><tr>'", "'<hr>'"):
        assert tag in markdown_source, f"UPMarkdownSource block output missing {tag}"
    for inline in ("'<strong>'", "'<em>'", "'<del>'", "'<code>'"):
        assert inline in markdown_source, f"UPMarkdownSource inline output missing {inline}"
    assert "'<br>'" in markdown_source, "UPMarkdownSource keeps the hard break output"
    assert "first === '=' ? 1 : 2" in markdown_source, (
        "UPMarkdownSource keeps both setext heading levels"
    )
    assert "padding-left:32px" in markdown_source, "UPMarkdownSource list indent changed"
    assert "padding:6px 13px" in markdown_source, "UPMarkdownSource table cell padding changed"
    assert "font-weight:600" in markdown_source, "UPMarkdownSource th weight changed"

    parse = sources["UPParse"]
    for field in ("lazyLoad", "loadingImg", "errorImg", "previewImg", "showImgMenu",
                  "pauseVideo", "setTitle"):
        assert f"'{field}'" in parse, f"UPParse must report the {field} boundary"
    assert "'openLink rejected the external link'" in parse
    assert "'media source list is empty'" in parse
    assert "'视频占位'" in parse and "'音频占位'" in parse

    markdown = sources["UPMarkdown"]
    assert "'light'" in markdown, "UPMarkdown keeps the upstream default theme"
    assert "'light', 'dark'" in markdown_source, "UPMarkdown themes missing"
    for field in ("theme", "applyTheme", "showLineNumber", "content"):
        assert f"'{field}'" in markdown, f"UPMarkdown must report the {field} boundary"

    picker_column = sources["UPPickerColumn"]
    assert "'center'" in picker_column and "'start'" in picker_column and "'end'" in picker_column
    for field in ("align", "picker-view-column"):
        assert f"'{field}'" in picker_column, f"UPPickerColumn must report the {field} boundary"

    city = sources["UPCityLocate"]
    for hot in ("'北京'", "'上海'", "'广州'", "'深圳'", "'杭州'"):
        assert hot in city, f"UPCityLocate default hot city {hot} missing"
    for value in ("'beijing'", "'shanghai'", "'guangzhou'", "'shenzhen'", "'hangzhou'"):
        assert value in city, f"UPCityLocate default hot city value {value} missing"
    for field in ("nameKey", "locationType", "locate", "header", "footer"):
        assert f"'{field}'" in city, f"UPCityLocate must report the {field} boundary"

    pdf = sources["UPPdfReader"]
    assert "'https' + '://uview-plus.jiangruyi.com/h5'" in pdf, (
        "UPPdfReader keeps the upstream default viewer host without a literal URL"
    )
    for field in ("src", "baseUrl", "web-view-styles"):
        assert f"'{field}'" in pdf, f"UPPdfReader must report the {field} boundary"
    assert "0xd800" in pdf and "0xdc00" in pdf, "UPPdfReader keeps surrogate pair encoding"

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components W" in catalog, "missing Phase 19 sample group Components W"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from public HAR entry"
        assert "../src/main" not in demo and "ultra-ui/src" not in demo
        assert not re.search(r"=>\s*this\.", demo), f"{filename} must not capture this in arrow bodies"
        for token in FORBIDDEN:
            assert token not in demo, f"{filename} contains forbidden boundary {token}"
        assert route in page and filename.replace(".ets", "") in page, f"sample dispatch missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in (
        "阶段 19", "UPParse", "UPMarkdown", "UPPickerColumn", "UPCityLocate",
        "UPPdfReader", "Components W", "137 个组件", "137 条组件示例路由",
        "phase-19.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 19 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPParse", "UPParseController", "UPMarkdown",
        "UPPickerColumn", "UPCityLocate", "UPPdfReader", "mp-html", "marked",
        "encodeURIComponent", "applyTheme", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-19 note missing {phrase}"

    print("phase 19 parse markdown contract: PASS")


if __name__ == "__main__":
    main()
