// PA MHAD Learn articles: an English | Español review copy (.docx) for a
// fluent reviewer, who edits the Spanish column with Track Changes.
//
//   cd tool/learn_review && npm install        (once; node_modules is git-ignored)
//   node make_review_docx.js <repo root> <out.docx>
//
// One table per section, labelled with its id (the key back into
// assets/data/educational_content_es.json). Each content line is its own
// paragraph and list markers stay as typed (•, -, 1., ☐), so the Spanish
// column maps back to the JSON line for line; **bold** / *italic* become
// real bold / italic. Terms come from docs/SPANISH_STYLE.md (one source).
const fs = require('fs');
const path = require('path');
const {
  AlignmentType, BorderStyle, Document, Footer, HeadingLevel, Packer, PageNumber,
  PageOrientation, Paragraph, ShadingType, Table, TableCell, TableRow, TextRun,
  WidthType,
} = require('docx');

const [repo, out] = process.argv.slice(2);
if (!repo || !out) {
  console.error('usage: node make_review_docx.js <repo root> <out.docx>');
  process.exit(2);
}
const read = (rel) => fs.readFileSync(path.join(repo, rel), 'utf8');
const en = JSON.parse(read('assets/data/educational_content.json')).sections;
const esDoc = JSON.parse(read('assets/data/educational_content_es.json'));
const es = esDoc.sections;
const style = read('docs/SPANISH_STYLE.md');

const FONT = 'Arial';
const PAGE_W = 15840; // landscape Letter, DXA
const MARGIN = 1080; // 0.75"
const TABLE_W = PAGE_W - 2 * MARGIN; // 13680
const COL = TABLE_W / 2;
const SIZE = 20; // 10 pt
const GREY = '6B7280';
const HEAD_FILL = 'E8ECF7';
const border = { style: BorderStyle.SINGLE, size: 4, color: 'C9CFDC' };
const borders = { top: border, bottom: border, left: border, right: border };

const CATEGORIES = [
  ['intro', 'Introduction / Introducción'],
  ['faq', 'Frequently asked questions / Preguntas frecuentes'],
  ['combined', 'Combined form / Formulario Combinado'],
  ['declaration', 'Declaration / Declaración'],
  ['poa', 'Power of Attorney / Poder de Salud Mental'],
  ['glossary', 'Glossary / Glosario'],
  ['supplementary', 'Beyond the booklet / Más allá del folleto'],
  ['checklist', 'Your checklist / Su lista de verificación'],
];

// **bold** and *italic* inside one line -> runs.
function runs(text, base = {}) {
  const parts = [];
  const re = /\*\*(.+?)\*\*|\*([^*\s][^*]*?)\*/g;
  let last = 0;
  let m;
  while ((m = re.exec(text))) {
    if (m.index > last) parts.push(new TextRun({ text: text.slice(last, m.index), ...base }));
    if (m[1] !== undefined) parts.push(new TextRun({ text: m[1], bold: true, ...base }));
    else parts.push(new TextRun({ text: m[2], italics: true, ...base }));
    last = m.index + m[0].length;
  }
  if (last < text.length) parts.push(new TextRun({ text: text.slice(last), ...base }));
  return parts;
}

// One paragraph per content line; list lines get a hanging indent.
function lines(content, base = {}) {
  return content.split('\n').map((line) => {
    const list = /^(\s*)(•|-|☐|\d{1,2}[.)])\s+/.exec(line);
    const indent = list
      ? { left: 360 + 240 * Math.floor(list[1].length / 2), hanging: 360 }
      : undefined;
    return new Paragraph({
      spacing: { after: 0, line: 264 },
      indent,
      children: runs(line, { size: SIZE, font: FONT, ...base }),
    });
  });
}

const cell = (children, opts = {}) => new TableCell({
  borders,
  width: { size: COL, type: WidthType.DXA },
  margins: { top: 100, bottom: 100, left: 140, right: 140 },
  ...opts,
  children,
});

function sectionTable(id) {
  const head = (t) => cell([new Paragraph({
    children: [new TextRun({ text: t, bold: true, size: SIZE, font: FONT })],
  })], { shading: { type: ShadingType.CLEAR, fill: HEAD_FILL, color: 'auto' } });
  const title = (t) => cell([new Paragraph({
    children: runs(t, { bold: true, size: 22, font: FONT }),
  })]);
  return new Table({
    width: { size: TABLE_W, type: WidthType.DXA },
    columnWidths: [COL, COL],
    rows: [
      new TableRow({ tableHeader: true, children: [head('English'), head('Español')] }),
      new TableRow({ children: [title(en[id].title), title(es[id].title)] }),
      new TableRow({ children: [cell(lines(en[id].content)), cell(lines(es[id].content))] }),
    ],
  });
}

const p = (text, opts = {}) => new Paragraph({
  spacing: { after: 120 },
  ...opts,
  children: runs(text, { size: 22, font: FONT }),
});
const bullet = (text) => new Paragraph({
  spacing: { after: 80 },
  indent: { left: 360, hanging: 360 },
  children: runs(text, { size: 22, font: FONT }),
});

