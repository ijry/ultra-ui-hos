import { UPCascader, UPCascaderChangeEvent, UPCascaderOption, UPCascaderProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CascaderDemo {
  @State private selected: string = '未选择';
  private options: Array<UPCascaderOption> = [
    { value: 'zj', label: '浙江', children: [{ value: 'hz', label: '杭州' }, { value: 'nb', label: '宁波' }] },
    { value: 'js', label: '江苏', children: [{ value: 'nj', label: '南京' }] }
  ];
  private change(event: UPCascaderChangeEvent): void { this.selected = event.labels.join(' / '); }

  build() {
    Column({ space: 12 }) {
      Text('级联选择').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPCascader({ props: new UPCascaderProps({ options: this.options, onChange: (event: UPCascaderChangeEvent): void => { this.change(event); },
        onConfirm: (event: UPCascaderChangeEvent): void => { this.change(event); } }) })
      Text('当前路径：' + this.selected).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
