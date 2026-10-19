import { UPI18n, upWeekText } from '../core/UPI18n';
/**
 * 上游 u-cropper 的画布几何计算：裁剪框布局、图片适配、缩放旋转与像素处理。
 * Geometry core of the upstream u-cropper: selection layout, image fitting, transforms and pixel work.
 */

/** 上游模板固定的底部操作条高度。/ Fixed toolbar height in the upstream template. */
export const UP_CROPPER_TAB_HEIGHT: number = 50;
/** 上游 drawInit 的可用区留白：左右各 20、上下各 40。/ Padding reserved by upstream drawInit. */
export const UP_CROPPER_VIEW_INSET_X: number = 40;
export const UP_CROPPER_VIEW_INSET_Y: number = 80;
/** 上游默认缩放边界。/ Upstream default scale bounds. */
export const UP_CROPPER_MIN_SCALE: number = 0.3;
export const UP_CROPPER_MAX_SCALE: number = 4;
/** 上游默认导出质量。/ Upstream default export quality. */
export const UP_CROPPER_QUALITY: number = 0.9;
/** 上游 start() 的控制点命中半径与 drawInit 的控制点边长。/ Handle hit radius and drawn handle size. */
export const UP_CROPPER_HANDLE_HIT: number = 20;
export const UP_CROPPER_HANDLE_SIZE: number = 10;
/** 上游 move() 的裁剪框最小尺寸。/ Minimum selection size enforced by upstream move(). */
export const UP_CROPPER_MIN_SELECTION: number = 50;
/** 上游 move() 的单帧位移上限。/ Per-frame translation guard in upstream move(). */
export const UP_CROPPER_MOVE_GUARD: number = 100;
/** 上游 move() 的双指缩放系数。/ Pinch scale factor from upstream move(). */
export const UP_CROPPER_PINCH_FACTOR: number = 0.005;
/** 上游 drawImage() 的重绘节流间隔。/ Redraw throttle in upstream drawImage(). */
export const UP_CROPPER_DRAW_INTERVAL: number = 20;
/** 上游 drawInit 的遮罩与描边取值。/ Mask and stroke values from upstream drawInit. */
export const UP_CROPPER_MASK_ALPHA: number = 0.4;
export const UP_CROPPER_MASK_COLOR: string = 'black';
export const UP_CROPPER_BORDER_COLOR: string = 'grey';
export const UP_CROPPER_CORNER_COLOR: string = 'red';
export const UP_CROPPER_HANDLE_COLOR: string = 'white';
export const UP_CROPPER_BORDER_WIDTH: number = 3;
export const UP_CROPPER_CORNER_LENGTH: number = 20;
/** 透明填充关键字，上游 fillColor 的默认值。/ The upstream default fillColor keyword. */
export const UP_CROPPER_TRANSPARENT: string = 'transparent';
/** 上游 colorChange 的滑块区间。/ Saturation slider range from upstream colorChange. */
export const UP_CROPPER_COLOR_MIN: number = -100;
export const UP_CROPPER_COLOR_MAX: number = 100;
/** 上游 stretch 与 lock 的取值。/ Accepted stretch and lock values. */
export const UP_CROPPER_STRETCH_MODES: Array<string> = ['x', 'y', 'long', 'short', 'longSel', 'shortSel'];
/** 上游 i18n 的按钮与错误文案。/ Button and error strings from the upstream i18n table. */
export const UP_CROPPER_RESELECT_TEXT: string = UPI18n.t('up.common.re-select');
export const UP_CROPPER_CLOSE_TEXT: string = UPI18n.t('up.common.close');
export const UP_CROPPER_ROTATE_TEXT: string = UPI18n.t('up.common.rotate');
export const UP_CROPPER_PREVIEW_TEXT: string = UPI18n.t('up.common.preview');
export const UP_CROPPER_CONFIRM_TEXT: string = UPI18n.t('up.common.confirm');
export const UP_CROPPER_EMPTY_AREA_TEXT: string = UPI18n.t('up.cropper.emptyWidhtOrHeight');

/** 矩形区域，替代上游 selStyle 的字符串样式对象。/ Rect replacing the upstream selStyle strings. */
export class UPCropperRect {
  left: number = 0;
  top: number = 0;
  width: number = 0;
  height: number = 0;

