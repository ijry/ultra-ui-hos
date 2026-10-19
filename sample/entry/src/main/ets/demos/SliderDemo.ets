import { UPSlider, UPSliderChangeEvent, UPSliderProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SliderDemo {
  @State private value: number = 36;
  @State private message: string = '拖动滑块查看变更事件';

  private change(event: UPSliderChangeEvent): void {
    this.value = event.value;
    this.message = event.mode + '：' + String(event.value);
  }

  build() {
    Column({ space: 18 }) {
      Text('滑块').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPSlider({
        props: new UPSliderProps({
          modelValue: this.value,
          min: 0,
          max: 100,
          step: 5,
          showValue: true,
          length: '100%',
          onChange: (event: UPSliderChangeEvent): void => { this.change(event); }
        })
      })
      UPSlider({ props: new UPSliderProps({ value: 2, min: 0, max: 5, step: 0.5, activeColor: '#19be6b' }) })
      UPSlider({ props: new UPSliderProps({ value: 70, disabled: true, showValue: true }) })
      Text('当前值：' + String(this.value) + '，' + this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
