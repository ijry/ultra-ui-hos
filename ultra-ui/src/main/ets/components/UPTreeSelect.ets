import { UPRawValue, UPStyleInput, upBoolean, upNumber, upString } from '../core/UPTypes';
import { UPCompatibilityDiagnostics, UP_SILENT_DIAGNOSTICS } from '../core/UPDiagnostics';
import { UPColor } from '../core/UPColor';
import { UPStyle } from '../core/UPStyle';
import { UP_DEFAULT_THEME } from '../core/UPTheme';
import { UPIcon, UPIconProps } from './UPIcon';

/** 上游默认展开与折叠图标。/ Default expand and collapse icons upstream. */
export const UP_TREE_EXPAND_ICON: string = 'play-right-fill';
export const UP_TREE_COLLAPSE_ICON: string = 'arrow-down-fill';
/** 上游默认缩进、图标与勾选框尺寸。/ Default indent, icon and checkbox sizes. */
export const UP_TREE_INDENT: number = 32;
export const UP_TREE_ICON_SIZE: number = 14;
export const UP_TREE_CHECKBOX_SIZE: number = 16;
/** 上游 treeProps 的四个默认键名。/ The four default key names of upstream treeProps. */
export const UP_TREE_LABEL_KEY: string = 'label';
export const UP_TREE_CHILDREN_KEY: string = 'children';
export const UP_TREE_NODE_KEY: string = 'id';
export const UP_TREE_DISABLED_KEY: string = 'disabled';
/** 上游 .u-tree-node--current 的高亮底色与禁用透明度。/ Current highlight and disabled opacity. */
export const UP_TREE_CURRENT_BACKGROUND: string = '#ecf5ff';
export const UP_TREE_DISABLED_OPACITY: number = 0.55;
/** 上游 .u-tree-node__content 的最小行高（72rpx ≈ 36vp）。/ Minimum row height. */
export const UP_TREE_ROW_HEIGHT: number = 36;

/** 树节点。/ One tree node. */
export interface UPTreeSelectNode {
  value?: UPRawValue;
  id?: UPRawValue;
  label?: string;
  name?: string;
  text?: string;
  children?: Array<UPTreeSelectNode>;
  disabled?: UPRawValue;
  checked?: UPRawValue;
  expanded?: UPRawValue;
}

/** 上游 treeProps 的键名映射。/ Key-name mapping mirroring upstream treeProps. */
export interface UPTreeSelectKeys {
  label?: string;
  children?: string;
  nodeKey?: string;
  disabled?: string;
}

/** 摊平后的可见节点。/ One visible node after flattening. */
export class UPTreeSelectFlatNode {
  key: string = '';
  node: UPTreeSelectNode = {};
  depth: number = 0;
  level: number = 0;
  hasChildren: boolean = false;
  expanded: boolean = false;
  checked: boolean = false;
  indeterminate: boolean = false;
  disabled: boolean = false;
}

/** 上游 change 事件（保留既有形态）。/ The existing change payload. */
export interface UPTreeSelectChangeEvent {
  values: Array<UPRawValue>;
  node: UPTreeSelectNode;
}

/** 上游 check 事件的第二个参数。/ Second argument of the upstream check event. */
export interface UPTreeSelectCheckState {
  checkedKeys: Array<string>;
  checkedNodes: Array<UPTreeSelectNode>;
  halfCheckedKeys: Array<string>;
  halfCheckedNodes: Array<UPTreeSelectNode>;
}

/** 上游 check 事件。/ Upstream check payload. */
export interface UPTreeSelectCheckEvent {
  node: UPTreeSelectNode;
  state: UPTreeSelectCheckState;
}

/** 上游 check-change 事件。/ Upstream check-change payload. */
export interface UPTreeSelectCheckChangeEvent {
  node: UPTreeSelectNode;
  checked: boolean;
}

/** 上游 current-change 事件。/ Upstream current-change payload. */
export interface UPTreeSelectCurrentChangeEvent {
  node: UPTreeSelectNode;
  previous?: UPTreeSelectNode;
}