  constructor(left: number = 0, top: number = 0, width: number = 0, height: number = 0) {
    this.left = left;
    this.top = top;
    this.width = width;
    this.height = height;
  }

  clone(): UPCropperRect {
    return new UPCropperRect(this.left, this.top, this.width, this.height);
  }

  right(): number {
    return this.left + this.width;
  }

  bottom(): number {
    return this.top + this.height;
  }
}

/** 图片在画布上的摆放，对应上游 posWidth/posHeight/useWidth/useHeight。/ Image placement on the canvas. */
export class UPCropperPlacement {
  posWidth: number = 0;
  posHeight: number = 0;
  useWidth: number = 0;
  useHeight: number = 0;
  scaleSize: number = 1;
  rotateDeg: number = 0;
  scaleWidth: number = 0;
  scaleHeight: number = 0;

  clone(): UPCropperPlacement {
    const copy: UPCropperPlacement = new UPCropperPlacement();
    copy.posWidth = this.posWidth;
    copy.posHeight = this.posHeight;
    copy.useWidth = this.useWidth;
    copy.useHeight = this.useHeight;
    copy.scaleSize = this.scaleSize;
    copy.rotateDeg = this.rotateDeg;
    copy.scaleWidth = this.scaleWidth;
    copy.scaleHeight = this.scaleHeight;
    return copy;
  }
}

/** 拉伸与锁定的解析结果，对应上游 fixWidth/fixHeight/lckWidth/lckHeight。/ Stretch and lock flags. */
export class UPCropperConstraint {
  fixWidth: boolean = false;
  fixHeight: boolean = false;
  lockWidth: boolean = false;
  lockHeight: boolean = false;
}

/** 触点，替代上游 touch0/touch1。/ One touch point replacing upstream touch0/touch1. */
export class UPCropperTouch {
  x: number = 0;
  y: number = 0;

  constructor(x: number = 0, y: number = 0) {
    this.x = x;
    this.y = y;
  }
}

/** 预览区摆放，对应上游 prvX/prvY/prvWidth/prvHeight。/ Preview placement. */
export class UPCropperPreview {
  x: number = 0;
  y: number = 0;
  width: number = 0;
  height: number = 0;
}

/** 控制点命中结果。/ Which resize handle a touch hit. */
export type UPCropperHandle = 'none' | 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';

/**
 * 上游 `parseInt(value) * pxRatio` 的等价换算：`rpx` 按设计稿折算，其余按数值取整。
 * Mirrors the upstream rpx-or-px parsing used for area and export sizes.
 */
export function upCropperLength(value: string, viewportWidth: number): number {
  const text: string = value.trim();
  if (text.length === 0) {
    return 0;
  }
  const amount: number = parseFloat(text);
  if (isNaN(amount)) {
    return 0;
  }
  if (text.includes('rpx') || text.includes('upx')) {
    return Math.floor(amount) * (viewportWidth > 0 ? viewportWidth : 375) / 750;
  }
  return Math.floor(amount);
}

/** 上游 `parseInt(quality) || 0.9`：整数化后为 0 时回落 0.9。/ Mirrors the upstream quality fallback. */
export function upCropperQuality(value: string): number {
  const amount: number = Number.parseInt(value);
  return isNaN(amount) || amount === 0 ? UP_CROPPER_QUALITY : amount;
}

/** stretch 是否落在上游取值内。/ Whether stretch is one of the upstream values. */
export function upCropperStretchSupported(stretch: string): boolean {
  return stretch.length === 0 || UP_CROPPER_STRETCH_MODES.includes(stretch);
}

/**
 * 上游 drawInit 的 stretch 与 lock 分支。
 * Mirrors the stretch and lock switches of upstream drawInit.
 */
