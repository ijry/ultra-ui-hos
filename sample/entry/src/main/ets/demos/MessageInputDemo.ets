import {
  UPMessageInput,
  UPMessageInputChangeEvent,
  UPMessageInputProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct MessageInputDemo {
  @State private code: string = '';
  @State private status: string = '点击格子调起数字键盘，输满 4 位触发 finish';
  @State private sixCode: string = '';
  @State private sixStatus: string = '六位密码使用圆点填充';

  private trackCode(event: UPMessageInputChangeEvent): void {
    this.code = event.value;
    this.status = '当前输入：' + (event.value.length > 0 ? event.value : '空');
  }

  private finishCode(event: UPMessageInputChangeEvent): void {
    this.status = '已输满 4 位：' + event.value;
  }

  private trackSix(event: UPMessageInputChangeEvent): void {
    this.sixCode = event.value;
    this.sixStatus = '已输入 ' + String(event.value.length) + ' / 6 位';
  }

  private finishSix(event: UPMessageInputChangeEvent): void {
    this.sixStatus = '六位密码已输满，长度 ' + String(event.value.length);
  }

  build() {
    Column({ space: 16 }) {
      Text('默认盒子模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPMessageInput({
        props: new UPMessageInputProps({
          maxlength: 4,
          modelValue: this.code,
          onChange: (event: UPMessageInputChangeEvent): void => {
            this.trackCode(event);
          },
          onFinish: (event: UPMessageInputChangeEvent): void => {
            this.finishCode(event);
          }
        })
      })
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')

      Text('六位圆点密码')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPMessageInput({
        props: new UPMessageInputProps({
          maxlength: 6,
          dotFill: true,
          width: '60',
          fontSize: 40,
          activeColor: 'success',
          onChange: (event: UPMessageInputChangeEvent): void => {
            this.trackSix(event);
          },
          onFinish: (event: UPMessageInputChangeEvent): void => {
            this.finishSix(event);
          }
        })
      })
      Text(this.sixStatus).fontSize(13).fontColor('#606266').width('100%')

      Text('下划线模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPMessageInput({
        props: new UPMessageInputProps({
          mode: 'bottomLine',
          maxlength: 4,
          bold: true,
          breathe: false,
          fontSize: 40
        })
      })

      Text('中划线模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPMessageInput({
        props: new UPMessageInputProps({
          mode: 'middleLine',
          maxlength: 4,
          fontSize: 40,
          inactiveColor: '#c0c4cc',
          activeColor: 'warning'
        })
      })

      Text('禁用系统键盘（只展示，不可输入）')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPMessageInput({
        props: new UPMessageInputProps({
          maxlength: 4,
          modelValue: '2024',
          disabledKeyboard: true,
          breathe: false,
          fontSize: 40
        })
      })
      Text('禁用后隐藏输入框不再聚焦，可配合车牌键盘等自定义键盘使用')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
