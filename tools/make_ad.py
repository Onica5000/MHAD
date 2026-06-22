"""Generates a one-page product advertisement PDF for the MHAD app and saves it
to the user's Desktop. Pure presentation — run with the repo's Python."""
import os
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import (
    BaseDocTemplate, Frame, PageTemplate, Paragraph, Spacer, Table, TableStyle,
)
from reportlab.lib.enums import TA_CENTER, TA_LEFT

# ---- Brand palette ----------------------------------------------------------
TEAL = colors.HexColor("#0F766E")
TEAL_DK = colors.HexColor("#115E59")
TEAL_LT = colors.HexColor("#CCFBF1")
TEAL_BG = colors.HexColor("#F0FDFA")
ACCENT = colors.HexColor("#14B8A6")
INK = colors.HexColor("#0F172A")
SLATE = colors.HexColor("#475569")
LIGHT = colors.HexColor("#64748B")

OUT = os.path.join(os.path.expanduser("~"), "Desktop",
                   "Forethought-MHAD-advertisement.pdf")

PRODUCT = "Forethought"
TAGLINE = "The simplest way to create your Pennsylvania Mental Health Advance Directive."

# ---- Styles -----------------------------------------------------------------
def style(name, **kw):
    base = dict(fontName="Helvetica", fontSize=10, leading=14, textColor=INK)
    base.update(kw)
    return ParagraphStyle(name, **base)

st_headline = style("hl", fontName="Helvetica-Bold", fontSize=23, leading=26,
                    textColor=INK)
st_hook = style("hook", fontSize=11.5, leading=16.5, textColor=SLATE)
st_section = style("sec", fontName="Helvetica-Bold", fontSize=12.5, leading=15,
                   textColor=TEAL_DK)
st_body = style("body", fontSize=10, leading=14, textColor=SLATE)
st_pillar_h = style("ph", fontName="Helvetica-Bold", fontSize=11.5, leading=14,
                    textColor=colors.white, alignment=TA_LEFT)
st_pillar_b = style("pb", fontSize=9.3, leading=12.5, textColor=colors.white)
st_step_n = style("sn", fontName="Helvetica-Bold", fontSize=15, leading=16,
                  textColor=TEAL, alignment=TA_CENTER)
st_step_b = style("sb", fontSize=9.6, leading=12.8, textColor=SLATE)
st_feat = style("feat", fontSize=9.6, leading=13, textColor=INK)
st_cta = style("cta", fontName="Helvetica-Bold", fontSize=14.5, leading=18,
               textColor=colors.white, alignment=TA_CENTER)
st_cta_sub = style("ctas", fontSize=10, leading=13, textColor=TEAL_LT,
                   alignment=TA_CENTER)
st_foot = style("foot", fontSize=7.4, leading=9.5, textColor=LIGHT,
                alignment=TA_CENTER)


def header_footer(canvas, doc):
    canvas.saveState()
    w, h = letter
    # Top brand band
    canvas.setFillColor(TEAL)
    canvas.rect(0, h - 1.15 * inch, w, 1.15 * inch, fill=1, stroke=0)
    canvas.setFillColor(ACCENT)
    canvas.rect(0, h - 1.15 * inch, w, 0.07 * inch, fill=1, stroke=0)
    canvas.setFillColor(colors.white)
    canvas.setFont("Helvetica-Bold", 27)
    canvas.drawString(0.7 * inch, h - 0.66 * inch, PRODUCT)
    canvas.setFont("Helvetica-Oblique", 11)
    canvas.setFillColor(TEAL_LT)
    canvas.drawString(0.72 * inch, h - 0.92 * inch, TAGLINE)
    # tiny kicker top-right
    canvas.setFont("Helvetica-Bold", 8.5)
    canvas.setFillColor(colors.white)
    canvas.drawRightString(w - 0.7 * inch, h - 0.62 * inch, "FREE  -  IN YOUR BROWSER")
    canvas.drawRightString(w - 0.7 * inch, h - 0.80 * inch, "PC & MOBILE  -  PA ACT 194")
    canvas.restoreState()


def pillar(title, body):
    p = Table(
        [[Paragraph(title, st_pillar_h)],
         [Paragraph(body, st_pillar_b)]],
        colWidths=[2.18 * inch],
    )
    p.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), TEAL),
        ("LINEABOVE", (0, 0), (-1, 0), 3, ACCENT),
        ("LEFTPADDING", (0, 0), (-1, -1), 11),
        ("RIGHTPADDING", (0, 0), (-1, -1), 11),
        ("TOPPADDING", (0, 0), (0, 0), 11),
        ("BOTTOMPADDING", (0, 1), (0, 1), 12),
        ("TOPPADDING", (0, 1), (0, 1), 3),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ]))
    return p


def step(num, body):
    t = Table(
        [[Paragraph(num, st_step_n), Paragraph(body, st_step_b)]],
        colWidths=[0.42 * inch, 1.93 * inch],
    )
    t.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (0, 0), 0),
        ("RIGHTPADDING", (0, 0), (0, 0), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 0),
    ]))
    return t


def feat_row(text):
    sq = Table([[""]], colWidths=[0.10 * inch], rowHeights=[0.10 * inch])
    sq.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, -1), ACCENT)]))
    return Table(
        [[sq, Paragraph(text, st_feat)]],
        colWidths=[0.22 * inch, 3.0 * inch],
        style=TableStyle([
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("TOPPADDING", (0, 0), (0, 0), 3),
            ("LEFTPADDING", (0, 0), (0, 0), 0),
            ("TOPPADDING", (1, 0), (1, 0), 0),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ]),
    )


