# Ultra UI HOS Phase 8 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use executing-plans. Steps use TDD.

**Goal:** Add six navigation-and-more components to the native HarmonyOS HAR with sample coverage.

**Architecture:** Follow the existing Props-plus-`@Component` pattern. Parent/child swipe coordination uses a composition context; popover, tooltip, read-more, and pagination remain page-controlled. Rendering uses ArkUI containers, gestures, clipping, and buttons only.

**Tech Stack:** ArkTS, ArkUI, HarmonyOS NEXT API 24, Python static contracts, Hvigor HAR/HAP builds.

## Global Constraints

- Stable exports come only from `ultra-ui/Index.ets`.
- Samples import only `@lingyun/ultra-ui-hos`.
- No WebView, network access, runtime JSON mapping, Vue/NVue, or business routing.
- Invalid values fall back safely through existing `up*` helpers and diagnostics.
- Baseline remains API 24 / `5.0.0(12)`.

## Tasks

1. Add `scripts/test_phase_8_navigation_more_contract.py`; run it and verify it fails because the six source files are absent. Lock public structs/Props/options/events, model/value priority, defaults, swipe context methods, six routes/demos, documentation phrases, and forbidden boundaries.
2. Implement `UPPopover`, `UPTooltip`, and `UPSticky`. Popover supports click/toggle and placement fallbacks; tooltip supports longpress/click, overlay, buttons, and copy callback fields; sticky renders its content and reports that dynamic scroll binding remains host-driven when used outside a native sticky list.
3. Implement swipe parent/item with an auto-close context, threshold, disabled guard, option selection, close-on-click, duration field, and explicit typed events.
4. Implement `UPReadMore` collapsed-height control and `UPPagination` page derivation, single-page hiding, prev/next, bounded pager, and change callbacks.
5. Add six Chinese demos/routes under a new catalog group, dispatch them in `SamplePage`, export APIs, update README/count, and add `docs/compatibility/phase-8.md`.
6. Run the new contract, every static contract, boundary checks, HAR/HAP builds, toolchain check, diff hygiene, and screenshot capture. Record skipped device verification when no target is connected.
