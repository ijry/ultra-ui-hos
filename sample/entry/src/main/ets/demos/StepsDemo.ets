import { UPSteps, UPStepsItem, UPStepsItemProps, UPStepsProps } from '@lingyun/ultra-ui-hos';

@Component
export struct StepsDemo {
  @State private current: number = 1;
  @State private message: string = '点击步骤提出索引事件';
  build() {
    Column({ space: 18 }) {
      UPSteps({ props: new UPStepsProps({ current: this.current, contentBuilder: (): void => {} }) }) {
        UPStepsItem({ props: new UPStepsItemProps({ title: '提交', desc: '资料已提交', onClick: (index: number): void => { this.current = index; this.message = '点击横向步骤：' + String(index); } }) })
        UPStepsItem({ props: new UPStepsItemProps({ title: '审核', desc: '审核中', onClick: (index: number): void => { this.current = index; this.message = '点击横向步骤：' + String(index); } }) })
        UPStepsItem({ props: new UPStepsItemProps({ title: '完成', error: true, onClick: (index: number): void => { this.current = index; this.message = '点击错误步骤：' + String(index); } }) })
      }
      UPSteps({ props: new UPStepsProps({ direction: 'column', current: 0, dot: true, activeColor: '#67c23a' }) }) {
        UPStepsItem({ props: new UPStepsItemProps({ title: '纵向步骤', desc: '点状连接线' }) })
        UPStepsItem({ props: new UPStepsItemProps({ title: '下一步', desc: '等待处理' }) })
      }
      Text(this.message).fontSize(13).fontColor('#606266')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
