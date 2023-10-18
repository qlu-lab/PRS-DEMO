#!/s/bin/R35
suppressMessages(library(data.table))
suppressMessages(library(R.utils))
suppressMessages(library(plyr))
suppressMessages(library(bigsnpr))
suppressMessages(library(bigreadr))
suppressMessages(library(optparse))
suppressMessages(library(tidyverse))
suppressMessages(library(parallel))
suppressMessages(library(foreach))
suppressMessages(library(rngtools))
options(stringsAsFactors = FALSE)
args <- commandArgs(trailingOnly = TRUE)
wd <- as.character(args[1])
h2 <- as.numeric(args[2])
sumstats_path <- as.character(args[3])
ldref <- as.character(args[4])

m <- 1030186
cores <- max(1, detectCores() - 1, na.rm = TRUE)
cat("\nRunning PRS model LDpred2 for 22 chromosomes in parallel...\n")

# read and format gwas sumstats
gwas.raw <- as.data.frame(fread(sumstats_path))
gwas.dat <- gwas.raw[,c(1,3,2,10,4:8)]
colnames(gwas.dat) <- c("chr","rsid","pos","n_eff","a1","a0","MAF","beta","beta_se")

# read in necessary data LD data
bim_file <- fread2(paste0(ldref, ".bim"))
fam_file <- fread2(paste0(ldref, ".fam"))
val_bed <- snp_attach(paste0(ldref, ".rds"))
G <- snp_fastImputeSimple(val_bed$genotypes)
CHR <- val_bed$map$chromosome
POS <- val_bed$map$physical.pos
map <- val_bed$map[-(3)]
names(map) <- c("chr", "rsid", "pos", "a1", "a0")
# run LDpred2 for each chromosome
ldpred2 <- mclapply(1:22, function(chr) {
    cat("\nRunning LDpred2 for chromosome ", chr, "\n")
    chr_out_path <- paste0(wd, "/chr", chr, ".ldpred2.txt")

    summstats <- gwas.dat[gwas.dat$chr==chr,]
    n_snp <- dim(summstats)[1]
    snp.ratio <- nrow(summstats)/1030186
    summstats$sgenosd <- 2*summstats$MAF*(1-summstats$MAF)
    summstats$MAF <- NULL
    info_snp <- snp_match(summstats, map, match.min.prop = 0.05, join_by_pos=F)
    maf <- snp_MAF(G, ind.col = info_snp$`_NUM_ID_`)
    sd_val <- sqrt(2 * maf * (1 - maf))
    sd_gwas <- with(info_snp, sqrt(sgenosd))
    is_bad <- abs(sd_gwas-sd_val) >= 0.05 | sd_gwas < 0.01 | sd_val < 0.01
    df_beta <- info_snp[!is_bad, c("beta", "beta_se", "n_eff")]
    info_snp <- info_snp[!is_bad,]
    info_chr <- info_snp$`_NUM_ID_`
    corr <- snp_cor(G, ind.col = info_chr, size = 500)
    h2_est <- 0.3*snp.ratio
    if(h2_est < 1e-4){
        beta_LDpred2 <- data.frame(info_snp$rsid,info_snp$a1,beta_inf=rep(0,length(info_snp$rsid)),beta_auto=rep(0,length(info_snp$rsid)),beta_grid=matrix(rep(0,30*length(info_snp$rsid)),ncol=30))
    } else {
        corr_sp <- bigsparser::as_SFBM(as(corr, "generalMatrix"))
        auto <- snp_ldpred2_auto(corr_sp, df_beta, h2_init = h2_est, allow_jump_sign = FALSE, shrink_corr = 0.5)
        beta_auto <- auto[[1]]$beta_est
        beta_auto <- ifelse(is.na(beta_auto), 0, beta_auto)
        p_seq <- signif(c(1e-3, 1e-2, 0.1), 2)
        h_seq <- round(c(0.1,0.3)*h2_est,4)
        params <- expand.grid(p = p_seq, h2 = h_seq, sparse = c(TRUE,FALSE))
        beta_grid <- snp_ldpred2_grid(corr_sp, df_beta, params)
        beta_grid <- apply(beta_grid,2,function(s){return(ifelse(is.na(s), 0, s))})
        beta_grid <- apply(beta_grid,2,function(s){return(ifelse(abs(s)>=1, 0, s))})
        beta_LDpred2 <- data.frame(info_snp$rsid,info_snp$a1,beta_auto,beta_grid)
    }
    fwrite2(beta_LDpred2, chr_out_path, col.names = F, row.names = F, quote = F,sep=" ",na=NA)
}, mc.cores=cores)
cat("\nFinished running LDPred2 for all 22 chromosomes\n")

