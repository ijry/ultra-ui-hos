import { UPRawValue, UPStyleInput, upBoolean, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIndexItem, UPIndexItemProps } from './UPIndexItem';
import { UPIndexList, UPIndexListProps, UPIndexListSelectEvent } from './UPIndexList';
import { UPLine, UPLineProps } from './UPLine';
import { UPI18n, upWeekText } from '../core/UPI18n';

/** 上游 i18n 的三条文案。/ The three upstream i18n strings. */
export const UP_CITY_LOCATE_TITLE: string = UPI18n.t('up.cityLocate.locateCity');
export const UP_CITY_LOCATE_LOADING: string = UPI18n.t('up.cityLocate.locating');
export const UP_CITY_LOCATE_FAIL: string = UPI18n.t('up.cityLocate.fail');
/** 上游 locationCity 初值的省略号。/ The ellipsis appended to the initial locationCity. */
export const UP_CITY_LOCATE_DOTS: string = '....';
/** 上游 scss 的取色。/ Colors from the upstream scss. */
export const UP_CITY_LOCATE_TITLE_COLOR: string = '#909399';
export const UP_CITY_LOCATE_TEXT_COLOR: string = '#303133';
export const UP_CITY_LOCATE_HOT_BORDER: string = '#ededed';
export const UP_CITY_LOCATE_HOT_BACKGROUND: string = '#ffffff';
/** 上游 .u-current-city-item 的高度。/ Height of the upstream current city row. */
export const UP_CITY_LOCATE_HEADER_HEIGHT: number = 30;
/** 上游默认索引与热门城市列表。/ Upstream default index list and hot cities. */
export const UP_CITY_LOCATE_HOT_INDEX: string = '🔥';

/** 城市条目的具名模型，替代上游任意对象。/ Named city entry instead of an arbitrary object. */
export interface UPCityLocateItem {
  name?: string;
  value?: string;
  city?: string;
  label?: string;
}

/** 宿主定位请求。/ Locate request handed to the host. */
export interface UPCityLocateRequest {
  type: string;
  geocode: boolean;
}

/** 宿主定位结果，对应 uni.getLocation 的成功回调。/ Host locate result mirroring uni.getLocation. */
export interface UPCityLocateResult {
  city?: string;
  address?: string;
  latitude?: number;
  longitude?: number;
}

/** 上游 location-success 事件。/ Upstream location-success payload. */
export interface UPCityLocateSuccessEvent {
  locationCity: string;
  city: string;
  address: string;
  latitude: number;
  longitude: number;
}

/** 上游 select-city 事件。/ Upstream select-city payload. */
export interface UPCityLocateSelectEvent {
  locationCity: string;
}

/** 定位失败原因。/ Reason a locate attempt failed. */
export type UPCityLocateFailureReason = 'locate-unavailable' | 'locate-failed' | 'empty-city';

/** 定位失败事件。/ Locate failure payload. */
export interface UPCityLocateFailureEvent {
  reason: UPCityLocateFailureReason;
  notice: string;
}

/** nameKey 白名单读取，替代上游 item[nameKey]。/ Named lookup instead of a dynamic key. */
export function upCityLocateName(item: UPCityLocateItem, keyName: string): string {
  if (keyName === 'value' && item.value !== undefined) {
    return item.value;
  }
  if (keyName === 'city' && item.city !== undefined) {
    return item.city;
  }
  if (keyName === 'label' && item.label !== undefined) {
    return item.label;
  }
  if (keyName === 'name' && item.name !== undefined) {
    return item.name;
  }
  return item.name ?? item.city ?? item.label ?? item.value ?? '';
}

/** nameKey 是否落在具名模型字段内。/ Whether nameKey targets a modelled field. */
export function upCityLocateKeySupported(keyName: string): boolean {
  return keyName.length === 0 || keyName === 'name' || keyName === 'value'
    || keyName === 'city' || keyName === 'label';
}

