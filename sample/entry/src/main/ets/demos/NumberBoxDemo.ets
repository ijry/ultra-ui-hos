import { UPNumberBox, UPNumberBoxChangeEvent, UPNumberBoxProps } from '@lingyun/ultra-ui-hos';

@Component
export struct NumberBoxDemo {
  @State private value: number = 2;
  @State private message: string = '加减按钮会回传数值和类型';

  private change(event: UPNumberBoxChangeEvent): void {
    this.value = event.value;
    this.message = event.type + '：' + String(event.value);
  }

  @Builder
  private slotMinus() {
    Text('减').fontSize(13).fontColor('#ffffff').width(30).height(30).textAlign(TextAlign.Center)
      .backgroundColor('#909399').borderRadius(15)
  }

  @Builder
  private slotPlus() {
    Text('加').fontSize(13).fontColor('#ffffff').width(30).height(30).textAlign(TextAlign.Center)
      .backgroundColor('#2979ff').borderRadius(15)
  }

  @Builder
  private slotInput() {
    Text(String(this.value)).fontSize(15).fontColor('#303133').fontWeight(FontWeight.Bold)
      .width(44).height(30).textAlign(TextAlign.Center).backgroundColor('#f2f3f5')
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
      Text('具名插槽（上游 minus / input / plus）')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPNumberBox({ props: new UPNumberBoxProps({
        modelValue: this.value,
        min: 1,
        max: 5,
        minusBuilder: this.slotMinus,
        plusBuilder: this.slotPlus,
        inputBuilder: this.slotInput,
        onChange: (event: UPNumberBoxChangeEvent): void => { this.change(event); }
      }) })
      Text('插槽只替换外观，加减判定与越界事件仍由组件负责。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
