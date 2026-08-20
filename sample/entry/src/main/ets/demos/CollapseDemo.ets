import { UPCollapse, UPCollapseItem, UPCollapseItemProps, UPCollapseProps, UPCollapseChangeEvent, UPCollapseValue } from '@lingyun/ultra-ui-hos';
@Component
export struct CollapseDemo {
  @State private value: UPCollapseValue = ['first'];
  @State private message: string = '支持多个面板同时展开';
  private change(event: UPCollapseChangeEvent): void { this.value = event.value; this.message = (event.open ? '展开：' : '收起：') + String(event.name); }
  build() {
    Column({ space: 12 }) {
      Text('折叠面板').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPCollapse({ props: new UPCollapseProps({ modelValue: this.value, onValueChange: (value: UPCollapseValue): void => { this.value = value; }, onChange: (event: UPCollapseChangeEvent): void => { this.change(event); } }) }) {
        UPCollapseItem({ props: new UPCollapseItemProps({ title: '第一个面板', name: 'first', label: '多开模式' }) }) { Text('第一个面板内容').fontSize(14).fontColor('#606266') }
        UPCollapseItem({ props: new UPCollapseItemProps({ title: '第二个面板', name: 'second', label: '点击标题切换' }) }) { Text('第二个面板内容').fontSize(14).fontColor('#606266') }
      }
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
