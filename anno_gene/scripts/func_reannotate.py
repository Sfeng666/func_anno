# -*- coding: utf-8 -*-
################################################################################
##  *
##  *  Function: Generate an annotation table of exons & UTRs by gene
##  *  Author: Siyuan Feng
##  *  Mail: siyuanfeng.bioinfo@gmail.com
##  *  Version: 11.05.2021
##  *
################################################################################

from optparse import OptionParser
import gzip
import re

### help and usage ### 
usage = "usage: %prog [options] args"
description = '''Function: to generate an annotation table of exons & UTRs by gene'''
version = '%prog 11.05.2021'
parser = OptionParser(usage=usage,version=version, description = description)
parser.add_option("--contig",
                    action="store",
                    dest = "contig",
                    help = "RefSeq Accession of the chromosome/contig",
                    metavar = "ARG")
parser.add_option("--in_anno",
                    action="store",
                    dest = "in_anno",
                    help = "input path of genome annotation in compressed gff3 format (.gff.gz)",
                    metavar = "PATH")
parser.add_option("--in_ortho",
                    action="store",
                    dest = "in_ortho",
                    help = "input path of suzukii gene table orthlogous to melanogaster (.txt)",
                    metavar = "PATH")                    
parser.add_option("--in_coord",
                    action="store",
                    dest = "in_coord",
                    help = "input path of coordinates of sites on both strands by categories in bed format (.bed)",
                    metavar = "PATH")
parser.add_option("--out_tab",
                    action = "store",
                    dest = "out_tab",
                    help = "output table of exons & UTRs by gene (.txt)",
                    metavar = "PATH")
(options,args) = parser.parse_args()

### introduced variables ###
contig = options.contig
in_anno = options.in_anno
in_ortho = options.in_ortho
in_coord = options.in_coord
out_tab = options.out_tab

### in-script variables ###
gene_coord = {}
strands = ['+', '-']
coordinate = {std: {} for std in strands}

### 1. Read in the bed format of reannotation file 
with open(in_coord, 'r') as f:
    for line in f:
        line = line.split('\t')
        start = line[1]
        end = line[2]
        anno = line[3]
        strand = line[5]

### 1. Read the annotation file from RefSeq gff
with gzip.open(in_anno, 'rt') as f:
    for line in f:
        if not line.startswith('#'):
            line = line.strip().split('\t')
            chr = line[0]
            feature = line[2]
            start = line[3]
            end = line[4]
            strand = line[6]
            attr = line[8]
            phase = line[7]

            if chr == contig:
                if feature == 'region':
                    for std in strands:
                        coordinate[std].setdefault(contig, {})

                elif feature == 'gene' or feature == 'pseudogene':
                    gene = re.search('Dbxref=GeneID:(.*?);', attr).group(1)
                    try:
                        gene_biotype = re.search('gene_biotype=(.*?);', attr).group(1)
                    except:
                        gene_biotype = re.search('gene_biotype=(.*)', attr).group(1)
                    if gene_biotype == "protein_coding":
                        coordinate[strand][chr][gene] = [chr, start, end, strand]

### 2. Read the orthology table
ortho = {}
with open(in_ortho, 'r') as f:
    for line in f:
            line = line.strip().split('\t')
            gene = line[0]
            symb = line[2]
            fb = line[4].split(':')[1]
            ortho[gene] = [symb, fb]

### 3. Read the bed format of reannotation file
UTR_name = {"3'UTR": "t", "5'UTR": "f"}
cds_name = ['non-synonymous', '2-fold_synonymous', '3-fold_synonymous', '4-fold_synonymous']
cds = 0
with open(in_coord, 'r') as f, open(out_tab, 'a') as out:
    for line in f:
        line = line.strip().split('\t')
        start = line[1]
        end = line[2]
        anno = line[3]
        strand = line[5]

        if anno in cds_name:
            if cds == 0:
                cds_start = start
                cds = 1
            cds_end = end
            cds_strand = strand

        else:
            if cds == 1:
                for gene in coordinate[cds_strand][contig]:
                    if int(cds_start) >= int(coordinate[cds_strand][contig][gene][1]) and int(cds_end) <= int(coordinate[cds_strand][contig][gene][2]):
                        if gene in ortho:
                            pline = '\t'.join([ortho[gene][1], ortho[gene][0], contig, cds_strand, cds_start, cds_end, 'e']) + '\n'
                        else:                
                            pline = '\t'.join([gene, 'NA', contig, cds_strand, cds_start, cds_end, 'e']) + '\n'
                        out.write(pline)
                        break
                cds = 0

            if "UTR" in anno:
                for gene in coordinate[strand][contig]:
                    if int(start) >= int(coordinate[strand][contig][gene][1]) and int(end) <= int(coordinate[strand][contig][gene][2]):
                        if gene in ortho:
                            pline = '\t'.join([ortho[gene][1], ortho[gene][0], contig, strand, start, end, UTR_name[anno]]) + '\n'
                        else:
                            pline = '\t'.join([gene, 'NA', contig, strand, start, end, UTR_name[anno]]) + '\n'
                        out.write(pline)
                        break