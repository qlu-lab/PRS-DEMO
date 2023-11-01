rm(list = ls())
suppressMessages(library(data.table))
suppressMessages(library(R.utils))
suppressMessages(library(tidyverse))

args = commandArgs(trailingOnly=TRUE)
wd <- as.character(args[1])
prs_methods <- as.character(args[2])
h2 <- as.numeric(args[3])
sumstats_path <- as.character(args[4])
ldref <- as.character(args[5])
os <- as.character(args[6])

methods <- as.list(strsplit(prs_methods, ",")[[1]])

extract_snp_weights <- function(dat,snp,a1,weight){
    out <- data.frame(SNP=dat[,snp],A1=dat[,a1],Weight=dat[,weight])
    return(out)
}

if ("ldpred2" %in% methods) {
    source("./methods/LDPred2.R")
    LDpred2(wd = wd, h2 = h2, sumstats_path = sumstats_path, ldref = ldref, os = os)
    # Sort LDPred2 weights and store in formatted table
    cat("\nSorting SNP weights for LDpred2...")
    for (j in 1:13) {
        dat <- c()
        weight.col <- j + 2
        for (chr in 1:22) {
            dat.tmp <- as.data.frame(fread(paste0(wd,"/chr",chr,".ldpred2.txt"),header=F))
            dat.sorted <- extract_snp_weights(dat=dat.tmp,snp="V1",a1="V2",weight=weight.col)
            dat <- rbind(dat,dat.sorted)
        }
        dat[,3] <- dat[,3]/sd(dat[,3])
        if(j == 1) {
            lddat <- dat
        } else {
            lddat <- cbind(lddat, dat[,3])
        }
    }
    fwrite(lddat,paste0(wd,"/ldpred2.txt"),col.names=F,row.names=F,sep="\t",quote=F)
    cat("\nFinished sorting SNP weights for LDpred2\n")
}

if ("default" %in% methods) {
    source("./methods/PRS.R")
    default(wd = wd, sumstats_path = sumstats_path)
}