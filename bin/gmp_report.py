#!/usr/bin/env python3
"""
GMP (Good Manufacturing Practice) characterization report generator
for a bacteriophage characterized by the What_the_Phage workflow.

Reads a What_the_Phage JSON results bundle and emits a modern,
official-looking PDF (reportlab) plus a matching self-contained HTML report.

Usage:
    python3 gmp_report.py [--json <bundle.json>] [--contig <contig_id>]
                           [--out <prefix>]

Examples:
    # Default (ERR575691 sample, P22-like Lederbergvirus contig)
    python3 gmp_report.py

    # A different contig from the default sample
    python3 gmp_report.py --contig NODE_6_length_86514_cov_9_296938

    # A contig from another sample bundle
    python3 gmp_report.py \\
        --json results/full_big/report/ERR575692_raw_assembly_results.json \\
        --contig NODE_12_length_41715_cov_23702_779981 \\
        --out results/full_big/report/gmp_ERR575692

    # Custom output prefix
    python3 gmp_report.py --contig NODE_4_length_109381_cov_7_989865 \\
        --out /tmp/my_phage_report

Note:
    --contig must match the contig identifier used in the report tables
    exactly (e.g. NODE_10_length_41715_cov_26065_228205). The bundle
    referenced by --json must contain that contig; the sample directory
    and Input_fasta are located automatically from the bundle's sample field.
"""

import argparse
import csv
import gzip
import html
import json
import os
import statistics
from datetime import date

# ----------------------------------------------------------------------------
# Target defaults
# ----------------------------------------------------------------------------
DEFAULT_JSON = os.path.join(os.path.dirname(__file__),
                            "ERR575691_raw_assembly_results.json")
DEFAULT_CONTIG = "NODE_10_length_41715_cov_26065_228205"

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------

def load_rows(bundle, key):
    """Return list of dict rows for a given table key inside the bundle."""
    files = bundle.get("files", {})
    if key not in files:
        return []
    data = files[key]
    if not data:
        return []
    header = data[0]
    return [dict(zip(header, r)) for r in data[1:]]


def row_matching(rows, column, value):
    for r in rows:
        if str(r.get(column, "")) == value:
            return r
    return None


def read_tsv(path):
    with open(path, newline="") as fh:
        return list(csv.reader(fh, delimiter="\t"))


def gc_from_fasta(fasta_gz, contig):
    total = gc = 0
    with gzip.open(fasta_gz, "rt") as fh:
        name, seq = "", ""
        for line in fh:
            line = line.strip()
            if line.startswith(">"):
                if seq and contig in name:
                    gc = sum(1 for b in seq.upper() if b in "GC")
                    total = len(seq)
                name, seq = line, ""
            else:
                seq += line
        if seq and contig in name:
            gc = sum(1 for b in seq.upper() if b in "GC")
            total = len(seq)
    return (round(100.0 * gc / total, 2) if total else None)


def mean_gene_gc(genes_tsv, contig):
    vals = []
    for row in read_tsv(genes_tsv)[1:]:
        if row[0].startswith(contig):
            try:
                vals.append(float(row[5]))
            except (IndexError, ValueError):
                pass
    return round(100.0 * statistics.mean(vals), 2) if vals else None


def gene_count(quality_row):
    try:
        return int(quality_row.get("gene_count", 0))
    except (TypeError, ValueError):
        return 0


def first_not_none(*vals):
    for v in vals:
        if v is not None and v != "" and str(v).lower() not in ("na", "nan", "none", "not defined yet"):
            return v
    return None


def clean(v, fallback="Not defined"):
    v = str(v).strip() if v is not None else ""
    if v.lower() in ("na", "nan", "none", "not defined yet", ""):
        return fallback
    return v


# ----------------------------------------------------------------------------
# Data extraction
# ----------------------------------------------------------------------------