export function upCropperConstraint(stretch: string, lock: string, imageRatio: number,
  selection: UPCropperRect): UPCropperConstraint {
  const constraint: UPCropperConstraint = new UPCropperConstraint();
  const wideImage: boolean = imageRatio > 1;
  const wideSelection: boolean = selection.width > selection.height;
  if (stretch === 'x') {
    constraint.fixWidth = true;
  } else if (stretch === 'y') {
    constraint.fixHeight = true;
  } else if (stretch === 'long') {
    constraint.fixWidth = wideImage;
    constraint.fixHeight = !wideImage;
  } else if (stretch === 'short') {
    constraint.fixHeight = wideImage;
    constraint.fixWidth = !wideImage;
  } else if (stretch === 'longSel') {
    constraint.fixWidth = wideSelection;
    constraint.fixHeight = !wideSelection;
  } else if (stretch === 'shortSel') {
    constraint.fixHeight = wideSelection;
    constraint.fixWidth = !wideSelection;
  }
  if (lock === 'x') {
    constraint.lockWidth = true;
  } else if (lock === 'y') {
    constraint.lockHeight = true;
  } else if (lock === 'long') {
    constraint.lockWidth = wideImage;
    constraint.lockHeight = !wideImage;
  } else if (lock === 'short') {
    constraint.lockHeight = wideImage;
    constraint.lockWidth = !wideImage;
  } else if (lock === 'longSel') {
    constraint.lockWidth = wideSelection;
    constraint.lockHeight = !wideSelection;
  } else if (lock === 'shortSel') {
    constraint.lockHeight = wideSelection;
    constraint.lockWidth = !wideSelection;
  }
  return constraint;
}

/**
 * 上游 loadImage 的裁剪框居中布局。
 * Mirrors the centered selection layout of upstream loadImage.
 */
export function upCropperSelection(areaWidth: number, areaHeight: number,
  canvasWidth: number, canvasHeight: number): UPCropperRect {
  const rect: UPCropperRect = new UPCropperRect();
  rect.width = areaWidth;
  rect.height = areaHeight;
  rect.top = (canvasHeight - areaHeight - UP_CROPPER_TAB_HEIGHT) / 2;
  rect.left = (canvasWidth - areaWidth) / 2;
  return rect;
}

/**
 * 上游 drawInit 的图片适配与居中，含 inner 模式的最小覆盖修正。
 * Mirrors the fitting, centering and inner-mode coverage of upstream drawInit.
 */
export function upCropperPlacement(canvasWidth: number, canvasHeight: number,
  imageWidth: number, imageHeight: number, selection: UPCropperRect,
  constraint: UPCropperConstraint, inner: boolean): UPCropperPlacement {
  const placement: UPCropperPlacement = new UPCropperPlacement();
  const imageRatio: number = imageHeight === 0 ? 1 : imageWidth / imageHeight;
  let useWidth: number = canvasWidth - UP_CROPPER_VIEW_INSET_X;
  let useHeight: number = canvasHeight - UP_CROPPER_TAB_HEIGHT - UP_CROPPER_VIEW_INSET_Y;
  if (constraint.fixWidth) {
    useWidth = selection.width;
    useHeight = useWidth / imageRatio;
  } else if (constraint.fixHeight) {
    useHeight = selection.height;
    useWidth = useHeight * imageRatio;
  } else if (imageRatio < 1) {
    if (imageHeight < useHeight) {
      useWidth = imageWidth;
      useHeight = imageHeight;
    } else {
      useWidth = useHeight * imageRatio;
    }
  } else {
    if (imageWidth < useWidth) {
      useWidth = imageWidth;
      useHeight = imageHeight;
    } else {
      useHeight = useWidth / imageRatio;
    }
  }
  if (inner) {
    if (useWidth < selection.width) {
      useWidth = selection.width;
      useHeight = useWidth / imageRatio;
      constraint.lockHeight = false;
    }
    if (useHeight < selection.height) {
      useHeight = selection.height;
      useWidth = useHeight * imageRatio;
      constraint.lockWidth = false;
    }
  }
  placement.useWidth = useWidth;
  placement.useHeight = useHeight;
  placement.posWidth = (canvasWidth - useWidth) / 2;
  placement.posHeight = (canvasHeight - useHeight - UP_CROPPER_TAB_HEIGHT) / 2;
  placement.scaleSize = 1;
  placement.rotateDeg = 0;
  return placement;
}

