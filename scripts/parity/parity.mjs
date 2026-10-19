// Byte-for-byte parity between the ArkTS core modules and the upstream uview-plus JS.
// Run via scripts/parity/run.sh, which builds the .ts shims and points SHIMS/UPSTREAM here.
const SHIMS = process.env.PARITY_SHIMS;
const UPSTREAM = process.env.PARITY_UPSTREAM;
if (!SHIMS || !UPSTREAM) {
  console.error('PARITY_SHIMS and PARITY_UPSTREAM must be set');
  process.exit(2);
}

const load = (name) => import(`${SHIMS}/${name}.ts`);
const up = (rel) => import(`${UPSTREAM}/${rel}`);

let failures = 0;
const fail = (...args) => { failures += 1; console.log('  MISMATCH', ...args); };
const close = (a, b, eps = 1e-12) => Object.is(a, b) || Math.abs(a - b) < eps;

// ---------------- UPMath vs digit.js ----------------
{
  const { UPMath } = await load('UPMath');
  const digit = await up('libs/function/digit.js');
  const pairs = [[0.1, 0.2], [1.1, 2.2], [3.3, 1.1], [0.3, 0.1], [123.456, 7.89],
                 [-0.1, 0.2], [100, 3], [0.07, 100], [2.675, 1]];
  for (const [a, b] of pairs) {
    if (!close(UPMath.plus(a, b), digit.plus(a, b))) fail('math.plus', a, b);
    if (!close(UPMath.minus(a, b), digit.minus(a, b))) fail('math.minus', a, b);
    if (!close(UPMath.times(a, b), digit.times(a, b))) fail('math.times', a, b);
    if (!close(UPMath.divide(a, b), digit.divide(a, b))) fail('math.divide', a, b);
  }
  for (const [v, d] of [[2.675, 2], [1.005, 2], [-1.005, 2], [0.5, 0], [-0.5, 0]]) {
    if (!close(UPMath.round(v, d), digit.round(v, d))) fail('math.round', v, d);
  }
  console.log('UPMath vs digit.js:', failures === 0 ? 'OK' : `FAIL(${failures})`);
}

// ---------------- UPValidate vs test.js ----------------
{
  const before = failures;
  const mine = await load('UPValidate');
  const test = await up('libs/function/test.js');
  const cases = {
    upIsEmail: ['email', ['a@b.co', 'bad@', 'x.y@z-w.com', '', 'a b@c.d']],
    upIsMobile: ['mobile', ['13800138000', '10000000000', '', '19912345678']],
    upIsIdCard: ['idCard', ['110101199003074258', '11010119900307425X', '123', '']],
    upIsCarNo: ['carNo', ['京A12345', '京AD12345', '沪AF00123', '']],
    upIsChinese: ['chinese', ['中文', '中a', '', 'abc']],
    upIsAmount: ['amount', ['12.34', '0.5', '12.345', '']],
    upIsImage: ['image', ['a.png', 'a.PNG?x=1', 'a.txt']],
    upIsVideo: ['video', ['a.mp4', 'a.MOV', 'a.txt']],
  };
  for (const [name, [upName, values]] of Object.entries(cases)) {
    for (const v of values) if (mine[name](v) !== test[upName](v)) fail('validate.' + name, JSON.stringify(v));
  }
  console.log('UPValidate vs test.js:', failures === before ? 'OK' : `FAIL(${failures - before})`);
}

// ---------------- UPFormat vs index.js ----------------
{
  const before = failures;
  const { UPFormat } = await load('UPFormat');
  const index = await up('libs/function/index.js');
  const stamps = [1000, 1700000000000, 1700000000, 946684800000];
  for (const s of stamps) for (const p of ['yyyy-mm-dd', 'yyyy-mm-dd hh:MM:ss', 'yy/mm/dd', 'hh:MM']) {
    if (UPFormat.timeFormat(s, p) !== index.timeFormat(s, p)) fail('format.timeFormat', s, p);
  }
  for (const [v, d] of [[1234.5678, 2], [1234567, 0], [0.5, 2], [-1234.5, 1]]) {
    if (UPFormat.priceFormat(v, d) !== index.priceFormat(v, d)) fail('format.priceFormat', v, d);
  }
  console.log('UPFormat vs index.js:', failures === before ? 'OK' : `FAIL(${failures - before})`);
}

// ---------------- UPGradient vs colorGradient.js ----------------
{
  const before = failures;
  const { UPGradient } = await load('UPGradient');
  const cg = await up('libs/function/colorGradient.js');
  for (const c of ['#2979ff', '#fff', 'rgb(25, 190, 107)', '#19be6b']) {
    if (UPGradient.toHex(c) !== cg.rgbToHex(c)) fail('gradient.toHex', c);
    for (const a of [0.5, 1, 0]) if (UPGradient.toRgba(c, a) !== cg.colorToRgba(c, a)) fail('gradient.toRgba', c, a);
  }
  for (const [s, e, step] of [['#2979ff', '#ffffff', 10], ['#000', '#fff', 5]]) {
    const m = UPGradient.gradient(s, e, step), t = cg.colorGradient(s, e, step);
    if (m.length !== t.length || m.some((x, i) => x !== t[i])) fail('gradient.gradient', s, e, step);
  }
  console.log('UPGradient vs colorGradient.js:', failures === before ? 'OK' : `FAIL(${failures - before})`);
}

