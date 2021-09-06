#docker run --rm -it -v $PWD:/input multifractal/ggplots:v4.1.1
install.packages("reshape2")
library(purrr)
library(readr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(reshape2)
#install.packages("readr")




#setwd ("/input")
list_of_files <- list.files( pattern = "*.tsv",
                            full.names = TRUE)
df <- list_of_files %>%
  set_names() %>% 
  map_dfr(
    ~ read_tsv(.x, col_types = cols(), col_names = FALSE),
    .id = "Prediction_tool"
  )


## get toolnames   gsub("\\..*", "", x)
df$Prediction_tool<-gsub("\\./*","",as.character(df$Prediction_tool))
df$Prediction_tool<-gsub("_.*", "",as.character(df$Prediction_tool))
df

## rename columns properly
df <- df %>% 
          rename(
            Contig = X1,
            p_value = X2
          )

# df_grouped <- df %>% group_by(Prediction_tool)
write.csv(df,"test.csv", row.names = FALSE)
uniformtheme <- theme_classic() +
		 	theme(legend.position="right", legend.direction="vertical") +
			# theme(legend.position = "none") +
      theme(legend.key.height= unit(3, 'cm'),
            legend.key.width= unit(0.5, 'cm'))+
      theme(plot.title = element_text(size=30))+
      theme(text = element_text(size=30), axis.text.x = element_text(angle = 45, hjust = 1))

dt_contigs <- df[!duplicated(df[,c('Contig')]),]
dt_tools <- df[!duplicated(df[,c('Prediction_tool')]),]
resize_h <- ( (nrow(dt_contigs)*2.0))		
resize_w <- ( (nrow(dt_tools)*2.0)	)	

plot <- ggplot(data = df, aes(x=Prediction_tool, y=Contig, fill=p_value)) + 
    geom_tile(width=0.99, height=0.99) +
    labs(x="Prediction tools", y="Contig", fill="p-Value") +
    labs(title = "Predictions") +
	  uniformtheme +
    geom_text(aes(label = round(p_value, 2))) +
    scale_fill_gradientn(colours=c("#9ebcda", "#8c6bb1", "#88419d", "#6e016b"))
    #scale_fill_gradient(low = "white", high = "steelblue")+  
print(plot)

pdf("phage-distribution.pdf",height = resize_h, width = resize_w) 
plot
dev.off()
#pdf("phage-distribution.pdf") 
#ggsave(paste0("phage_contig_heatmap_test.jpeg"), plot, width = 25, height = 10, dpi = 300, device="jpeg")