/** 缩放后的图片边界。/ Image bounds after scaling. */
export function upCropperImageBounds(placement: UPCropperPlacement): UPCropperRect {
  const width: number = placement.useWidth * placement.scaleSize;
  const height: number = placement.useHeight * placement.scaleSize;
  const centerX: number = placement.posWidth + placement.useWidth / 2;
  const centerY: number = placement.posHeight + placement.useHeight / 2;
  return new UPCropperRect(centerX - width / 2, centerY - height / 2, width, height);
}

/** 上游 move() 双指分支的 inner 覆盖校验。/ Inner coverage check from the pinch branch. */
export function upCropperCovers(bounds: UPCropperRect, selection: UPCropperRect): boolean {
  return selection.left >= bounds.left && selection.right() <= bounds.right()
    && selection.top >= bounds.top && selection.bottom() <= bounds.bottom();
}

/** 上游 start() 的控制点命中判定。/ Handle hit test from upstream start(). */
export function upCropperHandleAt(touch: UPCropperTouch, selection: UPCropperRect): UPCropperHandle {
  const hit: number = UP_CROPPER_HANDLE_HIT;
  const nearLeft: boolean = Math.abs(touch.x - selection.left) < hit;
  const nearRight: boolean = Math.abs(touch.x - selection.right()) < hit;
  const nearTop: boolean = Math.abs(touch.y - selection.top) < hit;
  const nearBottom: boolean = Math.abs(touch.y - selection.bottom()) < hit;
  if (nearLeft && nearTop) {
    return 'top-left';
  }
  if (nearRight && nearTop) {
    return 'top-right';
  }
  if (nearLeft && nearBottom) {
    return 'bottom-left';
  }
  if (nearRight && nearBottom) {
    return 'bottom-right';
  }
  return 'none';
}

/**
 * 上游 move() 的控制点拖拽：按角落改写矩形后再夹到画布与图片内。
 * Mirrors the handle drag of upstream move(), including screen and inner clamping.
 */
export function upCropperResize(selection: UPCropperRect, handle: UPCropperHandle, touch: UPCropperTouch,
  canvasWidth: number, canvasHeight: number, bounds?: UPCropperRect): UPCropperRect | undefined {
  if (handle === 'none') {
    return undefined;
  }
  const next: UPCropperRect = selection.clone();
  if (handle === 'top-left') {
    next.left = touch.x;
    next.top = touch.y;
    next.width = selection.right() - touch.x;
    next.height = selection.bottom() - touch.y;
  } else if (handle === 'top-right') {
    next.top = touch.y;
    next.width = touch.x - selection.left;
    next.height = selection.bottom() - touch.y;
  } else if (handle === 'bottom-left') {
    next.left = touch.x;
    next.width = selection.right() - touch.x;
    next.height = touch.y - selection.top;
  } else {
    next.width = touch.x - selection.left;
    next.height = touch.y - selection.top;
  }
  if (next.left < 0) {
    next.left = 0;
  }
  if (next.top < 0) {
    next.top = 0;
  }
  if (next.right() > canvasWidth) {
    next.width = canvasWidth - next.left;
  }
  const limitHeight: number = canvasHeight - UP_CROPPER_TAB_HEIGHT;
  if (next.bottom() > limitHeight) {
    next.height = limitHeight - next.top;
  }
  if (bounds !== undefined) {
    if (next.left < bounds.left) {
      next.left = bounds.left;
    }
    if (next.top < bounds.top) {
      next.top = bounds.top;
    }
    if (next.right() > bounds.right()) {
      next.width = bounds.right() - next.left;
    }
    if (next.bottom() > bounds.bottom()) {
      next.height = bounds.bottom() - next.top;
    }
  }
  if (next.width < UP_CROPPER_MIN_SELECTION || next.height < UP_CROPPER_MIN_SELECTION) {
    return undefined;
  }
  return next;
}

/**
 * 上游 move() 的单指平移，含 inner 模式的贴边回弹与锁定轴。
 * Mirrors the single-finger pan of upstream move() with inner clamping and locked axes.
 */
