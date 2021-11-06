#!/bin/bash

### 1. set paths ###

## set parameter parsings for user-specified paths ##
usage="This script parallelly generate genomic reannotations of exons and UTRs.\n
usage: sh parallel_by_chr [-h/--help] [-w/--work_directory <path>] [-s/--script <path>]\n
[-o/--in_ortho <path>] [-a/--input_anno <path>] [-r/--chr_assignment <path>]\n
[-c/--dir_coord <path>] [-d/--conda_path <path>] [-e/--conda_env <name>]"

while [ $# -gt 0 ]; do
  case "$1" in
    --work_directory*|-w*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      wd="${1#*=}"
      ;;
    --script*|-s*)
      if [[ "$1" != *=* ]]; then shift; fi
      script="${1#*=}"
      ;;
    --input_anno*|-a*)
      if [[ "$1" != *=* ]]; then shift; fi
      in_anno="${1#*=}"
      ;;
    --in_ortho*|-o*)
      if [[ "$1" != *=* ]]; then shift; fi
      in_ortho="${1#*=}"
      ;;
    --dir_coord*|-c*)
      if [[ "$1" != *=* ]]; then shift; fi
      dir_coord="${1#*=}"
      ;;
    --chr_assignment*|-r*)
      if [[ "$1" != *=* ]]; then shift; fi
      chr_assignment="${1#*=}"
      ;;
    --conda_path*|-d*)
      if [[ "$1" != *=* ]]; then shift; fi
      conda_path="${1#*=}"
      ;;
    --conda_env*|-e*)
      if [[ "$1" != *=* ]]; then shift; fi
      conda_env="${1#*=}"
      ;;      
    --help|-h)
      echo $usage # Flag argument
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      exit 1
      ;;
  esac
  shift
done

if [[ -z $wd || -z $script || -z $in_anno || -z $in_ortho || -z $dir_coord \
|| -z $chr_assignment || -z $conda_path || -z $conda_env ]]; then
    echo $usage
    echo "-w $wd
-s $script
-a $in_anno
-o $in_ortho
-c $dir_coord
-r $chr_assignment
-d $conda_path
-e $conda_env"
    exit 1
fi

## derived paths ##
# input
in_coord=$dir_coord/reannotate_{2}.bed

# output
sep_dir=$wd/sep
out_tab_sep=$sep_dir/anno_{1}.txt
out_tab=$wd/anno_genome.txt
log=$wd/reannotate.log
temp=$wd/temp

mkdir -p $sep_dir
mkdir -p $temp

### 2. configure the conda enviroment ###
source $conda_path/bin/activate $conda_env

### 3. run steps of the pipeline ###

### script starts ###
echo start at time `date +%F'  '%H:%M`

## define a function to reannotate each chromosome separately
function anno() {
local mapchr=$1
local contig=$2
local in_coord=$3
local out_tab=$4

python $script \
--contig $contig \
--in_anno $in_anno \
--in_ortho $in_ortho \
--in_coord $in_coord \
--out_tab $out_tab

echo "annotation done for $contig at chromosome $mapchr" >> $log
}

## function to parallel by contig
function para() {
awk 'BEGIN{OFS="\t"} $2 != "na" && NR>1{print $2, $1}' $chr_assignment | sort -k1 \
| parallel --tmpdir $temp -j 0 -k --colsep '\t' \
"$@"
}

## function to parallel by chromosome
function para_chr() {
awk 'BEGIN{OFS="\t"} $2 != "na" && NR>1{print $2}' $chr_assignment | sort | uniq \
| parallel --tmpdir $temp -j 0 -k \
"$@"
}

## 3.1. run reannotations

echo -e "### Reannotations starts ###\n" >> $log

export -f anno
export in_anno
export in_ortho
export script
export log

para \
anno {1} {2} $in_coord $out_tab_sep $script $in_ortho $in_anno $log

echo -e "### Reannotations ends ###\n" >> $log

## 3.2. merge outputs
echo -e "### Merging starts ###\n" >> $log

# merge bed files
para_chr \
cat $out_tab_sep >> $out_tab

echo -e "### Merging ends ###\n" >> $log

### script ends ###
rm -r $temp
echo finish at time `date +%F'  '%H:%M`