#!/bin/bash

# run the job
bash /home/siyuan/jobs/suzukii_WGS/func_anno/anno_gene/scripts/func_reannotate.sh \
-w /home/siyuan/jobs/suzukii_WGS/func_anno/anno_gene/results \
-s /home/siyuan/jobs/suzukii_WGS/func_anno/anno_gene/scripts/func_reannotate.py \
-a /home/siyuan/reference/WT3-2.0/refseq/annotation/GCF_013340165.1_LBDM_Dsuz_2.1.pri_genomic.gff.gz \
-o /home/siyuan/reference/WT3-2.0/refseq/ortholog/gene_ortholog_suzukii_melanogaster.txt \
-c /raid10/siyuan/marula_storage/jobs/suzukii_WGS/reannotate/in_parallel/sep \
-r /home/siyuan/jobs/suzukii_WGS/calc_maxcov/amb/assignment_cor_amb.txt \
-d /opt/miniconda3/ \
-e WGS_analysis \
> run.log 2>&1