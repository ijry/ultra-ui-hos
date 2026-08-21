import { UPBadge, UPBadgeProps } from '@lingyun/ultra-ui-hos';

@Component
export struct BadgeDemo {
  build() {
    Column({ space: 20 }) {
      Text('数字徽标')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 16 }) {
        UPBadge({ props: new UPBadgeProps({ value: 8 }) })
        UPBadge({ props: new UPBadgeProps({ value: 108, max: 99 }) })
        UPBadge({ props: new UPBadgeProps({ value: 'NEW', type: 'primary', shape: 'horn' }) })
      }
      Text('圆点与反色')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Row({ space: 16 }) {
        UPBadge({ props: new UPBadgeProps({ isDot: true, type: 'success' }) })
        UPBadge({ props: new UPBadgeProps({ value: 6, inverted: true, type: 'warning' }) })
        UPBadge({ props: new UPBadgeProps({ value: 0, showZero: true, type: 'info' }) })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
