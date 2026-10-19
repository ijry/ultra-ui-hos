#!/usr/bin/env python3
"""Every upstream component emit must have a matching ArkTS on* callback."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = Path('/Users/admin/Documents/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components')
COMPONENTS = ROOT / 'ultra-ui/src/main/ets/components'
CONTROLLERS = ROOT / 'ultra-ui/src/main/ets/controllers'

ALIASES = {
    'u-datetime-picker': ['UPDatePicker', 'UPTimePicker'],
    'u-dragsort': ['UPDragSort'],
    'u-float-button': ['UPFloatingBubble'],
    'u-table2': ['UPTable2'],
    'u-toast': ['UPToastHost'],
    'u-tree': ['UPTreeSelect'],
}
SKIPPED = ('u-action-sheet-data', 'u-picker-data')


def camel(name: str) -> str:
    parts = name.replace('u-', '', 1).split('-')
    return 'UP' + ''.join(p[:1].upper() + p[1:] for p in parts)


def handler_name(event: str) -> str:
    """`select-city` -> onSelectCity, `update:modelValue` -> onModelValueChange candidates."""
    core = event.replace('update:', '')
    parts = re.split(r'[-_:]', core)
    camelized = parts[0] + ''.join(p[:1].upper() + p[1:] for p in parts[1:])
    return 'on' + camelized[:1].upper() + camelized[1:]


def upstream_emits(directory: Path) -> set[str]:
    names: set[str] = set()
    for candidate in sorted(directory.glob('*.vue')):
        if candidate.name != f'{directory.name}.vue':
            continue
        text = candidate.read_text(encoding='utf-8')
        for match in re.finditer(r"emits\s*:\s*\[(.*?)\]", text, re.S):
            for item in re.finditer(r"'([^']+)'|\"([^\"]+)\"", match.group(1)):
                names.add(item.group(1) or item.group(2))
        # $emit('name', ...) calls also count
        for match in re.finditer(r"\$emit\(\s*'([^']+)'", text):
            names.add(match.group(1))
        for match in re.finditer(r"\$emit\(\s*\"([^\"]+)\"", text):
            names.add(match.group(1))
    return names


def implemented(names: list[str]) -> set[str]:
    handlers: set[str] = set()
    for name in names:
        for base in (COMPONENTS / f'{name}.ets', CONTROLLERS / f'{name}.ets'):
            if not base.is_file():
                continue
            text = base.read_text(encoding='utf-8')
            for pattern in (rf'export class {name}Props \{{(.*?)\n\}}',
                            rf'export interface {name}Options \{{(.*?)\n\}}'):
                match = re.search(pattern, text, re.S)
                if match is None:
                    continue
                for field in re.finditer(r'\b(on[A-Z][A-Za-z0-9]*)\s*\??\s*[:=]', match.group(1)):
                    handlers.add(field.group(1))
    return handlers


def main() -> None:
    assert UPSTREAM.is_dir(), f'upstream checkout is required at {UPSTREAM}'
    rows: list[tuple[str, str, list[str], int]] = []
    checked = 0
    for directory in sorted(UPSTREAM.iterdir()):
        if not directory.is_dir() or not directory.name.startswith('u-') or directory.name in SKIPPED:
            continue
        targets = ALIASES.get(directory.name, [camel(directory.name)])
        have = implemented(targets)
        have_lower = {h.lower() for h in have}
        want = upstream_emits(directory)
        gap = []
        for event in sorted(want):
            expected = handler_name(event)
            candidates = {expected}
            core = event.replace('update:', '')
            camelized = ''.join(part[:1].upper() + part[1:] for part in re.split(r'[-_:]', core))
            candidates.add('on' + camelized + 'Change')
            # upstream v-model pairs: `input` and `update:modelValue` both mean "value changed"
            if event in ('input', 'update:modelValue', 'update:value'):
                candidates |= {'onChange', 'onModelValueChange', 'onInput'}
            if event == 'update:checked':
                candidates |= {'onChange', 'onCheckedChange'}
            if event in ('update:show', 'update:visible'):
                candidates |= {'onShowChange', 'onClose'}
            if event == 'update:scrolling':
                candidates |= {'onScrollingChange', 'onScroll'}
            if event == 'update:fileList':
                candidates |= {'onFileListChange', 'onChoose'}
            if event in ('update:currentPage', 'update:pageSize'):
                candidates |= {'onPageChange', 'onChange'}
            # `closed` is the post-animation twin of `close`
            if event == 'closed':
                candidates |= {'onClose', 'onClosed'}
            if event == 'open':
                candidates |= {'onOpen', 'onShowChange'}
            # `$uGridItem` is a global uni event-bus broadcast, not a component emit
            if event == '$uGridItem':
                candidates |= {'onGridItemBroadcast'}
            if any(item.lower() in have_lower for item in candidates):
                continue
            gap.append(f'{event} -> {expected}')
        checked += 1
        if gap:
            rows.append((directory.name, '+'.join(targets), gap, len(want)))

    assert checked >= 138, f'expected at least 138 upstream UI directories, scanned {checked}'
    if rows:
        report: list[str] = []
        for upstream_name, name, gap, want_count in sorted(rows, key=lambda item: -len(item[2])):
            report.append(f'{upstream_name} ({name}): {len(gap)}/{want_count} -> ' + ', '.join(gap))
        raise AssertionError('upstream emits without a matching callback:\n  ' + '\n  '.join(report))
    print(f'upstream event coverage: PASS ({checked} directories)')


if __name__ == '__main__':
    main()