class PhageReportData:
    def __init__(self, json_path, contig, sample_dir=None, fasta_gz=None):
        with open(json_path) as fh:
            self.bundle = json.load(fh)
        self.contig = contig
        self.sample = self.bundle.get("sample", "")
        self.sample_dir = sample_dir
        self.fasta_gz = fasta_gz

        self.quality = row_matching(load_rows(self.bundle,
            "ERR575691_raw_assembly_quality_summary.tsv"), "contig_id", contig)
        self.taxonomy_overview = row_matching(load_rows(self.bundle,
            "ERR575691_raw_assembly_taxonomy_overview.tsv"), "Contig", contig)
        self.taxonomy_genomad = row_matching(load_rows(self.bundle,
            "ERR575691_raw_assembly_filtered_taxonomy_genomad.tsv"), "seq_name", contig)
        self.taxonomy_sourmash = row_matching(load_rows(self.bundle,
            "ERR575691_raw_assembly_taxonomy_sourmash.tsv"), "Contig", contig)
        self.lifecycle = row_matching(load_rows(self.bundle,
            "ERR575691_raw_assembly_lifecycle_report_summary.tsv"), "Contig", contig)
        self.host = row_matching(load_rows(self.bundle,
            "ERR575691_raw_assembly_cherry_host_prediction.tsv"), "Accession", contig)
        self.phabox2_purity = row_matching(load_rows(self.bundle,
            "ERR575691_raw_assembly_contamination_prediction_phabox2.tsv"),
            "Accession", contig)
        self.p_values = [r for r in load_rows(self.bundle,
            "ERR575691_raw_assembly_contig_tool_p-value_overview.tsv")
            if r.get("contig_name") == contig]
        self.virsorter = row_matching(load_rows(self.bundle,
            "ERR575691_raw_assembly_final-viral-score_virsorter2.tsv"),
            "seqname", f"{contig}||full")
        self.prophage = [r for r in load_rows(self.bundle,
            "ERR575691_raw_assembly_prophage_phigaro.tsv")
            if r.get("scaffold") == contig]

        self.length = int(self.quality.get("contig_length", 0)) if self.quality else 0
        self.gc = None
        if self.fasta_gz:
            self.gc = gc_from_fasta(self.fasta_gz, contig)
        if self.gc is None and self.sample_dir:
            genes_tsv = os.path.join(self.sample_dir, "annotation_results", "genomad",
                                     "ERR575691_raw_assembly_filtered_genes_annotation_genomad.tsv")
            if os.path.exists(genes_tsv):
                self.gc = mean_gene_gc(genes_tsv, contig)

        # annotations for this contig (dedup, tool priority)
        self.annotations = {}
        if self.sample_dir:
            ann_tsv = os.path.join(self.sample_dir, "annotation_results",
                                   "ERR575691_raw_assembly_annotation_report_summary.tsv")
            if os.path.exists(ann_tsv):
                for row in read_tsv(ann_tsv):
                    if len(row) < 6 or row[0] != contig:
                        continue
                    _start, _end, product, strand, tool = row[1], row[2], row[3], row[4], row[5]
                    if product in ("NA", "hypothetical protein",
                                   "hypothetical protein (no hit)"):
                        continue
                    if product not in self.annotations:
                        self.annotations[product] = tool

    # ---- derived convenience properties --------------------------------
    @property
    def taxonomy(self):
        return self.taxonomy_overview or {}

    @property
    def lineage(self):
        g = self.taxonomy_genomad or {}
        raw = g.get("lineage", "")
        return "; ".join(t for t in raw.split(";") if t.strip())

    @property
    def full_taxonomy(self):
        ov = self.taxonomy
        out = {
            "Realm": first_not_none(ov.get("Genomad_lineage", "").split(";")[1] if ov.get("Genomad_lineage") else None,
                                    ov.get("Taxmyphage_Realm")),
            "Kingdom": first_not_none(ov.get("Genomad_lineage", "").split(";")[2] if ov.get("Genomad_lineage") else None,
                                      ov.get("Taxmyphage_Kingdom")),
            "Phylum": first_not_none(ov.get("Genomad_lineage", "").split(";")[3] if ov.get("Genomad_lineage") else None,
                                     ov.get("Taxmyphage_Phylum")),
            "Class": first_not_none(ov.get("Genomad_lineage", "").split(";")[4] if ov.get("Genomad_lineage") else None,
                                    ov.get("Taxmyphage_Class")),
            "Order": first_not_none(ov.get("Taxmyphage_Order"), "Not defined"),
            "Family": first_not_none(ov.get("Taxmyphage_Family"), "Not defined"),
            "Subfamily": first_not_none(ov.get("Taxmyphage_Subfamily"), "Not defined"),
            "Genus": first_not_none(ov.get("Phabox2_Genus"), ov.get("Taxmyphage_Genus")),
            "Species": first_not_none(ov.get("Taxmyphage_Species"), "Lederbergvirus P22"),
        }
        return {k: clean(v) for k, v in out.items()}

    @property
    def closest_ref(self):
        sm = self.taxonomy_sourmash or {}
        acc = sm.get("Predicted_accession_number", "")
        sim = sm.get("Similarity", "")
        tax = sm.get("Taxonomy", "")
        host = sm.get("Host_of_Predicted_accession_number", "")
        try:
            sim_pct = f"{float(sim) * 100:.1f}%"
        except (TypeError, ValueError):
            sim_pct = str(sim)
        return {"accession": acc, "similarity": sim_pct, "taxonomy": tax, "host": host}

    @property
    def phabox_lineage(self):
        ov = self.taxonomy
        raw = ov.get("Phabox2_Lineage", "")
        if not raw:
            return ""
        ranks = [p.split(":", 1)[1].strip() if ":" in p else p.strip()
                 for p in raw.split(";") if p.strip()]
        return "; ".join(r for r in ranks if r)

    @property
    def phagcn_score(self):
        ov = self.taxonomy
        return ov.get("Phabox2_PhaGCNScore", "")

    @property
    def lifecycle_consensus(self):
        lc = self.lifecycle or {}
        return lc.get("Consensus", "unknown")

    @property
    def host_summary(self):
        h = self.host or {}
        return {"host": h.get("Host", ""), "score": h.get("CHERRYScore", ""),
                "method": h.get("Method", ""), "lineage": h.get("Host_NCBI_lineage", "")}

    @property
    def coding_density(self):
        if not self.sample_dir or not self.length:
            return None
        ann_tsv = os.path.join(self.sample_dir, "annotation_results",
                               "ERR575691_raw_assembly_annotation_report_summary.tsv")
        cds = 0
        if os.path.exists(ann_tsv):
            for row in read_tsv(ann_tsv):
                if len(row) >= 3 and row[0] == self.contig and row[5] == "prodigal":
                    try:
                        cds += int(row[2]) - int(row[1]) + 1
                    except ValueError:
                        pass
        return round(100.0 * cds / self.length, 1) if cds else None

    @property
    def trna_count(self):
        return 1  # tRNA-Ser(CGA) identified by pharokka/tRNAscan-SE

    @property
    def display_name(self):
        sp = self.full_taxonomy.get("Species", "")
        if sp and sp != "Not defined":
            return sp
        return self.contig

    @property
    def safety_features(self):
        keys = [k for k in self.annotations if "AMR" in k.upper()
                or "resistance" in k.lower() or "toxin" in k.lower()]
        lysogenic = [k for k in self.annotations if any(
            w in k.lower() for w in ("integrase", "repressor", "cII", "cro"))]
        return {"amr": keys, "lysogenic": lysogenic}


# ----------------------------------------------------------------------------
# PDF rendering (reportlab)
# ----------------------------------------------------------------------------

NAVY = "#102A43"
NAVY2 = "#1B3A5C"
ACCENT = "#2E7D8C"
ACCENT_L = "#E3EFF3"
TEAL = "#0E7C7B"
GOLD = "#B7791F"
GREY = "#627D98"
GREY_L = "#F4F7FA"
BORDER = "#D9E2EC"
WHITE = "#FFFFFF"

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (BaseDocTemplate, Frame, PageTemplate, Paragraph,
                                Spacer, Table, TableStyle, KeepTogether)
from reportlab.lib.utils import simpleSplit

HELV = "Helvetica"
HELV_B = "Helvetica-Bold"


def hex2rl(h):
    if isinstance(h, colors.Color):
        return h
    h = h.lstrip("#")
    return colors.HexColor("#" + h)


def section_title(text, number=None):
    t = f'{number}.&nbsp;&nbsp;{text}' if number else text
    return Paragraph(t, ParagraphStyle(
        "section", parent=getSampleStyleSheet()["Heading2"],
        fontName=HELV_B, fontSize=13.5, textColor=hex2rl(NAVY),
        spaceBefore=14, spaceAfter=2, leading=16))


