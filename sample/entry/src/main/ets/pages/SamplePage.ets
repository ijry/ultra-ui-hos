import { AvatarDemo } from '../demos/AvatarDemo';
import { AvatarGroupDemo } from '../demos/AvatarGroupDemo';
import { BadgeDemo } from '../demos/BadgeDemo';
import { ButtonDemo } from '../demos/ButtonDemo';
import { CellDemo } from '../demos/CellDemo';
import { DividerDemo } from '../demos/DividerDemo';
import { GapDemo } from '../demos/GapDemo';
import { IconDemo } from '../demos/IconDemo';
import { LineDemo } from '../demos/LineDemo';
import { LineProgressDemo } from '../demos/LineProgressDemo';
import { LinkDemo } from '../demos/LinkDemo';
import { LoadingIconDemo } from '../demos/LoadingIconDemo';
import { LoadmoreDemo } from '../demos/LoadmoreDemo';
import { ModalDemo } from '../demos/ModalDemo';
import { OverlayDemo } from '../demos/OverlayDemo';
import { PopupDemo } from '../demos/PopupDemo';
import { SkeletonDemo } from '../demos/SkeletonDemo';
import { TagDemo } from '../demos/TagDemo';
import { TitleDemo } from '../demos/TitleDemo';
import { ToastDemo } from '../demos/ToastDemo';
import { CodeInputDemo } from '../demos/CodeInputDemo';
import { EmptyDemo } from '../demos/EmptyDemo';
import { ImageDemo } from '../demos/ImageDemo';
import { LoadingPageDemo } from '../demos/LoadingPageDemo';
import { SearchDemo } from '../demos/SearchDemo';
import { TextDemo } from '../demos/TextDemo';
import { InputDemo } from '../demos/InputDemo';
import { TextareaDemo } from '../demos/TextareaDemo';
import { SwitchDemo } from '../demos/SwitchDemo';
import { RateDemo } from '../demos/RateDemo';
import { NumberBoxDemo } from '../demos/NumberBoxDemo';
import { CheckboxDemo } from '../demos/CheckboxDemo';
import { CheckboxGroupDemo } from '../demos/CheckboxGroupDemo';
import { RadioDemo } from '../demos/RadioDemo';
import { RadioGroupDemo } from '../demos/RadioGroupDemo';
import { FormDemo } from '../demos/FormDemo';
import { FormItemDemo } from '../demos/FormItemDemo';
import { RowDemo } from '../demos/RowDemo';
import { ColDemo } from '../demos/ColDemo';
import { GridDemo } from '../demos/GridDemo';
import { GridItemDemo } from '../demos/GridItemDemo';
import { CardDemo } from '../demos/CardDemo';
import { CircleProgressDemo } from '../demos/CircleProgressDemo';
import { AlertDemo } from '../demos/AlertDemo';
import { NotifyDemo } from '../demos/NotifyDemo';
import { NoticeBarDemo } from '../demos/NoticeBarDemo';

import { SampleScaffold, SampleScaffoldProps } from '../shared/SampleScaffold';

export interface SamplePageOptions {
  route?: string;
  onBack?: () => void;
}

/** Props container keeps route callbacks compatible with ArkTS V1 decorators. */
export class SamplePageProps {
  route: string = 'button';
  onBack?: () => void;

  constructor(options?: SamplePageOptions) {
    if (options === undefined) {
      return;
    }
    this.route = options.route ?? this.route;
    this.onBack = options.onBack;
  }
}

@Component
export struct SamplePage {
  @Prop props: SamplePageProps = new SamplePageProps();

