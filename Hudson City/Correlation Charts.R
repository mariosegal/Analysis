#read the data from the csv export
modeling <- read.csv("C:/Documents and Settings/ewnym5s/My Documents/Hudson City/modeling.csv")

library(lattice)

library(latticeExtra)
library(MASS)
library(lme4)
library(directlabels)



mypanel <- function(x,y,...) {
  panel.xyplot(x,y,...)
  panel.grid(x=-1,y=-1)
  panel.lmline(x,y,col="red",lwd=1,lty=1)
  panel.text(12,60,substitute(R^2 == rrr, list(rrr=r2[panel.number()])),cex=.8, font = 2,col="black")
} 

fit <- lm(contrib ~ DDA_Amt,data=modeling)


r2 <- round(summary(fit)$r.squared,2)



main_t <- list(label="Contribution Correlation versu Multiple Variables",col="blue",cex=1.5)
ylab_t <-list(label="Contribution ($/month)",col="black",cex=1,fontface="bold")
xlab_t <-list(label="Balance ($)",col="black",cex=1,fontface="bold")

xyplot (contrib ~ DDA_Amt  
          ,data=modeling,xlab=xlab_t,
        ylab=ylab_t,layout=c(2,2),panel=mypanel,main=main_t)