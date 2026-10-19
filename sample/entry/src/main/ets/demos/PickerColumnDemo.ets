import {
  UPCompatibilityDiagnostics,
  UPCompatibilityEvent,
  UPPickerColumn,
  UPPickerColumnProps,
  UP_PICKER_COLUMN_ITEM_HEIGHT,
  upPickerColumnAlignSupported
} from '@lingyun/ultra-ui-hos';

@Component
export struct PickerColumnDemo {
  @State private status: string = '上游 u-picker-column 是空壳插槽容器，本端保持同样职责';
  @State private boundary: string = '';
  @State private picked: string = '';
  private diagnostics: UPCompatibilityDiagnostics = new UPCompatibilityDiagnostics();
  private options: Array<string> = ['杭州', '宁波', '温州'];
  private probeAligns: Array<string> = ['center', 'start', 'end', 'baseline'];

  aboutToAppear(): void {
    this.diagnostics = new UPCompatibilityDiagnostics((event: UPCompatibilityEvent): void => {
      this.boundary = event.component + '.' + event.property + '：' + event.reason;
    });
  }

  private pick(value: string): void {
    this.picked = value;
    this.status = '插槽内的行由示例自行处理点击：' + value;
  }

  private probeText(align: string): string {
    return 'align=' + align + (upPickerColumnAlignSupported(align)
      ? '：映射到 FlexAlign 主轴对齐'
      : '：不在支持范围内，回落 center 并报诊断');
  }

  @Builder
  private singleRow() {
    Text('固定单行插槽内容')
      .fontSize(14)
      .fontColor('#303133')
  }

  @Builder
  private optionRows() {
    Column() {
      ForEach(this.options, (value: string): void => {
        Text(value)
          .fontSize(14)
          .fontColor(this.picked === value ? '#2979ff' : '#606266')
          .width('100%')
          .height(UP_PICKER_COLUMN_ITEM_HEIGHT)
          .textAlign(TextAlign.Center)
          .onClick((): void => {
            this.pick(value);
          })
      }, (value: string): string => value)
    }
    .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      Text('列容器基础用法')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPPickerColumn({
        props: new UPPickerColumnProps({
          customStyle: { backgroundColor: '#ffffff' },
          diagnostics: this.diagnostics
        }),
        contentBuilder: this.singleRow
      })
      Text('多行插槽与对齐')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPPickerColumn({
        props: new UPPickerColumnProps({
          align: 'start',
          customStyle: { height: 132, backgroundColor: '#ffffff' },
          diagnostics: this.diagnostics
        }),
        contentBuilder: this.optionRows
      })
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.boundary.length > 0 ? '最近诊断：' + this.boundary : '暂无诊断输出')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('对齐取值')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      ForEach(this.probeAligns, (align: string): void => {
        Text(this.probeText(align)).fontSize(12).fontColor('#909399').width('100%')
      }, (align: string): string => align)
      Text('默认高度取 itemHeight，缺省 ' + String(UP_PICKER_COLUMN_ITEM_HEIGHT) + 'vp，与上游单行选项高度一致。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('上游没有 props 与事件，滚动联动仍由父级 Picker 负责，本组件只承载插槽与尺寸。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