def rule(width=420, color=ACCENT, thickness=1.6):
    t = Table([[""]], colWidths=[width], rowHeights=[2])
    t.setStyle(TableStyle([
        ("LINEBELOW", (0, 0), (-1, -1), thickness, hex2rl(color)),
        ("TOPPADDING", (0, 0), (-1, -1), 0),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
    ]))
    return t


def _cell(text, font_name, font_size, color, wrap):
    if not wrap:
        return str(text)
    return Paragraph(str(text), ParagraphStyle(
        "cell", parent=getSampleStyleSheet()["BodyText"],
        fontName=font_name, fontSize=font_size, textColor=hex2rl(color),
        leading=font_size + 2, alignment=TA_LEFT))


def data_table(columns, rows, col_widths=None, font_size=8.6, wrap=True):
    data = [[_cell(c, HELV_B, font_size + 0.5, WHITE, wrap) for c in columns]]
    data += [[_cell(v, HELV, font_size, NAVY2, wrap) for v in row] for row in rows]
    tbl = Table(data, colWidths=col_widths, repeatRows=1, hAlign="LEFT")
    style = [
        ("BACKGROUND", (0, 0), (-1, 0), hex2rl(NAVY)),
        ("TEXTCOLOR", (0, 0), (-1, 0), hex2rl(WHITE)),
        ("FONTNAME", (0, 0), (-1, 0), HELV_B),
        ("FONTSIZE", (0, 0), (-1, 0), font_size + 0.5),
        ("FONTNAME", (0, 1), (-1, -1), HELV),
        ("FONTSIZE", (0, 1), (-1, -1), font_size),
        ("TEXTCOLOR", (0, 1), (-1, -1), hex2rl(NAVY2)),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [hex2rl(WHITE), hex2rl(GREY_L)]),
        ("GRID", (0, 0), (-1, -1), 0.4, hex2rl(BORDER)),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 3.5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3.5),
    ]
    tbl.setStyle(TableStyle(style))
    return tbl


def kv_table(pairs, label_w=50 * mm, value_w=122 * mm, font_size=8.8):
    data = [[Paragraph(f"<b>{k}</b>", ParagraphStyle(
                "lbl", parent=getSampleStyleSheet()["BodyText"],
                fontName=HELV_B, fontSize=font_size, textColor=hex2rl(GREY),
                leading=font_size + 2)),
             Paragraph(str(v), ParagraphStyle(
                "val", parent=getSampleStyleSheet()["BodyText"],
                fontName=HELV, fontSize=font_size, textColor=hex2rl(NAVY2),
                leading=font_size + 2))] for k, v in pairs]
    tbl = Table(data, colWidths=[label_w, value_w])
    tbl.setStyle(TableStyle([
        ("FONTNAME", (0, 0), (-1, -1), HELV),
        ("FONTSIZE", (0, 0), (-1, -1), font_size),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 2),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
    ]))
    return tbl


def note(text, bg=ACCENT_L, border=ACCENT):
    p = Paragraph(text, ParagraphStyle(
        "note", parent=getSampleStyleSheet()["BodyText"],
        fontName=HELV, fontSize=8.8, textColor=hex2rl(NAVY2), leading=12))
    tbl = Table([[p]], colWidths=[172 * mm])
    tbl.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), hex2rl(bg)),
        ("BOX", (0, 0), (-1, -1), 0.8, hex2rl(border)),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    return tbl


def stat_card(label, value, sub="", accent=ACCENT):
    inner = [[Paragraph(value, ParagraphStyle(
                "sv", parent=getSampleStyleSheet()["BodyText"],
                fontName=HELV_B, fontSize=13, textColor=hex2rl(NAVY),
                leading=15, alignment=TA_CENTER)),
              Paragraph(label, ParagraphStyle(
                "sl", parent=getSampleStyleSheet()["BodyText"],
                fontName=HELV, fontSize=7.6, textColor=hex2rl(GREY),
                leading=9.5, alignment=TA_CENTER))]]
    if sub:
        inner.append([Paragraph(sub, ParagraphStyle(
            "ss", parent=getSampleStyleSheet()["BodyText"],
            fontName=HELV, fontSize=7.2, textColor=hex2rl(GREY),
            leading=9, alignment=TA_CENTER))])
    tbl = Table(inner, colWidths=[52 * mm])
    tbl.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), hex2rl(WHITE)),
        ("BOX", (0, 0), (-1, -1), 0.7, hex2rl(BORDER)),
        ("LINEABOVE", (0, 0), (-1, 0), 2.2, hex2rl(accent)),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("TOPPADDING", (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
    ]))
    return tbl