/** 上游 treeProps 的键名读取，替代 `node[key]`。/ Named lookup replacing `node[key]`. */
export function upTreeLabel(node: UPTreeSelectNode, keyName: string): string {
  if (keyName === 'name' && node.name !== undefined) {
    return node.name;
  }
  if (keyName === 'text' && node.text !== undefined) {
    return node.text;
  }
  if (keyName === 'label' && node.label !== undefined) {
    return node.label;
  }
  return node.label ?? node.name ?? node.text ?? '';
}

/** 节点键值读取。/ Reads the node key. */
export function upTreeKey(node: UPTreeSelectNode, keyName: string): string {
  if (keyName === 'value' && node.value !== undefined && node.value !== null) {
    return String(node.value);
  }
  if (keyName === 'id' && node.id !== undefined && node.id !== null) {
    return String(node.id);
  }
  const fallback: UPRawValue = node.id ?? node.value;
  return fallback === undefined || fallback === null ? '' : String(fallback);
}

/** 键名是否落在具名字段内。/ Whether the key name targets a modelled field. */
export function upTreeKeySupported(keyName: string): boolean {
  return keyName.length === 0 || keyName === 'label' || keyName === 'name' || keyName === 'text'
    || keyName === 'id' || keyName === 'value' || keyName === 'children' || keyName === 'disabled';
}

/** 上游 getIndentValue()：按层级乘以缩进。/ Mirrors upstream getIndentValue(). */
export function upTreeIndent(indent: number, level: number): number {
  return Math.max(0, indent) * Math.max(0, level);
}

export interface UPTreeSelectOptions {
  data?: Array<UPTreeSelectNode>;
  options?: Array<UPTreeSelectNode>;
  keys?: UPTreeSelectKeys;
  props?: UPTreeSelectKeys;
  nodeKey?: UPRawValue;
  showCheckbox?: UPRawValue;
  defaultExpandAll?: UPRawValue;
  defaultExpandedKeys?: Array<UPRawValue>;
  defaultCheckedKeys?: Array<UPRawValue>;
  expandOnClickNode?: UPRawValue;
  checkOnClickNode?: UPRawValue;
  checkStrictly?: UPRawValue;
  accordion?: UPRawValue;
  highlightCurrent?: UPRawValue;
  currentNodeKey?: UPRawValue;
  indent?: UPRawValue;
  iconSize?: UPRawValue;
  checkboxSize?: UPRawValue;
  expandIcon?: UPRawValue;
  collapseIcon?: UPRawValue;
  value?: Array<UPRawValue>;
  modelValue?: Array<UPRawValue>;
  multiple?: UPRawValue;
  max?: UPRawValue;
  expanded?: UPRawValue;
  activeColor?: string;
  customStyle?: UPStyleInput;
  diagnostics?: UPCompatibilityDiagnostics;
  onChange?: (event: UPTreeSelectChangeEvent) => void;
  onNodeClick?: (node: UPTreeSelectNode) => void;
  onCheck?: (event: UPTreeSelectCheckEvent) => void;
  onCheckChange?: (event: UPTreeSelectCheckChangeEvent) => void;
  onNodeExpand?: (node: UPTreeSelectNode) => void;
  onNodeCollapse?: (node: UPTreeSelectNode) => void;
  onCurrentChange?: (event: UPTreeSelectCurrentChangeEvent) => void;
}

