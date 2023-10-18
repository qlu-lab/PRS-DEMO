options(install.packages.check.source = "no")

repos <- "https://cloud.r-project.org"
# Ensure user has all necessary packages
cat("Installing all required R packages...\n")
if (!suppressMessages(require(plyr))) {
    cat("\nInstalling R package plyr...\n")
    install.packages("plyr", repos = repos)
    suppressMessages(library(plyr))
    cat("\nSuccessfully installed R package plyr...\n")
}
if (!suppressMessages(require(tidyverse))) {
    cat("\nInstalling R package tidyverse...\n")
    install.packages("tidyverse", repos = repos)
    suppressMessages(library(tidyverse))
    cat("\nSuccessfully installed R package tidyverse...\n")
}
if (!suppressMessages(require(R.utils))) {
    cat("\nInstalling R package R.utils...\n")
    install.packages("R.utils", repos = repos)
    suppressMessages(library(R.utils))
    cat("\nSuccessfully installed R package R.utils...\n")
}
if (!suppressMessages(require(rngtools))) {
    cat("\nInstalling R package rngtools...\n")
    install.packages("rngtools", repos = repos)
    suppressMessages(library(rngtools))
    cat("\nSuccessfully installed R package rngtools...\n")
}
if (!suppressMessages(require(data.table))) {
    cat("\nInstalling R package data.table...\n")
    install.packages("data.table", repos = repos)
    suppressMessages(library(data.table))
    cat("\nSuccessfully installed R package data.table...\n")
}
if (!suppressMessages(require(foreach))) {
    cat("\nInstalling R package foreach...\n")
    install.packages("foreach", repos = repos)
    suppressMessages(library(foreach))
    cat("\nSuccessfully installed R package foreach...\n")
}
if (!suppressMessages(require(bigreadr))) {
    cat("\nInstalling R package bigreadr...\n")
    install.packages("bigreadr", repos = repos)
    suppressMessages(library(bigreadr))
    cat("\nSuccessfully installed R package bigreadr...\n")
}
if (!suppressMessages(require(bigsnpr))) {
    cat("\nInstalling R package bigsnpr...\n")
    install.packages("bigsnpr", repos = repos)
    suppressMessages(library(bigsnpr))
    cat("\nSuccessfully installed R package bigsnpr...\n")
}
if (!suppressMessages(require(optparse))) {
    cat("\nInstalling R package optparse...\n")
    install.packages("optparse", repos = repos)
    suppressMessages(library(optparse))
    cat("\nSuccessfully installed R package optparse...\n")
}
cat("All required R packages are successfully installed...\n")