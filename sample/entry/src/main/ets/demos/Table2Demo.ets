import {
  UPTable2,
  UPTable2CellSlot,
  UPTable2Column,
  UPTable2ExpandEvent,
  UPTable2Props,
  UPTable2Row,
  UPTable2HeaderSlot,
  UPTable2HeaderSortSlot,
  UPTable2RowEvent,
  UPTable2SelectionEvent,
  UPTable2SortEvent,
  upTable2Value
} from '@lingyun/ultra-ui-hos';

@Component
export struct Table2Demo {
  @State private message: string = '点击表头排序、勾选行或展开子节点';
  private columns: Array<UPTable2Column> = [
    { key: 'name', title: '名称', align: 'left' },
    { key: 'stock', title: '库存', width: '70px', sortable: true },
    { key: 'price', title: '单价', width: '80px', sortable: true }
  ];
  private rows: Array<UPTable2Row> = [
    { cells: [{ key: 'id', value: 1 }, { key: 'name', value: '甘露青提' }, { key: 'stock', value: 128 }, { key: 'price', value: 29.9 }] },
    { cells: [{ key: 'id', value: 2 }, { key: 'name', value: '烟熏红茶' }, { key: 'stock', value: 46 }, { key: 'price', value: 18.5 }] },
    { cells: [{ key: 'id', value: 3 }, { key: 'name', value: '海盐芝士' }, { key: 'stock', value: 302 }, { key: 'price', value: 22 }] }
  ];
  private selectionColumns: Array<UPTable2Column> = [
    { type: 'selection', width: '36px' },
    { key: 'name', title: '成员', align: 'left' },
    { key: 'role', title: '角色', width: '90px' }
  ];
  private selectionRows: Array<UPTable2Row> = [
    { cells: [{ key: 'id', value: 'u1' }, { key: 'name', value: '林语堂' }, { key: 'role', value: '管理员' }], selected: true },
    { cells: [{ key: 'id', value: 'u2' }, { key: 'name', value: '赵晚舟' }, { key: 'role', value: '编辑' }] },
    { cells: [{ key: 'id', value: 'u3' }, { key: 'name', value: '周清和' }, { key: 'role', value: '只读' }], disabled: true }
  ];
  private treeColumns: Array<UPTable2Column> = [
    { key: 'dept', title: '组织', align: 'left' },
    { key: 'count', title: '人数', width: '70px' }
  ];
  private treeRows: Array<UPTable2Row> = [
    {
      cells: [{ key: 'id', value: 'd1' }, { key: 'dept', value: '研发中心' }, { key: 'count', value: 42 }],
      children: [
        { cells: [{ key: 'id', value: 'd1-1' }, { key: 'dept', value: '客户端组' }, { key: 'count', value: 18 }] },
        {
          cells: [{ key: 'id', value: 'd1-2' }, { key: 'dept', value: '服务端组' }, { key: 'count', value: 24 }],
          children: [
            { cells: [{ key: 'id', value: 'd1-2-1' }, { key: 'dept', value: '网关小组' }, { key: 'count', value: 9 }] }
          ]
        }
      ]
    },
    { cells: [{ key: 'id', value: 'd2' }, { key: 'dept', value: '设计中心' }, { key: 'count', value: 11 }] }
  ];
  private emptyRows: Array<UPTable2Row> = [];

  @Builder
  private slotHeader(slot: UPTable2HeaderSlot) {
    Text(String(slot.column.title))
      .fontSize(13)
      .fontColor('#2979ff')
      .fontWeight(FontWeight.Bold)
      .layoutWeight(1)
  }

  @Builder
  private slotHeaderSort(slot: UPTable2HeaderSortSlot) {
    Text(slot.sortStatus === 'ascending' ? '升' : (slot.sortStatus === 'descending' ? '降' : '排'))
      .fontSize(11)
      .fontColor('#ffffff')
      .padding({ left: 4, right: 4 })
      .backgroundColor(slot.sortStatus.length > 0 ? '#2979ff' : '#c0c4cc')
      .borderRadius(3)
  }

  @Builder
  private slotCell(slot: UPTable2CellSlot) {
    Text(String(upTable2Value(slot.flat.row, String(this.columns[slot.columnIndex].key))))
      .fontSize(13)
      .fontColor(slot.columnIndex === 0 ? '#303133' : '#fa3534')
      .layoutWeight(1)
  }

  @Builder
  private slotEmpty() {
    Column({ space: 6 }) {
      Text('插槽空态').fontSize(14).fontColor('#909399')
      Text('emptyBuilder 替换 emptyText').fontSize(12).fontColor('#c0c4cc')
    }
    .width('100%')
    .padding(20)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column({ space: 18 }) {
      Text('斑马纹与排序')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable2({ props: new UPTable2Props({
        data: this.rows,
        columns: this.columns,
        stripe: true,
        border: true,
        highlightCurrentRow: true,
        onSortChange: (event: UPTable2SortEvent): void => {
          const order: string = event.order.length === 0 ? '取消排序' : event.order;
          this.message = '排序：' + String(event.column.title) + ' ' + order;
        },
        onRowClick: (event: UPTable2RowEvent): void => {
          this.message = '点击第 ' + String(event.rowIndex + 1) + ' 行';
        }
      }) })
      Text('列上 sortable=true 后点击表头在 ascending / descending / 取消之间循环，排序在组件内完成。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('勾选列')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable2({ props: new UPTable2Props({
        data: this.selectionRows,
        columns: this.selectionColumns,
        border: true,
        onSelectionChange: (event: UPTable2SelectionEvent): void => {
          this.message = '已选 ' + String(event.selection.length) + ' 项';
        }
      }) })
      Text('type=selection 的列渲染勾选框，行上 selected 决定初始状态，disabled 行不可勾选。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('树形展开')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable2({ props: new UPTable2Props({
        data: this.treeRows,
        columns: this.treeColumns,
        border: true,
        mainCol: 'dept',
        defaultExpandAll: true,
        maxHeight: '220px',
        onExpandChange: (event: UPTable2ExpandEvent): void => {
          this.message = (event.expanded ? '展开' : '收起') + '，当前展开 ' + String(event.expandedKeys.length) + ' 个节点';
        }
      }) })
      Text('children 字段构成层级，mainCol 指定缩进列；设置 maxHeight 后表体在原生 Scroll 内滚动。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('空数据')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable2({ props: new UPTable2Props({
        data: this.emptyRows,
        columns: this.columns,
        border: true,
        emptyText: '暂无库存记录'
      }) })
      Text('data 为空时展示 emptyText，表头依然保留以维持列宽。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('作用域插槽（上游 header / headerSort / cell / empty）')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable2({
        props: new UPTable2Props({
          data: this.rows,
          columns: this.columns,
          border: true,
          onSortChange: (event: UPTable2SortEvent): void => {
            this.message = '插槽表排序：' + String(event.column.key) + ' ' + event.order;
          }
        }),
        headerBuilder: this.slotHeader,
        headerSortBuilder: this.slotHeaderSort,
        cellBuilder: this.slotCell
      })
      UPTable2({
        props: new UPTable2Props({
          data: this.emptyRows,
          columns: this.columns,
          border: true,
          emptyBuilder: this.slotEmpty
        })
      })
      Text('headerSort 只在列可排序时渲染，sortStatus 回传 ascending / descending / 空串。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      Text('spanMethod、cellClassName、rowClassName、headerCellClassName、lazy 与 load 保留为 no-op 兼容字段，仅通过 diagnostics 记录。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