/** 上游默认 cityList 的热门分组。/ The hot group of the upstream default cityList. */
export function upCityLocateHotCities(): Array<UPCityLocateItem> {
  return [
    { name: '北京', value: 'beijing' },
    { name: '上海', value: 'shanghai' },
    { name: '广州', value: 'guangzhou' },
    { name: '深圳', value: 'shenzhen' },
    { name: '杭州', value: 'hangzhou' }
  ];
}

/** 上游默认 cityList。/ The upstream default cityList. */
export function upCityLocateDefaultList(): Array<Array<UPCityLocateItem>> {
  return [upCityLocateHotCities()];
}

export interface UPCityLocateOptions {
  indexList?: Array<UPRawValue>;
  cityList?: Array<Array<UPCityLocateItem>>;
  locationType?: UPRawValue;
  currentCity?: UPRawValue;
  nameKey?: UPRawValue;
  sticky?: UPRawValue;
  showSidebar?: UPRawValue;
  customStyle?: UPStyleInput;
  listStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  locate?: (request: UPCityLocateRequest) => UPCityLocateResult | undefined;
  onLocationSuccess?: (event: UPCityLocateSuccessEvent) => void;
  onLocationFail?: (event: UPCityLocateFailureEvent) => void;
  onSelectCity?: (event: UPCityLocateSelectEvent) => void;
  onIndexSelect?: (event: UPIndexListSelectEvent) => void;
}

export class UPCityLocateProps {
  indexList: Array<UPRawValue> = [UP_CITY_LOCATE_HOT_INDEX];
  cityList: Array<Array<UPCityLocateItem>> = upCityLocateDefaultList();
  locationType: UPRawValue = 'wgs84';
  currentCity: UPRawValue = '';
  nameKey: UPRawValue = 'name';
  sticky: UPRawValue = true;
  showSidebar: UPRawValue = true;
  customStyle: UPStyleInput = undefined;
  listStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  locate?: (request: UPCityLocateRequest) => UPCityLocateResult | undefined;
  onLocationSuccess?: (event: UPCityLocateSuccessEvent) => void;
  onLocationFail?: (event: UPCityLocateFailureEvent) => void;
  onSelectCity?: (event: UPCityLocateSelectEvent) => void;
  onIndexSelect?: (event: UPIndexListSelectEvent) => void;

  constructor(options?: UPCityLocateOptions) {
    if (options === undefined) {
      return;
    }
    this.indexList = options.indexList ?? this.indexList;
    this.cityList = options.cityList ?? this.cityList;
    this.locationType = options.locationType ?? this.locationType;
    this.currentCity = options.currentCity ?? this.currentCity;
    this.nameKey = options.nameKey ?? this.nameKey;
    this.sticky = options.sticky ?? this.sticky;
    this.showSidebar = options.showSidebar ?? this.showSidebar;
    this.customStyle = options.customStyle;
    this.listStyle = options.listStyle;
    this.diagnostics = options.diagnostics;
    this.locate = options.locate;
    this.onLocationSuccess = options.onLocationSuccess;
    this.onLocationFail = options.onLocationFail;
    this.onSelectCity = options.onSelectCity;
    this.onIndexSelect = options.onIndexSelect;
  }
}

/** 单个索引分组的渲染模型。/ Render model of one index group. */
class UPCityLocateSectionModel {
  label: UPRawValue = '';
  hot: boolean = false;
  nameKey: string = 'name';
  cities: Array<UPCityLocateItem> = [];
  onPick?: (city: UPCityLocateItem) => void;
}

@Component
struct UPCityLocateSection {
  @Prop model: UPCityLocateSectionModel = new UPCityLocateSectionModel();

  private cityText(city: UPCityLocateItem): string {
    return upCityLocateName(city, this.model.nameKey);
  }

  private pick(city: UPCityLocateItem): void {
    this.model.onPick?.(city);
  }

