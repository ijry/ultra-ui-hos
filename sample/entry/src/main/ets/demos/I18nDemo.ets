import {
  UPButton,
  UPButtonProps,
  UPI18n,
  UPI18nParam,
  UPLoadmore,
  UPLoadmoreProps,
  UPSection,
  UPSectionProps,
  UPToolbar,
  UPToolbarProps,
  UPValidateResult,
  UPValidator,
  upValidateMessagesFor,
  upWeekText
} from '@lingyun/ultra-ui-hos';

/** 一行文案对照。/ One key rendered across locales. */
interface I18nRow {
  key: string;
  current: string;
  chinese: string;
  english: string;
}

@Component
export struct I18nDemo {
  @State private locale: string = UPI18n.locale();
  @State private registered: boolean = false;
  @State private validateText: string = '切换语言后点击查看校验文案';
  private readonly sampleKeys: Array<string> = [
    'up.common.confirm',
    'up.common.cancel',
    'up.common.search',
    'up.common.loading2',
    'up.readMore.expand',
    'up.loadmoe.nomore',
    'up.noNetwork.text',
    'up.goodsSku.buyAmount'
  ];

  private rows(): Array<I18nRow> {
    const list: Array<I18nRow> = [];
    for (let index: number = 0; index < this.sampleKeys.length; index++) {
      const key: string = this.sampleKeys[index];
      list.push({
        key,
        current: UPI18n.translate(this.locale, key),
        chinese: UPI18n.translate('zh-Hans', key),
        english: UPI18n.translate('en', key)
      });
    }
    return list;
  }

  private switchTo(tag: string): void {
    this.locale = UPI18n.setLocale(tag);
    this.validateText = '当前语言：' + this.locale;
  }

  /** 演示 registerLocale 覆盖单个键。/ Shows a single-key override. */
  private toggleOverride(): void {
    if (this.registered) {
      UPI18n.clearLocale('en');
      this.registered = false;
      return;
    }
    const overrides: Array<UPI18nParam> = [
      { name: 'up.common.confirm', value: 'OK' },
      { name: 'up.common.cancel', value: 'Dismiss' }
    ];
    UPI18n.registerLocale('en', overrides);
    this.registered = true;
  }

  /** 校验文案按语言切换（本端扩展，上游校验器只有英文）。/ Locale-aware validator copy. */
  private runValidate(): void {
    const validator: UPValidator = new UPValidator(
      [{ field: 'name', label: this.locale === 'en' ? 'Name' : '姓名', rules: [{ required: true, type: 'string' }] }],
      upValidateMessagesFor(this.locale)
    );
    const result: UPValidateResult = validator.validate([{ field: 'name', value: '' }]);
    this.validateText = result.errors.length > 0 ? result.errors[0].message : '校验通过';
  }

  private placeholderText(): string {
    const params: Array<UPI18nParam> = [{ name: 'days', value: 7 }];
    return UPI18n.translate(this.locale, 'up.calendar.daysExceed', params);
  }

  @Builder
  private sectionTitle(text: string) {
    Text(text)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#303133')
      .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      this.sectionTitle('语言切换')
      Text('内置 ' + String(UPI18n.locales().length) + ' 种语言、每种 ' + String(UPI18n.keys().length) + ' 条文案')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(UPI18n.locales(), (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor(this.locale === tag ? '#ffffff' : '#606266')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.locale === tag ? '#2979ff' : '#f5f7fa')
            .borderRadius(4)
            .onClick((): void => {
              this.switchTo(tag);
            })
        }, (tag: string): string => tag)
      }
      .width('100%')

      this.sectionTitle('文案对照')
      Row() {
        Text('键').fontSize(11).fontColor('#909399').layoutWeight(3)
        Text('当前').fontSize(11).fontColor('#909399').layoutWeight(2)
        Text('zh-Hans').fontSize(11).fontColor('#909399').layoutWeight(2)
        Text('en').fontSize(11).fontColor('#909399').layoutWeight(2)
      }
      .width('100%')
      .padding({ bottom: 4 })
      .border({ width: { bottom: 1 }, color: '#ebeef5' })
      ForEach(this.rows(), (row: I18nRow) => {
        Row() {
          Text(row.key.replace('up.', '')).fontSize(11).fontColor('#c0c4cc').layoutWeight(3)
          Text(row.current).fontSize(12).fontColor('#2979ff').layoutWeight(2)
          Text(row.chinese).fontSize(12).fontColor('#606266').layoutWeight(2)
          Text(row.english).fontSize(12).fontColor('#606266').layoutWeight(2)
        }
        .width('100%')
        .padding({ top: 4, bottom: 4 })
      }, (row: I18nRow): string => row.key)

      this.sectionTitle('组件默认文案')
      UPToolbar({ props: new UPToolbarProps({ title: UPI18n.translate(this.locale, 'up.calendar.chooseDates') }) })
      UPSection({ props: new UPSectionProps({ title: UPI18n.translate(this.locale, 'up.common.more') }) })
      UPLoadmore({ props: new UPLoadmoreProps({ status: 'nomore' }) })
      Text('组件默认值在实例化时读取语言包；已挂载的组件不会随语言切换自动刷新，需要重建或显式传文案。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      this.sectionTitle('占位符与注册覆盖')
      Text(this.placeholderText())
        .fontSize(13)
        .fontColor('#606266')
        .width('100%')
      Row({ space: 8 }) {
        UPButton({ props: new UPButtonProps({
          text: this.registered ? '撤销 en 覆盖' : '覆盖 en 文案',
          type: 'primary',
          onClick: (): void => {
            this.toggleOverride();
          }
        }) })
        UPButton({ props: new UPButtonProps({
          text: '运行校验',
          onClick: (): void => {
            this.runValidate();
          }
        }) })
      }
      .width('100%')
      Text('registerLocale 覆盖后 en 的 confirm/cancel 变为 OK/Dismiss，未覆盖的键继续走内置表。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text(this.validateText)
        .fontSize(13)
        .fontColor('#fa3534')
        .width('100%')

      this.sectionTitle('星期简称')
      Row() {
        ForEach(upWeekText(), (week: string) => {
          Text(week)
            .fontSize(12)
            .fontColor('#606266')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (week: string, index: number): string => week + '-' + String(index))
      }
      .width('100%')
      Text('上游 weekText 默认值由 up.week.one 到 up.week.seven 组成，本端用 upWeekText() 复刻。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
