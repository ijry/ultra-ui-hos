import { UPTreeSelect, UPTreeSelectChangeEvent, UPTreeSelectNode, UPTreeSelectProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TreeSelectDemo {
  @State private selected: string = '未选择';
  private nodes: Array<UPTreeSelectNode> = [
    { value: 'food', label: '食品', children: [{ value: 'fruit', label: '水果' }, { value: 'snack', label: '零食', disabled: true }] },
    { value: 'book', label: '图书' }
  ];

  build() {
    Column({ space: 12 }) {
      Text('树形选择').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPTreeSelect({ props: new UPTreeSelectProps({ options: this.nodes, multiple: true, max: 2,
        onChange: (event: UPTreeSelectChangeEvent): void => { this.selected = event.values.join(', '); } }) })
      Text('已选择：' + this.selected).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
