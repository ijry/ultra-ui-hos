#!/usr/bin/env python3
"""Every upstream component <slot> must have a matching ArkTS builder entry."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = Path('/Users/admin/Documents/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components')
COMPONENTS = ROOT / 'ultra-ui/src/main/ets/components'

ALIASES = {
    'u-datetime-picker': ['UPDatePicker', 'UPTimePicker'],
    'u-dragsort': ['UPDragSort'],
    'u-float-button': ['UPFloatingBubble'],
    'u-table2': ['UPTable2'],
    'u-toast': ['UPToastHost'],
    'u-tree': ['UPTreeSelect'],
}
SKIPPED = ('u-action-sheet-data', 'u-picker-data')

# Scoped `default` slots are implemented as per-row builders, so they carry a row-shaped name.
SCOPED_DEFAULTS = ('itemBuilder', 'nodeBuilder', 'tabBuilder', 'columnBuilder', 'rowBuilder')


def camel(name: str) -> str:
    parts = name.replace('u-', '', 1).split('-')
    return 'UP' + ''.join(part[:1].upper() + part[1:] for part in parts)


def builder_name(slot: str) -> str:
    """`right-icon` -> rightIconBuilder, `toolbar-bottom` -> toolbarBottomBuilder."""
    parts = re.split(r'[-_]', slot)
    camelized = parts[0] + ''.join(part[:1].upper() + part[1:] for part in parts[1:])
    return camelized + 'Builder'


def upstream_slots(directory: Path) -> set[str]:
    """Slot names declared in the directory's primary .vue file."""
    primary = directory / f'{directory.name}.vue'
    if not primary.is_file():
        return set()
    text = primary.read_text(encoding='utf-8')
    names: set[str] = set()
    for match in re.finditer(r'<slot\b([^>]*)>', text):
        named = re.search(r'name="([^"]+)"', match.group(1))
        names.add(named.group(1) if named else 'default')
    return names


def implemented(names: list[str]) -> set[str]:
    """Builder entries exposed either as @BuilderParam or as a `*Builder` prop field."""
    builders: set[str] = set()
    for name in names:
        path = COMPONENTS / f'{name}.ets'
        if not path.is_file():
            continue
        text = path.read_text(encoding='utf-8')
        for match in re.finditer(r'@BuilderParam\s+([A-Za-z_][A-Za-z0-9_]*)', text):
            builders.add(match.group(1))
        for pattern in (rf'export class {name}Props \{{(.*?)\n\}}',
                        rf'export interface {name}Options \{{(.*?)\n\}}'):
            block = re.search(pattern, text, re.S)
            if block is None:
                continue
            for field in re.finditer(r'\b([A-Za-z_][A-Za-z0-9_]*Builder)\s*\??\s*[:=]', block.group(1)):
                builders.add(field.group(1))
    return builders


def main() -> None:
    assert UPSTREAM.is_dir(), f'upstream checkout missing: {UPSTREAM}'
    rows: list[tuple[str, str, list[str], int]] = []
    checked = 0
    for directory in sorted(UPSTREAM.iterdir()):
        if not directory.is_dir() or not directory.name.startswith('u-') or directory.name in SKIPPED:
            continue
        targets = ALIASES.get(directory.name, [camel(directory.name)])
        have = {item.lower() for item in implemented(targets)}
        gap: list[str] = []
        want = upstream_slots(directory)
        for slot in sorted(want):
            expected = builder_name(slot)
            candidates = {expected}
            # the unnamed slot is the component body; both spellings are accepted
            if slot == 'default':
                candidates |= {'contentBuilder', 'defaultBuilder'}
                candidates |= set(SCOPED_DEFAULTS)
            if any(item.lower() in have for item in candidates):
                continue
            gap.append(f'{slot} -> {expected}')
        checked += 1
        if gap:
            rows.append((directory.name, '+'.join(targets), gap, len(want)))

    assert checked >= 138, f'expected at least 138 upstream UI directories, scanned {checked}'
    if rows:
        report: list[str] = []
        for upstream_name, name, gap, want_count in sorted(rows, key=lambda item: -len(item[2])):
            report.append(f'{upstream_name} ({name}): {len(gap)}/{want_count} -> ' + ', '.join(gap))
        raise AssertionError('upstream slots without a matching builder:\n  ' + '\n  '.join(report))
    print(f'upstream slot coverage: PASS ({checked} directories)')


if __name__ == '__main__':
    main()
