import { UPTag, UPTagProps, UPTitle, UPTitleProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TitleDemo {
  @Builder
  private slotPrefix() {
    Column()
      .width(3)
      .height(20)
      .backgroundColor('#19be6b')
      .borderRadius(2)
  }

  @Builder
  private slotContent() {
    Row({ space: 6 }) {
      UPTag({ props: new UPTagProps({ text: '插槽', type: 'success', size: 'mini' }) })
      Text('default 插槽追加在标题之后').fontSize(12).fontColor('#909399')
    }
  }

  build() {
    Column({ space: 18 }) {
      UPTitle({ props: new UPTitleProps({ title: '基础标题', subTitle: '默认主要色前缀' }) })
      UPTitle({ props: new UPTitleProps({ title: '成功状态', subTitle: 'type 控制前缀颜色', type: 'success' }) })
      UPTitle({ props: new UPTitleProps({ title: '居中标题', subTitle: '隐藏前缀并居中', prefix: false, align: 'center', color: 'primary' }) })
      UPTitle({ props: new UPTitleProps({ title: '自定义尺寸', subTitle: '更大字号与警告色前缀', type: 'warning', size: 20 }) })
      UPTitle({ props: new UPTitleProps({
        title: '插槽标题',
        subTitle: 'prefix 与 default 均由 Builder 提供',
        prefixBuilder: this.slotPrefix,
        contentBuilder: this.slotContent
      }) })
    }
    .width('100%')
  }
}
