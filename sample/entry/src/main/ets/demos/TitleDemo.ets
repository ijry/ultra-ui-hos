import { UPTitle, UPTitleProps } from '@lingyun/ultra-ui-hos';

@Component
export struct TitleDemo {
  build() {
    Column({ space: 18 }) {
      UPTitle({ props: new UPTitleProps({ title: '基础标题', subTitle: '默认主要色前缀' }) })
      UPTitle({ props: new UPTitleProps({ title: '成功状态', subTitle: 'type 控制前缀颜色', type: 'success' }) })
      UPTitle({ props: new UPTitleProps({ title: '居中标题', subTitle: '隐藏前缀并居中', prefix: false, align: 'center', color: 'primary' }) })
      UPTitle({ props: new UPTitleProps({ title: '自定义尺寸', subTitle: '更大字号与警告色前缀', type: 'warning', size: 20 }) })
    }
    .width('100%')
  }
}