export class UPTreeSelectProps {
  data: Array<UPTreeSelectNode> = [];
  options: Array<UPTreeSelectNode> = [];
  keys: UPTreeSelectKeys = {};
  /** 上游把键名映射叫 `props`，`keys` 是本端别名。/ Upstream names the mapping `props`; `keys` is the local alias. */
  props: UPTreeSelectKeys = {};
  nodeKey: UPRawValue = '';
  showCheckbox: UPRawValue = false;
  defaultExpandAll: UPRawValue = false;
  defaultExpandedKeys: Array<UPRawValue> = [];
  defaultCheckedKeys: Array<UPRawValue> = [];
  expandOnClickNode: UPRawValue = true;
  checkOnClickNode: UPRawValue = false;
  checkStrictly: UPRawValue = false;
  accordion: UPRawValue = false;
  highlightCurrent: UPRawValue = false;
  currentNodeKey: UPRawValue = '';
  indent: UPRawValue = UP_TREE_INDENT;
  iconSize: UPRawValue = UP_TREE_ICON_SIZE;
  checkboxSize: UPRawValue = UP_TREE_CHECKBOX_SIZE;
  expandIcon: UPRawValue = UP_TREE_EXPAND_ICON;
  collapseIcon: UPRawValue = UP_TREE_COLLAPSE_ICON;
  value: Array<UPRawValue> = [];
  modelValue: Array<UPRawValue> = [];
  multiple: UPRawValue = false;
  max: UPRawValue = 0;
  expanded: UPRawValue = true;
  activeColor: string = '#2979ff';
  customStyle: UPStyleInput = undefined;
  diagnostics?: UPCompatibilityDiagnostics;
  onChange?: (event: UPTreeSelectChangeEvent) => void;
  onNodeClick?: (node: UPTreeSelectNode) => void;
  onCheck?: (event: UPTreeSelectCheckEvent) => void;
  onCheckChange?: (event: UPTreeSelectCheckChangeEvent) => void;
  onNodeExpand?: (node: UPTreeSelectNode) => void;
  onNodeCollapse?: (node: UPTreeSelectNode) => void;
  onCurrentChange?: (event: UPTreeSelectCurrentChangeEvent) => void;

  constructor(options?: UPTreeSelectOptions) {
    if (options === undefined) {
      return;
    }
    this.data = options.data ?? this.data;
    this.options = options.options ?? this.options;
    this.keys = options.keys ?? this.keys;
    this.props = options.props ?? this.props;
    this.nodeKey = options.nodeKey ?? this.nodeKey;
    this.showCheckbox = options.showCheckbox ?? this.showCheckbox;
    this.defaultExpandAll = options.defaultExpandAll ?? this.defaultExpandAll;
    this.defaultExpandedKeys = options.defaultExpandedKeys ?? this.defaultExpandedKeys;
    this.defaultCheckedKeys = options.defaultCheckedKeys ?? this.defaultCheckedKeys;
    this.expandOnClickNode = options.expandOnClickNode ?? this.expandOnClickNode;
    this.checkOnClickNode = options.checkOnClickNode ?? this.checkOnClickNode;
    this.checkStrictly = options.checkStrictly ?? this.checkStrictly;
    this.accordion = options.accordion ?? this.accordion;
    this.highlightCurrent = options.highlightCurrent ?? this.highlightCurrent;
    this.currentNodeKey = options.currentNodeKey ?? this.currentNodeKey;
    this.indent = options.indent ?? this.indent;
    this.iconSize = options.iconSize ?? this.iconSize;
    this.checkboxSize = options.checkboxSize ?? this.checkboxSize;
    this.expandIcon = options.expandIcon ?? this.expandIcon;
    this.collapseIcon = options.collapseIcon ?? this.collapseIcon;
    this.value = options.value ?? this.value;
    this.modelValue = options.modelValue ?? this.modelValue;
    this.multiple = options.multiple ?? this.multiple;
    this.max = options.max ?? this.max;
    this.expanded = options.expanded ?? this.expanded;
    this.activeColor = options.activeColor ?? this.activeColor;
    this.customStyle = options.customStyle;
    this.diagnostics = options.diagnostics;
    this.onChange = options.onChange;
    this.onNodeClick = options.onNodeClick;
    this.onCheck = options.onCheck;
    this.onCheckChange = options.onCheckChange;
    this.onNodeExpand = options.onNodeExpand;
    this.onNodeCollapse = options.onNodeCollapse;
    this.onCurrentChange = options.onCurrentChange;
  }
}

/**
 * u-tree 的 HarmonyOS 原生实现：键名映射、三态勾选、手风琴展开与当前节点高亮。
 * Native u-tree with key mapping, tri-state checkboxes, accordion expansion and current highlight.
 */
