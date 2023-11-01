#!/bin/bash
set -o errexit

script_path="./scripts"
work_dir="./weights"
heritability=0.3

sumstats_path="./input/gwas_train.txt.gz"
ld_path="./input/1kg_hm3_QCed_noM"
genotype_path="./input/1kg_hm3_QCed_noM"
plink_path="./plink"
prs_methods="ldpred2,default"
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
Rscript --vanilla ${script_path}/calculate_weights.R $work_dir $prs_methods $heritability $sumstats_path $ld_path $os

## calculate PRS scores on genotypes
Rscript --vanilla ${script_path}/calculate_PRS.R $work_dir $prs_methods $genotype_path $plink_path

## combine PRS calculations into a final table
Rscript --vanilla ${script_path}/sort_PRS_calcs.R $work_dir $prs_methods