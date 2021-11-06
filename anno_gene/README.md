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
2. It's worthnoting that only 49 out of 546 suzukii total contigs could be unamibiously mapped to chromosome arms of D.mel, which add up to 57.15% of the whole genome in length. To make it easier to relate genomic information of D.*suz* to D.*mel*, we choose to include only these 49 contigs in the annotation table. Those contigs are originally labelled as 'unlocalized-scaffold or 'assembled-molecule' in the ![refseq assemby report][1].

[1]: https://ftp.ncbi.nlm.nih.gov/genomes/refseq/invertebrate/Drosophila_suzukii/latest_assembly_versions/GCF_013340165.1_LBDM_Dsuz_2.1.pri/GCF_013340165.1_LBDM_Dsuz_2.1.pri_assembly_report.txt "assembly report of Dsuz_2.1"

----
Author: [Siyuan Feng](https://scholar.google.com/citations?user=REHFXSsAAAAJ&hl)