import {
  UPButton,
  UPButtonProps,
  UPCheckboxGroup,
  UPCheckboxGroupChangeEvent,
  UPCheckboxGroupProps,
  UPFieldRules,
  UPForm,
  UPFormController,
  UPFormErrorToastEvent,
  UPFormItem,
  UPFormItemProps,
  UPFormProps,
  UPFormValidateEvent,
  UPInput,
  UPInputChangeEvent,
  UPInputProps,
  UPRadioGroup,
  UPRadioGroupChangeEvent,
  UPRadioGroupProps,
  UPValidateFieldValue
} from '@lingyun/ultra-ui-hos';

@Component
export struct FormDemo {
  @State private name: string = '';
  @State private email: string = '';
  @State private age: string = '';
  @State private sex: string = 'female';
  @State private interests: Array<string> = ['ui'];
  @State private message: string = '点击「提交校验」运行上游规则';
  @State private toastText: string = '';
  private controller: UPFormController = new UPFormController();

  /** 上游 rules 对象在 ArkTS 里表达为字段规则数组。/ The upstream rules object as field entries. */
  private rules(): Array<UPFieldRules> {
    return [
      {
        field: 'name',
        label: '姓名',
        rules: [
          { required: true, type: 'string', message: '请输入姓名', triggers: ['blur', 'change'] },
          { type: 'string', min: 2, max: 8, message: '姓名长度需为 2 到 8 个字符', triggers: ['blur'] }
        ]
      },
      {
        field: 'email',
        label: '邮箱',
        rules: [
          { required: true, type: 'string', message: '请输入邮箱', triggers: ['blur'] },
          { type: 'email', message: '邮箱格式不正确', triggers: ['blur'] }
        ]
      },
      {
        field: 'age',
        label: '年龄',
        rules: [
          { required: true, type: 'number', message: '请输入年龄', triggers: ['blur'] },
          { type: 'number', min: 18, max: 60, message: '年龄需在 18 到 60 之间', triggers: ['blur'] }
        ]
      },
      {
        field: 'sex',
        label: '性别',
        rules: [{ type: 'enum', enumValues: ['male', 'female'], message: '请选择性别', triggers: ['change'] }]
      },
      {
        field: 'interests',
        label: '兴趣',
        rules: [{ type: 'array', min: 1, message: '请至少选择一项兴趣', triggers: ['change'] }]
      }
    ];
  }

  /** 当前值下发给控制器与 `UPForm`。/ The current values handed to the controller. */
  private values(): Array<UPValidateFieldValue> {
    return [
      { field: 'name', value: this.name },
      { field: 'email', value: this.email },
      { field: 'age', value: this.age },
      { field: 'sex', value: this.sex },
      { field: 'interests', value: this.interests }
    ];
  }

  private sync(): void {
    this.controller.setValues(this.values());
  }

  /** 逐字段校验，对应上游 validateField(prop, callback, trigger)。/ Per-field validation. */
  private touch(field: string, trigger: string): void {
    this.sync();
    this.controller.validateField(field, trigger);
    const failure: string = this.controller.errorOf(field);
    this.message = failure.length > 0 ? field + '：' + failure : field + ' 校验通过';
  }

  private submit(): void {
    this.sync();
    const result = this.controller.validate();
    this.message = result.valid
      ? '全部通过，可提交'
      : '共 ' + String(result.errors.length) + ' 条错误，首条：' + result.errors[0].message;
  }

  private reset(): void {
    this.controller.resetFields();
    const restored: Array<UPValidateFieldValue> = this.controller.resetValues();
    for (let index: number = 0; index < restored.length; index++) {
      const entry: UPValidateFieldValue = restored[index];
      if (entry.field === 'name') {
        this.name = entry.value === null || entry.value === undefined ? '' : String(entry.value);
      } else if (entry.field === 'email') {
        this.email = entry.value === null || entry.value === undefined ? '' : String(entry.value);
      } else if (entry.field === 'age') {
        this.age = entry.value === null || entry.value === undefined ? '' : String(entry.value);
      }
    }
    this.message = '已还原首次快照并清空错误';
    this.toastText = '';
  }