// ---------------- UPI18n vs locale-packs.js ----------------
{
  const before = failures;
  const { UPI18n } = await load('UPI18n');
  const packs = (await up('libs/i18n/locale-packs.js')).all;
  let compared = 0;
  for (const [tag, table] of Object.entries(packs)) {
    for (const [key, value] of Object.entries(table)) {
      compared += 1;
      if (UPI18n.translate(tag, key) !== value) fail('i18n', tag, key);
    }
  }
  console.log(`UPI18n vs locale-packs.js: ${failures === before ? 'OK' : 'FAIL'} (${compared} entries)`);
}

// ---------------- UPThemeTokens vs theme.js ----------------
{
  const before = failures;
  const { UPThemeTokens } = await load('UPThemeTokens');
  const theme = await up('libs/theme/theme.js');
  const unwrap = (v) => { const m = typeof v === 'string' && v.match(/^var\(--up-light-[a-z0-9-]+,\s*(.+)\)$/); return m ? m[1].trim() : v; };
  let compared = 0;
  for (const mode of ['light', 'dark']) {
    const vars = theme.getThemeVars(mode);
    for (const token of UPThemeTokens.names()) {
      compared += 1;
      const raw = vars[`--up-${token}`];
      const want = mode === 'light' ? unwrap(raw) : raw;
      if (UPThemeTokens.value(mode, token) !== want) fail('theme', mode, token);
    }
  }
  console.log(`UPThemeTokens vs theme.js: ${failures === before ? 'OK' : 'FAIL'} (${compared} values)`);
}

// ---------------- UPValidator vs async-validator.js ----------------
{
  const before = failures;
  const { UPValidator } = await load('UPValidator');
  const SchemaMod = await up('libs/util/async-validator.js');
  const Schema = SchemaMod.default;
  Schema.warning = function () {};
  const upstreamMsg = (field, rule, value, present) => {
    const source = present ? { [field]: value } : {};
    let message = '';
    new Schema({ [field]: rule }).validate(source, (errors) => {
      if (Array.isArray(errors) && errors.length > 0) message = errors[0].message;
    });
    return message;
  };
  const mineMsg = (field, rule, value, present) => {
    const values = present ? [{ field, value }] : [];
    const result = new UPValidator([{ field, rules: [rule] }]).validate(values);
    return result.errors.length > 0 ? result.errors[0].message : '';
  };
  const cases = [
    [{ required: true }, { required: true, type: 'string' }, ['', 'abc'], true],
    [{ type: 'email' }, { type: 'email' }, ['a@b.co', 'bad@'], true],
    [{ type: 'number', min: 10, max: 20 }, { type: 'number', min: 10, max: 20 }, [5, 15, 25], true],
    [{ type: 'string', min: 2, max: 4 }, { type: 'string', min: 2, max: 4 }, ['a', 'abc', 'abcde'], true],
    [{ type: 'array', len: 2 }, { type: 'array', len: 2 }, [['a'], ['a', 'b']], true],
    [{ pattern: '^\\d+$' }, { pattern: '^\\d+$' }, ['123', 'a1'], true],
    [{ type: 'string', whitespace: true }, { type: 'string', whitespace: true }, ['   ', 'a'], true],
  ];
  for (const [upRule, mineRule, values, present] of cases) {
    for (const v of values) if (mineMsg('name', mineRule, v, present) !== upstreamMsg('name', upRule, v, present)) {
      fail('validator', JSON.stringify(upRule), JSON.stringify(v));
    }
  }
  // enum needs the reserved-word rename
  for (const v of ['a', 'z']) {
    if (mineMsg('name', { type: 'enum', enumValues: ['a', 'b'] }, v, true)
      !== upstreamMsg('name', { type: 'enum', enum: ['a', 'b'] }, v, true)) fail('validator.enum', v);
  }
  console.log('UPValidator vs async-validator.js:', failures === before ? 'OK' : `FAIL(${failures - before})`);
}

// ---------------- UPThemeManager mode/token behaviour ----------------
{
  const before = failures;
  const { UPThemeManager } = await load('UPThemeManager');
  const { UPColor } = await load('UPColor');
  const theme = await up('libs/theme/theme.js');
  // brand colours are mode-invariant; neutral names shift with the mode
  UPThemeManager.setMode('light');
  const brandLight = ['primary', 'success', 'warning', 'error', 'info'].map((n) => UPColor.parse(n));
  UPThemeManager.setMode('dark');
  const brandDark = ['primary', 'success', 'warning', 'error', 'info'].map((n) => UPColor.parse(n));
  if (brandLight.some((c, i) => c !== brandDark[i])) fail('theme.brandInvariant');
  const darkVars = theme.getThemeVars('dark');
  for (const [name, token] of [['main', 'main-color'], ['content', 'content-color'],
                               ['tips', 'tips-color'], ['light', 'light-color']]) {
    if (UPColor.parse(name) !== darkVars[`--up-${token}`]) fail('theme.neutralDark', name);
  }
  UPThemeManager.setMode('light');
  console.log('UPThemeManager mode/token:', failures === before ? 'OK' : `FAIL(${failures - before})`);
}

console.log(failures === 0 ? '\nparity: OK' : `\nparity: FAILED (${failures})`);
process.exit(failures === 0 ? 0 : 1);
