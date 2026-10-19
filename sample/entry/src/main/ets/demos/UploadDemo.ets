import { UPUpload, UPUploadChooseEvent, UPUploadDeleteEvent, UPUploadProps } from '@lingyun/ultra-ui-hos';

@Component
export struct UploadDemo {
  @State private message: string = '仅演示本地文件占位';
  build() {
    Column({ space: 12 }) {
      Text('上传占位').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#303133').width('100%')
      UPUpload({ props: new UPUploadProps({ maxCount: 3,
        onChoose: (event: UPUploadChooseEvent): void => { this.message = '已添加：' + event.file.name; },
        onDelete: (event: UPUploadDeleteEvent): void => { this.message = '已删除：' + event.file.name; } }) })
      Text(this.message).fontSize(13).fontColor('#909399').width('100%')
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
