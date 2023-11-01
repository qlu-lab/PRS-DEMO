rm(list = ls())

args = commandArgs(trailingOnly=TRUE)
wd <- as.character(args[1])
prs_methods <- as.character(args[2])
genotype_path <- as.character(args[3])
plink_path <- as.character(args[4])

methods <- as.list(strsplit(prs_methods, ",")[[1]])

# LDPred2
if ("ldpred2" %in% methods) {
    for(n in 1:13) {
        cat("\nCalculating PRS scores for LDpred2 model", n, "\n\n")
        system(paste0(plink_path, "/plink --bfile ", genotype_path, " --score ", wd, "/ldpred2.txt 1 2 ", (n+2), " header sum center --out ", wd,"/ldpred2.", (n+2)))
    }
}

# default PRS method
if ("default" %in% methods) {
    for(n in 1:5) {
        cat("\nCalculating PRS scores for default PRS model", n, "\n\n")
        system(paste0(plink_path, "/plink --bfile ", genotype_path, " --score ", wd, "/default.txt 1 2 ", (n+2), " header sum center --out ", wd,"/default.", (n+2)))
    }
}
