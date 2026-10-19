import {
  UPButton,
  UPButtonProps,
  UPCanvas,
  UPCanvasProps,
  UPCanvasSurface,
  UPCanvasTextMetrics,
  UPCanvasTouchEvent,
  upCanvasId,
  upCanvasParseSize,
  upCanvasUnitSupported
} from '@lingyun/ultra-ui-hos';

@Component
export struct CanvasDemo {
  @State private measureText: string = 'onReady 后回传 measureText 宽度';
  @State private touchText: string = '在下方画板上拖动即可涂鸦';
  @State private exportText: string = '导出结果待生成';
  private basicSurface: UPCanvasSurface = new UPCanvasSurface();
  private padSurface: UPCanvasSurface = new UPCanvasSurface();
  private lastX: number = 0;
  private lastY: number = 0;
  private canvasIdText: string = upCanvasId();
  private unitNames: Array<string> = ['px', 'rpx', 'upx', 'vw', 'em'];

  /** onReady 回传绘制面板后一次性画出基础图元。/ Paints the basic primitives once the surface is ready. */
  private paintBasic(surface: UPCanvasSurface): void {
    this.basicSurface = surface;
    surface.clearCanvas();
    surface.setFillStyle('#3c9cff');
    surface.fillRect(12, 12, 90, 48);
    surface.setStrokeStyle('#fa3534');
    surface.setLineWidth(3);
    surface.setLineCap('round');
    surface.beginPath();
    surface.arc(150, 36, 24, 0, Math.PI * 2);
    surface.stroke();
    surface.setLineDash([6, 4]);
    surface.beginPath();
    surface.moveTo(12, 78);
    surface.lineTo(276, 78);
    surface.stroke();
    surface.setLineDash([]);
    const gradient: CanvasGradient | undefined = surface.createLinearGradient(12, 0, 276, 0);
    if (gradient !== undefined) {
      gradient.addColorStop(0, '#3c9cff');
      gradient.addColorStop(1, '#fa3534');
      surface.setFillGradient(gradient);
      surface.fillRect(12, 92, 264, 22);
    }
    surface.setFillStyle('#303133');
    surface.setFontSize(14);
    surface.setTextAlign('left');
    surface.setTextBaseline('middle');
    const label: string = 'ArkUI Canvas 即时绘制';
    surface.fillText(label, 12, 138);
    const metrics: UPCanvasTextMetrics = surface.measureText(label);
    surface.draw(true, (): void => {
      this.reportMeasure(metrics.width);
    });
  }

  private reportMeasure(value: number): void {
    this.measureText = 'measureText("ArkUI Canvas 即时绘制") = ' + String(Math.round(value)) + 'vp';
  }

  /** 画板 onReady：铺底并画一条提示基线。/ Prepares the scribble pad. */
  private preparePad(surface: UPCanvasSurface): void {
    this.padSurface = surface;
    surface.clearCanvas();
    surface.setStrokeStyle('#e4e7ed');
    surface.setLineWidth(1);
    surface.beginPath();
    surface.moveTo(0, 60);
    surface.lineTo(300, 60);
    surface.stroke();
  }

  private handleTouchStart(event: UPCanvasTouchEvent): void {
    this.lastX = event.x;
    this.lastY = event.y;
    this.touchText = event.type + '：(' + String(Math.round(event.x)) + ', ' + String(Math.round(event.y)) + ')';
  }

  private handleTouchMove(event: UPCanvasTouchEvent): void {
    this.padSurface.setStrokeStyle('#2979ff');
    this.padSurface.setLineWidth(4);
    this.padSurface.setLineJoin('round');
    this.padSurface.beginPath();
    this.padSurface.moveTo(this.lastX, this.lastY);
    this.padSurface.lineTo(event.x, event.y);
    this.padSurface.stroke();
    this.lastX = event.x;
    this.lastY = event.y;
    this.touchText = event.type + '：(' + String(Math.round(event.x)) + ', ' + String(Math.round(event.y)) + ')';
  }

