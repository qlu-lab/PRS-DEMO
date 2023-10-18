#!/bin/bash

set -o errexit

script_path="./scripts"
work_dir="./weights"
heritability=0.3

sumstats_path="./input/gwas_train.txt.gz"
ld_path="./input/1kg_hm3_QCed_noM"
genotype_path="./input/1kg_hm3_QCed_noM"
plink_path="./plink"
prs_methods="ldpred2,prs"
os="mac"

while getopts s:l:g:p:m:o: flag
do
    case "${flag}" in
        s) sumstats_path=${OPTARG};;
        l) ld_path=${OPTARG};;
        g) genotype_path=${OPTARG};;
        p) plink_path=${OPTARG};;
        m) prs_methods=${OPTARG};;
        o) os=${OPTARG};;
    esac
done
echo "Sumstats path: $sumstats_path";
echo "LD path: $ld_path";
echo "Genotype path: $genotype_path";
echo "Plink path: $plink_path";
echo "PRS Methods: $prs_methods";
echo "Operating system: $os";

## download and import necessary R packages
Rscript --vanilla ${script_path}/download_R_packages.R

## run PRS to calculate beta weights
Rscript --vanilla ${script_path}/LDpred2.R $work_dir $heritability $sumstats_path $ld_path
Rscript --vanilla ${script_path}/PRS.R $work_dir $sumstats_path

## sort PRS model weights
Rscript --vanilla ${script_path}/sort_SNP_weights.R $work_dir

## calculate PRS scores on genotypes
# PRS score calculation for LD pred2
for n in {3..15};
do
    echo
    echo "Calculating PRS scores for LDpred2 model ${n}"
    echo
    ${plink_path}/plink --bfile ${genotype_path} --score ${work_dir}/ldpred2.txt 1 2 ${n} header sum center --out ${work_dir}/ldpred2.${n}
done
# PRS score caclulation for default PRS
for n in {3..7};
do
    echo
    echo "Calculating PRS scores for default PRS model ${n}"
    echo
    ${plink_path}/plink --bfile ${genotype_path} --score ${work_dir}/default.txt 1 2 ${n} header sum center --out ${work_dir}/default.${n}
done

## combine PRS calculations into a final table
Rscript --vanilla ${script_path}/sort_PRS_calcs.R $work_dir