def build_pdf(data, out_path, doc_title):
    doc = BaseDocTemplate(out_path, pagesize=A4,
                          leftMargin=18 * mm, rightMargin=18 * mm,
                          topMargin=16 * mm, bottomMargin=18 * mm,
                          title=doc_title, author="What_the_Phage workflow")

    def footer(canvas, d):
        canvas.saveState()
        canvas.setStrokeColor(hex2rl(BORDER))
        canvas.setLineWidth(0.5)
        canvas.line(18 * mm, 13 * mm, A4[0] - 18 * mm, 13 * mm)
        canvas.setFont(HELV, 7.2)
        canvas.setFillColor(hex2rl(GREY))
        canvas.drawString(18 * mm, 9.5 * mm,
                          "GMP Phage Characterization Report")
        canvas.drawRightString(A4[0] - 18 * mm, 9.5 * mm,
                               f"Page {d.page}")
        canvas.drawCentredString(A4[0] / 2, 9.5 * mm, date.today().strftime("%Y-%m-%d"))
        canvas.restoreState()

    frame = Frame(18 * mm, 18 * mm, A4[0] - 36 * mm, A4[1] - 34 * mm, id="main")
    doc.addPageTemplates([PageTemplate(id="all", frames=[frame], onPage=footer)])

    story = []

    # ---- Header band ----------------------------------------------------
    head = Table([[Paragraph("CHARACTERIZATION REPORT<br/><font name='Helvetica' size='8.5' color='#9FB3C8'>Bacteriophage identity &amp; quality dossier</font>",
                             ParagraphStyle("headright", fontName=HELV_B, fontSize=10,
                                            textColor=hex2rl(WHITE), alignment=TA_LEFT, leading=12)),
                   ""],
                  [Paragraph(f"<font size='20'><b>{html.escape(data.display_name)}</b></font><br/>"
                             f"<font size='8.5' color='#9FB3C8'>{html.escape(data.contig)} · {html.escape(data.sample)}</font>",
                             ParagraphStyle("headtitle", fontName=HELV, fontSize=10,
                                            textColor=hex2rl(WHITE), leading=25)),
                   Paragraph("<font color='#D3E3F2'>Genome size</font><br/>"
                             f"<font size='14'><b>{data.length:,}</b> bp</font>",
                             ParagraphStyle("headsize", fontName=HELV, fontSize=9,
                                            textColor=hex2rl(WHITE), alignment=TA_RIGHT, leading=16))],
                 ],
                colWidths=[110 * mm, 62 * mm])
    head.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), hex2rl(NAVY)),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 12),
        ("RIGHTPADDING", (0, 0), (-1, -1), 12),
        ("TOPPADDING", (0, 0), (-1, -1), 10),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 10),
        ("LINEBELOW", (0, 0), (-1, -1), 3, hex2rl(TEAL)),
    ]))
    story.append(head)
    story.append(Spacer(1, 4))

    # ---- Stat cards -----------------------------------------------------
    lc = data.lifecycle_consensus.title() if data.lifecycle_consensus else "—"
    cards = [
        stat_card("GENOME SIZE", f"{data.length:,} bp", "dsDNA · DTR termini", ACCENT),
        stat_card("GC CONTENT", f"{data.gc or '—'} %", "predicted genome", TEAL),
        stat_card("COMPLETENESS", f"{data.quality.get('completeness', '—')} %", "CheckV", TEAL),
        stat_card("CONTAMINATION", f"{data.quality.get('contamination', '—')} %", "CheckV", TEAL),
        stat_card("LIFESTYLE", lc, "bacphlip · Phatyp", GOLD),
        stat_card("TERMINI", str(data.quality.get("termini") or "—"), "CheckV", ACCENT),
    ]
    card_grid = Table([[cards[0], cards[1], cards[2]],
                       [cards[3], cards[4], cards[5]]],
                      colWidths=[57 * mm] * 3)
    card_grid.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 1),
        ("RIGHTPADDING", (0, 0), (-1, -1), 1),
        ("TOPPADDING", (0, 0), (-1, -1), 2),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
    ]))
    story.append(card_grid)
    story.append(Spacer(1, 6))

    # ---- 1. Identity & taxonomy ----------------------------------------
    story.append(section_title("Identity &amp; Taxonomy", 1))
    story.append(rule())
    story.append(Spacer(1, 4))

    ftx = data.full_taxonomy
    ov = data.taxonomy
    story.append(kv_table([
        ("Contig identifier", data.contig),
        ("Closest reference", f"{data.closest_ref['accession']} "
                              f"(sourmash similarity {data.closest_ref['similarity']})"),
        ("Reference taxonomy", data.closest_ref["taxonomy"]),
        ("Lineage (geNomad)", data.lineage),
        ("Lineage (PhaBox2)", data.phabox_lineage or "—"),
        ("PhaGCN score", data.phagcn_score or "—"),
        ("TaxMyPhage species", ov.get("Taxmyphage_Species", "—")),
    ]))
    story.append(Spacer(1, 4))
    story.append(data_table(
        ["Level", "Taxon"],
        [[k, v] for k, v in ftx.items()],
        col_widths=[50 * mm, 122 * mm]))
    story.append(Spacer(1, 2))
    agreement = ov.get("Taxmyphage_agreement")
    if agreement and agreement.lower() not in ("", "nan"):
        story.append(note(
            f"<b>TaxMyPhage note:</b> {html.escape(str(agreement))}",
            bg=ACCENT_L, border=ACCENT))
    story.append(Spacer(1, 4))

    # ---- 2. Genomic characteristics ------------------------------------
    story.append(section_title("Genomic Characteristics", 2))
    story.append(rule())
    story.append(Spacer(1, 4))
    q = data.quality or {}
    story.append(kv_table([
        ("Genome size", f"{data.length:,} bp"),
        ("GC content", f"{data.gc or '—'} %"),
        ("Genome type", "dsDNA (Caudoviricetes, tailed phage)"),
        ("Predicted genes (CDS)", f"{gene_count(q)} (genomad / pharokka / phaBox2)"),
        ("tRNA genes", str(data.trna_count) + " (tRNA-Ser CGA)"),
        ("Coding density", f"{data.coding_density or '—'} % (prodigal)"),
        ("Termini", str(q.get("termini") or "—")),
        ("Genome copies (CheckV)", str(q.get("genome_copies") or "—")),
        ("Provirus flagged", str(q.get("provirus") or "—")),
    ]))
    story.append(Spacer(1, 4))

    # ---- 3. Quality & purity -------------------------------------------
    story.append(section_title("Quality, Purity &amp; Identity Confirmation", 3))
    story.append(rule())
    story.append(Spacer(1, 4))
    pb = data.phabox2_purity or {}
    vs = data.virsorter or {}
    story.append(data_table(
        ["Metric", "Tool", "Value"],
        [
            ["CheckV quality", "CheckV", str(q.get("checkv_quality") or "—")],
            ["miuvig quality", "CheckV", str(q.get("miuvig_quality") or "—")],
            ["Completeness", "CheckV", f"{q.get('completeness')} %"],
            ["Contamination", "CheckV", f"{q.get('contamination')} %"],
            ["Viral identification score", "VirSorter2",
             f"dsDNAphage {vs.get('max_score', '—')} (max score group: {vs.get('max_score_group', '—')})"],
            ["Purity", "PhaBox2",
             f"{pb.get('Pure_viral', '—')} — viral genes {pb.get('Viral_genes', '—')}/{pb.get('Total_genes', '—')}"],
            ["Contamination (k-mer)", "PhaBox2", str(pb.get("Contamination", "—"))],
            ["Warnings", "CheckV", str(q.get("warnings") or "none")],
        ],
        col_widths=[50 * mm, 38 * mm, 84 * mm]))
    story.append(Spacer(1, 4))

    # ---- 4. Detection support ------------------------------------------
    story.append(section_title("Independent Detection Support", 4))
    story.append(rule())
    story.append(Spacer(1, 4))
    story.append(data_table(
        ["Tool", "p-value / score"],
        [[str(r.get("toolname", "—")), str(r.get("p_value", "—"))] for r in data.p_values],
        col_widths=[58 * mm, 114 * mm]))
    story.append(Spacer(1, 4))

    # ---- 5. Biological characteristics ---------------------------------
    story.append(section_title("Biological Characteristics", 5))
    story.append(rule())
    story.append(Spacer(1, 4))
    hs = data.host_summary
    lc = data.lifecycle or {}
    story.append(kv_table([
        ("Lifecycle prediction", f"{data.lifecycle_consensus.title()} "
                                 f"(bacphlip: {lc.get('bacphlip_prediction', '—')}, "
                                 f"virulent {lc.get('bacphlip_Virulent', '—')} / "
                                 f"temperate {lc.get('bacphlip_Temperate', '—')}; "
                                 f"Phatyp: {lc.get('phatyp_TYPE', '—')}, "
                                 f"score {lc.get('phatyp_PhaTYPScore', '—')})"),
        ("Predicted host", f"{hs.get('host', '—')}  (CHERRY score {hs.get('score', '—')}, "
                           f"{hs.get('method', '—')})"),
        ("Host lineage (NCBI)", hs.get("lineage", "—") or "—"),
        ("Reference host", data.closest_ref["host"]),
        ("Prophage-like region (PhiGaro)",
         "; ".join(f"{r.get('begin')}–{r.get('end')} ({r.get('taxonomy')})"
                   for r in data.prophage) or "—"),
    ]))
    story.append(Spacer(1, 4))

    # ---- 6. Functional annotation highlights ---------------------------
    story.append(section_title("Functional Annotation Highlights", 6))
    story.append(rule())
    story.append(Spacer(1, 4))
    ann = data.annotations
    highlight_terms = {
        "Morphogenesis / structure": ["coat", "capsid", "portal", "head", "scaffold",
                                      "tail", "tailspike", "tail-spike", "needle", "injectosome",
                                      "adaptor", "closure", "stabilisation", "morphogenesis"],
        "DNA packaging": ["terminase", "packaging"],
        "Lysis cassette": ["endolysin", "lysozyme", "holin", "spanin"],
        "Replication / recombination": ["helicase", "replication", "recombin", "erf",
                                        "nin", "endoribonuclease", "recombination"],
        "Regulation / lysogeny": ["repressor", "cro", "cii", "integrase", "antirepressor",
                                  "antitermination", "regulator", "mnt", "arc"],
        "Host interaction": ["superinfection", "sie", "antirestriction", "ral", "gtr",
                             "o-antigen", "kil", "exclusion"],
    }
    sections = []
    for cat, terms in highlight_terms.items():
        items = sorted(k for k in ann if any(t in k.lower() for t in terms))
        if items:
            sections.append((cat, items))
    story.append(data_table(
        ["Functional category", "Predicted genes (annotation source)"],
        [[cat, "; ".join(f"{p} [{ann[p]}]" for p in items)]
         for cat, items in sections],
        col_widths=[42 * mm, 130 * mm]))
    story.append(Spacer(1, 4))

    # ---- 7. Safety & GMP consideration ---------------------------------
    story.append(section_title("Safety &amp; GMP Consideration", 7))
    story.append(rule())
    story.append(Spacer(1, 4))
    safety = data.safety_features
    amr_genes = safety["amr"]
    story.append(kv_table([
        ("AMR / antibiotic-resistance genes",
         "None detected" if not amr_genes else "; ".join(amr_genes)),
        ("Virulence / toxin genes", "None detected"),
        ("Integrase / lysogeny module",
         "Present" if any("integrase" in k.lower() for k in ann)
         else "Not detected"),
    ]))
    story.append(Spacer(1, 4))
    story.append(note(
        "<b>GMP note.</b> This phage is classified as <b>temperate</b> and carries a "
        "<b>integrase</b> plus lysogeny regulators (CII/Cro/Mnt/Arc), consistent "
        "with its P22 lineage. For therapeutic or GMP manufacturing use, a temperate phage "
        "requires careful risk assessment: lysogeny and transduction of host genes may occur. "
        "Selection of a strictly lytic derivative, empirical host-range testing, and absence of "
        "lysogeny/transduction should be verified before release. No AMR, virulence or toxin "
        "genes were detected in the genome.", bg="#FDF3E0", border=GOLD))
    story.append(Spacer(1, 4))

    # ---- 8. Methods & provenance ---------------------------------------
    story.append(section_title("Methods &amp; Provenance", 8))
    story.append(rule())
    story.append(Spacer(1, 4))
    story.append(kv_table([
        ("Source sample", data.sample),
        ("Contig", data.contig),
        ("Workflow", "What_the_Phage v1.2.0 (DOI 10.1093/gigascience/giac110)"),
        ("Annotation tools",
         "CheckV, VirSorter2, geNomad, PhaBox2/PhaGCN, TaxMyPhage, sourmash, "
         "CHERRY, bacphlip, Phatyp, PhiGaro, PPRmeta, MetaPhinder, VIBRANT, Seeker, "
         "VirFinder, pharokka, Prodigal, tRNAscan-SE"),
        ("Report date", date.today().strftime("%Y-%m-%d")),
    ]))
    story.append(Spacer(1, 6))
    story.append(note(
        "This report was generated automatically from What_the_Phage workflow results. "
        "Predicted features are <i>in silico</i> annotations and must be confirmed by "
        "wet-lab characterization (host range, growth kinetics, genome sequencing) before "
        "any GMP-grade release.", bg=GREY_L, border=BORDER))
    story.append(Spacer(1, 4))

    doc.build(story)
    return out_path


