import { UPSubsection, UPSubsectionItem, UPSubsectionProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SubsectionDemo {
  @State private current: number = 0;
  @State private message: string = 'button 模式';
  private list: Array<UPSubsectionItem> = [{ name: '日榜', activeColor: '#2979ff' }, { name: '周榜', activeColor: '#67c23a' }, { name: '月榜', disabled: true }];
  build() {
    Column({ space: 14 }) {
      UPSubsection({ props: new UPSubsectionProps({ list: this.list, current: this.current, onCurrentChange: (index: number): void => { this.current = index; }, onChange: (index: number): void => { this.message = 'button 选择：' + String(index); } }) })
      UPSubsection({ props: new UPSubsectionProps({ list: this.list, current: this.current, mode: 'subsection', bold: false, onChange: (index: number): void => { this.message = 'subsection 选择：' + String(index); } }) })
      Text(this.message).fontSize(13).fontColor('#606266')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
