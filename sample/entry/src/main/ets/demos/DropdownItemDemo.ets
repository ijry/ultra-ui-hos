import { UPDropdownItem, UPDropdownItemProps, UPDropdownOption } from '@lingyun/ultra-ui-hos';

@Component
export struct DropdownItemDemo {
  @State private value: Array<string> = ['red'];
  @State private message: string = '多选模式保持菜单打开';
  private options: Array<UPDropdownOption> = [
    { label: '红色', value: 'red' }, { label: '绿色', value: 'green' }, { label: '蓝色', value: 'blue', disabled: true },
  ];
  build() {
    Column({ space: 12 }) {
      Text('下拉项').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPDropdownItem({ props: new UPDropdownItemProps({ title: '多选颜色', modelValue: this.value, options: this.options, multiple: true, onValueChange: (value): void => { this.value = Array.isArray(value) ? value.map((item): string => String(item)) : []; this.message = '已选择：' + this.value.join('、'); } }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