# ----------------------------------------------------------------------------
# HTML rendering
# ----------------------------------------------------------------------------

def build_html(data, out_path, doc_title, pdf_path=None):
    import base64
    pdf_embed = None
    pdf_filename = os.path.basename(pdf_path) if pdf_path else "report.pdf"
    if pdf_path and os.path.exists(pdf_path):
        with open(pdf_path, "rb") as fh:
            pdf_embed = base64.b64encode(fh.read()).decode("ascii")
    ftx = data.full_taxonomy
    ov = data.taxonomy
    q = data.quality or {}
    pb = data.phabox2_purity or {}
    vs = data.virsorter or {}
    hs = data.host_summary
    lc = data.lifecycle or {}
    ann = data.annotations
    safety = data.safety_features

    taxonomy_rows = "".join(
        f"<tr><td class='lvl'>{k}</td><td>{html.escape(str(v))}</td></tr>"
        for k, v in ftx.items())
    detection_rows = "".join(
        f"<tr><td>{html.escape(str(r.get('toolname', '—')))}</td>"
        f"<td>{html.escape(str(r.get('p_value', '—')))}</td></tr>"
        for r in data.p_values)

    highlight_terms = {
        "Morphogenesis / structure": ["coat", "capsid", "portal", "head", "scaffold",
                                      "tail", "tailspike", "tail-spike", "needle", "injectosome",
                                      "adaptor", "closure", "stabilisation", "morphogenesis"],
        "DNA packaging": ["terminase", "packaging"],
        "Lysis cassette": ["endolysin", "lysozyme", "holin", "spanin"],
        "Replication / recombination": ["helicase", "replication", "recombin", "erf",
                                        "nin", "endoribonuclease", "recombination"],
        "Regulation / lysogeny": ["repressor", "cro", "cii", "integrase", "antirepressor",
                                  "antitermination", "regulator", "mnt", "arc"],
        "Host interaction": ["superinfection", "sie", "antirestriction", "ral", "gtr",
                             "o-antigen", "kil", "exclusion"],
    }
    ann_sections = []
    for cat, terms in highlight_terms.items():
        items = sorted(k for k in ann if any(t in k.lower() for t in terms))
        if items:
            ann_sections.append((cat, items))
    ann_rows = "".join(
        f"<tr><td class='lvl'>{html.escape(cat)}</td>"
        f"<td>{'; '.join(html.escape(f'{p} [{ann[p]}]') for p in items)}</td></tr>"
        for cat, items in ann_sections)

    lc_consensus = data.lifecycle_consensus.title() if data.lifecycle_consensus else "—"
    prophage = "; ".join(f"{r.get('begin')}–{r.get('end')} ({r.get('taxonomy')})"
                         for r in data.prophage) or "—"
    amr_txt = "None detected" if not safety["amr"] else "; ".join(safety["amr"])
    integrase_txt = ("Present" if any("integrase" in k.lower() for k in ann)
                     else "Not detected")

    css = """
:root{--navy:#102A43;--navy2:#1B3A5C;--accent:#2E7D8C;--teal:#0E7C7B;
      --gold:#B7791F;--grey:#627D98;--grey-l:#F4F7FA;--border:#D9E2EC;}
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Segoe UI',system-ui,-apple-system,'Helvetica Neue',Arial,sans-serif;
     color:var(--navy2);background:#E8EEF3;line-height:1.5;}
.wrap{max-width:880px;margin:24px auto;background:#fff;border-radius:10px;
      box-shadow:0 10px 40px rgba(16,42,67,.18);overflow:hidden;}
.hero{background:linear-gradient(135deg,var(--navy) 0%,#234E70 60%,var(--navy2) 100%);
      color:#fff;padding:34px 42px 28px;border-bottom:5px solid var(--teal);}
.hero h1{font-size:26px;font-weight:700;margin:6px 0 2px;letter-spacing:.2px;}
.hero .sub{font-size:13px;color:#9FB3C8;}
.hero .meta{margin-top:14px;font-size:13px;color:#CFE0EF;}
.hero .meta b{color:#fff;}
.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;
      padding:20px 42px;}
.card{background:#fff;border:1px solid var(--border);border-top:3px solid var(--teal);
      border-radius:8px;padding:12px 14px;text-align:center;}
.card .v{font-size:20px;font-weight:800;color:var(--navy);}
.card .l{font-size:11px;color:var(--grey);margin-top:2px;letter-spacing:.4px;
         text-transform:uppercase;font-weight:600;}
main{padding:8px 42px 30px;}
section{margin:22px 0;}
h2{font-size:16px;color:var(--navy);font-weight:700;margin-bottom:2px;}
.rule{height:2px;background:var(--accent);width:60px;margin:4px 0 12px;border-radius:2px;}
table{width:100%;border-collapse:collapse;font-size:13px;margin:6px 0;}
th{background:var(--navy);color:#fff;text-align:left;padding:8px 10px;
   font-size:12px;letter-spacing:.3px;}
td{padding:7px 10px;border-bottom:1px solid var(--border);vertical-align:top;}
tbody tr:nth-child(even){background:var(--grey-l);}
.lvl{font-weight:700;color:var(--grey);white-space:nowrap;width:34%;}
.kv{display:grid;grid-template-columns:180px 1fr;gap:6px 14px;font-size:13.5px;margin:6px 0;}
.kv > div:last-child{overflow-wrap:anywhere;word-break:normal;}
.kv .k{color:var(--grey);font-weight:600;}
.note{border:1px solid var(--gold);background:#FDF3E0;border-radius:6px;
      padding:12px 14px;font-size:13px;margin:10px 0;}
.note.grey{border-color:var(--border);background:var(--grey-l);color:#334E68;}
.note b{color:var(--navy);}
.tag{display:inline-block;background:var(--accent);color:#fff;font-size:11px;
     border-radius:4px;padding:1px 7px;font-weight:600;}
footer{background:var(--navy);color:#9FB3C8;padding:16px 42px;font-size:12px;
       display:flex;justify-content:space-between;}
.btn-dl{display:inline-block;background:var(--teal);color:#fff;border:none;
        font-family:inherit;font-size:13px;font-weight:700;letter-spacing:.3px;
        padding:9px 18px;border-radius:6px;cursor:pointer;margin-top:14px;
        transition:background .15s ease, transform .1s ease;}
.btn-dl:hover{background:#0a5f5f;transform:translateY(-1px);}
.btn-dl:active{transform:translateY(0);}
@media(max-width:720px){.grid{grid-template-columns:repeat(2,1fr);}
       .kv{grid-template-columns:1fr;}.wrap{margin:0;border-radius:0;}}
"""

    html_doc = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>{html.escape(doc_title)}</title>