@Component
export struct UPTreeSelect {
  @Prop @Watch('applyProps') props: UPTreeSelectProps = new UPTreeSelectProps();
  @State private selected: Array<UPRawValue> = [];
  @State private expandedKeys: Array<string> = [];
  @State private checkedKeys: Array<string> = [];
  @State private halfCheckedKeys: Array<string> = [];
  @State private currentKey: string = '';
  private applied: string = '';

  aboutToAppear(): void {
    this.applied = this.signature();
    this.initTree();
    this.reportBoundaries();
  }

  private applyProps(): void {
    const next: string = this.signature();
    if (next === this.applied) {
      return;
    }
    this.applied = next;
    this.initTree();
    this.reportBoundaries();
  }

  private diagnostics(): UPCompatibilityDiagnostics {
    return this.props.diagnostics ?? UP_SILENT_DIAGNOSTICS;
  }

  private signature(): string {
    return String(this.roots().length) + '|' + this.labelKey() + '|' + this.nodeKeyName()
      + '|' + String(upBoolean(this.props.defaultExpandAll, false))
      + '|' + String(upBoolean(this.props.checkStrictly, false))
      + '|' + upString(this.props.currentNodeKey, '');
  }

  private reportBoundaries(): void {
    const diagnostics: UPCompatibilityDiagnostics = this.diagnostics();
    for (const keyName of [this.labelKey(), this.childrenKey(), this.nodeKeyName(), this.disabledKey()]) {
      if (!upTreeKeySupported(keyName)) {
        diagnostics.report('UPTreeSelect', 'keys', keyName,
          'key names must target modelled node fields: label, name, text, id, value, children and disabled');
      }
    }
    diagnostics.report('UPTreeSelect', 'children', this.childrenKey(),
      'child arrays are always read from the children field because ArkTS forbids dynamic keys');
  }

  /** 上游 treeProps：`props` 与本端 `keys` 合并，`keys` 优先。/ Upstream treeProps merged with the local alias. */
  private keyMap(): UPTreeSelectKeys {
    const upstream: UPTreeSelectKeys = this.props.props;
    const local: UPTreeSelectKeys = this.props.keys;
    return {
      label: local.label ?? upstream.label,
      children: local.children ?? upstream.children,
      nodeKey: local.nodeKey ?? upstream.nodeKey,
      disabled: local.disabled ?? upstream.disabled
    };
  }

  /** 上游 treeProps.label。/ Upstream treeProps.label. */
  private labelKey(): string {
    const keyName: string = this.keyMap().label ?? UP_TREE_LABEL_KEY;
    return keyName.length > 0 ? keyName : UP_TREE_LABEL_KEY;
  }

  private childrenKey(): string {
    const keyName: string = this.keyMap().children ?? UP_TREE_CHILDREN_KEY;
    return keyName.length > 0 ? keyName : UP_TREE_CHILDREN_KEY;
  }

  private disabledKey(): string {
    const keyName: string = this.keyMap().disabled ?? UP_TREE_DISABLED_KEY;
    return keyName.length > 0 ? keyName : UP_TREE_DISABLED_KEY;
  }

  /** 上游 keyField：`nodeKey || treeProps.nodeKey || 'id'`。/ Mirrors upstream keyField. */
  private nodeKeyName(): string {
    const explicit: string = upString(this.props.nodeKey, '');
    if (explicit.length > 0) {
      return explicit;
    }
    const mapped: string = this.keyMap().nodeKey ?? '';
    return mapped.length > 0 ? mapped : UP_TREE_NODE_KEY;
  }

  /** `data` 优先，回退既有 `options`。/ Prefers data and falls back to the existing options. */
  private roots(): Array<UPTreeSelectNode> {
    return this.props.data.length > 0 ? this.props.data : this.props.options;
  }

  private childrenOf(node: UPTreeSelectNode): Array<UPTreeSelectNode> {
    return node.children ?? [];
  }

  private keyOf(node: UPTreeSelectNode): string {
    return upTreeKey(node, this.nodeKeyName());
  }

  private labelOf(node: UPTreeSelectNode): string {
    return upTreeLabel(node, this.labelKey());
  }

