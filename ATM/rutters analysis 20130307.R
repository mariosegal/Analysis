library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
rutters <- sqlQuery(myconn,"select * from wip.Rutters")
rutters$rutters_group <- factor(rutters$rutters_group,labels=c("Rutters Only","Rutters and Any Other","Branch Only","Other Partner and Branch","Other Partner Only","No ATM"))
plotdata <- rutters[(rutters$rutters_group == levels(rutters$rutters_group)[1]| rutters$rutters_group==levels(rutters$rutters_group)[2]) & rutters$rutters_num > 0,]

library(hexbin)
bin<-hexbin(x=sheetz$other_num,y=sheetz$sheetz_num,xbins=50)
plot

library(ggplot2)
library(scales)
p<- ggplot(plotdata,aes(non_rutters_num,rutters_num))+stat_binhex(bins=100,binwidth=c(1,1))
p <- p+ scale_x_continuous(limits=c(0,40))+ scale_y_continuous(limits=c(0,40))+geom_abline(slope=1,intercept=0,color="red")
p

plotdata$count <- 1
p<- ggplot(a,aes(non_rutters_num,rutters_num,z=sum))+stat_summary_hex()
p <- p+ scale_x_continuous(limits=c(0,25))+ scale_y_continuous(limits=c(0,25))+geom_abline(slope=1,intercept=0,color="red")
p

library(plyr)
a<- ddply(plotdata, .(non_rutters_num, rutters_num), summarize, sum = sum(count))

p<- ggplot(a,aes(x=non_rutters_num,y=rutters_num,size=sum))+geom_jitter(alpha=.7,color="blue")+scale_x_continuous(limits=c(0,25))
p <- p+ scale_y_continuous(limits=c(0,25))+geom_abline(slope=1,intercept=0,color="red")+scale_size_continuous(labels=comma)
p<-p+
  p


#product chart
rm(list=ls())
library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
prods <- sqlQuery(myconn,"select * from wip.products1 where atm_group in (1,2,3,4,5)")
prods$atm_group <- factor(prods$atm_group,labels=c("Sheetz\nOnly","Sheetz and\nAny Other","Branch\nOnly","Other Partner\nand Branch","Other Partner\nOnly"))
prods$product <- factor(prods$product,labels=c("Checking","Money\nMarket","Savings","Time\nDeposits","IRAs","Securities","Mortgage","Home\nEquity","Credit\nCard","Dir.\nLoan","ind.\nLoan"))


p1 <- ggplot(prods[prods$product %in%  c("Checking","Money\nMarket","Savings","Time\nDeposits","IRAs"),],aes(x=product,y=balance,fill=atm_group))
p1 <- p1+geom_boxplot(outlier.shape = NA,notch=T)+scale_y_continuous(limits=c(0,20000),labels=dollar,name="Average Balance")
p1 <- p1 + theme(legend.position="bottom")
p1

#with presummarizd data so it does not break
prods_summ1 <- ddply(prods[prods$product %in% c("Checking","Money\nMarket","Savings","Time\nDeposits","IRAs"),], .(atm_group, product),summarize, lower=quantile(balance,probs=0.25,na.rm=T), middle=quantile(balance,probs=.5,na.rm=T),upper=quantile(balance,probs=.75,na.rm=T),avg=mean(balance,na.rm=T))
prods_summ2 <- ddply(prods[prods$product %in% c("Securities","Mortgage","Home\nEquity","Credit\nCard","Dir.\nLoan","ind.\nLoan"),], .(atm_group, product),summarize, lower=quantile(balance,probs=0.25,na.rm=T), middle=quantile(balance,probs=.5,na.rm=T),upper=quantile(balance,probs=.75,na.rm=T),avg=mean(balance,na.rm=T))
prods_summ <- rbind(prods_summ1,prods_summ2)
prods_avg <-ddply(prods, .(atm_group, product),summarize, value=mean(balance,na.rm=T))

p2 <- ggplot(prods_summ[!(prods_summ$product %in% c("Mortgage" ,"Securities","Home\nEquity")),], aes(x = product, lower = lower, middle = middle, upper = upper,fill=atm_group,ymin=lower,ymax=upper))+geom_boxplot(stat = "identity")
p2 <- p2 +  scale_y_continuous(limits=c(0,50000),labels=dollar)
p2 <- p2 +theme_bw() + theme(legend.position="bottom")+ guides(col=guide_legend(nrow=2, byrow=T))
p2 <- p2 + ylab("Account Balance Range") + xlab("Product")+scale_fill_discrete(name="Type of\nCustomer")
p2 <- p2 +  theme(axis.title.y = element_text(face="bold",  size=14,color="blue") ,axis.title.x = element_text(face="bold",  size=14,color="blue"), axis.text.x = element_text(face="bold",size=10), axis.text.y = element_text(face="bold"),panel.grid.major.y = theme_line(colour = 'black', size = .5, linetype = 'dashed'))

p2 <- p2 + geom_point(aes(x = product, y=avg, color=atm_group),color="red",position=position_dodge(width=.9))
p2<- p2+scale_fill_manual(name="Type of\nCustomer",values=c("#007856","#C3E76F","#FFB300","#003359","#86499D"))
p2 <- p2 + theme(legend.title = element_text(size=12, face="bold"))
p2

p3 <- ggplot(prods_summ[(prods_summ$product %in% c("Mortgage" ,"Securities","Home\nEquity")),], aes(x = product, lower = lower, middle = middle, upper = upper,fill=atm_group,ymin=lower,ymax=upper))+geom_boxplot(stat = "identity")
p3 <- p3 +  scale_y_continuous(limits=c(0,175000),labels=dollar)
p3 <- p3 +theme_bw() + theme(legend.position="bottom")+ guides(col=guide_legend(nrow=2, byrow=T))
p3 <- p3 + ylab("Account Balance Range") + xlab("Product")+scale_fill_discrete(name="Type of\nCustomer")
p3 <- p3 +  theme(axis.title.y = element_text(face="bold",  size=14,color="blue") ,axis.title.x = element_text(face="bold",  size=14,color="blue"), axis.text.x = element_text(face="bold",size=10), axis.text.y = element_text(face="bold"),panel.grid.major.y = theme_line(colour = 'black', size = .5, linetype = 'dashed'))

p3 <- p3 + geom_point(aes(x = product, y=avg, color=atm_group),color="red",position=position_dodge(width=.9))
p3<- p3+scale_fill_manual(name="Type of\nCustomer",values=c("#007856","#C3E76F","#FFB300","#003359","#86499D"))
p3 <- p3 + theme(legend.title = element_text(size=12, face="bold"))
p3


ggsave(p2, file = "C:/Documents and Settings/ewnym5s/My Documents/ATM/products.png", width = 7, height = 5)
ggsave(p3, file = "C:/Documents and Settings/ewnym5s/My Documents/ATM/products2.png", width = 2, height = 5)
