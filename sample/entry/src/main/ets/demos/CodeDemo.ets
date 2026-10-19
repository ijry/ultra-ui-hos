import {
  UPCode,
  UPCodeChangeEvent,
  UPCodeEndEvent,
  UPCodeProps,
  UPCodeStorage
} from '@lingyun/ultra-ui-hos';

class DemoCodeStorage implements UPCodeStorage {
  private timestamp: number | undefined = undefined;

  get(key: string): number | undefined {
    return this.timestamp;
  }

  set(key: string, timestamp: number): void {
    this.timestamp = timestamp;
  }

  remove(key: string): void {
    this.timestamp = undefined;
  }
}

@Component
export struct CodeDemo {
  @State private message: string = '点击验证码开始倒计时';
  private storage: DemoCodeStorage = new DemoCodeStorage();

  build() {
    Column({ space: 16 }) {
      Text('验证码倒计时')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row() {
        UPCode({
          props: new UPCodeProps({
            seconds: 8,
            startText: '获取验证码',
            changeText: 'x秒后重新获取',
            endText: '重新获取',
            keepRunning: true,
            uniqueKey: 'phase-12-demo-code',
            storage: this.storage,
            onStart: (): void => {
              this.message = '倒计时已开始';
            },
            onChange: (event: UPCodeChangeEvent): void => {
              this.message = event.text;
            },
            onEnd: (event: UPCodeEndEvent): void => {
              this.message = '倒计时结束：' + event.text;
            }
          })
        })
      }
      .padding({ left: 18, right: 18, top: 10, bottom: 10 })
      .backgroundColor('#ecf5ff')
      .borderRadius(6)
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      Text('keepRunning 仅通过可选 UPCodeStorage 保存结束时间；示例使用内存存储，不接入网络。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