  private disabledOf(node: UPTreeSelectNode): boolean {
    return upBoolean(node.disabled, false);
  }

  /** 上游 initTree()：按默认展开与默认勾选建立初始状态。/ Mirrors upstream initTree(). */
  private initTree(): void {
    const expanded: Array<string> = [];
    const checked: Array<string> = [];
    this.collectInitial(this.roots(), expanded, checked);
    this.expandedKeys = expanded;
    this.checkedKeys = checked;
    this.currentKey = upString(this.props.currentNodeKey, '');
    this.selected = (this.props.modelValue.length > 0 ? this.props.modelValue : this.props.value).slice();
    if (!upBoolean(this.props.checkStrictly, false)) {
      this.syncCheckedState();
    }
  }

  private collectInitial(nodes: Array<UPTreeSelectNode>, expanded: Array<string>, checked: Array<string>): void {
    for (const node of nodes) {
      const key: string = this.keyOf(node);
      const children: Array<UPTreeSelectNode> = this.childrenOf(node);
      const openAll: boolean = upBoolean(this.props.defaultExpandAll, false);
      const legacyOpen: boolean = upBoolean(this.props.expanded, true) && this.props.data.length === 0;
      const listed: boolean = this.includesKey(this.props.defaultExpandedKeys, key);
      if (children.length > 0 && (openAll || legacyOpen || listed || upBoolean(node.expanded, false))) {
        expanded.push(key);
      }
      if (this.includesKey(this.props.defaultCheckedKeys, key) || upBoolean(node.checked, false)) {
        checked.push(key);
        if (!upBoolean(this.props.checkStrictly, false)) {
          this.collectDescendants(node, checked);
        }
      }
      if (children.length > 0) {
        this.collectInitial(children, expanded, checked);
      }
    }
  }

  private collectDescendants(node: UPTreeSelectNode, keys: Array<string>): void {
    for (const child of this.childrenOf(node)) {
      if (this.disabledOf(child)) {
        continue;
      }
      const key: string = this.keyOf(child);
      if (!keys.includes(key)) {
        keys.push(key);
      }
      this.collectDescendants(child, keys);
    }
  }

  private includesKey(keys: Array<UPRawValue>, key: string): boolean {
    for (const item of keys) {
      if (item !== null && item !== undefined && String(item) === key) {
        return true;
      }
    }
    return false;
  }

  /** 上游 collectVisibleNodes()。/ Mirrors upstream collectVisibleNodes(). */
  private visibleNodes(): Array<UPTreeSelectFlatNode> {
    const result: Array<UPTreeSelectFlatNode> = [];
    this.collectVisible(this.roots(), 0, result);
    return result;
  }

  private collectVisible(nodes: Array<UPTreeSelectNode>, level: number,
    result: Array<UPTreeSelectFlatNode>): void {
    for (const node of nodes) {
      const children: Array<UPTreeSelectNode> = this.childrenOf(node);
      const key: string = this.keyOf(node);
      const flat: UPTreeSelectFlatNode = new UPTreeSelectFlatNode();
      flat.key = key;
      flat.node = node;
      flat.depth = level;
      flat.level = level;
      flat.hasChildren = children.length > 0;
      flat.expanded = this.expandedKeys.includes(key);
      flat.checked = this.checkedKeys.includes(key);
      flat.indeterminate = this.halfCheckedKeys.includes(key);
      flat.disabled = this.disabledOf(node);
      result.push(flat);
      if (children.length > 0 && flat.expanded) {
        this.collectVisible(children, level + 1, result);
      }
    }
  }

  private findParent(target: UPTreeSelectNode, nodes: Array<UPTreeSelectNode>,
    parent?: UPTreeSelectNode): UPTreeSelectNode | undefined {
    for (const node of nodes) {
      if (node === target) {
        return parent;
      }
      const found: UPTreeSelectNode | undefined = this.findParent(target, this.childrenOf(node), node);
      if (found !== undefined) {
        return found;
      }
    }
    return undefined;
  }