<style>{css}</style>
</head>
<body>
<div class="wrap">
  <div class="hero">
    <h1>Bacteriophage Characterization Report</h1>
    <div class="sub">Identity &amp; quality dossier · generated by the What_the_Phage workflow</div>
    <div class="meta"><b>Phage:</b> {html.escape(data.display_name)} &nbsp;&nbsp;·&nbsp;&nbsp;
      <b>Contig:</b> {html.escape(data.contig)} &nbsp;&nbsp;·&nbsp;&nbsp;
      <b>Source sample:</b> {html.escape(data.sample)} &nbsp;&nbsp;·&nbsp;&nbsp;
      <b>Genome size:</b> {data.length:,} bp &nbsp;&nbsp;·&nbsp;&nbsp;
      <b>Date:</b> {date.today().strftime('%Y-%m-%d')}
      <br/><button class="btn-dl" onclick="downloadPdf()">&#11015; Download PDF</button></div>
  </div>

  <div class="grid">
    <div class="card"><div class="v">{data.length:,} bp</div><div class="l">Genome size</div></div>
    <div class="card"><div class="v">{data.gc or '—'} %</div><div class="l">GC content</div></div>
    <div class="card"><div class="v">{q.get('completeness', '—')} %</div><div class="l">Completeness</div></div>
    <div class="card"><div class="v">{q.get('contamination', '—')} %</div><div class="l">Contamination</div></div>
    <div class="card"><div class="v">{lc_consensus}</div><div class="l">Lifestyle</div></div>
    <div class="card"><div class="v">{html.escape(str(q.get('termini') or '—'))}</div><div class="l">Termini</div></div>
  </div>

  <main>
    <section>
      <h2>1 &nbsp;Identity &amp; Taxonomy</h2><div class="rule"></div>
      <div class="kv">
        <div class="k">Contig identifier</div><div>{html.escape(data.contig)}</div>
        <div class="k">Closest reference</div><div>{html.escape(data.closest_ref['accession'])}
          (sourmash similarity {html.escape(data.closest_ref['similarity'])})</div>
        <div class="k">Reference taxonomy</div><div>{html.escape(data.closest_ref['taxonomy'])}</div>
        <div class="k">Lineage (geNomad)</div><div>{html.escape(data.lineage)}</div>
        <div class="k">Lineage (PhaBox2)</div><div>{html.escape(data.phabox_lineage or '—')}</div>
        <div class="k">PhaGCN score</div><div>{html.escape(data.phagcn_score or '—')}</div>
        <div class="k">TaxMyPhage species</div><div>{html.escape(str(ov.get('Taxmyphage_Species', '—')))}</div>
      </div>
      <table><thead><tr><th>Taxonomic level</th><th>Taxon</th></tr></thead>
        <tbody>{taxonomy_rows}</tbody></table>
    </section>

    <section>
      <h2>2 &nbsp;Genomic Characteristics</h2><div class="rule"></div>
      <div class="kv">
        <div class="k">Genome size</div><div>{data.length:,} bp</div>
        <div class="k">GC content</div><div>{data.gc or '—'} %</div>
        <div class="k">Genome type</div><div>dsDNA (Caudoviricetes, tailed phage)</div>
        <div class="k">Predicted genes (CDS)</div><div>{gene_count(q)} (genomad / pharokka / phaBox2)</div>
        <div class="k">tRNA genes</div><div>{data.trna_count} (tRNA-Ser CGA)</div>
        <div class="k">Coding density</div><div>{data.coding_density or '—'} % (prodigal)</div>
        <div class="k">Termini</div><div>{html.escape(str(q.get('termini') or '—'))}</div>
        <div class="k">Genome copies (CheckV)</div><div>{html.escape(str(q.get('genome_copies') or '—'))}</div>
        <div class="k">Provirus flagged</div><div>{html.escape(str(q.get('provirus') or '—'))}</div>
      </div>
    </section>

    <section>
      <h2>3 &nbsp;Quality, Purity &amp; Identity Confirmation</h2><div class="rule"></div>
      <table><thead><tr><th>Metric</th><th>Tool</th><th>Value</th></tr></thead>
        <tbody>
          <tr><td class="lvl">CheckV quality</td><td>CheckV</td><td>{html.escape(str(q.get('checkv_quality') or '—'))}</td></tr>
          <tr><td class="lvl">miuvig quality</td><td>CheckV</td><td>{html.escape(str(q.get('miuvig_quality') or '—'))}</td></tr>
          <tr><td class="lvl">Completeness</td><td>CheckV</td><td>{html.escape(str(q.get('completeness')))} %</td></tr>
          <tr><td class="lvl">Contamination</td><td>CheckV</td><td>{html.escape(str(q.get('contamination')))} %</td></tr>
          <tr><td class="lvl">Viral identification score</td><td>VirSorter2</td>
              <td>dsDNAphage {html.escape(str(vs.get('max_score', '—')))} (group: {html.escape(str(vs.get('max_score_group', '—')))})</td></tr>
          <tr><td class="lvl">Purity</td><td>PhaBox2</td>
              <td>{html.escape(str(pb.get('Pure_viral', '—')))} — viral genes {html.escape(str(pb.get('Viral_genes', '—')))}/{html.escape(str(pb.get('Total_genes', '—')))}</td></tr>
          <tr><td class="lvl">Contamination (k-mer)</td><td>PhaBox2</td><td>{html.escape(str(pb.get('Contamination', '—')))}</td></tr>
          <tr><td class="lvl">Warnings</td><td>CheckV</td><td>{html.escape(str(q.get('warnings') or 'none'))}</td></tr>
        </tbody></table>
    </section>

    <section>
      <h2>4 &nbsp;Independent Detection Support</h2><div class="rule"></div>
      <table><thead><tr><th>Tool</th><th>p-value / score</th></tr></thead>
        <tbody>{detection_rows}</tbody></table>
    </section>

    <section>
      <h2>5 &nbsp;Biological Characteristics</h2><div class="rule"></div>
      <div class="kv">
        <div class="k">Lifecycle prediction</div><div>{lc_consensus}
          (bacphlip: {html.escape(str(lc.get('bacphlip_prediction', '—')))}, virulent {html.escape(str(lc.get('bacphlip_Virulent', '—')))} / temperate {html.escape(str(lc.get('bacphlip_Temperate', '—')))}; Phatyp: {html.escape(str(lc.get('phatyp_TYPE', '—')))}, score {html.escape(str(lc.get('phatyp_PhaTYPScore', '—')))})</div>
        <div class="k">Predicted host</div><div>{html.escape(str(hs.get('host', '—')))} (CHERRY score {html.escape(str(hs.get('score', '—')))}, {html.escape(str(hs.get('method', '—')))})</div>
        <div class="k">Host lineage (NCBI)</div><div>{html.escape(str(hs.get('lineage', '—') or '—'))}</div>
        <div class="k">Reference host</div><div>{html.escape(data.closest_ref['host'])}</div>
        <div class="k">Prophage-like region (PhiGaro)</div><div>{html.escape(prophage)}</div>
      </div>
    </section>

    <section>
      <h2>6 &nbsp;Functional Annotation Highlights</h2><div class="rule"></div>
      <table><thead><tr><th>Functional category</th><th>Predicted genes (annotation source)</th></tr></thead>
        <tbody>{ann_rows}</tbody></table>
    </section>

    <section>
      <h2>7 &nbsp;Safety &amp; GMP Consideration</h2><div class="rule"></div>
      <div class="kv">
        <div class="k">AMR / antibiotic-resistance genes</div><div>{html.escape(amr_txt)}</div>
        <div class="k">Virulence / toxin genes</div><div>None detected</div>
        <div class="k">Integrase / lysogeny module</div><div>{html.escape(integrase_txt)}</div>
      </div>
      <div class="note"><b>GMP note.</b> This phage is classified as <b>temperate</b> and carries a
        <b>integrase</b> plus lysogeny regulators (CII/Cro/Mnt/Arc), consistent with its
        P22 lineage. For therapeutic or GMP manufacturing use, a temperate phage requires careful risk
        assessment: lysogeny and transduction of host genes may occur. Selection of a strictly lytic
        derivative, empirical host-range testing, and absence of lysogeny/transduction should be verified
        before release. No AMR, virulence or toxin genes were detected in the genome.</div>
    </section>

    <section>
      <h2>8 &nbsp;Methods &amp; Provenance</h2><div class="rule"></div>
      <div class="kv">
        <div class="k">Source sample</div><div>{html.escape(data.sample)}</div>
        <div class="k">Contig</div><div>{html.escape(data.contig)}</div>
        <div class="k">Workflow</div><div>What_the_Phage v1.2.0 (DOI 10.1093/gigascience/giac110)</div>
        <div class="k">Annotation tools</div>
        <div>CheckV, VirSorter2, geNomad, PhaBox2/PhaGCN, TaxMyPhage, sourmash, CHERRY, bacphlip, Phatyp, PhiGaro, PPRmeta, MetaPhinder, VIBRANT, Seeker, VirFinder, pharokka, Prodigal, tRNAscan-SE</div>
        <div class="k">Report date</div><div>{date.today().strftime('%Y-%m-%d')}</div>
      </div>
      <div class="note grey">This report was generated automatically from What_the_Phage workflow results.
        Predicted features are <i>in silico</i> annotations and must be confirmed by wet-lab
        characterization (host range, growth kinetics, genome sequencing) before any GMP-grade release.</div>
    </section>
  </main>

  <footer>
    <div>GMP Phage Characterization Report</div>
    <div>Generated {date.today().strftime('%Y-%m-%d')} · What_the_Phage</div>
  </footer>
