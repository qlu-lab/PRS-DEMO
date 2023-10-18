suppressMessages(library(data.table))
suppressMessages(library(R.utils))
suppressMessages(library(tidyverse))
options(stringsAsFactors=F)
args = commandArgs(trailingOnly=TRUE)
wd <- as.character(args[1])
sumstats_path <- as.character(args[2])

# prs default - use beta sumstats above p-value threshold
cat("\nRunning default PRS method...")
p_value_cutoff <- c(0.01, 0.05, 0.1, 0.5, 1)
gwas.raw <- as.data.frame(fread(sumstats_path,header=T))
gwas.out <- gwas.raw[,c(3,4,7,9)]
colnames(gwas.out) <- c("snp","a1","weight","p")

for (j in 1:length(p_value_cutoff)) {
    dat <- gwas.out
    
    dat <- dat %>% 
        mutate(weight = ifelse(p <= p_value_cutoff[j], weight, 0), p = NULL)
    
    if(j == 1) {
        default.dat <- dat
    } else {
        default.dat <- cbind(default.dat, dat[,3])
    }
}

fwrite(default.dat,paste0(wd,"/default.txt"),col.names=F,row.names=F,sep="\t",quote=F)
cat("\nFinished running default PRS method\n")