  private handleTouchEnd(event: UPCanvasTouchEvent): void {
    this.touchText = event.type + '：抬笔于 (' + String(Math.round(event.x)) + ', ' + String(Math.round(event.y)) + ')';
  }

  private clearPad(): void {
    this.padSurface.clearCanvas();
    this.touchText = '画板已清空，可继续涂鸦';
  }

  private exportPad(): void {
    const dataUrl: string = this.padSurface.exportImage('png', 1);
    if (dataUrl.length === 0) {
      this.exportText = '画板尚未就绪，导出返回空串';
      return;
    }
    this.exportText = '导出 data URL，长度 ' + String(dataUrl.length) + ' 字符（上游返回临时文件路径）';
  }

  private unitText(name: string): string {
    const size: number = upCanvasParseSize(200, name);
    return 'unit=' + name + (upCanvasUnitSupported(name) ? '：支持' : '：不支持，回落 px')
      + '，200 → ' + String(Math.round(size)) + 'vp';
  }

  build() {
    Column({ space: 16 }) {
      Text('基础图元与渐变')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCanvas({
        props: new UPCanvasProps({
          width: 300,
          height: 160,
          bgColor: '#f7f8fa',
          onReady: (surface: UPCanvasSurface): void => {
            this.paintBasic(surface);
          }
        })
      })
      Text(this.measureText).fontSize(13).fontColor('#606266').width('100%')
      Text('setFillStyle/setStrokeStyle/setLineDash/createLinearGradient 与上游同名同参，draw(isLastDraw, callback) 只保留回调时序。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')

      Text('触摸涂鸦与导出')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCanvas({
        props: new UPCanvasProps({
          canvasId: this.canvasIdText,
          width: 300,
          height: 180,
          bgColor: '#ffffff',
          onReady: (surface: UPCanvasSurface): void => {
            this.preparePad(surface);
          },
          onTouchStart: (event: UPCanvasTouchEvent): void => {
            this.handleTouchStart(event);
          },
          onTouchMove: (event: UPCanvasTouchEvent): void => {
            this.handleTouchMove(event);
          },
          onTouchEnd: (event: UPCanvasTouchEvent): void => {
            this.handleTouchEnd(event);
          }
        })
      })
      Row({ space: 12 }) {
        UPButton({
          props: new UPButtonProps({
            text: '清空画板',
            size: 'small',
            onClick: (): void => {
              this.clearPad();
            }
          })
        })
        UPButton({
          props: new UPButtonProps({
            text: '导出图片',
            type: 'primary',
            size: 'small',
            onClick: (): void => {
              this.exportPad();
            }
          })
        })
      }
      .width('100%')
      Text(this.touchText).fontSize(13).fontColor('#606266').width('100%')
      Text(this.exportText).fontSize(13).fontColor('#606266').width('100%')

      Text('尺寸单位与 canvasId')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#303133')
        .width('100%')
      UPCanvas({
        props: new UPCanvasProps({
          width: 600,
          height: 120,
          unit: 'rpx',
          bgColor: '#ecf5ff'
        })
      })
      Text('unit=rpx 时 600rpx 宽的画布按 375 设计稿换算到 300vp。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      ForEach(this.unitNames, (name: string): void => {
        Text(this.unitText(name)).fontSize(12).fontColor('#909399').width('100%')
      }, (name: string): string => name)
      Text('宿主既可像本例一样从 onReady 接过绘制面板，也可自行 new UPCanvasSurface() 通过 surface 注入。')
        .fontSize(12)
        .fontColor('#909399')
        .width('100%')
      Text('canvasId 仅作信息透传：' + this.canvasIdText + '；ArkUI 通过渲染上下文寻址画布，disableScroll 为 no-op。')
        .fontSize(12)
        .fontColor('#c0c4cc')
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
