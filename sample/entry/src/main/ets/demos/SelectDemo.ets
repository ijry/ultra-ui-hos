import {
  UPSelect,
  UPSelectOption,
  UPSelectOptionSlot,
  UPSelectProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct SelectDemo {
  @State private current: string = 'all';
  @State private message: string = '全部';
  private options: Array<UPSelectOption> = [
    { id: 'all', name: '全部' },
    { id: 'todo', name: '待处理' },
    { id: 'done', name: '已完成' },
    { id: 'disabled', name: '已禁用', disabled: true }
  ];

  @Builder
  private slotOptionItem(slot: UPSelectOptionSlot) {
    Row({ space: 8 }) {
      Text(String(slot.index + 1))
        .fontSize(11)
        .fontColor('#ffffff')
        .width(20)
        .height(20)
        .textAlign(TextAlign.Center)
        .backgroundColor('#2979ff')
        .borderRadius(10)
      Text(String(slot.item.name)).fontSize(14).fontColor('#303133').layoutWeight(1)
      if (String(slot.item.id) === this.current) {
        Text('当前').fontSize(11).fontColor('#19be6b')
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
    .opacity(slot.item.disabled === true ? 0.4 : 1)
  }

  build() {
    Column({ space: 16 }) {
      Text('下拉选择').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSelect({
        props: new UPSelectProps({
          options: this.options,
          current: this.current,
          label: '状态',
          showOptionsLabel: true,
          border: true,
          onCurrentChange: (value): void => {
            this.current = String(value);
            const selected: UPSelectOption | undefined = this.options.find((item: UPSelectOption): boolean => String(item.id) === this.current);
            this.message = selected?.name === undefined ? '' : String(selected.name);
          }
        })
      })
      Text('当前选择：' + this.message).fontSize(13).fontColor('#909399').width('100%')
      Text('optionItem 作用域插槽').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSelect({
        props: new UPSelectProps({
          options: this.options,
          current: this.current,
          label: '带序号的选项',
          border: true
        }),
        optionItemBuilder: this.slotOptionItem
      })
      Text('上游 optionItem 插槽把条目与下标传给调用方，本端折叠为 UPSelectOptionSlot 单参数。')
        .fontSize(12).fontColor('#c0c4cc').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