  @Builder
  private hotCities() {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
      ForEach(this.model.cities, (city: UPCityLocateItem) => {
        Text(this.cityText(city))
          .fontSize(14)
          .fontColor(UP_CITY_LOCATE_TEXT_COLOR)
          .padding({ top: 6, right: 12, bottom: 6, left: 12 })
          .margin(5)
          .backgroundColor(UP_CITY_LOCATE_HOT_BACKGROUND)
          .borderWidth(1)
          .borderColor(UP_CITY_LOCATE_HOT_BORDER)
          .onClick((): void => this.pick(city))
      }, (city: UPCityLocateItem, index: number): string => String(index) + '-' + this.cityText(city))
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  private cityRows() {
    Column() {
      ForEach(this.model.cities, (city: UPCityLocateItem) => {
        Column() {
          Row() {
            Text(this.cityText(city))
              .fontSize(14)
              .fontColor(UP_CITY_LOCATE_TEXT_COLOR)
          }
          .width('100%')
          .padding({ top: 8, right: 1, bottom: 8, left: 1 })
          .onClick((): void => this.pick(city))
          UPLine({ props: new UPLineProps() })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }, (city: UPCityLocateItem, index: number): string => String(index) + '-' + this.cityText(city))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private sectionBody() {
    Column() {
      if (this.model.hot) {
        this.hotCities()
      } else {
        this.cityRows()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    UPIndexItem({
      props: new UPIndexItemProps({ index: this.model.label }),
      contentBuilder: this.sectionBody
    })
  }
}

/**
 * u-city-locate 的 HarmonyOS 原生实现：索引列表复用 UPIndexList，定位由宿主回调提供。
 * Native u-city-locate: reuses UPIndexList and delegates positioning to a host callback.
 */
@Component
export struct UPCityLocate {
  @Prop @Watch('applyProps') props: UPCityLocateProps = new UPCityLocateProps();
  @State private locationCity: string = UP_CITY_LOCATE_LOADING + UP_CITY_LOCATE_DOTS;
  private applied: string = '';

  aboutToAppear(): void {
    this.applied = this.signature();
    this.reportBoundaries();
    this.requestLocation();
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    const current: string = upString(this.props.currentCity);
    if (current.length > 0) {
      this.locationCity = current;
    }
    this.reportBoundaries();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    return upString(this.props.currentCity) + '|' + this.nameKeyValue() + '|' + this.locationTypeValue();
  }

  private nameKeyValue(): string {
    const keyName: string = upString(this.props.nameKey, 'name');
    return keyName.length > 0 ? keyName : 'name';
  }

  private locationTypeValue(): string {
    const type: string = upString(this.props.locationType, 'wgs84');
    return type.length > 0 ? type : 'wgs84';
  }

  private reportBoundaries(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    if (!upCityLocateKeySupported(this.nameKeyValue())) {
      diagnostics.report('UPCityLocate', 'nameKey', this.props.nameKey,
        'nameKey falls back to the modelled city fields name, value, city and label');
    }
    diagnostics.report('UPCityLocate', 'locationType', this.props.locationType,
      'system positioning is delegated to the host through the locate callback');
    diagnostics.report('UPCityLocate', 'header', '',
      'the locate header is pinned above the index list because the list header slot is reserved for anchors');
    diagnostics.report('UPCityLocate', 'footer', '',
      'the upstream footer slot only carries a safe-area spacer, so it is omitted');
  }

  /** 上游 location()：改为宿主同步回调。/ Upstream location(), routed through the host callback. */
  requestLocation(): void {
    if (this.props.locate === undefined) {
      this.locationCity = UP_CITY_LOCATE_FAIL;
      this.diagnostics().report('UPCityLocate', 'locate', '',
        'no locate callback is connected, so the failure notice is shown');
      this.props.onLocationFail?.({ reason: 'locate-unavailable', notice: UP_CITY_LOCATE_FAIL });
      return;
    }
    let result: UPCityLocateResult | undefined = undefined;
    try {
      result = this.props.locate({ type: this.locationTypeValue(), geocode: true });
    } catch (_error) {
      result = undefined;
    }
    if (result === undefined) {
      this.locationCity = UP_CITY_LOCATE_FAIL;
      this.props.onLocationFail?.({ reason: 'locate-failed', notice: UP_CITY_LOCATE_FAIL });
      return;
    }
    const city: string = result.city ?? '';
    if (city.length === 0) {
      this.locationCity = UP_CITY_LOCATE_FAIL;
      this.props.onLocationFail?.({ reason: 'empty-city', notice: UP_CITY_LOCATE_FAIL });
      return;
    }
    this.locationCity = city;
    this.props.onLocationSuccess?.({
      locationCity: city,
      city: city,
      address: result.address ?? '',
      latitude: result.latitude ?? 0,
      longitude: result.longitude ?? 0
    });
  }

  /** 上游 selectedCity()。/ Upstream selectedCity(). */
  private pickCity(city: UPCityLocateItem): void {
    const name: string = upCityLocateName(city, this.nameKeyValue());
    this.locationCity = name;
    this.props.onSelectCity?.({ locationCity: name });
  }

  private groupIndexes(): Array<number> {
    const indexes: Array<number> = [];
    for (let index: number = 0; index < this.props.cityList.length; index++) {
      indexes.push(index);
    }
    return indexes;
  }

  private indexLabel(groupIndex: number): UPRawValue {
    return groupIndex < this.props.indexList.length ? this.props.indexList[groupIndex] : String(groupIndex + 1);
  }

  private sectionModel(groupIndex: number): UPCityLocateSectionModel {
    const model: UPCityLocateSectionModel = new UPCityLocateSectionModel();
    model.label = this.indexLabel(groupIndex);
    model.hot = groupIndex === 0;
    model.nameKey = this.nameKeyValue();
    model.cities = this.props.cityList[groupIndex];
    model.onPick = (city: UPCityLocateItem): void => this.pickCity(city);
    return model;
  }

  private listProps(): UPIndexListProps {
    return new UPIndexListProps({
      indexList: this.props.indexList,
      sticky: this.props.sticky,
      showSidebar: this.props.showSidebar,
      customStyle: this.props.listStyle,
      diagnostics: this.props.diagnostics,
      onSelect: this.props.onIndexSelect
    });
  }

  @Builder
  private sections() {
    ForEach(this.groupIndexes(), (groupIndex: number) => {
      UPCityLocateSection({ model: this.sectionModel(groupIndex) })
    }, (groupIndex: number): string => 'group-' + String(groupIndex))
  }

  @Builder
  private locateHeader() {
    Column() {
      Text(UP_CITY_LOCATE_TITLE)
        .fontSize(14)
        .fontColor(UPColor.parse(UP_CITY_LOCATE_TITLE_COLOR, UP_DEFAULT_THEME, UP_CITY_LOCATE_TITLE_COLOR))
        .margin({ bottom: 5 })
      Row() {
        Text(this.locationCity)
          .fontSize(14)
          .fontColor(UPColor.parse(UP_CITY_LOCATE_TEXT_COLOR, UP_DEFAULT_THEME, UP_CITY_LOCATE_TEXT_COLOR))
      }
      .width('100%')
      .height(UP_CITY_LOCATE_HEADER_HEIGHT)
      .alignItems(VerticalAlign.Center)
      .onClick((): void => this.requestLocation())
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 12 })
  }

  build() {
    Column() {
      this.locateHeader()
      UPIndexList({ props: this.listProps() }) {
        this.sections()
      }
    }
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
    .padding(UPStyle.parse(this.props.customStyle).padding ?? 0)
    .backgroundColor(UPStyle.parse(this.props.customStyle).backgroundColor ?? UP_CITY_LOCATE_HOT_BACKGROUND)
    .alignItems(HorizontalAlign.Start)
  }
}
