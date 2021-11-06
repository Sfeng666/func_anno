# Generate an annotation table of exons & UTRs by gene

----

This program generate an annotation table of exons & UTRs by each protein-coding gene. The primary usage of this table is as an input file to John's GSEA pipeline.

## Notes
1. The columns represent: 
    * Column 1: flybase ID of orthologous gene in D. melanogaster. If no orthology found, a refseq geneID will be presented.
    * Column 2: gene symbol of orthologous gene in D. melanogaster. If no orthology found, 'NA' will be presented. 
    * Column 3: refseq accession of the contig/chr
    * Column 4: strand
    * Column 5: start coordinate
    * Column 6: end coordinate
    * Column 7: genomic elements (exon - e; 5'UTR - f; 3'UTR - t)

----
###  Author: [Siyuan Feng](https://scholar.google.com/citations?user=REHFXSsAAAAJ&hl)
###  Mail: siyuanfeng.bioinfo@gmail.com