  /** 上游 syncParentChecked()：自底向上重算父节点的全选与半选。/ Mirrors syncParentChecked(). */
  private syncCheckedState(): void {
    const half: Array<string> = [];
    const checked: Array<string> = this.checkedKeys.slice();
    this.syncNodes(this.roots(), checked, half);
    this.checkedKeys = checked;
    this.halfCheckedKeys = half;
  }

  private syncNodes(nodes: Array<UPTreeSelectNode>, checked: Array<string>, half: Array<string>): void {
    for (const node of nodes) {
      const children: Array<UPTreeSelectNode> = this.childrenOf(node);
      if (children.length === 0) {
        continue;
      }
      this.syncNodes(children, checked, half);
      const key: string = this.keyOf(node);
      let total: number = 0;
      let full: number = 0;
      let some: boolean = false;
      for (const child of children) {
        if (this.disabledOf(child)) {
          continue;
        }
        total += 1;
        const childKey: string = this.keyOf(child);
        if (checked.includes(childKey)) {
          full += 1;
          some = true;
        } else if (half.includes(childKey)) {
          some = true;
        }
      }
      const allChecked: boolean = total > 0 && full === total;
      const index: number = checked.indexOf(key);
      if (allChecked && index === -1) {
        checked.push(key);
      } else if (!allChecked && index !== -1) {
        checked.splice(index, 1);
      }
      const halfIndex: number = half.indexOf(key);
      if (!allChecked && some && halfIndex === -1) {
        half.push(key);
      } else if ((allChecked || !some) && halfIndex !== -1) {
        half.splice(halfIndex, 1);
      }
    }
  }

  /** 上游 toggleExpand()，含 accordion 折叠同级。/ Mirrors toggleExpand() with accordion. */
  private toggleExpand(flat: UPTreeSelectFlatNode): void {
    if (!flat.hasChildren) {
      return;
    }
    const opening: boolean = !this.expandedKeys.includes(flat.key);
    let keys: Array<string> = this.expandedKeys.slice();
    if (opening && upBoolean(this.props.accordion, false)) {
      const parent: UPTreeSelectNode | undefined = this.findParent(flat.node, this.roots(), undefined);
      const siblings: Array<UPTreeSelectNode> = parent === undefined
        ? this.roots()
        : this.childrenOf(parent);
      for (const sibling of siblings) {
        if (sibling !== flat.node) {
          const siblingKey: string = this.keyOf(sibling);
          keys = keys.filter((item: string): boolean => item !== siblingKey);
        }
      }
    }
    if (opening) {
      keys.push(flat.key);
    } else {
      keys = keys.filter((item: string): boolean => item !== flat.key);
    }
    this.expandedKeys = keys;
    if (opening) {
      this.props.onNodeExpand?.(flat.node);
      return;
    }
    this.props.onNodeCollapse?.(flat.node);
  }

  /** 上游 setNodeChecked()。/ Mirrors upstream setNodeChecked(). */
  private setChecked(flat: UPTreeSelectFlatNode, checked: boolean): void {
    let keys: Array<string> = this.checkedKeys.slice();
    const apply = (key: string, on: boolean): void => {
      const index: number = keys.indexOf(key);
      if (on && index === -1) {
        keys.push(key);
      } else if (!on && index !== -1) {
        keys.splice(index, 1);
      }
    };
    apply(flat.key, checked);
    if (!upBoolean(this.props.checkStrictly, false)) {
      const descendants: Array<string> = [];
      this.collectDescendants(flat.node, descendants);
      for (const key of descendants) {
        apply(key, checked);
      }
    }
    this.checkedKeys = keys;
    if (!upBoolean(this.props.checkStrictly, false)) {
      this.syncCheckedState();
    }
  }

  private checkedNodes(): Array<UPTreeSelectNode> {
    const nodes: Array<UPTreeSelectNode> = [];
    for (const flat of this.allNodes()) {
      if (this.checkedKeys.includes(flat.key)) {
        nodes.push(flat.node);
      }
    }
    return nodes;
  }

