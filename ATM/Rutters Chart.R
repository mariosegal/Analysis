library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
usage <- sqlQuery(myconn,"select hhid, sheetz_count ,non_sheetz_count, sheetz_months from atm.atm_usage")
group <- sqlQuery(myconn,"select hhid, sheetz_usage_num from data.main_201303")
odbcCloseAll()

setwd("C:/Documents and Settings/ewnym5s/My Documents/ATM")

library(scales)

usage$percent <- usage$sheetz_count / (usage$sheetz_count+usage$non_sheetz_count)
names(group) <- tolower(names(group))
sheetz <- merge(usage, group,by="hhid")
sheetz$sheetz_usage <- factor(sheetz$sheetz_usage_num,ordered=T,levels=c(1,2,3,4),labels=c("Low","Med","High","None"))


library(ggplot2)
mtb_colors <- c("#007856","#C3E76F","#FFB300")
mylabs <- c("Low (~31M HHs)","Med (~10M HHs)","High (~30M HHs)")

p <- ggplot(data=sheetz[sheetz$sheetz_usage != "None",],aes(x=sheetz_months,y=percent,color=sheetz_usage))+geom_jitter(alpha=0.6)+theme_bw()
p <- p+ xlab("Number of Months Using Sheetz ATMs")+ylab("Sheetz ATM Withdrawals (Percent of Total)")
p <- p + theme(axis.title.x=element_text(face="bold",size=11),axis.title.y=element_text(face="bold",size=11))
p <- p+ scale_y_continuous(labels=percent, limits=c(0,1)) +theme(legend.position="bottom")
p <- p +scale_color_manual(values=mtb_colors,name="Sheetz \nDependency",labels=mylabs)
p

ggsave("sheetz_classification.png",width=8,height=5,dpi=300)
print(p)
dev.off()

table(sheetz$sheetz_usage)
sum(table(sheetz$sheetz_usage)[1:3])

save.image("sheetz_workspace.RData")