export function upCropperTranslate(placement: UPCropperPlacement, deltaX: number, deltaY: number,
  selection: UPCropperRect, constraint: UPCropperConstraint, inner: boolean): UPCropperPlacement {
  const next: UPCropperPlacement = placement.clone();
  const beX: number = placement.posWidth + deltaX;
  const beY: number = placement.posHeight + deltaY;
  if (!inner) {
    if (Math.abs(deltaX) < UP_CROPPER_MOVE_GUARD && !constraint.lockWidth) {
      next.posWidth = beX;
    }
    if (Math.abs(deltaY) < UP_CROPPER_MOVE_GUARD && !constraint.lockHeight) {
      next.posHeight = beY;
    }
    return next;
  }
  const width: number = placement.useWidth * placement.scaleSize;
  const height: number = placement.useHeight * placement.scaleSize;
  const left: number = beX + placement.useWidth / 2 - width / 2;
  const top: number = beY + placement.useHeight / 2 - height / 2;
  const right: number = left + width;
  const bottom: number = top + height;
  if (!constraint.lockWidth && Math.abs(deltaX) < UP_CROPPER_MOVE_GUARD) {
    if (selection.left >= left && selection.right() <= right) {
      next.posWidth = beX;
    } else if (selection.left < left) {
      next.posWidth = selection.left - placement.scaleWidth;
    } else {
      next.posWidth = selection.left - (width - selection.width) - placement.scaleWidth;
    }
  }
  if (!constraint.lockHeight && Math.abs(deltaY) < UP_CROPPER_MOVE_GUARD) {
    if (selection.top >= top && selection.bottom() <= bottom) {
      next.posHeight = beY;
    } else if (selection.top < top) {
      next.posHeight = selection.top - placement.scaleHeight;
    } else {
      next.posHeight = selection.top - (height - selection.height) - placement.scaleHeight;
    }
  }
  return next;
}

/**
 * 上游 move() 的双指缩放：越界或不满足 inner 覆盖时保持原值。
 * Mirrors the pinch branch of upstream move(), keeping the old scale when clamped.
 */
export function upCropperScale(placement: UPCropperPlacement, scale: number, minScale: number,
  maxScale: number, selection: UPCropperRect, inner: boolean): UPCropperPlacement {
  const next: UPCropperPlacement = placement.clone();
  if (scale < minScale || scale > maxScale) {
    return next;
  }
  if (inner) {
    const probe: UPCropperPlacement = placement.clone();
    probe.scaleSize = scale;
    if (!upCropperCovers(upCropperImageBounds(probe), selection)) {
      return next;
    }
    next.scaleWidth = (placement.useWidth - placement.useWidth * scale) / 2;
    next.scaleHeight = (placement.useHeight - placement.useHeight * scale) / 2;
  }
  next.scaleSize = scale;
  return next;
}

/** 上游 move() 的双指距离。/ Pinch distance from upstream move(). */
export function upCropperDistance(first: UPCropperTouch, second: UPCropperTouch): number {
  const deltaX: number = second.x - first.x;
  const deltaY: number = second.y - first.y;
  return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
}

/** 上游 rotate()：补到下一个 90 度整数倍。/ Mirrors upstream rotate() snapping to 90 degrees. */
export function upCropperRotate(rotateDeg: number): number {
  return rotateDeg + 90 - rotateDeg % 90;
}

/**
 * 上游 preview() 的预览区适配。
 * Mirrors the preview fitting of upstream preview().
 */
export function upCropperPreviewPlacement(canvasWidth: number, canvasHeight: number,
  selection: UPCropperRect): UPCropperPreview {
  const preview: UPCropperPreview = new UPCropperPreview();
  const useWidth: number = canvasWidth - UP_CROPPER_VIEW_INSET_X;
  const useHeight: number = canvasHeight - UP_CROPPER_VIEW_INSET_Y;
  let width: number = selection.width;
  let height: number = selection.height;
  let ratio: number = width === 0 ? 1 : useWidth / width;
  const scaledHeight: number = height * ratio;
  if (scaledHeight < useHeight) {
    width = useWidth;
    height = scaledHeight;
  } else {
    ratio = height === 0 ? 1 : useHeight / height;
    width = width * ratio;
    height = useHeight;
  }
  preview.width = width;
  preview.height = height;
  preview.x = (canvasWidth - width) / 2;
  preview.y = (canvasHeight - height) / 2;
  return preview;
}

