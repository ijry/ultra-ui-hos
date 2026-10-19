import { UPCell, UPCellClickEvent, UPCellGroup, UPCellGroupProps, UPCellProps, UPIcon, UPIconProps, UPTag, UPTagProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CellDemo {
  @State private message: string = '点击可点击单元格查看 name 回传';

  private select(event: UPCellClickEvent, prefix: string = 'name='): void {
    this.message = prefix + String(event.name);
  }

  @Builder
  private slotIcon() {
    UPIcon({ props: new UPIconProps({ name: 'star-fill', size: 18, color: '#ff9900' }) })
  }

  @Builder
  private slotTitle() {
    Row({ space: 6 }) {
      Text('自定义标题').fontSize(15).fontColor('#303133')
      UPTag({ props: new UPTagProps({ text: 'Builder', type: 'primary', size: 'mini' }) })
    }
  }

  @Builder
  private slotLabel() {
    Text('label 插槽同样接受 Builder').fontSize(12).fontColor('#909399')
  }

  @Builder
  private slotValue() {
    Text('¥ 128.00').fontSize(15).fontColor('#fa3534').fontWeight(FontWeight.Medium)
  }

  @Builder
  private slotRightIcon() {
    UPIcon({ props: new UPIconProps({ name: 'arrow-right', size: 16, color: '#2979ff' }) })
  }

  @Builder
  private slotRightIconExtra() {
    Text('额外一列').fontSize(11).fontColor('#c0c4cc')
  }

  build() {
    Column({ space: 12 }) {
      Text('基础单元格')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCellGroup({ props: new UPCellGroupProps({ title: '账号信息', inset: true }) }) {
        UPCell({ props: new UPCellProps({
          title: '头像',
          value: '默认头像',
          icon: 'home',
          arrow: true,
          clickable: true,
          name: 1001,
          onClick: (event: UPCellClickEvent): void => {
            this.select(event);
          }
        }) })
        UPCell({ props: new UPCellProps({
          title: '昵称',
          label: '展示给其他用户',
          value: 'UltraUI',
          required: true,
          arrow: true,
          clickable: true,
          name: 'nickname',
          onClick: (event: UPCellClickEvent): void => {
            this.select(event);
          }
        }) })
        UPCell({ props: new UPCellProps({
          title: '路由兼容字段',
          value: '仅诊断，不自动导航',
          url: '/pages/demo',
          linkType: 'navigateTo',
          arrow: true,
          clickable: true,
          name: 'no-op',
          onClick: (event: UPCellClickEvent): void => {
            this.select(event, '由调用方处理：');
          }
        }) })
      }
      Text('具名插槽（上游 icon / title / label / value / right-icon / righticon）')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCellGroup({ props: new UPCellGroupProps({ inset: true }) }) {
        UPCell({ props: new UPCellProps({
          title: '被插槽替换的标题',
          label: '被插槽替换的描述',
          value: '被插槽替换的值',
          clickable: true,
          name: 'slot-cell',
          iconBuilder: this.slotIcon,
          titleBuilder: this.slotTitle,
          labelBuilder: this.slotLabel,
          valueBuilder: this.slotValue,
          rightIconBuilder: this.slotRightIcon,
          righticonBuilder: this.slotRightIconExtra,
          onClick: (event: UPCellClickEvent): void => {
            this.select(event);
          }
        }) })
      }
      Text('上游 right-icon 替换箭头位，righticon 是额外一列，本端保留两个独立入口。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
