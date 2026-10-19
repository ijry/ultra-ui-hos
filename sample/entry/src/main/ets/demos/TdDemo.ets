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
export struct TdDemo {
  build() {
    Column({ space: 18 }) {
      Text('宽度与对齐')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({ align: 'center' }) }) {
        UPTr({ props: new UPTrProps() }) {
          UPTh({ props: new UPThProps({ text: '项目', width: '90px' }) })
          UPTh({ props: new UPThProps({ text: '数值' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '默认 auto', width: '90px' }) })
          UPTd({ props: new UPTdProps({ text: '居中继承' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '局部左对齐', width: '90px' }) })
          UPTd({ props: new UPTdProps({ text: 'textAlign=left', textAlign: 'left' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '局部右对齐', width: '90px' }) })
          UPTd({ props: new UPTdProps({ text: 'textAlign=right', textAlign: 'right' }) })
        }
      }
      Text('width 默认 auto 时按 layoutWeight 平分，textAlign 为空则继承整表 align。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('字号、颜色与边框')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({ fontSize: '13px', color: '#606266', borderColor: '#e4e7ed' }) }) {
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '继承 13px' }) })
          UPTd({ props: new UPTdProps({ text: '局部 16px', fontSize: '16px' }) })
        }
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '成功', color: '#19be6b' }) })
          UPTd({ props: new UPTdProps({ text: '失败', color: '#fa3534', borderColor: '#fab6b6' }) })
        }
      }
      Text('fontSize/color/borderColor 留空时继承整表上下文，填写后仅影响当前单元格。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')

      Text('自定义单元格内容')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPTable({ props: new UPTableProps({ align: 'left', padding: '8px 6px' }) }) {
        UPTr({ props: new UPTrProps() }) {
          UPTd({ props: new UPTdProps({ text: '状态', width: '90px' }) })
          UPTd({ props: new UPTdProps() }) {
            Row({ space: 6 }) {
              Text('已上线')
                .fontSize(12)
                .fontColor('#ffffff')
                .backgroundColor('#19be6b')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(9)
              Text('灰度 30%').fontSize(12).fontColor('#909399')
            }
          }
        }
      }
      Text('不传 text 时使用子组件插槽，可渲染标签、按钮等任意原生节点。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
