# build a demo data set


surfaces = c('G8_A', 'G8_B', 'G8_C', 'G8_D', 'G10_A', 'G10_B', 'G10_C', 'G10_D', 'T1_A', 'T1_C', 'T1_E')

for(i in surfaces) {
	name = paste(i, '.csv',sep = "")
	raw <- read.csv(name, header = TRUE, sep=",")
	dat <- melt(raw,id.vars='xi')
	
	mn <- tapply(dat$value, dat$xi, min)
	mm <- tapply(dat$value, dat$xi, mean)
	mx <- tapply(dat$value, dat$xi, max)
	d_min <- data.frame(x=names(mn), y=unname(mn))
	d_max <- data.frame(x=names(mx), y=unname(mx))
	d_mean <- data.frame(x=names(mm), y=unname(mm))
	
	d_range <- data.frame(x=raw$xi, value=d_mean$y, Min=d_min$y, Max = d_max$y)
	
	
	p1 <- ggplot(dat,aes(x=xi,y=value))+scale_y_continuous(breaks = c(0, 0.1, 0.2, 0.3, 0.4, 0.5), limits = c(0, 0.5))+scale_x_continuous(breaks = c(-3,-2,-1,0,1,2,3,4,5), limits = c(-3, 5))+geom_ribbon(data=d_range,aes(ymin=Max,ymax=Min,x=x),fill = "grey50",group = 1, alpha=.3)+geom_point(aes(x=xi,y=value,group=variable), colour = "grey20", alpha=0.5, size=.5)+stat_summary(fun.y = "mean", colour = "black", size = 2,  geom = "line")+theme_bw(base_size = 14)+labs(title = name, x=expression(xi), y='f')
	
	ggsave(paste('gf/', i, '.png',sep = ""), width = 5, height = 5, dpi = 220)
}


