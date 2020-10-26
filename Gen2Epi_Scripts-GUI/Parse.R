#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library(methods)
library(dplyr)
Genstat <- read.table(file=args[1],sep="\t",header=T)
Genstat1 <- read.table(file=args[2],sep="\t",header=T)
com <- inner_join(Genstat,Genstat1)
write.table(com,file=args[3],sep="\t",col.names=TRUE,row.names=FALSE,quote=F)
