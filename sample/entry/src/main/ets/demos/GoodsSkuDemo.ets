import {
  UPButton,
  UPButtonProps,
  UPGoodsSku,
  UPGoodsSkuCombination,
  UPGoodsSkuConfirmEvent,
  UPGoodsSkuInfo,
  UPGoodsSkuProps,
  UPGoodsSkuSelection,
  UPGoodsSkuTreeItem,
  UP_GOODS_SKU_MAX_BUY,
  UP_GOODS_SKU_RESERVED_KEYS,
  upGoodsSkuKeySupported,
  upGoodsSkuMatch,
  upGoodsSkuPrice,
  upGoodsSkuStock
} from '@lingyun/ultra-ui-hos';

@Component
export struct GoodsSkuDemo {
  @State private panelVisible: boolean = false;
  @State private confirmText: string = '选齐规格后点击确定，回传组合、数量与已选文案';
  @State private lifecycleText: string = '打开面板会先回传 onOpen';
  private goodsInfo: UPGoodsSkuInfo = {
    image: '$rawfile:app_icon.png',
    title: '云锦针织衫',
    price: '129.00',
    stock: 30
  };
  private remoteGoodsInfo: UPGoodsSkuInfo = {
    image: 'remote://cdn/goods.png',
    title: '远端图占位演示',
    price: '99.00',
    stock: 12
  };
  private skuTree: Array<UPGoodsSkuTreeItem> = [
    {
      name: 'color',
      label: '颜色',
      children: [
        { id: 1, name: '烟雨青' },
        { id: 2, name: '晴空蓝' },
        { id: 3, name: '夜色黑' }
      ]
    },
    {
      name: 'size',
      label: '尺码',
      children: [
        { id: 11, name: 'S' },
        { id: 12, name: 'M' },
        { id: 13, name: 'L' }
      ]
    }
  ];
  private skuList: Array<UPGoodsSkuCombination> = [
    { values: [{ name: 'color', id: 1 }, { name: 'size', id: 11 }], price: '129.00', stock: 6 },
    { values: [{ name: 'color', id: 1 }, { name: 'size', id: 12 }], price: '139.00', stock: 0 },
    { values: [{ name: 'color', id: 2 }, { name: 'size', id: 12 }], price: '149.00', stock: 3 },
    { values: [{ name: 'color', id: 2 }, { name: 'size', id: 13 }], price: '159.00', stock: 9 },
    { values: [{ name: 'color', id: 3 }, { name: 'size', id: 11 }], price: '169.00', quantity: 2 }
  ];
  private probeSelection: Array<UPGoodsSkuSelection> = [
    { name: 'color', id: 2 },
    { name: 'size', id: 12 }
  ];
  private keyNames: Array<string> = ['color', 'size', 'price', 'stock', 'quantity'];

  private openPanel(): void {
    this.panelVisible = true;
  }

  private handleOpen(): void {
    this.lifecycleText = 'onOpen：面板已打开，选择状态重置';
  }

  private handleConfirm(event: UPGoodsSkuConfirmEvent): void {
    const stock: number = upGoodsSkuStock(event.sku, event.goodsInfo);
    this.confirmText = '已选 ' + event.selectedText + ' × ' + String(event.num)
      + ' 件，单价 ' + upGoodsSkuPrice(event.sku, event.goodsInfo) + ' 元，剩余库存 ' + String(stock) + ' 件';
    this.panelVisible = false;
  }

  private handleClose(): void {
    this.panelVisible = false;
    this.lifecycleText = 'onClose：面板已关闭';
  }

  private handleClosed(): void {
    this.lifecycleText = 'onClosed：关闭动作收尾';
  }

  private matchText(): string {
    const combination: UPGoodsSkuCombination | null = upGoodsSkuMatch(this.skuList, this.probeSelection);
    if (combination === null) {
      return '晴空蓝 + M 未命中任何组合';
    }
    return '晴空蓝 + M 命中组合：单价 ' + upGoodsSkuPrice(combination, this.goodsInfo)
      + ' 元，库存 ' + String(upGoodsSkuStock(combination, this.goodsInfo)) + ' 件';
  }

  private fallbackText(): string {
    return '未选齐时回落商品信息：单价 ' + upGoodsSkuPrice(null, this.goodsInfo)
      + ' 元，库存 ' + String(upGoodsSkuStock(null, this.goodsInfo)) + ' 件';
  }

  private keyText(name: string): string {
    return "维度键 '" + name + "'" + (upGoodsSkuKeySupported(name) ? '：可用' : '：与保留字段冲突，不可用作维度');
  }

  build() {
    Column({ space: 16 }) {
      Text('内联规格面板')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPGoodsSku({
        props: new UPGoodsSkuProps({
          goodsInfo: this.goodsInfo,
          skuTree: this.skuTree,
          skuList: this.skuList,
          pageInline: true,
          maxBuy: 5,
          confirmText: '加入购物车',
          onConfirm: (event: UPGoodsSkuConfirmEvent): void => {
            this.handleConfirm(event);
          }
        })
      })
      Text(this.confirmText).fontSize(13).fontColor('#606266').width('100%')
      Text('pageInline=true 时直接内联渲染，没有遮罩；库存为 0 或不存在的组合会自动置灰。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('受控弹层与生命周期')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Stack() {
        Column({ space: 12 }) {
          UPButton({
            props: new UPButtonProps({
              text: '选择规格',
              type: 'primary',
              onClick: (): void => {
                this.openPanel();
              }
            })
          })
          Text(this.lifecycleText).fontSize(13).fontColor('#606266').width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        UPGoodsSku({
          props: new UPGoodsSkuProps({
            goodsInfo: this.goodsInfo,
            skuTree: this.skuTree,
            skuList: this.skuList,
            show: this.panelVisible,
            onOpen: (): void => {
              this.handleOpen();
            },
            onConfirm: (event: UPGoodsSkuConfirmEvent): void => {
              this.handleConfirm(event);
            },
            onClose: (): void => {
              this.handleClose();
            },
            onClosed: (): void => {
              this.handleClosed();
            }
          })
        })
      }
      .width('100%')
      .height(640)
      Text('上游 trigger/header 插槽换成受控 show：onClose 与 onConfirm 后需要宿主自行把 show 置回 false。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('远端图占位')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPGoodsSku({
        props: new UPGoodsSkuProps({
          goodsInfo: this.remoteGoodsInfo,
          skuTree: this.skuTree,
          skuList: this.skuList,
          pageInline: true,
          closeable: false
        })
      })
      Text('远端地址不会发起加载，一律渲染本地占位；closeable=false 时隐藏右上角关闭按钮。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('组合匹配与保留字段')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      Text(this.matchText()).fontSize(12).fontColor('#909399').width('100%')
      Text(this.fallbackText()).fontSize(12).fontColor('#909399').width('100%')
      ForEach(this.keyNames, (name: string): void => {
        Text(this.keyText(name)).fontSize(12).fontColor('#909399').width('100%')
      }, (name: string): string => name)
      Text('保留字段：' + UP_GOODS_SKU_RESERVED_KEYS.join('、') + '；maxBuy 缺省上限 '
        + String(UP_GOODS_SKU_MAX_BUY) + ' 件，实际上限再与库存取小。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
      Text('组合用具名 values 数组表达（上游是 sku[key] 扁平对象），价格优先取 price，其次 price_fee；库存优先 stock，其次 quantity。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