  private clear(): void {
    this.controller.clearValidate();
    this.message = '已清空校验结果，值保持不变';
    this.toastText = '';
  }

  build() {
    Column({ space: 12 }) {
      Text('规则校验表单')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPForm({
        props: new UPFormProps({
          values: this.values(),
          rules: this.rules(),
          controller: this.controller,
          errorType: 'message',
          labelWidth: 72,
          borderBottom: true,
          onValidate: (event: UPFormValidateEvent): void => {
            if (event.valid) {
              this.toastText = '';
            }
          },
          onErrorToast: (event: UPFormErrorToastEvent): void => {
            this.toastText = event.field + '：' + event.message;
          }
        })
      }) {
        UPFormItem({ props: new UPFormItemProps({ label: '姓名', prop: 'name', required: true }) }) {
          UPInput({ props: new UPInputProps({
            modelValue: this.name,
            placeholder: '2 到 8 个字符',
            onInput: (event: UPInputChangeEvent): void => {
              this.name = event.value;
              this.touch('name', 'change');
            },
            onBlur: (): void => {
              this.touch('name', 'blur');
            }
          }) })
        }
        UPFormItem({ props: new UPFormItemProps({ label: '邮箱', prop: 'email', required: true }) }) {
          UPInput({ props: new UPInputProps({
            modelValue: this.email,
            placeholder: 'name@example.com',
            onInput: (event: UPInputChangeEvent): void => {
              this.email = event.value;
            },
            onBlur: (): void => {
              this.touch('email', 'blur');
            }
          }) })
        }
        UPFormItem({ props: new UPFormItemProps({ label: '年龄', prop: 'age', required: true }) }) {
          UPInput({ props: new UPInputProps({
            modelValue: this.age,
            type: 'number',
            placeholder: '18 到 60',
            onInput: (event: UPInputChangeEvent): void => {
              this.age = event.value;
            },
            onBlur: (): void => {
              this.touch('age', 'blur');
            }
          }) })
        }
        UPFormItem({ props: new UPFormItemProps({ label: '性别', prop: 'sex' }) }) {
          UPRadioGroup({ props: new UPRadioGroupProps({
            modelValue: this.sex,
            options: [{ name: 'male', label: '男' }, { name: 'female', label: '女' }],
            onChange: (event: UPRadioGroupChangeEvent): void => {
              this.sex = String(event.value);
              this.touch('sex', 'change');
            }
          }) })
        }
        UPFormItem({ props: new UPFormItemProps({ label: '兴趣', prop: 'interests' }) }) {
          UPCheckboxGroup({ props: new UPCheckboxGroupProps({
            modelValue: this.interests,
            placement: 'column',
            options: [{ name: 'ui', label: '界面设计' }, { name: 'code', label: '原生开发' }],
            onChange: (event: UPCheckboxGroupChangeEvent): void => {
              this.interests = event.value.map((item): string => String(item));
              this.touch('interests', 'change');
            }
          }) })
        }
      }
      Row({ space: 8 }) {
        UPButton({ props: new UPButtonProps({
          text: '提交校验',
          type: 'primary',
          onClick: (): void => {
            this.submit();
          }
        }) })
        UPButton({ props: new UPButtonProps({
          text: '清空校验',
          onClick: (): void => {
            this.clear();
          }
        }) })
        UPButton({ props: new UPButtonProps({
          text: '重置表单',
          onClick: (): void => {
            this.reset();
          }
        }) })
      }
      .width('100%')
      Text(this.message)
        .fontSize(13)
        .fontColor('#909399')
        .width('100%')
      if (this.toastText.length > 0) {
        Text('errorType=toast 时由宿主呈现：' + this.toastText)
          .fontSize(12)
          .fontColor('#fa3534')
          .width('100%')
      }
      Text('规则字段与上游 async-validator 对齐：required、type、min/max/len、pattern、enum、whitespace 与自定义 validator；触发时机由 triggers 控制。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('errorType 支持 message / toast / border-bottom / none；toast 分支不内置全局提示，改为 onErrorToast 交给宿主（可接 UPToastController）。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
