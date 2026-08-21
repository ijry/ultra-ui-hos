import { UPAvatarGroup, UPAvatarGroupProps } from '@lingyun/ultra-ui-hos';

@Component
export struct AvatarGroupDemo {
  build() {
    Column({ space: 18 }) {
      Text('头像组')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPAvatarGroup({ props: new UPAvatarGroupProps({
        urls: [
          { text: '云', name: '云' },
          { text: 'UI', name: 'UI' },
          { text: '鸿', name: '鸿蒙' },
          { text: 'A', name: 'ArkTS' },
          { text: 'N', name: 'NEXT' }
        ],
        maxCount: 4,
        size: 42,
        gap: 6,
        showMore: true
      }) })
      UPAvatarGroup({ props: new UPAvatarGroupProps({
        urls: [{ text: '设' }, { text: '计' }, { text: '端' }],
        shape: 'square',
        size: 36,
        gap: 8,
        showMore: false
      }) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
