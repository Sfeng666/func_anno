#!/bin/bash

assembly=/home/siyuan/reference/WT3-2.0/refseq/annotation/GCF_013340165.1_LBDM_Dsuz_2.1.pri_assembly_report.txt

# calculate: 
# 1. the percentage of the number of unambigously assigned contigs (unlocalized-scaffold + assembled-molecule)
# 2. the percentage of the length of unambigously assigned contigs 
awk 'BEGIN{FS = "\t"; total = total_len = 0; unamb = unamb_len = 0}
$1 !~ /#/ {total += 1; total_len += $9}
$1 !~ /#/ && $2 != "unplaced-scaffold"{unamb += 1; unamb_len += $9}
END{printf "The percentage of the number of unambigously assigned contigs is %.2f %%\n", unamb/total * 100;
printf "The percentage of the length of unambigously assigned contigs is %.2f %%\n", unamb_len/total_len * 100}' $assembly