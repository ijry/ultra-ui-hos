import {
  UPTable,
  UPTableProps,
  UPTd,
  UPTdProps,
  UPTh,
  UPThProps,
  UPTr,
  UPTrProps
} from '@lingyun/ultra-ui-hos';

@Component
export struct TrDemo {
  build() {
    Column({ space: 18 }) {
      Text('行背景与斑马纹')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({ align: 'left', padding: '8px 6px' }) }) {
        UPTr({ props: new UPTrProps() }) {
          UPTh({ props: new UPThProps({ text: '序号', width: '70px' }) })
          UPTh({ props: new UPThProps({ text: '行说明' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '01', width: '70px' }) })
          UPTd({ props: new UPTdProps({ text: '默认行，背景透明' }) })
        }
        UPTr({ props: new UPTrProps({ bgColor: '#fafafa' }) }) {
          UPTd({ props: new UPTdProps({ text: '02', width: '70px' }) })
          UPTd({ props: new UPTdProps({ text: 'bgColor=#fafafa' }) })
        }
        UPTr({ props: new UPTrProps({ bgColor: '#ecf5ff' }) }) {
          UPTd({ props: new UPTdProps({ text: '03', width: '70px' }) })
          UPTd({ props: new UPTdProps({ text: 'bgColor=#ecf5ff' }) })
        }
      }
      Text('UPTr 只负责行方向布局与背景，交替底色由调用方按需指定。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('子单元格等高拉伸')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({ align: 'left' }) }) {
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ width: '90px', text: '短内容' }) })
          UPTd({ props: new UPTdProps({ text: '较长的一段说明文字，会把整行撑高，同行其他单元格自动等高，无需手动设置高度。' }) })
        }
      }
      Text('行容器使用 Flex 的 Stretch 对齐，任一单元格换行都会带动同行等高。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('自定义行样式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({ align: 'center' }) }) {
        UPTr({ props: new UPTrProps({ customStyle: { backgroundColor: '#f0f9eb' } }) }) {
          UPTd({ props: new UPTdProps({ text: '合计' }) })
          UPTd({ props: new UPTdProps({ text: '24,060', color: '#19be6b' }) })
        }
      }
      Text('customStyle 的 backgroundColor 优先于 bgColor，可用于合计行等特殊行。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
