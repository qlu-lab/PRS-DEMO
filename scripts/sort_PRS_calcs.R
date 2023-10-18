#!/s/bin/R35
suppressMessages(library(data.table))
suppressMessages(library(R.utils))
options(stringsAsFactors=F)
args = commandArgs(trailingOnly=TRUE)
wd <- as.character(args[1])

extract_fid_iid <- function(dat,fid,iid){
    out <- data.frame(FID=dat[,fid],IID=dat[,iid])
    return(out)
}

extract_score_data <- function(prs_name, columns) {
    scores <- c()
    for (i in 1:length(columns)) {
        # read scores from .profile file
        dat <- as.data.frame(fread(paste0(wd, "/", prs_name, ".", i+2, ".profile"), header = TRUE))
        # normalize the score
        score <- dat[,"SCORESUM"]
        normalized_score <- (score - mean(score)) / sd(score)
        # add the score to the vector of different versions of scores
        scores <- cbind(scores, normalized_score)
        colnames(scores)[i] <- columns[i]
    }

    return(scores)
}

cat("\nCreating table for final PRS scores from LDpred2 and default PRS methods and normalizing scores...")
# Set initial table for prs scores
dat.tmp <- as.data.frame(fread(paste0(wd,"/ldpred2.3.profile"), header = TRUE))
dat <- extract_fid_iid(dat.tmp,fid="FID",iid="IID")
colnames(dat) <- c("FID", "IID")
prs_scores <- dat

# Extract LD Pred2 PRS scores
ld_pred2_columns <- c("LDpred2_auto", "LDpred2_0.03_0.001_sparse", "LDpred2_0.03_0.01_sparse", "LDpred2_0.03_0.1_sparse", "LDpred2_0.09_0.001_sparse", "LDpred2_0.09_0.01_sparse", "LDpred2_0.09_0.1_sparse", "LDpred2_0.03_0.001", "LDpred2_0.03_0.01", "LDpred2_0.03_0.1", "LDpred2_0.09_0.001", "LDpred2_0.09_0.01", "LDpred2_0.09_0.1")
prs_scores <- cbind(prs_scores, extract_score_data("ldpred2", ld_pred2_columns))
# Extract Default PRS scores
default_prs_columns <- c("PRS_0.01", "PRS_0.05", "PRS_0.1", "PRS_0.5", "PRS_1")
prs_scores <- cbind(prs_scores, extract_score_data("default", default_prs_columns))

# write prs scores data to file
fwrite(prs_scores,"./prs_scores.txt",col.names=T,row.names=F,sep="\t",quote=F)
cat("\n\nFinal PRS scores written to file: ./prs_scores.txt\n")