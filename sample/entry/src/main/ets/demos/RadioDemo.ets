import { UPRadio, UPRadioChangeEvent, UPRadioProps } from '@lingyun/ultra-ui-hos';

@Component
export struct RadioDemo {
  @State private selected: string = 'A';
  @State private message: string = '选择一个选项';
  private change(event: UPRadioChangeEvent): void { this.selected = String(event.name); this.message = '当前：' + this.selected; }
  build() {
    Column({ space: 16 }) {
      Text('独立单选项').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPRadio({ props: new UPRadioProps({ name: 'A', label: '选项 A', checked: this.selected === 'A', onChange: (event: UPRadioChangeEvent): void => { this.change(event); } }) })
      UPRadio({ props: new UPRadioProps({ name: 'B', label: '选项 B', checked: this.selected === 'B', onChange: (event: UPRadioChangeEvent): void => { this.change(event); } }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
