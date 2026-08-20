import { UPButton, UPButtonProps, UPDropdown, UPDropdownItem, UPDropdownItemProps, UPDropdownOption, UPDropdownProps } from '@lingyun/ultra-ui-hos';

@Component
export struct DropdownDemo {
  @State private openIndex: number = -1;
  @State private selected: string = '全部';
  private options: Array<UPDropdownOption> = [
    { label: '全部', value: 'all' }, { label: '已完成', value: 'done' }, { label: '已禁用', value: 'disabled', disabled: true },
  ];
  build() {
    Column({ space: 12 }) {
      Text('下拉菜单').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPButton({ props: new UPButtonProps({ text: this.openIndex < 0 ? '打开下拉菜单' : '关闭下拉菜单', type: 'primary', onClick: (): void => { this.openIndex = this.openIndex < 0 ? 0 : -1; } }) })
      UPDropdown({ props: new UPDropdownProps({ openIndex: this.openIndex, onOpenChange: (index: number): void => { this.openIndex = index; } }) }) {
        UPDropdownItem({ props: new UPDropdownItemProps({ title: '状态：' + this.selected, options: this.options, value: this.selected === '已完成' ? 'done' : 'all', onValueChange: (value): void => { this.selected = String(value) === 'done' ? '已完成' : '全部'; } }) })
      }
      Text('当前选择：' + this.selected).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