def build():
    doc = BaseDocTemplate(
        OUT, pagesize=letter,
        leftMargin=0.7 * inch, rightMargin=0.7 * inch,
        topMargin=1.35 * inch, bottomMargin=0.55 * inch,
    )
    frame = Frame(doc.leftMargin, doc.bottomMargin,
                  doc.width, doc.height, id="main",
                  leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0)
    doc.addPageTemplates([PageTemplate(id="main", frames=[frame],
                                       onPage=header_footer)])

    s = []
    s.append(Paragraph("Your care. Your choices.<br/>Even on your hardest days.",
                       st_headline))
    s.append(Spacer(1, 8))
    s.append(Paragraph(
        "A mental health crisis can take away your voice right when you need it "
        "most. A <b>Mental Health Advance Directive</b> is how you keep it - a "
        "legal document that tells doctors and loved ones which treatments you "
        "want, which you don't, and who you trust to decide. Pennsylvania's "
        "Act 194 makes it <b>binding</b>. " + PRODUCT + " makes it <b>easy.</b>",
        st_hook))
    s.append(Spacer(1, 12))

    # Problem -> solution shaded box
    box = Table([[Paragraph(
        "<b>The official form is 50+ pages of legal language.</b> Most people "
        "start it, feel overwhelmed, and give up - so their wishes stay in "
        "their head, where they can't help anyone. " + PRODUCT + " turns that "
        "intimidating form into a friendly, step-by-step conversation you can "
        "finish in one sitting.", st_body)]], colWidths=[doc.width])
    box.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), TEAL_BG),
        ("LINEBEFORE", (0, 0), (0, -1), 3, ACCENT),
        ("LEFTPADDING", (0, 0), (-1, -1), 12),
        ("RIGHTPADDING", (0, 0), (-1, -1), 12),
        ("TOPPADDING", (0, 0), (-1, -1), 9),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 9),
    ]))
    s.append(box)
    s.append(Spacer(1, 14))

    # Three pillars
    pillars = Table([[
        pillar("Effortless",
               "A guided wizard in plain English - no legalese, no guesswork. "
               "Finish in one sitting."),
        pillar("Intelligent",
               "Snap a photo, upload a record, or just talk - the AI fills "
               "the form and checks it for contradictions before you sign."),
        pillar("Private &amp; Free",
               "Your personal details stay on your device. The AI is free. No "
               "account, no fees - right in your browser."),
    ]], colWidths=[2.34 * inch] * 3)
    pillars.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (0, 0), 0),
        ("RIGHTPADDING", (-1, 0), (-1, 0), 0),
        ("LEFTPADDING", (1, 0), (-1, 0), 8),
    ]))
    s.append(pillars)
    s.append(Spacer(1, 16))

    # How it works + Features, two columns
    how = [
        Paragraph("How it works", st_section),
        Spacer(1, 7),
        step("1", "<b>Tell it your wishes</b> - type, upload a document, or "
                  "speak them out loud."),
        Spacer(1, 7),
        step("2", "<b>Review the AI's draft</b> - every field in plain "
                  "language, with a built-in consistency check."),
        Spacer(1, 7),
        step("3", "<b>Print your directive</b> - a pixel-perfect, "
                  "PA-compliant PDF, ready to sign and share."),
    ]
    feats = [
        Paragraph("Everything it does", st_section),
        Spacer(1, 7),
        feat_row("Plain-language wizard for all three PA form types"),
        feat_row("Snap-to-fill from a photo, PDF, or <b>audio recording</b>"),
        feat_row("Dictate your wishes - AI transcribes medical terms"),
        feat_row("A free AI assistant answers questions as you go"),
        feat_row("Consistency check catches contradictions before you sign"),
        feat_row("Crisis plan, medications, allergies &amp; agent designation"),
        feat_row("Built-in Learn library explains every choice"),
    ]
    two = Table([[how, feats]], colWidths=[3.05 * inch, 4.05 * inch])
    two.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (0, 0), 0),
        ("LEFTPADDING", (1, 0), (1, 0), 18),
        ("RIGHTPADDING", (-1, 0), (-1, 0), 0),
    ]))
    s.append(two)
    s.append(Spacer(1, 16))

    # CTA banner
    cta = Table([[Paragraph("Make your voice impossible to ignore.", st_cta)],
                 [Paragraph("Create your Mental Health Advance Directive today "
                            "- free, in your browser.", st_cta_sub)]],
                colWidths=[doc.width])
    cta.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), TEAL_DK),
        ("LINEABOVE", (0, 0), (-1, 0), 4, ACCENT),
        ("TOPPADDING", (0, 0), (0, 0), 14),
        ("BOTTOMPADDING", (0, 1), (0, 1), 14),
        ("TOPPADDING", (0, 1), (0, 1), 2),
    ]))
    s.append(cta)
    s.append(Spacer(1, 10))
    s.append(Paragraph(
        PRODUCT + " helps you complete Pennsylvania's Mental Health Advance "
        "Directive (Act 194 of 2004). It provides information, not legal "
        "advice - consult an attorney for guidance specific to your situation. "
        "Free to use - works on PC and mobile browsers.", st_foot))

    doc.build(s)
    print("WROTE", OUT)


if __name__ == "__main__":
    build()
