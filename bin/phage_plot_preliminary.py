#!/usr/bin/env python3
# how to use root@9a899e99ea29:/input# python plasmidplot.py --gff3 contig_255_barcode01_bakta.gff3 --name contig_225_barcode01_plasmidplot --contig contig_225 --ring1 salmon --ring2 skyblue --limit 30
# docker run --rm -it -v $PWD:/input nanozoo/pycirclize:3.12--48de646 /bin/bash
# remove hypothetical Proteins: grep "ID=" contig_9_barcode2_bakta.gff3 | grep -v "Name=hypothetical protein" >without_hypothetical_protein.gff3


from pycirclize import Circos
from pycirclize.utils import fetch_genbank_by_accid
from pycirclize.parser import Genbank
from pycirclize.parser import Gff
import argparse

################################################################################
## Initialization

parser = argparse.ArgumentParser(description = 'Create json-file for upload to MongoDB from different result-files.')

#define arguments
parser.add_argument('-g', '--gff3', help = "Input gff3-files", default = 'false')
parser.add_argument('-n', '--name', help = "Plotname", default = 'false')
parser.add_argument('-c', '--contig', help = "Contig to plot", default = 'false')
parser.add_argument('-1', '--ring1', help = "Ring color 1", default = 'salmon')
parser.add_argument('-2', '--ring2', help = "Ring color 1", default = 'skyblue')
parser.add_argument('-l', '--limit', help = "character limit for text, after ... is added", default = 30)

#parsing:
arg = parser.parse_args()

################################################################################
## INPUT

gff_file = arg.gff3
plotname = arg.name
contigname = arg.contig
ringnr1 = arg.ring1
ringnr2 = arg.ring2
charlimit = arg.limit

# read file
gff = Gff(gff_file=gff_file, name=plotname + "\n" + contigname,target_seqid=contigname)

# Initialize Circos instance with genome size
circos = Circos(sectors={gff.name: gff.range_size})
circos.text(f"{gff.name}\n\n{gff.range_size}bp", size=14)
circos.rect(r_lim=(90, 100), fc="lightgrey", ec="none", alpha=0.5)
sector = circos.sectors[0]

# Plot forward strand CDS
f_cds_track = sector.add_track((95, 100))
f_cds_feats = gff.extract_features("CDS", target_strand=1)
f_cds_track.genomic_features(f_cds_feats, plotstyle="arrow", fc=ringnr1, lw=0.5)

# Plot reverse strand CDS
r_cds_track = sector.add_track((90, 95))
r_cds_feats = gff.extract_features("CDS", target_strand=-1)
r_cds_track.genomic_features(r_cds_feats, plotstyle="arrow", fc=ringnr2, lw=0.5)

# Plot 'gene' qualifier label if exists
labels, label_pos_list = [], []
for feat in gff.extract_features("CDS"):
    start = int(str(feat.location.start))
    end = int(str(feat.location.end))
    label_pos = (start + end) / 2
    gene_name = feat.qualifiers.get("gene", [None])[0]
    name = feat.qualifiers.get("function", [""])[0]
    if len(name) > int(charlimit):
        name = name[:int(charlimit)] + "..."    
    if gene_name is not None:
        labels.append(gene_name)
        label_pos_list.append(label_pos)
    else:
        labels.append(name)
        label_pos_list.append(label_pos)

f_cds_track.xticks(label_pos_list, labels, label_size=6, label_orientation="vertical")

# Plot xticks (interval = 10 Kb)
r_cds_track.xticks_by_interval(
    10000, outer=False, label_formatter=lambda v: f"{v/1000:.1f} Kb"
)

circos.savefig(plotname + "_" + contigname + ".jpg", dpi=300)
circos.savefig(plotname + "_" + contigname + ".svg", dpi=200)