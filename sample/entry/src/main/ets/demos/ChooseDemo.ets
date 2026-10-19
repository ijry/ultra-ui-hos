import {
  UPChoose,
  UPChooseChangeEvent,
  UPChooseItem,
  UPChooseProps,
  upChooseLabel,
  upChooseValue
} from '@lingyun/ultra-ui-hos';

@Component
export struct ChooseDemo {
  @State private wrapIndex: number = 0;
  @State private scrollIndex: number = 2;
  @State private status: string = '点击标签查看选中回传';
  private sizeOptions: Array<UPChooseItem> = [
    { title: '小杯', value: 's' },
    { title: '中杯', value: 'm' },
    { title: '大杯', value: 'l' },
    { title: '超大杯', value: 'xl' }
  ];
  private cityOptions: Array<UPChooseItem> = [
    { label: '北京', id: 110000 },
    { label: '上海', id: 310000 },
    { label: '广州', id: 440100 },
    { label: '深圳', id: 440300 },
    { label: '杭州', id: 330100 },
    { label: '成都', id: 510100 }
  ];

  private handleChange(event: UPChooseChangeEvent): void {
    this.wrapIndex = event.index;
    this.status = '选中第 ' + String(event.index + 1) + ' 项：'
      + upChooseLabel(event.item, 'title') + '（value ' + String(upChooseValue(event.item, 'value')) + '）';
  }

  private handleScrollChange(event: UPChooseChangeEvent): void {
    this.scrollIndex = event.index;
    this.status = '横滑选中：' + upChooseLabel(event.item, 'label')
      + '（id ' + String(upChooseValue(event.item, 'id')) + '）';
  }

  private handleCustomClick(event: UPChooseChangeEvent): void {
    this.status = 'customClick 拦截：点了 ' + upChooseLabel(event.item, 'title') + '，选中态未变';
  }

  build() {
    Column({ space: 16 }) {
      Text('换行排列与选中回传')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPChoose({
        props: new UPChooseProps({
          options: this.sizeOptions,
          modelValue: this.wrapIndex,
          onChange: (event: UPChooseChangeEvent): void => {
            this.handleChange(event);
          }
        })
      })
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')

      Text('横向滚动不换行')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPChoose({
        props: new UPChooseProps({
          options: this.cityOptions,
          modelValue: this.scrollIndex,
          labelName: 'label',
          valueName: 'id',
          wrap: false,
          itemHeight: '40px',
          itemPadding: '6px',
          onChange: (event: UPChooseChangeEvent): void => {
            this.handleScrollChange(event);
          }
        })
      })

      Text('customClick 交给宿主决定选中')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPChoose({
        props: new UPChooseProps({
          options: this.sizeOptions,
          modelValue: 1,
          customClick: true,
          onCustomClick: (event: UPChooseChangeEvent): void => {
            this.handleCustomClick(event);
          }
        })
      })
      Text('customClick 为真时组件只回传 onCustomClick，不改内部选中态，宿主可先弹确认再回写 modelValue。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('空数据态')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPChoose({ props: new UPChooseProps({ options: [] }) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
