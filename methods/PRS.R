suppressMessages(library(data.table))
suppressMessages(library(R.utils))
suppressMessages(library(tidyverse))

default <- function(wd, sumstats_path) {
    # prs default - use beta sumstats above p-value threshold
    cat("\nRunning default PRS method...")
    p_value_cutoff <- c(0.01, 0.05, 0.1, 0.5, 1)
    gwas.raw <- as.data.frame(fread(sumstats_path,header=T))
    # run for chr 22 for purposes of the demo
    gwas.out <- gwas.raw[gwas.raw$CHR==22,]
    sumstats <- gwas.out[,c(3,4,7,9)]
    colnames(sumstats) <- c("snp","a1","weight","p")

    for (j in 1:length(p_value_cutoff)) {
        dat <- sumstats
        
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
}