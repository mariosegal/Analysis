library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
bbchart <- sqlQuery(myconn,"select * from wip.chart")
odbcCloseAll()

library(ggplot2)


mtbpalette <- c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3","#7AB800","#23A491","#144629")
p1<- ggplot(data=bbchart,aes(y=total, x=rank, color=total_grp))+geom_jitter(alpha=0.9)+geom_smooth(method="lm",se=F)
p1 <- p1+scale_color_manual(name="Branch Opportunity\n(Dep-Loan)",values=mtbpalette)+theme_bw()+theme(legend.position="bottom")
p1 <- p1 + theme(axis.title.x=element_text(face="bold",color="blue",size=12))+xlab("Branch Opportunity Rank (1=Highest)")
p1 <- p1 + theme(axis.title.y=element_text(face="bold",color="blue",size=12))+ylab("Checking Sales (Oct-2011 to Sep-2012)")
p1 <- p1+ theme(legend.title=element_text(face="bold",size=11))+guides(color=guide_legend(nrow=2))
p1

setwd(".\\Business Banking")
png(filename = "Rplot_oppvsales.png",
    width = 8, height = 6, units = "in", pointsize = 12,
    bg = "white", res = 300, family = "", restoreConsole = TRUE)
p1
dev.off()