  private halfCheckedNodes(): Array<UPTreeSelectNode> {
    const nodes: Array<UPTreeSelectNode> = [];
    for (const flat of this.allNodes()) {
      if (this.halfCheckedKeys.includes(flat.key)) {
        nodes.push(flat.node);
      }
    }
    return nodes;
  }

  private allNodes(): Array<UPTreeSelectFlatNode> {
    const result: Array<UPTreeSelectFlatNode> = [];
    this.collectAll(this.roots(), 0, result);
    return result;
  }

  private collectAll(nodes: Array<UPTreeSelectNode>, level: number,
    result: Array<UPTreeSelectFlatNode>): void {
    for (const node of nodes) {
      const flat: UPTreeSelectFlatNode = new UPTreeSelectFlatNode();
      flat.key = this.keyOf(node);
      flat.node = node;
      flat.depth = level;
      flat.level = level;
      flat.hasChildren = this.childrenOf(node).length > 0;
      flat.disabled = this.disabledOf(node);
      result.push(flat);
      this.collectAll(this.childrenOf(node), level + 1, result);
    }
  }

  /** 上游 emitCheck()。/ Mirrors upstream emitCheck(). */
  private emitCheck(node: UPTreeSelectNode): void {
    this.props.onCheck?.({
      node: node,
      state: {
        checkedKeys: this.checkedKeys.slice(),
        checkedNodes: this.checkedNodes(),
        halfCheckedKeys: this.halfCheckedKeys.slice(),
        halfCheckedNodes: this.halfCheckedNodes()
      }
    });
  }

  private toggleCheckbox(flat: UPTreeSelectFlatNode): void {
    if (flat.disabled) {
      return;
    }
    const next: boolean = !this.checkedKeys.includes(flat.key);
    this.setChecked(flat, next);
    this.props.onCheckChange?.({ node: flat.node, checked: next });
    this.emitCheck(flat.node);
  }

  /** 上游 handleNodeClick()，并保留既有 onChange 的选中值语义。/ Mirrors handleNodeClick(). */
  private handleNodeClick(flat: UPTreeSelectFlatNode): void {
    const previousKey: string = this.currentKey;
    this.currentKey = flat.key;
    if (upBoolean(this.props.expandOnClickNode, true) && flat.hasChildren) {
      this.toggleExpand(flat);
    }
    if (upBoolean(this.props.checkOnClickNode, false) && upBoolean(this.props.showCheckbox, false)
      && !flat.disabled) {
      const next: boolean = !this.checkedKeys.includes(flat.key);
      this.setChecked(flat, next);
      this.emitCheck(flat.node);
    }
    this.props.onNodeClick?.(flat.node);
    if (previousKey !== flat.key) {
      let previous: UPTreeSelectNode | undefined = undefined;
      for (const item of this.allNodes()) {
        if (item.key === previousKey) {
          previous = item.node;
          break;
        }
      }
      this.props.onCurrentChange?.({ node: flat.node, previous: previous });
    }
    if (!flat.hasChildren) {
      this.choose(flat);
    }
  }

  /** 既有 onChange 语义：叶子节点单选或多选累积。/ The existing onChange selection semantics. */
  private choose(flat: UPTreeSelectFlatNode): void {
    if (flat.disabled) {
      return;
    }
    const identity: UPRawValue = flat.node.value ?? flat.node.id ?? flat.key;
    const multiple: boolean = upBoolean(this.props.multiple, false);
    let values: Array<UPRawValue> = multiple ? this.selected.slice() : [];
    if (multiple && this.isSelected(identity)) {
      values = values.filter((item: UPRawValue): boolean => String(item) !== String(identity));
    } else if (multiple) {
      const max: number = Math.max(0, upNumber(this.props.max, 0));
      if (max === 0 || values.length < max) {
        values.push(identity);
      }
    } else {
      values = [identity];
    }
    this.selected = values;
    this.props.onChange?.({ values: this.selected.slice(), node: flat.node });
  }

  private isSelected(value: UPRawValue): boolean {
    for (const item of this.selected) {
      if (String(item) === String(value)) {
        return true;
      }
    }
    return false;
  }

