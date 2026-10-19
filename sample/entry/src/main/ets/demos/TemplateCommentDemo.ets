import { UPAvatar, UPAvatarProps, UPIcon, UPIconProps } from '@lingyun/ultra-ui-hos';

/** 一条回复。/ One nested reply. */
interface CommentReply {
  name: string;
  text: string;
}

/** 一条评论。/ One comment row. */
interface CommentRow {
  id: number;
  name: string;
  date: string;
  content: string;
  likeNum: number;
  liked: boolean;
  allReply: number;
  replies: Array<CommentReply>;
}

/**
 * 复刻上游 `pages/template/comment/index.vue` 的评论列表场景。
 * ArkTS port of the upstream comment template: avatar, like toggle, nested replies.
 * 「查看全部回复」原为路由跳转，这里改为本地文案，不引入业务路由。
 */
@Component
export struct TemplateCommentDemo {
  @State private comments: Array<CommentRow> = [
    {
      id: 1, name: '叶轻眉', date: '12-25 18:58',
      content: '这套组件库的暗色模式做得挺细，令牌切换很顺。',
      likeNum: 33, liked: false, allReply: 12,
      replies: [
        { name: '范闲', text: '同感，表格斑马纹在暗色下也没糊。' },
        { name: '王启年', text: '插槽 Builder 用起来比想象中顺手。' }
      ]
    },
    {
      id: 2, name: '林婉儿', date: '12-25 20:12',
      content: '表单校验的错误文案能跟随语言切换，省了不少事。',
      likeNum: 8, liked: true, allReply: 3,
      replies: [
        { name: '五竹', text: '规则字段和上游对齐，迁移几乎零成本。' }
      ]
    }
  ];

  private toggleLike(index: number): void {
    const row: CommentRow = this.comments[index];
    const next: CommentRow = {
      id: row.id, name: row.name, date: row.date, content: row.content,
      liked: !row.liked, likeNum: row.liked ? row.likeNum - 1 : row.likeNum + 1,
      allReply: row.allReply, replies: row.replies
    };
    this.comments[index] = next;
  }

  @Builder
  private commentCard(row: CommentRow, index: number) {
    Row({ space: 10 }) {
      UPAvatar({ props: new UPAvatarProps({ text: row.name.substring(0, 1), size: 40 }) })
      Column({ space: 6 }) {
        Row() {
          Text(row.name).fontSize(14).fontColor('#303133').fontWeight(FontWeight.Medium)
          Blank()
          Row({ space: 4 }) {
            Text(String(row.likeNum)).fontSize(12).fontColor(row.liked ? '#2979ff' : '#9a9a9a')
            UPIcon({ props: new UPIconProps({
              name: row.liked ? 'thumb-up-fill' : 'thumb-up',
              size: 18,
              color: row.liked ? '#2979ff' : '#9a9a9a',
              onClick: (): void => { this.toggleLike(index); }
            }) })
          }
        }
        .width('100%')
        Text(row.content).fontSize(14).fontColor('#606266').width('100%')
        Column({ space: 4 }) {
          ForEach(row.replies, (reply: CommentReply) => {
            Row({ space: 4 }) {
              Text(reply.name + '：').fontSize(12).fontColor('#2979ff')
              Text(reply.text).fontSize(12).fontColor('#606266').layoutWeight(1)
            }
            .width('100%')
          }, (reply: CommentReply): string => reply.name)
          Row({ space: 2 }) {
            Text('共 ' + String(row.allReply) + ' 条回复').fontSize(12).fontColor('#909399')
            UPIcon({ props: new UPIconProps({ name: 'arrow-right', size: 13, color: '#909399' }) })
          }
        }
        .width('100%')
        .padding(8)
        .backgroundColor('#f3f4f6')
        .borderRadius(6)
        .alignItems(HorizontalAlign.Start)
        Row() {
          Text(row.date).fontSize(11).fontColor('#909399')
          Blank()
          Text('回复').fontSize(12).fontColor('#909399')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .alignItems(VerticalAlign.Top)
    .border({ width: { bottom: 1 }, color: '#ebeef5' })
  }

  build() {
    Column() {
      ForEach(this.comments, (row: CommentRow, index: number) => {
        this.commentCard(row, index)
      }, (row: CommentRow): string => String(row.id))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
