import { UPCell, UPCellClickEvent, UPCellGroup, UPCellGroupProps, UPCellProps } from '@lingyun/ultra-ui-hos';

@Component
export struct CellDemo {
  @State private message: string = '点击可点击单元格查看 name 回传';

  private select(event: UPCellClickEvent, prefix: string = 'name='): void {
    this.message = prefix + String(event.name);
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
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
