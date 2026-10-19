#!/usr/bin/env python3
"""Every upstream libs/function + libs/config export must have an ArkTS counterpart."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = Path('/Users/admin/Documents/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/libs')
CORE = ROOT / 'ultra-ui/src/main/ets/core'

# upstream export -> ArkTS symbol that covers it
MAPPING = {
    # libs/function/test.js
    'email': 'upIsEmail',
    'mobile': 'upIsMobile',
    'url': 'upIsUrl',
    'date': 'upIsDate',
    'dateISO': 'upIsDateISO',
    'number': 'upIsNumeric',
    'digits': 'upIsDigits',
    'idCard': 'upIsIdCard',
    'carNo': 'upIsCarNo',
    'amount': 'upIsAmount',
    'chinese': 'upIsChinese',
    'letter': 'upIsLetter',
    'enOrNum': 'upIsEnOrNum',
    'contains': 'upContains',
    'rangeLength': 'upInRangeLength',
    'landline': 'upIsLandline',
    'code': 'upIsCode',
    'image': 'upIsImage',
    'video': 'upIsVideo',
    'empty': 'upIsEmpty',
    'string': 'upString',
    # libs/function/digit.js and calc.js
    'strip': 'UPMath.strip',
    'digitLength': 'UPMath.digitLength',
    'float2Fixed': 'UPMath.float2Fixed',
    'checkBoundary': 'UPMath.checkBoundary',
    'enableBoundaryChecking': 'UPMath.enableBoundaryChecking',
    'iteratorOperation': 'UPMath.plusAll',
    'times': 'UPMath.times',
    'plus': 'UPMath.plus',
    'minus': 'UPMath.minus',
    'divide': 'UPMath.divide',
    'round': 'UPMath.round',
    'add': 'UPMath.plus',
    'sub': 'UPMath.minus',
    'mul': 'UPMath.times',
    'div': 'UPMath.divide',
    # libs/function/index.js
    'range': 'UPMath.clamp',
    'getPx': 'UPUnit.parse',
    'rpx2px': 'UPUnit.parse',
    'addUnit': 'UPUnit.parse',
    'addStyle': 'UPStyle.parse',
    'timeFormat': 'UPFormat.timeFormat',
    'timeFrom': 'UPFormat.timeFrom',
    'trim': 'UPFormat.trim',
    'queryParams': 'UPFormat.queryParams',
    'type2icon': 'UPFormat.typeIcon',
    'priceFormat': 'UPFormat.priceFormat',
    'getDuration': 'UPFormat.durationText',
    'padZero': 'UPFormat.padZero',
    'genLightColor': 'UPGradient.lightColor',
    # libs/function/colorGradient.js
    'colorGradient': 'UPGradient.gradient',
    'hexToRgb': 'UPGradient.toRgb',
    'rgbToHex': 'UPGradient.toHex',
    'colorToRgba': 'UPGradient.toRgba',
}

# upstream exports that stay caller-owned because they need a uni-app runtime
PLATFORM_OWNED = {
    'upGetRect', 'upCreateIntersectionObserver', 'sleep', 'os', 'sys', 'getWindowInfo',
    'getDeviceInfo', 'random', 'guid', '$parent', 'deepClone', 'deepMerge', 'shallowMerge',
    'error', 'randomArray', 'toast', 'formValidate', 'getProperty', 'setProperty', 'page',
    'pages', 'getValueByPath', 'applyUniApiShims', 'jsonString', 'array', 'object',
    'objectPromise', 'func', 'promise', 'regExp', 'isEmpty',
}


def upstream_exports(relative: str) -> set[str]:
    path = UPSTREAM / relative
    assert path.is_file(), f'upstream module missing: {path}'
    text = path.read_text(encoding='utf-8')
    names: set[str] = set()
    for match in re.finditer(r'^export function ([A-Za-z_$][A-Za-z0-9_$]*)', text, re.M):
        names.add(match.group(1))
    return names


def main() -> None:
    assert UPSTREAM.is_dir(), f'upstream checkout missing: {UPSTREAM}'
    sources = ''
    for name in ('UPValidate.ets', 'UPMath.ets', 'UPFormat.ets', 'UPGradient.ets', 'UPLayers.ets',
                 'UPUnit.ets', 'UPStyle.ets', 'UPTypes.ets'):
        path = CORE / name
        assert path.is_file(), f'missing core module: {path.relative_to(ROOT)}'
        sources += path.read_text(encoding='utf-8')

    checked = 0
    gaps: list[str] = []
    for relative in ('function/test.js', 'function/digit.js', 'function/calc.js',
                     'function/index.js', 'function/colorGradient.js'):
        for name in sorted(upstream_exports(relative)):
            if name in PLATFORM_OWNED:
                continue
            target = MAPPING.get(name)
            if target is None:
                gaps.append(f'{relative}:{name} -> (unmapped)')
                continue
            checked += 1
            symbol = target.split('.')[-1]
            if symbol not in sources:
                gaps.append(f'{relative}:{name} -> {target} (missing)')

    # the zIndex and legacy colour tables are mirrored verbatim
    z_index = (UPSTREAM / 'config/zIndex.js').read_text(encoding='utf-8')
    layers = (CORE / 'UPLayers.ets').read_text(encoding='utf-8')
    for match in re.finditer(r'^\s{4}([A-Za-z]+):\s*(\d+)', z_index, re.M):
        checked += 1
        if match.group(2) not in layers:
            gaps.append(f'config/zIndex.js:{match.group(1)}={match.group(2)} (missing)')

    palette = (UPSTREAM / 'config/color.js').read_text(encoding='utf-8')
    for match in re.finditer(r"^\s{4}([A-Za-z]+):\s*'(#[0-9a-fA-F]{3,8})'", palette, re.M):
        checked += 1
        if match.group(2).lower() not in layers.lower():
            gaps.append(f'config/color.js:{match.group(1)}={match.group(2)} (missing)')

    if gaps:
        raise AssertionError('upstream utilities without an ArkTS counterpart:\n  ' + '\n  '.join(gaps))
    assert checked >= 60, f'expected at least 60 mapped utilities, checked {checked}'
    print(f'upstream utility coverage: PASS ({checked} exports, {len(PLATFORM_OWNED)} caller-owned)')


if __name__ == '__main__':
    main()
