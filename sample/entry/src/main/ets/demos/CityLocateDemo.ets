import {
  UPCityLocate,
  UPCityLocateFailureEvent,
  UPCityLocateItem,
  UPCityLocateProps,
  UPCityLocateRequest,
  UPCityLocateResult,
  UPCityLocateSelectEvent,
  UPCityLocateSuccessEvent,
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UP_CITY_LOCATE_FAIL,
  UP_CITY_LOCATE_HOT_INDEX,
  upCityLocateHotCities,
  upCityLocateKeySupported,
  upCityLocateName
} from '@lingyun/ultra-ui-hos';

@Component
export struct CityLocateDemo {
  @State private status: string = '定位能力由宿主注入，组件不会直接调用系统定位';
  @State private boundary: string = '';
  @State private granted: boolean = true;
  @State private selected: string = '';
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private probeKeys: Array<string> = ['name', 'city', 'label', 'pinyin'];
  private cities: Array<Array<UPCityLocateItem>> = [
    upCityLocateHotCities(),
    [{ name: '安庆', value: 'anqing' }, { name: '鞍山', value: 'anshan' }],
    [{ name: '北海', value: 'beihai' }, { name: '蚌埠', value: 'bengbu' }, { name: '保定', value: 'baoding' }],
    [{ name: '长沙', value: 'changsha' }, { name: '成都', value: 'chengdu' }]
  ];
  private indexes: Array<string> = [UP_CITY_LOCATE_HOT_INDEX, 'A', 'B', 'C'];

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private locate(request: UPCityLocateRequest): UPCityLocateResult | undefined {
    if (!this.granted) {
      return undefined;
    }
    return {
      city: '杭州',
      address: '浙江省杭州市',
      latitude: 30.28,
      longitude: 120.15
    };
  }

  private handleSuccess(event: UPCityLocateSuccessEvent): void {
    this.status = 'location-success：' + event.locationCity + '（' + event.address + '）';
  }

  private handleFail(event: UPCityLocateFailureEvent): void {
    this.status = '定位失败：' + event.reason + '，界面提示「' + event.notice + '」';
  }

  private handleSelect(event: UPCityLocateSelectEvent): void {
    this.selected = event.locationCity;
    this.status = 'select-city：' + event.locationCity;
  }

  private probeText(keyName: string): string {
    const sample: UPCityLocateItem = { name: '杭州', value: 'hangzhou' };
    return 'nameKey=' + keyName + (upCityLocateKeySupported(keyName)
      ? '：读取到 ' + upCityLocateName(sample, keyName)
      : '：不在具名字段内，回落 ' + upCityLocateName(sample, keyName) + ' 并报诊断');
  }

  build() {
    Column({ space: 16 }) {
      Text('城市定位与索引选择')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCityLocate({
        props: new UPCityLocateProps({
          indexList: this.indexes,
          cityList: this.cities,
          currentCity: '',
          nameKey: 'name',
          listStyle: { height: 320 },
          diagnostics: this.diagnostics,
          locate: (request: UPCityLocateRequest): UPCityLocateResult | undefined => {
            return this.locate(request);
          },
          onLocationSuccess: (event: UPCityLocateSuccessEvent): void => {
            this.handleSuccess(event);
          },
          onLocationFail: (event: UPCityLocateFailureEvent): void => {
            this.handleFail(event);
          },
          onSelectCity: (event: UPCityLocateSelectEvent): void => {
            this.handleSelect(event);
          }
        })
      })
      Row({ space: 10 }) {
        Button(this.granted ? '模拟定位失败' : '恢复定位成功')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.granted = !this.granted;
            this.status = this.granted
              ? '再次点击顶部定位行可重新定位'
              : '已切换为失败分支，点击顶部定位行会显示「' + UP_CITY_LOCATE_FAIL + '」';
          })
      }
      .width('100%')
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.selected.length > 0 ? '已选择：' + this.selected : '尚未选择城市')
        .fontSize(13)
        .fontColor('#606266')
        .width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('城市字段读取')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      ForEach(this.probeKeys, (keyName: string): void => {
        Text(this.probeText(keyName)).fontSize(12).fontColor('#909399').width('100%')
      }, (keyName: string): string => keyName)
      Text('第一组按上游渲染成热门城市横排标签，其余分组是列表行加分割线。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('定位入口固定在索引列表上方，上游 footer 只放安全区占位，本端省略。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
