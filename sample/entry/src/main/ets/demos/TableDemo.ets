import {
  UPTable,
  UPTableProps,
  UPTableRow,
  UPTd,
  UPTdProps,
  UPTh,
  UPThProps,
  UPTr,
  UPTrProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct TableDemo {
  private headers: Array<string> = ['姓名', '部门', '工号'];
  private widths: Array<string> = ['90px', '', '80px'];
  private rows: Array<UPTableRow> = [
    { cells: ['林语堂', '研发中心', 'A-1024'] },
    { cells: ['赵晚舟', '设计中心', 'B-2048'] },
    { cells: ['周清和', '质量保障', 'C-4096'] }
  ];

  build() {
    Column({ space: 18 }) {
      Text('插槽写法')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps() }) {
        UPTr({ props: new UPTrProps() }) {
          UPTh({ props: new UPThProps({ text: '月份', width: '90px' }) })
          UPTh({ props: new UPThProps({ text: '收入' }) })
          UPTh({ props: new UPThProps({ text: '同比' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '一月', width: '90px' }) })
          UPTd({ props: new UPTdProps({ text: '12,800' }) })
          UPTd({ props: new UPTdProps({ text: '+8.2%', color: '#19be6b' }) })
        }
        UPTr({ props: new UPTrProps({ bgColor: '#fafafa' }) }) {
          UPTd({ props: new UPTdProps({ text: '二月', width: '90px' }) })
          UPTd({ props: new UPTdProps({ text: '11,260' }) })
          UPTd({ props: new UPTdProps({ text: '-3.5%', color: '#fa3534' }) })
        }
      }
      Text('UPTable 提供边框色、对齐、内边距与字号的统一上下文，UPTr/UPTh/UPTd 继承后可局部覆盖。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('数据驱动写法')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({
        headers: this.headers,
        rows: this.rows,
        widths: this.widths,
        align: 'left',
        padding: '8px 6px',
        color: '#303133'
      }) })
      Text('传入 headers/rows/widths 后无需手写单元格，align=left、padding=8px 6px 作用于整表。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('自定义边框与表头')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({
        borderColor: '#a0cfff',
        bgColor: '#f7fbff',
        fontSize: '13px',
        thStyle: { backgroundColor: '#ecf5ff', color: '#2979ff' }
      }) }) {
        UPTr({ props: new UPTrProps() }) {
          UPTh({ props: new UPThProps({ text: '字段' }) })
          UPTh({ props: new UPThProps({ text: '说明' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: 'borderColor' }) })
          UPTd({ props: new UPTdProps({ text: '整表边框色', textAlign: 'left' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: 'thStyle' }) })
          UPTd({ props: new UPTdProps({ text: '表头单元格样式', textAlign: 'left' }) })
        }
      }
      Text('thStyle 统一下发到所有 UPTh，单个 UPTh 的 customStyle 优先级更高。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
