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
export struct ThDemo {
  build() {
    Column({ space: 18 }) {
      Text('固定宽度与自适应')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps() }) {
        UPTr({ props: new UPTrProps() }) {
          UPTh({ props: new UPThProps({ text: '固定 80', width: '80px' }) })
          UPTh({ props: new UPThProps({ text: '自适应剩余宽度' }) })
          UPTh({ props: new UPThProps({ text: '固定 60', width: '60px' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '80px', width: '80px' }) })
          UPTd({ props: new UPTdProps({ text: 'auto' }) })
          UPTd({ props: new UPTdProps({ text: '60px', width: '60px' }) })
        }
      }
      Text('width 留空的表头按 layoutWeight 平分剩余宽度，填写后使用原生固定宽度。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('表头对齐')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({ align: 'right' }) }) {
        UPTr({ props: new UPTrProps() }) {
          UPTh({ props: new UPThProps({ text: '继承右对齐' }) })
          UPTh({ props: new UPThProps({ text: '局部居左', customStyle: { textAlign: 'left' } }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '1,280' }) })
          UPTd({ props: new UPTdProps({ text: '2,360', textAlign: 'left' }) })
        }
      }
      Text('表头默认继承 UPTable 的 align，customStyle 的 textAlign 可单独覆盖。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('自定义表头内容')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({ thStyle: { backgroundColor: '#ecf5ff', color: '#2979ff', fontSize: 13 } }) }) {
        UPTr({ props: new UPTrProps() }) {
          UPTh({ props: new UPThProps({ width: '110px' }) }) {
            Row({ space: 4 }) {
              Text('销量').fontSize(13).fontColor('#2979ff').fontWeight(FontWeight.Bold)
              Text('↓').fontSize(11).fontColor('#2979ff')
            }
          }
          UPTh({ props: new UPThProps({ text: '门店' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '860', width: '110px' }) })
          UPTd({ props: new UPTdProps({ text: '城东旗舰店' }) })
        }
      }
      Text('不传 text 时使用子组件插槽，可放入图标、排序标记等自定义节点。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
