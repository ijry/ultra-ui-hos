import { UPIndexAnchor, UPIndexAnchorProps } from '@lingyun/ultra-ui-hos';

@Component
export struct IndexAnchorDemo {
  build() {
    Column({ space: 14 }) {
      UPIndexAnchor({ props: new UPIndexAnchorProps({ text: 'A' }) })
      UPIndexAnchor({ props: new UPIndexAnchorProps({ text: '自定义', color: '#ffffff', size: 16, bgColor: '#5677fc', height: 42, customStyle: { padding: 16, borderRadius: 8 } }) })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