  @Builder
  private demo() {
    if (this.props.route === 'circle-progress') {
      CircleProgressDemo()
    } else if (this.props.route === 'alert') {
      AlertDemo()
    } else if (this.props.route === 'notify') {
      NotifyDemo()
    } else if (this.props.route === 'notice-bar') {
      NoticeBarDemo()
    } else if (this.props.route === 'button') {
      ButtonDemo()
    } else if (this.props.route === 'cell') {
      CellDemo()
    } else if (this.props.route === 'icon') {
      IconDemo()
    } else if (this.props.route === 'loading-icon') {
      LoadingIconDemo()
    } else if (this.props.route === 'overlay') {
      OverlayDemo()
    } else if (this.props.route === 'popup') {
      PopupDemo()
    } else if (this.props.route === 'line') {
      LineDemo()
    } else if (this.props.route === 'gap') {
      GapDemo()
    } else if (this.props.route === 'link') {
      LinkDemo()
    } else if (this.props.route === 'title') {
      TitleDemo()
    } else if (this.props.route === 'badge') {
      BadgeDemo()
    } else if (this.props.route === 'divider') {
      DividerDemo()
    } else if (this.props.route === 'skeleton') {
      SkeletonDemo()
    } else if (this.props.route === 'line-progress') {
      LineProgressDemo()
    } else if (this.props.route === 'loadmore') {
      LoadmoreDemo()
    } else if (this.props.route === 'avatar') {
      AvatarDemo()
    } else if (this.props.route === 'avatar-group') {
      AvatarGroupDemo()
    } else if (this.props.route === 'input') {
      InputDemo()
    } else if (this.props.route === 'textarea') {
      TextareaDemo()
    } else if (this.props.route === 'switch') {
      SwitchDemo()
    } else if (this.props.route === 'rate') {
      RateDemo()
    } else if (this.props.route === 'number-box') {
      NumberBoxDemo()
    } else if (this.props.route === 'checkbox') {
      CheckboxDemo()
    } else if (this.props.route === 'checkbox-group') {
      CheckboxGroupDemo()
    } else if (this.props.route === 'radio') {
      RadioDemo()
    } else if (this.props.route === 'radio-group') {
      RadioGroupDemo()
    } else if (this.props.route === 'form') {
      FormDemo()
    } else if (this.props.route === 'form-item') {
      FormItemDemo()
    } else if (this.props.route === 'tag') {
      TagDemo()
    } else if (this.props.route === 'toast') {
      ToastDemo()
    } else if (this.props.route === 'text') {
      TextDemo()
    } else if (this.props.route === 'image') {
      ImageDemo()
    } else if (this.props.route === 'empty') {
      EmptyDemo()
    } else if (this.props.route === 'loading-page') {
      LoadingPageDemo()
    } else if (this.props.route === 'search') {
      SearchDemo()
    } else if (this.props.route === 'code-input') {
      CodeInputDemo()
    } else if (this.props.route === 'row') {
      RowDemo()
    } else if (this.props.route === 'col') {
      ColDemo()
    } else if (this.props.route === 'grid') {
      GridDemo()
    } else if (this.props.route === 'grid-item') {
      GridItemDemo()
    } else if (this.props.route === 'card') {
      CardDemo()
    } else {
      ModalDemo()
    }
  }

  private title(): string {
    switch (this.props.route) {
      case 'circle-progress': return '环形进度 CircleProgress';
      case 'alert': return '提示条 Alert';
      case 'notify': return '通知 Notify';
      case 'notice-bar': return '公告栏 NoticeBar';
      case 'button': return '按钮 Button';
      case 'cell': return '单元格 Cell';
      case 'icon': return '图标 Icon';
      case 'loading-icon': return '加载图标 LoadingIcon';
      case 'overlay': return '遮罩层 Overlay';
      case 'popup': return '弹出层 Popup';
      case 'line': return '线条 Line';
      case 'gap': return '间隔槽 Gap';
      case 'link': return '超链接 Link';
      case 'title': return '标题 Title';
      case 'badge': return '徽标 Badge';
      case 'divider': return '分割线 Divider';
      case 'skeleton': return '骨架屏 Skeleton';
      case 'line-progress': return '线形进度条 LineProgress';
      case 'loadmore': return '加载更多 Loadmore';
      case 'avatar': return '头像 Avatar';
      case 'avatar-group': return '头像组 AvatarGroup';
      case 'input': return '输入框 Input';
      case 'textarea': return '文本域 Textarea';
      case 'switch': return '开关 Switch';
      case 'rate': return '评分 Rate';
      case 'number-box': return '步进器 NumberBox';
      case 'checkbox': return '复选框 Checkbox';
      case 'checkbox-group': return '复选框组 CheckboxGroup';
      case 'radio': return '单选框 Radio';
      case 'radio-group': return '单选框组 RadioGroup';
      case 'form': return '表单 Form';
      case 'form-item': return '表单项 FormItem';
      case 'tag': return '标签 Tag';
      case 'toast': return '提示消息 Toast';
      case 'text': return '文本 Text';
      case 'image': return '图片 Image';
      case 'empty': return '空状态 Empty';
      case 'loading-page': return '加载页 LoadingPage';
      case 'search': return '搜索框 Search';
      case 'code-input': return '验证码输入 CodeInput';
      case 'row': return '行布局 Row';
      case 'col': return '列布局 Col';
      case 'grid': return '宫格 Grid';
      case 'grid-item': return '宫格项 GridItem';
      case 'card': return '卡片 Card';
      default: return '模态框 Modal';
    }
  }

  build() {
    SampleScaffold({
      props: new SampleScaffoldProps({
        title: this.title(),
        subtitle: '固定中文案例 · 原生 ArkUI 交互',
        onBack: (): void => {
          this.props.onBack?.();
        }
      })
    }) {
      this.demo()
    }
  }
}
