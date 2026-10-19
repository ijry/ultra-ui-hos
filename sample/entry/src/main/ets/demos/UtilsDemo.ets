import {
  UPFormat,
  UPGradient,
  UPLegacyColor,
  UPMath,
  UPQueryEntry,
  UPTimeParts,
  UPZIndex,
  upIsCarNo,
  upIsCalendarDate,
  upIsDate,
  upIsEmail,
  upIsIdCard,
  upIsMobile,
  upIsUrl
} from '@lingyun/ultra-ui-hos';

/** 校验示例的一行结果。/ One validator row rendered by the demo. */
interface UtilsCheckRow {
  label: string;
  sample: string;
  passed: boolean;
}

@Component
export struct UtilsDemo {
  @State private amountLeft: string = '0.1';
  @State private amountRight: string = '0.2';
  @State private validatorInput: string = '13800138000';
  @State private gradientSteps: number = 6;
  private readonly sampleTimestamp: number = 1700000000000;

  private numberOf(value: string, fallback: number): number {
    const amount: number = Number(value.trim());
    return Number.isFinite(amount) ? amount : fallback;
  }

  private left(): number {
    return this.numberOf(this.amountLeft, 0);
  }

  private right(): number {
    return this.numberOf(this.amountRight, 0);
  }

  /** 与原生浮点运算对照，突出高精度差异。/ Contrasts native float math with UPMath. */
  private nativeSum(): string {
    return String(this.left() + this.right());
  }

  private checks(): Array<UtilsCheckRow> {
    const value: string = this.validatorInput;
    return [
      { label: '手机号 upIsMobile', sample: value, passed: upIsMobile(value) },
      { label: '邮箱 upIsEmail', sample: value, passed: upIsEmail(value) },
      { label: '网址 upIsUrl', sample: value, passed: upIsUrl(value) },
      { label: '身份证 upIsIdCard', sample: value, passed: upIsIdCard(value) },
      { label: '车牌 upIsCarNo', sample: value, passed: upIsCarNo(value) },
      { label: '日期 upIsDate', sample: value, passed: upIsDate(value) },
      { label: '严格日历 upIsCalendarDate', sample: value, passed: upIsCalendarDate(value) }
    ];
  }

  private gradientColors(): Array<string> {
    return UPGradient.gradient('#2979ff', '#19be6b', Math.max(2, Math.floor(this.gradientSteps)));
  }

  private queryText(): string {
    const entries: Array<UPQueryEntry> = [
      { key: 'page', value: 1 },
      { key: 'keyword', value: '鸿蒙' },
      { key: 'tags', values: ['ui', 'arkts'] }
    ];
    return UPFormat.queryParams(entries, true, 'brackets');
  }

  private timeParts(): string {
    const parts: UPTimeParts = UPFormat.partsOf(this.sampleTimestamp);
    return String(parts.year) + '/' + UPFormat.padZero(parts.month) + '/' + UPFormat.padZero(parts.day)
      + ' ' + UPFormat.padZero(parts.hour) + ':' + UPFormat.padZero(parts.minute);
  }

  @Builder
  private sectionTitle(text: string) {
    Text(text)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#303133')
      .width('100%')
  }

