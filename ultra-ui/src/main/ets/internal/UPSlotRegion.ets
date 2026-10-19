/**
 * 上游具名 slot 的通用承载区域：把 `UPBuilder` 包成可复用的子组件。
 * Shared render region that lifts a `UPBuilder` into a reusable child component,
 * because ArkTS `@BuilderParam` cannot accept an optional callback directly.
 */

/**
 * 具名插槽的渲染区域，宿主未提供 Builder 时渲染零尺寸占位。
 * Renders one named slot, collapsing to a zero-sized row when the host supplies nothing.
 */
@Component
export struct UPSlotRegion {
  @Builder
  private emptySlot() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptySlot;

  build() {
    this.contentBuilder()
  }
}

/**
 * 带宽度约束的插槽区域，用于需要占满一行的具名插槽。
 * A slot region that stretches to the full width of its parent.
 */
@Component
export struct UPSlotBlock {
  @Builder
  private emptySlot() {
    Row().width(0).height(0)
  }

  @BuilderParam contentBuilder: () => void = this.emptySlot;

  build() {
    Column() {
      this.contentBuilder()
    }
    .width('100%')
  }
}
