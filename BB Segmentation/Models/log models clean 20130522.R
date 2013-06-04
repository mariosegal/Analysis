
setwd("C:/Documents and Settings/ewnym5s/My Documents/BB Segmentation/Models")

load("train_scaled.RData")
library(ggplot2)

temp <- train[1,-1]
temp <- temp[,colSums(temp)!=0]

include <- names(which(colSums(temp)!=0 ))
include <- include[!include %in% c("s1","s2","s3","s4","s5","s6")] 