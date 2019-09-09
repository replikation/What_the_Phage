source("https://bioconductor.org/biocLite.R")
biocLite("reshape2")
biocLite("ggplot2")
biocLite("gridExtra")
biocLite("grid")
biocLite("cowplot")


library(reshape2)
library(ggplot2)
library(gridExtra)
library(grid)
library(cowplot)  # not working on the current R environment


## tutorial
# dummy data
set.seed(777)
x.values <- seq(1:10)
y.values <-  LETTERS[seq(1:10)]
v <- sample(seq(1:10), size=100, replace=TRUE)
m <- matrix(v, nrow = 10, ncol = 10)
df <- data.frame(m)
colnames(df) <- y.values
df$x.values <- x.values
print(df)

### own input
df <- read.table("test.csv", sep=",", header = TRUE)
print(df)
###

df.melted <- melt(df, id.vars=c("x.values"))
summary(df.melted)



# heatmap
hm <- ggplot(data = df.melted, aes(x = factor(x.values), y = variable, fill = value)) + geom_tile() + 
  scale_fill_distiller(name = "Legend title", palette = "Reds", direction = 1, na.value = "transparent") +
  scale_x_discrete(breaks = unique(df.melted$x.values), labels = unique(df.melted$x.values)) + theme_gray() 
hm

#heatmap done

tmp <- ggplot_gtable(ggplot_build(hm))
leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
legend <- tmp$grobs[[leg]]

hm.clean <- hm +
  theme(axis.title.y = element_blank(), axis.text.y = element_blank(),
        axis.ticks.y = element_blank(), axis.title.x = element_blank(),
        axis.text.x = element_blank(), axis.ticks.x = element_blank(),
        legend.position="none")
hm.clean

df.melted.x.avg <- aggregate(df.melted$value, by = list(df.melted$x.values), FUN = mean)
colnames(df.melted.x.avg) <- c("XCategory", "ValueAvg")
print(df.melted.x.avg)

bp.x <- ggplot(data = df.melted.x.avg, aes(x = factor(XCategory), y = ValueAvg)) + 
  geom_bar(stat = "identity", aes(fill = ValueAvg)) + theme_gray() +
  theme(axis.title.y = element_blank(), axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(), axis.text.x = element_text(size = 15), 
        axis.title.x = element_text(size = 20, margin = margin(10,0,0,0)),
        legend.position = "none") +
  scale_fill_distiller(name = "Value", palette = "Reds", direction = 1) + 
  labs(x = "X Category")
bp.x


bp.x.flip <- switch_axis_position(bp.x, "x")

df.melted.y.avg <- aggregate(df.melted$value, by = list(df.melted$variable), FUN = mean)
colnames(df.melted.y.avg) <- c("YCategory", "ValueAvg")
print(df.melted.y.avg)


bp.y <- ggplot(data = df.melted.y.avg, aes(x = YCategory, y = ValueAvg)) + 
  geom_bar(stat = "identity", aes(fill = ValueAvg)) + coord_flip() + theme_gray() +
  theme(axis.title.x = element_blank(), axis.text.x = element_blank(),
        axis.ticks.x = element_blank(), axis.text.y = element_text(size = 15), 
        axis.title.y = element_text(size = 20, margin = margin(0,10,0,0), angle = -90),
        legend.position="none") +
  scale_fill_distiller(name = "Value", palette = "Reds", direction = 1) + 
  labs(x = "Y Category")
bp.y


bp.y.flip <- switch_axis_position(bp.y, "y")


grob.title <- textGrob("Main Title", hjust = 0.5, vjust = 0.5, gp = gpar(fontsize = 20))
grid.arrange(bp.x.flip, legend, hm.clean, bp.y.flip, nrow = 2, ncol = 2, 
             widths = c(30, 40), heights = c(40, 60), top = grob.title)
