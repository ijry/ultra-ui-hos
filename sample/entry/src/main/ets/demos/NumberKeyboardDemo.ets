import {
  UPNumberKeyboard,
  UPNumberKeyboardChangeEvent,
  UPNumberKeyboardProps,
  UPSubsection,
  UPSubsectionItem,
  UPSubsectionProps,
  UPSwitch,
  UPSwitchChangeEvent,
  UPSwitchProps,
  UP_NUMBER_KEYBOARD_BACKSPACE_INTERVAL,
  upNumberKeyboardKeys,
  upNumberKeyboardModeSupported,
  upNumberKeyboardWideKey
} from '@lingyun/ultra-ui-hos';

@Component
export struct NumberKeyboardDemo {
  @State private input: string = '';
  @State private status: string = '点击按键回填，长按删除键可连续删除';
  @State private modeIndex: number = 0;
  @State private dotDisabled: boolean = false;
  @State private random: boolean = false;
  private modes: Array<UPSubsectionItem> = [{ name: '数字' }, { name: '身份证' }];
  private modeNames: Array<string> = ['number', 'card'];
  private probeModes: Array<string> = ['number', 'card', 'idcard'];

  private append(event: UPNumberKeyboardChangeEvent): void {
    if (this.input.length >= 18) {
      this.status = '演示上限 18 位，已达上限';
      return;
    }
    this.input = this.input + event.text;
    this.status = 'change：text=' + event.text + '，value 类型为 '
      + (typeof event.value === 'number' ? 'number' : 'string');
  }

  private backspace(): void {
    if (this.input.length === 0) {
      this.status = '已经没有可删除的字符';
      return;
    }
    this.input = this.input.slice(0, this.input.length - 1);
    this.status = '删除一位，当前 ' + String(this.input.length) + ' 位';
  }

  private reset(): void {
    this.input = '';
    this.status = '已清空输入';
  }

  private selectMode(index: number): void {
    this.modeIndex = index;
    this.input = '';
    this.status = 'mode=' + this.modeNames[index] + (index === 1 ? '：第 10 键为 X' : '：第 10 键为小数点或 0');
  }

  private toggleDot(event: UPSwitchChangeEvent): void {
    this.dotDisabled = event.checked;
    this.status = event.checked ? 'dotDisabled=true：隐藏小数点，0 键占两格' : 'dotDisabled=false：显示小数点，change 回传数字';
  }

  private toggleRandom(event: UPSwitchChangeEvent): void {
    this.random = event.checked;
    this.status = event.checked ? '按键已乱序排列' : '按键恢复默认顺序';
  }

  private layoutText(): string {
    const keys: Array<string> = upNumberKeyboardKeys(this.modeNames[this.modeIndex], this.dotDisabled, false);
    return '当前布局：' + keys.join(' ') + '（共 ' + String(keys.length) + ' 键 + 退格键）';
  }

  private wideText(): string {
    const wide: boolean = upNumberKeyboardWideKey(this.modeNames[this.modeIndex], this.dotDisabled, 9);
    return wide ? 'index 9 的 0 键占 464rpx 双格宽度' : 'index 9 的按键保持 222rpx 标准宽度';
  }

  private probeText(mode: string): string {
    return 'mode=' + mode + (upNumberKeyboardModeSupported(mode)
      ? '：上游 numList 有对应分支'
      : '：上游 numList 返回 undefined 渲染空键盘，本端回落数字布局并报诊断');
  }

  build() {
    Column({ space: 16 }) {
      Text('数字键盘回填')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.input.length === 0 ? '等待输入' : this.input)
        .fontSize(18)
        .fontColor(this.input.length === 0 ? '#c0c4cc' : '#303133')
        .width('100%')
        .height(44)
        .padding({ left: 12, right: 12 })
        .borderRadius(4)
        .border({ width: 1, color: '#dcdfe6' })
        .backgroundColor('#ffffff')
      UPSubsection({
        props: new UPSubsectionProps({
          list: this.modes,
          current: this.modeIndex,
          onChange: (index: number): void => {
            this.selectMode(index);
          }
        })
      })
      Row({ space: 10 }) {
        Text('隐藏小数点').fontSize(13).fontColor('#606266')
        UPSwitch({
          props: new UPSwitchProps({
            modelValue: this.dotDisabled,
            size: 22,
            onChange: (event: UPSwitchChangeEvent): void => {
              this.toggleDot(event);
            }
          })
        })
        Text('乱序按键').fontSize(13).fontColor('#606266')
        UPSwitch({
          props: new UPSwitchProps({
            modelValue: this.random,
            size: 22,
            onChange: (event: UPSwitchChangeEvent): void => {
              this.toggleRandom(event);
            }
          })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      UPNumberKeyboard({
        props: new UPNumberKeyboardProps({
          mode: this.modeNames[this.modeIndex],
          dotDisabled: this.dotDisabled,
          random: this.random,
          onChange: (event: UPNumberKeyboardChangeEvent): void => {
            this.append(event);
          },
          onBackspace: (): void => {
            this.backspace();
          }
        })
      })
      Row({ space: 10 }) {
        Button('清空输入')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.reset();
          })
        Text('长按删除键每 ' + String(UP_NUMBER_KEYBOARD_BACKSPACE_INTERVAL) + 'ms 连续删除')
          .fontSize(12)
          .fontColor('#909399')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Text(this.status).fontSize(13).fontColor('#606266').width('100%')

      Text('布局与 mode 兜底')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.layoutText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.wideText()).fontSize(12).fontColor('#909399').width('100%')
      ForEach(this.probeModes, (mode: string): void => {
        Text(this.probeText(mode)).fontSize(12).fontColor('#909399').width('100%')
      }, (mode: string): string => mode)
      Text('change 事件复刻上游取值：允许小数点时除 . 与 X 外一律 Number() 转数字，否则保持字符串。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text('hover-class 与 hover-stay-time 在 ArkUI 无等价能力，改由 onTouch 按下态切换背景色。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
