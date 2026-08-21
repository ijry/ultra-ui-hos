import { UPSkeleton, UPSkeletonProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SkeletonDemo {
  build() {
    Column({ space: 18 }) {
      Text('基础骨架')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPSkeleton({ props: new UPSkeletonProps({ rows: 3, title: true }) })
      Text('头像骨架')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPSkeleton({ props: new UPSkeletonProps({ avatar: true, rows: 4, titleWidth: '55%', rowWidth: ['100%', '92%', '80%', '64%'] }) })
    }
    .width('100%')
  }
}