  @Builder
  private resultRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(13).fontColor('#606266').layoutWeight(1)
      Text(value).fontSize(13).fontColor('#303133').fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
  }

  build() {
    Column({ space: 18 }) {
      this.sectionTitle('高精度运算 UPMath')
      Row({ space: 8 }) {
        TextInput({ text: this.amountLeft, placeholder: '左操作数' })
          .type(InputType.NUMBER_DECIMAL)
          .fontSize(14)
          .height(36)
          .layoutWeight(1)
          .backgroundColor('#f5f7fa')
          .onChange((value: string): void => {
            this.amountLeft = value;
          })
        TextInput({ text: this.amountRight, placeholder: '右操作数' })
          .type(InputType.NUMBER_DECIMAL)
          .fontSize(14)
          .height(36)
          .layoutWeight(1)
          .backgroundColor('#f5f7fa')
          .onChange((value: string): void => {
            this.amountRight = value;
          })
      }
      .width('100%')
      this.resultRow('原生加法', this.nativeSum())
      this.resultRow('UPMath.plus', String(UPMath.plus(this.left(), this.right())))
      this.resultRow('UPMath.minus', String(UPMath.minus(this.left(), this.right())))
      this.resultRow('UPMath.times', String(UPMath.times(this.left(), this.right())))
      this.resultRow('UPMath.divide', this.right() === 0 ? '除数为 0' : String(UPMath.divide(this.left(), this.right())))
      this.resultRow('UPMath.round(2 位)', String(UPMath.round(this.left(), 2)))
      Text('先把操作数放大成整数再运算，避免二进制浮点误差；与上游 digit.js 逐值对齐。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      this.sectionTitle('格式化 UPFormat')
      this.resultRow('timeFormat', UPFormat.timeFormat(this.sampleTimestamp, 'yyyy-mm-dd hh:MM:ss'))
      this.resultRow('timeFormat(yy)', UPFormat.timeFormat(this.sampleTimestamp, 'yy年mm月dd日'))
      this.resultRow('partsOf', this.timeParts())
      this.resultRow('priceFormat', UPFormat.priceFormat(1234567.891, 2))
      this.resultRow('durationText', UPFormat.durationText(300) + ' / ' + UPFormat.durationText('2s'))
      this.resultRow('durationValue', String(UPFormat.durationValue('2s')) + ' ms')
      this.resultRow('trim(all)', '[' + UPFormat.trim('  a b  ', 'all') + ']')
      this.resultRow('typeIcon', UPFormat.typeIcon('warning', true))
      this.resultRow('queryParams', this.queryText())
      Text('时间相关函数保持纯函数：需要「当前时间」时由调用方传入时间戳，日历换算按 UTC 进行。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      this.sectionTitle('校验器 UPValidate')
      TextInput({ text: this.validatorInput, placeholder: '输入待校验内容' })
        .fontSize(14)
        .height(36)
        .width('100%')
        .backgroundColor('#f5f7fa')
        .onChange((value: string): void => {
          this.validatorInput = value;
        })
      ForEach(this.checks(), (row: UtilsCheckRow) => {
        Row() {
          Text(row.label).fontSize(13).fontColor('#606266').layoutWeight(1)
          Text(row.passed ? '通过' : '不通过')
            .fontSize(12)
            .fontColor('#ffffff')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(row.passed ? '#19be6b' : '#c0c4cc')
            .borderRadius(3)
        }
        .width('100%')
        .padding({ top: 3, bottom: 3 })
      }, (row: UtilsCheckRow): string => row.label)
      Text('upIsDate 沿用上游宽松口径（2024-02-30 会通过），upIsCalendarDate 才做严格日历判定。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      this.sectionTitle('颜色 UPGradient')
      Row({ space: 4 }) {
        ForEach(this.gradientColors(), (color: string) => {
          Column()
            .layoutWeight(1)
            .height(28)
            .backgroundColor(color)
            .borderRadius(3)
        }, (color: string, index: number): string => color + '-' + String(index))
      }
      .width('100%')
      Slider({ value: this.gradientSteps, min: 2, max: 12, step: 1 })
        .width('100%')
        .onChange((value: number): void => {
          this.gradientSteps = Math.round(value);
        })
      this.resultRow('渐变段数', String(Math.max(2, Math.floor(this.gradientSteps))))
      this.resultRow('toHex', UPGradient.toHex('rgb(41,121,255)'))
      this.resultRow('toRgbText', UPGradient.toRgbText('#19be6b'))
      this.resultRow('toRgba', UPGradient.toRgba('#fa3534', 0.5))
      Row({ space: 8 }) {
        Text('lightColor').fontSize(13).fontColor('#606266').layoutWeight(1)
        Text(UPGradient.lightColor('#2979ff', 95))
          .fontSize(13)
          .fontColor('#2979ff')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(UPGradient.lightColor('#2979ff', 95))
          .borderRadius(3)
      }
      .width('100%')

      this.sectionTitle('层级与兼容调色板')
      this.resultRow('UPZIndex.TOAST', String(UPZIndex.TOAST))
      this.resultRow('UPZIndex.POPUP', String(UPZIndex.POPUP))
      this.resultRow('UPZIndex.of(sticky)', String(UPZIndex.of('sticky')))
      Row({ space: 6 }) {
        Text('兼容主色').fontSize(13).fontColor('#606266').layoutWeight(1)
        Text(UPLegacyColor.PRIMARY)
          .fontSize(12)
          .fontColor('#ffffff')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(UPLegacyColor.PRIMARY)
          .borderRadius(3)
      }
      .width('100%')
      Text('上游 config.js 主色为 #2979ff，libs/config/color.js 的兼容主色是 #3c9cff，两者按原样保留。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
