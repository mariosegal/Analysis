data <- read.csv("C:/Documents and Settings/ewnym5s/My Documents/Hudson City/MTB Penetration by CBR.csv", colClasses="character")

product<-factor(data$Product)
penet1 <- as.numeric(data$Penetration)
branch <- as.numeric(data$Share)
cbr<- as.factor(data$CBR)

penet2 <- round(penet1*100,1)
branch2 <- round(branch*100,1)

library(lattice)

library(latticeExtra)
library(MASS)
library(lme4)
library(directlabels)

data1 <- data
data1[,1] <- as.factor(data1[,1])
data1[,2] <- as.factor(data1[,2])
data1[,3]=as.numeric(data1[,3])
data1[,4]=as.numeric(data1[,4])
data1[,3]=round(as.numeric(data1[,3])*100,2)
data1[,4]=round(as.numeric(data1[,4])*100,2)


fit <- lmList(Penetration ~ Share | Product,data1)


r2 <- round(summary(fit)$r.squared,2)

mypanel <- function(x,y,...) {
  panel.xyplot(x,y,...)
  panel.grid(x=-1,y=-1)
  panel.lmline(x,y,col="red",lwd=1,lty=1)
  panel.text(12,60,substitute(R^2 == rrr, list(rrr=r2[panel.number()])),cex=.8, font = 2,col="black")
} 

colors <- 1:16
symbols<- 1:16
main_t <- list(label="Product Penetration vs. Branch Share by CBR\nM&T Bank September 2012",col="blue",cex=1.5)
ylab_t <-list(label="Product penetration (%)",col="black",cex=1,fontface="bold")
xlab_t <-list(label="M&T Branch Share (%)",col="black",cex=1,fontface="bold")

key.panel <- list(title="CBR",space="right",text=list(levels(data1$CBR)),points=(list(pch=symbols,col=colors)))

#panel.text(15,40,paste("r squared=",r2[panel.number()],sep=""),cex=0.8, font = 2,col="red")
# panel.text(15,30,paste("=",r2[panel.number()],sep=""), cex=0.8,font = 2,col="red")
#panel.text(10,40,paste("r squared=",r2[panel.number()],sep=""),cex=1, font = 2,col="red")

xyplot (data1$Penetration ~ data1$Share | data1$Product,groups=data1$CBR,xlab=xlab_t,
        ylab=ylab_t,layout=c(4,3),panel=mypanel,key=key.panel,pch=symbols,col=colors
        ,main=main_t)
