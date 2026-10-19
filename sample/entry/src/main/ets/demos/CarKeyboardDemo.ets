import {
  UPCarKeyboard,
  UPCarKeyboardChangeEvent,
  UPCarKeyboardProps,
  UPCarKeyboardRow,
  UPSwitch,
  UPSwitchChangeEvent,
  UPSwitchProps,
  upCarKeyboardRows
} from '@lingyun/ultra-ui-hos';

@Component
export struct CarKeyboardDemo {
  @State private plate: string = '';
  @State private status: string = '先选省份简称，再输入号码';
  @State private randomOrder: boolean = false;
  @State private autoChange: boolean = true;
  private cellIndexes: Array<number> = [0, 1, 2, 3, 4, 5, 6, 7];

  private append(value: string): void {
    if (this.plate.length >= this.cellIndexes.length) {
      this.status = '车牌号最长 8 位，已达上限';
      return;
    }
    this.plate = this.plate + value;
    this.status = '输入按键：' + value;
  }

  private backspace(): void {
    if (this.plate.length === 0) {
      this.status = '已经没有可删除的字符';
      return;
    }
    this.plate = this.plate.slice(0, this.plate.length - 1);
    this.status = '删除一位，当前 ' + String(this.plate.length) + ' 位';
  }

  private reset(): void {
    this.plate = '';
    this.status = '已清空，重新选择省份简称';
  }

  private toggleRandom(event: UPSwitchChangeEvent): void {
    this.randomOrder = event.checked;
    this.status = event.checked ? '按键已乱序排列' : '按键恢复默认顺序';
  }

  private toggleAuto(event: UPSwitchChangeEvent): void {
    this.autoChange = event.checked;
    this.status = event.checked ? '选完省份后自动切到号码键盘' : '需要手动点击中/英切换';
  }

  private rowSummary(): string {
    const rows: Array<UPCarKeyboardRow> = upCarKeyboardRows([
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
      'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
      'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Z',
      'X', 'C', 'V', 'B', 'N', 'M'
    ]);
    const counts: Array<string> = rows.map((row: UPCarKeyboardRow): string => String(row.keys.length));
    return '按键分行：' + counts.join(' / ');
  }

  @Builder
  private plateCells() {
    Row({ space: 6 }) {
      ForEach(this.cellIndexes, (index: number) => {
        Text(index < this.plate.length ? this.plate.charAt(index) : '')
          .fontSize(16)
          .fontColor('#303133')
          .textAlign(TextAlign.Center)
          .width(32)
          .height(40)
          .borderRadius(4)
          .border({ width: 1, color: index === this.plate.length ? '#2979ff' : '#dcdfe6' })
          .backgroundColor('#ffffff')
      }, (index: number): string => String(index))
    }
    .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      Text('车牌号输入回填')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      this.plateCells()
      Row({ space: 10 }) {
        Text('乱序按键').fontSize(13).fontColor('#606266')
        UPSwitch({
          props: new UPSwitchProps({
            modelValue: this.randomOrder,
            size: 22,
            onChange: (event: UPSwitchChangeEvent): void => {
              this.toggleRandom(event);
            }
          })
        })
        Text('自动切换').fontSize(13).fontColor('#606266')
        UPSwitch({
          props: new UPSwitchProps({
            modelValue: this.autoChange,
            size: 22,
            onChange: (event: UPSwitchChangeEvent): void => {
              this.toggleAuto(event);
            }
          })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      UPCarKeyboard({
        props: new UPCarKeyboardProps({
          random: this.randomOrder,
          autoChange: this.autoChange,
          onChange: (event: UPCarKeyboardChangeEvent): void => {
            this.append(event.value);
          },
          onBackspace: (): void => {
            this.backspace();
          }
        })
      })

      Row({ space: 10 }) {
        Button('清空车牌')
          .fontSize(14)
          .height(36)
          .backgroundColor('#f4f4f5')
          .fontColor('#606266')
          .onClick((): void => {
            this.reset();
          })
        Text('长按删除键可连续删除').fontSize(12).fontColor('#909399')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(this.status).fontSize(13).fontColor('#606266').width('100%')
      Text(this.rowSummary()).fontSize(12).fontColor('#909399').width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