// Required terms: the table under "## Required terms" in SPANISH_STYLE.md.
const termRows = [];
let inTerms = false;
for (const line of style.split(/\r?\n/)) {
  if (line.startsWith('## ')) inTerms = line.startsWith('## Required terms');
  else if (inTerms && line.startsWith('|') && !/^\|\s*-/.test(line)) {
    const cols = line.split('|').slice(1, -1).map((c) => c.trim().replace(/`/g, ''));
    if (cols.length === 2) termRows.push(cols);
  }
}
const termTable = new Table({
  width: { size: TABLE_W, type: WidthType.DXA },
  columnWidths: [COL, COL],
  rows: termRows.map((cols, i) => new TableRow({
    tableHeader: i === 0,
    children: cols.map((c) => cell([new Paragraph({
      children: runs(c, { size: SIZE, font: FONT, bold: i === 0 }),
    })], i === 0 ? { shading: { type: ShadingType.CLEAR, fill: HEAD_FILL, color: 'auto' } } : {})),
  })),
});

const ids = Object.keys(en);
const missing = ids.filter((id) => !es[id]);
if (missing.length) {
  console.error(`Spanish is missing ${missing.length} sections: ${missing.join(', ')}`);
  process.exit(1);
}

const body = [
  new Paragraph({ heading: HeadingLevel.TITLE, children: [new TextRun('PA MHAD Learn articles in Spanish')] }),
  p(`Review copy · ${ids.length} sections · English source on the left, Spanish draft on the right.`),
  p('**Status:** draft of 18 November 2026. Machine translation of the English text; '
    + 'every section was checked by script (lists, numbers, citations), and the legal '
    + 'sections were read against the English. It has not yet been reviewed by a fluent '
    + 'Spanish speaker. The app will not show it to anyone until that review is done.'),
  new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun('For the reviewer / Para quien revisa')] }),
  p('**What to check / Qué revisar**'),
  bullet('1.\tThe Spanish says exactly what the English says. This is legal information: '
    + 'nothing added, dropped or softened (ages, time limits, "must" vs "may", exceptions). '
    + '/ El español dice exactamente lo mismo que el inglés: nada agregado, omitido ni suavizado.'),
  bullet('2.\tIt reads as natural, plain Spanish for adults in the US (usted). '
    + '/ Se lee como un español natural y sencillo para adultos en EE. UU. (usted).'),
  bullet('3.\tThe required terms below are used consistently. To change a term, add a comment '
    + 'rather than changing it in one place. / Los términos de la tabla se usan de forma '
    + 'uniforme; para cambiar uno, deje un comentario.'),
  p('**How to edit / Cómo editar**'),
  bullet('•\tTurn on Track Changes first (Review → Track Changes). / Active primero '
    + '"Control de cambios" (Revisar → Control de cambios).'),
  bullet('•\tEdit only the Spanish (right) column. Use comments for questions. / Edite solo la '
    + 'columna en español (derecha). Use comentarios para las preguntas.'),
  bullet('•\tKeep as they are: list markers (•, -, 1.), phone numbers, citations (§), codes, and '
    + 'the grey section ids, which connect each table to the app. / No cambie las viñetas, '
    + 'los teléfonos, las citas (§), los códigos ni los identificadores grises.'),
  new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun('Required terms / Términos obligatorios')] }),
  p('From the app\'s style sheet (docs/SPANISH_STYLE.md); the app\'s Spanish screens use the same terms.'),
  termTable,
];

for (const [cat, label] of CATEGORIES) {
  const inCat = ids.filter((id) => en[id].category === cat);
  if (!inCat.length) continue;
  body.push(new Paragraph({
    heading: HeadingLevel.HEADING_1,
    pageBreakBefore: true,
    children: [new TextRun(`${label} (${inCat.length})`)],
  }));
  for (const id of inCat) {
    body.push(new Paragraph({
      keepNext: true,
      spacing: { before: 240, after: 60 },
      children: [new TextRun({ text: `id: ${id}`, size: 16, color: GREY, font: FONT })],
    }));
    body.push(sectionTable(id));
  }
}

const doc = new Document({
  creator: 'PA MHAD',
  title: 'PA MHAD Learn articles in Spanish: review copy',
  styles: {
    default: {
      document: { run: { font: FONT, size: SIZE } },
      title: { run: { font: FONT, size: 40, bold: true }, paragraph: { spacing: { before: 0, after: 160 }, keepNext: true } },
      heading1: { run: { font: FONT, size: 30, bold: true, color: '152A66' }, paragraph: { spacing: { before: 240, after: 120 }, keepNext: true } },
    },
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840, orientation: PageOrientation.LANDSCAPE },
        margin: { top: MARGIN, bottom: MARGIN, left: MARGIN, right: MARGIN },
      },
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [new TextRun({
            children: ['PA MHAD Learn · Spanish review copy · page ', PageNumber.CURRENT,
              ' of ', PageNumber.TOTAL_PAGES],
            size: 16, color: GREY, font: FONT,
          })],
        })],
      }),
    },
    children: body,
  }],
});

Packer.toBuffer(doc).then((buf) => {
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, buf);
  console.log(`wrote ${out} (${Math.round(buf.length / 1024)} KB, ${ids.length} sections, ${termRows.length - 1} terms)`);
});