  private indentValue(): number {
    return Math.max(0, upNumber(this.props.indent, UP_TREE_INDENT) / 2);
  }

  private iconSizeValue(): number {
    return Math.max(1, upNumber(this.props.iconSize, UP_TREE_ICON_SIZE));
  }

  private checkboxSizeValue(): number {
    return Math.max(1, upNumber(this.props.checkboxSize, UP_TREE_CHECKBOX_SIZE));
  }

  private switcherIcon(flat: UPTreeSelectFlatNode): string {
    return flat.expanded
      ? upString(this.props.collapseIcon, UP_TREE_COLLAPSE_ICON)
      : upString(this.props.expandIcon, UP_TREE_EXPAND_ICON);
  }

  private rowBackground(flat: UPTreeSelectFlatNode): string {
    return upBoolean(this.props.highlightCurrent, false) && flat.key === this.currentKey
      ? UPColor.adaptive(UP_TREE_CURRENT_BACKGROUND, 'primary-light')
      : '#00000000';
  }

  private labelColor(flat: UPTreeSelectFlatNode): string {
    if (flat.disabled) {
      return '#c0c4cc';
    }
    const identity: UPRawValue = flat.node.value ?? flat.node.id ?? flat.key;
    return this.isSelected(identity)
      ? UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#2979ff')
      : '#303133';
  }

  @Builder
  private checkboxMark(flat: UPTreeSelectFlatNode) {
    Stack() {
      if (flat.checked) {
        UPIcon({
          props: new UPIconProps({
            name: 'checkbox-mark',
            size: this.checkboxSizeValue() - 4,
            color: '#ffffff'
          })
        })
      } else if (flat.indeterminate) {
        Row()
          .width(this.checkboxSizeValue() - 8)
          .height(2)
          .backgroundColor(UPColor.adaptive('#ffffff', 'card-bg-color'))
      }
    }
    .width(this.checkboxSizeValue())
    .height(this.checkboxSizeValue())
    .borderRadius(3)
    .borderWidth(1)
    .borderColor(flat.checked || flat.indeterminate
      ? UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#2979ff')
      : '#c8c9cc')
    .backgroundColor(flat.checked || flat.indeterminate
      ? UPColor.parse(this.props.activeColor, UP_DEFAULT_THEME, '#2979ff')
      : '#ffffff')
    .alignContent(Alignment.Center)
    .onClick((): void => this.toggleCheckbox(flat))
  }

  @Builder
  private defaultNodeLabel(flat: UPTreeSelectFlatNode) {
    Text(this.labelOf(flat.node))
      .fontSize(14)
      .fontColor(this.labelColor(flat))
      .layoutWeight(1)
  }

  @BuilderParam nodeBuilder: (flat: UPTreeSelectFlatNode) => void = this.defaultNodeLabel;

  build() {
    Column() {
      ForEach(this.visibleNodes(), (flat: UPTreeSelectFlatNode) => {
        Row({ space: 7 }) {
          Row() {
            if (flat.hasChildren) {
              UPIcon({
                props: new UPIconProps({
                  name: this.switcherIcon(flat),
                  size: this.iconSizeValue(),
                  color: '#606266'
                })
              })
            }
          }
          .width(18)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => this.toggleExpand(flat))
          if (upBoolean(this.props.showCheckbox, false)) {
            this.checkboxMark(flat)
          }
          this.nodeBuilder(flat)
        }
        .width('100%')
        .constraintSize({ minHeight: UP_TREE_ROW_HEIGHT })
        .padding({ left: upTreeIndent(this.indentValue(), flat.level), top: 6, bottom: 6 })
        .backgroundColor(this.rowBackground(flat))
        .borderRadius(4)
        .opacity(flat.disabled ? UP_TREE_DISABLED_OPACITY : 1)
        .alignItems(VerticalAlign.Center)
        .onClick((): void => this.handleNodeClick(flat))
      }, (flat: UPTreeSelectFlatNode): string => flat.key + '-' + String(flat.level))
    }
    .alignItems(HorizontalAlign.Start)
    .width(UPStyle.parse(this.props.customStyle).width ?? '100%')
  }
}
