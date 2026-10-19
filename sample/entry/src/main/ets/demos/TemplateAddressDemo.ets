import {
  UPButton,
  UPButtonProps,
  UPIcon,
  UPIconProps,
  UPInput,
  UPInputChangeEvent,
  UPInputProps,
  UPSwitch,
  UPSwitchChangeEvent,
  UPSwitchProps,
  UPTag,
  UPTagProps
} from '@lingyun/ultra-ui-hos';

/** 一个收货地址。/ One saved shipping address. */
interface AddressItem {
  id: number;
  name: string;
  phone: string;
  tags: Array<string>;
  site: string;
  isDefault: boolean;
}

/**
 * 复刻上游 `pages/template/address/index.vue` 与 `addSite.vue` 的地址管理场景。
 * ArkTS port of the upstream address template: a list of saved addresses plus an
 * inline新增表单 (收货人 / 手机号 / 详细地址 / 标签 / 默认开关).
 */
@Component
export struct TemplateAddressDemo {
  @State private list: Array<AddressItem> = [
    { id: 1, name: '游 X', phone: '183****5523', tags: ['默认', '家'], site: '广东省深圳市宝安区 自由路 66 号', isDefault: true },
    { id: 2, name: '李 XX', phone: '183****5555', tags: ['公司'], site: '广东省深圳市宝安区 翻身路 xx 号', isDefault: false }
  ];
  @State private editing: boolean = false;
  @State private formName: string = '';
  @State private formPhone: string = '';
  @State private formSite: string = '';
  @State private formTag: string = '家';
  @State private formDefault: boolean = false;
  @State private message: string = '';
  private nextId: number = 3;
  private readonly tagOptions: Array<string> = ['家', '公司', '学校'];

  private save(): void {
    if (this.formName.length === 0 || this.formPhone.length === 0) {
      this.message = '请填写收货人和手机号';
      return;
    }
    const item: AddressItem = {
      id: this.nextId,
      name: this.formName,
      phone: this.formPhone,
      tags: this.formDefault ? ['默认', this.formTag] : [this.formTag],
      site: this.formSite.length > 0 ? this.formSite : '未填写详细地址',
      isDefault: this.formDefault
    };
    this.nextId = this.nextId + 1;
    this.list = this.list.concat([item]);
    this.editing = false;
    this.formName = '';
    this.formPhone = '';
    this.formSite = '';
    this.formDefault = false;
    this.message = '已新增地址';
  }

  @Builder
  private addressCard(item: AddressItem) {
    Column({ space: 6 }) {
      Row({ space: 8 }) {
        Text(item.name).fontSize(15).fontColor('#303133').fontWeight(FontWeight.Medium)
        Text(item.phone).fontSize(13).fontColor('#606266')
        Blank()
        ForEach(item.tags, (tag: string) => {
          UPTag({ props: new UPTagProps({ text: tag, type: tag === '默认' ? 'error' : 'info', size: 'mini', plain: true }) })
        }, (tag: string): string => tag)
      }
      .width('100%')
      Row() {
        Text(item.site).fontSize(13).fontColor('#606266').layoutWeight(1)
        UPIcon({ props: new UPIconProps({ name: 'edit-pen', size: 18, color: '#999999' }) })
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .border({ width: { bottom: 1 }, color: '#ebeef5' })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private form() {
    Column({ space: 10 }) {
      UPInput({ props: new UPInputProps({ modelValue: this.formName, placeholder: '请填写收货人姓名', border: 'bottom',
        onInput: (event: UPInputChangeEvent): void => { this.formName = event.value; } }) })
      UPInput({ props: new UPInputProps({ modelValue: this.formPhone, type: 'number', placeholder: '请填写手机号', border: 'bottom',
        onInput: (event: UPInputChangeEvent): void => { this.formPhone = event.value; } }) })
      UPInput({ props: new UPInputProps({ modelValue: this.formSite, placeholder: '街道、楼牌等详细地址', border: 'bottom',
        onInput: (event: UPInputChangeEvent): void => { this.formSite = event.value; } }) })
      Row({ space: 8 }) {
        Text('标签').fontSize(13).fontColor('#606266')
        ForEach(this.tagOptions, (tag: string) => {
          UPTag({ props: new UPTagProps({
            text: tag,
            type: this.formTag === tag ? 'primary' : 'info',
            plain: this.formTag !== tag,
            onClick: (): void => { this.formTag = tag; }
          }) })
        }, (tag: string): string => tag)
      }
      .width('100%')
      Row() {
        Column({ space: 2 }) {
          Text('设置默认地址').fontSize(14).fontColor('#303133')
          Text('每次下单会默认推荐该地址').fontSize(12).fontColor('#909399')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        UPSwitch({ props: new UPSwitchProps({
          modelValue: this.formDefault,
          onChange: (event: UPSwitchChangeEvent): void => { this.formDefault = event.checked; }
        }) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      UPButton({ props: new UPButtonProps({ text: '保存地址', type: 'primary',
        onClick: (): void => { this.save(); } }) })
    }
    .width('100%')
    .padding(12)
  }

  build() {
    Column() {
      ForEach(this.list, (item: AddressItem) => {
        this.addressCard(item)
      }, (item: AddressItem): string => String(item.id))
      if (this.editing) {
        this.form()
      } else {
        UPButton({ props: new UPButtonProps({ text: '新建收货地址', type: 'error', icon: 'plus',
          onClick: (): void => { this.editing = true; this.message = ''; } }) })
      }
      if (this.message.length > 0) {
        Text(this.message).fontSize(13).fontColor('#909399').width('100%').padding({ left: 12, top: 8 })
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }
}
