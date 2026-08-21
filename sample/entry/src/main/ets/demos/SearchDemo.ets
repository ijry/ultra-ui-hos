import { UPSearch, UPSearchChangeEvent, UPSearchConfirmEvent, UPSearchProps } from '@lingyun/ultra-ui-hos';

@Component
export struct SearchDemo {
  @State private value: string = '';
  @State private message: string = '输入、清除、图标与操作区均回传本地事件';

  private change(event: UPSearchChangeEvent): void {
    this.value = event.value;
    this.message = '当前输入：' + (event.value.length > 0 ? event.value : '空');
  }

  private confirm(event: UPSearchConfirmEvent): void {
    this.message = event.action + '：' + (event.value.length > 0 ? event.value : '空');
  }

  build() {
    Column({ space: 16 }) {
      Text('搜索框')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPSearch({ props: new UPSearchProps({
        modelValue: this.value,
        label: '商品',
        placeholder: '请输入商品名称',
        maxlength: 12,
        actionText: '查找',
        onInput: (event: UPSearchChangeEvent): void => { this.change(event); },
        onChange: (event: UPSearchChangeEvent): void => { this.message = '变更：' + (event.value.length > 0 ? event.value : '空'); },
        onClear: (): void => { this.message = '已清除'; },
        onSearch: (event: UPSearchConfirmEvent): void => { this.confirm(event); },
        onCustom: (event: UPSearchConfirmEvent): void => { this.confirm(event); },
        onFocus: (event: UPSearchChangeEvent): void => { this.message = '获得焦点：' + event.value; },
        onBlur: (event: UPSearchChangeEvent): void => { this.message = '失去焦点：' + event.value; },
        onClick: (): void => { this.message = '点击搜索框'; },
        onClickIcon: (event: UPSearchConfirmEvent): void => { this.message = '点击图标：' + event.action; }
      }) })
      UPSearch({ props: new UPSearchProps({
        value: '不可编辑',
        disabled: true,
        showAction: false,
        shape: 'square'
      }) })
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
