# Spanish style: app strings and Learn articles

One source for how PA MHAD writes Spanish: `lib/l10n/app_es.arb` (the screens) and
`assets/data/educational_content_es.json` (the Learn articles). A translator, a reviewer,
or an AI helper works from this page. Readers are Spanish-speaking adults in the US, some
under stress, some with limited formal schooling.

## Voice

- Plain, warm, neutral Latin American / US Spanish; no regionalisms.
- Formal **usted** when addressing the reader. Where the English speaks as "I" (wording from
  the form), keep the first person.
- Legal facts stay exact: ages, numbers of witnesses, time limits ("two years" = "dos años"),
  who may or may not do something, "must" vs "may", and every exception ("unless", "except").
  Never add, drop, or soften a legal statement.

## Typography

- ¿...? and ¡...!; quotation marks “ ”; ellipsis … (one character).
- Sentence case for titles and labels ("Médico tratante", not "Médico Tratante"), except
  proper names and the form names below.
- Digits stay digits. Dates the Spanish way: "1 de junio de 2024".
- Unchanged from English: URLs, emails, phone numbers, statute citations (§ 5822), ICD codes.

## Required terms

| English | Spanish |
|---|---|
| PA Mental Health Advance Directive | Directiva Anticipada de Salud Mental de PA |
| mental health advance directive (generic) | directiva anticipada de salud mental |
| MHAD (the abbreviation) / your directive | DASM / su directiva |
| Combined form | formulario Combinado |
| Mental Health Declaration / Declaration | Declaración de Salud Mental / Declaración |
| Mental Health Care Power of Attorney (this law's document) | Poder de Salud Mental |
| a general health care power of attorney (Chapter 54) | poder para atención médica |
| NEVER "poder notarial" | it implies a notary; PA directives need no notary |
| agent / alternate agent | agente / agente alternativo |
| principal (the person who makes the directive) | la persona que hizo la directiva ("el declarante" only where a text defines the legal term) |
| witness | testigo |
| revoke / revocation | revocar / revocación |
| amend | enmendar |
| execute (formally sign) the directive | firmar (glossary headword: "Firmar (formalizar)") |
| capacity / incapacity / incapable | capacidad / incapacidad / incapaz |
| competence (legal status) | competencia (legal) |
| attending physician | médico tratante |
| mental health care provider | proveedor de atención de salud mental |
| mental health treatment professional | profesional de tratamiento de salud mental |
| mental health care | atención de salud mental |
| guardian | tutor |
| involuntary commitment | internamiento involuntario |
| psychotropic medication | medicamento psicotrópico |
| electroconvulsive therapy (ECT) | terapia electroconvulsiva (TEC) |
| experimental studies / drug trials | estudios experimentales / ensayos de medicamentos |
| substituted judgment | juicio sustituto |
| least restrictive alternative | alternativa menos restrictiva |
| treatment over objection | tratamiento en contra de su objeción |
| restraints (physical or chemical) / seclusion | sujeción (física o química) / aislamiento |
| psychosurgery | psicocirugía |
| 988 Suicide & Crisis Lifeline | 988 Línea de Prevención del Suicidio y Crisis |
| Pennsylvania | Pensilvania (the abbreviation "PA" stays) |
| Section 302 / Section 303 | Sección 302 / Sección 303 |

## Names

- Organization, hospital, program and website names stay in English (PA Protection &
  Advocacy, Disabilities Law Project, PMHCA, NAMI). A short Spanish explanation may follow in
  parentheses the first time.
- A law's name: translated, with the official English name in parentheses the first time,
  e.g. "Ley de Procedimientos de Salud Mental (Mental Health Procedures Act)";
  "Act 194 of 2004" = "Ley 194 de 2004 (Act 194)".
- A phrase quoted from the law: translated, with the English in parentheses, e.g.
  “deberá cumplir” (“shall comply”).

## Checked by tests

`arb_typography_test` (screens) and `learn_es_test` (articles: same sections as the English,
lists and bold spans kept, phones / URLs / citations / codes unchanged, “ ” and …, never
"poder notarial", and a stale-translation check against the English each section came from).
