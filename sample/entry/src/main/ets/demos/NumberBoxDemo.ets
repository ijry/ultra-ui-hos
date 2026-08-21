import { UPNumberBox, UPNumberBoxChangeEvent, UPNumberBoxProps } from '@lingyun/ultra-ui-hos';

@Component
export struct NumberBoxDemo {
  @State private value: number = 2;
  @State private message: string = '加减按钮会回传数值和类型';

  private change(event: UPNumberBoxChangeEvent): void {
    this.value = event.value;
    this.message = event.type + '：' + String(event.value);
  }

  build() {
    Column({ space: 18 }) {
      Text('步进器')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPNumberBox({ props: new UPNumberBoxProps({ modelValue: this.value, min: 1, max: 5, onChange: (event: UPNumberBoxChangeEvent): void => { this.change(event); } }) })
      UPNumberBox({ props: new UPNumberBoxProps({ value: 1.5, step: 0.5, min: 0, max: 3, decimalLength: 1, inputWidth: 48 }) })
      UPNumberBox({ props: new UPNumberBoxProps({ value: 3, disabled: true }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