/** 上游 colorChange 的滑块值到饱和度系数。/ Slider value to saturation factor. */
export function upCropperSaturation(value: number): number {
  if (value === 0) {
    return -1;
  }
  let factor: number = (value + UP_CROPPER_COLOR_MAX) / (UP_CROPPER_COLOR_MAX - UP_CROPPER_COLOR_MIN);
  if (factor < 0.005) {
    factor = 0;
  }
  if (factor > 0.995) {
    factor = 1;
  }
  return factor;
}

/** RGB 到 HSL 的色相，对应上游 colorChange 的分支。/ Hue from the upstream RGB branches. */
export function upCropperHue(red: number, green: number, blue: number): number {
  const max: number = Math.max(red, green, blue);
  const min: number = Math.min(red, green, blue);
  const delta: number = max - min;
  if (max === min) {
    return 0;
  }
  if (max === red) {
    return green >= blue ? 60 * ((green - blue) / delta) : 60 * ((green - blue) / delta) + 360;
  }
  if (max === green) {
    return 60 * ((blue - red) / delta) + 120;
  }
  return 60 * ((red - green) / delta) + 240;
}

/** 上游 correctRGB()。/ Mirrors upstream correctRGB(). */
export function upCropperCorrectHue(value: number): number {
  if (value < 0) {
    return value + 1;
  }
  return value > 1 ? value - 1 : value;
}

/** 上游 createRGB()。/ Mirrors upstream createRGB(). */
export function upCropperCreateChannel(value: number, low: number, high: number): number {
  if (value < 1 / 6) {
    return low + (high - low) * 6 * value;
  }
  if (value < 1 / 2) {
    return high;
  }
  if (value < 2 / 3) {
    return low + (high - low) * 6 * (2 / 3 - value);
  }
  return low;
}

/**
 * 上游 colorChange 的整段像素处理：逐像素调整饱和度后写回目标数组。
 * Mirrors the saturation pass of upstream colorChange over an RGBA buffer.
 */
export function upCropperSaturate(source: Uint8ClampedArray, factor: number): Uint8ClampedArray {
  const target: Uint8ClampedArray = new Uint8ClampedArray(source.length);
  if (factor < 0) {
    for (let index: number = 0; index < source.length; index++) {
      target[index] = source[index];
    }
    return target;
  }
  for (let index: number = source.length - 1; index >= 3; index -= 4) {
    const red: number = source[index - 3] / 255;
    const green: number = source[index - 2] / 255;
    const blue: number = source[index - 1] / 255;
    const max: number = Math.max(red, green, blue);
    const min: number = Math.min(red, green, blue);
    const delta: number = max - min;
    const hue: number = upCropperHue(red, green, blue);
    const lightness: number = (max + min) / 2;
    let saturation: number = 0;
    if (lightness !== 0 && max !== min) {
      saturation = lightness <= 0.5 ? delta / (2 * lightness) : delta / (2 - 2 * lightness);
    }
    if (factor < 0.5) {
      saturation = saturation * factor / 0.5;
    } else if (factor > 0.5) {
      saturation = 2 * saturation + 2 * factor - saturation * factor / 0.5 - 1;
    }
    let outRed: number = 0;
    let outGreen: number = 0;
    let outBlue: number = 0;
    if (saturation === 0) {
      outRed = Math.round(lightness * 255);
      outGreen = outRed;
      outBlue = outRed;
    } else {
      const high: number = lightness < 0.5 ? lightness * (1 + saturation)
        : lightness + saturation - lightness * saturation;
      const low: number = 2 * lightness - high;
      const hueKey: number = hue / 360;
      outRed = Math.round(upCropperCreateChannel(upCropperCorrectHue(hueKey + 1 / 3), low, high) * 255);
      outGreen = Math.round(upCropperCreateChannel(upCropperCorrectHue(hueKey), low, high) * 255);
      outBlue = Math.round(upCropperCreateChannel(upCropperCorrectHue(hueKey - 1 / 3), low, high) * 255);
    }
    target[index] = source[index];
    target[index - 3] = outRed;
    target[index - 2] = outGreen;
    target[index - 1] = outBlue;
  }
  return target;
}
