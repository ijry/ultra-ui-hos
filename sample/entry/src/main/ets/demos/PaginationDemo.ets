import { UPPagination, UPPaginationChangeEvent, UPPaginationProps } from '@lingyun/ultra-ui-hos';

@Component
export struct PaginationDemo {
  @State private page: number = 2;
  build() {
    Column({ space: 12 }) {
      Text('分页器').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPPagination({ props: new UPPaginationProps({ currentPage: this.page, pageSize: 10, total: 55,
        onPageChange: (event: UPPaginationChangeEvent): void => { this.page = event.currentPage; } }) })
      Text('当前页：' + this.page).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
