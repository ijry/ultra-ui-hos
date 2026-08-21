import { UPSwitch, UPSwitchChangeEvent, UPSwitchProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SwitchDemo {
  @State private switchEnabled: boolean = true;
  @State private message: string = '开关使用 activeValue/inactiveValue 回传';

  private change(event: UPSwitchChangeEvent): void {
    this.switchEnabled = event.checked;
    this.message = 'value=' + String(event.value) + '，checked=' + String(event.checked);
  }

  build() {
    Column({ space: 18 }) {
      Text('开关状态')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 16 }) {
        UPSwitch({ props: new UPSwitchProps({ modelValue: this.switchEnabled, onChange: (event: UPSwitchChangeEvent): void => { this.change(event); } }) })
        UPSwitch({ props: new UPSwitchProps({ value: true, activeColor: 'success', size: 30 }) })
        UPSwitch({ props: new UPSwitchProps({ value: false, disabled: true }) })
        UPSwitch({ props: new UPSwitchProps({ value: true, loading: true }) })
      }
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