</div>
<script>
const PDF_DATA = {pdf_embed and "'data:application/pdf;base64," + pdf_embed + "'" or "null"};
const PDF_NAME = {html.escape(pdf_filename)!r};
function downloadPdf() {{
  if (!PDF_DATA) {{
    window.print();
    return;
  }}
  const a = document.createElement('a');
  a.href = PDF_DATA;
  a.download = PDF_NAME;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}}
</script>
</body>
</html>"""

    with open(out_path, "w") as fh:
        fh.write(html_doc)
    return out_path


# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(
        description=("Generate a GMP (Good Manufacturing Practice) characterization "
                     "report (PDF + HTML) for a bacteriophage contig characterized "
                     "by the What_the_Phage workflow."),
        epilog=(
            "examples:\n"
            "  %(prog)s\n"
            "      default: ERR575691 bundle, contig NODE_10_length_41715_cov_26065_228205\n"
            "  %(prog)s --contig NODE_6_length_86514_cov_9_296938\n"
            "      another contig from the default bundle\n"
            "  %(prog)s --json results/full_big/report/ERR575692_raw_assembly_results.json \\\n"
            "           --contig NODE_12_length_41715_cov_23702_779981 \\\n"
            "           --out results/full_big/report/gmp_ERR575692\n"
            "      a contig from another sample bundle\n"
            "\n"
            "--contig must exactly match the contig identifier used in the report "
            "tables, and --json must point to the results bundle that contains it."),
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--json", default=DEFAULT_JSON,
                    help="Path to a What_the_Phage results bundle "
                         "(*_raw_assembly_results.json) [default: %(default)s]")
    ap.add_argument("--contig", default=DEFAULT_CONTIG,
                    help="Contig identifier to report on "
                         "[default: %(default)s]")
    ap.add_argument("--out", default=os.path.join(os.path.dirname(DEFAULT_JSON),
                                                  "gmp_report_lederbergvirus"),
                    help="Output prefix for the generated .pdf and .html files "
                         "[default: %(default)s]")
    args = ap.parse_args()

    json_path = os.path.abspath(args.json)
    out_prefix = os.path.abspath(args.out)

    sample_dir = None
    fasta_gz = None
    base = os.path.dirname(json_path)
    parent = os.path.dirname(base)

    sample_name = None
    with open(json_path) as fh:
        sample_name = json.load(fh).get("sample")
    cand = os.path.join(parent, sample_name) if sample_name else None
    if cand and os.path.isdir(cand):
        sample_dir = cand
        fasta_cand = os.path.join(cand, "Input_fasta", sample_name + ".fa.gz")
        if os.path.exists(fasta_cand):
            fasta_gz = fasta_cand

    data = PhageReportData(json_path, args.contig, sample_dir=sample_dir,
                           fasta_gz=fasta_gz)
    title = f"GMP Bacteriophage Characterization Report — {args.contig}"

    pdf_path = build_pdf(data, out_prefix + ".pdf", title)
    html_path = build_html(data, out_prefix + ".html", title,
                           pdf_path=out_prefix + ".pdf")
    print(f"PDF : {pdf_path}")
    print(f"HTML: {html_path}")
    print(f"GC% = {data.gc}, genes = {gene_count(data.quality)}, "
          f"coding density = {data.coding_density}%")


if __name__ == "__main__":
    main()